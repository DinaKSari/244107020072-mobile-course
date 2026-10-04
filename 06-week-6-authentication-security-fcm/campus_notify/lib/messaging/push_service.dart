import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _local = FlutterLocalNotificationsPlugin();
String? pendingDeepLink;
void Function(String route)? _go;

/// Fungsi murni, mudah di-unit-test tanpa Firebase.
String routeFromMessage(Map<String, dynamic> data) {
  final route = (data['route'] ?? '/').toString();
  return route.startsWith('/') ? route : '/$route';
}

// Wajib top-level, berjalan di isolate terpisah (jangan akses BuildContext/Riverpod).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true, badge: true, sound: true,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (r) {
      final p = r.payload;
      if (p == null || p.isEmpty) return;
      if (_go != null) {
        _go!(p); // klik banner foreground
      } else {
        pendingDeepLink = p;
      }
    },
  );
}

Future<void> initFcmToken({required Future<void> Function(String token) onToken}) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await onToken(token);
  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);
  await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
}

Future<void> unsubscribeAnnouncements() =>
    FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');

/// Pasang ketiga handler: foreground, background (klik), terminated.
Future<void> setupMessageHandlers(void Function(String route) go) async {
  _go = go;

  // Foreground: sistem tidak menampilkan banner, tampilkan manual.
  FirebaseMessaging.onMessage.listen((message) async {
    const details = AndroidNotificationDetails(
      'pengumuman', 'Pengumuman Kampus',
      importance: Importance.high, priority: Priority.high,
    );
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(android: details),
      payload: routeFromMessage(message.data),
    );
  });

  // Background -> banner diklik.
  FirebaseMessaging.onMessageOpenedApp
      .listen((m) => go(routeFromMessage(m.data)));

  // Terminated -> app dibuka dari notifikasi.
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) go(routeFromMessage(initial.data));
  if (pendingDeepLink != null) {
    go(pendingDeepLink!);
    pendingDeepLink = null;
  }
}