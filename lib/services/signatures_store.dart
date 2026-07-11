import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/signature.dart';
import 'storage_service.dart';

class SignaturesStore extends ChangeNotifier {
  List<SeatSignature> _signatures = [];
  bool _loaded = false;
  StreamSubscription<List<SeatSignature>>? _sub;
  String? _userId;

  List<SeatSignature> get signatures => _signatures;
  bool get loaded => _loaded;
  String? get userId => _userId;

  Future<void> load() async {
    _userId = await StorageService.ensureSignedIn();
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

  List<SeatSignature> forStadium(String stadiumId) =>
      _signatures.where((s) => s.stadiumId == stadiumId).toList();
}