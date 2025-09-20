import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trirecall/core/models/subject_model.dart';
import 'package:trirecall/core/models/topic_model.dart';
import 'package:trirecall/core/models/date_card_model.dart';

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
      version: 3, // Used for database migrations.
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  // This switch statement is a robust way to handle multiple migrations over time.
  // If we were upgrading from version 2 to 3, we'd add another case.
  if (oldVersion < 2) {
    print('DB UPGRADE: Migrating from version 1 to 2');
    // Create the new date_cards table.
    await db.execute('''
      CREATE TABLE date_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        study_date TEXT NOT NULL UNIQUE,
        interval_index INTEGER NOT NULL DEFAULT 0,
        next_due TEXT,
        status TEXT NOT NULL,
        is_incomplete INTEGER NOT NULL DEFAULT 1
      )
    ''');
    
    // Add the new date_card_id column to the existing topics table.
    // We use ON DELETE RESTRICT as we decided: prevent deleting a DateCard if topics are linked to it.
    await db.execute('''
      ALTER TABLE topics ADD COLUMN date_card_id INTEGER REFERENCES date_cards(id) ON DELETE RESTRICT
    ''');
    print('DB UPGRADE: Migration to version 2 complete.');
  }
  if (oldVersion < 3) {
      // --- THIS IS THE NEW MIGRATION LOGIC FOR THIS STEP ---
      print('DB UPGRADE: Migrating from version 2 to 3');
      // Add the new last_reviewed_at column to the date_cards table.
      await db.execute('''
        ALTER TABLE date_cards ADD COLUMN last_reviewed_at TEXT
      ''');
      print('DB UPGRADE: Migration to version 3 complete.');
    }
  }

  // This function is called when the database is created for the first time.
  // This is where we define the structure of our tables.
  Future<void> _onCreate(Database db, int version) async {
    // This method now contains the complete, final schema for a brand new install.
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        color TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE date_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        study_date TEXT NOT NULL UNIQUE,
        interval_index INTEGER NOT NULL DEFAULT 0,
        next_due TEXT,
        status TEXT NOT NULL,
        is_incomplete INTEGER NOT NULL DEFAULT 1,
        last_reviewed_at TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        date_card_id INTEGER REFERENCES date_cards(id) ON DELETE RESTRICT,
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
}

  // --- CRUD Methods for Subjects ---

  /// Fetches all DateCards from the database, sorted by study date.
  Future<List<DateCard>> getAllDateCards() async {
    final db = await instance.database;
    final maps = await db.query('date_cards', orderBy: 'study_date DESC');
    return List.generate(maps.length, (i) => DateCard.fromMap(maps[i]));
  }

  /// Deletes a DateCard from the database given its ID.
  Future<void> deleteDateCard(int id) async {
    final db = await instance.database;
    await db.delete('date_cards', where: 'id = ?', whereArgs: [id]);
  }

  /// Fetches all DateCards that are marked as incomplete.
  Future<List<DateCard>> getIncompleteDateCards() async {
    final db = await instance.database;
    final maps = await db.query(
      'date_cards',
      where: 'is_incomplete = ?',
      whereArgs: [1], // 1 represents 'true' in our database
      orderBy: 'study_date ASC', // Show the oldest incomplete ones first
    );
    return List.generate(maps.length, (i) => DateCard.fromMap(maps[i]));
  }

  /// Updates a given DateCard in the database.
  Future<void> updateDateCard(DateCard dateCard) async {
    final db = await instance.database;
    await db.update(
      'date_cards',
      dateCard.toMap(),
      where: 'id = ?',
      whereArgs: [dateCard.id],
    );
  }

  /// Creates a new DateCard in the database.
  /// Uses `ConflictAlgorithm.ignore` to silently fail if a DateCard for the
  /// same `study_date` already exists, which is perfect for our generation logic.
  Future<void> createDateCard(DateCard dateCard) async {
    final db = await instance.database;
    await db.insert(
      'date_cards',
      dateCard.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

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

  Future<int> updateSubject(Subject subject) async {
    final db = await instance.database;
    // The `db.update` helper method is the safest way to update a row.
    // It takes the table name, a map of the new values, and a `where` clause
    // to specify which row to update.
    return await db.update(
      'subjects',
      subject.toMap(),
      where: 'id = ?', // The '?' is a placeholder to prevent SQL injection attacks.
      whereArgs: [subject.id], // The subject's ID is passed in safely.
    );
  }

  // --- CRUD Methods for Topics ---

  Future<DateCard?> getDateCardByDate(DateTime date) async {
    final db = await instance.database;
    // We need to compare just the date part, so we normalize the DateTime object.
    final dateString = DateTime(date.year, date.month, date.day).toIso8601String();
    
    final maps = await db.query(
      'date_cards',
      where: 'study_date = ?',
      whereArgs: [dateString],
      limit: 1, // We only expect one result.
    );

    if (maps.isNotEmpty) {
      return DateCard.fromMap(maps.first);
    }
    return null;
  }

  /// Fetches all topics that are linked to a specific DateCard ID.
  Future<List<Topic>> getTopicsForDateCard(int dateCardId) async {
    final db = await instance.database;
    final maps = await db.query(
      'topics',
      where: 'date_card_id = ?',
      whereArgs: [dateCardId],
    );
    return List.generate(maps.length, (i) => Topic.fromMap(maps[i]));
  }

  /// Fetches all DateCards that are due for review today or are overdue.
  Future<List<DateCard>> getDue_DateCards() async {
    final db = await instance.database;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1).toIso8601String();
    
    final maps = await db.query(
      'date_cards',
      where: 'status = ? AND next_due IS NOT NULL AND next_due < ?',
      whereArgs: ['active', tomorrow],
    );
    
    return List.generate(maps.length, (i) => DateCard.fromMap(maps[i]));
  }

  /// Fetches all "stray" topics. These are topics that are due today,
  /// but their parent DateCard is NOT due today.
  Future<List<Topic>> getDue_Stray_Topics(List<int> due_DateCardIds) async {
    final db = await instance.database;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1).toIso8601String();

    // This is a more complex query. It finds topics that are due today,
    // AND their parent date_card_id is NOT in the list of due date cards we provide.
    String whereClause = 'status = ? AND next_due IS NOT NULL AND next_due < ?';
    if (due_DateCardIds.isNotEmpty) {
      // The `join(',')` creates a string like '1,2,3' for the SQL query.
      whereClause += ' AND date_card_id NOT IN (${due_DateCardIds.join(',')})';
    }

    final maps = await db.query(
      'topics',
      where: whereClause,
      whereArgs: ['active', tomorrow],
    );

    return List.generate(maps.length, (i) => Topic.fromMap(maps[i]));
  }

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

  /// Deletes a topic from the database given its ID.
  Future<void> deleteTopic(int id) async {
    final db = await instance.database;
    await db.delete(
      'topics',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null; // Set to null so it will be re-initialized on next access
  }
}