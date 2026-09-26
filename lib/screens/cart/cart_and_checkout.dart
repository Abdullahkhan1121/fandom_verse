// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../models/product_model.dart';
// import '../../services/product_service.dart';

// // ==================== MODELS ====================

// class CartItemModel {
//   final String productId;
//   final int quantity;
//   final Timestamp? addedAt;
//   final Timestamp? updatedAt;

//   CartItemModel({
//     required this.productId,
//     required this.quantity,
//     this.addedAt,
//     this.updatedAt,
//   });

//   factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>? ?? {};
//     return CartItemModel(
//       productId: doc.id,
//       quantity: ((data['quantity'] ?? 0) as num).toInt(),
//       addedAt: data['addedAt'] as Timestamp?,
//       updatedAt: data['updatedAt'] as Timestamp?,
//     );
//   }
// }

// class OrderModel {
//   final String id;
//   final String userId;
//   final List<Map<String, dynamic>> items;
//   final double totalAmount;
//   final String currency;
//   final String status;
//   final String shippingAddress;
//   final Timestamp? createdAt;
//   final Timestamp? updatedAt;

//   OrderModel({
//     required this.id,
//     required this.userId,
//     required this.items,
//     required this.totalAmount,
//     required this.currency,
//     required this.status,
//     required this.shippingAddress,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory OrderModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>? ?? {};
//     return OrderModel(
//       id: doc.id,
//       userId: (data['userId'] ?? '') as String,
//       items: List<Map<String, dynamic>>.from(
//           (data['items'] ?? []) as List<dynamic>),
//       totalAmount: ((data['totalAmount'] ?? 0) as num).toDouble(),
//       currency: (data['currency'] ?? 'USD') as String,
//       status: (data['status'] ?? 'pending') as String,
//       shippingAddress: (data['shippingAddress'] ?? '') as String,
//       createdAt: data['createdAt'] as Timestamp?,
//       updatedAt: data['updatedAt'] as Timestamp?,
//     );
//   }
// }

// // ==================== SERVICES ====================

// class CartException implements Exception {
//   final String message;
//   CartException(this.message);
//   @override
//   String toString() => message;
// }

// class CartService {
//   CollectionReference<Map<String, dynamic>> get _cartRef {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) {
//       throw CartException('You must be logged in.');
//     }
//     return FirebaseFirestore.instance
//         .collection('users')
//         .doc(uid)
//         .collection('cart');
//   }

//   Stream<List<CartItemModel>> streamCartItems() {
//     return _cartRef.snapshots().map(
//         (snap) => snap.docs.map(CartItemModel.fromFirestore).toList());
//   }

//   Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
//     final docRef = _cartRef.doc(product.id);
//     DocumentSnapshot<Map<String, dynamic>> doc;
//     try {
//       doc = await docRef.get();
//     } on FirebaseException catch (e) {
//       if (e.code == 'unavailable') {
//         throw CartException(
//             'No internet connection. Please check your network and try again.');
//       }
//       rethrow;
//     }

//     if (doc.exists) {
//       final currentQty = ((doc.data()?['quantity'] ?? 0) as num).toInt();
//       final newQty = currentQty + quantity;
//       if (newQty > product.stock) {
//         throw CartException('Only ${product.stock} left in stock.');
//       }
//       await docRef.update({
//         'quantity': newQty,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } else {
//       if (quantity > product.stock) {
//         throw CartException('Only ${product.stock} left in stock.');
//       }
//       await docRef.set({
//         'productId': product.id,
//         'quantity': quantity,
//         'addedAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     }
//   }

//   Future<void> updateQuantity(String productId, int quantity) async {
//     if (quantity <= 0) {
//       await removeItem(productId);
//       return;
//     }
//     await _cartRef.doc(productId).update({
//       'quantity': quantity,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> removeItem(String productId) async {
//     await _cartRef.doc(productId).delete();
//   }

//   Future<void> clearCart() async {
//     final snap = await _cartRef.get();
//     final batch = FirebaseFirestore.instance.batch();
//     for (final doc in snap.docs) {
//       batch.delete(doc.reference);
//     }
//     await batch.commit();
//   }
// }

// class OrderException implements Exception {
//   final String message;
//   OrderException(this.message);
//   @override
//   String toString() => message;
// }

// class OrderService {
//   final _ordersRef = FirebaseFirestore.instance.collection('orders');
//   final _productService = ProductService();
//   final _cartService = CartService();

//   Stream<List<OrderModel>> streamMyOrders() {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return const Stream.empty();
//     return _ordersRef
//         .where('userId', isEqualTo: uid)
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList());
//   }

//   /// Re-fetches every product fresh from Firestore (never trusts prices
//   /// carried from the cart/checkout UI), validates stock, writes the
//   /// order, then clears the cart. Cart is only cleared on success.
//   Future<String> placeOrder({
//     required List<CartItemModel> cartItems,
//     required String shippingAddress,
//   }) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       throw OrderException('You must be logged in to place an order.');
//     }
//     if (cartItems.isEmpty) {
//       throw OrderException('Your cart is empty.');
//     }
//     if (shippingAddress.trim().isEmpty) {
//       throw OrderException('Please enter a shipping address.');
//     }

