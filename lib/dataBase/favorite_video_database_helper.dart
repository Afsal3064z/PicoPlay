// This is the video database for the whole app
// here  is the database regarding the video app is managed
// and all the CRUD operation according to the app operation are done
// For the database i am using sqflite

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// This is the model for the video to store in the database
class Video {
  int id;
  final String videoPath;
  final String videoName;

  Video({
    required this.id,
    required this.videoPath,
    required this.videoName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'videoPath': videoPath,
      'videoName': videoName,
    };
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'],
      videoPath: map['videoPath'],
      videoName: map['videoName'],
    );
  }
}

class FavoriteDatabaseHelper {
  static final FavoriteDatabaseHelper instance = FavoriteDatabaseHelper._init();

  static Database? _database;

  FavoriteDatabaseHelper._init();
  // Methode to get the daatabase
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('favorites.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS favorites(id INTEGER PRIMARY KEY, videoPath TEXT, videoName TEXT)',
    );
  }

  // Methode to insert video in the database
  Future<void> insertFavorite(Video video) async {
    final db = await database;

    // Check if the video is already in favorites
    final isFavorite = await isVideoInFavorites(video.videoPath);
    if (isFavorite) {
      // Video is already a favorite, do not add it again.
      return;
    }

    video.id = await db.insert(
      'favorites',
      video.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // methode to remove the video from the database
  Future<void> removeFavorite(int id) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Methode to get all the favorite video form the database
  Future<List<Video>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) {
      return Video.fromMap(maps[i]);
    });
  }

  // Methode to for the duplicate videos
  Future<bool> isVideoInFavorites(String videoPath) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM favorites WHERE videoPath = ?',
      [videoPath],
    ));
    return count! > 0;
  }
}
