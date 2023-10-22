import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class VideoHistory {
  final int? id;
  final String videoPath;
  final String videoName;
  final String timestamp;
  double progress; // New field to store video progress

  VideoHistory({
    this.id,
    required this.videoPath,
    required this.videoName,
    required this.timestamp,
    this.progress = 0.0, // Default progress is 0.0 (not watched)
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'videopath': videoPath,
      'videoname': videoName,
      'timestamp': timestamp,
      'progress': progress, // Ensure a default value of 0.0
    };
  }

  factory VideoHistory.fromMap(Map<String, dynamic> map) {
    return VideoHistory(
      id: map['id'] as int?,
      videoPath: map['videopath'] as String,
      videoName: map['videoname'] as String,
      timestamp: map['timestamp'] as String,
      progress:
          (map['progress'] as double?) ?? 0.0, // Ensure a default value of 0.0
    );
  }
}

class VideoHistoryDatabaseHelper {
  static const String tableName = 'videohistory';
  late Database _database;
  late StreamController<List<VideoHistory>> _historyStreamController;

  VideoHistoryDatabaseHelper() {
    _historyStreamController = StreamController<List<VideoHistory>>.broadcast();
    getVideoHistory().then((history) {
      _historyStreamController.add(history);
    });
  }

  Stream<List<VideoHistory>> get videoHistoryStream =>
      _historyStreamController.stream;

  Future<void> open() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'videohistory.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, videopath TEXT, videoname TEXT, timestamp TEXT, progress REAL)',
        );
      },
      version: 1,
    );
  }

  Future<void> saveVideoHistory(VideoHistory videoHistory) async {
    await open();
    final existingEntry = await getVideoHistoryByPath(videoHistory.videoPath);

    if (existingEntry != null) {
      await updateVideoHistory(videoHistory);
    } else {
      await insertVideoHistory(videoHistory);
    }
  }

  Future<void> updateVideoHistory(VideoHistory videoHistory) async {
    await open();

    await _database.update(
      tableName,
      {
        'videopath': videoHistory.videoPath,
        'videoname': videoHistory.videoName,
        'timestamp': videoHistory.timestamp,
        'progress': videoHistory.progress,
      },
      where: 'videopath = ?',
      whereArgs: [videoHistory.videoPath],
    );

    final updatedHistory = await getVideoHistory();
    _historyStreamController.add(updatedHistory);
  }

  Future<VideoHistory?> getVideoHistoryByPath(String videoPath) async {
    await open();
    final List<Map<String, dynamic>> maps = await _database.query(
      tableName,
      where: 'videopath = ?',
      whereArgs: [videoPath],
    );

    if (maps.isNotEmpty) {
      return VideoHistory.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> insertVideoHistory(VideoHistory videoHistory) async {
    await open();
    await _database.insert(
      tableName,
      videoHistory.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    final updatedHistory = await getVideoHistory();
    _historyStreamController.add(updatedHistory);
  }

  Future<List<VideoHistory>> getVideoHistory() async {
    await open();
    final List<Map<String, dynamic>> maps = await _database.query(
      tableName,
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) {
      return VideoHistory.fromMap(maps[i]);
    });
  }

  void dispose() {
    _historyStreamController.close();
  }

  Future<void> deleteVideoHistory(int? id) async {
    await open();

    await _database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    final updatedHistory = await getVideoHistory();
    _historyStreamController.add(updatedHistory);
  }

  Future<void> updateVideoProgress(String videoPath, double progress) async {
    await open();

    await _database.update(
      tableName,
      {
        'progress': progress,
      },
      where: 'videopath = ?',
      whereArgs: [videoPath],
    );

    final updatedHistory = await getVideoHistory();
    _historyStreamController.add(updatedHistory);
  }

  Future<double> getVideoProgressByPath(String videoPath) async {
    await open();
    final List<Map<String, dynamic>> maps = await _database.query(
      tableName,
      columns: ['progress'],
      where: 'videopath = ?',
      whereArgs: [videoPath],
    );

    if (maps.isNotEmpty) {
      return (maps.first['progress'] as double?) ?? 0.0;
    } else {
      return 0.0; // Return a default value if no progress is found
    }
  }
}
