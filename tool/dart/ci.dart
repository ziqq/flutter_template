/*
 * Date: 27 May 2026
 */

// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:meta/meta.dart';

final $log = io.stdout.writeln;
final $err = io.stderr.writeln;

const String _clearLine = '\r\x1B[2K';

/// Check the current platform is `Windows`.
final _isWindows = io.Platform.isWindows;

const String _dart = '__DART__';
const String _flutter = '__FLUTTER__';
const String _fluttergen = '__FLUTTERGEN__';

const String _flags = '__FLAGS__';
const String _verbose = '__VERBOSE__';

const List<String> _packages = <String>['ui'];

late final Toolchain _toolchain;
late final RunOptions _runOptions;

@internal
final class RunOptions {
  const RunOptions({required this.workflow, required this.verbose});

  final String? workflow;
  final bool verbose;
}

@internal
final class Toolchain {
  const Toolchain({required this.dart, required this.flutter, required this.fluttergen, required this.label});

  /// Default system toolchain, using globally available `dart`, `flutter`, and `fluttergen` commands.
  @literal
  const Toolchain.system()
    : label = 'system',
      dart = const <String>['dart'],
      flutter = const <String>['flutter'],
      fluttergen = const <String>['fluttergen'];

  /// FVM toolchain, using `fvm` to run `dart`, `flutter`, and `fluttergen` commands within the configured Flutter version.
  @literal
  const Toolchain.fvm()
    : label = 'fvm',
      dart = const <String>['fvm', 'dart'],
      flutter = const <String>['fvm', 'flutter'],
      fluttergen = const <String>['fvm', 'fluttergen'];

  final String label;
  final List<String> dart;
  final List<String> flutter;
  final List<String> fluttergen;

  String get dartShell => dart.join(' ');

  String get flutterShell => flutter.join(' ');

  String get fluttergenShell => fluttergen.join(' ');
}

@internal
final class Workflow {
  const Workflow({required this.name, required this.groups, this.description});

  final String name;
  final String? description;
  final List<Group> groups;
}

@internal
final class Group {
  const Group({required this.name, required this.steps});

  final String name;
  final List<Step> steps;
}

@internal
final class Step {
  const Step({required this.name, required this.command, this.workingDirectory});

  /// Create a step for running `fluttergen` to generate Flutter assets.
  static final Step flutter_gen = Step(
    name: 'fluttergen',
    command: _parseCommand('$_dart pub global activate flutter_gen && $_fluttergen -c pubspec.yaml'),
  );

  /// Create a step for running `dart format` to format code in the app and packages sources.
  static final Step format = Step(name: 'formating', command: _parseCommand(_formatScript()));

  /// Create a step for running unit tests for the project packages.
  static final Step test_packages = Step(
    name: 'test-packages',
    command: _parseCommand('VERBOSE=$_verbose bash ./tool/scripts/test-packages.sh ${_packages.join(' ')}'),
  );

  /// Create a step for running unit and widget tests for the app.
  static final Step test_app = Step(
    name: 'test-app',
    command: _parseCommand(
      '$_flutter test $_flags '
      'test/unit_test.dart test/widget_test.dart && '
      'if command -v lcov >/dev/null 2>&1; then '
      'lcov --remove coverage/lcov.info "packages/*" "**/generated/*" "*.g.dart" -o coverage/lcov.cleaned.info; '
      'else echo "Skip: lcov is not installed, keeping raw coverage/lcov.info."; fi && '
      'if command -v genhtml >/dev/null 2>&1; then '
      'coverage_input="coverage/lcov.cleaned.info"; '
      r'if [ ! -f "$coverage_input" ]; then coverage_input="coverage/lcov.info"; fi; '
      r'genhtml "$coverage_input" --output=coverage -o coverage/html; '
      'else echo "Skip: genhtml is not installed, HTML coverage will not be generated."; fi',
    ),
  );

  /// Create a step for running `dart format` to format code in the project packages sources.
  static final Step analyze_packages = Step(name: 'analyze-packages', command: _parseCommand(_analyzePackagesScript()));

  /// Create a step for running `dart format` to format code in the app sources.
  static const Step analyze_app = Step(
    name: 'analyze-app',
    command: <String>[_flutter, 'analyze', '--fatal-warnings', '--no-fatal-infos', 'lib/', 'test/'],
  );

