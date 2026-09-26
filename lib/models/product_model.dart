import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String imageUrl;
  final String fandomId;
  final String category;
  final int stock;
  final bool isAvailable;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final String createdBy;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.imageUrl,
    required this.fandomId,
    required this.category,
    required this.stock,
    required this.isAvailable,
    this.createdAt,
    this.updatedAt,
    required this.createdBy,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductModel(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      price: ((data['price'] ?? 0) as num).toDouble(),
      currency: (data['currency'] ?? 'USD') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
      fandomId: (data['fandomId'] ?? '') as String,
      category: (data['category'] ?? 'Uncategorized') as String,
      stock: ((data['stock'] ?? 0) as num).toInt(),
      isAvailable: (data['isAvailable'] ?? false) as bool,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
      createdBy: (data['createdBy'] ?? '') as String,
    );
  }

  bool get canPurchase => isAvailable && stock > 0;
}