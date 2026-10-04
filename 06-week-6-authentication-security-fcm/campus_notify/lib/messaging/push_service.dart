import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kTopic = 'pengumuman-kampus';

/// Ganti dengan Dio milikmu (yang punya interceptor Authorization).
final dioProvider = Provider<Dio>((_) => Dio(BaseOptions(baseUrl: 'https://api.example.com')));
final pushServiceProvider = Provider((ref) => PushService(ref.watch(dioProvider)));

/// Fungsi murni: data FCM -> rute GoRouter.
String routeFromData(Map<String, dynamic> data) {
  final r = (data['route'] ?? '/').toString();
  return r.startsWith('/') ? r : '/$r';
}

// ⛔ TANPA BuildContext/Riverpod: top-level, isolate terpisah.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class PushService {
  PushService(this._dio);
  final Dio _dio;
  final _fcm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();
  bool _started = false;

  /// [go] = callback navigasi (mis. router.go), sehingga kelas ini bebas BuildContext.
  Future<void> init(void Function(String route) go) async {
    if (_started) return;
    _started = true;

    await _requestPermission();
    await _initLocal(go);

    _fcm.onTokenRefresh.listen(_sendToken);
    await syncToken();
    await subscribe();

    // Foreground
    FirebaseMessaging.onMessage.listen(_showForeground);
    // Background -> klik
    FirebaseMessaging.onMessageOpenedApp.listen((m) => go(routeFromData(m.data)));
    // Terminated -> klik
    final initial = await _fcm.getInitialMessage();
    if (initial != null) go(routeFromData(initial.data));
  }

  Future<void> _requestPermission() async {
    // 🤖 Android 13+: memunculkan dialog POST_NOTIFICATIONS (butuh izin di AndroidManifest).
    //    Android <13: otomatis authorized.
    // 🍎 iOS: dialog izin + butuh APNs key & capability Push.
    await _fcm.requestPermission();

    // 🍎 iOS saja: sistem sudah menampilkan banner saat foreground.
    if (Platform.isIOS) {
      await _fcm.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);
    }
  }

  Future<void> _initLocal(void Function(String) go) => _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // 🍎 izin sudah diminta lewat FCM, jangan minta dua kali.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (r) {
          final p = r.payload;
          if (p != null && p.isNotEmpty) go(p); // klik banner lokal (foreground)
        },
      );

  /// Panggil juga setelah login agar POST /devices membawa Authorization.
  Future<void> syncToken() async {
    // 🍎 iOS: token FCM baru valid setelah APNs token tersedia.
    if (Platform.isIOS && await _fcm.getAPNSToken() == null) return;
    final token = await _fcm.getToken();
    if (token != null) await _sendToken(token);
  }

  Future<void> _sendToken(String token) async {
    try {
      await _dio.post('/devices', data: {
        'fcm_token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (_) {/* jangan log token; coba lagi saat syncToken() berikutnya */}
  }

  Future<void> _showForeground(RemoteMessage m) async {
    if (Platform.isIOS) return; // 🍎 sudah ditampilkan sistem
    // 🤖 Android: foreground tidak menampilkan banner, tampilkan manual.
    await _local.show(
      id: m.hashCode,
      title: m.notification?.title ?? 'Pengumuman',
      body: m.notification?.body ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'pengumuman', 'Pengumuman Kampus',
          importance: Importance.high, priority: Priority.high,
        ),
      ),
      payload: routeFromData(m.data),
    );
  }

  Future<void> subscribe() => _fcm.subscribeToTopic(kTopic);
  Future<void> unsubscribe() => _fcm.unsubscribeFromTopic(kTopic);
}