import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/session.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sessions.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startTime TEXT,
        endTime TEXT,
        distance REAL,
        elapsedTime INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER,
        latitude REAL,
        longitude REAL,
        timestamp TEXT,
        FOREIGN KEY(sessionId) REFERENCES sessions(id)
      )
    ''');
  }

  Future<int> insertSession(Session session) async {
    final db = await database;
    return await db.insert('sessions', session.toMap());
  }

  Future<void> updateSession(Session session) async {
    final db = await database;
    await db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<void> insertLocationPoints(int sessionId, List<LocationPoint> points) async {
    final db = await database;
    for (var point in points) {
      await db.insert('locations', point.toMap(sessionId));
    }
  }

  Future<List<Session>> getAllSessions() async {
    final db = await database;
    final sessionMaps = await db.query('sessions', orderBy: 'startTime DESC');

    List<Session> sessions = [];
    for (var sessionMap in sessionMaps) {
      final sessionId = sessionMap['id'] as int;
      final locations = await _getLocationsForSession(sessionId);
      sessions.add(Session.fromMap(sessionMap, locations));
    }

    return sessions;
  }

  Future<List<LocationPoint>> _getLocationsForSession(int sessionId) async {
    final db = await database;
    final maps = await db.query(
      'locations',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );

    return maps.map((map) => LocationPoint.fromMap(map)).toList();
  }
}