//     final itemsSnapshot = <Map<String, dynamic>>[];
//     double total = 0;
//     String currency = 'USD';

//     for (final cartItem in cartItems) {
//       final product = await _productService.getProductById(cartItem.productId);
//       if (product == null) {
//         throw OrderException('A product in your cart no longer exists.');
//       }
//       if (!product.canPurchase || cartItem.quantity > product.stock) {
//         throw OrderException(
//             '${product.name} is out of stock or unavailable.');
//       }
//       currency = product.currency;
//       total += product.price * cartItem.quantity;
//       itemsSnapshot.add({
//         'productId': product.id,
//         'name': product.name,
//         'imageUrl': product.imageUrl,
//         'price': product.price,
//         'quantity': cartItem.quantity,
//         'currency': product.currency,
//       });
//     }

//     final orderRef = _ordersRef.doc();
//     debugPrint('OrderService: writing order ${orderRef.id} for uid=${user.uid}');
//     try {
//       await orderRef.set({
//         'userId': user.uid,
//         'items': itemsSnapshot,
//         'totalAmount': total,
//         'currency': currency,
//         'status': 'pending',
//         'shippingAddress': shippingAddress.trim(),
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       }).timeout(const Duration(seconds: 15));
//     } on FirebaseException catch (e) {
//       debugPrint('OrderService: Firestore error -> ${e.code}: ${e.message}');
//       if (e.code == 'unavailable') {
//         throw OrderException(
//             'No internet connection. Please check your network and try again.');
//       }
//       throw OrderException(
//           'Could not save your order (${e.code}). Please try again.');
//     } on TimeoutException {
//       debugPrint('OrderService: order write timed out after 15s');
//       throw OrderException(
//           'This is taking too long — check your internet connection and try again.');
//     }

//     debugPrint('OrderService: order ${orderRef.id} saved successfully');

//     await _cartService.clearCart();

//     return orderRef.id;
//   }
// }

// // ==================== CART SCREEN ====================

// class _EnrichedCartItem {
//   final CartItemModel item;
//   final ProductModel? product;
//   _EnrichedCartItem({required this.item, required this.product});
// }

// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   final _cartService = CartService();
//   final _productService = ProductService();

//   // Caches each product fetch by id so the FutureBuilder below doesn't
//   // re-fetch (and re-show a loading spinner / flicker the image) every
//   // time the cart stream emits — only new productIds trigger a fetch.
//   final Map<String, Future<ProductModel?>> _productFutures = {};

//   Future<ProductModel?> _getProduct(String productId) {
//     return _productFutures.putIfAbsent(
//         productId, () => _productService.getProductById(productId));
//   }

//   Future<List<_EnrichedCartItem>> _enrich(List<CartItemModel> items) async {
//     return Future.wait(items.map((item) async {
//       final product = await _getProduct(item.productId);
//       return _EnrichedCartItem(item: item, product: product);
//     }));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0B0D14),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0B0D14),
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text('My Cart', style: TextStyle(color: Colors.white)),
//       ),
//       body: StreamBuilder<List<CartItemModel>>(
//         stream: _cartService.streamCartItems(),
//         builder: (context, cartSnapshot) {
//           if (cartSnapshot.hasError) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Text(
//                   _friendlyError(cartSnapshot.error),
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//               ),
//             );
//           }
//           if (!cartSnapshot.hasData) {
//             return const Center(
//                 child: CircularProgressIndicator(color: Colors.white));
//           }
//           final cartItems = cartSnapshot.data!;
//           if (cartItems.isEmpty) {
//             return const _EmptyCart();
//           }

//           return FutureBuilder<List<_EnrichedCartItem>>(
//             future: _enrich(cartItems),
//             builder: (context, enrichedSnapshot) {
//               if (enrichedSnapshot.hasError) {
//                 return Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Text(
//                       _friendlyError(enrichedSnapshot.error),
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(color: Colors.white70),
//                     ),
//                   ),
//                 );
//               }
//               if (!enrichedSnapshot.hasData) {
//                 return const Center(
//                     child: CircularProgressIndicator(color: Colors.white));
//               }
//               final enriched = enrichedSnapshot.data!;
//               final subtotal = enriched.fold<double>(
//                   0,
//                   (sum, e) =>
//                       sum + (e.product?.price ?? 0) * e.item.quantity);
//               final currency = enriched
//                       .firstWhere((e) => e.product != null,
//                           orElse: () => enriched.first)
//                       .product
//                       ?.currency ??
//                   '';
//               final itemCount =
//                   cartItems.fold<int>(0, (sum, i) => sum + i.quantity);

