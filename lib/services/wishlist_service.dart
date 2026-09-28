import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Wishlist = a list of product ids stored on the logged-in user's document
/// (users/{uid}.wishlistProductIds), the same pattern used for fandom likes.
class WishlistService {
  WishlistService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String field = 'wishlistProductIds';

  /// Live set of wishlisted product ids for the current user.
  Stream<Set<String>> watchIds() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(<String>{});

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      final list = (doc.data()?[field] as List?) ?? const [];
      return list.map((e) => e.toString()).toSet();
    });
  }

  Future<void> setWishlisted(String productId, {required bool add}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set({
      field: add
          ? FieldValue.arrayUnion([productId])
          : FieldValue.arrayRemove([productId]),
    }, SetOptions(merge: true));
  }
}