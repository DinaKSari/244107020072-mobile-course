import 'package:flutter/material.dart';
import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    this.onTap,
    this.onLongPress,
  });

  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: Text(note.body),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (note.dirty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'belum tersinkron',
                style: TextStyle(fontSize: 10, color: Colors.deepOrange),
              ),
            ),
          Icon(
            note.dirty ? Icons.cloud_off : Icons.cloud_done,
            color: note.dirty ? Colors.orange : Colors.green,
          ),
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}