import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bookmark_model.dart';
import 'fandom/fandom_service.dart';

/// Bookmarks for fandoms, events, resources and gallery images.
///
/// Storage:
///  * Firestore  -> users/{uid}/bookmarks/{type}_{refId}   (the online copy)
///  * SharedPreferences -> 'bookmarks_{uid}'                (the offline copy)
///
/// [watchAll] first emits the offline copy (instant, works without internet)
/// and then keeps it in sync with Firestore.
class BookmarkService {
  BookmarkService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // When the device is offline a Firestore write only completes after it is
  // synced. We wait a few seconds so real errors (for example permission
  // denied) still reach the UI, then let the write finish in the background.
  static const Duration _writeWait = Duration(seconds: 4);

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _bookmarks(String uid) =>
      _firestore.collection('users').doc(uid).collection('bookmarks');

  // ------------------------------------------------------------
  // LOCAL CACHE
  // ------------------------------------------------------------

  String _cacheKey(String uid) => 'bookmarks_$uid';

  Future<List<BookmarkModel>> _readCache(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey(uid));
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw) as List;
      return decoded
          .whereType<Map>()
          .map((e) => BookmarkModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeCache(String uid, List<BookmarkModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey(uid),
        jsonEncode(items.map((b) => b.toMap()).toList()),
      );
    } catch (_) {
      // The cache is only a convenience, never fail because of it.
    }
  }

  List<BookmarkModel> _newestFirst(List<BookmarkModel> items) =>
      [...items]..sort((a, b) => b.savedAt.compareTo(a.savedAt));

  // ------------------------------------------------------------
  // READ
  // ------------------------------------------------------------

  /// All bookmarks of the current user, newest first.
  Stream<List<BookmarkModel>> watchAll() async* {
    final uid = _uid;
    if (uid == null) {
      yield const [];
      return;
    }

    // 1) Offline copy first, so the screen is never empty while loading.
    var current = await _readCache(uid);
    yield _newestFirst(current);

    // 2) Then follow Firestore and refresh the offline copy every time.
    final live = _bookmarks(uid).snapshots().handleError((Object _) {});

    await for (final snap in live) {
      // A brand-new install can briefly report an empty cache-only result.
      // Do not let that wipe the saved offline copy.
      if (snap.metadata.isFromCache &&
          !snap.metadata.hasPendingWrites &&
          snap.docs.isEmpty &&
          current.isNotEmpty) {
        continue;
      }

      current = snap.docs.map((d) => BookmarkModel.fromMap(d.data())).toList();
      await _writeCache(uid, current);
      yield _newestFirst(current);
    }
  }

  /// Keys ("type_refId") of everything the user has bookmarked.
  Stream<Set<String>> watchKeys() =>
      watchAll().map((list) => list.map((b) => b.key).toSet());

  // ------------------------------------------------------------
  // WRITE
  // ------------------------------------------------------------

  /// Adds ([on] = true) or removes ([on] = false) a bookmark.
  Future<void> setBookmarked(BookmarkModel bookmark, {required bool on}) async {
    final uid = _uid;
    if (uid == null) return;

    final doc = _bookmarks(uid).doc(bookmark.key);

    final data = bookmark.toMap()
      ..['savedAt'] = DateTime.now().millisecondsSinceEpoch;

    final writes = <Future<void>>[on ? doc.set(data) : doc.delete()];

    // Fandom bookmarks also keep the old id list on the user document,
    // because the Discover screen still reads it for its saved filter.
    if (bookmark.type == BookmarkType.fandom) {
      writes.add(
        _firestore.collection('users').doc(uid).set({
          FandomService.bookmarkedField: on
              ? FieldValue.arrayUnion([bookmark.refId])
              : FieldValue.arrayRemove([bookmark.refId]),
        }, SetOptions(merge: true)),
      );
    }

    await Future.wait(
      writes.map((w) => w.timeout(_writeWait, onTimeout: () {})),
    );
  }

  /// Fandoms bookmarked BEFORE this feature only exist as ids on the user
  /// document. This creates the missing snapshots for them (safe to call
  /// many times; it does nothing when everything is already migrated).
  Future<void> syncLegacyFandoms() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(_writeWait);

      final ids = ((userDoc.data()?[FandomService.bookmarkedField] as List?) ??
              const [])
          .map((e) => e.toString())
          .toSet();
      if (ids.isEmpty) return;

      final existing = await _bookmarks(uid).get().timeout(_writeWait);
      final have = existing.docs.map((d) => d.id).toSet();

      final fandomService = FandomService();
      for (final id in ids) {
        if (have.contains('${BookmarkType.fandom.name}_$id')) continue;

        final fandom = await fandomService.getFandomById(id);
        if (fandom == null) continue;

        await setBookmarked(BookmarkModel.fandom(fandom), on: true);
      }
    } catch (_) {
      // Offline or no permission: try again next time the screen opens.
    }
  }
}
