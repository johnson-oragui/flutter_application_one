import 'package:flutter_application_one/database/db.dart';

class LastLoggedInEmail {
  final String email;

  const LastLoggedInEmail({required this.email});

  Map<String, Object?> toMap() {
    return {'email': email};
  }

  @override
  String toString() {
    return "LastLoggedInEmail{email: $email}";
  }

  static Future<void> insertEmail(String newEmail) async {
    final db = await DBHelper.getDatabase();

    List<Map<String, Object?>> result = await db.rawQuery("""
      SELECT email FROM last_logged_in_emails WHERE email = $newEmail;
      """);

    if (result.isNotEmpty) {
      return;
    }
    Map<String, Object> value = {'email': newEmail};
    await db.insert('last_logged_in_emails', value);
  }

  static Future<String?> fetchEmail() async {
    final db = await DBHelper.getDatabase();

    List<Map> maps = await db.query(
      'last_logged_in_emails',
      columns: ['email'],
    );

    print(maps);
    if (maps.isNotEmpty) {
      return maps.first.values.first;
    }
    return null;
  }

  static Future<void> clearSavedEmails() async {
    final db = await DBHelper.getDatabase();

    db.rawQuery('DELETE FROM last_logged_in_emails;');
  }
}
