import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class Playlist {
  final int id;
  final String name;
  final String description;
  final List<String> videos;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.videos,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'videos': jsonEncode(videos),
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    final videosData = map['videos'];

    List<String> videosList;

    if (videosData != null) {
      if (videosData is String) {
        videosList = (jsonDecode(videosData) as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else if (videosData is List<dynamic>) {
        videosList = videosData.map((e) => e.toString()).toList();
      } else {
        videosList = <String>[];
      }
    } else {
      videosList = <String>[];
    }

    return Playlist(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      videos: videosList,
    );
  }
}

class PlaylistDatabaseHelper {
  static final PlaylistDatabaseHelper instance = PlaylistDatabaseHelper._init();

  static const String dbName = 'playlists.db';
  static const int dbVersion = 2;

  static const String tableName = 'playlists';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnVideos = 'videos';

  static Database? _database;

  PlaylistDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(dbName);
    return _database!;
  }

  Future<Database> _initDB(String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT,
        $columnDescription TEXT,
        $columnVideos TEXT
      )
    ''');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < 2) {
      db.execute('ALTER TABLE $tableName ADD COLUMN $columnVideos TEXT');
    }
  }

  Future<int> createPlaylist(String name, String description) async {
    final db = await instance.database;
    final id = await db.insert(
      tableName,
      {
        columnName: name,
        columnDescription: description,
        columnVideos: jsonEncode([]),
      },
    );
    return id;
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Playlist.fromMap(maps[i]);
    });
  }

  Future<void> deletePlaylist(int id) async {
    final db = await instance.database;
    await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<Playlist?> fetchPlaylistByName(String name) async {
    final db = await instance.database;
    final maps =
        await db.query(tableName, where: '$columnName = ?', whereArgs: [name]);
    if (maps.isNotEmpty) {
      return Playlist.fromMap(maps.first);
    }
    return null;
  }

  Future<void> deletePlaylistByName(String name) async {
    final db = await instance.database;
    await db.delete(tableName, where: '$columnName = ?', whereArgs: [name]);
  }

  Future<void> updatePlaylistVideos(String name, List<String> videos) async {
    final db = await database;
    final playlist = await fetchPlaylistByName(name);

    if (playlist != null) {
      final updatedPlaylist = Playlist(
        id: playlist.id,
        name: playlist.name,
        description: playlist.description,
        videos: videos,
      );

      await db.update(
        tableName,
        updatedPlaylist.toMap(),
        where: '$columnId = ?',
        whereArgs: [playlist.id],
      );
    }
  }

  Future<void> editPlaylistName(String oldName, String newName) async {
    final db = await instance.database;
    final playlist = await fetchPlaylistByName(oldName);

    if (playlist != null) {
      final updatedPlaylist = Playlist(
        id: playlist.id,
        name: newName, // Update the name with the new name
        description: playlist.description,
        videos: playlist.videos,
      );

      await db.update(
        tableName,
        updatedPlaylist.toMap(),
        where: '$columnId = ?',
        whereArgs: [playlist.id],
      );
    }
  }

  Future<void> addVideoToPlaylist(String playlistName, String videoPath) async {
    final db = await instance.database;
    final playlist = await fetchPlaylistByName(playlistName);

    if (playlist != null) {
      final existingVideos = List<String>.from(playlist.videos);

      if (!existingVideos.contains(videoPath)) {
        // Add the video only if it's not already in the playlist
        existingVideos.add(videoPath);

        final updatedPlaylist = Playlist(
          id: playlist.id,
          name: playlist.name,
          description: playlist.description,
          videos: existingVideos,
        );

        await db.update(
          tableName,
          updatedPlaylist.toMap(),
          where: '$columnId = ?',
          whereArgs: [playlist.id],
        );
      }
    }
  }
}