//               return Column(
//                 children: [
//                   Expanded(
//                     child: ListView.separated(
//                       padding: const EdgeInsets.all(20),
//                       itemCount: enriched.length,
//                       separatorBuilder: (_, __) => const SizedBox(height: 14),
//                       itemBuilder: (context, index) {
//                         final e = enriched[index];
//                         return _CartItemTile(
//                           item: e.item,
//                           product: e.product,
//                           onIncrease: e.product == null
//                               ? null
//                               : () {
//                                   if (e.item.quantity + 1 >
//                                       e.product!.stock) {
//                                     ScaffoldMessenger.of(context)
//                                         .showSnackBar(SnackBar(
//                                       content: Text(
//                                           'Only ${e.product!.stock} in stock'),
//                                     ));
//                                     return;
//                                   }
//                                   _cartService.updateQuantity(
//                                       e.item.productId, e.item.quantity + 1);
//                                 },
//                           onDecrease: () => _cartService.updateQuantity(
//                               e.item.productId, e.item.quantity - 1),
//                           onRemove: () {
//                             _productFutures.remove(e.item.productId);
//                             _cartService.removeItem(e.item.productId);
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                   _CartFooter(
//                     subtotal: subtotal,
//                     currency: currency,
//                     itemCount: itemCount,
//                     onCheckout: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => const CheckoutScreen()),
//                       );
//                     },
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   String _friendlyError(Object? error) {
//     if (error is FirebaseException && error.code == 'unavailable') {
//       return 'No internet connection. Please check your network and try again.';
//     }
//     return 'Something went wrong loading your cart.\n$error';
//   }
// }

// class _CartItemTile extends StatelessWidget {
//   final CartItemModel item;
//   final ProductModel? product;
//   final VoidCallback? onIncrease;
//   final VoidCallback onDecrease;
//   final VoidCallback onRemove;

//   const _CartItemTile({
//     required this.item,
//     required this.product,
//     required this.onIncrease,
//     required this.onDecrease,
//     required this.onRemove,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (product == null) {
//       return Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: const Color(0xFF161A24),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Row(
//           children: [
//             const Expanded(
//               child: Text('This product is no longer available',
//                   style: TextStyle(color: Colors.white70)),
//             ),
//             IconButton(
//               onPressed: onRemove,
//               icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
//             ),
//           ],
//         ),
//       );
//     }

//     final unavailable = !product!.isAvailable;

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFF161A24),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: SizedBox(
//               width: 64,
//               height: 64,
//               child: product!.imageUrl.isNotEmpty
//                   ? Image.network(
//                       product!.imageUrl,
//                       fit: BoxFit.cover,
//                       loadingBuilder: (context, child, progress) {
//                         if (progress == null) return child;
//                         return Container(
//                           color: const Color(0xFF1E2230),
//                           child: const Center(
//                             child: SizedBox(
//                               width: 18,
//                               height: 18,
//                               child: CircularProgressIndicator(
//                                   strokeWidth: 2, color: Colors.white38),
//                             ),
//                           ),
//                         );
//                       },
//                       errorBuilder: (_, __, ___) => Container(
//                           color: const Color(0xFF1E2230),
//                           child: const Icon(Icons.image_not_supported_outlined,
//                               color: Colors.white38)),
//                     )
//                   : Container(
//                       color: const Color(0xFF1E2230),
//                       child: const Icon(Icons.image_not_supported_outlined,
//                           color: Colors.white38)),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(product!.name,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 4),
//                 Text(
//                     '${product!.currency} ${product!.price.toStringAsFixed(0)}',
//                     style: TextStyle(
//                         color: Colors.white.withValues(alpha: 0.6),
//                         fontSize: 12)),
//                 if (unavailable)
//                   const Padding(
//                     padding: EdgeInsets.only(top: 4),
//                     child: Text('Currently unavailable',
//                         style:
//                             TextStyle(color: Colors.redAccent, fontSize: 11)),
//                   ),
//               ],
//             ),
//           ),
//           Column(
//             children: [
//               Row(
//                 children: [
//                   _StepperButton(icon: Icons.remove, onTap: onDecrease),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Text('${item.quantity}',
//                         style: const TextStyle(
//                             color: Colors.white, fontWeight: FontWeight.w600)),
//                   ),
//                   _StepperButton(
//                       icon: Icons.add,
//                       onTap: unavailable ? null : onIncrease),
//                 ],
//               ),
//               Text(
//                   '${product!.currency} ${(product!.price * item.quantity).toStringAsFixed(0)}',
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StepperButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback? onTap;
//   const _StepperButton({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final disabled = onTap == null;
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 26,
//         height: 26,
//         decoration: BoxDecoration(
//           color: disabled
//               ? Colors.white.withValues(alpha: 0.04)
//               : Colors.white.withValues(alpha: 0.08),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(icon,
//             size: 14,
//             color: disabled ? Colors.white24 : Colors.white),
//       ),
//     );
//   }
// }

// class _CartFooter extends StatelessWidget {
//   final double subtotal;
//   final String currency;
//   final int itemCount;
//   final VoidCallback onCheckout;

//   const _CartFooter({
//     required this.subtotal,
//     required this.currency,
//     required this.itemCount,
//     required this.onCheckout,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
//         decoration: BoxDecoration(
//           color: const Color(0xFF12141D),
//           border: Border(
//               top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Subtotal ($itemCount items)',
//                     style: TextStyle(
//                         color: Colors.white.withValues(alpha: 0.6),
//                         fontSize: 13)),
//                 Text('$currency ${subtotal.toStringAsFixed(0)}',
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16)),
//               ],
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: itemCount == 0 ? null : onCheckout,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF4F7CFF),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(24)),
//                 ),
//                 child: const Text('Proceed to Checkout',
//                     style: TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.w600)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _EmptyCart extends StatelessWidget {
//   const _EmptyCart();
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.shopping_cart_outlined,
//               size: 56, color: Colors.white.withValues(alpha: 0.3)),
//           const SizedBox(height: 16),
//           Text('Your cart is empty',
//               style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
//         ],
//       ),
//     );
//   }
// }

