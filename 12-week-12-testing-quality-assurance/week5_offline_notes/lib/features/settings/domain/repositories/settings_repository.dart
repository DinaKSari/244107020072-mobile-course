abstract class SettingsRepository {
  Future<bool> getDarkMode();
  Future<void> setDarkMode(bool value);
  Future<void> markOpenedNow();
  Future<String?> getLastOpened();
}