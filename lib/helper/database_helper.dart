import 'package:path/path.dart';
import 'package:punch_in_out/constants/value_constant.dart';
import 'package:punch_in_out/dto/event_dto.dart';
import 'package:punch_in_out/dto/user_dto.dart';
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
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        userType TEXT NOT NULL,
        punchIn TEXT,
        punchOut TEXT,
        punchInLat REAL,
        punchInLon REAL,
        punchOutLat REAL,
        punchOutLon REAL,
        punchInScanData TEXT,
        punchOutScanData TEXT
      )
    ''');

    db.execute('''
        CREATE TABLE events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          notes TEXT,
          date TEXT,
          company TEXT
        )
      ''');
  }

  Future<void> deleteDb() async {
    await deleteDatabase(join(await getDatabasesPath(), 'punch_app.db'));
  }

  Future<int> createUser(UserDto user) async {
    final db = await instance.database;
    return await db.insert('users', user.toJson());
  }

  Future<int?> deleteUser(int? userId) async {
    final db = await instance.database;
    if (userId != null) {
      return await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
    } else {
      return null;
    }
  }

  Future<int?> updatePunchInOut({required int userId, required String punchInOutTime, double? latitude, double? longitude, required int punchType, String? punchInOutScanData}) async {
    final db = await instance.database;
    if (punchType == 1) {
      return await db.update(
        'users',
        {'punchIn': punchInOutTime, 'punchInLat': latitude, 'punchInLon': longitude, 'punchInScanData': punchInOutScanData},
        where: 'id = ?',
        whereArgs: [userId],
      );
    } else if (punchType == 2) {
      return await db.update(
        'users',
        {'punchOut': punchInOutTime, 'punchOutLat': latitude, 'punchOutLon': longitude, 'punchOutScanData': punchInOutScanData},
        where: 'id = ?',
        whereArgs: [userId],
      );
    } else {
      return null;
    }
  }

  Future<void> updatePunchIn(int userId, String punchInTime, double? lat, double? lon) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'punchIn': punchInTime, 'punchInLat': lat, 'punchInLon': lon},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updatePunchOut(int userId, String punchOutTime, double? lat, double? lon) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'punchOut': punchOutTime, 'punchOutLat': lat, 'punchOutLon': lon},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<bool> checkUserExists(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  Future<UserDto?> authenticateUser(String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? UserDto.fromJson(result.first) : null;
  }

  Future<List<UserDto>> getStaffRecords([String? date]) async {
    final db = await instance.database;
    String query = "SELECT * FROM users WHERE userType = '${ValueConstant.staff}' AND punchIn IS NOT NULL";
    List<Map<String, dynamic>> result;

    if (date != null) {
      query = 'SELECT * FROM users WHERE DATE(punchIn) = ? OR DATE(punchOut) = ?';
      result = await db.rawQuery(query, [date, date]);
    } else {
      result = await db.rawQuery(query);
    }

    return result.map((json) => UserDto.fromJson(json)).toList();
  }

  //
  Future<List<EventDto>> getEvents() async {
    final db = await database;
    final result = await db.query('events');
    return result.map((e) => EventDto.fromJson(e)).toList();
  }

  Future<void> insertEvent(EventDto event) async {
    final db = await database;
    await db.insert('events', event.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateEvent(EventDto event) async {
    final db = await database;
    await db.update('events', event.toJson(), where: 'id = ?', whereArgs: [event.id]);
  }

  Future<void> deleteEvent(int id) async {
    final db = await database;
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}