  /// Create a step for running `sheety_localization` code generation,
  /// which generates localization files from Google Sheets.
  static final Step sheety_localization = Step(
    name: 'sheety-localizations',
    command: _parseCommand(
      '$_dart pub global activate sheety_localization && '
      '$_dart pub global run sheety_localization:generate '
      '--credentials=credentials.json '
      '--sheet=1kEQwRk5fC_xVjY31liZU2nLIY84fRtce_HMf5-oBe2g '
      '--lib=lib '
      '--arb=src/l10n '
      '--gen=src/generated --prefix=app --format --no-include-empty --no-last-modified '
      '--author=\'Anton Ustinoff <a.a.ustinoff@gmail.com>\' '
      '--comment=\'Generated from Google Sheets\' '
      '--context=\'From Google Sheets\' '
      '--ignore=help,backend,backend-monetization,telegram-monetization,locales,template',
    ),
    workingDirectory: 'packages/localization',
  );

  /// Create a step for running `flutter gen-l10n` to generate default localizations.
  static final Step l10n = Step(
    name: 'localizations',
    command: _parseCommand(
      '$_dart pub global activate intl_utils && '
      '$_dart pub global run intl_utils:generate && '
      '$_flutter gen-l10n '
      '--arb-dir lib/src/common/localization/translations '
      '--output-dir lib/src/common/localization/generated '
      '--template-arb-file intl_ru.arb',
    ),
  );

  /// Create a step for running `pubspec_generator` code generation.
  static final Step pubspec_generator = Step(
    name: 'pubspec-generator',
    command: _parseCommand(
      '$_dart pub global activate pubspec_generator && '
      '$_dart pub global run pubspec_generator:generate '
      '-o lib/src/common/constants/generated/pubspec.yaml.g.dart',
    ),
  );

  /// Create a step for running `build_runner` code generation.
  static final Step build_runner = Step(
    name: 'build-runner',
    command: _parseCommand(
      '$_dart --disable-analytics && $_dart run build_runner build --delete-conflicting-outputs --release',
    ),
  );

  /// Create a step for running `pub get` to fetch dependencies.
  static const Step pubget = Step(name: 'pub-get', command: <String>[_flutter, 'pub', 'get']);

  /// Create a step for stopping active Dart and Flutter processes.
  static final Step cache_clean_stop_processes = Step(
    name: 'stop-processes',
    command: _parseCommand('command -v pkill >/dev/null 2>&1 && pkill -f "dart|flutter" 2>/dev/null || true'),
  );

  /// Create a step for removing global pub cache directories.
  static final Step cache_clean_pub_cache = Step(
    name: 'pub-cache',
    command: _parseCommand(
      r'[ -d "$HOME/.pub-cache" ] && rm -rf "$HOME/.pub-cache" || true; '
      r'[ -n "$PUB_CACHE" ] && [ -d "$PUB_CACHE" ] && rm -rf "$PUB_CACHE" || true',
    ),
  );

  /// Create a step for removing the Dart language server cache.
  static final Step cache_clean_dart_server = Step(
    name: 'dart-server-cache',
    command: _parseCommand(r'[ -d "$HOME/.dartServer" ] && rm -rf "$HOME/.dartServer" || true'),
  );

  /// Create a step for removing iOS caches on macOS hosts.
  static final Step cache_clean_ios = Step(
    name: 'ios-cache',
    command: _parseCommand(
      r'if [ "$(uname -s 2>/dev/null || echo Unknown)" = "Darwin" ]; then '
      'bash ./tool/scripts/flutter-clean-ios.sh; '
      'else '
      'echo "Skip: iOS cache cleanup is macOS-only."; '
      'fi',
    ),
  );

  /// Create a step for removing workspace-local caches and reports.
  static final Step cache_clean_workspace = Step(
    name: 'workspace-caches',
    command: _parseCommand('rm -rf .dart_tool .packages build coverage || true'),
  );

  /// Create a step for refreshing CocoaPods dependencies on macOS hosts.
  static final Step pod_install = Step(
    name: 'pod-install',
    command: _parseCommand(
      r'if [ "$(uname -s 2>/dev/null || echo Unknown)" = "Darwin" ]; then '
      'cd ios && pod install; '
      'else '
      'echo "Skip: pod install is macOS-only."; '
      'fi',
    ),
  );

  final String name;
  final List<String> command;
  final String? workingDirectory;
}

