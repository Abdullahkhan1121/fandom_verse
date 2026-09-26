import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final _productsRef = FirebaseFirestore.instance.collection('products');

  Stream<List<ProductModel>> streamProducts() {
    return _productsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ProductModel.fromFirestore).toList());
  }

  Stream<List<String>> streamCategories() {
    return streamProducts().map((products) {
      final set = <String>{};
      for (final p in products) {
        if (p.category.isNotEmpty) set.add(p.category);
      }
      final list = set.toList()..sort();
      return list;
    });
  }

  /// Checks the in-memory cache (kept fresh by the live products stream)
  /// first — this is what makes cart/checkout resilient to flaky
  /// network, since the grid's realtime listener already has the data.
  /// Only falls back to a one-time network/offline-cache fetch when the
  /// product truly isn't in memory yet.
  Future<ProductModel?> getProductById(String id) async {
    final cached = ProductCache.instance.getCached(id);
    if (cached != null) return cached;

    try {
      final doc = await _productsRef
          .doc(id)
          .get(const GetOptions(source: Source.server));
      if (!doc.exists) return null;
      final product = ProductModel.fromFirestore(doc);
      ProductCache.instance.put(product);
      return product;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        final cachedDoc = await _productsRef
            .doc(id)
            .get(const GetOptions(source: Source.cache));
        if (cachedDoc.exists) {
          final product = ProductModel.fromFirestore(cachedDoc);
          ProductCache.instance.put(product);
          return product;
        }
      }
      rethrow;
    }
  }
}

/// App-wide in-memory cache of products, kept up to date by whichever
/// screen has the live products stream open (normally ProductsScreen).
/// Call ProductCache.instance.start() once after login so it keeps
/// running for the whole session.
class ProductCache {
  ProductCache._internal();
  static final ProductCache instance = ProductCache._internal();

  final Map<String, ProductModel> _cache = {};
  StreamSubscription<List<ProductModel>>? _subscription;

  void start() {
    _subscription ??= ProductService().streamProducts().listen((products) {
      for (final p in products) {
        _cache[p.id] = p;
      }
    });
  }

  void put(ProductModel product) {
    _cache[product.id] = product;
  }

  ProductModel? getCached(String id) => _cache[id];
}