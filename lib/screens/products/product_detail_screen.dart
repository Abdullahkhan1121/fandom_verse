import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/fandom/fandom_service.dart';
import '../../services/wishlist_service.dart';
import '../../widgets/fandom_image.dart';
import '../cart/cart_and_checkout.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color _bg = Color(0xFF0B0D14);
  static const Color _panel = Color(0xFF161A24);
  static const Color _violet = Color(0xFF9B5CFF);

  final _cartService = CartService();
  final _wishlist = WishlistService();
  final _pageController = PageController();

  late final Future<String?> _fandomName = _loadFandomName();
  late final Stream<Set<String>> _wishlistStream = _wishlist.watchIds();

  int _imageIndex = 0;
  int _quantity = 1;
  bool _adding = false;

  ProductModel get _product => widget.product;

  Future<String?> _loadFandomName() async {
    if (_product.fandomId.isEmpty) return null;
    try {
      final fandom = await FandomService().getFandomById(_product.fandomId);
      return fandom?.name;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addToCart() async {
    if (_adding) return;
    setState(() => _adding = true);
    try {
      await _cartService.addToCart(_product, quantity: _quantity);
      _snack('${_product.name} added to cart');
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = _product.imageUrls.isNotEmpty
        ? _product.imageUrls
        : <String>[_product.imageUrl];
    final canBuy = _product.canPurchase;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        title: const Text('Product'),
        actions: [
          StreamBuilder<Set<String>>(
            stream: _wishlistStream,
            builder: (context, snapshot) {
              final saved = (snapshot.data ?? {}).contains(_product.id);
              return IconButton(
                tooltip: saved ? 'Remove from wishlist' : 'Add to wishlist',
                onPressed: () => _wishlist.setWishlisted(
                  _product.id,
                  add: !saved,
                ),
                icon: Icon(
                  saved ? Icons.favorite : Icons.favorite_border,
                  color: saved ? Colors.pinkAccent : Colors.white,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ---------------- IMAGE GALLERY ----------------
          SizedBox(
            height: 320,
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _imageIndex = i),
              itemBuilder: (_, i) => FandomImage(
                imageUrl: images[i],
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _imageIndex ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _imageIndex ? _violet : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_product.currency} ${_product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(Icons.category_outlined, _product.category),
                    _chip(
                      canBuy
                          ? Icons.check_circle_outline
                          : Icons.remove_circle_outline,
                      canBuy ? '${_product.stock} in stock' : 'Out of stock',
                      color: canBuy ? Colors.greenAccent : Colors.redAccent,
                    ),
                    FutureBuilder<String?>(
                      future: _fandomName,
                      builder: (context, snapshot) {
                        final name = snapshot.data;
                        if (name == null || name.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return _chip(Icons.auto_awesome, name, color: _violet);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Description',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _product.description.isEmpty
                      ? 'No description available.'
                      : _product.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 13.5,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ---------------- ADD TO CART BAR ----------------
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: _panel,
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: canBuy && _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove, size: 18),
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: canBuy && _quantity < _product.stock
                          ? () => setState(() => _quantity++)
                          : null,
                      icon: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canBuy && !_adding ? _addToCart : null,
                  icon: _adding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: Text(canBuy ? 'Add to Cart' : 'Out of Stock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _violet,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, {Color color = Colors.white70}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}