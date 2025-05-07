import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Future<Database> getDatabase() async {
    final path = join(await getDatabasesPath(), 'db.db');

    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE IF NOT EXISTS last_logged_in_emails (
            id INTEGER PRIMARY KEY,
            email VARCHAR(255) UNIQUE
          );
          ''');
      },
      version: 1,
    );
  }
}
