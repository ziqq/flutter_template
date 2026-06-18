/*
 * Date: 03 February 2026
 */

import 'dart:convert';
import 'dart:io' as io;

final $log = io.stdout.writeln; // Log to stdout
final $err = io.stderr.writeln; // Log to stderr

/// This script used for building Flutter apps with git info (branch, sha) embedded as dart-define variables.
/// Usage: dart run tool/dart/flutter_build_with_git.dart apk --release --flavor dev --dart-define-from-file=config/development.json
Future<void> main(List<String> args) async {
  int? exitCode; // ignore: unused_local_variable

  if (args.isEmpty) {
    $err(
      'Usage:\n'
      '  dart run tool/dart/flutter_build_with_git.dart <target> [flutter build args...]\n\n'
      'Examples:\n'
      '  dart run tool/dart/flutter_build_with_git.dart appbundle --release --flavor dev --dart-define-from-file=config/development.json\n'
      '  dart run tool/dart/flutter_build_with_git.dart apk --release --flavor dev --dart-define-from-file=config/development.json\n'
      '  dart run tool/dart/flutter_build_with_git.dart ios --release --flavor dev --dart-define-from-file=config/production.json\n'
      '  dart run tool/dart/flutter_build_with_git.dart ipa --release --flavor dev --dart-define-from-file=config/production.json\n',
    );
    exitCode = 64;
    return;
  }

  try {
    final target = args.first; // apk / appbundle / ipa / ios / web / macos / windows / linux, etc.
    final passthrough = args.sublist(1);

    final info = await BuildInfo.detect();

    // Важно: даже если ветка/sha не определились, мы всё равно передаём "unknown"
    final defines = <String>[
      '--dart-define=GIT_BRANCH=${info.branch}',
      '--dart-define=GIT_SHA=${info.sha}',
      '--dart-define=GIT_SHA_SHORT=${info.shaShort}',
    ];

    final $args = <String>['build', target, ...passthrough, ...defines];

    $log('> Build info:');
    $log('  Branch: ${info.branch}');
    $log('  Commit: ${info.shaShort}');
    $log('> Running: ${info.flutterExecutable} ${[...info.flutterPrefixArgs, ...$args].join(' ')}');

    final result = await io.Process.start(
      info.flutterExecutable,
      [...info.flutterPrefixArgs, ...$args],
      mode: io.ProcessStartMode.inheritStdio,
      runInShell: io.Platform.isWindows,
    );

    exitCode = await result.exitCode;
  } on Object catch (e, s) {
    $err('Error during build: $e\n$s');
    exitCode = 1;
  }
}

/// Information about current build from git.
/// Includes branch name, full commit SHA and short commit SHA.
final class BuildInfo {
  BuildInfo({
    required this.branch,
    required this.sha,
    required this.shaShort,
    this.flutterExecutable = 'flutter',
    this.flutterPrefixArgs = const <String>[],
  });

  /// Current git branch name.
  final String branch;

  /// Full commit SHA.
  final String sha;

  /// Short commit SHA (8 characters).
  final String shaShort;

  /// Either "flutter" or "fvm"
  final String flutterExecutable;

  /// Empty for "flutter", or ["flutter"] for "fvm flutter"
  final List<String> flutterPrefixArgs;

