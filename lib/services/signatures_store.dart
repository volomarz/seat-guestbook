import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/signature.dart';
import 'blocked_users_service.dart';
import 'storage_service.dart';

class SignaturesStore extends ChangeNotifier {
  List<SeatSignature> _signatures = [];
  bool _loaded = false;
  StreamSubscription<List<SeatSignature>>? _sub;
  String? _userId;
  Set<String> _blockedIds = {};

  List<SeatSignature> get signatures => _signatures;
  bool get loaded => _loaded;
  String? get userId => _userId;
  Set<String> get blockedIds => _blockedIds;

  Future<void> load() async {
    _userId = await StorageService.ensureSignedIn();
    _blockedIds = await BlockedUsersService.getBlockedIds();
    _sub = StorageService.watchSignatures().listen((sigs) {
      _signatures = sigs;
      _loaded = true;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> add(SeatSignature sig) async {
    await StorageService.addSignature(sig);
  }

  Future<void> remove(String id) async {
    await StorageService.deleteSignature(id);
  }

  Future<void> report(String id) async {
    await StorageService.reportSignature(id);
  }

  /// Hides this person's signatures from your own view going forward. This
  /// is personal and immediate — unlike report(), it doesn't touch the
  /// server or affect what anyone else sees.
  Future<void> block(String ownerId, String name) async {
    await BlockedUsersService.block(ownerId, name);
    _blockedIds = await BlockedUsersService.getBlockedIds();
    notifyListeners();
  }

  Future<void> unblock(String ownerId) async {
    await BlockedUsersService.unblock(ownerId);
    _blockedIds = await BlockedUsersService.getBlockedIds();
    notifyListeners();
  }

  List<SeatSignature> forStadium(String stadiumId) => _signatures
      .where((s) => s.stadiumId == stadiumId && !_blockedIds.contains(s.ownerId))
      .toList();
}