// // ==================== CARD NUMBER FORMATTER ====================

// class _CardNumberFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     final allDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
//     final digitsOnly =
//         allDigits.length > 16 ? allDigits.substring(0, 16) : allDigits;
//     final buffer = StringBuffer();
//     for (var i = 0; i < digitsOnly.length; i++) {
//       buffer.write(digitsOnly[i]);
//       if ((i + 1) % 4 == 0 && i + 1 != digitsOnly.length) buffer.write(' ');
//     }
//     return TextEditingValue(
//       text: buffer.toString(),
//       selection: TextSelection.collapsed(offset: buffer.length),
//     );
//   }
// }

// class _ExpiryFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
//     final trimmed =
//         digitsOnly.length > 4 ? digitsOnly.substring(0, 4) : digitsOnly;
//     if (trimmed.length <= 2) {
//       return TextEditingValue(
//         text: trimmed,
//         selection: TextSelection.collapsed(offset: trimmed.length),
//       );
//     }
//     final formatted = '${trimmed.substring(0, 2)}/${trimmed.substring(2)}';
//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//   }
// }

// // ==================== CHECKOUT SCREEN ====================

// class CheckoutScreen extends StatefulWidget {
//   const CheckoutScreen({super.key});

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final _cartService = CartService();
//   final _orderService = OrderService();
//   final _addressController = TextEditingController();
//   final _cardNameController = TextEditingController();
//   final _cardNumberController = TextEditingController();
//   final _expiryController = TextEditingController();
//   final _cvvController = TextEditingController();

//   bool _placing = false;

//   @override
//   void dispose() {
//     _addressController.dispose();
//     _cardNameController.dispose();
//     _cardNumberController.dispose();
//     _expiryController.dispose();
//     _cvvController.dispose();
//     super.dispose();
//   }

//   String get _cardBrand {
//     final digits = _cardNumberController.text.replaceAll(' ', '');
//     if (digits.startsWith('4')) return 'Visa';
//     if (digits.startsWith('5')) return 'Mastercard';
//     return 'Card';
//   }

//   Future<void> _placeOrder(List<CartItemModel> cartItems) async {
//     if (_addressController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter a shipping address')));
//       return;
//     }
//     final digits = _cardNumberController.text.replaceAll(' ', '');
//     if (digits.length < 12) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text('Enter a demo card number (12–16 digits)')));
//       return;
//     }
//     if (_expiryController.text.length < 5) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Enter expiry as MM/YY')));
//       return;
//     }
//     if (_cvvController.text.trim().length < 3) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Enter a 3-digit CVV')));
//       return;
//     }

