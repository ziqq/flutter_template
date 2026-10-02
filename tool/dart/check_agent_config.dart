import 'dart:convert';
import 'dart:io';

final List<String> _issues = <String>[];

void main() {
  final root = Directory.current;
  final skillsRoot = Directory('${root.path}/.agents/skills');
  final customAgentsRoot = Directory('${root.path}/.codex/agents');

  if (!skillsRoot.existsSync()) {
    _issues.add('Missing .agents/skills directory.');
  }

  final skillFiles =
      (skillsRoot.existsSync()
            ? skillsRoot
                  .listSync()
                  .whereType<Directory>()
                  .map((directory) => File('${directory.path}/SKILL.md'))
                  .toList()
            : <File>[])
        ..sort((left, right) => left.path.compareTo(right.path));

  final names = <String, String>{};
  for (final skillFile in skillFiles) {
    _validateSkill(root, skillFile, names);
  }

  _validateSkillIndex(root, skillFiles);

  final customAgentFiles =
      (customAgentsRoot.existsSync()
            ? customAgentsRoot.listSync().whereType<File>().where((file) => file.path.endsWith('.toml')).toList()
            : <File>[])
        ..sort((left, right) => left.path.compareTo(right.path));
  for (final agentFile in customAgentFiles) {
    _validateCustomAgent(root, agentFile);
  }

  _validateProjectConfig(root);
  _validateClaudeConfig(root);

  final markdownFiles = _guidanceMarkdownFiles(root);
  for (final file in markdownFiles) {
    _validateMarkdownLinks(root, file);
    _validatePortableContent(root, file);
  }

  if (_issues.isNotEmpty) {
    stderr.writeln('Agent configuration validation failed:');
    for (final issue in _issues) {
      stderr.writeln('- $issue');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Agent configuration OK: ${skillFiles.length} skills, '
    '${customAgentFiles.length} custom agents, ${markdownFiles.length} Markdown files.',
  );
}

void _validateSkill(Directory root, File skillFile, Map<String, String> names) {
  final path = _relativePath(root, skillFile.path);
  if (!skillFile.existsSync()) {
    _issues.add('$path is missing.');
    return;
  }

  final lines = skillFile.readAsLinesSync();
  if (lines.isEmpty || lines.first.trim() != '---') {
    _issues.add('$path must start with YAML frontmatter.');
    return;
  }

  final closingIndex = lines.indexWhere((line) => line.trim() == '---', 1);
  if (closingIndex < 0) {
    _issues.add('$path has unclosed YAML frontmatter.');
    return;
  }

  final metadata = <String, String>{};
  for (final line in lines.sublist(1, closingIndex)) {
    if (line.trim().isEmpty) continue;
    final match = RegExp(r'^([a-zA-Z0-9_-]+):\s*(.+)$').firstMatch(line);
    if (match == null) {
      _issues.add('$path has unsupported frontmatter syntax: $line');
      continue;
    }
    metadata[match.group(1)!] = _unquote(match.group(2)!.trim());
  }

  const allowedKeys = <String>{'name', 'description'};
  final unexpectedKeys = metadata.keys.where((key) => !allowedKeys.contains(key));
  for (final key in unexpectedKeys) {
    _issues.add('$path has unsupported frontmatter key "$key".');
  }

  final name = metadata['name'];
  final description = metadata['description'];
  if (name == null || name.isEmpty) _issues.add('$path is missing a skill name.');
  if (description == null || description.isEmpty) _issues.add('$path is missing a skill description.');
  if (name == null) return;

  if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(name)) {
    _issues.add('$path has invalid skill name "$name".');
  }

  final directoryName = skillFile.parent.uri.pathSegments.where((segment) => segment.isNotEmpty).last;
  if (directoryName != name) {
    _issues.add('$path declares "$name" but its directory is "$directoryName".');
  }

  final previousPath = names[name];
  if (previousPath != null) {
    _issues.add('Duplicate skill name "$name" in $previousPath and $path.');
  } else {
    names[name] = path;
  }
}

void _validateSkillIndex(Directory root, List<File> skillFiles) {
  final index = File('${root.path}/.agents/README.md');
  if (!index.existsSync()) {
    _issues.add('Missing .agents/README.md skill index.');
    return;
  }

  final contents = index.readAsStringSync();
  for (final skillFile in skillFiles) {
    final directoryName = skillFile.parent.uri.pathSegments.where((segment) => segment.isNotEmpty).last;
    final expectedLink = './skills/$directoryName/SKILL.md';
    if (!contents.contains(expectedLink)) {
      _issues.add('.agents/README.md does not index $expectedLink.');
    }
  }
}

