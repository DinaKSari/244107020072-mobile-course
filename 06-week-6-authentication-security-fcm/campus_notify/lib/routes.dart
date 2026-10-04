abstract final class Routes {
  static const login = '/login';
  static const home = '/';
  static const announcement = '/pengumuman/:id';
  static String announcementOf(String id) => '/pengumuman/$id';
}

/// RemoteMessage.data -> rute GoRouter.
String routeFromMessage(Map<String, dynamic> data) {
  final r = (data['route'] ?? Routes.home).toString();
  return r.startsWith('/') ? r : '/$r';
}