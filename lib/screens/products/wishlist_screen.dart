import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/wishlist_service.dart';
import '../../widgets/product_card.dart';
import '../cart/cart_and_checkout.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _wishlist = WishlistService();
  final _cartService = CartService();

  late final Stream<Set<String>> _idsStream = _wishlist.watchIds();
  late final Stream<List<ProductModel>> _productsStream =
      ProductService().streamProducts();

  Future<void> _addToCart(ProductModel product) async {
    try {
      await _cartService.addToCart(product);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} added to cart')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D14),
        surfaceTintColor: Colors.transparent,
        title: const Text('My Wishlist'),
      ),
      body: StreamBuilder<Set<String>>(
        stream: _idsStream,
        builder: (context, idsSnapshot) {
          if (!idsSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final ids = idsSnapshot.data!;

          return StreamBuilder<List<ProductModel>>(
            stream: _productsStream,
            builder: (context, productsSnapshot) {
              if (productsSnapshot.hasError) {
                return Center(
                  child: Text(
                    productsSnapshot.error.toString(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }
              if (!productsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // Products deleted by an admin are simply skipped.
              final items = productsSnapshot.data!
                  .where((p) => ids.contains(p.id))
                  .toList();

              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 56,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your wishlist is empty',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap the heart on any product to save it here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.66,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = items[index];
                  return ProductCard(
                    product: product,
                    isWishlisted: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    ),
                    onWishlistToggle: () =>
                        _wishlist.setWishlisted(product.id, add: false),
                    onAddToCart: () => _addToCart(product),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}