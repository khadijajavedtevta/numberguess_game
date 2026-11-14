
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'guessing_game.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE guesses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            guess INTEGER NOT NULL,
            target INTEGER NOT NULL,
            result TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // INSERT GUESS
  Future<int> insertGuess(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('guesses', data);
  }

  // GET ALL GUESSES
  Future<List<Map<String, dynamic>>> getGuesses() async {
    final db = await database;

    return await db.query(
      'guesses',
      orderBy: 'id DESC',
    );
  }

  // DELETE ALL GUESSES
  Future<int> deleteAllGuesses() async {
    final db = await database;
    return await db.delete('guesses');
  }
}
