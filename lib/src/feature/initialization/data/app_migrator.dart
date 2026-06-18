// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:async';

import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/constant/pubspec.yaml.g.dart';
import 'package:flutter_template_name/src/common/database/database.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:l/l.dart';

/// {@template app_migrator}
/// Migrate application when version is changed.
/// {@endtemplate}
sealed class AppMigrator {
  /// Migrate application when version is changed.
  static Future<void> migrate(Dependencies dependencies) async {
    try {
      final prevMajor = await dependencies.sharedPreferences.getInt(Config.versionMajorKey);
      final prevMinor = await dependencies.sharedPreferences.getInt(Config.versionMinorKey);
      final prevPatch = await dependencies.sharedPreferences.getInt(Config.versionPatchKey);
      if (prevMajor == null || prevMinor == null || prevPatch == null) {
        l.i('Initializing app for the first time');
        /* ... */
      } else if (Pubspec.version.major != prevMajor ||
          Pubspec.version.minor != prevMinor ||
          Pubspec.version.patch != prevPatch) {
        l.i(
          'Migrating '
          'from $prevMajor.$prevMinor.$prevPatch '
          'to ${Pubspec.version.major}.${Pubspec.version.minor}.${Pubspec.version.patch}',
        );
        await dependencies.sharedPreferences.remove('api_base_url'); // Remove old API base URL if exists
        await $migrator$DropDatabase(dependencies.database); // db.removeAll();
      } else {
        l.i('App is up-to-date');
        return;
      }
      await (
        dependencies.sharedPreferences.setInt(Config.versionMajorKey, Pubspec.version.major),
        dependencies.sharedPreferences.setInt(Config.versionMinorKey, Pubspec.version.minor),
        dependencies.sharedPreferences.setInt(Config.versionPatchKey, Pubspec.version.patch),
      ).wait;
    } on Object catch (e, s) {
      l.e('App migration failed: $e', s);
      rethrow;
    }
  }
}
