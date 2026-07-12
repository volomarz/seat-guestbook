import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/signature.dart';

class StorageService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static final _storage = FirebaseStorage.instance;

  static CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('signatures');

  static Future<String> ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current.uid;
    final result = await _auth.signInAnonymously();
    return result.user!.uid;
  }

  static String? get currentUserId => _auth.currentUser?.uid;

  static Stream<List<SeatSignature>> watchSignatures() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((doc) => SeatSignature.fromJson(doc.data()))
              .where((sig) => !sig.reported)
              .toList(),
        );
  }

  static Future<void> addSignature(SeatSignature sig) async {
    await _collection.doc(sig.id).set(sig.toJson());
  }

  static Future<void> deleteSignature(String id) async {
    await _collection.doc(id).delete();
  }

  static Future<void> reportSignature(String id) async {
    await _collection.doc(id).update({'reported': true});
  }

  static Future<List<String>> uploadPhotos(
      List<String> localPaths, String signatureId) async {
    final urls = <String>[];
    for (var i = 0; i < localPaths.length; i++) {
      final ext = localPaths[i].split('.').last;
      final ref = _storage.ref().child('seat_photos/${signatureId}_$i.$ext');
      await ref.putFile(File(localPaths[i]));
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }
}