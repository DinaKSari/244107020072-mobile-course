import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'api_client.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

// true = jangan hit network, hanya baca cache lokal.
final forceOfflineProvider = StateProvider<bool>((ref) => false);