import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Result of sending an inquiry.
enum InquiryResult {
  /// Firestore confirmed the write.
  sent,

  /// No confirmation in time (probably offline). Firestore keeps the write
  /// and sends it automatically once the phone is back online.
  queued,
}

/// Contact Us inquiries are stored in the top-level `inquiries` collection.
class InquiryService {
  InquiryService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const Duration _wait = Duration(seconds: 6);

  /// All inquiries, newest first. Used by the admin Inquiries screen.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchAll() {
    return _firestore
        .collection('inquiries')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Count of inquiries still marked 'new'. Used for the admin badge.
  Stream<int> watchNewCount() {
    return _firestore
        .collection('inquiries')
        .where('status', isEqualTo: 'new')
        .snapshots()
        .map((s) => s.docs.length);
  }

  Future<void> setStatus(String inquiryId, String status) {
    return _firestore.collection('inquiries').doc(inquiryId).update({
      'status': status,
    });
  }

  Future<void> delete(String inquiryId) {
    return _firestore.collection('inquiries').doc(inquiryId).delete();
  }

  Future<InquiryResult> submit({
    required String name,
    required String email,
    required String topic,
    required String message,
  }) async {
    final write = _firestore.collection('inquiries').add({
      'uid': _auth.currentUser?.uid,
      'name': name.trim(),
      'email': email.trim(),
      'topic': topic,
      'message': message.trim(),
      'status': 'new',
      'createdAt': FieldValue.serverTimestamp(),
    });

    try {
      await write.timeout(_wait);
      return InquiryResult.sent;
    } on TimeoutException {
      // Real errors (like permission denied) still throw; a timeout only
      // means the write is waiting for the network.
      return InquiryResult.queued;
    }
  }
}