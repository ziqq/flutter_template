import 'dart:io' as io;

final $log = io.stdout.writeln; // Log to stdout
final $err = io.stderr.writeln; // Log to stderr

/// This script is used to bump the patch version of the package.
void main(List<String> arguments) {
  try {
    $log('Bumping patch version...');
    var found = false;
    final lines = io.File('pubspec.yaml').readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      if (!lines[i].startsWith('version:')) continue;
      final versionLine = lines[i];
      final <String>[major, minor, patch] = versionLine
          .split(':')[1]
          .trim()
          .split('.');
      final $patch = int.parse(patch) + 1;
      lines[i] = 'version: $major.$minor.${$patch}';
      found = true;
      $log('Bumping from "$versionLine" to "${lines[i]}"');
      break;
    }
    if (!found) {
      $err('Error: version line not found in pubspec.yaml');
      io.exit(1);
    }
    io.File('pubspec.yaml').writeAsStringSync(lines.join('\n'));
    $log('Bumped patch version successfully.');
  } on Exception catch (e) {
    $err('Error bumping patch version: $e');
    io.exit(1);
  }
}
