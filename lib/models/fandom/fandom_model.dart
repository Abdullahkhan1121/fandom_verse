import 'package:cloud_firestore/cloud_firestore.dart';

/// One glossary entry: a fandom term and what it means.
class GlossaryTerm {
  const GlossaryTerm({required this.term, required this.meaning});

  final String term;
  final String meaning;

  factory GlossaryTerm.fromMap(Map<String, dynamic> map) {
    return GlossaryTerm(
      term: (map['term'] ?? '').toString(),
      meaning: (map['meaning'] ?? '').toString(),
    );
  }
}

/// One resource link: news article, video clip, or podcast.
class FandomResource {
  const FandomResource({
    required this.type,
    required this.title,
    required this.url,
  });

  /// 'news', 'video' or 'podcast'
  final String type;
  final String title;
  final String url;

  factory FandomResource.fromMap(Map<String, dynamic> map) {
    return FandomResource(
      type: (map['type'] ?? 'news').toString().toLowerCase(),
      title: (map['title'] ?? '').toString(),
      url: (map['url'] ?? '').toString(),
    );
  }
}

class FandomModel {
  const FandomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.isActive,
    this.tagline = '',
    this.beginnerGuide = '',
    this.images = const [],
    this.glossary = const [],
    this.deepDive = const [],
    this.resources = const [],
    this.isTrending = false,
    this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final bool isActive;

  // ---- new fields (all optional, so old fandoms still load) ----
  final String tagline;
  final String beginnerGuide;
  final List<String> images;
  final List<GlossaryTerm> glossary;
  final List<String> deepDive;
  final List<FandomResource> resources;
  final bool isTrending;
  final DateTime? createdAt;

  factory FandomModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    List<Map<String, dynamic>> mapList(dynamic value) {
      if (value is! List) return const [];
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    final createdAtValue = data['createdAt'];

    return FandomModel(
      id: document.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      category: data['category'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? false,
      tagline: data['tagline'] as String? ?? '',
      beginnerGuide: data['beginnerGuide'] as String? ?? '',
      images: ((data['images'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      glossary: mapList(data['glossary']).map(GlossaryTerm.fromMap).toList(),
      deepDive: ((data['deepDive'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      resources:
          mapList(data['resources']).map(FandomResource.fromMap).toList(),
      isTrending: data['isTrending'] as bool? ?? false,
      createdAt: createdAtValue is Timestamp ? createdAtValue.toDate() : null,
    );
  }
}