//     setState(() => _placing = true);
//     try {
//       final orderId = await _orderService.placeOrder(
//         cartItems: cartItems,
//         shippingAddress: _addressController.text,
//       );
//       if (!mounted) return;
//       setState(() => _placing = false);
//       await showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => AlertDialog(
//           backgroundColor: const Color(0xFF161A24),
//           title: const Text('Order placed!',
//               style: TextStyle(color: Colors.white)),
//           content: Text('Order #$orderId has been created.',
//               style: const TextStyle(color: Colors.white70)),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).popUntil((route) => route.isFirst);
//               },
//               child: const Text('Done'),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       debugPrint('CheckoutScreen: place order failed -> $e');
//       if (mounted) {
//         setState(() => _placing = false);
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(e.toString())));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0B0D14),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0B0D14),
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text('Checkout', style: TextStyle(color: Colors.white)),
//       ),
//       body: StreamBuilder<List<CartItemModel>>(
//         stream: _cartService.streamCartItems(),
//         builder: (context, snapshot) {
//           final cartItems = snapshot.data ?? [];
//           if (snapshot.hasData && cartItems.isEmpty) {
//             return const Center(
//               child: Text('Your cart is empty',
//                   style: TextStyle(color: Colors.white70)),
//             );
//           }
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Shipping Address',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15)),
//                 const SizedBox(height: 10),
//                 _DarkField(
//                   controller: _addressController,
//                   hint: 'House #, street, city',
//                   maxLines: 3,
//                 ),
//                 const SizedBox(height: 24),
//                 const Text('Payment',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15)),
//                 const SizedBox(height: 10),
//                 _DummyPaymentCard(
//                   brand: _cardBrand,
//                   name: _cardNameController.text,
//                   number: _cardNumberController.text,
//                   expiry: _expiryController.text,
//                 ),
//                 const SizedBox(height: 16),
//                 _DarkField(
//                   controller: _cardNumberController,
//                   hint: 'Card number',
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [_CardNumberFormatter()],
//                   prefixIcon: Icons.credit_card,
//                   onChanged: (_) => setState(() {}),
//                 ),
//                 const SizedBox(height: 10),
//                 _DarkField(
//                   controller: _cardNameController,
//                   hint: 'Cardholder name',
//                   onChanged: (_) => setState(() {}),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _DarkField(
//                         controller: _expiryController,
//                         hint: 'MM/YY',
//                         keyboardType: TextInputType.number,
//                         inputFormatters: [_ExpiryFormatter()],
//                         onChanged: (_) => setState(() {}),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: _DarkField(
//                         controller: _cvvController,
//                         hint: 'CVV',
//                         keyboardType: TextInputType.number,
//                         maxLength: 3,
//                         obscure: true,
//                         onChanged: (_) => setState(() {}),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.amber.withValues(alpha: 0.08),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                         color: Colors.amber.withValues(alpha: 0.3)),
//                   ),
//                   child: const Text(
//                     'Demo payment only — no real card is charged. '
//                     'Fandom Verse does not process real payments yet.',
//                     style: TextStyle(color: Colors.amber, fontSize: 11.5),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _placing ? null : () => _placeOrder(cartItems),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF4F7CFF),
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(24)),
//                     ),
//                     child: _placing
//                         ? const SizedBox(
//                             height: 18,
//                             width: 18,
//                             child: CircularProgressIndicator(
//                                 strokeWidth: 2, color: Colors.white))
//                         : const Text('Place Order',
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _DummyPaymentCard extends StatelessWidget {
//   final String brand;
//   final String name;
//   final String number;
//   final String expiry;
//   const _DummyPaymentCard({
//     required this.brand,
//     required this.name,
//     required this.number,
//     required this.expiry,
//   });

//   String get _displayNumber => number.isEmpty
//       ? '•••• •••• •••• ••••'
//       : number.padRight(19, '•').substring(0, 19);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 190,
//       width: double.infinity,
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFF232849), Color(0xFF0F1119)],
//         ),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF4F7CFF).withValues(alpha: 0.15),
//             blurRadius: 24,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 width: 38,
//                 height: 28,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                       colors: [Color(0xFFFFD700), Color(0xFFB8860B)]),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ),
//               Text(brand,
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       fontStyle: FontStyle.italic)),
//             ],
//           ),
//           const Spacer(),
//           Text(_displayNumber,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 19,
//                   letterSpacing: 2,
//                   fontWeight: FontWeight.w600,
//                   fontFamily: 'monospace')),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('CARD HOLDER',
//                         style: TextStyle(
//                             color: Colors.white.withValues(alpha: 0.4),
//                             fontSize: 9,
//                             letterSpacing: 1)),
//                     const SizedBox(height: 4),
//                     Text(name.isEmpty ? 'YOUR NAME' : name.toUpperCase(),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600)),
//                   ],
//                 ),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text('EXPIRES',
//                       style: TextStyle(
//                           color: Colors.white.withValues(alpha: 0.4),
//                           fontSize: 9,
//                           letterSpacing: 1)),
//                   const SizedBox(height: 4),
//                   Text(expiry.isEmpty ? 'MM/YY' : expiry,
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600)),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DarkField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final int maxLines;
//   final int? maxLength;
//   final TextInputType? keyboardType;
//   final ValueChanged<String>? onChanged;
//   final List<TextInputFormatter>? inputFormatters;
//   final IconData? prefixIcon;
//   final bool obscure;

//   const _DarkField({
//     required this.controller,
//     required this.hint,
//     this.maxLines = 1,
//     this.maxLength,
//     this.keyboardType,
//     this.onChanged,
//     this.inputFormatters,
//     this.prefixIcon,
//     this.obscure = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF161A24),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: TextField(
//         controller: controller,
//         maxLines: maxLines,
//         maxLength: maxLength,
//         keyboardType: keyboardType,
//         onChanged: onChanged,
//         inputFormatters: inputFormatters,
//         obscureText: obscure,
//         style: const TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
//           prefixIcon: prefixIcon == null
//               ? null
//               : Icon(prefixIcon, color: Colors.white.withValues(alpha: 0.4)),
//           border: InputBorder.none,
//           counterStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';

// ==================== MODELS ====================

class CartItemModel {
  final String productId;
  final int quantity;
  final Timestamp? addedAt;
  final Timestamp? updatedAt;

