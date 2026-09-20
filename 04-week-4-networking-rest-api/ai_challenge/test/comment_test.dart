import 'package:flutter_test/flutter_test.dart';
// Sesuaikan dengan struktur folder Anda, contoh:
import 'package:ai_challenge/comment_model.dart'; 

void main() {
  group('Comment Model Tests', () {
    
    test('Happy Path: fromJson berhasil memparsing data valid', () {
      final Map<String, dynamic> validJson = {
        'postId': 1,
        'id': 1,
        'name': 'Budi',
        'email': 'budi@example.com',
        'body': 'Ini adalah komentar yang bagus.'
      };
      
      final result = Comment.fromJson(validJson);
      
      expect(result.postId, equals(1));
      expect(result.name, equals('Budi'));
      expect(result.body, equals('Ini adalah komentar yang bagus.'));
    });

    test('Edge Case 1 (Missing Fields): fromJson aman saat JSON kosong sama sekali', () {
      final Map<String, dynamic> emptyJson = {};
      
      final result = Comment.fromJson(emptyJson);
      
      // Harus kembali ke fallback value, BUKAN error NullPointerException
      expect(result.postId, equals(0));
      expect(result.id, equals(0));
      expect(result.name, equals('Unknown'));
      expect(result.email, equals('No Email'));
      expect(result.body, equals(''));
    });

    test('Edge Case 2 (Explicit Null): fromJson aman saat API mengirim nilai null', () {
      final Map<String, dynamic> explicitNullJson = {
        'postId': null,
        'id': null,
        'name': null,
        'email': null,
        'body': null,
      };
      
      final result = Comment.fromJson(explicitNullJson);
      
      // Meskipun key-nya ada tapi nilainya null, tetap harus menggunakan fallback
      expect(result.postId, equals(0));
      expect(result.name, equals('Unknown'));
      expect(result.body, equals(''));
    });
  });
}