  /// Detect build info from git and environment variables.
  static Future<BuildInfo> detect() async {
    try {
      final flutterCmd = await _pickFlutterCommand();

      final sha = _firstNonEmpty([
        io.Platform.environment['GIT_SHA'],
        await _git(['rev-parse', 'HEAD']),
      ], fallback: 'unknown');

      final shaShort = _firstNonEmpty([
        io.Platform.environment['GIT_SHA_SHORT'],
        if (sha != 'unknown') sha.substring(0, sha.length >= 8 ? 8 : sha.length) else null,
      ], fallback: 'unknown');

      var branch = _firstNonEmpty([
        io.Platform.environment['GIT_BRANCH'],

        // GitHub Actions
        io.Platform.environment['GITHUB_HEAD_REF'],
        io.Platform.environment['GITHUB_REF_NAME'],
        _stripRef(io.Platform.environment['GITHUB_REF']),

        // GitLab CI
        io.Platform.environment['CI_MERGE_REQUEST_SOURCE_BRANCH_NAME'],
        io.Platform.environment['CI_COMMIT_BRANCH'],

        // Bitrise / generic
        io.Platform.environment['BITRISE_GIT_BRANCH'],
        io.Platform.environment['BRANCH_NAME'],
      ], fallback: '');

      if (branch.isEmpty) {
        branch = _firstNonEmpty([
          await _git(['branch', '--show-current']),
          await _git(['rev-parse', '--abbrev-ref', 'HEAD']),
        ], fallback: 'unknown');
      }

      if (branch == 'HEAD' || branch.trim().isEmpty) branch = 'unknown';

      return BuildInfo(
        branch: branch,
        sha: sha,
        shaShort: shaShort,
        flutterExecutable: flutterCmd.executable,
        flutterPrefixArgs: flutterCmd.prefixArgs,
      );
    } on Object catch (e, s) {
      $err('Error while detecting git info: $e\n$s');
      return BuildInfo(branch: 'unknown', sha: 'unknown', shaShort: 'unknown');
    }
  }

  /// Strip refs/heads/ or refs/tags/ prefix from git ref.
  static String _stripRef(String? ref) {
    if (ref == null || ref.isEmpty) return '';
    var r = ref;
    if (r.startsWith('refs/heads/')) r = r.substring('refs/heads/'.length);
    if (r.startsWith('refs/tags/')) r = r.substring('refs/tags/'.length);
    return r;
  }

  /// Return the first non-empty trimmed string from the list, or fallback if none found.
  static String _firstNonEmpty(List<String?> values, {required String fallback}) {
    for (final v in values) {
      final s = v?.trim();
      if (s != null && s.isNotEmpty) return s;
    }
    return fallback;
  }

  /// Run git command with given arguments and return trimmed stdout, or null on error.
  static Future<String?> _git(List<String> args) async {
    try {
      final result = await io.Process.run(
        'git',
        args,
        runInShell: io.Platform.isWindows,
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
      if (result.exitCode != 0) return null;
      final out = switch (result.stdout) {
        String s => s.trim(),
        _ => null,
      };
      return out == null || out.isEmpty ? null : out;
    } on Object catch (e, s) {
      $err('Error while running git ${args.join(' ')}: $e\n$s');
      return null;
    }
  }
}

/// Pick flutter command to use (either "flutter" or "fvm flutter").
Future<({String executable, List<String> prefixArgs})> _pickFlutterCommand() async {
  try {
    // Check if FLUTTER_CMD env variable is set (e.g. by FVM or manually)
    final envCmd = io.Platform.environment['FLUTTER_CMD']?.trim();
    if (envCmd != null && envCmd.isNotEmpty) {
      final parts = envCmd.split(RegExp(r'\s+'));
      return (executable: parts.first, prefixArgs: parts.sublist(1));
    }

    // If not set, try to detect FVM
    final hasFvm = await _hasCommand('fvm');
    if (hasFvm) return const (executable: 'fvm', prefixArgs: ['flutter']);

    // Else use flutter without fvm
    return const (executable: 'flutter', prefixArgs: <String>[]);
  } on Object catch (e, s) {
    $err('Error while detecting flutter command: $e\n$s');
    return const (executable: 'flutter', prefixArgs: <String>[]);
  }
}

/// Check if a command is available in the system.
Future<bool> _hasCommand(String cmd) async {
  try {
    final res = await io.Process.run(cmd, ['--version'], runInShell: io.Platform.isWindows);
    return res.exitCode == 0;
  } on Object catch (e, s) {
    $err('Error while checking command "$cmd": $e\n$s');
    return false;
  }
}