  CartItemModel({
    required this.productId,
    required this.quantity,
    this.addedAt,
    this.updatedAt,
  });

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CartItemModel(
      productId: doc.id,
      quantity: ((data['quantity'] ?? 0) as num).toInt(),
      addedAt: data['addedAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String currency;
  final String status;
  final String shippingAddress;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.shippingAddress,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      items: List<Map<String, dynamic>>.from(
          (data['items'] ?? []) as List<dynamic>),
      totalAmount: ((data['totalAmount'] ?? 0) as num).toDouble(),
      currency: (data['currency'] ?? 'USD') as String,
      status: (data['status'] ?? 'pending') as String,
      shippingAddress: (data['shippingAddress'] ?? '') as String,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }
}

// ==================== SERVICES ====================

class CartException implements Exception {
  final String message;
  CartException(this.message);
  @override
  String toString() => message;
}

class CartService {
  CollectionReference<Map<String, dynamic>> get _cartRef {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw CartException('You must be logged in.');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart');
  }

  Stream<List<CartItemModel>> streamCartItems() {
    return _cartRef.snapshots().map(
        (snap) => snap.docs.map(CartItemModel.fromFirestore).toList());
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final docRef = _cartRef.doc(product.id);
    DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      doc = await docRef.get();
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        throw CartException(
            'No internet connection. Please check your network and try again.');
      }
      rethrow;
    }

    if (doc.exists) {
      final currentQty = ((doc.data()?['quantity'] ?? 0) as num).toInt();
      final newQty = currentQty + quantity;
      if (newQty > product.stock) {
        throw CartException('Only ${product.stock} left in stock.');
      }
      await docRef.update({
        'quantity': newQty,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      if (quantity > product.stock) {
        throw CartException('Only ${product.stock} left in stock.');
      }
      await docRef.set({
        'productId': product.id,
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }
    await _cartRef.doc(productId).update({
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeItem(String productId) async {
    await _cartRef.doc(productId).delete();
  }

  Future<void> clearCart() async {
    final snap = await _cartRef.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

class OrderException implements Exception {
  final String message;
  OrderException(this.message);
  @override
  String toString() => message;
}

class OrderService {
  final _ordersRef = FirebaseFirestore.instance.collection('orders');
  final _productService = ProductService();
  final _cartService = CartService();

  Stream<List<OrderModel>> streamMyOrders() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _ordersRef
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList());
  }

  /// Re-fetches every product fresh from Firestore (never trusts prices
  /// carried from the cart/checkout UI), validates stock, writes the
  /// order, then clears the cart. Cart is only cleared on success.
  Future<String> placeOrder({
    required List<CartItemModel> cartItems,
    required String shippingAddress,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw OrderException('You must be logged in to place an order.');
    }
    if (cartItems.isEmpty) {
      throw OrderException('Your cart is empty.');
    }
    if (shippingAddress.trim().isEmpty) {
      throw OrderException('Please enter a shipping address.');
    }

    final itemsSnapshot = <Map<String, dynamic>>[];
    double total = 0;
    String currency = 'USD';

    for (final cartItem in cartItems) {
      final product = await _productService.getProductById(cartItem.productId);
      if (product == null) {
        throw OrderException('A product in your cart no longer exists.');
      }
      if (!product.canPurchase || cartItem.quantity > product.stock) {
        throw OrderException(
            '${product.name} is out of stock or unavailable.');
      }
      currency = product.currency;
      total += product.price * cartItem.quantity;
      itemsSnapshot.add({
        'productId': product.id,
        'name': product.name,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'quantity': cartItem.quantity,
        'currency': product.currency,
      });
    }

    final orderRef = _ordersRef.doc();
    debugPrint('OrderService: writing order ${orderRef.id} for uid=${user.uid}');
    try {
      await orderRef.set({
        'userId': user.uid,
        'items': itemsSnapshot,
        'totalAmount': total,
        'currency': currency,
        'status': 'pending',
        'shippingAddress': shippingAddress.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 15));
    } on FirebaseException catch (e) {
      debugPrint('OrderService: Firestore error -> ${e.code}: ${e.message}');
      if (e.code == 'unavailable') {
        throw OrderException(
            'No internet connection. Please check your network and try again.');
      }
      throw OrderException(
          'Could not save your order (${e.code}). Please try again.');
    } on TimeoutException {
      debugPrint('OrderService: order write timed out after 15s');
      throw OrderException(
          'This is taking too long — check your internet connection and try again.');
    }

    debugPrint('OrderService: order ${orderRef.id} saved successfully');

    await _cartService.clearCart();

    return orderRef.id;
  }
}

// ==================== IMAGE HELPER (network + base64) ====================

/// Renders a product image whether [imageSource] is a normal network URL
/// or a base64-encoded image string (plain base64, or a full
/// "data:image/...;base64,...." data URI).
Widget buildProductImage(
  String imageSource, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
}) {
  Widget placeholder(IconData icon) {
    final box = Container(
      width: width,
      height: height,
      color: const Color(0xFF1E2230),
      child: Icon(icon, color: Colors.white38),
    );
    return borderRadius == null
        ? box
        : ClipRRect(borderRadius: borderRadius, child: box);
  }

  if (imageSource.isEmpty) {
    return placeholder(Icons.image_not_supported_outlined);
  }

  final isDataUri = imageSource.startsWith('data:image');
  // Anything that isn't a URL and isn't a data URI but is a long-ish
  // string is treated as a raw base64 payload (e.g. image_picker output
  // saved straight into Firestore without going through Storage).
  final looksLikeRawBase64 = !imageSource.startsWith('http') &&
      !isDataUri &&
      imageSource.length > 100;

  if (isDataUri || looksLikeRawBase64) {
    try {
      final base64Str = isDataUri ? imageSource.split(',').last : imageSource;
      final bytes = base64Decode(base64Str);
      final img = Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            placeholder(Icons.broken_image_outlined),
      );
      return borderRadius == null
          ? img
          : ClipRRect(borderRadius: borderRadius, child: img);
    } catch (_) {
      return placeholder(Icons.broken_image_outlined);
    }
  }

  // Fallback: normal network image.
  final img = Image.network(
    imageSource,
    width: width,
    height: height,
    fit: fit,
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return Container(
        width: width,
        height: height,
        color: const Color(0xFF1E2230),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38),
          ),
        ),
      );
    },
    errorBuilder: (_, __, ___) =>
        placeholder(Icons.image_not_supported_outlined),
  );
  return borderRadius == null
      ? img
      : ClipRRect(borderRadius: borderRadius, child: img);
}

