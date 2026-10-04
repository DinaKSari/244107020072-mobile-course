import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';

// 1. Deklarasikan TokenStore Provider
final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

// 2. Deklarasikan AuthRepository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// 3. Provider AuthState milikmu
final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    // Sekarang tokenStoreProvider sudah dikenali!
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(false);
  }
}