//////////////////////////////////////////////////////////
/// This is the custom tile for the playlist in the app to create multiple playlists dynamically ///
import 'package:flutter/material.dart';
import 'package:picoplay/screens/playList_screen/playlist_view_screen.dart';

class CustomTileForPlayList extends StatelessWidget {
  const CustomTileForPlayList({
    required this.title,
    required this.onDelete,
    required this.refreshPlaylists,
    Key? key, required void Function(dynamic newName) updatePlaylistName,
  }) : super(key: key);

  final String title;
  final VoidCallback onDelete;
  final Function() refreshPlaylists;
// This is the fucntion to show the delete conformation box for deleting the palylist
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Playlist"),
          content:
              Text("Are you sure you want to delete the playlist '$title'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                onDelete(); // Call the onDelete callback to delete the playlist
                Navigator.of(context).pop(); // Close the dialog
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 12,
        ),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 48, 0, 107),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: ListTile(
          onTap: () {
            // Navigation to the video player screen
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PlayListViewScreen(
                playlistName: title,
                refreshPlaylists: refreshPlaylists,
              ),
            ));
          },
          leading: const Icon(
            Icons.folder,
            color: Colors.white,
            size: 60,
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () {
              // to show the delete conformation for the user
              _showDeleteConfirmationDialog(context);
            },
          ),
        ),
      ),
    );
  }
}