@internal
final class StepException implements Exception {
  const StepException({
    required this.step,
    required this.command,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final String step;
  final List<String> command;
  final int exitCode;
  final String stdout;
  final String stderr;
}

final List<Workflow> _workflows = <Workflow>[
  Workflow(
    name: 'precommit',
    description: 'Dependencies, generation, analysis, and unit tests.',
    groups: <Group>[
      const Group(name: 'Dependencies', steps: <Step>[Step.pubget]),
      Group(name: 'Code generation', steps: <Step>[Step.pubspec_generator, Step.build_runner, Step.format]),
      Group(name: 'Static analysis', steps: <Step>[Step.analyze_app, Step.analyze_packages]),
      Group(name: 'Tests', steps: <Step>[Step.test_app, Step.test_packages]),
    ],
  ),
  Workflow(
    name: 'gen',
    description: 'Dependencies and code generation commands.',
    groups: <Group>[
      const Group(name: 'Dependencies', steps: <Step>[Step.pubget]),
      Group(
        name: 'Code generation',
        steps: <Step>[
          Step.flutter_gen,
          Step.l10n,
          Step.sheety_localization,
          Step.pubspec_generator,
          Step.build_runner,
          Step.format,
        ],
      ),
    ],
  ),
  Workflow(
    name: 'check',
    description: 'Dependencies and static analysis only.',
    groups: <Group>[
      const Group(name: 'Dependencies', steps: <Step>[Step.pubget]),
      Group(name: 'Static analysis', steps: <Step>[Step.analyze_app, Step.analyze_packages]),
    ],
  ),
  Workflow(
    name: 'test',
    description: 'Dependencies and unit tests for app and packages.',
    groups: <Group>[
      const Group(name: 'Dependencies', steps: <Step>[Step.pubget]),
      Group(name: 'Tests', steps: <Step>[Step.test_app, Step.test_packages]),
    ],
  ),
  const Workflow(
    name: 'get',
    description: 'Dependencies only.',
    groups: <Group>[
      Group(name: 'Dependencies', steps: <Step>[Step.pubget]),
    ],
  ),
  Workflow(
    name: 'format',
    description: 'Format app and workspace packages.',
    groups: <Group>[
      Group(name: 'Formatting', steps: <Step>[Step.format]),
    ],
  ),
  Workflow(
    name: 'cache-clean',
    description: 'Full clean of Dart, Flutter, and workspace caches.',
    groups: <Group>[
      Group(
        name: 'Full cache clean',
        steps: <Step>[
          Step.cache_clean_stop_processes,
          Step.cache_clean_pub_cache,
          Step.cache_clean_dart_server,
          Step.cache_clean_ios,
          Step.cache_clean_workspace,
        ],
      ),
      Group(name: 'Dependencies', steps: <Step>[Step.pubget, Step.pod_install]),
    ],
  ),
  Workflow(
    name: 'build-runner',
    description: 'Run build_runner for the app workspace.',
    groups: <Group>[
      const Group(name: 'Dependencies', steps: <Step>[Step.pubget]),
      Group(name: 'Code generation', steps: <Step>[Step.build_runner]),
    ],
  ),
  Workflow(
    name: 'fluttergen',
    description: 'Generate Flutter assets.',
    groups: <Group>[
      const Group(name: 'Dependencies', steps: <Step>[Step.pubget]),
      Group(name: 'Code generation', steps: <Step>[Step.flutter_gen]),
    ],
  ),
  Workflow(
    name: 'l10n',
    description: 'Generate default localizations.',
    groups: <Group>[
      const Group(name: 'Dependencies', steps: <Step>[Step.pubget]),
      Group(name: 'Code generation', steps: <Step>[Step.l10n]),
    ],
  ),
  Workflow(
    name: 'pubspec-generator',
    description: 'Generate pubspec metadata constants.',
    groups: <Group>[
      const Group(name: 'Dependencies', steps: <Step>[Step.pubget]),
      Group(name: 'Code generation', steps: <Step>[Step.pubspec_generator]),
    ],
  ),
  Workflow(
    name: 'sheety-localization',
    description: 'Generate package localization from Google Sheets.',
    groups: <Group>[
      const Group(name: 'Dependencies', steps: <Step>[Step.pubget]),
      Group(name: 'Code generation', steps: <Step>[Step.sheety_localization]),
    ],
  ),
  const Workflow(
    name: 'analyze-app',
    description: 'Analyze app sources only.',
    groups: <Group>[
      Group(name: 'Static analysis', steps: <Step>[Step.analyze_app]),
    ],
  ),
  Workflow(
    name: 'analyze-packages',
    description: 'Analyze workspace packages only.',
    groups: <Group>[
      Group(name: 'Static analysis', steps: <Step>[Step.analyze_packages]),
    ],
  ),
  Workflow(
    name: 'test-app',
    description: 'Run app unit and widget tests only.',
    groups: <Group>[
      Group(name: 'Test app', steps: <Step>[Step.pubget, Step.test_app]),
    ],
  ),
  Workflow(
    name: 'test-packages',
    description: 'Run package tests only.',
    groups: <Group>[
      Group(name: 'Test packages', steps: <Step>[Step.pubget, Step.test_packages]),
    ],
  ),
];

/// Tool for running CI commands locally with structured logs.
/// Usage: `fvm dart run tool/dart/ci.dart <workflow>`
/// Available workflows: precommit, gen, check, test.
Future<void> main(List<String> args) async {
  _toolchain = await _detectToolchain();
  try {
    _runOptions = _parseRunOptions(args);
  } on FormatException catch (error) {
    $err(error.message);
    $err('');
    _printUsage();
    io.exitCode = 64;
    return;
  }

  final command = _runOptions.workflow;
  if (command == null || command == '--help' || command == '-h' || command == 'help') {
    _printUsage();
    return;
  }

  final workflow = _workflows.where((item) => item.name == command).firstOrNull;
  if (workflow == null) {
    $err('Unknown workflow: $command\n');
    _printUsage();
    io.exitCode = 64;
    return;
  }

  try {
    await _runWorkflow(workflow);
    $log('');
    $log('Success: workflow "${workflow.name}" completed.');
  } on StepException catch (error) {
    $err('');
    $err('Command failed for step "${error.step}" with exit code ${error.exitCode}:');
    $err(error.command.join(' '));

    final stdoutText = error.stdout.trimRight();
    if (stdoutText.isNotEmpty) {
      $err('');
      $err('Logs:');
      $err(stdoutText);
    }

    final stderrText = error.stderr.trimRight();
    if (stderrText.isNotEmpty) {
      $err('');
      $err('Error:');
      $err(stderrText);
    }

    io.exitCode = error.exitCode;
  }
}

void _printUsage() {
  $log('Usage: fvm dart run tool/dart/ci.dart <workflow> [--verbose]');
  $log('');
  $log('Options:');
  $log('  --verbose, -v   Stream child command output immediately.');
  $log('');
  $log('Available workflows:');
  for (final workflow in _workflows) {
    final description = workflow.description == null ? '' : ' - ${workflow.description}';
    $log('  ${workflow.name}$description');
  }
}

RunOptions _parseRunOptions(List<String> args) {
  String? workflow;
  var verbose = false;

  for (final arg in args) {
    switch (arg) {
      case '--verbose':
      case '-v':
        verbose = true;
      case '--help':
      case '-h':
      case 'help':
        workflow ??= arg;
      default:
        if (arg.startsWith('-')) {
          throw FormatException('Unknown option: $arg');
        }

        if (workflow != null) {
          throw FormatException('Unexpected argument: $arg');
        }

        workflow = arg;
    }
  }

  return RunOptions(workflow: workflow, verbose: verbose);
}

Future<void> _runWorkflow(Workflow workflow) async {
  final totalGroups = workflow.groups.length;

  for (var groupIndex = 0; groupIndex < workflow.groups.length; groupIndex++) {
    final group = workflow.groups[groupIndex];
    $log('[${groupIndex + 1}/$totalGroups] ${group.name}');

    for (var stepIndex = 0; stepIndex < group.steps.length; stepIndex++) {
      final step = group.steps[stepIndex];
      final isLastStep = stepIndex == group.steps.length - 1;
      final branch = isLastStep ? '└─' : '├─';
      final prefix = '  $branch [${stepIndex + 1}/${group.steps.length}] ${step.name}';
      final stopwatch = Stopwatch()..start();
      Timer? progressTimer;

      if (_runOptions.verbose) {
        $log(prefix);
      } else {
        _writeStepProgress(prefix, stopwatch.elapsed);
        progressTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          _writeStepProgress(prefix, stopwatch.elapsed);
        });
      }

      try {
        await _runCommand(step);
        stopwatch.stop();
        progressTimer?.cancel();
        if (_runOptions.verbose) {
          $log('    done in ${_formatDuration(stopwatch.elapsed)}');
        } else {
          $log('$_clearLine${_pad(prefix)}${_formatDuration(stopwatch.elapsed)}');
        }
      } on StepException {
        stopwatch.stop();
        progressTimer?.cancel();
        if (_runOptions.verbose) {
          $err('    failed after ${_formatDuration(stopwatch.elapsed)}');
        } else {
          $err('$_clearLine$prefix failed after ${_formatDuration(stopwatch.elapsed)}');
        }
        rethrow;
      }
    }
  }
}

