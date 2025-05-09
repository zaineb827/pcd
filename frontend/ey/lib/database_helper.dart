import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ey/screens/journal/journal_view.dart'; // For JournalEntry model

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  void deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'journal.db');
    await deleteDatabase(path);
  }

  Future<void> updateUserPassword(String username, String newPassword) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<void> insertUser(User user) async {
    final db = await instance.database;
    await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      return User.fromMap(
        result.first,
      ); // This includes all fields, including security questions
    }
    return null;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('journal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE journal_entries (
      id TEXT PRIMARY KEY,
      date TEXT,
      content TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  age INTEGER NOT NULL,
  gender TEXT NOT NULL,
  question1 TEXT,
  question2 TEXT,
  question3 TEXT
)

  ''');
  }

  Future<void> insertEntry(JournalEntry entry) async {
    final db = await instance.database;
    await db.insert('journal_entries', {
      'id': entry.id,
      'date': entry.date.toIso8601String(),
      'content': entry.content,
    });
  }

  Future<List<JournalEntry>> getEntries() async {
    final db = await instance.database;
    final result = await db.query('journal_entries', orderBy: 'date DESC');

    return result.map((json) {
      return JournalEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        content: json['content'] as String,
      );
    }).toList();
  }

  Future<void> deleteEntry(String id) async {
    final db = await instance.database;
    await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }
}

class User {
  final int? id;
  final String username;
  final String password;
  final int age;
  final String gender;
  final String? question1;
  final String? question2;
  final String? question3;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.age,
    required this.gender,
    this.question1,
    this.question2,
    this.question3,
  });

  // Used when inserting/updating
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'password': password,
      'age': age,
      'gender': gender,
      'question1': question1,
      'question2': question2,
      'question3': question3,
    };
  }

  // **New**: Used when reading from the database
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      question1: map['question1'] as String?,
      question2: map['question2'] as String?,
      question3: map['question3'] as String?,
    );
  }
}
