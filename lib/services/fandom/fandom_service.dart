import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/fandom/fandom_model.dart';

class FandomService {
  FandomService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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
}
