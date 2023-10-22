// This is the database for the storing the whole videos in the app
// and all the CRUD operations relating to the database as the app demands
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class VideoDatabaseHelper {
  static final VideoDatabaseHelper instance =
      VideoDatabaseHelper._privateConstructor();

  static const String tableName = 'videos';
  static const String columnId = 'id';
  static const String columnPath = 'path';

  static Database? _database;

  VideoDatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'video_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnPath TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertVideoPaths(List<String> videoPaths) async {
    final db = await database;
    final batch = db.batch();

    // Get the existing video paths from the database
    final existingPaths = await getVideoPaths();

    // Remove duplicates from the list of new paths
    final uniquePaths = Set<String>.from(videoPaths);

    // Remove any new paths that already exist in the database
    final pathsToAdd = uniquePaths.difference(existingPaths.toSet());

    for (final path in pathsToAdd) {
      batch.insert(
        tableName, // Use the tableName constant here
        {columnPath: path}, // Use the columnPath constant here
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

// methode to get all videos for the database
  Future<List<String>> getVideoPaths() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return maps[i][columnPath] as String;
    });
  }

// methode to create database
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(tableName);
  }
}
