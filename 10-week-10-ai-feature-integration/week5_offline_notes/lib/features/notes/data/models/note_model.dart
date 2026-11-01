import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    super.id,
    required super.title,
    super.body = '',
    required super.updatedAt,
    super.dirty = false,
  });

  factory NoteModel.fromEntity(Note n) => NoteModel(
      id: n.id, title: n.title, body: n.body, updatedAt: n.updatedAt, dirty: n.dirty);

  factory NoteModel.fromMap(Map<String, Object?> m) => NoteModel(
        id: (m['id'] as num?)?.toInt(),
        title: m['title'] as String? ?? '',
        body: m['body'] as String? ?? '',
        updatedAt: DateTime.tryParse(m['updated_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        dirty: ((m['dirty'] as num?)?.toInt() ?? 0) == 1,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'updated_at': updatedAt.toIso8601String(),
        'dirty': dirty ? 1 : 0,
      };

  Note toEntity() =>
      Note(id: id, title: title, body: body, updatedAt: updatedAt, dirty: dirty);
}