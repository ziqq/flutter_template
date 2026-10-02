import 'dart:io' as io;

/// Template maintenance preserves the starting application version.
void main(List<String> arguments) {
  io.stderr.writeln('Automatic version bumps are disabled: this template stays at 0.0.1+1.');
  io.exitCode = 1;
}