void _validateCustomAgent(Directory root, File file) {
  final path = _relativePath(root, file.path);
  final contents = file.readAsStringSync();
  for (final key in <String>['name', 'description', 'developer_instructions']) {
    if (!RegExp('^$key\\s*=', multiLine: true).hasMatch(contents)) {
      _issues.add('$path is missing required key "$key".');
    }
  }
  if (RegExp(r'^instructions\s*=', multiLine: true).hasMatch(contents)) {
    _issues.add('$path uses legacy "instructions"; use "developer_instructions".');
  }
}

void _validateProjectConfig(Directory root) {
  final config = File('${root.path}/.codex/config.toml');
  if (!config.existsSync()) {
    _issues.add('Missing .codex/config.toml.');
    return;
  }

  final contents = config.readAsStringSync();
  if (!contents.contains('#:schema https://developers.openai.com/codex/config-schema.json')) {
    _issues.add('.codex/config.toml is missing the official schema declaration.');
  }
}

void _validateClaudeConfig(Directory root) {
  final claudeRoot = Directory('${root.path}/.claude');
  if (!claudeRoot.existsSync()) return;

  final settings = File('${claudeRoot.path}/settings.json');
  if (!settings.existsSync()) {
    _issues.add('Missing .claude/settings.json.');
  } else {
    try {
      jsonDecode(settings.readAsStringSync());
    } on FormatException catch (error) {
      _issues.add('.claude/settings.json is invalid JSON: ${error.message}');
    }
  }

  final skillsLink = Link('${claudeRoot.path}/skills');
  if (!skillsLink.existsSync()) {
    _issues.add('Missing .claude/skills symlink to ../.agents/skills.');
  } else if (skillsLink.targetSync() != '../.agents/skills') {
    _issues.add('.claude/skills must target ../.agents/skills.');
  }

  for (final path in <String>[
    '.claude/statusline.sh',
    '.claude/hooks/format-dart.sh',
    '.claude/hooks/notify.sh',
    '.claude/hooks/stop-reminder.sh',
  ]) {
    if (!File('${root.path}/$path').existsSync()) {
      _issues.add('Missing $path.');
    }
  }
}

List<File> _guidanceMarkdownFiles(Directory root) {
  final files = <File>[];
  for (final path in <String>[
    'AGENTS.md',
    'CLAUDE.md',
    'docs/agent-skill-authoring.md',
    'docs/agent-configuration.md',
  ]) {
    final file = File('${root.path}/$path');
    if (file.existsSync()) files.add(file);
  }

  final agentsRoot = Directory('${root.path}/.agents');
  if (agentsRoot.existsSync()) {
    files.addAll(agentsRoot.listSync(recursive: true).whereType<File>().where((file) => file.path.endsWith('.md')));
  }
  final claudeRoot = Directory('${root.path}/.claude');
  if (claudeRoot.existsSync()) {
    files.addAll(
      claudeRoot
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((file) => file.path.endsWith('.md')),
    );
  }
  files.sort((left, right) => left.path.compareTo(right.path));
  return files;
}

void _validateMarkdownLinks(Directory root, File file) {
  final contents = file.readAsStringSync();
  final linkPattern = RegExp(r'\[[^\]]+\]\(([^)]+)\)');
  for (final match in linkPattern.allMatches(contents)) {
    var target = match.group(1)!.trim();
    if (target.startsWith('<') && target.endsWith('>')) {
      target = target.substring(1, target.length - 1);
    }
    if (target.isEmpty ||
        target.startsWith('#') ||
        target.startsWith('http://') ||
        target.startsWith('https://') ||
        target.startsWith('mailto:')) {
      continue;
    }

    final pathOnly = target.split('#').first;
    final resolved = file.parent.uri.resolve(pathOnly).toFilePath();
    if (!File(resolved).existsSync() && !Directory(resolved).existsSync() && !Link(resolved).existsSync()) {
      _issues.add('${_relativePath(root, file.path)} links to missing path "$target".');
    }
  }
}

void _validatePortableContent(Directory root, File file) {
  const forbiddenValues = <String>[
    'Tetradka',
    'packages/localization/',
    'mise exec -- just',
    '.Codex/skills',
    'docs/CONTRIBUTING.md',
    'docs/contributing.md',
    'packages/ui/lib/src/widgets/_widgets.dart',
  ];
  final contents = file.readAsStringSync();
  for (final value in forbiddenValues) {
    if (contents.contains(value)) {
      _issues.add('${_relativePath(root, file.path)} contains stale reference "$value".');
    }
  }
}

String _relativePath(Directory root, String path) {
  final prefix = '${root.path}${Platform.pathSeparator}';
  return path.startsWith(prefix) ? path.substring(prefix.length) : path;
}

String _unquote(String value) {
  if (value.length >= 2 &&
      ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'")))) {
    return value.substring(1, value.length - 1);
  }
  return value;
}
