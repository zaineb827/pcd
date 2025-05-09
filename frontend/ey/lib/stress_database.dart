import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StressDatabase {
  static final StressDatabase _instance = StressDatabase._internal();
  factory StressDatabase() => _instance;
  static Database? _database;

  StressDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Si la base de données n'est pas encore ouverte, on l'ouvre
    _database = await _initDatabase();
    return _database!;
  }

  //  initialiser la base de données
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'stress.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  // Méthode pour créer la table
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE stress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        level INTEGER,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // Méthode pour insérer un nouveau niveau de stress dans la base de données
  Future<void> insertStressLevel(int level) async {
    final db = await database;
    await db.insert(
      'stress',
      {'level': level},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Méthode pour récupérer les niveaux de stress depuis la base de données
  Future<List<Map<String, dynamic>>> getStressLevels() async {
    final db = await database;
    return await db.query('stress', orderBy: 'timestamp DESC');
  }
}
