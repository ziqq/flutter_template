import 'dart:io' as io;

final $log = io.stdout.writeln;
final $err = io.stderr.writeln;

/// Updates the build number (after +) to the current UNIX timestamp.
void main(List<String> arguments) {
  try {
    $log('Updating build version...');
    final lines = io.File('pubspec.yaml').readAsLinesSync();
    final unixTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var found = false;

    for (var i = 0; i < lines.length; i++) {
      if (!lines[i].startsWith('version:')) continue;

      final versionLine = lines[i];
      final versionParts = versionLine.split(':')[1].trim().split('+');
      final versionNumber = versionParts[0];

      lines[i] = 'version: $versionNumber+$unixTime';
      $log('Updated version: ${lines[i]}');
      found = true;
      break;
    }

    if (!found) {
      $err('Error: version line not found in pubspec.yaml');
      io.exit(1);
    }

    io.File('pubspec.yaml').writeAsStringSync(lines.join('\n'));
  } on Exception catch (e) {
    $err('Error updating build version: $e');
    io.exit(1);
  }
}