// ==================== CART SCREEN ====================

class _EnrichedCartItem {
  final CartItemModel item;
  final ProductModel? product;
  _EnrichedCartItem({required this.item, required this.product});
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartService = CartService();
  final _productService = ProductService();

  // Caches each product fetch by id so the FutureBuilder below doesn't
  // re-fetch (and re-show a loading spinner / flicker the image) every
  // time the cart stream emits — only new productIds trigger a fetch.
  final Map<String, Future<ProductModel?>> _productFutures = {};

  Future<ProductModel?> _getProduct(String productId) {
    return _productFutures.putIfAbsent(
        productId, () => _productService.getProductById(productId));
  }

  Future<List<_EnrichedCartItem>> _enrich(List<CartItemModel> items) async {
    return Future.wait(items.map((item) async {
      final product = await _getProduct(item.productId);
      return _EnrichedCartItem(item: item, product: product);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D14),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('My Cart', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<CartItemModel>>(
        stream: _cartService.streamCartItems(),
        builder: (context, cartSnapshot) {
          if (cartSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _friendlyError(cartSnapshot.error),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            );
          }
          if (!cartSnapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }
          final cartItems = cartSnapshot.data!;
          if (cartItems.isEmpty) {
            return const _EmptyCart();
          }

          return FutureBuilder<List<_EnrichedCartItem>>(
            future: _enrich(cartItems),
            builder: (context, enrichedSnapshot) {
              if (enrichedSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _friendlyError(enrichedSnapshot.error),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              }
              if (!enrichedSnapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }
              final enriched = enrichedSnapshot.data!;
              final subtotal = enriched.fold<double>(
                  0,
                  (sum, e) =>
                      sum + (e.product?.price ?? 0) * e.item.quantity);
              final currency = enriched
                      .firstWhere((e) => e.product != null,
                          orElse: () => enriched.first)
                      .product
                      ?.currency ??
                  '';
              final itemCount =
                  cartItems.fold<int>(0, (sum, i) => sum + i.quantity);

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: enriched.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final e = enriched[index];
                        return _CartItemTile(
                          item: e.item,
                          product: e.product,
                          onIncrease: e.product == null
                              ? null
                              : () {
                                  if (e.item.quantity + 1 >
                                      e.product!.stock) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'Only ${e.product!.stock} in stock'),
                                    ));
                                    return;
                                  }
                                  _cartService.updateQuantity(
                                      e.item.productId, e.item.quantity + 1);
                                },
                          onDecrease: () => _cartService.updateQuantity(
                              e.item.productId, e.item.quantity - 1),
                          onRemove: () {
                            _productFutures.remove(e.item.productId);
                            _cartService.removeItem(e.item.productId);
                          },
                        );
                      },
                    ),
                  ),
                  _CartFooter(
                    subtotal: subtotal,
                    currency: currency,
                    itemCount: itemCount,
                    onCheckout: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CheckoutScreen()),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _friendlyError(Object? error) {
    if (error is FirebaseException && error.code == 'unavailable') {
      return 'No internet connection. Please check your network and try again.';
    }
    return 'Something went wrong loading your cart.\n$error';
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final ProductModel? product;
  final VoidCallback? onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.product,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF161A24),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text('This product is no longer available',
                  style: TextStyle(color: Colors.white70)),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
          ],
        ),
      );
    }

    final unavailable = !product!.isAvailable;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161A24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: buildProductImage(
              product!.imageUrl,
              width: 64,
              height: 64,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                    '${product!.currency} ${product!.price.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12)),
                if (unavailable)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Currently unavailable',
                        style:
                            TextStyle(color: Colors.redAccent, fontSize: 11)),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _StepperButton(icon: Icons.remove, onTap: onDecrease),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${item.quantity}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  _StepperButton(
                      icon: Icons.add,
                      onTap: unavailable ? null : onIncrease),
                ],
              ),
              Text(
                  '${product!.currency} ${(product!.price * item.quantity).toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: disabled
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 14,
            color: disabled ? Colors.white24 : Colors.white),
      ),
    );
  }
}

