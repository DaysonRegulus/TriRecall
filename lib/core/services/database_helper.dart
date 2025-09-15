import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trirecall/core/models/subject_model.dart';
import 'package:trirecall/core/models/topic_model.dart';

class DatabaseHelper {
  // A private constructor. This class cannot be instantiated from the outside.
  DatabaseHelper._privateConstructor();
  // The single instance of the class.
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // A private, nullable variable to hold the database instance.
  static Database? _database;

  // A public getter for the database. If the database is null, it initializes it.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // This method initializes the database. It finds the path and opens the database.
  Future<Database> _initDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    final dbPath = await getDatabasesPath();
    // Join the path with the database file name.
    final path = join(dbPath, 'trirecall.db');

    // Open the database. The `onCreate` function is called only if the database
    // does not exist at the given path.
    return await openDatabase(
      path,
      version: 1, // Used for database migrations.
      onCreate: _onCreate,
    );
  }

  // This function is called when the database is created for the first time.
  // This is where we define the structure of our tables.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        color TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        notes TEXT NOT NULL,
        studied_on TEXT NOT NULL,
        interval_index INTEGER NOT NULL DEFAULT 0,
        next_due TEXT,
        status TEXT NOT NULL,
        last_reviewed_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');
    
    // We can add a 'reviews' table here later if needed.
  }

  // --- CRUD Methods for Subjects ---

  Future<int> createSubject(Subject subject) async {
    final db = await instance.database;
    return await db.insert('subjects', subject.toMap());
  }

  Future<List<Subject>> getAllSubjects() async {
    final db = await instance.database;
    final maps = await db.query('subjects');
    return List.generate(maps.length, (i) {
      return Subject.fromMap(maps[i]);
    });
  }

  // --- CRUD Methods for Topics ---

  Future<List<Topic>> getAllTopics() async {
    final db = await instance.database;
    // Query without a 'where' clause gets all entries.
    // We order by creation date to see the newest ones first.
    final maps = await db.query('topics', orderBy: 'created_at DESC');
    
    return List.generate(maps.length, (i) {
      return Topic.fromMap(maps[i]);
    });
  }

  Future<List<Topic>> getTopicsForSubject(int subjectId) async {
    final db = await instance.database;
    // This is the core of the filtering logic. The `WHERE` clause tells SQL
    // to only return rows where the 'subject_id' column matches the provided id.
    final maps = await db.query(
      'topics',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'created_at DESC', // Default sort by newest first.
    );

    return List.generate(maps.length, (i) {
      return Topic.fromMap(maps[i]);
    });
  }

  Future<int> createTopic(Topic topic) async {
    final db = await instance.database;
    return await db.insert('topics', topic.toMap());
  }

  Future<List<Topic>> getDueTopics() async {
    final db = await instance.database;
    final now = DateTime.now();
    // Create a string for tomorrow's date at midnight.
    // This ensures we get everything due today up until 23:59:59.
    final tomorrow = DateTime(now.year, now.month, now.day + 1).toIso8601String();

    // Query for topics that are active and their due date is before tomorrow.
    final maps = await db.query(
      'topics',
      where: 'status = ? AND next_due IS NOT NULL AND next_due < ?',
      whereArgs: ['active', tomorrow],
      orderBy: 'next_due ASC',
    );
    
    return List.generate(maps.length, (i) {
      return Topic.fromMap(maps[i]);
    });
  }

  Future<int> updateTopic(Topic topic) async {
    final db = await instance.database;
    return await db.update(
      'topics',
      topic.toMap(),
      where: 'id = ?',
      whereArgs: [topic.id],
    );
  }
}