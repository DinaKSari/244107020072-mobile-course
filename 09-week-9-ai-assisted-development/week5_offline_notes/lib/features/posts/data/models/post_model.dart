import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({required super.userId, required super.id, required super.title, required super.body});

  factory PostModel.fromJson(Map<String, dynamic> j) => PostModel(
        userId: (j['userId'] as num?)?.toInt() ?? 0,
        id: (j['id'] as num?)?.toInt() ?? 0,
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
      );

  Map<String, dynamic> toJson() =>
      {'userId': userId, 'id': id, 'title': title, 'body': body};
}