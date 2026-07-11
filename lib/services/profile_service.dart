import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const _nameKey = 'profileName';
  static const _teamKey = 'profileFavoriteTeam';

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  static Future<String?> getFavoriteTeam() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_teamKey);
  }

  static Future<void> saveProfile({required String name, required String? favoriteTeam}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    if (favoriteTeam != null) {
      await prefs.setString(_teamKey, favoriteTeam);
    } else {
      await prefs.remove(_teamKey);
    }
  }
}