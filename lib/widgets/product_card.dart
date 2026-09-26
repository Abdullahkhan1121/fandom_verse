import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlistToggle;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.isWishlisted,
    required this.onTap,
    required this.onWishlistToggle,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !product.canPurchase;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161A24),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: AspectRatio(
                    aspectRatio: 1.15,
                    child: product.imageUrl.isNotEmpty
    ? (product.imageUrl.startsWith('data:image') ||
            !product.imageUrl.startsWith('http'))
        ? Image.memory(
            base64Decode(
              product.imageUrl.contains(',')
                  ? product.imageUrl.split(',').last
                  : product.imageUrl,
            ),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _ImageFallback(),
          )
        : Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _ImageFallback(),
          )
    : const _ImageFallback(),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onWishlistToggle,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black.withValues(alpha: 0.45),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isWishlisted ? Colors.pinkAccent : Colors.white,
                      ),
                    ),
                  ),
                ),
                if (disabled)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18)),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Out of stock',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
    child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
  child: Text(
    product.description,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,  ),
),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.currency} ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: disabled ? null : onAddToCart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: disabled
                                ? null
                                : const LinearGradient(colors: [
                                    Color(0xFF4F7CFF),
                                    Color(0xFF9B5CFF),
                                  ]),
                            color: disabled
                                ? Colors.white.withValues(alpha: 0.08)
                                : null,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.add, size: 14, color: Colors.white),
                              SizedBox(width: 3),
                              Text('Add',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E2230),
      alignment: Alignment.center,
      child: Icon(Icons.image_not_supported_outlined,
          color: Colors.white.withValues(alpha: 0.3)),
    );
  }
}