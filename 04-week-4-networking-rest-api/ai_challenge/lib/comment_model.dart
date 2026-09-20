class Comment {
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  // Factory constructor dari JSON dengan penanganan field null atau hilang
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      // Jika key 'postId' tidak ada atau null, fallback ke angka 0
      postId: json['postId'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
      // Jika key 'name' tidak ada atau null, fallback ke string 'Unknown'
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? 'No Email',
      body: json['body'] as String? ?? '',
    );
  }
}