class _CartFooter extends StatelessWidget {
  final double subtotal;
  final String currency;
  final int itemCount;
  final VoidCallback onCheckout;

  const _CartFooter({
    required this.subtotal,
    required this.currency,
    required this.itemCount,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(
          color: const Color(0xFF12141D),
          border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal ($itemCount items)',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13)),
                Text('$currency ${subtotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: itemCount == 0 ? null : onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F7CFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Proceed to Checkout',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 56, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Your cart is empty',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

// ==================== CARD NUMBER FORMATTER ====================

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final allDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final digitsOnly =
        allDigits.length > 16 ? allDigits.substring(0, 16) : allDigits;
    final buffer = StringBuffer();
    for (var i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if ((i + 1) % 4 == 0 && i + 1 != digitsOnly.length) buffer.write(' ');
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final trimmed =
        digitsOnly.length > 4 ? digitsOnly.substring(0, 4) : digitsOnly;
    if (trimmed.length <= 2) {
      return TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
    }
    final formatted = '${trimmed.substring(0, 2)}/${trimmed.substring(2)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ==================== CHECKOUT SCREEN ====================

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _cartService = CartService();
  final _orderService = OrderService();
  final _addressController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _placing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String get _cardBrand {
    final digits = _cardNumberController.text.replaceAll(' ', '');
    if (digits.startsWith('4')) return 'Visa';
    if (digits.startsWith('5')) return 'Mastercard';
    return 'Card';
  }

  Future<void> _placeOrder(List<CartItemModel> cartItems) async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a shipping address')));
      return;
    }
    final digits = _cardNumberController.text.replaceAll(' ', '');
    if (digits.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enter a demo card number (12–16 digits)')));
      return;
    }
    if (_expiryController.text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter expiry as MM/YY')));
      return;
    }
    if (_cvvController.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a 3-digit CVV')));
      return;
    }

    setState(() => _placing = true);
    try {
      final orderId = await _orderService.placeOrder(
        cartItems: cartItems,
        shippingAddress: _addressController.text,
      );
      if (!mounted) return;
      setState(() => _placing = false);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF161A24),
          title: const Text('Order placed!',
              style: TextStyle(color: Colors.white)),
          content: Text('Order #$orderId has been created.',
              style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('CheckoutScreen: place order failed -> $e');
      if (mounted) {
        setState(() => _placing = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D14),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<CartItemModel>>(
        stream: _cartService.streamCartItems(),
        builder: (context, snapshot) {
          final cartItems = snapshot.data ?? [];
          if (snapshot.hasData && cartItems.isEmpty) {
            return const Center(
              child: Text('Your cart is empty',
                  style: TextStyle(color: Colors.white70)),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Shipping Address',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 10),
                _DarkField(
                  controller: _addressController,
                  hint: 'House #, street, city',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                const Text('Payment',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 10),
                _DummyPaymentCard(
                  brand: _cardBrand,
                  name: _cardNameController.text,
                  number: _cardNumberController.text,
                  expiry: _expiryController.text,
                ),
                const SizedBox(height: 16),
                _DarkField(
                  controller: _cardNumberController,
                  hint: 'Card number',
                  keyboardType: TextInputType.number,
                  inputFormatters: [_CardNumberFormatter()],
                  prefixIcon: Icons.credit_card,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                _DarkField(
                  controller: _cardNameController,
                  hint: 'Cardholder name',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DarkField(
                        controller: _expiryController,
                        hint: 'MM/YY',
                        keyboardType: TextInputType.number,
                        inputFormatters: [_ExpiryFormatter()],
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DarkField(
                        controller: _cvvController,
                        hint: 'CVV',
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        obscure: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'Demo payment only — no real card is charged. '
                    'Fandom Verse does not process real payments yet.',
                    style: TextStyle(color: Colors.amber, fontSize: 11.5),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _placing ? null : () => _placeOrder(cartItems),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F7CFF),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: _placing
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Place Order',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DummyPaymentCard extends StatelessWidget {
  final String brand;
  final String name;
  final String number;
  final String expiry;
  const _DummyPaymentCard({
    required this.brand,
    required this.name,
    required this.number,
    required this.expiry,
  });

  String get _displayNumber => number.isEmpty
      ? '•••• •••• •••• ••••'
      : number.padRight(19, '•').substring(0, 19);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF232849), Color(0xFF0F1119)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F7CFF).withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFB8860B)]),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Text(brand,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontStyle: FontStyle.italic)),
            ],
          ),
          const Spacer(),
          Text(_displayNumber,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace')),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CARD HOLDER',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 9,
                            letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(name.isEmpty ? 'YOUR NAME' : name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('EXPIRES',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 9,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(expiry.isEmpty ? 'MM/YY' : expiry,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final bool obscure;

  const _DarkField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.onChanged,
    this.inputFormatters,
    this.prefixIcon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161A24),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
          prefixIcon: prefixIcon == null
              ? null
              : Icon(prefixIcon, color: Colors.white.withValues(alpha: 0.4)),
          border: InputBorder.none,
          counterStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}