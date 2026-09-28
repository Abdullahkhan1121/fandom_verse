import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/fandom/fandom_model.dart';

class FandomService {
  FandomService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// User document fields that hold lists of fandom ids.
  static const String likedField = 'favoriteFandomIds';
  static const String bookmarkedField = 'bookmarkedFandomIds';

  CollectionReference<Map<String, dynamic>> get _fandoms =>
      _firestore.collection('fandoms');

  Stream<List<FandomModel>> getActiveFandoms() {
    return _fandoms
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(FandomModel.fromFirestore).toList(),
        );
  }

  Future<FandomModel?> getFandomById(String id) async {
    final document = await _fandoms.doc(id).get();

    if (!document.exists) {
      return null;
    }

    return FandomModel.fromFirestore(document);
  }

  // ------------------------------------------------------------
  // LIKES + BOOKMARKS (stored on the logged-in user's document)
  // ------------------------------------------------------------

  /// Live set of fandom ids stored in [field] of the current user.
  Stream<Set<String>> watchUserIds(String field) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(<String>{});

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      final list = (doc.data()?[field] as List?) ?? const [];
      return list.map((e) => e.toString()).toSet();
    });
  }

  /// Adds or removes [fandomId] from [field] on the current user.
  Future<void> setUserId({
    required String field,
    required String fandomId,
    required bool add,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set({
      field: add
          ? FieldValue.arrayUnion([fandomId])
          : FieldValue.arrayRemove([fandomId]),
    }, SetOptions(merge: true));
  }
}