void _writeStepProgress(String prefix, Duration duration) {
  io.stdout.write('$_clearLine${_pad(prefix)}${_formatDuration(duration)}');
}

String _pad(String text) {
  const width = 74;
  return text.length >= width ? '$text ' : text.padRight(width);
}

String _formatDuration(Duration duration) {
  if (duration.inMilliseconds < 1000) {
    return '${duration.inMilliseconds}ms';
  }

  if (duration.inSeconds < 60) {
    return '${duration.inSeconds}s';
  }

  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '${minutes}m ${seconds}s';
}

String _appTestFlagsValue() {
  const commonFlags = '--color --coverage --platform=tester --reporter=expanded --timeout=30s';
  final concurrency = _runOptions.verbose ? 1 : 50;
  return '$commonFlags --concurrency=$concurrency';
}

String _testVerboseValue() => _runOptions.verbose ? '1' : '0';

List<String> _parseCommand(String script) {
  if (_isWindows) return <String>['cmd', '/C', script];
  return <String>['bash', '-lc', script];
}

String _formatScript() {
  final directories = <String>[
    '.',
    ..._packages.map((package) => 'packages/$package'),
  ].map((directory) => '"$directory"').join(' ');
  return 'for dir in $directories; do '
      r'if [ ! -d "$dir" ]; then echo "Directory not found: $dir"; exit 1; fi; '
      r'cd "$dir" && '
      'find lib test -path "*/generated/*" -prune -o -type f -name "*.dart" ! -name "*.*.dart" ! -name "messages_.*.dart" ! -name "l10n.dart" -exec $_dart format --line-length 120 {} + 2>/dev/null || exit 1; '
      'cd - >/dev/null || exit 1; '
      'done';
}

