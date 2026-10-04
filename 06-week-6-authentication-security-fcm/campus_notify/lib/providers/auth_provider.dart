import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_client.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';

final tokenStoreProvider = Provider((_) => TokenStore());
final authRepositoryProvider = Provider((_) => AuthRepository());

final dioProvider = Provider<Dio>((ref) => buildApiClient(
      ref.read(tokenStoreProvider),
      ref.read(authRepositoryProvider),
      () => ref.read(authStateProvider.notifier).expire(),
    ));

final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async =>
      await ref.read(tokenStoreProvider).readAccess() != null;

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final s = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref.read(tokenStoreProvider).save(access: s.access, refresh: s.refresh);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    expire();
  }

  /// Sesi berakhir -> guard route mengarahkan ke /login.
  void expire() => state = const AsyncData(false);
}