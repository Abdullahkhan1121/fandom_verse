import 'fandom/fandom_model.dart';

/// What kind of thing was bookmarked.
enum BookmarkType { fandom, event, resource, image }

/// One saved item. It keeps a small SNAPSHOT of the content (title, image,
/// link, a few extra fields) so the Bookmarks screen can still show it when
/// the phone is offline.
class BookmarkModel {
  const BookmarkModel({
    required this.type,
    required this.refId,
    required this.title,
    this.subtitle = '',
    this.imageUrl = '',
    this.url = '',
    this.savedAt = 0,
    this.meta = const {},
  });

  final BookmarkType type;

  /// Id of the original thing (fandom id, event id, ...).
  final String refId;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String url;

  /// Milliseconds since epoch, set when it is saved.
  final int savedAt;

  /// Extra text fields that depend on [type] (description, dates, ...).
  final Map<String, String> meta;

  /// Unique key, also used as the Firestore document id.
  String get key => '${type.name}_$refId';

  // Images stored as base64 can be huge. Firestore documents are limited to
  // 1 MB, so very large images are not copied into the snapshot.
  static const int _maxImageChars = 150000;

  static String safeImage(String value) =>
      value.length > _maxImageChars ? '' : value;

  /// Small deterministic hash (same result on every platform and every run),
  /// used to build ids for resources / images that have no id of their own.
  static String stableHash(String input) {
    var h = 7;
    for (final c in input.codeUnits) {
      h = (h * 31 + c) & 0x3FFFFFF;
    }
    return '${h.toRadixString(36)}${input.length}';
  }

  // ---------------- factories for each type ----------------

  factory BookmarkModel.fandom(FandomModel f) {
    return BookmarkModel(
      type: BookmarkType.fandom,
      refId: f.id,
      title: f.name,
      subtitle: f.category,
      imageUrl: safeImage(f.imageUrl),
      meta: {
        'category': f.category,
        'tagline': f.tagline,
        'description': f.description,
        'beginnerGuide': f.beginnerGuide,
      },
    );
  }

  factory BookmarkModel.event({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required String category,
    required String location,
    required String city,
    required String ticketLink,
    required DateTime startAt,
    required DateTime endAt,
  }) {
    return BookmarkModel(
      type: BookmarkType.event,
      refId: id,
      title: title,
      subtitle: location,
      imageUrl: safeImage(imageUrl),
      url: ticketLink,
      meta: {
        'description': description,
        'category': category,
        'location': location,
        'city': city,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
      },
    );
  }

  factory BookmarkModel.resource({
    required String fandomId,
    required String fandomName,
    required String resourceType,
    required String title,
    required String url,
  }) {
    return BookmarkModel(
      type: BookmarkType.resource,
      refId: '${fandomId}_${stableHash('$title|$url')}',
      title: title,
      subtitle: '${resourceType.toUpperCase()} · $fandomName',
      url: url,
      meta: {
        'resourceType': resourceType,
        'fandomId': fandomId,
        'fandomName': fandomName,
      },
    );
  }

  factory BookmarkModel.image({
    required String fandomId,
    required String fandomName,
    required String imageUrl,
  }) {
    return BookmarkModel(
      type: BookmarkType.image,
      refId: '${fandomId}_${stableHash(imageUrl)}',
      title: fandomName,
      subtitle: 'Gallery image',
      imageUrl: safeImage(imageUrl),
      meta: {'fandomId': fandomId, 'fandomName': fandomName},
    );
  }

  // ---------------- map conversion ----------------

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'refId': refId,
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'url': url,
        'savedAt': savedAt,
        'meta': meta,
      };

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    final typeName = (map['type'] ?? '').toString();
    final type = BookmarkType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => BookmarkType.fandom,
    );

    final rawMeta = map['meta'];
    final meta = <String, String>{
      if (rawMeta is Map)
        for (final e in rawMeta.entries) e.key.toString(): e.value.toString(),
    };

    final saved = map['savedAt'];

    return BookmarkModel(
      type: type,
      refId: (map['refId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      subtitle: (map['subtitle'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      url: (map['url'] ?? '').toString(),
      savedAt: saved is num ? saved.toInt() : 0,
      meta: meta,
    );
  }
}
