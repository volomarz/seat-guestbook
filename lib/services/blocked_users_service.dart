import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A blocked person, remembered on-device only. We store the name they were
/// signing under at the time you blocked them (rather than just their raw
/// anonymous user id) so a "manage blocked users" screen has something
/// readable to show — there's no shared user-profile name to look up later.
class BlockedUser {
  final String ownerId;
  final String name;
  BlockedUser({required this.ownerId, required this.name});
}

/// Lets someone hide a specific person's signatures from their own view of
/// the app. This is separate from "report," which flags content for the app
/// owner to review — blocking is personal and immediate, doesn't require any
/// review, and doesn't affect what other users see.
class BlockedUsersService {
  static const _key = 'blockedUsers';

  static Future<List<BlockedUser>> getBlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => _fromJson(e as Map<String, dynamic>))
          .whereType<BlockedUser>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Set<String>> getBlockedIds() async {
    final blocked = await getBlocked();
    return blocked.map((b) => b.ownerId).toSet();
  }

  static Future<void> block(String ownerId, String name) async {
    if (ownerId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final current = await getBlocked();
    current.removeWhere((b) => b.ownerId == ownerId);
    current.insert(0, BlockedUser(ownerId: ownerId, name: name.isEmpty ? 'Unnamed' : name));
    final raw = jsonEncode(current.map(_toJson).toList());
    await prefs.setString(_key, raw);
  }

  static Future<void> unblock(String ownerId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getBlocked();
    current.removeWhere((b) => b.ownerId == ownerId);
    final raw = jsonEncode(current.map(_toJson).toList());
    await prefs.setString(_key, raw);
  }

  static Map<String, dynamic> _toJson(BlockedUser b) => {
        'ownerId': b.ownerId,
        'name': b.name,
      };

  static BlockedUser? _fromJson(Map<String, dynamic> json) {
    final ownerId = json['ownerId'] as String?;
    final name = json['name'] as String?;
    if (ownerId == null || name == null) return null;
    return BlockedUser(ownerId: ownerId, name: name);
  }
}
