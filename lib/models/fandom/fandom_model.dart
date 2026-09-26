import 'package:cloud_firestore/cloud_firestore.dart';

class FandomModel {
  const FandomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.isActive,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final bool isActive;

  factory FandomModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return FandomModel(
      id: document.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      category: data['category'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? false,
    );
  }
}
