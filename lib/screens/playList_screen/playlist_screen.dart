import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:picoplay/dataBase/play_list_database_helper.dart';
import 'package:picoplay/screens/playList_screen/playlist_view_screen.dart';
import 'package:picoplay/theme_data/theme_colors.dart';

class PlayListScreen extends StatefulWidget {
  const PlayListScreen({Key? key}) : super(key: key);

  @override
  State<PlayListScreen> createState() => _PlayListScreenState();
}

class _PlayListScreenState extends State<PlayListScreen> {
  final TextEditingController _playlistNameController = TextEditingController();
  List<String> playlistNames = [];
  bool nameAlreadyExists = false; // Flag to track if the name already exists

  @override
  void initState() {
    super.initState();
    loadPlaylists();
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

//This is the methode to load the playlists from the database
  Future<void> loadPlaylists() async {
    final playlists = await PlaylistDatabaseHelper.instance.getAllPlaylists();
    if (mounted) {
      setState(() {
        playlistNames = playlists.map((playlist) => playlist.name).toList();
      });
    }
  }

// This is the methode to delete the playlist from the database
  Future<void> deletePlaylist(String name) async {
    await PlaylistDatabaseHelper.instance.deletePlaylistByName(name);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.deepPurple,
          content: Text("Playlist '$name' deleted."),
        ),
      );
      setState(() {
        playlistNames.remove(name);
      });
    }
  }

//This is the methode to update the name of the playlist
  void updatePlaylistName(String oldPlaylistName, String newPlaylistName) {
    setState(() {
      final index = playlistNames.indexOf(oldPlaylistName);
      if (index != -1) {
        playlistNames[index] = newPlaylistName;
      }
    });
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 239, 230, 255),
            title: const Text('Create New Playlist'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _playlistNameController,
                  onChanged: (value) {
                    setState(() {
                      nameAlreadyExists = playlistNames.contains(value);
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Playlist Name'),
                ),
                if (nameAlreadyExists)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Playlist name already exists. Please choose another name.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.green),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final name = _playlistNameController.text;
                  if (name.isNotEmpty && !nameAlreadyExists) {
                    await PlaylistDatabaseHelper.instance
                        .createPlaylist(name, '');
                    _playlistNameController.clear();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    loadPlaylists();
                  }
                },
                child: const Text(
                  'Create',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: MyCustomColor.bgColor,
            stops: const [0.2, 0.8],
          ),
        ),
        child: playlistNames.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset("lib/assets/animation_ln9y998e.json"),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'No playlists found.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: playlistNames.length,
                itemBuilder: (context, index) {
                  final title = playlistNames[index];
                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(
                      color: Colors.deepPurple.shade600,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (_) async {
                      return await _showDeleteConfirmationDialog(
                          context, title);
                    },
                    onDismissed: (_) {
                      // Do nothing when dismissed; the deletion is handled in confirmDismiss
                    },
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 48, 0, 107),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: const Icon(
                          Icons.movie_filter,
                          color: Colors.white,
                          size: 60,
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PlayListViewScreen(
                                playlistName: title,
                                refreshPlaylists: loadPlaylists,
                              ),
                            ),
                          );
                        },
                        trailing: PopupMenuButton<String>(
                          color: const Color.fromARGB(255, 239, 230, 255),
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Edit Playlist Name'),
                                  Icon(Icons.edit)
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Delete Playlist'),
                                  Icon(Icons.delete)
                                ],
                              ),
                            ),
                          ],
                          onSelected: (String value) {
                            if (value == 'edit') {
                              _showEditPlaylistNameDialog(title);
                            } else if (value == 'delete') {
                              _showDeleteConfirmationDialog(context, title);
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple.shade900,
        onPressed: _showCreatePlaylistDialog,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

//The is the delete alert box for the deleting the playlist
  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, String title) async {
    if (!mounted) {
      return false;
    }

    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Playlist"),
          content:
              Text("Are you sure you want to delete the playlist '$title'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await deletePlaylist(title);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(true);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

//This is the alert box to edit the playlist name
  void _showEditPlaylistNameDialog(String currentName) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final newNameController = TextEditingController(text: currentName);
        return AlertDialog(
          title: const Text('Edit Playlist Name'),
          content: TextField(
            controller: newNameController,
            onChanged: (value) {},
            decoration: const InputDecoration(labelText: 'New Playlist Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newName = newNameController.text;
                if (newName.isNotEmpty && newName != currentName) {
                  await PlaylistDatabaseHelper.instance
                      .editPlaylistName(currentName, newName);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  loadPlaylists();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
