import '../../domain/entities/note.dart';

import 'package:flutter/material.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({super.key, required this.note, this.onTap, this.onLongPress});

  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: Text(note.body),
      trailing: note.dirty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE0B2),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: const Text(
                    'belum tersinkron',
                    style: TextStyle(fontSize: 10, color: Colors.deepOrange),
                  ),
                ),
                const Icon(Icons.cloud_off, color: Colors.orange),
              ],
            )
          : const Icon(Icons.cloud_done, color: Colors.green),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