String _analyzePackagesScript() {
  final packages = _packages.map((package) => '"$package"').join(' ');
  return 'for package in $packages; do '
      r'cd "packages/$package" && '
      '$_flutter analyze --fatal-warnings --no-fatal-infos lib/ test/ || exit 1; '
      'cd - >/dev/null || exit 1; '
      'done';
}

Future<Toolchain> _detectToolchain() async {
  try {
    if (await _commandExists('fvm')) return const Toolchain.fvm();
    return const Toolchain.system();
  } on Object catch (e, s) {
    $err('Error detecting toolchain, falling back to system: $e');
    $err('StackTrace: $s');
    return const Toolchain.system();
  }
}

Future<bool> _commandExists(String command) async {
  try {
    final result = await io.Process.run(
      _isWindows ? 'where' : 'command',
      _isWindows ? <String>[command] : <String>['-v', command],
      runInShell: _isWindows,
    );
    return result.exitCode == 0;
  } on Object catch (e, s) {
    $err('Error checking for command "$command": $e');
    $err('StackTrace: $s');
    return false;
  }
}

List<String> _resolveCommand(List<String> command) {
  final resolved = <String>[];

  for (final part in command) {
    if (part == _dart) {
      resolved.addAll(_toolchain.dart);
      continue;
    }

    if (part == _flutter) {
      resolved.addAll(_toolchain.flutter);
      continue;
    }

    if (part == _fluttergen) {
      resolved.addAll(_toolchain.fluttergen);
      continue;
    }

    resolved.add(
      part
          .replaceAll(_dart, _toolchain.dartShell)
          .replaceAll(_flutter, _toolchain.flutterShell)
          .replaceAll(_fluttergen, _toolchain.fluttergenShell)
          .replaceAll(_flags, _appTestFlagsValue())
          .replaceAll(_verbose, _testVerboseValue()),
    );
  }

  return resolved;
}

Future<void> _runCommand(Step step) async {
  final command = _resolveCommand(step.command);
  final process = await io.Process.start(
    command.first,
    command.sublist(1),
    workingDirectory: step.workingDirectory,
    runInShell: _isWindows,
  );

  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();

  final stdoutFuture = process.stdout.transform(utf8.decoder).forEach((chunk) {
    stdoutBuffer.write(chunk);
    if (_runOptions.verbose) io.stdout.write(chunk);
  });
  final stderrFuture = process.stderr.transform(utf8.decoder).forEach((chunk) {
    stderrBuffer.write(chunk);
    if (_runOptions.verbose) io.stderr.write(chunk);
  });
  final exitCodeValue = await process.exitCode;
  await Future.wait<void>(<Future<void>>[stdoutFuture, stderrFuture]);

  if (exitCodeValue != 0) {
    throw StepException(
      step: step.name,
      command: command,
      exitCode: exitCodeValue,
      stdout: stdoutBuffer.toString(),
      stderr: stderrBuffer.toString(),
    );
  }
}
