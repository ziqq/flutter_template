import 'dart:io' as io;

import 'package:drift/drift.dart';
import 'package:drift/native.dart' as ffi;
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/constant/generated/pubspec.yaml.g.dart';
import 'package:l/l.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:platform_info/platform_info.dart';

@internal
Future<QueryExecutor> $createQueryExecutor({
  String? path,
  bool logStatements = false,
  bool dropDatabase = false,
  bool memoryDatabase = false,
}) async {
  // Put this somewhere before you open your first VmDatabase

  // Close existing instances for hot restart
  // if (kDebugMode) {
  //   try {
  //     ffi.NativeDatabase.closeExistingInstances();
  //   } on Object catch (e, st) {
  //     l.w("Can't close existing database instances, error: $e", st);
  //   }
  // }

  if (memoryDatabase) {
    return ffi.NativeDatabase.memory(
      logStatements: logStatements,
      /* setup: (db) {}, */
    );
  }
  io.File file;
  if (path == null) {
    try {
      var dbFolder = await getApplicationDocumentsDirectory();
      if (platform.desktop) {
        dbFolder = io.Directory(join(dbFolder.path, Pubspec.name));
        if (!dbFolder.existsSync()) await dbFolder.create(recursive: true);
      }
      file = io.File(join(dbFolder.path, '${Config.databaseName}.db'));
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace('Failed to get application documents directory "$error"', stackTrace);
    }
  } else {
    file = io.File(path);
  }
  try {
    if (dropDatabase && file.existsSync()) {
      await file.delete();
    }
  } on Object catch (e, st) {
    l.e("Can't delete database file: $file, error: $e", st);
    rethrow;
  }
  /* return ffi.NativeDatabase(
    file,
    logStatements: logStatements,
    /* setup: (db) {}, */
  ); */
  return ffi.NativeDatabase.createInBackground(
    file,
    logStatements: logStatements,
    /* setup: (db) {}, */
  );
}
