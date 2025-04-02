import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('punch_app.db');
    return _database!;
  }

  Future<void> initDatabase() async {
    await database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        userType INTEGER NOT NULL
      )
    ''');
  }

  Future<void> createUser(String username, String password, int userType) async {
    final db = await instance.database;
    await db.insert('users', {
      'username': username,
      'password': password,
      'userType': userType,
    });
  }

  Future<int?> authenticateUser(String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return result.first['userType'] as int;
    }
    return null;
  }

  Future<void> punchIn(String time) async {
    final db = await instance.database;
    await db.insert('punches', {'punchIn': time, 'punchOut': null});
  }

  Future<void> punchOut(String time) async {
    final db = await instance.database;
    await db.rawUpdate('''
      UPDATE punches
      SET punchOut = ?
      WHERE punchOut IS NULL
    ''', [time]);
  }

  Future<Map<String, String?>> getLastPunch() async {
    final db = await instance.database;
    final result = await db.query('punches', orderBy: 'id DESC', limit: 1);
    if (result.isNotEmpty) {
      return {
        'punchIn': result.first['punchIn'] as String?,
        'punchOut': result.first['punchOut'] as String?,
      };
    }
    return {'punchIn': null, 'punchOut': null};
  }

  Future<List<Map<String, dynamic>>> getStaffRecords([String? date]) async {
    final db = await instance.database;
    String query = 'SELECT * FROM punches WHERE punchOut IS NULL';
    List<Map<String, dynamic>> result;

    if (date != null) {
      query = 'SELECT * FROM punches WHERE DATE(punchIn) = ?';
      result = await db.rawQuery(query, [date]);
    } else {
      result = await db.rawQuery(query);
    }
    return result;
  }
}
