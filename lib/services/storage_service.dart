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

  /// Makes sure this device has an anonymous Firebase Auth identity, and
  /// returns its uid. Safe to call repeatedly.
  static Future<String> ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current.uid;
    final result = await _auth.signInAnonymously();
    return result.user!.uid;
  }

  static String? get currentUserId => _auth.currentUser?.uid;

  /// Live stream of every non-reported signature, newest first.
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

  /// Uploads a local photo file to Cloud Storage and returns its public
  /// download URL.
  static Future<String> uploadPhoto(String localPath, String signatureId) async {
    final ext = localPath.split('.').last;
    final ref = _storage.ref().child('seat_photos/$signatureId.$ext');
    await ref.putFile(File(localPath));
    return ref.getDownloadURL();
  }
}