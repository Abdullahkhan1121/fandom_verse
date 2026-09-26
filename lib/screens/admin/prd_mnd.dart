// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fandom_verse/screens/admin/add_prd_form.dart';
// import 'package:flutter/material.dart';


// class ProductManagementScreen extends StatefulWidget {
//   const ProductManagementScreen({super.key});

//   @override
//   State<ProductManagementScreen> createState() =>
//       _ProductManagementScreenState();
// }

// class _ProductManagementScreenState extends State<ProductManagementScreen> {
//   final TextEditingController _searchController = TextEditingController();

//   static const Color _backgroundColor = Color(0xFF080A12);
//   static const Color _panelColor = Color(0xFF111522);
//   static const Color _primaryColor = Color(0xFF7C5CFC);
//   static const Color _primaryLightColor = Color(0xFF9D87FF);
//   static const Color _goldColor = Color(0xFFE0B45A);
//   static const Color _whiteColor = Color(0xFFF5F5F7);
//   static const Color _mutedColor = Color(0xFF9CA3B5);
//   static const Color _borderColor = Color(0xFF272D40);

//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();

//     _searchController.addListener(() {
//       setState(() {
//         _searchQuery = _searchController.text.trim().toLowerCase();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _backgroundColor,
//       appBar: AppBar(
//         backgroundColor: _backgroundColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_rounded,
//             color: _whiteColor,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           'Manage Products',
//           style: TextStyle(
//             color: _whiteColor,
//             fontSize: 20,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             const _BackgroundGlow(),
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 final isMobile = constraints.maxWidth < 600;

//                 return SingleChildScrollView(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: isMobile ? 16 : 30,
//                     vertical: 20,
//                   ),
//                   child: Center(
//                     child: ConstrainedBox(
//                       constraints: const BoxConstraints(
//                         maxWidth: 1250,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildHeader(isMobile),
//                           const SizedBox(height: 20),
//                           _buildSearchBar(),
//                           const SizedBox(height: 22),
//                           _buildProductsList(constraints.maxWidth),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(bool isMobile) {
//     if (isMobile) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeaderText(),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             height: 48,
//             child: _buildAddButton(),
//           ),
//         ],
//       );
//     }

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           child: _buildHeaderText(),
//         ),
//         const SizedBox(width: 20),
//         SizedBox(
//           height: 48,
//           child: _buildAddButton(),
//         ),
//       ],
//     );
//   }

//   Widget _buildHeaderText() {
//     return const Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Products',
//           style: TextStyle(
//             color: _whiteColor,
//             fontSize: 27,
//             fontWeight: FontWeight.w900,
//           ),
//         ),
//         SizedBox(height: 6),
//         Text(
//           'Manage your Fandom Verse products and inventory.',
//           style: TextStyle(
//             color: _mutedColor,
//             fontSize: 13,
//             height: 1.4,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAddButton() {
//     return ElevatedButton.icon(
//       onPressed: _openAddProduct,
//       icon: const Icon(
//         Icons.add_rounded,
//         size: 21,
//       ),
//       label: const Text(
//         'Add Item',
//         style: TextStyle(
//           fontSize: 13.5,
//           fontWeight: FontWeight.w800,
//         ),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         padding: const EdgeInsets.symmetric(
//           horizontal: 20,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: _panelColor,
//         borderRadius: BorderRadius.circular(17),
//         border: Border.all(
//           color: _borderColor,
//         ),
//       ),
//       child: TextField(
//         controller: _searchController,
//         style: const TextStyle(
//           color: _whiteColor,
//           fontSize: 14,
//         ),
//         cursorColor: _primaryLightColor,
//         decoration: InputDecoration(
//           hintText: 'Search products by name, category or fandom...',
//           hintStyle: const TextStyle(
//             color: _mutedColor,
//             fontSize: 13,
//           ),
//           prefixIcon: const Icon(
//             Icons.search_rounded,
//             color: _primaryLightColor,
//             size: 22,
//           ),
//           suffixIcon: _searchQuery.isNotEmpty
//               ? IconButton(
//                   tooltip: 'Clear search',
//                   icon: const Icon(
//                     Icons.close_rounded,
//                     color: _mutedColor,
//                   ),
//                   onPressed: () {
//                     _searchController.clear();
//                   },
//                 )
//               : null,
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 17,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProductsList(double screenWidth) {
//     return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//       stream: FirebaseFirestore.instance
//           .collection('products')
//           .orderBy('createdAt', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return _buildErrorState(snapshot.error.toString());
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _buildLoadingState();
//         }

//         final documents = snapshot.data?.docs ?? [];

//         final filteredProducts = documents.where((document) {
//           final data = document.data();

//           final name = (data['name'] ?? '').toString().toLowerCase();
//           final category =
//               (data['category'] ?? '').toString().toLowerCase();
//           final fandomId =
//               (data['fandomId'] ?? '').toString().toLowerCase();

//           if (_searchQuery.isEmpty) {
//             return true;
//           }

//           return name.contains(_searchQuery) ||
//               category.contains(_searchQuery) ||
//               fandomId.contains(_searchQuery);
//         }).toList();

//         if (documents.isEmpty) {
//           return _buildEmptyState(
//             icon: Icons.inventory_2_outlined,
//             title: 'No products yet',
//             message: 'Start by adding your first product.',
//             showAddButton: true,
//           );
//         }

//         if (filteredProducts.isEmpty) {
//           return _buildEmptyState(
//             icon: Icons.search_off_rounded,
//             title: 'No products found',
//             message: 'Try searching with a different keyword.',
//             showAddButton: false,
//           );
//         }

//         final crossAxisCount = screenWidth >= 1100
//             ? 3
//             : screenWidth >= 700
//                 ? 2
//                 : 1;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'All Products',
//                   style: TextStyle(
//                     color: _whiteColor,
//                     fontSize: 17,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(width: 9),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 9,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _primaryColor.withValues(alpha: 0.13),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     '${filteredProducts.length}',
//                     style: const TextStyle(
//                       color: _primaryLightColor,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 14),
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: filteredProducts.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: crossAxisCount,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: crossAxisCount == 1 ? 2.7 : 0.88,
//               ),
//               itemBuilder: (context, index) {
//                 final document = filteredProducts[index];

//                 return _buildProductCard(
//                   document.id,
//                   document.data(),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildProductCard(
//     String productId,
//     Map<String, dynamic> data,
//   ) {
//     final String name = (data['name'] ?? 'Unnamed Product').toString();
//     final String category = (data['category'] ?? 'Uncategorized').toString();
//     final String fandomId = (data['fandomId'] ?? '').toString();

//     final bool isAvailable = data['isAvailable'] == true;

//     final int stock = _getStock(data['stock']);

//     final String currency = (data['currency'] ?? 'PKR').toString();

//     final double price = _getPrice(data['price']);

//     final String imageUrl = (data['imageUrl'] ?? '').toString();

//     return Container(
//       decoration: BoxDecoration(
//         color: _panelColor,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: _borderColor,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.15),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 6,
//             child: _buildProductImage(imageUrl),
//           ),
//           Expanded(
//             flex: 7,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 15,
//                 13,
//                 15,
//                 13,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           name,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: _whiteColor,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                       ),
//                       _buildMoreButton(
//                         productId,
//                         name,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     category,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: _primaryLightColor,
//                       fontSize: 11.5,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   if (fandomId.isNotEmpty) ...[
//                     const SizedBox(height: 5),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.auto_awesome_rounded,
//                           color: _goldColor,
//                           size: 13,
//                         ),
//                         const SizedBox(width: 5),
//                         Expanded(
//                           child: Text(
//                             fandomId,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               color: _mutedColor,
//                               fontSize: 10.5,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                   const Spacer(),
//                   Row(
//                     children: [
//                       Text(
//                         '$currency ${price.toStringAsFixed(2)}',
//                         style: const TextStyle(
//                           color: _goldColor,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       const Spacer(),
//                       _buildAvailabilityBadge(isAvailable),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.inventory_2_outlined,
//                         color: _mutedColor,
//                         size: 15,
//                       ),
//                       const SizedBox(width: 5),
//                       Text(
//                         'Stock: $stock',
//                         style: const TextStyle(
//                           color: _mutedColor,
//                           fontSize: 11.5,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductImage(String imageUrl) {
//     if (imageUrl.isEmpty) {
//       return Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: _backgroundColor,
//           borderRadius: const BorderRadius.vertical(
//             top: Radius.circular(20),
//           ),
//         ),
//         child: const Center(
//           child: Icon(
//             Icons.image_not_supported_outlined,
//             color: _mutedColor,
//             size: 42,
//           ),
//         ),
//       );
//     }

//     return ClipRRect(
//       borderRadius: const BorderRadius.vertical(
//         top: Radius.circular(20),
//       ),
//       child: Image.network(
//         imageUrl,
//         width: double.infinity,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) {
//           return Container(
//             color: _backgroundColor,
//             child: const Center(
//               child: Icon(
//                 Icons.broken_image_outlined,
//                 color: _mutedColor,
//                 size: 42,
//               ),
//             ),
//           );
//         },
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) {
//             return child;
//           }

//           return Container(
//             color: _backgroundColor,
//             child: const Center(
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color: _primaryLightColor,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAvailabilityBadge(bool isAvailable) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 8,
//         vertical: 5,
//       ),
//       decoration: BoxDecoration(
//         color: isAvailable
//             ? Colors.greenAccent.withValues(alpha: 0.08)
//             : Colors.redAccent.withValues(alpha: 0.08),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             isAvailable
//                 ? Icons.check_circle_rounded
//                 : Icons.cancel_rounded,
//             color: isAvailable
//                 ? Colors.greenAccent
//                 : Colors.redAccent,
//             size: 12,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             isAvailable ? 'Available' : 'Unavailable',
//             style: TextStyle(
//               color: isAvailable
//                   ? Colors.greenAccent
//                   : Colors.redAccent,
//               fontSize: 9.5,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMoreButton(
//     String productId,
//     String productName,
//   ) {
//     return PopupMenuButton<String>(
//       tooltip: 'Product actions',
//       color: _panelColor,
//       icon: const Icon(
//         Icons.more_vert_rounded,
//         color: _mutedColor,
//         size: 20,
//       ),
//       onSelected: (value) {
//         if (value == 'delete') {
//           _confirmDelete(
//             productId,
//             productName,
//           );
//         }
//       },
//       itemBuilder: (context) {
//         return [
//           const PopupMenuItem<String>(
//             value: 'delete',
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.delete_outline_rounded,
//                   color: Colors.redAccent,
//                   size: 19,
//                 ),
//                 SizedBox(width: 10),
//                 Text(
//                   'Delete Product',
//                   style: TextStyle(
//                     color: Colors.redAccent,
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ];
//       },
//     );
//   }

//   Widget _buildLoadingState() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(
//         vertical: 70,
//       ),
//       child: const Column(
//         children: [
//           CircularProgressIndicator(
//             color: _primaryLightColor,
//           ),
//           SizedBox(height: 16),
//           Text(
//             'Loading products...',
//             style: TextStyle(
//               color: _mutedColor,
//               fontSize: 13,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(String error) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(30),
//       decoration: BoxDecoration(
//         color: _panelColor,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: Colors.redAccent.withValues(alpha: 0.25),
//         ),
//       ),
//       child: Column(
//         children: [
//           const Icon(
//             Icons.error_outline_rounded,
//             color: Colors.redAccent,
//             size: 45,
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'Could not load products',
//             style: TextStyle(
//               color: _whiteColor,
//               fontSize: 16,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             error,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: _mutedColor,
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState({
//     required IconData icon,
//     required String title,
//     required String message,
//     required bool showAddButton,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(
//         horizontal: 25,
//         vertical: 60,
//       ),
//       decoration: BoxDecoration(
//         color: _panelColor,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: _borderColor,
//         ),
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 70,
//             height: 70,
//             decoration: BoxDecoration(
//               color: _primaryColor.withValues(alpha: 0.10),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               color: _primaryLightColor,
//               size: 34,
//             ),
//           ),
//           const SizedBox(height: 18),
//           Text(
//             title,
//             style: const TextStyle(
//               color: _whiteColor,
//               fontSize: 17,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 7),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: _mutedColor,
//               fontSize: 12.5,
//             ),
//           ),
//           if (showAddButton) ...[
//             const SizedBox(height: 20),
//             _buildAddButton(),
//           ],
//         ],
//       ),
//     );
//   }

//   int _getStock(dynamic value) {
//     if (value is int) {
//       return value;
//     }

//     if (value is num) {
//       return value.toInt();
//     }

//     return int.tryParse(value?.toString() ?? '') ?? 0;
//   }

//   double _getPrice(dynamic value) {
//     if (value is double) {
//       return value;
//     }

//     if (value is num) {
//       return value.toDouble();
//     }

//     return double.tryParse(value?.toString() ?? '') ?? 0;
//   }

//   void _openAddProduct() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const AddProductScreen(),
//       ),
//     );
//   }

//   Future<void> _confirmDelete(
//     String productId,
//     String productName,
//   ) async {
//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: _panelColor,
//           title: const Text(
//             'Delete Product?',
//             style: TextStyle(
//               color: _whiteColor,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete "$productName"? This action cannot be undone.',
//             style: const TextStyle(
//               color: _mutedColor,
//               height: 1.4,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext, false);
//               },
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: _mutedColor,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext, true);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != true) {
//       return;
//     }

//     try {
//       await FirebaseFirestore.instance
//           .collection('products')
//           .doc(productId)
//           .delete();

//       if (!mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Product deleted successfully.'),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (error) {
//       if (!mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to delete product: $error'),
//           backgroundColor: Colors.redAccent,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
// }

// class _BackgroundGlow extends StatelessWidget {
//   const _BackgroundGlow();

//   @override
//   Widget build(BuildContext context) {
//     return IgnorePointer(
//       child: Stack(
//         children: [
//           Positioned(
//             top: -100,
//             right: -80,
//             child: Container(
//               width: 260,
//               height: 260,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: const Color(0xFF7C5CFC).withValues(alpha: 0.06),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 30,
//             left: -120,
//             child: Container(
//               width: 280,
//               height: 280,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: const Color(0xFFE0B45A).withValues(alpha: 0.03),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }






// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fandom_verse/screens/admin/add_prd_form.dart';
// import 'package:fandom_verse/screens/admin/admin_drawer.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';


// class ProductManagementScreen extends StatefulWidget {
//   const ProductManagementScreen({super.key});

//   @override
//   State<ProductManagementScreen> createState() =>
//       _ProductManagementScreenState();
// }

// class _ProductManagementScreenState extends State<ProductManagementScreen> {
//   final TextEditingController _searchController = TextEditingController();

//   static const Color _backgroundColor = Color(0xFF080A12);
//   static const Color _panelColor = Color(0xFF111522);
//   static const Color _panelLightColor = Color(0xFF171B2B);
//   static const Color _primaryColor = Color(0xFF7C5CFC);
//   static const Color _primaryLightColor = Color(0xFF9D87FF);
//   static const Color _goldColor = Color(0xFFE0B45A);
//   static const Color _whiteColor = Color(0xFFF5F5F7);
//   static const Color _mutedColor = Color(0xFF9CA3B5);
//   static const Color _borderColor = Color(0xFF272D40);

//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();

//     _searchController.addListener(_onSearchChanged);
//   }

//   void _onSearchChanged() {
//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _searchQuery = _searchController.text.trim().toLowerCase();
//     });
//   }

//   @override
//   void dispose() {
//     _searchController
//       ..removeListener(_onSearchChanged)
//       ..dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _backgroundColor,
//       appBar: AppBar(
//         backgroundColor: _backgroundColor,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//         leading: IconButton(
//           tooltip: 'Back',
//           icon: const Icon(
//             Icons.arrow_back_rounded,
//             color: _whiteColor,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           'Manage Products',
//           style: TextStyle(
//             color: _whiteColor,
//             fontSize: 19,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//       ),
//       drawer: AdminDrawer(),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             const _BackgroundGlow(),
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 final double horizontalPadding =
//                     constraints.maxWidth < 600 ? 14 : 28;

//                 return SingleChildScrollView(
//                   padding: EdgeInsets.fromLTRB(
//                     horizontalPadding,
//                     16,
//                     horizontalPadding,
//                     30,
//                   ),
//                   child: Center(
//                     child: ConstrainedBox(
//                       constraints: const BoxConstraints(
//                         maxWidth: 1250,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildTopSection(constraints.maxWidth),
//                           const SizedBox(height: 16),
//                           _buildSearchBar(),
//                           const SizedBox(height: 18),
//                           _buildProducts(
//                             constraints.maxWidth,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTopSection(double width) {
//     final bool verySmall = width < 360;

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Products',
//                 style: TextStyle(
//                   color: _whiteColor,
//                   fontSize: 25,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 'Manage your products and inventory.',
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: _mutedColor,
//                   fontSize: 11.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 12),
//         _buildAddButton(verySmall),
//       ],
//     );
//   }

//   Widget _buildAddButton(bool iconOnly) {
//     return SizedBox(
//       height: 42,
//       child: ElevatedButton(
//         onPressed: _openAddProduct,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _primaryColor,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           padding: EdgeInsets.symmetric(
//             horizontal: iconOnly ? 12 : 14,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: iconOnly
//             ? const Icon(
//                 Icons.add_rounded,
//                 size: 21,
//               )
//             : const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.add_rounded,
//                     size: 19,
//                   ),
//                   SizedBox(width: 5),
//                   Text(
//                     'Add Item',
//                     style: TextStyle(
//                       fontSize: 12.5,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       height: 48,
//       decoration: BoxDecoration(
//         color: _panelColor,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: _borderColor,
//         ),
//       ),
//       child: TextField(
//         controller: _searchController,
//         style: const TextStyle(
//           color: _whiteColor,
//           fontSize: 13,
//         ),
//         cursorColor: _primaryLightColor,
//         decoration: InputDecoration(
//           hintText: 'Search products...',
//           hintStyle: const TextStyle(
//             color: _mutedColor,
//             fontSize: 12,
//           ),
//           prefixIcon: const Icon(
//             Icons.search_rounded,
//             color: _primaryLightColor,
//             size: 20,
//           ),
//           suffixIcon: _searchQuery.isEmpty
//               ? null
//               : IconButton(
//                   tooltip: 'Clear',
//                   onPressed: () {
//                     _searchController.clear();
//                   },
//                   icon: const Icon(
//                     Icons.close_rounded,
//                     color: _mutedColor,
//                     size: 18,
//                   ),
//                 ),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 14,
//             vertical: 14,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProducts(double width) {
//     return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//       stream: FirebaseFirestore.instance
//           .collection('products')
//           .orderBy('createdAt', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return _buildErrorState(
//             snapshot.error.toString(),
//           );
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _buildLoadingState();
//         }

//         final documents = snapshot.data?.docs ?? [];

//         final filteredProducts = documents.where((document) {
//           final data = document.data();

//           final name = _lower(data['name']);
//           final category = _lower(data['category']);
//           final fandomId = _lower(data['fandomId']);
//           final description = _lower(data['description']);

//           if (_searchQuery.isEmpty) {
//             return true;
//           }

//           return name.contains(_searchQuery) ||
//               category.contains(_searchQuery) ||
//               fandomId.contains(_searchQuery) ||
//               description.contains(_searchQuery);
//         }).toList();

//         if (documents.isEmpty) {
//           return _buildEmptyState(
//             icon: Icons.inventory_2_outlined,
//             title: 'No products yet',
//             message: 'Add your first product to get started.',
//             showAddButton: true,
//           );
//         }

//         if (filteredProducts.isEmpty) {
//           return _buildEmptyState(
//             icon: Icons.search_off_rounded,
//             title: 'No products found',
//             message: 'Try another search term.',
//             showAddButton: false,
//           );
//         }

//         final int crossAxisCount = width >= 1000 ? 4 : 2;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'All Products',
//                   style: TextStyle(
//                     color: _whiteColor,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 3,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _primaryColor.withValues(alpha: 0.13),
//                     borderRadius: BorderRadius.circular(7),
//                   ),
//                   child: Text(
//                     '${filteredProducts.length}',
//                     style: const TextStyle(
//                       color: _primaryLightColor,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: filteredProducts.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: crossAxisCount,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 childAspectRatio: width >= 1000 ? 0.88 : 0.78,
//               ),
//               itemBuilder: (context, index) {
//                 final document = filteredProducts[index];

//                 return _buildProductCard(
//                   document.id,
//                   document.data(),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildProductCard(
//     String productId,
//     Map<String, dynamic> data,
//   ) {
//     final String name = _stringValue(
//       data['name'],
//       'Unnamed Product',
//     );

//     final String category = _stringValue(
//       data['category'],
//       'Uncategorized',
//     );

//     final String currency = _stringValue(
//       data['currency'],
//       'PKR',
//     );

//     final double price = _getPrice(data['price']);
//     final int stock = _getStock(data['stock']);
//     final bool isAvailable = data['isAvailable'] == true;

//     final List<String> imageUrls = _getImageUrls(data);

//     return Container(
//       decoration: BoxDecoration(
//         color: _panelColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: _borderColor,
//         ),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 6,
//             child: _buildImageGallery(
//               imageUrls,
//             ),
//           ),
//           Expanded(
//             flex: 6,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 11,
//                 9,
//                 11,
//                 9,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           name,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: _whiteColor,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 3),
//                       _buildActionButtons(
//                         productId,
//                         data,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     category,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: _primaryLightColor,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const Spacer(),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           '$currency ${price.toStringAsFixed(0)}',
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: _goldColor,
//                             fontSize: 12.5,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                       ),
//                       _buildAvailabilityBadge(
//                         isAvailable,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 5),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.inventory_2_outlined,
//                         color: _mutedColor,
//                         size: 13,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Stock $stock',
//                         style: const TextStyle(
//                           color: _mutedColor,
//                           fontSize: 10,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const Spacer(),
//                       if (imageUrls.isNotEmpty)
//                         Text(
//                           '${imageUrls.length} photos',
//                           style: const TextStyle(
//                             color: _mutedColor,
//                             fontSize: 9,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageGallery(List<String> imageUrls) {
//     if (imageUrls.isEmpty) {
//       return Container(
//         width: double.infinity,
//         color: _backgroundColor,
//         child: const Center(
//           child: Icon(
//             Icons.image_not_supported_outlined,
//             color: _mutedColor,
//             size: 32,
//           ),
//         ),
//       );
//     }

//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         PageView.builder(
//           itemCount: imageUrls.length,
//           itemBuilder: (context, index) {
//             return Image.network(
//               imageUrls[index],
//               fit: BoxFit.cover,
//               errorBuilder: (
//                 context,
//                 error,
//                 stackTrace,
//               ) {
//                 return Container(
//                   color: _backgroundColor,
//                   child: const Center(
//                     child: Icon(
//                       Icons.broken_image_outlined,
//                       color: _mutedColor,
//                       size: 30,
//                     ),
//                   ),
//                 );
//               },
//               loadingBuilder: (
//                 context,
//                 child,
//                 loadingProgress,
//               ) {
//                 if (loadingProgress == null) {
//                   return child;
//                 }

//                 return Container(
//                   color: _backgroundColor,
//                   child: const Center(
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: _primaryLightColor,
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//         if (imageUrls.length > 1)
//           Positioned(
//             right: 7,
//             top: 7,
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 7,
//                 vertical: 4,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.black.withValues(alpha: 0.65),
//                 borderRadius: BorderRadius.circular(7),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(
//                     Icons.photo_library_rounded,
//                     color: Colors.white,
//                     size: 11,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     '${imageUrls.length}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 9,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildActionButtons(
//     String productId,
//     Map<String, dynamic> data,
//   ) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _smallIconButton(
//           icon: Icons.edit_rounded,
//           color: _primaryLightColor,
//           tooltip: 'Edit',
//           onPressed: () {
//             _openEditProduct(
//               productId,
//               data,
//             );
//           },
//         ),
//         const SizedBox(width: 3),
//         _smallIconButton(
//           icon: Icons.delete_outline_rounded,
//           color: Colors.redAccent,
//           tooltip: 'Delete',
//           onPressed: () {
//             _confirmDelete(
//               productId,
//               _stringValue(
//                 data['name'],
//                 'this product',
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _smallIconButton({
//     required IconData icon,
//     required Color color,
//     required String tooltip,
//     required VoidCallback onPressed,
//   }) {
//     return Tooltip(
//       message: tooltip,
//       child: Material(
//         color: color.withValues(alpha: 0.08),
//         borderRadius: BorderRadius.circular(7),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(7),
//           onTap: onPressed,
//           child: Padding(
//             padding: const EdgeInsets.all(6),
//             child: Icon(
//               icon,
//               color: color,
//               size: 15,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAvailabilityBadge(bool isAvailable) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 6,
//         vertical: 3,
//       ),
//       decoration: BoxDecoration(
//         color: isAvailable
//             ? Colors.greenAccent.withValues(alpha: 0.08)
//             : Colors.redAccent.withValues(alpha: 0.08),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(
//         isAvailable ? 'Available' : 'Off',
//         style: TextStyle(
//           color: isAvailable
//               ? Colors.greenAccent
//               : Colors.redAccent,
//           fontSize: 8,
//           fontWeight: FontWeight.w800,
//         ),
//       ),
//     );
//   }

//   Future<void> _openEditProduct(
//     String productId,
//     Map<String, dynamic> data,
//   ) async {
//     final bool? updated = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return _EditProductDialog(
//           productId: productId,
//           data: data,
//         );
//       },
//     );

//     if (updated == true && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Product updated successfully.',
//           ),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   Future<void> _confirmDelete(
//     String productId,
//     String productName,
//   ) async {
//     final bool? shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: _panelColor,
//           title: const Text(
//             'Delete Product?',
//             style: TextStyle(
//               color: _whiteColor,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete "$productName"?\n\nThis action cannot be undone.',
//             style: const TextStyle(
//               color: _mutedColor,
//               height: 1.45,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                   false,
//                 );
//               },
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: _mutedColor,
//                 ),
//               ),
//             ),
//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                   true,
//                 );
//               },
//               icon: const Icon(
//                 Icons.delete_outline_rounded,
//                 size: 17,
//               ),
//               label: const Text('Delete'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != true) {
//       return;
//     }

//     try {
//       await FirebaseFirestore.instance
//           .collection('products')
//           .doc(productId)
//           .delete();

//       if (!mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Product deleted successfully.',
//           ),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (error) {
//       if (!mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Delete failed: $error',
//           ),
//           backgroundColor: Colors.redAccent,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   void _openAddProduct() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const AddProductScreen(),
//       ),
//     );
//   }

//   String _lower(dynamic value) {
//     return value?.toString().toLowerCase() ?? '';
//   }

//   String _stringValue(
//     dynamic value,
//     String fallback,
//   ) {
//     final result = value?.toString().trim() ?? '';

//     return result.isEmpty ? fallback : result;
//   }

//   int _getStock(dynamic value) {
//     if (value is int) {
//       return value;
//     }

//     if (value is num) {
//       return value.toInt();
//     }

//     return int.tryParse(
//           value?.toString() ?? '',
//         ) ??
//         0;
//   }

//   double _getPrice(dynamic value) {
//     if (value is num) {
//       return value.toDouble();
//     }

//     return double.tryParse(
//           value?.toString() ?? '',
//         ) ??
//         0;
//   }

//   List<String> _getImageUrls(
//     Map<String, dynamic> data,
//   ) {
//     final List<String> result = [];

//     final dynamic imageUrlsValue = data['imageUrls'];

//     if (imageUrlsValue is List) {
//       for (final item in imageUrlsValue) {
//         final url = item?.toString().trim() ?? '';

//         if (url.isNotEmpty && !result.contains(url)) {
//           result.add(url);
//         }
//       }
//     }

//     final String oldImageUrl =
//         data['imageUrl']?.toString().trim() ?? '';

//     if (oldImageUrl.isNotEmpty &&
//         !result.contains(oldImageUrl)) {
//       result.insert(0, oldImageUrl);
//     }

//     return result;
//   }

//   Widget _buildLoadingState() {
//     return const SizedBox(
//       width: double.infinity,
//       height: 250,
//       child: Center(
//         child: CircularProgressIndicator(
//           strokeWidth: 2,
//           color: _primaryLightColor,
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorState(String error) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(25),
//       decoration: BoxDecoration(
//         color: _panelColor,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(
//           color: Colors.redAccent.withValues(alpha: 0.25),
//         ),
//       ),
//       child: Column(
//         children: [
//           const Icon(
//             Icons.error_outline_rounded,
//             color: Colors.redAccent,
//             size: 40,
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'Could not load products',
//             style: TextStyle(
//               color: _whiteColor,
//               fontSize: 15,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 7),
//           Text(
//             error,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: _mutedColor,
//               fontSize: 10,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState({
//     required IconData icon,
//     required String title,
//     required String message,
//     required bool showAddButton,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(
//         horizontal: 20,
//         vertical: 55,
//       ),
//       decoration: BoxDecoration(
//         color: _panelColor,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: _borderColor,
//         ),
//       ),
//       child: Column(
//         children: [
//           Icon(
//             icon,
//             color: _primaryLightColor,
//             size: 42,
//           ),
//           const SizedBox(height: 14),
//           Text(
//             title,
//             style: const TextStyle(
//               color: _whiteColor,
//               fontSize: 16,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: _mutedColor,
//               fontSize: 12,
//             ),
//           ),
//           if (showAddButton) ...[
//             const SizedBox(height: 18),
//             _buildAddButton(false),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class _EditProductDialog extends StatefulWidget {
//   final String productId;
//   final Map<String, dynamic> data;

//   const _EditProductDialog({
//     required this.productId,
//     required this.data,
//   });

//   @override
//   State<_EditProductDialog> createState() =>
//       _EditProductDialogState();
// }

// class _EditProductDialogState extends State<_EditProductDialog> {
//   static const Color _backgroundColor = Color(0xFF080A12);
//   static const Color _panelColor = Color(0xFF111522);
//   static const Color _primaryColor = Color(0xFF7C5CFC);
//   static const Color _primaryLightColor = Color(0xFF9D87FF);
//   static const Color _goldColor = Color(0xFFE0B45A);
//   static const Color _whiteColor = Color(0xFFF5F5F7);
//   static const Color _mutedColor = Color(0xFF9CA3B5);
//   static const Color _borderColor = Color(0xFF272D40);

//   final GlobalKey<FormState> _formKey =
//       GlobalKey<FormState>();

//   late final TextEditingController _nameController;
//   late final TextEditingController _descriptionController;
//   late final TextEditingController _priceController;
//   late final TextEditingController _currencyController;
//   late final TextEditingController _categoryController;
//   late final TextEditingController _fandomIdController;
//   late final TextEditingController _stockController;

//   final ImagePicker _imagePicker = ImagePicker();

//   List<String> _existingImageUrls = [];
//   final List<XFile> _newImages = [];

//   bool _isAvailable = true;
//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();

//     _nameController = TextEditingController(
//       text: _stringValue(widget.data['name']),
//     );

//     _descriptionController = TextEditingController(
//       text: _stringValue(widget.data['description']),
//     );

//     _priceController = TextEditingController(
//       text: _numberString(widget.data['price']),
//     );

//     _currencyController = TextEditingController(
//       text: _stringValue(
//         widget.data['currency'],
//         fallback: 'PKR',
//       ),
//     );

//     _categoryController = TextEditingController(
//       text: _stringValue(widget.data['category']),
//     );

//     _fandomIdController = TextEditingController(
//       text: _stringValue(widget.data['fandomId']),
//     );

//     _stockController = TextEditingController(
//       text: _numberString(widget.data['stock']),
//     );

//     _isAvailable = widget.data['isAvailable'] == true;

//     _existingImageUrls = _getImageUrls(
//       widget.data,
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _priceController.dispose();
//     _currencyController.dispose();
//     _categoryController.dispose();
//     _fandomIdController.dispose();
//     _stockController.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: const EdgeInsets.symmetric(
//         horizontal: 14,
//         vertical: 20,
//       ),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final bool isSmall =
//               constraints.maxWidth < 600;

//           return Container(
//             width: 760,
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.92,
//             ),
//             decoration: BoxDecoration(
//               color: _panelColor,
//               borderRadius: BorderRadius.circular(22),
//               border: Border.all(
//                 color: _borderColor,
//               ),
//             ),
//             child: Column(
//               children: [
//                 _buildDialogHeader(),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: EdgeInsets.all(
//                       isSmall ? 16 : 24,
//                     ),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                         children: [
//                           _buildSectionTitle(
//                             'Product Information',
//                           ),
//                           const SizedBox(height: 12),
//                           _buildResponsiveFields(
//                             isSmall,
//                           ),
//                           const SizedBox(height: 22),
//                           _buildSectionTitle(
//                             'Product Images',
//                           ),
//                           const SizedBox(height: 5),
//                           const Text(
//                             'Existing images are shown below. Remove old images or add new ones.',
//                             style: TextStyle(
//                               color: _mutedColor,
//                               fontSize: 11,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           _buildImagesGrid(
//                             isSmall,
//                           ),
//                           const SizedBox(height: 12),
//                           _buildAddImagesButton(),
//                           const SizedBox(height: 20),
//                           _buildAvailability(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 _buildDialogActions(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDialogHeader() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(
//         20,
//         18,
//         14,
//         18,
//       ),
//       decoration: BoxDecoration(
//         color: _backgroundColor.withValues(alpha: 0.35),
//         border: const Border(
//           bottom: BorderSide(
//             color: _borderColor,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//               color: _primaryColor.withValues(alpha: 0.13),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(
//               Icons.edit_rounded,
//               color: _primaryLightColor,
//               size: 21,
//             ),
//           ),
//           const SizedBox(width: 12),
//           const Expanded(
//             child: Text(
//               'Edit Product',
//               style: TextStyle(
//                 color: _whiteColor,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//           IconButton(
//             tooltip: 'Close',
//             onPressed: _isSaving
//                 ? null
//                 : () {
//                     Navigator.pop(context);
//                   },
//             icon: const Icon(
//               Icons.close_rounded,
//               color: _mutedColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         color: _whiteColor,
//         fontSize: 14,
//         fontWeight: FontWeight.w800,
//       ),
//     );
//   }

//   Widget _buildResponsiveFields(bool isSmall) {
//     if (isSmall) {
//       return Column(
//         children: [
//           _buildTextField(
//             controller: _nameController,
//             label: 'Product Name',
//             icon: Icons.shopping_bag_outlined,
//             validator: (value) {
//               if (value == null ||
//                   value.trim().isEmpty) {
//                 return 'Enter product name';
//               }

//               return null;
//             },
//           ),
//           const SizedBox(height: 12),
//           _buildTextField(
//             controller: _descriptionController,
//             label: 'Description',
//             icon: Icons.description_outlined,
//             maxLines: 3,
//           ),
//           const SizedBox(height: 12),
//           _buildTextField(
//             controller: _categoryController,
//             label: 'Category',
//             icon: Icons.category_outlined,
//             validator: (value) {
//               if (value == null ||
//                   value.trim().isEmpty) {
//                 return 'Enter category';
//               }

//               return null;
//             },
//           ),
//           const SizedBox(height: 12),
//           _buildTextField(
//             controller: _fandomIdController,
//             label: 'Fandom ID',
//             icon: Icons.auto_awesome_outlined,
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildTextField(
//                   controller: _priceController,
//                   label: 'Price',
//                   icon: Icons.payments_outlined,
//                   keyboardType:
//                       const TextInputType.numberWithOptions(
//                     decimal: true,
//                   ),
//                   validator: (value) {
//                     if (value == null ||
//                         value.trim().isEmpty) {
//                       return 'Required';
//                     }

//                     if (double.tryParse(
//                           value.trim(),
//                         ) ==
//                         null) {
//                       return 'Invalid';
//                     }

//                     return null;
//                   },
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _buildTextField(
//                   controller: _currencyController,
//                   label: 'Currency',
//                   icon: Icons.currency_exchange_rounded,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           _buildTextField(
//             controller: _stockController,
//             label: 'Stock',
//             icon: Icons.inventory_2_outlined,
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value == null ||
//                   value.trim().isEmpty) {
//                 return 'Required';
//               }

//               if (int.tryParse(
//                     value.trim(),
//                   ) ==
//                   null) {
//                 return 'Invalid';
//               }

//               return null;
//             },
//           ),
//         ],
//       );
//     }

//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 controller: _nameController,
//                 label: 'Product Name',
//                 icon: Icons.shopping_bag_outlined,
//                 validator: (value) {
//                   if (value == null ||
//                       value.trim().isEmpty) {
//                     return 'Enter product name';
//                   }

//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildTextField(
//                 controller: _categoryController,
//                 label: 'Category',
//                 icon: Icons.category_outlined,
//                 validator: (value) {
//                   if (value == null ||
//                       value.trim().isEmpty) {
//                     return 'Enter category';
//                   }

//                   return null;
//                 },
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         _buildTextField(
//           controller: _descriptionController,
//           label: 'Description',
//           icon: Icons.description_outlined,
//           maxLines: 3,
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 controller: _fandomIdController,
//                 label: 'Fandom ID',
//                 icon: Icons.auto_awesome_outlined,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildTextField(
//                 controller: _stockController,
//                 label: 'Stock',
//                 icon: Icons.inventory_2_outlined,
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null ||
//                       value.trim().isEmpty) {
//                     return 'Required';
//                   }

//                   if (int.tryParse(
//                         value.trim(),
//                       ) ==
//                       null) {
//                     return 'Invalid';
//                   }

//                   return null;
//                 },
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 controller: _priceController,
//                 label: 'Price',
//                 icon: Icons.payments_outlined,
//                 keyboardType:
//                     const TextInputType.numberWithOptions(
//                   decimal: true,
//                 ),
//                 validator: (value) {
//                   if (value == null ||
//                       value.trim().isEmpty) {
//                     return 'Required';
//                   }

//                   if (double.tryParse(
//                         value.trim(),
//                       ) ==
//                       null) {
//                     return 'Invalid';
//                   }

//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildTextField(
//                 controller: _currencyController,
//                 label: 'Currency',
//                 icon: Icons.currency_exchange_rounded,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     String? Function(String?)? validator,
//     int maxLines = 1,
//     TextInputType? keyboardType,
//   }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboardType,
//       style: const TextStyle(
//         color: _whiteColor,
//         fontSize: 13,
//       ),
//       cursorColor: _primaryLightColor,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(
//           color: _mutedColor,
//           fontSize: 12,
//         ),
//         prefixIcon: Icon(
//           icon,
//           color: _primaryLightColor,
//           size: 19,
//         ),
//         filled: true,
//         fillColor: _backgroundColor,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 13,
//           vertical: 13,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: _borderColor,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: _borderColor,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: _primaryColor,
//           ),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: Colors.redAccent,
//           ),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: Colors.redAccent,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildImagesGrid(bool isSmall) {
//     final int totalImages =
//         _existingImageUrls.length + _newImages.length;

//     if (totalImages == 0) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(
//           vertical: 30,
//         ),
//         decoration: BoxDecoration(
//           color: _backgroundColor,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: _borderColor,
//           ),
//         ),
//         child: const Column(
//           children: [
//             Icon(
//               Icons.photo_library_outlined,
//               color: _mutedColor,
//               size: 32,
//             ),
//             SizedBox(height: 8),
//             Text(
//               'No images selected',
//               style: TextStyle(
//                 color: _mutedColor,
//                 fontSize: 11,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: totalImages,
//       gridDelegate:
//           const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 8,
//         mainAxisSpacing: 8,
//         childAspectRatio: 1,
//       ),
//       itemBuilder: (context, index) {
//         if (index < _existingImageUrls.length) {
//           return _buildExistingImage(
//             index,
//             _existingImageUrls[index],
//           );
//         }

//         final int newIndex =
//             index - _existingImageUrls.length;

//         return _buildNewImage(
//           newIndex,
//           _newImages[newIndex],
//         );
//       },
//     );
//   }

//   Widget _buildExistingImage(
//     int index,
//     String url,
//   ) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Image.network(
//             url,
//             fit: BoxFit.cover,
//             errorBuilder: (
//               context,
//               error,
//               stackTrace,
//             ) {
//               return Container(
//                 color: _backgroundColor,
//                 child: const Icon(
//                   Icons.broken_image_outlined,
//                   color: _mutedColor,
//                 ),
//               );
//             },
//           ),
//         ),
//         Positioned(
//           top: 6,
//           right: 6,
//           child: _imageRemoveButton(
//             onPressed: () {
//               setState(() {
//                 _existingImageUrls.removeAt(index);
//               });
//             },
//           ),
//         ),
//         if (index == 0)
//           Positioned(
//             left: 6,
//             bottom: 6,
//             child: _mainImageLabel(),
//           ),
//       ],
//     );
//   }

//   Widget _buildNewImage(
//     int index,
//     XFile image,
//   ) {
//     return FutureBuilder<Uint8List>(
//       future: image.readAsBytes(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Container(
//             decoration: BoxDecoration(
//               color: _backgroundColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Center(
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color: _primaryLightColor,
//               ),
//             ),
//           );
//         }

//         return Stack(
//           fit: StackFit.expand,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.memory(
//                 snapshot.data!,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             Positioned(
//               top: 6,
//               right: 6,
//               child: _imageRemoveButton(
//                 onPressed: () {
//                   setState(() {
//                     _newImages.removeAt(index);
//                   });
//                 },
//               ),
//             ),
//             Positioned(
//               left: 6,
//               bottom: 6,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 6,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: _primaryColor,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: const Text(
//                   'NEW',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 8,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _imageRemoveButton({
//     required VoidCallback onPressed,
//   }) {
//     return Material(
//       color: Colors.black.withValues(alpha: 0.70),
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onPressed,
//         child: const Padding(
//           padding: EdgeInsets.all(5),
//           child: Icon(
//             Icons.close_rounded,
//             color: Colors.white,
//             size: 15,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _mainImageLabel() {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 6,
//         vertical: 4,
//       ),
//       decoration: BoxDecoration(
//         color: _primaryColor,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: const Text(
//         'MAIN',
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 8,
//           fontWeight: FontWeight.w800,
//         ),
//       ),
//     );
//   }

//   Widget _buildAddImagesButton() {
//     return OutlinedButton.icon(
//       onPressed: _isSaving
//           ? null
//           : _pickAdditionalImages,
//       icon: const Icon(
//         Icons.add_photo_alternate_outlined,
//         size: 18,
//       ),
//       label: const Text(
//         'Add More Images',
//       ),
//       style: OutlinedButton.styleFrom(
//         foregroundColor: _primaryLightColor,
//         side: BorderSide(
//           color: _primaryColor.withValues(alpha: 0.45),
//         ),
//         padding: const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 11,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(11),
//         ),
//       ),
//     );
//   }

//   Widget _buildAvailability() {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 13,
//         vertical: 4,
//       ),
//       decoration: BoxDecoration(
//         color: _backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: _borderColor,
//         ),
//       ),
//       child: SwitchListTile(
//         contentPadding: EdgeInsets.zero,
//         value: _isAvailable,
//         onChanged: _isSaving
//             ? null
//             : (value) {
//                 setState(() {
//                   _isAvailable = value;
//                 });
//               },
//         activeColor: _primaryLightColor,
//         title: const Text(
//           'Product Available',
//           style: TextStyle(
//             color: _whiteColor,
//             fontSize: 12.5,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         subtitle: Text(
//           _isAvailable
//               ? 'Customers can purchase this product.'
//               : 'Product is currently unavailable.',
//           style: const TextStyle(
//             color: _mutedColor,
//             fontSize: 10,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDialogActions() {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: const BoxDecoration(
//         border: Border(
//           top: BorderSide(
//             color: _borderColor,
//           ),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           TextButton(
//             onPressed: _isSaving
//                 ? null
//                 : () {
//                     Navigator.pop(context);
//                   },
//             child: const Text(
//               'Cancel',
//               style: TextStyle(
//                 color: _mutedColor,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           ElevatedButton.icon(
//             onPressed: _isSaving
//                 ? null
//                 : _confirmUpdate,
//             icon: _isSaving
//                 ? const SizedBox(
//                     width: 15,
//                     height: 15,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     ),
//                   )
//                 : const Icon(
//                     Icons.save_rounded,
//                     size: 17,
//                   ),
//             label: Text(
//               _isSaving ? 'Saving...' : 'Update Product',
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _primaryColor,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 15,
//                 vertical: 12,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickAdditionalImages() async {
//     try {
//       final List<XFile> images =
//           await _imagePicker.pickMultiImage();

//       if (images.isEmpty || !mounted) {
//         return;
//       }

//       setState(() {
//         for (final image in images) {
//           final bool duplicate =
//               _newImages.any(
//             (existing) => existing.path == image.path,
//           );

//           if (!duplicate) {
//             _newImages.add(image);
//           }
//         }
//       });
//     } catch (error) {
//       if (!mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Could not select images: $error',
//           ),
//           backgroundColor: Colors.redAccent,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   Future<void> _confirmUpdate() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     final bool? confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: _panelColor,
//           title: const Text(
//             'Confirm Update',
//             style: TextStyle(
//               color: _whiteColor,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           content: const Text(
//             'Are you sure you want to update this product?',
//             style: TextStyle(
//               color: _mutedColor,
//               height: 1.4,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                   false,
//                 );
//               },
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: _mutedColor,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                   true,
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _primaryColor,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Confirm'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed != true) {
//       return;
//     }

//     await _updateProduct();
//   }

//   Future<void> _updateProduct() async {
//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       final List<String> finalImageUrls =
//           List<String>.from(
//         _existingImageUrls,
//       );

//       if (_newImages.isNotEmpty) {
//         for (int index = 0;
//             index < _newImages.length;
//             index++) {
//           final XFile image = _newImages[index];

//           final Uint8List bytes =
//               await image.readAsBytes();

//           final String extension =
//               _getExtension(image.name);

//           final String fileName =
//               '${DateTime.now().millisecondsSinceEpoch}_${index}_$extension';

//           final Reference storageRef =
//               FirebaseStorage.instance
//                   .ref()
//                   .child('products')
//                   .child(widget.productId)
//                   .child(fileName);

//           final SettableMetadata metadata =
//               SettableMetadata(
//             contentType: _contentType(extension),
//           );

//           await storageRef.putData(
//             bytes,
//             metadata,
//           );

//           final String downloadUrl =
//               await storageRef.getDownloadURL();

//           finalImageUrls.add(downloadUrl);
//         }
//       }

//       final double price =
//           double.parse(
//         _priceController.text.trim(),
//       );

//       final int stock =
//           int.parse(
//         _stockController.text.trim(),
//       );

//       final Map<String, dynamic> updateData = {
//         'name': _nameController.text.trim(),
//         'description':
//             _descriptionController.text.trim(),
//         'price': price,
//         'currency':
//             _currencyController.text.trim().isEmpty
//                 ? 'PKR'
//                 : _currencyController.text.trim(),
//         'category':
//             _categoryController.text.trim(),
//         'fandomId':
//             _fandomIdController.text.trim(),
//         'stock': stock,
//         'isAvailable': _isAvailable,
//         'imageUrls': finalImageUrls,
//         'imageUrl': finalImageUrls.isNotEmpty
//             ? finalImageUrls.first
//             : '',
//         'updatedAt': FieldValue.serverTimestamp(),
//         'updatedBy':
//             FirebaseAuth.instance.currentUser?.uid,
//       };

//       await FirebaseFirestore.instance
//           .collection('products')
//           .doc(widget.productId)
//           .update(updateData);

//       if (!mounted) {
//         return;
//       }

//       Navigator.pop(
//         context,
//         true,
//       );
//     } catch (error) {
//       if (!mounted) {
//         return;
//       }

//       setState(() {
//         _isSaving = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Update failed: $error',
//           ),
//           backgroundColor: Colors.redAccent,
//           behavior: SnackBarBehavior.floating,
//           duration: const Duration(seconds: 6),
//         ),
//       );
//     }
//   }

//   String _getExtension(String fileName) {
//     final int dotIndex =
//         fileName.lastIndexOf('.');

//     if (dotIndex == -1) {
//       return 'jpg';
//     }

//     return fileName
//         .substring(dotIndex + 1)
//         .toLowerCase();
//   }

//   String _contentType(String extension) {
//     switch (extension) {
//       case 'png':
//         return 'image/png';
//       case 'webp':
//         return 'image/webp';
//       case 'gif':
//         return 'image/gif';
//       case 'jpg':
//       case 'jpeg':
//       default:
//         return 'image/jpeg';
//     }
//   }

//   String _stringValue(
//     dynamic value, {
//     String fallback = '',
//   }) {
//     final String result =
//         value?.toString().trim() ?? '';

//     return result.isEmpty ? fallback : result;
//   }

//   String _numberString(dynamic value) {
//     if (value == null) {
//       return '';
//     }

//     if (value is num) {
//       return value.toString();
//     }

//     return value.toString();
//   }

//   List<String> _getImageUrls(
//     Map<String, dynamic> data,
//   ) {
//     final List<String> result = [];

//     final dynamic imageUrls =
//         data['imageUrls'];

//     if (imageUrls is List) {
//       for (final item in imageUrls) {
//         final String url =
//             item?.toString().trim() ?? '';

//         if (url.isNotEmpty &&
//             !result.contains(url)) {
//           result.add(url);
//         }
//       }
//     }

//     final String imageUrl =
//         data['imageUrl']?.toString().trim() ?? '';

//     if (imageUrl.isNotEmpty &&
//         !result.contains(imageUrl)) {
//       result.insert(0, imageUrl);
//     }

//     return result;
//   }
// }

// class _BackgroundGlow extends StatelessWidget {
//   const _BackgroundGlow();

//   @override
//   Widget build(BuildContext context) {
//     return IgnorePointer(
//       child: Stack(
//         children: [
//           Positioned(
//             top: -100,
//             right: -100,
//             child: Container(
//               width: 270,
//               height: 270,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: const Color(
//                   0xFF7C5CFC,
//                 ).withValues(alpha: 0.055),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -100,
//             left: -100,
//             child: Container(
//               width: 280,
//               height: 280,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: const Color(
//                   0xFFE0B45A,
//                 ).withValues(alpha: 0.025),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }





// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fandom_verse/screens/admin/add_prd_form.dart';
// import 'package:fandom_verse/screens/admin/admin_drawer.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class ProductManagementScreen extends StatefulWidget {
//   const ProductManagementScreen({super.key});

//   @override
//   State<ProductManagementScreen> createState() =>
//       _ProductManagementScreenState();
// }

// class _ProductManagementScreenState
//     extends State<ProductManagementScreen> {
//   // ============================================================
//   // THEME
//   // ============================================================

//   static const Color _backgroundColor = Color(0xFF080A12);
//   static const Color _panelColor = Color(0xFF111522);
//   static const Color _panelLightColor = Color(0xFF171B2B);
//   static const Color _primaryColor = Color(0xFF7C5CFC);
//   static const Color _primaryLightColor = Color(0xFF9D87FF);
//   static const Color _goldColor = Color(0xFFE0B45A);
//   static const Color _whiteColor = Color(0xFFF5F5F7);
//   static const Color _mutedColor = Color(0xFF9CA3B5);
//   static const Color _borderColor = Color(0xFF272D40);

//   final TextEditingController _searchController =
//       TextEditingController();

//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//   }

//   void _onSearchChanged() {
//     if (!mounted) return;

//     setState(() {
//       _searchQuery =
//           _searchController.text.trim().toLowerCase();
//     });
//   }

//   @override
//   void dispose() {
//     _searchController
//       ..removeListener(_onSearchChanged)
//       ..dispose();

//     super.dispose();
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _backgroundColor,
//       appBar: AppBar(
//         backgroundColor: _backgroundColor,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//         leading: IconButton(
//           tooltip: 'Back',
//           icon: const Icon(
//             Icons.arrow_back_rounded,
//             color: _whiteColor,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           'Manage Products',
//           style: TextStyle(
//             color: _whiteColor,
//             fontSize: 19,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//       ),
//       drawer: AdminDrawer(),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             const _BackgroundGlow(),
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 final double horizontalPadding =
//                     constraints.maxWidth < 600 ? 14 : 28;

//                 return SingleChildScrollView(
//                   padding: EdgeInsets.fromLTRB(
//                     horizontalPadding,
//                     16,
//                     horizontalPadding,
//                     30,
//                   ),
//                   child: Center(
//                     child: ConstrainedBox(
//                       constraints: const BoxConstraints(
//                         maxWidth: 1250,
//                       ),
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                         children: [
//                           _buildTopSection(
//                             constraints.maxWidth,
//                           ),
//                           const SizedBox(height: 16),
//                           _buildSearchBar(),
//                           const SizedBox(height: 18),
//                           _buildProducts(
//                             constraints.maxWidth,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // TOP SECTION
//   // ============================================================

//   Widget _buildTopSection(double width) {
//     final bool verySmall = width < 360;

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Products',
//                 style: TextStyle(
//                   color: _whiteColor,
//                   fontSize: 25,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 'Manage your products and inventory.',
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: _mutedColor,
//                   fontSize: 11.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 12),
//         _buildAddButton(verySmall),
//       ],
//     );
//   }

//   Widget _buildAddButton(bool iconOnly) {
//     return SizedBox(
//       height: 42,
//       child: ElevatedButton(
//         onPressed: _openAddProduct,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _primaryColor,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           padding: EdgeInsets.symmetric(
//             horizontal: iconOnly ? 12 : 14,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: iconOnly
//             ? const Icon(
//                 Icons.add_rounded,
//                 size: 21,
//               )
//             : const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.add_rounded,
//                     size: 19,
//                   ),
//                   SizedBox(width: 5),
//                   Text(
//                     'Add Item',
//                     style: TextStyle(
//                       fontSize: 12.5,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   // ============================================================
//   // SEARCH
//   // ============================================================

//   Widget _buildSearchBar() {
//     return Container(
//       height: 48,
//       decoration: BoxDecoration(
//         color: _panelColor,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: _borderColor,
//         ),
//       ),
//       child: TextField(
//         controller: _searchController,
//         style: const TextStyle(
//           color: _whiteColor,
//           fontSize: 13,
//         ),
//         cursorColor: _primaryLightColor,
//         decoration: InputDecoration(
//           hintText: 'Search products...',
//           hintStyle: const TextStyle(
//             color: _mutedColor,
//             fontSize: 12,
//           ),
//           prefixIcon: const Icon(
//             Icons.search_rounded,
//             color: _primaryLightColor,
//             size: 20,
//           ),
//           suffixIcon: _searchQuery.isEmpty
//               ? null
//               : IconButton(
//                   tooltip: 'Clear',
//                   onPressed: () {
//                     _searchController.clear();
//                   },
//                   icon: const Icon(
//                     Icons.close_rounded,
//                     color: _mutedColor,
//                     size: 18,
//                   ),
//                 ),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 14,
//             vertical: 14,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PRODUCTS STREAM
//   // ============================================================

//   Widget _buildProducts(double width) {
//     return StreamBuilder<
//         QuerySnapshot<Map<String, dynamic>>>(
//       stream: FirebaseFirestore.instance
//           .collection('products')
//           .orderBy(
//             'createdAt',
//             descending: true,
//           )
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return _buildErrorState(
//             snapshot.error.toString(),
//           );
//         }

//         if (snapshot.connectionState ==
//             ConnectionState.waiting) {
//           return _buildLoadingState();
//         }

//         final documents =
//             snapshot.data?.docs ?? [];

//         final filteredProducts =
//             documents.where((document) {
//           final data = document.data();

//           final String name =
//               _lower(data['name']);
//           final String category =
//               _lower(data['category']);
//           final String fandomId =
//               _lower(data['fandomId']);
//           final String description =
//               _lower(data['description']);

//           if (_searchQuery.isEmpty) {
//             return true;
//           }

//           return name.contains(_searchQuery) ||
//               category.contains(_searchQuery) ||
//               fandomId.contains(_searchQuery) ||
//               description.contains(_searchQuery);
//         }).toList();

//         if (documents.isEmpty) {
//           return _buildEmptyState(
//             icon: Icons.inventory_2_outlined,
//             title: 'No products yet',
//             message:
//                 'Add your first product to get started.',
//             showAddButton: true,
//           );
//         }

//         if (filteredProducts.isEmpty) {
//           return _buildEmptyState(
//             icon: Icons.search_off_rounded,
//             title: 'No products found',
//             message: 'Try another search term.',
//             showAddButton: false,
//           );
//         }

//         final int crossAxisCount =
//             width >= 1200
//                 ? 4
//                 : width >= 700
//                     ? 3
//                     : 2;

//         final double aspectRatio =
//             width >= 1200
//                 ? 0.88
//                 : width >= 700
//                     ? 0.78
//                     : 0.72;

//         return Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'All Products',
//                   style: TextStyle(
//                     color: _whiteColor,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 3,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _primaryColor.withValues(
//                       alpha: 0.13,
//                     ),
//                     borderRadius:
//                         BorderRadius.circular(7),
//                   ),
//                   child: Text(
//                     '${filteredProducts.length}',
//                     style: const TextStyle(
//                       color: _primaryLightColor,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             GridView.builder(
//               shrinkWrap: true,
//               physics:
//                   const NeverScrollableScrollPhysics(),
//               itemCount: filteredProducts.length,
//               gridDelegate:
//                   SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount:
//                     crossAxisCount,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 childAspectRatio: aspectRatio,
//               ),
//               itemBuilder:
//                   (context, index) {
//                 final document =
//                     filteredProducts[index];

//                 return _buildProductCard(
//                   document.id,
//                   document.data(),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // PRODUCT CARD
//   // ============================================================

//   Widget _buildProductCard(
//     String productId,
//     Map<String, dynamic> data,
//   ) {
//     final String name = _stringValue(
//       data['name'],
//       'Unnamed Product',
//     );

//     final String category = _stringValue(
//       data['category'],
//       'Uncategorized',
//     );

//     final String currency = _stringValue(
//       data['currency'],
//       'PKR',
//     );

//     final double price =
//         _getPrice(data['price']);

//     final int stock =
//         _getStock(data['stock']);

//     final bool isAvailable =
//         data['isAvailable'] == true;

//     final List<String> imageUrls =
//         _getImageUrls(data);

//     return Container(
//       decoration: BoxDecoration(
//         color: _panelColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: _borderColor,
//         ),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 6,
//             child: _buildImageGallery(
//               imageUrls,
//             ),
//           ),
//           Expanded(
//             flex: 6,
//             child: Padding(
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 11,
//                 9,
//                 11,
//                 9,
//               ),
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           name,
//                           maxLines: 2,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style:
//                               const TextStyle(
//                             color: _whiteColor,
//                             fontSize: 13,
//                             fontWeight:
//                                 FontWeight.w800,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 3),
//                       _buildActionButtons(
//                         productId,
//                         data,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     category,
//                     maxLines: 1,
//                     overflow:
//                         TextOverflow.ellipsis,
//                     style:
//                         const TextStyle(
//                       color:
//                           _primaryLightColor,
//                       fontSize: 10,
//                       fontWeight:
//                           FontWeight.w600,
//                     ),
//                   ),
//                   const Spacer(),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           '$currency ${price.toStringAsFixed(0)}',
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style:
//                               const TextStyle(
//                             color: _goldColor,
//                             fontSize: 12.5,
//                             fontWeight:
//                                 FontWeight.w800,
//                           ),
//                         ),
//                       ),
//                       _buildAvailabilityBadge(
//                         isAvailable,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 5),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.inventory_2_outlined,
//                         color: _mutedColor,
//                         size: 13,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Stock $stock',
//                         style:
//                             const TextStyle(
//                           color: _mutedColor,
//                           fontSize: 10,
//                           fontWeight:
//                               FontWeight.w600,
//                         ),
//                       ),
//                       const Spacer(),
//                       if (imageUrls.isNotEmpty)
//                         Text(
//                           '${imageUrls.length} photos',
//                           style:
//                               const TextStyle(
//                             color: _mutedColor,
//                             fontSize: 9,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // IMAGE GALLERY
//   // ============================================================

//   Widget _buildImageGallery(
//     List<String> imageUrls,
//   ) {
//     if (imageUrls.isEmpty) {
//       return Container(
//         width: double.infinity,
//         color: _backgroundColor,
//         child: const Center(
//           child: Icon(
//             Icons.image_not_supported_outlined,
//             color: _mutedColor,
//             size: 32,
//           ),
//         ),
//       );
//     }

//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         PageView.builder(
//           itemCount: imageUrls.length,
//           itemBuilder:
//               (context, index) {
//             return Image.network(
//               imageUrls[index],
//               fit: BoxFit.cover,
//               gaplessPlayback: true,
//               errorBuilder:
//                   (context, error, stackTrace) {
//                 return Container(
//                   color: _backgroundColor,
//                   child: const Center(
//                     child: Icon(
//                       Icons.broken_image_outlined,
//                       color: _mutedColor,
//                       size: 30,
//                     ),
//                   ),
//                 );
//               },
//               loadingBuilder: (
//                 context,
//                 child,
//                 loadingProgress,
//               ) {
//                 if (loadingProgress == null) {
//                   return child;
//                 }

//                 return Container(
//                   color: _backgroundColor,
//                   child: const Center(
//                     child:
//                         CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color:
//                           _primaryLightColor,
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//         if (imageUrls.length > 1)
//           Positioned(
//             right: 7,
//             top: 7,
//             child: Container(
//               padding:
//                   const EdgeInsets.symmetric(
//                 horizontal: 7,
//                 vertical: 4,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.black
//                     .withValues(alpha: 0.65),
//                 borderRadius:
//                     BorderRadius.circular(7),
//               ),
//               child: Row(
//                 mainAxisSize:
//                     MainAxisSize.min,
//                 children: [
//                   const Icon(
//                     Icons.photo_library_rounded,
//                     color: Colors.white,
//                     size: 11,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     '${imageUrls.length}',
//                     style:
//                         const TextStyle(
//                       color: Colors.white,
//                       fontSize: 9,
//                       fontWeight:
//                           FontWeight.w700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   // ============================================================
//   // ACTION BUTTONS
//   // ============================================================

//   Widget _buildActionButtons(
//     String productId,
//     Map<String, dynamic> data,
//   ) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _smallIconButton(
//           icon: Icons.edit_rounded,
//           color: _primaryLightColor,
//           tooltip: 'Edit',
//           onPressed: () {
//             _openEditProduct(
//               productId,
//               data,
//             );
//           },
//         ),
//         const SizedBox(width: 3),
//         _smallIconButton(
//           icon: Icons.delete_outline_rounded,
//           color: Colors.redAccent,
//           tooltip: 'Delete',
//           onPressed: () {
//             _confirmDelete(
//               productId,
//               _stringValue(
//                 data['name'],
//                 'this product',
//               ),
//               _getImageUrls(data),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _smallIconButton({
//     required IconData icon,
//     required Color color,
//     required String tooltip,
//     required VoidCallback onPressed,
//   }) {
//     return Tooltip(
//       message: tooltip,
//       child: Material(
//         color: color.withValues(alpha: 0.08),
//         borderRadius:
//             BorderRadius.circular(7),
//         child: InkWell(
//           borderRadius:
//               BorderRadius.circular(7),
//           onTap: onPressed,
//           child: Padding(
//             padding:
//                 const EdgeInsets.all(6),
//             child: Icon(
//               icon,
//               color: color,
//               size: 15,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAvailabilityBadge(
//     bool isAvailable,
//   ) {
//     return Container(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 6,
//         vertical: 3,
//       ),
//       decoration: BoxDecoration(
//         color: isAvailable
//             ? Colors.greenAccent
//                 .withValues(alpha: 0.08)
//             : Colors.redAccent
//                 .withValues(alpha: 0.08),
//         borderRadius:
//             BorderRadius.circular(6),
//       ),
//       child: Text(
//         isAvailable
//             ? 'Available'
//             : 'Off',
//         style: TextStyle(
//           color: isAvailable
//               ? Colors.greenAccent
//               : Colors.redAccent,
//           fontSize: 8,
//           fontWeight:
//               FontWeight.w800,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EDIT
//   // ============================================================

//   Future<void> _openEditProduct(
//     String productId,
//     Map<String, dynamic> data,
//   ) async {
//     final bool? updated =
//         await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return _EditProductDialog(
//           productId: productId,
//           data: data,
//         );
//       },
//     );

//     if (updated == true && mounted) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Product updated successfully.',
//           ),
//           backgroundColor: Colors.green,
//           behavior:
//               SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   // ============================================================
//   // DELETE
//   // ============================================================

//   Future<void> _confirmDelete(
//     String productId,
//     String productName,
//     List<String> imageUrls,
//   ) async {
//     final bool? shouldDelete =
//         await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: _panelColor,
//           title: const Text(
//             'Delete Product?',
//             style: TextStyle(
//               color: _whiteColor,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete "$productName"?\n\nThe product and its stored images will be removed.',
//             style: const TextStyle(
//               color: _mutedColor,
//               height: 1.45,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                   false,
//                 );
//               },
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: _mutedColor,
//                 ),
//               ),
//             ),
//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                   true,
//                 );
//               },
//               icon: const Icon(
//                 Icons.delete_outline_rounded,
//                 size: 17,
//               ),
//               label:
//                   const Text('Delete'),
//               style:
//                   ElevatedButton.styleFrom(
//                 backgroundColor:
//                     Colors.redAccent,
//                 foregroundColor:
//                     Colors.white,
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != true) {
//       return;
//     }

//     _showLoadingDialog(
//       title: 'Deleting product',
//       message:
//           'Removing product data...',
//     );

//     try {
//       // First remove Firestore document.
//       await FirebaseFirestore.instance
//           .collection('products')
//           .doc(productId)
//           .delete();

//       // Then remove images from Storage.
//       await _deleteStorageImages(
//         imageUrls,
//       );

//       if (!mounted) return;

//       Navigator.of(context).pop();

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Product deleted successfully.',
//           ),
//           backgroundColor: Colors.green,
//           behavior:
//               SnackBarBehavior.floating,
//         ),
//       );
//     } catch (error) {
//       if (!mounted) return;

//       Navigator.of(context).pop();

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Delete failed: $error',
//           ),
//           backgroundColor:
//               Colors.redAccent,
//           behavior:
//               SnackBarBehavior.floating,
//           duration:
//               const Duration(seconds: 6),
//         ),
//       );
//     }
//   }

//   Future<void> _deleteStorageImages(
//     List<String> urls,
//   ) async {
//     for (final String url in urls) {
//       if (url.trim().isEmpty) continue;

//       try {
//         final Reference ref =
//             FirebaseStorage.instance
//                 .refFromURL(url);

//         await ref.delete();
//       } catch (_) {
//         // Image may already be deleted.
//         // Do not make the whole operation fail.
//       }
//     }
//   }

//   // ============================================================
//   // ADD
//   // ============================================================

//   void _openAddProduct() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             const AddProductScreen(),
//       ),
//     );
//   }

//   // ============================================================
//   // HELPERS
//   // ============================================================

//   String _lower(dynamic value) {
//     return value
//             ?.toString()
//             .toLowerCase() ??
//         '';
//   }

//   String _stringValue(
//     dynamic value,
//     String fallback,
//   ) {
//     final result =
//         value?.toString().trim() ?? '';

//     return result.isEmpty
//         ? fallback
//         : result;
//   }

//   int _getStock(dynamic value) {
//     if (value is int) {
//       return value;
//     }

//     if (value is num) {
//       return value.toInt();
//     }

//     return int.tryParse(
//           value?.toString() ?? '',
//         ) ??
//         0;
//   }

//   double _getPrice(dynamic value) {
//     if (value is num) {
//       return value.toDouble();
//     }

//     return double.tryParse(
//           value?.toString() ?? '',
//         ) ??
//         0;
//   }

//   List<String> _getImageUrls(
//     Map<String, dynamic> data,
//   ) {
//     final List<String> result = [];

//     final dynamic imageUrlsValue =
//         data['imageUrls'];

//     if (imageUrlsValue is List) {
//       for (final item in imageUrlsValue) {
//         final String url =
//             item?.toString().trim() ?? '';

//         if (url.isNotEmpty &&
//             !result.contains(url)) {
//           result.add(url);
//         }
//       }
//     }

//     final String oldImageUrl =
//         data['imageUrl']
//                 ?.toString()
//                 .trim() ??
//             '';

//     if (oldImageUrl.isNotEmpty &&
//         !result.contains(oldImageUrl)) {
//       result.insert(0, oldImageUrl);
//     }

//     return result;
//   }

//   // ============================================================
//   // LOADING DIALOG
//   // ============================================================

//   void _showLoadingDialog({
//     required String title,
//     required String message,
//   }) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) {
//         return AlertDialog(
//           backgroundColor: _panelColor,
//           content: Row(
//             children: [
//               const SizedBox(
//                 width: 25,
//                 height: 25,
//                 child:
//                     CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                   color:
//                       _primaryLightColor,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   mainAxisSize:
//                       MainAxisSize.min,
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style:
//                           const TextStyle(
//                         color:
//                             _whiteColor,
//                         fontSize: 14,
//                         fontWeight:
//                             FontWeight.w800,
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     Text(
//                       message,
//                       style:
//                           const TextStyle(
//                         color:
//                             _mutedColor,
//                         fontSize: 11,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // STATES
//   // ============================================================

//   Widget _buildLoadingState() {
//     return const SizedBox(
//       width: double.infinity,
//       height: 250,
//       child: Center(
//         child:
//             CircularProgressIndicator(
//           strokeWidth: 2,
//           color: _primaryLightColor,
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorState(
//     String error,
//   ) {
//     return Container(
//       width: double.infinity,
//       padding:
//           const EdgeInsets.all(25),
//       decoration: BoxDecoration(
//         color: _panelColor,
//         borderRadius:
//             BorderRadius.circular(18),
//         border: Border.all(
//           color: Colors.redAccent
//               .withValues(alpha: 0.25),
//         ),
//       ),
//       child: Column(
//         children: [
//           const Icon(
//             Icons.error_outline_rounded,
//             color: Colors.redAccent,
//             size: 40,
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'Could not load products',
//             style: TextStyle(
//               color: _whiteColor,
//               fontSize: 15,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 7),
//           Text(
//             error,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: _mutedColor,
//               fontSize: 10,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState({
//     required IconData icon,
//     required String title,
//     required String message,
//     required bool showAddButton,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 20,
//         vertical: 55,
//       ),
//       decoration: BoxDecoration(
//         color: _panelColor,
//         borderRadius:
//             BorderRadius.circular(20),
//         border: Border.all(
//           color: _borderColor,
//         ),
//       ),
//       child: Column(
//         children: [
//           Icon(
//             icon,
//             color: _primaryLightColor,
//             size: 42,
//           ),
//           const SizedBox(height: 14),
//           Text(
//             title,
//             style: const TextStyle(
//               color: _whiteColor,
//               fontSize: 16,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: _mutedColor,
//               fontSize: 12,
//             ),
//           ),
//           if (showAddButton) ...[
//             const SizedBox(height: 18),
//             _buildAddButton(false),
//           ],
//         ],
//       ),
//     );
//   }
// }

// // ============================================================================
// // EDIT PRODUCT DIALOG
// // ============================================================================

// class _EditProductDialog
//     extends StatefulWidget {
//   final String productId;
//   final Map<String, dynamic> data;

//   const _EditProductDialog({
//     required this.productId,
//     required this.data,
//   });

//   @override
//   State<_EditProductDialog> createState() =>
//       _EditProductDialogState();
// }

// class _EditProductDialogState
//     extends State<_EditProductDialog> {
//   // ============================================================
//   // THEME
//   // ============================================================

//   static const Color _backgroundColor =
//       Color(0xFF080A12);

//   static const Color _panelColor =
//       Color(0xFF111522);

//   static const Color _primaryColor =
//       Color(0xFF7C5CFC);

//   static const Color _primaryLightColor =
//       Color(0xFF9D87FF);

//   static const Color _whiteColor =
//       Color(0xFFF5F5F7);

//   static const Color _mutedColor =
//       Color(0xFF9CA3B5);

//   static const Color _borderColor =
//       Color(0xFF272D40);

//   final GlobalKey<FormState> _formKey =
//       GlobalKey<FormState>();

//   late final TextEditingController
//       _nameController;

//   late final TextEditingController
//       _descriptionController;

//   late final TextEditingController
//       _priceController;

//   late final TextEditingController
//       _currencyController;

//   late final TextEditingController
//       _categoryController;

//   late final TextEditingController
//       _fandomIdController;

//   late final TextEditingController
//       _stockController;

//   final ImagePicker _imagePicker =
//       ImagePicker();

//   // Images currently remaining.
//   List<String> _existingImageUrls = [];

//   // Images selected during this edit.
//   final List<XFile> _newImages = [];

//   // Images removed by the admin.
//   final List<String> _removedImageUrls = [];

//   bool _isAvailable = true;
//   bool _isSaving = false;

//   // Upload status.
//   int _currentUpload = 0;
//   int _totalUploads = 0;

//   @override
//   void initState() {
//     super.initState();

//     _nameController =
//         TextEditingController(
//       text: _stringValue(
//         widget.data['name'],
//       ),
//     );

//     _descriptionController =
//         TextEditingController(
//       text: _stringValue(
//         widget.data['description'],
//       ),
//     );

//     _priceController =
//         TextEditingController(
//       text: _numberString(
//         widget.data['price'],
//       ),
//     );

//     _currencyController =
//         TextEditingController(
//       text: _stringValue(
//         widget.data['currency'],
//         fallback: 'PKR',
//       ),
//     );

//     _categoryController =
//         TextEditingController(
//       text: _stringValue(
//         widget.data['category'],
//       ),
//     );

//     _fandomIdController =
//         TextEditingController(
//       text: _stringValue(
//         widget.data['fandomId'],
//       ),
//     );

//     _stockController =
//         TextEditingController(
//       text: _numberString(
//         widget.data['stock'],
//       ),
//     );

//     _isAvailable =
//         widget.data['isAvailable'] == true;

//     _existingImageUrls =
//         _getImageUrls(widget.data);
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _priceController.dispose();
//     _currencyController.dispose();
//     _categoryController.dispose();
//     _fandomIdController.dispose();
//     _stockController.dispose();

//     super.dispose();
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor:
//           Colors.transparent,
//       insetPadding:
//           const EdgeInsets.symmetric(
//         horizontal: 14,
//         vertical: 20,
//       ),
//       child: LayoutBuilder(
//         builder:
//             (context, constraints) {
//           final bool isSmall =
//               constraints.maxWidth < 600;

//           return Container(
//             width: 760,
//             constraints:
//                 BoxConstraints(
//               maxHeight:
//                   MediaQuery.of(context)
//                           .size
//                           .height *
//                       0.92,
//             ),
//             decoration:
//                 BoxDecoration(
//               color: _panelColor,
//               borderRadius:
//                   BorderRadius.circular(
//                 22,
//               ),
//               border: Border.all(
//                 color: _borderColor,
//               ),
//             ),
//             child: Column(
//               children: [
//                 _buildDialogHeader(),
//                 Expanded(
//                   child:
//                       SingleChildScrollView(
//                     padding:
//                         EdgeInsets.all(
//                       isSmall
//                           ? 16
//                           : 24,
//                     ),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment
//                                 .start,
//                         children: [
//                           _buildSectionTitle(
//                             'Product Information',
//                           ),
//                           const SizedBox(
//                             height: 12,
//                           ),
//                           _buildResponsiveFields(
//                             isSmall,
//                           ),
//                           const SizedBox(
//                             height: 22,
//                           ),
//                           _buildSectionTitle(
//                             'Product Images',
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           const Text(
//                             'Remove old images or add new images. Changes are saved when you press Update Product.',
//                             style:
//                                 TextStyle(
//                               color:
//                                   _mutedColor,
//                               fontSize: 11,
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 12,
//                           ),
//                           _buildImagesGrid(),
//                           const SizedBox(
//                             height: 12,
//                           ),
//                           _buildAddImagesButton(),
//                           const SizedBox(
//                             height: 20,
//                           ),
//                           _buildAvailability(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 _buildDialogActions(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildDialogHeader() {
//     return Container(
//       padding:
//           const EdgeInsets.fromLTRB(
//         20,
//         18,
//         14,
//         18,
//       ),
//       decoration:
//           BoxDecoration(
//         color: _backgroundColor
//             .withValues(alpha: 0.35),
//         border: const Border(
//           bottom: BorderSide(
//             color: _borderColor,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration:
//                 BoxDecoration(
//               color: _primaryColor
//                   .withValues(
//                 alpha: 0.13,
//               ),
//               borderRadius:
//                   BorderRadius.circular(
//                 12,
//               ),
//             ),
//             child: const Icon(
//               Icons.edit_rounded,
//               color:
//                   _primaryLightColor,
//               size: 21,
//             ),
//           ),
//           const SizedBox(width: 12),
//           const Expanded(
//             child: Text(
//               'Edit Product',
//               style: TextStyle(
//                 color: _whiteColor,
//                 fontSize: 18,
//                 fontWeight:
//                     FontWeight.w800,
//               ),
//             ),
//           ),
//           IconButton(
//             tooltip: 'Close',
//             onPressed: _isSaving
//                 ? null
//                 : () {
//                     Navigator.pop(
//                       context,
//                     );
//                   },
//             icon: const Icon(
//               Icons.close_rounded,
//               color: _mutedColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(
//     String title,
//   ) {
//     return Text(
//       title,
//       style: const TextStyle(
//         color: _whiteColor,
//         fontSize: 14,
//         fontWeight: FontWeight.w800,
//       ),
//     );
//   }

//   // ============================================================
//   // FORM
//   // ============================================================

//   Widget _buildResponsiveFields(
//     bool isSmall,
//   ) {
//     if (isSmall) {
//       return Column(
//         children: [
//           _buildTextField(
//             controller:
//                 _nameController,
//             label: 'Product Name',
//             icon:
//                 Icons.shopping_bag_outlined,
//             validator: (value) {
//               if (value == null ||
//                   value.trim().isEmpty) {
//                 return 'Enter product name';
//               }

//               return null;
//             },
//           ),
//           const SizedBox(height: 12),
//           _buildTextField(
//             controller:
//                 _descriptionController,
//             label: 'Description',
//             icon:
//                 Icons.description_outlined,
//             maxLines: 3,
//           ),
//           const SizedBox(height: 12),
//           _buildTextField(
//             controller:
//                 _categoryController,
//             label: 'Category',
//             icon:
//                 Icons.category_outlined,
//             validator: (value) {
//               if (value == null ||
//                   value.trim().isEmpty) {
//                 return 'Enter category';
//               }

//               return null;
//             },
//           ),
//           const SizedBox(height: 12),
//           _buildTextField(
//             controller:
//                 _fandomIdController,
//             label: 'Fandom ID',
//             icon:
//                 Icons.auto_awesome_outlined,
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildTextField(
//                   controller:
//                       _priceController,
//                   label: 'Price',
//                   icon:
//                       Icons.payments_outlined,
//                   keyboardType:
//                       const TextInputType
//                           .numberWithOptions(
//                     decimal: true,
//                   ),
//                   validator: (value) {
//                     if (value == null ||
//                         value
//                             .trim()
//                             .isEmpty) {
//                       return 'Required';
//                     }

//                     if (double.tryParse(
//                           value.trim(),
//                         ) ==
//                         null) {
//                       return 'Invalid';
//                     }

//                     return null;
//                   },
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _buildTextField(
//                   controller:
//                       _currencyController,
//                   label: 'Currency',
//                   icon:
//                       Icons.currency_exchange_rounded,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           _buildTextField(
//             controller:
//                 _stockController,
//             label: 'Stock',
//             icon:
//                 Icons.inventory_2_outlined,
//             keyboardType:
//                 TextInputType.number,
//             validator: (value) {
//               if (value == null ||
//                   value.trim().isEmpty) {
//                 return 'Required';
//               }

//               if (int.tryParse(
//                     value.trim(),
//                   ) ==
//                   null) {
//                 return 'Invalid';
//               }

//               return null;
//             },
//           ),
//         ],
//       );
//     }

//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 controller:
//                     _nameController,
//                 label: 'Product Name',
//                 icon:
//                     Icons.shopping_bag_outlined,
//                 validator: (value) {
//                   if (value == null ||
//                       value
//                           .trim()
//                           .isEmpty) {
//                     return 'Enter product name';
//                   }

//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildTextField(
//                 controller:
//                     _categoryController,
//                 label: 'Category',
//                 icon:
//                     Icons.category_outlined,
//                 validator: (value) {
//                   if (value == null ||
//                       value
//                           .trim()
//                           .isEmpty) {
//                     return 'Enter category';
//                   }

//                   return null;
//                 },
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         _buildTextField(
//           controller:
//               _descriptionController,
//           label: 'Description',
//           icon:
//               Icons.description_outlined,
//           maxLines: 3,
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 controller:
//                     _fandomIdController,
//                 label: 'Fandom ID',
//                 icon:
//                     Icons.auto_awesome_outlined,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildTextField(
//                 controller:
//                     _stockController,
//                 label: 'Stock',
//                 icon:
//                     Icons.inventory_2_outlined,
//                 keyboardType:
//                     TextInputType.number,
//                 validator: (value) {
//                   if (value == null ||
//                       value
//                           .trim()
//                           .isEmpty) {
//                     return 'Required';
//                   }

//                   if (int.tryParse(
//                         value.trim(),
//                       ) ==
//                       null) {
//                     return 'Invalid';
//                   }

//                   return null;
//                 },
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 controller:
//                     _priceController,
//                 label: 'Price',
//                 icon:
//                     Icons.payments_outlined,
//                 keyboardType:
//                     const TextInputType
//                         .numberWithOptions(
//                   decimal: true,
//                 ),
//                 validator: (value) {
//                   if (value == null ||
//                       value
//                           .trim()
//                           .isEmpty) {
//                     return 'Required';
//                   }

//                   if (double.tryParse(
//                         value.trim(),
//                       ) ==
//                       null) {
//                     return 'Invalid';
//                   }

//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildTextField(
//                 controller:
//                     _currencyController,
//                 label: 'Currency',
//                 icon:
//                     Icons.currency_exchange_rounded,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController
//         controller,
//     required String label,
//     required IconData icon,
//     String? Function(String?)?
//         validator,
//     int maxLines = 1,
//     TextInputType? keyboardType,
//   }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboardType,
//       style: const TextStyle(
//         color: _whiteColor,
//         fontSize: 13,
//       ),
//       cursorColor:
//           _primaryLightColor,
//       validator: validator,
//       decoration:
//           InputDecoration(
//         labelText: label,
//         labelStyle:
//             const TextStyle(
//           color: _mutedColor,
//           fontSize: 12,
//         ),
//         prefixIcon: Icon(
//           icon,
//           color:
//               _primaryLightColor,
//           size: 19,
//         ),
//         filled: true,
//         fillColor:
//             _backgroundColor,
//         contentPadding:
//             const EdgeInsets
//                 .symmetric(
//           horizontal: 13,
//           vertical: 13,
//         ),
//         border:
//             OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(
//             12,
//           ),
//           borderSide:
//               const BorderSide(
//             color:
//                 _borderColor,
//           ),
//         ),
//         enabledBorder:
//             OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(
//             12,
//           ),
//           borderSide:
//               const BorderSide(
//             color:
//                 _borderColor,
//           ),
//         ),
//         focusedBorder:
//             OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(
//             12,
//           ),
//           borderSide:
//               const BorderSide(
//             color:
//                 _primaryColor,
//           ),
//         ),
//         errorBorder:
//             OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(
//             12,
//           ),
//           borderSide:
//               const BorderSide(
//             color:
//                 Colors.redAccent,
//           ),
//         ),
//         focusedErrorBorder:
//             OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(
//             12,
//           ),
//           borderSide:
//               const BorderSide(
//             color:
//                 Colors.redAccent,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // IMAGE GRID
//   // ============================================================

//   Widget _buildImagesGrid() {
//     final int totalImages =
//         _existingImageUrls.length +
//             _newImages.length;

//     if (totalImages == 0) {
//       return Container(
//         width: double.infinity,
//         padding:
//             const EdgeInsets.symmetric(
//           vertical: 30,
//         ),
//         decoration:
//             BoxDecoration(
//           color: _backgroundColor,
//           borderRadius:
//               BorderRadius.circular(
//             14,
//           ),
//           border: Border.all(
//             color: _borderColor,
//           ),
//         ),
//         child: const Column(
//           children: [
//             Icon(
//               Icons
//                   .photo_library_outlined,
//               color: _mutedColor,
//               size: 32,
//             ),
//             SizedBox(height: 8),
//             Text(
//               'No images selected',
//               style: TextStyle(
//                 color: _mutedColor,
//                 fontSize: 11,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return GridView.builder(
//       shrinkWrap: true,
//       physics:
//           const NeverScrollableScrollPhysics(),
//       itemCount: totalImages,
//       gridDelegate:
//           const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 8,
//         mainAxisSpacing: 8,
//         childAspectRatio: 1,
//       ),
//       itemBuilder:
//           (context, index) {
//         if (index <
//             _existingImageUrls.length) {
//           return _buildExistingImage(
//             index,
//             _existingImageUrls[index],
//           );
//         }

//         final int newIndex =
//             index -
//                 _existingImageUrls.length;

//         return _buildNewImage(
//           newIndex,
//           _newImages[newIndex],
//         );
//       },
//     );
//   }

//   Widget _buildExistingImage(
//     int index,
//     String url,
//   ) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         ClipRRect(
//           borderRadius:
//               BorderRadius.circular(12),
//           child: Image.network(
//             url,
//             fit: BoxFit.cover,
//             loadingBuilder: (
//               context,
//               child,
//               progress,
//             ) {
//               if (progress == null) {
//                 return child;
//               }

//               return Container(
//                 color:
//                     _backgroundColor,
//                 child:
//                     const Center(
//                   child:
//                       CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color:
//                         _primaryLightColor,
//                   ),
//                 ),
//               );
//             },
//             errorBuilder: (
//               context,
//               error,
//               stackTrace,
//             ) {
//               return Container(
//                 color:
//                     _backgroundColor,
//                 child:
//                     const Center(
//                   child: Icon(
//                     Icons
//                         .broken_image_outlined,
//                     color:
//                         _mutedColor,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         Positioned(
//           top: 6,
//           right: 6,
//           child: _imageRemoveButton(
//             onPressed: () {
//               _removeExistingImage(
//                 index,
//               );
//             },
//           ),
//         ),
//         if (index == 0)
//           Positioned(
//             left: 6,
//             bottom: 6,
//             child: _mainImageLabel(),
//           ),
//       ],
//     );
//   }

//   Widget _buildNewImage(
//     int index,
//     XFile image,
//   ) {
//     return FutureBuilder<
//         Uint8List>(
//       future: image.readAsBytes(),
//       builder:
//           (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Container(
//             decoration:
//                 BoxDecoration(
//               color:
//                   _backgroundColor,
//               borderRadius:
//                   BorderRadius.circular(
//                 12,
//               ),
//             ),
//             child:
//                 const Center(
//               child:
//                   CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color:
//                     _primaryLightColor,
//               ),
//             ),
//           );
//         }

//         return Stack(
//           fit: StackFit.expand,
//           children: [
//             ClipRRect(
//               borderRadius:
//                   BorderRadius.circular(
//                 12,
//               ),
//               child:
//                   Image.memory(
//                 snapshot.data!,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             Positioned(
//               top: 6,
//               right: 6,
//               child:
//                   _imageRemoveButton(
//                 onPressed: () {
//                   setState(() {
//                     _newImages
//                         .removeAt(index);
//                   });
//                 },
//               ),
//             ),
//             Positioned(
//               left: 6,
//               bottom: 6,
//               child: Container(
//                 padding:
//                     const EdgeInsets
//                         .symmetric(
//                   horizontal: 6,
//                   vertical: 4,
//                 ),
//                 decoration:
//                     BoxDecoration(
//                   color:
//                       _primaryColor,
//                   borderRadius:
//                       BorderRadius.circular(
//                     6,
//                   ),
//                 ),
//                 child: const Text(
//                   'NEW',
//                   style: TextStyle(
//                     color:
//                         Colors.white,
//                     fontSize: 8,
//                     fontWeight:
//                         FontWeight.w800,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _removeExistingImage(
//     int index,
//   ) {
//     final String url =
//         _existingImageUrls[index];

//     setState(() {
//       _existingImageUrls
//           .removeAt(index);

//       if (!_removedImageUrls
//           .contains(url)) {
//         _removedImageUrls.add(url);
//       }
//     });
//   }

//   Widget _imageRemoveButton({
//     required VoidCallback onPressed,
//   }) {
//     return Material(
//       color: Colors.black
//           .withValues(alpha: 0.70),
//       shape:
//           const CircleBorder(),
//       child: InkWell(
//         customBorder:
//             const CircleBorder(),
//         onTap: onPressed,
//         child: const Padding(
//           padding:
//               EdgeInsets.all(5),
//           child: Icon(
//             Icons.close_rounded,
//             color: Colors.white,
//             size: 15,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _mainImageLabel() {
//     return Container(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 6,
//         vertical: 4,
//       ),
//       decoration:
//           BoxDecoration(
//         color: _primaryColor,
//         borderRadius:
//             BorderRadius.circular(6),
//       ),
//       child: const Text(
//         'MAIN',
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 8,
//           fontWeight:
//               FontWeight.w800,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // ADD IMAGES
//   // ============================================================

//   Widget _buildAddImagesButton() {
//     return OutlinedButton.icon(
//       onPressed: _isSaving
//           ? null
//           : _pickAdditionalImages,
//       icon: const Icon(
//         Icons
//             .add_photo_alternate_outlined,
//         size: 18,
//       ),
//       label: const Text(
//         'Add More Images',
//       ),
//       style:
//           OutlinedButton.styleFrom(
//         foregroundColor:
//             _primaryLightColor,
//         side: BorderSide(
//           color: _primaryColor
//               .withValues(
//             alpha: 0.45,
//           ),
//         ),
//         padding:
//             const EdgeInsets
//                 .symmetric(
//           horizontal: 14,
//           vertical: 11,
//         ),
//         shape:
//             RoundedRectangleBorder(
//           borderRadius:
//               BorderRadius.circular(
//             11,
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void>
//       _pickAdditionalImages() async {
//     try {
//       final List<XFile> images =
//           await _imagePicker
//               .pickMultiImage(
//         imageQuality: 90,
//       );

//       if (images.isEmpty ||
//           !mounted) {
//         return;
//       }

//       setState(() {
//         for (final image in images) {
//           final bool duplicate =
//               _newImages.any(
//             (existing) =>
//                 existing.path ==
//                 image.path,
//           );

//           if (!duplicate) {
//             _newImages.add(image);
//           }
//         }
//       });
//     } catch (error) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Could not select images: $error',
//           ),
//           backgroundColor:
//               Colors.redAccent,
//           behavior:
//               SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   // ============================================================
//   // AVAILABILITY
//   // ============================================================

//   Widget _buildAvailability() {
//     return Container(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 13,
//         vertical: 4,
//       ),
//       decoration:
//           BoxDecoration(
//         color: _backgroundColor,
//         borderRadius:
//             BorderRadius.circular(
//           12,
//         ),
//         border: Border.all(
//           color: _borderColor,
//         ),
//       ),
//       child: SwitchListTile(
//         contentPadding:
//             EdgeInsets.zero,
//         value: _isAvailable,
//         onChanged: _isSaving
//             ? null
//             : (value) {
//                 setState(() {
//                   _isAvailable =
//                       value;
//                 });
//               },
//         activeColor:
//             _primaryLightColor,
//         title: const Text(
//           'Product Available',
//           style: TextStyle(
//             color: _whiteColor,
//             fontSize: 12.5,
//             fontWeight:
//                 FontWeight.w700,
//           ),
//         ),
//         subtitle: Text(
//           _isAvailable
//               ? 'Customers can purchase this product.'
//               : 'Product is currently unavailable.',
//           style:
//               const TextStyle(
//             color: _mutedColor,
//             fontSize: 10,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // DIALOG ACTIONS
//   // ============================================================

//   Widget _buildDialogActions() {
//     return Container(
//       padding:
//           const EdgeInsets.all(14),
//       decoration:
//           const BoxDecoration(
//         border: Border(
//           top: BorderSide(
//             color: _borderColor,
//           ),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment:
//             MainAxisAlignment.end,
//         children: [
//           TextButton(
//             onPressed: _isSaving
//                 ? null
//                 : () {
//                     Navigator.pop(
//                       context,
//                     );
//                   },
//             child: const Text(
//               'Cancel',
//               style: TextStyle(
//                 color: _mutedColor,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           ElevatedButton.icon(
//             onPressed: _isSaving
//                 ? null
//                 : _confirmUpdate,
//             icon: _isSaving
//                 ? const SizedBox(
//                     width: 15,
//                     height: 15,
//                     child:
//                         CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color:
//                           Colors.white,
//                     ),
//                   )
//                 : const Icon(
//                     Icons.save_rounded,
//                     size: 17,
//                   ),
//             label: Text(
//               _isSaving
//                   ? _totalUploads > 0
//                       ? 'Uploading $_currentUpload/$_totalUploads...'
//                       : 'Saving...'
//                   : 'Update Product',
//             ),
//             style:
//                 ElevatedButton.styleFrom(
//               backgroundColor:
//                   _primaryColor,
//               foregroundColor:
//                   Colors.white,
//               padding:
//                   const EdgeInsets
//                       .symmetric(
//                 horizontal: 15,
//                 vertical: 12,
//               ),
//               shape:
//                   RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(
//                   10,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // CONFIRM UPDATE
//   // ============================================================

//   Future<void> _confirmUpdate() async {
//     if (!_formKey.currentState!
//         .validate()) {
//       return;
//     }

//     final bool? confirmed =
//         await showDialog<bool>(
//       context: context,
//       builder:
//           (dialogContext) {
//         return AlertDialog(
//           backgroundColor:
//               _panelColor,
//           title: const Text(
//             'Confirm Update',
//             style: TextStyle(
//               color: _whiteColor,
//               fontWeight:
//                   FontWeight.w800,
//             ),
//           ),
//           content: const Text(
//             'Are you sure you want to update this product?',
//             style: TextStyle(
//               color: _mutedColor,
//               height: 1.4,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                   false,
//                 );
//               },
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: _mutedColor,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                   true,
//                 );
//               },
//               style:
//                   ElevatedButton.styleFrom(
//                 backgroundColor:
//                     _primaryColor,
//                 foregroundColor:
//                     Colors.white,
//               ),
//               child:
//                   const Text('Confirm'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed != true) {
//       return;
//     }

//     await _updateProduct();
//   }

//   // ============================================================
//   // UPDATE PRODUCT
//   // ============================================================

//   Future<void> _updateProduct() async {
//     if (!mounted) return;

//     setState(() {
//       _isSaving = true;
//       _currentUpload = 0;
//       _totalUploads =
//           _newImages.length;
//     });

//     try {
//       // --------------------------------------------------------
//       // 1. Validate Firebase user
//       // --------------------------------------------------------

//       final User? user =
//           FirebaseAuth.instance
//               .currentUser;

//       if (user == null) {
//         throw Exception(
//           'You are not signed in.',
//         );
//       }

//       // --------------------------------------------------------
//       // 2. Start with images that still exist
//       // --------------------------------------------------------

//       final List<String>
//           finalImageUrls =
//           List<String>.from(
//         _existingImageUrls,
//       );

//       // --------------------------------------------------------
//       // 3. Upload NEW images
//       //
//       // Android emulator:
//       // XFile.path -> File -> putFile()
//       // --------------------------------------------------------

//       for (
//         int index = 0;
//         index < _newImages.length;
//         index++
//       ) {
//         if (!mounted) return;

//         final XFile image =
//             _newImages[index];

//         setState(() {
//           _currentUpload =
//               index + 1;
//         });

//         final File imageFile =
//             File(image.path);

//         if (!await imageFile.exists()) {
//           throw Exception(
//             'Image file could not be found: ${image.name}',
//           );
//         }

//         final String extension =
//             _getExtension(
//           image.name,
//         );

//         final String uniqueName =
//             '${DateTime.now().millisecondsSinceEpoch}_${index}_${_randomSafeId()}.$extension';

//         final Reference
//             storageRef =
//             FirebaseStorage.instance
//                 .ref()
//                 .child('products')
//                 .child(
//                   widget.productId,
//                 )
//                 .child(uniqueName);

//         final SettableMetadata
//             metadata =
//             SettableMetadata(
//           contentType:
//               _contentType(
//             extension,
//           ),
//           cacheControl:
//               'public,max-age=31536000',
//         );

//         // ------------------------------------------------------
//         // Upload with timeout.
//         // Prevents infinite "Saving..." state.
//         // ------------------------------------------------------

//         final UploadTask uploadTask =
//             storageRef.putFile(
//           imageFile,
//           metadata,
//         );

//         await _waitForUpload(
//           uploadTask,
//           image.name,
//         );

//         final String
//             downloadUrl =
//             await storageRef
//                 .getDownloadURL()
//                 .timeout(
//                   const Duration(
//                     seconds: 30,
//                   ),
//                   onTimeout: () {
//                     throw TimeoutException(
//                       'Timed out while getting image URL.',
//                     );
//                   },
//                 );

//         finalImageUrls
//             .add(downloadUrl);
//       }

//       // --------------------------------------------------------
//       // 4. Parse values
//       // --------------------------------------------------------

//       final double price =
//           double.parse(
//         _priceController.text
//             .trim(),
//       );

//       final int stock =
//           int.parse(
//         _stockController.text
//             .trim(),
//       );

//       // --------------------------------------------------------
//       // 5. Update Firestore
//       // --------------------------------------------------------

//       final Map<String, dynamic>
//           updateData = {
//         'name':
//             _nameController.text
//                 .trim(),

//         'description':
//             _descriptionController
//                 .text
//                 .trim(),

//         'price': price,

//         'currency':
//             _currencyController
//                     .text
//                     .trim()
//                     .isEmpty
//                 ? 'PKR'
//                 : _currencyController
//                     .text
//                     .trim(),

//         'category':
//             _categoryController
//                 .text
//                 .trim(),

//         'fandomId':
//             _fandomIdController
//                 .text
//                 .trim(),

//         'stock': stock,

//         'isAvailable':
//             _isAvailable,

//         'imageUrls':
//             finalImageUrls,

//         'imageUrl':
//             finalImageUrls.isNotEmpty
//                 ? finalImageUrls.first
//                 : '',

//         'updatedAt':
//             FieldValue.serverTimestamp(),

//         'updatedBy': user.uid,
//       };

//       await FirebaseFirestore
//           .instance
//           .collection('products')
//           .doc(widget.productId)
//           .update(updateData)
//           .timeout(
//         const Duration(
//           seconds: 30,
//         ),
//         onTimeout: () {
//           throw TimeoutException(
//             'Firestore update timed out.',
//           );
//         },
//       );

//       // --------------------------------------------------------
//       // 6. NOW delete images removed by admin.
//       //
//       // Important:
//       // Firestore is already updated, so if one old image
//       // cannot be deleted from Storage, the product itself
//       // remains successfully updated.
//       // --------------------------------------------------------

//       await _deleteRemovedImages();

//       // --------------------------------------------------------
//       // 7. Success
//       // --------------------------------------------------------

//       if (!mounted) return;

//       Navigator.pop(
//         context,
//         true,
//       );
//     } catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _isSaving = false;
//       });

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Update failed:\n$error',
//           ),
//           backgroundColor:
//               Colors.redAccent,
//           behavior:
//               SnackBarBehavior.floating,
//           duration:
//               const Duration(
//             seconds: 8,
//           ),
//         ),
//       );
//     }
//   }

//   // ============================================================
//   // UPLOAD TASK
//   // ============================================================

//   Future<void> _waitForUpload(
//     UploadTask task,
//     String fileName,
//   ) async {
//     final Completer<void>
//         completer =
//         Completer<void>();

//     StreamSubscription<
//         TaskSnapshot>? subscription;

//     subscription =
//         task.snapshotEvents.listen(
//       (TaskSnapshot snapshot) {
//         if (snapshot.state ==
//             TaskState.success) {
//           if (!completer.isCompleted) {
//             completer.complete();
//           }
//         }

//         if (snapshot.state ==
//             TaskState.error) {
//           if (!completer.isCompleted) {
//             completer.completeError(
//               Exception(
//                 'Firebase Storage failed while uploading $fileName.',
//               ),
//             );
//           }
//         }

//         if (snapshot.state ==
//             TaskState.canceled) {
//           if (!completer.isCompleted) {
//             completer.completeError(
//               Exception(
//                 'Upload cancelled for $fileName.',
//               ),
//             );
//           }
//         }
//       },
//       onError: (Object error) {
//         if (!completer.isCompleted) {
//           completer.completeError(
//             error,
//           );
//         }
//       },
//     );

//     try {
//       await completer.future.timeout(
//         const Duration(minutes: 3),
//         onTimeout: () {
//           throw TimeoutException(
//             'Image upload timed out for $fileName.',
//           );
//         },
//       );
//     } finally {
//       await subscription.cancel();
//     }
//   }

//   // ============================================================
//   // DELETE REMOVED IMAGES
//   // ============================================================

//   Future<void>
//       _deleteRemovedImages() async {
//     for (
//       final String url
//       in _removedImageUrls
//     ) {
//       if (url.trim().isEmpty) {
//         continue;
//       }

//       try {
//         final Reference ref =
//             FirebaseStorage.instance
//                 .refFromURL(url);

//         await ref.delete();
//       } catch (_) {
//         // Do not fail product update.
//       }
//     }
//   }

//   // ============================================================
//   // FILE HELPERS
//   // ============================================================

//   String _randomSafeId() {
//     return DateTime.now()
//         .microsecondsSinceEpoch
//         .toString();
//   }

//   String _getExtension(
//     String fileName,
//   ) {
//     final int dotIndex =
//         fileName.lastIndexOf('.');

//     if (dotIndex == -1) {
//       return 'jpg';
//     }

//     final String extension =
//         fileName
//             .substring(dotIndex + 1)
//             .toLowerCase();

//     if (extension == 'jpeg') {
//       return 'jpg';
//     }

//     if (extension == 'png' ||
//         extension == 'webp' ||
//         extension == 'gif' ||
//         extension == 'jpg') {
//       return extension;
//     }

//     return 'jpg';
//   }

//   String _contentType(
//     String extension,
//   ) {
//     switch (extension) {
//       case 'png':
//         return 'image/png';

//       case 'webp':
//         return 'image/webp';

//       case 'gif':
//         return 'image/gif';

//       case 'jpg':
//       default:
//         return 'image/jpeg';
//     }
//   }

//   // ============================================================
//   // DATA HELPERS
//   // ============================================================

//   String _stringValue(
//     dynamic value, {
//     String fallback = '',
//   }) {
//     final String result =
//         value?.toString().trim() ??
//             '';

//     return result.isEmpty
//         ? fallback
//         : result;
//   }

//   String _numberString(
//     dynamic value,
//   ) {
//     if (value == null) {
//       return '';
//     }

//     if (value is num) {
//       return value.toString();
//     }

//     return value.toString();
//   }

//   List<String> _getImageUrls(
//     Map<String, dynamic> data,
//   ) {
//     final List<String> result = [];

//     final dynamic imageUrls =
//         data['imageUrls'];

//     if (imageUrls is List) {
//       for (final item in imageUrls) {
//         final String url =
//             item?.toString().trim() ??
//                 '';

//         if (url.isNotEmpty &&
//             !result.contains(url)) {
//           result.add(url);
//         }
//       }
//     }

//     final String imageUrl =
//         data['imageUrl']
//                 ?.toString()
//                 .trim() ??
//             '';

//     if (imageUrl.isNotEmpty &&
//         !result.contains(imageUrl)) {
//       result.insert(0, imageUrl);
//     }

//     return result;
//   }
// }

// // ============================================================================
// // BACKGROUND GLOW
// // ============================================================================

// class _BackgroundGlow
//     extends StatelessWidget {
//   const _BackgroundGlow();

//   @override
//   Widget build(
//     BuildContext context,
//   ) {
//     return IgnorePointer(
//       child: Stack(
//         children: [
//           Positioned(
//             top: -100,
//             right: -100,
//             child: Container(
//               width: 270,
//               height: 270,
//               decoration:
//                   BoxDecoration(
//                 shape:
//                     BoxShape.circle,
//                 color:
//                     const Color(
//                   0xFF7C5CFC,
//                 ).withValues(
//                   alpha: 0.055,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -100,
//             left: -100,
//             child: Container(
//               width: 280,
//               height: 280,
//               decoration:
//                   BoxDecoration(
//                 shape:
//                     BoxShape.circle,
//                 color:
//                     const Color(
//                   0xFFE0B45A,
//                 ).withValues(
//                   alpha: 0.025,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }





// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class ProductManagementScreen extends StatefulWidget {
//   const ProductManagementScreen({super.key});

//   @override
//   State<ProductManagementScreen> createState() =>
//       _ProductManagementScreenState();
// }

// class _ProductManagementScreenState extends State<ProductManagementScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ImagePicker _picker = ImagePicker();

//   bool _isLoading = true;
//   String _searchQuery = '';

//   List<QueryDocumentSnapshot<Map<String, dynamic>>> _products = [];

//   // Change these according to your project's actual categories.
//   final List<String> _categories = [
//     'Figures',
//     'Clothing',
//     'Accessories',
//     'Collectibles',
//     'Books',
//     'Posters',
//     'Toys',
//     'Other',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchProducts();
//   }

//   // ============================================================
//   // FETCH PRODUCTS
//   // ============================================================

//   Future<void> _fetchProducts() async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });

//       final snapshot = await _firestore
//           .collection('products')
//           .orderBy('createdAt', descending: true)
//           .get();

//       if (!mounted) return;

//       setState(() {
//         _products = snapshot.docs;
//         _isLoading = false;
//       });
//     } catch (e) {
//       // Fallback in case createdAt is missing on any old document.
//       try {
//         final snapshot =
//             await _firestore.collection('products').get();

//         if (!mounted) return;

//         setState(() {
//           _products = snapshot.docs;
//           _isLoading = false;
//         });
//       } catch (error) {
//         if (!mounted) return;

//         setState(() {
//           _isLoading = false;
//         });

//         _showError('Failed to fetch products: $error');
//       }
//     }
//   }

//   // ============================================================
//   // IMAGE HELPERS
//   // ============================================================

//   Uint8List? _decodeBase64Image(dynamic value) {
//     if (value == null) return null;

//     try {
//       String base64String = value.toString();

//       // Supports:
//       // data:image/png;base64,xxxx
//       // and normal xxxx base64
//       if (base64String.contains(',')) {
//         base64String = base64String.split(',').last;
//       }

//       return base64Decode(base64String);
//     } catch (_) {
//       return null;
//     }
//   }

//   Widget _buildBase64Image(
//     dynamic imageData, {
//     double? width,
//     double? height,
//     BoxFit fit = BoxFit.cover,
//   }) {
//     final bytes = _decodeBase64Image(imageData);

//     if (bytes == null) {
//       return Container(
//         width: width,
//         height: height,
//         color: const Color(0xFF1A1E2D),
//         child: const Icon(
//           Icons.image_not_supported_outlined,
//           color: Colors.white38,
//           size: 42,
//         ),
//       );
//     }

//     return Image.memory(
//       bytes,
//       width: width,
//       height: height,
//       fit: fit,
//       gaplessPlayback: true,
//       errorBuilder: (_, __, ___) {
//         return Container(
//           width: width,
//           height: height,
//           color: const Color(0xFF1A1E2D),
//           child: const Icon(
//             Icons.broken_image_outlined,
//             color: Colors.white38,
//             size: 42,
//           ),
//         );
//       },
//     );
//   }

//   Future<List<String>> _pickImages() async {
//     try {
//       final List<XFile> pickedImages = await _picker.pickMultiImage(
//         imageQuality: 80,
//       );

//       if (pickedImages.isEmpty) {
//         return [];
//       }

//       final List<String> base64Images = [];

//       for (final image in pickedImages) {
//         final bytes = await image.readAsBytes();

//         if (bytes.isNotEmpty) {
//           base64Images.add(base64Encode(bytes));
//         }
//       }

//       return base64Images;
//     } catch (e) {
//       _showError('Unable to select images: $e');
//       return [];
//     }
//   }

//   // ============================================================
//   // DELETE PRODUCT
//   // ============================================================

//   Future<void> _confirmDelete(
//     QueryDocumentSnapshot<Map<String, dynamic>> product,
//   ) async {
//     final data = product.data();

//     final String name =
//         (data['name'] ?? 'Unnamed Product').toString();

//     final bool? confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF111522),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           title: const Text(
//             'Delete Product?',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete "$name"?\n\n'
//             'This action cannot be undone.',
//             style: const TextStyle(
//               color: Colors.white70,
//               height: 1.5,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(color: Colors.white70),
//               ),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 foregroundColor: Colors.white,
//               ),
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed != true) return;

//     try {
//       await _firestore
//           .collection('products')
//           .doc(product.id)
//           .delete();

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Product deleted successfully'),
//         ),
//       );

//       await _fetchProducts();
//     } catch (e) {
//       _showError('Failed to delete product: $e');
//     }
//   }

//   // ============================================================
//   // EDIT CONFIRMATION
//   // ============================================================

//   Future<void> _confirmEdit(
//     QueryDocumentSnapshot<Map<String, dynamic>> product,
//   ) async {
//     final data = product.data();

//     final String name =
//         (data['name'] ?? 'Unnamed Product').toString();

//     final bool? confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF111522),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           title: const Text(
//             'Edit Product?',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Text(
//             'Do you want to edit "$name"?',
//             style: const TextStyle(
//               color: Colors.white70,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(color: Colors.white70),
//               ),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF7C5CFC),
//                 foregroundColor: Colors.white,
//               ),
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('Continue'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed != true || !mounted) return;

//     await _showEditProductDialog(product);
//   }

//   // ============================================================
//   // EDIT PRODUCT DIALOG
//   // ============================================================

//   Future<void> _showEditProductDialog(
//     QueryDocumentSnapshot<Map<String, dynamic>> product,
//   ) async {
//     final data = product.data();

//     final nameController = TextEditingController(
//       text: (data['name'] ?? '').toString(),
//     );

//     final descriptionController = TextEditingController(
//       text: (data['desc'] ?? '').toString(),
//     );

//     final priceController = TextEditingController(
//       text: (data['price'] ?? '').toString(),
//     );

//     final stockController = TextEditingController(
//       text: (data['stock'] ?? '').toString(),
//     );

//     final currencyController = TextEditingController(
//       text: (data['currency'] ?? 'PKR').toString(),
//     );

//     String selectedCategory =
//         (data['category'] ?? '').toString();

//     // Keep an existing category even if it is not currently
//     // included in the hard-coded category list.
//     if (selectedCategory.isEmpty) {
//       selectedCategory = _categories.first;
//     }

//     final List<String> originalImages =
//         List<String>.from(data['imageUrls'] ?? []);

//     // IMPORTANT:
//     // Copy the images so editing does not modify Firestore data
//     // until Save is pressed.
//     List<String> editedImages = List<String>.from(originalImages);

//     bool isAvailable = data['isavailable'] == true;
//     bool isSaving = false;

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             Future<void> addImages() async {
//               final newImages = await _pickImages();

//               if (newImages.isEmpty) return;

//               setDialogState(() {
//                 editedImages.addAll(newImages);
//               });
//             }

//             void removeImage(int index) {
//               setDialogState(() {
//                 editedImages.removeAt(index);
//               });
//             }

//             void moveImageToFirst(int index) {
//               if (index == 0) return;

//               setDialogState(() {
//                 final image = editedImages.removeAt(index);
//                 editedImages.insert(0, image);
//               });
//             }

//             Future<void> saveChanges() async {
//               if (nameController.text.trim().isEmpty) {
//                 _showError('Product name is required');
//                 return;
//               }

//               if (priceController.text.trim().isEmpty) {
//                 _showError('Price is required');
//                 return;
//               }

//               if (stockController.text.trim().isEmpty) {
//                 _showError('Stock is required');
//                 return;
//               }

//               if (editedImages.isEmpty) {
//                 _showError('Please add at least one product image');
//                 return;
//               }

//               final double? price = double.tryParse(
//                 priceController.text.trim(),
//               );

//               final int? stock = int.tryParse(
//                 stockController.text.trim(),
//               );

//               if (price == null) {
//                 _showError('Enter a valid price');
//                 return;
//               }

//               if (stock == null) {
//                 _showError('Enter a valid stock quantity');
//                 return;
//               }

//               setDialogState(() {
//                 isSaving = true;
//               });

//               try {
//                 // IMPORTANT:
//                 // createdBy is NOT included here.
//                 // createdAt is NOT modified.
//                 //
//                 // Only editable fields are updated.
//                 await _firestore
//                     .collection('products')
//                     .doc(product.id)
//                     .update({
//                   'name': nameController.text.trim(),
//                   'desc': descriptionController.text.trim(),
//                   'currency':
//                       currencyController.text.trim().isEmpty
//                           ? 'PKR'
//                           : currencyController.text.trim(),
//                   'imageUrls': editedImages,
//                   'category': selectedCategory,
//                   'price': price,
//                   'stock': stock,
//                   'isavailable': isAvailable,
//                   'updatedAt': FieldValue.serverTimestamp(),
//                 });

//                 if (!mounted) return;

//                 Navigator.pop(dialogContext);

//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text(
//                       'Product updated successfully',
//                     ),
//                   ),
//                 );

//                 await _fetchProducts();
//               } catch (e) {
//                 setDialogState(() {
//                   isSaving = false;
//                 });

//                 _showError(
//                   'Failed to update product: $e',
//                 );
//               }
//             }

//             return Dialog(
//               backgroundColor: const Color(0xFF111522),
//               insetPadding: const EdgeInsets.symmetric(
//                 horizontal: 20,
//                 vertical: 24,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(22),
//               ),
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(
//                   maxWidth: 900,
//                   maxHeight: 850,
//                 ),
//                 child: Column(
//                   children: [
//                     // HEADER
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(
//                         22,
//                         20,
//                         14,
//                         14,
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 44,
//                             height: 44,
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF7C5CFC)
//                                   .withOpacity(.15),
//                               borderRadius:
//                                   BorderRadius.circular(12),
//                             ),
//                             child: const Icon(
//                               Icons.edit_rounded,
//                               color: Color(0xFF9D87FF),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           const Expanded(
//                             child: Text(
//                               'Edit Product',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 21,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: isSaving
//                                 ? null
//                                 : () => Navigator.pop(
//                                       dialogContext,
//                                     ),
//                             icon: const Icon(
//                               Icons.close_rounded,
//                               color: Colors.white70,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const Divider(
//                       color: Colors.white10,
//                       height: 1,
//                     ),

//                     Expanded(
//                       child: SingleChildScrollView(
//                         padding: const EdgeInsets.all(22),
//                         child: Column(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                           children: [
//                             // ==================================================
//                             // IMAGES
//                             // ==================================================

//                             Row(
//                               children: [
//                                 const Text(
//                                   'Product Images',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   '${editedImages.length} images',
//                                   style: const TextStyle(
//                                     color: Colors.white38,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 ElevatedButton.icon(
//                                   onPressed:
//                                       isSaving ? null : addImages,
//                                   icon: const Icon(
//                                     Icons.add_photo_alternate_outlined,
//                                     size: 18,
//                                   ),
//                                   label: const Text(
//                                     'Add Images',
//                                   ),
//                                   style:
//                                       ElevatedButton.styleFrom(
//                                     backgroundColor:
//                                         const Color(0xFF7C5CFC),
//                                     foregroundColor: Colors.white,
//                                     padding:
//                                         const EdgeInsets.symmetric(
//                                       horizontal: 14,
//                                       vertical: 12,
//                                     ),
//                                     shape:
//                                         RoundedRectangleBorder(
//                                       borderRadius:
//                                           BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 14),

//                             if (editedImages.isEmpty)
//                               Container(
//                                 height: 150,
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   color:
//                                       const Color(0xFF171B2B),
//                                   borderRadius:
//                                       BorderRadius.circular(15),
//                                   border: Border.all(
//                                     color: Colors.white10,
//                                   ),
//                                 ),
//                                 child: const Column(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.image_outlined,
//                                       color: Colors.white30,
//                                       size: 42,
//                                     ),
//                                     SizedBox(height: 8),
//                                     Text(
//                                       'No images',
//                                       style: TextStyle(
//                                         color: Colors.white54,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             else
//                               GridView.builder(
//                                 shrinkWrap: true,
//                                 physics:
//                                     const NeverScrollableScrollPhysics(),
//                                 itemCount: editedImages.length,
//                                 gridDelegate:
//                                     const SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: 3,
//                                   crossAxisSpacing: 10,
//                                   mainAxisSpacing: 10,
//                                   childAspectRatio: .95,
//                                 ),
//                                 itemBuilder: (context, index) {
//                                   return Stack(
//                                     fit: StackFit.expand,
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius:
//                                             BorderRadius.circular(
//                                           14,
//                                         ),
//                                         child: _buildBase64Image(
//                                           editedImages[index],
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),

//                                       // FIRST IMAGE BADGE
//                                       if (index == 0)
//                                         Positioned(
//                                           left: 8,
//                                           top: 8,
//                                           child: Container(
//                                             padding:
//                                                 const EdgeInsets
//                                                     .symmetric(
//                                               horizontal: 8,
//                                               vertical: 5,
//                                             ),
//                                             decoration:
//                                                 BoxDecoration(
//                                               color:
//                                                   const Color(
//                                                 0xFF7C5CFC,
//                                               ),
//                                               borderRadius:
//                                                   BorderRadius
//                                                       .circular(
//                                                 8,
//                                               ),
//                                             ),
//                                             child: const Text(
//                                               'MAIN',
//                                               style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 10,
//                                                 fontWeight:
//                                                     FontWeight.bold,
//                                               ),
//                                             ),
//                                           ),
//                                         ),

//                                       // REMOVE BUTTON
//                                       Positioned(
//                                         right: 7,
//                                         top: 7,
//                                         child: InkWell(
//                                           onTap: isSaving
//                                               ? null
//                                               : () =>
//                                                   removeImage(
//                                                     index,
//                                                   ),
//                                           child: Container(
//                                             width: 32,
//                                             height: 32,
//                                             decoration:
//                                                 const BoxDecoration(
//                                               color: Colors.black87,
//                                               shape:
//                                                   BoxShape.circle,
//                                             ),
//                                             child: const Icon(
//                                               Icons
//                                                   .delete_outline_rounded,
//                                               color: Colors.white,
//                                               size: 18,
//                                             ),
//                                           ),
//                                         ),
//                                       ),

//                                       // MAKE MAIN
//                                       if (index != 0)
//                                         Positioned(
//                                           bottom: 7,
//                                           left: 7,
//                                           right: 7,
//                                           child: InkWell(
//                                             onTap: isSaving
//                                                 ? null
//                                                 : () =>
//                                                     moveImageToFirst(
//                                                       index,
//                                                     ),
//                                             child: Container(
//                                               padding:
//                                                   const EdgeInsets
//                                                       .symmetric(
//                                                 vertical: 7,
//                                               ),
//                                               decoration:
//                                                   BoxDecoration(
//                                                 color: Colors
//                                                     .black87,
//                                                 borderRadius:
//                                                     BorderRadius
//                                                         .circular(
//                                                   8,
//                                                 ),
//                                               ),
//                                               child: const Text(
//                                                 'Make Main',
//                                                 textAlign:
//                                                     TextAlign.center,
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 11,
//                                                   fontWeight:
//                                                       FontWeight
//                                                           .w600,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                     ],
//                                   );
//                                 },
//                               ),

//                             const SizedBox(height: 24),

//                             // ==================================================
//                             // NAME
//                             // ==================================================

//                             _buildField(
//                               controller: nameController,
//                               label: 'Product Name',
//                               icon: Icons.inventory_2_outlined,
//                             ),

//                             const SizedBox(height: 14),

//                             // ==================================================
//                             // DESCRIPTION
//                             // ==================================================

//                             _buildField(
//                               controller: descriptionController,
//                               label: 'Description',
//                               icon: Icons.description_outlined,
//                               maxLines: 4,
//                             ),

//                             const SizedBox(height: 14),

//                             // ==================================================
//                             // PRICE + STOCK
//                             // ==================================================

//                             LayoutBuilder(
//                               builder: (context, constraints) {
//                                 if (constraints.maxWidth < 550) {
//                                   return Column(
//                                     children: [
//                                       _buildField(
//                                         controller:
//                                             priceController,
//                                         label: 'Price',
//                                         icon: Icons
//                                             .payments_outlined,
//                                         keyboardType:
//                                             const TextInputType
//                                                 .numberWithOptions(
//                                           decimal: true,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 14),
//                                       _buildField(
//                                         controller:
//                                             stockController,
//                                         label: 'Stock',
//                                         icon: Icons
//                                             .inventory_outlined,
//                                         keyboardType:
//                                             TextInputType.number,
//                                       ),
//                                     ],
//                                   );
//                                 }

//                                 return Row(
//                                   children: [
//                                     Expanded(
//                                       child: _buildField(
//                                         controller:
//                                             priceController,
//                                         label: 'Price',
//                                         icon: Icons
//                                             .payments_outlined,
//                                         keyboardType:
//                                             const TextInputType
//                                                 .numberWithOptions(
//                                           decimal: true,
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 14),
//                                     Expanded(
//                                       child: _buildField(
//                                         controller:
//                                             stockController,
//                                         label: 'Stock',
//                                         icon: Icons
//                                             .inventory_outlined,
//                                         keyboardType:
//                                             TextInputType.number,
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             ),

//                             const SizedBox(height: 14),

//                             // ==================================================
//                             // CURRENCY + CATEGORY
//                             // ==================================================

//                             LayoutBuilder(
//                               builder: (context, constraints) {
//                                 if (constraints.maxWidth < 550) {
//                                   return Column(
//                                     children: [
//                                       _buildField(
//                                         controller:
//                                             currencyController,
//                                         label: 'Currency',
//                                         icon: Icons
//                                             .currency_exchange_rounded,
//                                       ),
//                                       const SizedBox(height: 14),
//                                       _buildCategoryDropdown(
//                                         selectedCategory,
//                                         (value) {
//                                           setDialogState(() {
//                                             selectedCategory =
//                                                 value!;
//                                           });
//                                         },
//                                       ),
//                                     ],
//                                   );
//                                 }

//                                 return Row(
//                                   children: [
//                                     Expanded(
//                                       child: _buildField(
//                                         controller:
//                                             currencyController,
//                                         label: 'Currency',
//                                         icon: Icons
//                                             .currency_exchange_rounded,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 14),
//                                     Expanded(
//                                       child:
//                                           _buildCategoryDropdown(
//                                         selectedCategory,
//                                         (value) {
//                                           setDialogState(() {
//                                             selectedCategory =
//                                                 value!;
//                                           });
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             ),

//                             const SizedBox(height: 14),

//                             // ==================================================
//                             // AVAILABLE
//                             // ==================================================

//                             Container(
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF171B2B),
//                                 borderRadius:
//                                     BorderRadius.circular(14),
//                                 border: Border.all(
//                                   color: Colors.white10,
//                                 ),
//                               ),
//                               child: SwitchListTile(
//                                 value: isAvailable,
//                                 onChanged: isSaving
//                                     ? null
//                                     : (value) {
//                                         setDialogState(() {
//                                           isAvailable = value;
//                                         });
//                                       },
//                                 activeColor:
//                                     const Color(0xFF7C5CFC),
//                                 title: const Text(
//                                   'Product Available',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 subtitle: Text(
//                                   isAvailable
//                                       ? 'Customers can purchase this product'
//                                       : 'Product is currently unavailable',
//                                   style: const TextStyle(
//                                     color: Colors.white54,
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: 24),

//                             // ==================================================
//                             // SAVE
//                             // ==================================================

//                             SizedBox(
//                               width: double.infinity,
//                               height: 52,
//                               child: ElevatedButton(
//                                 onPressed:
//                                     isSaving ? null : saveChanges,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor:
//                                       const Color(0xFF7C5CFC),
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(14),
//                                   ),
//                                 ),
//                                 child: isSaving
//                                     ? const SizedBox(
//                                         width: 22,
//                                         height: 22,
//                                         child:
//                                             CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           color: Colors.white,
//                                         ),
//                                       )
//                                     : const Text(
//                                         'Save Changes',
//                                         style: TextStyle(
//                                           fontSize: 15,
//                                           fontWeight:
//                                               FontWeight.bold,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );

//     nameController.dispose();
//     descriptionController.dispose();
//     priceController.dispose();
//     stockController.dispose();
//     currencyController.dispose();
//   }

//   // ============================================================
//   // INPUT FIELD
//   // ============================================================

//   Widget _buildField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType? keyboardType,
//     int maxLines = 1,
//   }) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       maxLines: maxLines,
//       style: const TextStyle(
//         color: Colors.white,
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(
//           color: Colors.white54,
//         ),
//         prefixIcon: Icon(
//           icon,
//           color: const Color(0xFF9D87FF),
//         ),
//         filled: true,
//         fillColor: const Color(0xFF171B2B),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Colors.white10,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Colors.white10,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Color(0xFF7C5CFC),
//             width: 1.5,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY DROPDOWN
//   // ============================================================

//   Widget _buildCategoryDropdown(
//     String value,
//     ValueChanged<String?> onChanged,
//   ) {
//     final List<String> items = List<String>.from(_categories);

//     if (!items.contains(value) && value.isNotEmpty) {
//       items.insert(0, value);
//     }

//     return DropdownButtonFormField<String>(
//       value: value.isEmpty ? null : value,
//       dropdownColor: const Color(0xFF171B2B),
//       style: const TextStyle(
//         color: Colors.white,
//       ),
//       decoration: InputDecoration(
//         labelText: 'Category',
//         labelStyle: const TextStyle(
//           color: Colors.white54,
//         ),
//         prefixIcon: const Icon(
//           Icons.category_outlined,
//           color: Color(0xFF9D87FF),
//         ),
//         filled: true,
//         fillColor: const Color(0xFF171B2B),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Colors.white10,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Colors.white10,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Color(0xFF7C5CFC),
//             width: 1.5,
//           ),
//         ),
//       ),
//       items: items
//           .map(
//             (category) => DropdownMenuItem<String>(
//               value: category,
//               child: Text(category),
//             ),
//           )
//           .toList(),
//       onChanged: onChanged,
//     );
//   }

//   // ============================================================
//   // PRODUCT CARD
//   // ============================================================

//   Widget _buildProductCard(
//     QueryDocumentSnapshot<Map<String, dynamic>> product,
//   ) {
//     final data = product.data();

//     final String name =
//         (data['name'] ?? 'Unnamed Product').toString();

//     final String description =
//         (data['desc'] ?? '').toString();

//     final String currency =
//         (data['currency'] ?? 'PKR').toString();

//     final dynamic priceValue = data['price'];

//     final String price = priceValue is num
//         ? priceValue.toString()
//         : priceValue?.toString() ?? '0';

//     final dynamic stockValue = data['stock'];

//     final String stock = stockValue is num
//         ? stockValue.toString()
//         : stockValue?.toString() ?? '0';

//     final String category =
//         (data['category'] ?? 'Other').toString();

//     final bool isAvailable =
//         data['isavailable'] == true;

//     final List<String> images =
//         List<String>.from(data['imageUrls'] ?? []);

//     // IMPORTANT:
//     // imageurls[0] is ALWAYS used as the main card image.
//     final dynamic mainImage =
//         images.isNotEmpty ? images[0] : null;

//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF111522),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(
//           color: Colors.white10,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.18),
//             blurRadius: 18,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ======================================================
//           // MAIN IMAGE
//           // ======================================================

//           AspectRatio(
//             aspectRatio: 1.25,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 mainImage != null
//                     ? _buildBase64Image(
//                         mainImage,
//                         fit: BoxFit.cover,
//                       )
//                     : Container(
//                         color: const Color(0xFF171B2B),
//                         child: const Icon(
//                           Icons.image_outlined,
//                           color: Colors.white24,
//                           size: 55,
//                         ),
//                       ),

//                 // Gradient
//                 Positioned.fill(
//                   child: DecoratedBox(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.transparent,
//                           Colors.black.withOpacity(.55),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 // AVAILABLE BADGE
//                 Positioned(
//                   top: 10,
//                   left: 10,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 9,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isAvailable
//                           ? Colors.green.withOpacity(.9)
//                           : Colors.redAccent.withOpacity(.9),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       isAvailable
//                           ? 'AVAILABLE'
//                           : 'UNAVAILABLE',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 9,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),

//                 // IMAGE COUNT
//                 Positioned(
//                   bottom: 10,
//                   left: 10,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 5,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(.7),
//                       borderRadius: BorderRadius.circular(7),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(
//                           Icons.photo_library_outlined,
//                           size: 13,
//                           color: Colors.white,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${images.length}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ======================================================
//           // DETAILS
//           // ======================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               14,
//               13,
//               14,
//               14,
//             ),
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         name,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       padding:
//                           const EdgeInsets.symmetric(
//                         horizontal: 7,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF7C5CFC)
//                             .withOpacity(.13),
//                         borderRadius:
//                             BorderRadius.circular(7),
//                       ),
//                       child: Text(
//                         category,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Color(0xFFB9AFFF),
//                           fontSize: 9,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 7),

//                 if (description.isNotEmpty)
//                   Text(
//                     description,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: Colors.white54,
//                       fontSize: 12,
//                       height: 1.4,
//                     ),
//                   ),

//                 const SizedBox(height: 12),

//                 Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'PRICE',
//                             style: TextStyle(
//                               color: Colors.white38,
//                               fontSize: 9,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 3),
//                           Text(
//                             '$currency $price',
//                             style: const TextStyle(
//                               color: Color(0xFFE0B45A),
//                               fontSize: 15,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       width: 1,
//                       height: 30,
//                       color: Colors.white10,
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding:
//                             const EdgeInsets.only(left: 14),
//                         child: Column(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'STOCK',
//                               style: TextStyle(
//                                 color: Colors.white38,
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 3),
//                             Text(
//                               stock,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 14),

//                 // ==================================================
//                 // ACTION BUTTONS
//                 // ==================================================

//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () =>
//                             _confirmEdit(product),
//                         icon: const Icon(
//                           Icons.edit_outlined,
//                           size: 17,
//                         ),
//                         label: const Text('Edit'),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor:
//                               const Color(0xFFB9AFFF),
//                           side: const BorderSide(
//                             color: Color(0xFF7C5CFC),
//                           ),
//                           padding:
//                               const EdgeInsets.symmetric(
//                             vertical: 11,
//                           ),
//                           shape:
//                               RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     SizedBox(
//                       width: 48,
//                       height: 43,
//                       child: OutlinedButton(
//                         onPressed: () =>
//                             _confirmDelete(product),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor:
//                               Colors.redAccent,
//                           side: BorderSide(
//                             color: Colors.redAccent
//                                 .withOpacity(.45),
//                           ),
//                           padding: EdgeInsets.zero,
//                           shape:
//                               RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(10),
//                           ),
//                         ),
//                         child: const Icon(
//                           Icons.delete_outline_rounded,
//                           size: 19,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // ERROR
//   // ============================================================

//   void _showError(String message) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.redAccent,
//       ),
//     );
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final filteredProducts = _products.where((product) {
//       if (_searchQuery.trim().isEmpty) return true;

//       final data = product.data();

//       final name =
//           (data['name'] ?? '').toString().toLowerCase();

//       final category =
//           (data['category'] ?? '').toString().toLowerCase();

//       final query = _searchQuery.toLowerCase();

//       return name.contains(query) ||
//           category.contains(query);
//     }).toList();

//     return Scaffold(
//       backgroundColor: const Color(0xFF080A12),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final bool isSmall =
//                 constraints.maxWidth < 650;

//             return Column(
//               children: [
//                 // ==================================================
//                 // HEADER
//                 // ==================================================

//                 Padding(
//                   padding: EdgeInsets.fromLTRB(
//                     isSmall ? 16 : 26,
//                     20,
//                     isSmall ? 16 : 26,
//                     12,
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 46,
//                         height: 46,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF7C5CFC)
//                               .withOpacity(.14),
//                           borderRadius:
//                               BorderRadius.circular(13),
//                         ),
//                         child: const Icon(
//                           Icons.inventory_2_outlined,
//                           color: Color(0xFF9D87FF),
//                           size: 24,
//                         ),
//                       ),
//                       const SizedBox(width: 13),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Product Management',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 21,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               '${_products.length} products',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         tooltip: 'Refresh',
//                         onPressed:
//                             _isLoading ? null : _fetchProducts,
//                         icon: const Icon(
//                           Icons.refresh_rounded,
//                           color: Colors.white70,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // ==================================================
//                 // SEARCH
//                 // ==================================================

//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: isSmall ? 16 : 26,
//                     vertical: 8,
//                   ),
//                   child: TextField(
//                     onChanged: (value) {
//                       setState(() {
//                         _searchQuery = value;
//                       });
//                     },
//                     style: const TextStyle(
//                       color: Colors.white,
//                     ),
//                     decoration: InputDecoration(
//                       hintText:
//                           'Search products or categories...',
//                       hintStyle: const TextStyle(
//                         color: Colors.white,
//                       ),
//                       prefixIcon: const Icon(
//                         Icons.search_rounded,
//                         color: Color(0xFF9D87FF),
//                       ),
//                       filled: true,
//                       fillColor: const Color(0xFF111522),
//                       border: OutlineInputBorder(
//                         borderRadius:
//                             BorderRadius.circular(14),
//                         borderSide: const BorderSide(
//                           color: Colors.white10,
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius:
//                             BorderRadius.circular(14),
//                         borderSide: const BorderSide(
//                           color: Colors.white10,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius:
//                             BorderRadius.circular(14),
//                         borderSide: const BorderSide(
//                           color: Color(0xFF7C5CFC),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 // ==================================================
//                 // PRODUCTS
//                 // ==================================================

//                 Expanded(
//                   child: _isLoading
//                       ? const Center(
//                           child:
//                               CircularProgressIndicator(
//                             color: Color(0xFF7C5CFC),
//                           ),
//                         )
//                       : filteredProducts.isEmpty
//                           ? _buildEmptyState()
//                           : RefreshIndicator(
//                               color:
//                                   const Color(0xFF7C5CFC),
//                               backgroundColor:
//                                   const Color(0xFF111522),
//                               onRefresh: _fetchProducts,
//                               child: GridView.builder(
//                                 padding: EdgeInsets.fromLTRB(
//                                   isSmall ? 16 : 26,
//                                   10,
//                                   isSmall ? 16 : 26,
//                                   30,
//                                 ),
//                                 physics:
//                                     const AlwaysScrollableScrollPhysics(),
//                                 gridDelegate:
//                                     SliverGridDelegateWithFixedCrossAxisCount(
//                                   // 2 cards per row on normal
//                                   // screens.
//                                   //
//                                   // On very narrow phones,
//                                   // one card prevents the
//                                   // card from becoming unusable.
//                                   crossAxisCount:
//                                       constraints.maxWidth <
//                                               430
//                                           ? 1
//                                           : 2,
//                                   crossAxisSpacing:
//                                       isSmall ? 12 : 18,
//                                   mainAxisSpacing:
//                                       isSmall ? 12 : 18,
//                                   childAspectRatio:
//                                       constraints.maxWidth <
//                                               430
//                                           ? .90
//                                           : .78,
//                                 ),
//                                 itemCount:
//                                     filteredProducts.length,
//                                 itemBuilder:
//                                     (context, index) {
//                                   return _buildProductCard(
//                                     filteredProducts[index],
//                                   );
//                                 },
//                               ),
//                             ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF7C5CFC)
//                     .withOpacity(.10),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.inventory_2_outlined,
//                 color: Color(0xFF9D87FF),
//                 size: 38,
//               ),
//             ),
//             const SizedBox(height: 18),
//             Text(
//               _searchQuery.isEmpty
//                   ? 'No Products Yet'
//                   : 'No Products Found',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 19,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 7),
//             Text(
//               _searchQuery.isEmpty
//                   ? 'Products you add will appear here.'
//                   : 'Try another product name or category.',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 13,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fandom_verse/screens/admin/add_prd_form.dart';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';

// import 'admin_drawer.dart';
// // import 'add_product_screen.dart';

// class ProductManagementScreen extends StatefulWidget {
//   const ProductManagementScreen({super.key});

//   @override
//   State<ProductManagementScreen> createState() =>
//       _ProductManagementScreenState();
// }

// class _ProductManagementScreenState extends State<ProductManagementScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ImagePicker _picker = ImagePicker();

//   static const Color _bg = Color(0xFF080A12);
//   static const Color _panel = Color(0xFF111522);
//   static const Color _panel2 = Color(0xFF171B2B);
//   static const Color _purple = Color(0xFF7C5CFC);
//   static const Color _purpleLight = Color(0xFF9D87FF);

//   // Firestore's complete document limit is 1 MiB.
//   // We keep the image payload well below that limit because the
//   // document also contains name, description, price, etc.
//   static const int _maxImagePayload = 650000;

//   final List<String> _categories = const [
//     'Figures',
//     'Clothing',
//     'Accessories',
//     'Collectibles',
//     'Books',
//     'Posters',
//     'Toys',
//     'Other',
//   ];

//   bool _loading = true;
//   String _search = '';

//   List<QueryDocumentSnapshot<Map<String, dynamic>>> _products = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadProducts();
//   }

//   // ============================================================
//   // LOAD
//   // ============================================================

//   Future<void> _loadProducts() async {
//     if (mounted) {
//       setState(() => _loading = true);
//     }

//     try {
//       QuerySnapshot<Map<String, dynamic>> snapshot;

//       try {
//         snapshot = await _firestore
//             .collection('products')
//             .orderBy('createdAt', descending: true)
//             .get();
//       } catch (_) {
//         // Allows older products without createdAt to still load.
//         snapshot = await _firestore.collection('products').get();
//       }

//       if (!mounted) return;

//       setState(() {
//         _products = snapshot.docs;
//         _loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() => _loading = false);

//       _snack(
//         'Could not load products: $e',
//         error: true,
//       );
//     }
//   }

//   // ============================================================
//   // FIRESTORE FIELD HELPERS
//   //
//   // Your original schema uses:
//   // imageurls
//   // catgory
//   // stcok
//   //
//   // These helpers also understand imageUrls/category/stock so
//   // products created by the previous page still display correctly.
//   // ============================================================

//   List<String> _imagesFrom(Map<String, dynamic> data) {
//     final value = data['imageurls'] ?? data['imageUrls'];

//     if (value is! List) {
//       return [];
//     }

//     return value
//         .map((e) => e.toString())
//         .where((e) => e.isNotEmpty)
//         .toList();
//   }

//   String _categoryFrom(Map<String, dynamic> data) {
//     return (data['catgory'] ?? data['category'] ?? 'Other').toString();
//   }

//   String _stockFrom(Map<String, dynamic> data) {
//     return (data['stcok'] ?? data['stock'] ?? 0).toString();
//   }

//   // ============================================================
//   // BASE64 IMAGE HELPERS
//   // ============================================================

//   Uint8List? _decodeBase64(String value) {
//     try {
//       String clean = value;

//       if (clean.contains(',')) {
//         clean = clean.split(',').last;
//       }

//       return base64Decode(clean);
//     } catch (_) {
//       return null;
//     }
//   }

//   Widget _buildImage(
//     String? value, {
//     BoxFit fit = BoxFit.cover,
//   }) {
//     if (value == null || value.isEmpty) {
//       return _imagePlaceholder();
//     }

//     final bytes = _decodeBase64(value);

//     if (bytes == null || bytes.isEmpty) {
//       return _imagePlaceholder();
//     }

//     return Image.memory(
//       bytes,
//       fit: fit,
//       width: double.infinity,
//       height: double.infinity,
//       gaplessPlayback: true,
//       errorBuilder: (_, __, ___) {
//         return _imagePlaceholder();
//       },
//     );
//   }

//   Widget _imagePlaceholder() {
//     return Container(
//       color: _panel2,
//       alignment: Alignment.center,
//       child: const Icon(
//         Icons.image_not_supported_outlined,
//         color: Colors.white30,
//         size: 42,
//       ),
//     );
//   }

//   // ============================================================
//   // COMPRESS IMAGE
//   //
//   // Base64 increases the data size by roughly 33%.
//   // Images should therefore be resized/compressed before putting
//   // them inside Firestore.
//   // ============================================================

//   String? _compressImage(
//     Uint8List bytes, {
//     required int maxDimension,
//     required int quality,
//   }) {
//     try {
//       final decoded = img.decodeImage(bytes);

//       if (decoded == null) {
//         return null;
//       }

//       img.Image resized = decoded;

//       if (decoded.width > maxDimension ||
//           decoded.height > maxDimension) {
//         if (decoded.width >= decoded.height) {
//           resized = img.copyResize(
//             decoded,
//             width: maxDimension,
//             interpolation: img.Interpolation.linear,
//           );
//         } else {
//           resized = img.copyResize(
//             decoded,
//             height: maxDimension,
//             interpolation: img.Interpolation.linear,
//           );
//         }
//       }

//       final jpg = img.encodeJpg(
//         resized,
//         quality: quality,
//       );

//       return base64Encode(jpg);
//     } catch (_) {
//       return null;
//     }
//   }

//   Future<List<String>> _pickAndCompressImages() async {
//     try {
//       final files = await _picker.pickMultiImage(
//         imageQuality: 100,
//       );

//       if (files.isEmpty) {
//         return [];
//       }

//       final result = <String>[];

//       for (final file in files) {
//         final bytes = await file.readAsBytes();

//         final encoded = _compressImage(
//           bytes,
//           maxDimension: 800,
//           quality: 55,
//         );

//         if (encoded != null) {
//           result.add(encoded);
//         }
//       }

//       return result;
//     } catch (e) {
//       _snack(
//         'Could not select images: $e',
//         error: true,
//       );

//       return [];
//     }
//   }

//   Future<String?> _recompressExistingImage(
//     String value, {
//     required int maxDimension,
//     required int quality,
//   }) async {
//     final bytes = _decodeBase64(value);

//     if (bytes == null) {
//       return null;
//     }

//     return _compressImage(
//       bytes,
//       maxDimension: maxDimension,
//       quality: quality,
//     );
//   }

//   int _imagePayloadSize(List<String> images) {
//     return images.fold<int>(
//       0,
//       (total, image) => total + image.length,
//     );
//   }

//   Future<List<String>> _fitImagesToFirestoreLimit(
//     List<String> images,
//   ) async {
//     Future<List<String>> compressAll(
//       int dimension,
//       int quality,
//     ) async {
//       final result = <String>[];

//       for (final image in images) {
//         final compressed = await _recompressExistingImage(
//           image,
//           maxDimension: dimension,
//           quality: quality,
//         );

//         if (compressed != null) {
//           result.add(compressed);
//         }
//       }

//       return result;
//     }

//     // First attempt: good visual quality.
//     var result = await compressAll(800, 55);

//     if (_imagePayloadSize(result) <= _maxImagePayload) {
//       return result;
//     }

//     // Second attempt: smaller.
//     result = await compressAll(700, 45);

//     if (_imagePayloadSize(result) <= _maxImagePayload) {
//       return result;
//     }

//     // Third attempt: aggressively optimized.
//     result = await compressAll(600, 35);

//     return result;
//   }

//   // ============================================================
//   // EDIT
//   // ============================================================

//   Future<void> _editProduct(
//     QueryDocumentSnapshot<Map<String, dynamic>> product,
//   ) async {
//     final data = product.data();

//     final confirmed = await _showConfirmation(
//       title: 'Edit Product?',
//       message: 'Do you want to open this product for editing?',
//       confirmText: 'Edit',
//       danger: false,
//     );

//     if (!confirmed || !mounted) {
//       return;
//     }

//     final nameController = TextEditingController(
//       text: '${data['name'] ?? ''}',
//     );

//     final descriptionController = TextEditingController(
//       text: '${data['desc'] ?? ''}',
//     );

//     final priceController = TextEditingController(
//       text: '${data['price'] ?? ''}',
//     );

//     final stockController = TextEditingController(
//       text: _stockFrom(data),
//     );

//     final currencyController = TextEditingController(
//       text: '${data['currency'] ?? 'PKR'}',
//     );

//     String selectedCategory = _categoryFrom(data);

//     if (!_categories.contains(selectedCategory)) {
//       selectedCategory = _categories.first;
//     }

//     bool isAvailable = data['isavailable'] == true;

//     List<String> images = _imagesFrom(data);

//     // Keep the original list so we can detect whether the user
//     // actually changed the images.
//     final originalImages = List<String>.from(images);

//     bool isSaving = false;

//     await showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             Future<void> addImages() async {
//               final picked = await _pickAndCompressImages();

//               if (picked.isEmpty) {
//                 return;
//               }

//               setDialogState(() {
//                 images = [
//                   ...images,
//                   ...picked,
//                 ];
//               });
//             }

//             void removeImage(int index) {
//               setDialogState(() {
//                 final copy = List<String>.from(images);
//                 copy.removeAt(index);
//                 images = copy;
//               });
//             }

//             void makeMainImage(int index) {
//               if (index == 0) {
//                 return;
//               }

//               setDialogState(() {
//                 final copy = List<String>.from(images);
//                 final selected = copy.removeAt(index);

//                 // The main image is ALWAYS imageurls[0].
//                 copy.insert(0, selected);

//                 images = copy;
//               });
//             }

//             Future<void> saveChanges() async {
//               if (nameController.text.trim().isEmpty) {
//                 _snack(
//                   'Product name is required.',
//                   error: true,
//                 );
//                 return;
//               }

//               if (priceController.text.trim().isEmpty) {
//                 _snack(
//                   'Price is required.',
//                   error: true,
//                 );
//                 return;
//               }

//               if (stockController.text.trim().isEmpty) {
//                 _snack(
//                   'Stock is required.',
//                   error: true,
//                 );
//                 return;
//               }

//               if (images.isEmpty) {
//                 _snack(
//                   'At least one product image is required.',
//                   error: true,
//                 );
//                 return;
//               }

//               final parsedPrice = double.tryParse(
//                 priceController.text.trim(),
//               );

//               final parsedStock = int.tryParse(
//                 stockController.text.trim(),
//               );

//               if (parsedPrice == null) {
//                 _snack(
//                   'Enter a valid price.',
//                   error: true,
//                 );
//                 return;
//               }

//               if (parsedStock == null) {
//                 _snack(
//                   'Enter a valid whole-number stock.',
//                   error: true,
//                 );
//                 return;
//               }

//               setDialogState(() {
//                 isSaving = true;
//               });

//               try {
//                 final imagesChanged = !_sameImageList(
//                   originalImages,
//                   images,
//                 );

//                 // IMPORTANT:
//                 //
//                 // createdBy is NOT updated.
//                 // createdAt is NOT updated.
//                 //
//                 // Also, imageurls is NOT sent at all when the user
//                 // did not change images. This prevents an already
//                 // oversized old image array from causing an error
//                 // during a normal text/price/stock edit.
//                 final Map<String, dynamic> updateData = {
//                   'name': nameController.text.trim(),
//                   'desc': descriptionController.text.trim(),
//                   'currency':
//                       currencyController.text.trim().isEmpty
//                           ? 'PKR'
//                           : currencyController.text.trim(),
//                   'catgory': selectedCategory,
//                   'price': parsedPrice,
//                   'stcok': parsedStock,
//                   'isavailable': isAvailable,
//                   'updatedAt': FieldValue.serverTimestamp(),
//                 };

//                 if (imagesChanged) {
//                   final safeImages =
//                       await _fitImagesToFirestoreLimit(images);

//                   if (safeImages.isEmpty) {
//                     setDialogState(() {
//                       isSaving = false;
//                     });

//                     _snack(
//                       'The selected images could not be processed.',
//                       error: true,
//                     );

//                     return;
//                   }

//                   final payloadSize =
//                       _imagePayloadSize(safeImages);

//                   if (payloadSize > _maxImagePayload) {
//                     setDialogState(() {
//                       isSaving = false;
//                     });

//                     _snack(
//                       'The image collection is still too large. '
//                       'Use fewer or smaller images. Firestore has a 1 MiB document limit.',
//                       error: true,
//                     );

//                     return;
//                   }

//                   // Use YOUR original Firestore field name.
//                   updateData['imageurls'] = safeImages;
//                 }

//                 await _firestore
//                     .collection('products')
//                     .doc(product.id)
//                     .update(updateData);

//                 if (!mounted) {
//                   return;
//                 }

//                 Navigator.pop(dialogContext);

//                 _snack(
//                   'Product updated successfully.',
//                 );

//                 await _loadProducts();
//               } catch (e) {
//                 setDialogState(() {
//                   isSaving = false;
//                 });

//                 _snack(
//                   'Failed to update product: $e',
//                   error: true,
//                 );
//               }
//             }

//             return Dialog(
//               backgroundColor: _panel,
//               insetPadding: const EdgeInsets.symmetric(
//                 horizontal: 14,
//                 vertical: 18,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(
//                   maxWidth: 560,
//                   maxHeight: 820,
//                 ),
//                 child: Column(
//                   children: [
//                     // --------------------------------------------------
//                     // EDIT HEADER
//                     // --------------------------------------------------

//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(
//                         18,
//                         14,
//                         10,
//                         12,
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.edit_rounded,
//                             color: _purpleLight,
//                           ),
//                           const SizedBox(width: 10),
//                           const Expanded(
//                             child: Text(
//                               'Edit Product',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 19,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: isSaving
//                                 ? null
//                                 : () {
//                                     Navigator.pop(
//                                       dialogContext,
//                                     );
//                                   },
//                             icon: const Icon(
//                               Icons.close_rounded,
//                               color: Colors.white70,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const Divider(
//                       height: 1,
//                       color: Colors.white10,
//                     ),

//                     Expanded(
//                       child: SingleChildScrollView(
//                         padding: const EdgeInsets.all(18),
//                         child: Column(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                           children: [
//                             // ------------------------------------------------
//                             // IMAGES
//                             // ------------------------------------------------

//                             Row(
//                               children: [
//                                 const Expanded(
//                                   child: Text(
//                                     'Product Images',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight:
//                                           FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                                 Text(
//                                   '${images.length}',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 SizedBox(
//                                   height: 38,
//                                   child: ElevatedButton.icon(
//                                     onPressed:
//                                         isSaving
//                                             ? null
//                                             : addImages,
//                                     icon: const Icon(
//                                       Icons
//                                           .add_photo_alternate_outlined,
//                                       size: 16,
//                                     ),
//                                     label: const Text('Add'),
//                                     style: ElevatedButton
//                                         .styleFrom(
//                                       backgroundColor:
//                                           _purple,
//                                       foregroundColor:
//                                           Colors.white,
//                                       padding:
//                                           const EdgeInsets
//                                               .symmetric(
//                                         horizontal: 12,
//                                       ),
//                                       shape:
//                                           RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(
//                                           10,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 10),

//                             if (images.isEmpty)
//                               Container(
//                                 height: 120,
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   color: _panel2,
//                                   borderRadius:
//                                       BorderRadius.circular(
//                                     12,
//                                   ),
//                                 ),
//                                 alignment: Alignment.center,
//                                 child: const Text(
//                                   'No images',
//                                   style: TextStyle(
//                                     color: Colors.white54,
//                                   ),
//                                 ),
//                               )
//                             else
//                               GridView.builder(
//                                 shrinkWrap: true,
//                                 physics:
//                                     const NeverScrollableScrollPhysics(),
//                                 itemCount: images.length,
//                                 gridDelegate:
//                                     const SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: 3,
//                                   crossAxisSpacing: 8,
//                                   mainAxisSpacing: 8,
//                                   childAspectRatio: 1,
//                                 ),
//                                 itemBuilder: (
//                                   context,
//                                   index,
//                                 ) {
//                                   return ClipRRect(
//                                     borderRadius:
//                                         BorderRadius.circular(
//                                       11,
//                                     ),
//                                     child: Stack(
//                                       fit: StackFit.expand,
//                                       children: [
//                                         _buildImage(
//                                           images[index],
//                                         ),

//                                         if (index == 0)
//                                           Positioned(
//                                             left: 6,
//                                             top: 6,
//                                             child: _badge(
//                                               'MAIN',
//                                             ),
//                                           ),

//                                         Positioned(
//                                           right: 3,
//                                           top: 3,
//                                           child: IconButton(
//                                             onPressed: isSaving
//                                                 ? null
//                                                 : () {
//                                                     removeImage(
//                                                       index,
//                                                     );
//                                                   },
//                                             style:
//                                                 IconButton.styleFrom(
//                                               backgroundColor:
//                                                   Colors.black87,
//                                               minimumSize:
//                                                   const Size(
//                                                 30,
//                                                 30,
//                                               ),
//                                               padding:
//                                                   EdgeInsets.zero,
//                                             ),
//                                             icon: const Icon(
//                                               Icons
//                                                   .delete_outline,
//                                               color:
//                                                   Colors.white,
//                                               size: 17,
//                                             ),
//                                           ),
//                                         ),

//                                         if (index != 0)
//                                           Positioned(
//                                             left: 5,
//                                             right: 5,
//                                             bottom: 5,
//                                             child: GestureDetector(
//                                               onTap: isSaving
//                                                   ? null
//                                                   : () {
//                                                       makeMainImage(
//                                                         index,
//                                                       );
//                                                     },
//                                               child: Container(
//                                                 padding:
//                                                     const EdgeInsets
//                                                         .symmetric(
//                                                   vertical: 5,
//                                                 ),
//                                                 decoration:
//                                                     BoxDecoration(
//                                                   color: Colors
//                                                       .black87,
//                                                   borderRadius:
//                                                       BorderRadius
//                                                           .circular(
//                                                     7,
//                                                   ),
//                                                 ),
//                                                 child: const Text(
//                                                   'Make Main',
//                                                   textAlign:
//                                                       TextAlign
//                                                           .center,
//                                                   style: TextStyle(
//                                                     color:
//                                                         Colors.white,
//                                                     fontSize: 10,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),

//                             const SizedBox(height: 18),

//                             // ------------------------------------------------
//                             // NAME
//                             // ------------------------------------------------

//                             _field(
//                               nameController,
//                               'Product Name',
//                               Icons.inventory_2_outlined,
//                             ),

//                             const SizedBox(height: 10),

//                             // ------------------------------------------------
//                             // DESCRIPTION
//                             // ------------------------------------------------

//                             _field(
//                               descriptionController,
//                               'Description',
//                               Icons.description_outlined,
//                               maxLines: 4,
//                             ),

//                             const SizedBox(height: 10),

//                             // ------------------------------------------------
//                             // PRICE / STOCK
//                             // ------------------------------------------------

//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _field(
//                                     priceController,
//                                     'Price',
//                                     Icons.payments_outlined,
//                                     keyboardType:
//                                         const TextInputType
//                                             .numberWithOptions(
//                                       decimal: true,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                   child: _field(
//                                     stockController,
//                                     'Stock',
//                                     Icons.inventory_outlined,
//                                     keyboardType:
//                                         TextInputType.number,
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 10),

//                             // ------------------------------------------------
//                             // CURRENCY / CATEGORY
//                             // ------------------------------------------------

//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _field(
//                                     currencyController,
//                                     'Currency',
//                                     Icons
//                                         .currency_exchange_rounded,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                   child:
//                                       DropdownButtonFormField<
//                                           String>(
//                                     value: selectedCategory,
//                                     dropdownColor: _panel2,
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                     ),
//                                     decoration:
//                                         _decoration(
//                                       'Category',
//                                       Icons.category_outlined,
//                                     ),
//                                     items: _categories
//                                         .map(
//                                           (category) =>
//                                               DropdownMenuItem<
//                                                   String>(
//                                             value: category,
//                                             child:
//                                                 Text(category),
//                                           ),
//                                         )
//                                         .toList(),
//                                     onChanged: isSaving
//                                         ? null
//                                         : (value) {
//                                             if (value == null) {
//                                               return;
//                                             }

//                                             setDialogState(() {
//                                               selectedCategory =
//                                                   value;
//                                             });
//                                           },
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 10),

//                             // ------------------------------------------------
//                             // AVAILABLE
//                             // ------------------------------------------------

//                             Container(
//                               decoration: BoxDecoration(
//                                 color: _panel2,
//                                 borderRadius:
//                                     BorderRadius.circular(
//                                   12,
//                                 ),
//                               ),
//                               child: SwitchListTile(
//                                 value: isAvailable,
//                                 onChanged: isSaving
//                                     ? null
//                                     : (value) {
//                                         setDialogState(() {
//                                           isAvailable =
//                                               value;
//                                         });
//                                       },
//                                 activeColor: _purple,
//                                 title: const Text(
//                                   'Available',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight:
//                                         FontWeight.w600,
//                                   ),
//                                 ),
//                                 subtitle: Text(
//                                   isAvailable
//                                       ? 'Visible and available for purchase'
//                                       : 'Currently unavailable',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: 16),

//                             // ------------------------------------------------
//                             // SAVE
//                             // ------------------------------------------------

//                             SizedBox(
//                               width: double.infinity,
//                               height: 48,
//                               child: ElevatedButton(
//                                 onPressed:
//                                     isSaving
//                                         ? null
//                                         : saveChanges,
//                                 style: ElevatedButton
//                                     .styleFrom(
//                                   backgroundColor:
//                                       _purple,
//                                   foregroundColor:
//                                       Colors.white,
//                                   shape:
//                                       RoundedRectangleBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(
//                                       12,
//                                     ),
//                                   ),
//                                 ),
//                                 child: isSaving
//                                     ? const SizedBox(
//                                         width: 20,
//                                         height: 20,
//                                         child:
//                                             CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           color:
//                                               Colors.white,
//                                         ),
//                                       )
//                                     : const Text(
//                                         'Save Changes',
//                                         style: TextStyle(
//                                           fontWeight:
//                                               FontWeight.bold,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );

//     nameController.dispose();
//     descriptionController.dispose();
//     priceController.dispose();
//     stockController.dispose();
//     currencyController.dispose();
//   }

//   bool _sameImageList(
//     List<String> first,
//     List<String> second,
//   ) {
//     if (first.length != second.length) {
//       return false;
//     }

//     for (var i = 0; i < first.length; i++) {
//       if (first[i] != second[i]) {
//         return false;
//       }
//     }

//     return true;
//   }

//   // ============================================================
//   // DELETE
//   // ============================================================

//   Future<void> _deleteProduct(
//     QueryDocumentSnapshot<Map<String, dynamic>> product,
//   ) async {
//     final name =
//         '${product.data()['name'] ?? 'this product'}';

//     final confirmed = await _showConfirmation(
//       title: 'Delete Product?',
//       message:
//           'Delete "$name"? This action cannot be undone.',
//       confirmText: 'Delete',
//       danger: true,
//     );

//     if (!confirmed) {
//       return;
//     }

//     try {
//       await _firestore
//           .collection('products')
//           .doc(product.id)
//           .delete();

//       _snack(
//         'Product deleted successfully.',
//       );

//       await _loadProducts();
//     } catch (e) {
//       _snack(
//         'Failed to delete product: $e',
//         error: true,
//       );
//     }
//   }

//   // ============================================================
//   // CONFIRMATION
//   // ============================================================

//   Future<bool> _showConfirmation({
//     required String title,
//     required String message,
//     required String confirmText,
//     required bool danger,
//   }) async {
//     return await showDialog<bool>(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               backgroundColor: _panel,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               title: Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               content: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white70,
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context, false);
//                   },
//                   child: const Text(
//                     'Cancel',
//                     style: TextStyle(
//                       color: Colors.white60,
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context, true);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                         danger ? Colors.redAccent : _purple,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: Text(confirmText),
//                 ),
//               ],
//             );
//           },
//         ) ??
//         false;
//   }

//   // ============================================================
//   // UI HELPERS
//   // ============================================================

//   InputDecoration _decoration(
//     String label,
//     IconData icon,
//   ) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: const TextStyle(
//         color: Colors.white54,
//       ),
//       prefixIcon: Icon(
//         icon,
//         color: _purpleLight,
//       ),
//       filled: true,
//       fillColor: _panel2,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Colors.white10,
//         ),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Colors.white10,
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: _purple,
//         ),
//       ),
//     );
//   }

//   Widget _field(
//     TextEditingController controller,
//     String label,
//     IconData icon, {
//     int maxLines = 1,
//     TextInputType? keyboardType,
//   }) {
//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboardType,
//       style: const TextStyle(
//         color: Colors.white,
//       ),
//       decoration: _decoration(
//         label,
//         icon,
//       ),
//     );
//   }

//   Widget _badge(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 7,
//         vertical: 4,
//       ),
//       decoration: BoxDecoration(
//         color: _purple,
//         borderRadius: BorderRadius.circular(7),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 9,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   void _snack(
//     String message, {
//     bool error = false,
//   }) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor:
//             error ? Colors.redAccent : null,
//       ),
//     );
//   }

//   // ============================================================
//   // PRODUCT CARD
//   // ============================================================

//   Widget _productCard(
//     QueryDocumentSnapshot<Map<String, dynamic>> product,
//   ) {
//     final data = product.data();

//     final images = _imagesFrom(data);

//     // imageurls[0] is ALWAYS the card/main image.
//     final String? mainImage =
//         images.isEmpty ? null : images.first;

//     final name =
//         '${data['name'] ?? 'Unnamed Product'}';

//     final description =
//         '${data['desc'] ?? ''}';

//     final currency =
//         '${data['currency'] ?? 'PKR'}';

//     final price =
//         '${data['price'] ?? 0}';

//     final stock = _stockFrom(data);

//     final category =
//         _categoryFrom(data);

//     final available =
//         data['isavailable'] == true;

//     return Container(
//       decoration: BoxDecoration(
//         color: _panel,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Colors.white10,
//         ),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         children: [
//           // ------------------------------------------------------
//           // MAIN PRODUCT IMAGE
//           // ------------------------------------------------------

//           SizedBox(
//             height: 180,
//             width: double.infinity,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 _buildImage(mainImage),

//                 Positioned(
//                   left: 8,
//                   top: 8,
//                   child: _badge(
//                     available ? 'AVAILABLE' : 'OFF',
//                   ),
//                 ),

//                 if (images.isNotEmpty)
//                   Positioned(
//                     right: 8,
//                     bottom: 8,
//                     child: Container(
//                       padding:
//                           const EdgeInsets.symmetric(
//                         horizontal: 7,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.black87,
//                         borderRadius:
//                             BorderRadius.circular(7),
//                       ),
//                       child: Row(
//                         mainAxisSize:
//                             MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             Icons.photo_library_outlined,
//                             color: Colors.white,
//                             size: 13,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '${images.length}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           // ------------------------------------------------------
//           // DETAILS
//           // ------------------------------------------------------

//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         name,
//                         maxLines: 1,
//                         overflow:
//                             TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 15,
//                           fontWeight:
//                               FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Flexible(
//                       child: Text(
//                         category,
//                         maxLines: 1,
//                         overflow:
//                             TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: _purpleLight,
//                           fontSize: 10,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 if (description.isNotEmpty) ...[
//                   const SizedBox(height: 5),
//                   Text(
//                     description,
//                     maxLines: 2,
//                     overflow:
//                         TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 11,
//                       height: 1.35,
//                     ),
//                   ),
//                 ],

//                 const SizedBox(height: 9),

//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         '$currency $price',
//                         style: const TextStyle(
//                           color: Color(0xFFE0B45A),
//                           fontWeight:
//                               FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       'Stock: $stock',
//                       style: const TextStyle(
//                         color: Colors.white60,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 10),

//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () {
//                           _editProduct(product);
//                         },
//                         style: OutlinedButton
//                             .styleFrom(
//                           foregroundColor:
//                               _purpleLight,
//                           side: const BorderSide(
//                             color: _purple,
//                           ),
//                           minimumSize:
//                               const Size(0, 40),
//                           padding: EdgeInsets.zero,
//                           shape:
//                               RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(
//                               9,
//                             ),
//                           ),
//                         ),
//                         child: const Icon(
//                           Icons.edit_outlined,
//                           size: 18,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () {
//                           _deleteProduct(product);
//                         },
//                         style: OutlinedButton
//                             .styleFrom(
//                           foregroundColor:
//                               Colors.redAccent,
//                           side: BorderSide(
//                             color: Colors.redAccent
//                                 .withOpacity(.45),
//                           ),
//                           minimumSize:
//                               const Size(0, 40),
//                           padding: EdgeInsets.zero,
//                           shape:
//                               RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(
//                               9,
//                             ),
//                           ),
//                         ),
//                         child: const Icon(
//                           Icons.delete_outline,
//                           size: 18,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final search = _search.trim().toLowerCase();

//     final visibleProducts =
//         _products.where((product) {
//       if (search.isEmpty) {
//         return true;
//       }

//       final data = product.data();

//       final name =
//           '${data['name'] ?? ''}'.toLowerCase();

//       final category =
//           _categoryFrom(data).toLowerCase();

//       return name.contains(search) ||
//           category.contains(search);
//     }).toList();

//     return Scaffold(
//       backgroundColor: _bg,

//       // Existing project AdminDrawer.
//       drawer: AdminDrawer(
//         onProducts: () {
//           Navigator.pop(context);
//         },
//       ),

//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final bool compact =
//                 constraints.maxWidth < 500;

//             // Pixel 8 portrait is narrow enough that the
//             // card layout must be carefully sized.
//             final bool twoColumns =
//                 constraints.maxWidth >= 360;

//             return Column(
//               children: [
//                 // --------------------------------------------------
//                 // HEADER
//                 // --------------------------------------------------

//                 Padding(
//                   padding: EdgeInsets.fromLTRB(
//                     compact ? 8 : 22,
//                     10,
//                     compact ? 8 : 22,
//                     7,
//                   ),
//                   child: Row(
//                     children: [
//                       Builder(
//                         builder: (context) {
//                           return IconButton(
//                             tooltip: 'Admin menu',
//                             onPressed: () {
//                               Scaffold.of(context)
//                                   .openDrawer();
//                             },
//                             icon: const Icon(
//                               Icons.menu_rounded,
//                               color: Colors.white,
//                             ),
//                           );
//                         },
//                       ),

//                       const SizedBox(width: 2),

//                       const Expanded(
//                         child: Text(
//                           'Manage Products',
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 19,
//                             fontWeight:
//                                 FontWeight.bold,
//                           ),
//                         ),
//                       ),

                      

//                       const SizedBox(width: 2),

//                       // IMPORTANT:
//                       // This is deliberately NOT Expanded.
//                       // It stays a small button on Pixel 8.
//                       SizedBox(
//                         height: 36,
//                         child: ElevatedButton.icon(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) =>
//                                     const AddProductScreen(),
//                               ),
//                             ).then((_) {
//                               _loadProducts();
//                             });
//                           },
//                           icon: const Icon(
//                             Icons.add,
//                             size: 16,
//                           ),
//                           label: const Text(
//                             'Add',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight:
//                                   FontWeight.w600,
//                             ),
//                           ),
//                           style: ElevatedButton
//                               .styleFrom(
//                             backgroundColor:
//                                 _purple,
//                             foregroundColor:
//                                 Colors.white,
//                             padding:
//                                 const EdgeInsets
//                                     .symmetric(
//                               horizontal: 10,
//                             ),
//                             minimumSize:
//                                 const Size(0, 36),
//                             tapTargetSize:
//                                 MaterialTapTargetSize
//                                     .shrinkWrap,
//                             shape:
//                                 RoundedRectangleBorder(
//                               borderRadius:
//                                   BorderRadius.circular(
//                                 9,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // --------------------------------------------------
//                 // SEARCH
//                 // --------------------------------------------------

//                 Padding(
//                   padding:
//                       EdgeInsets.symmetric(
//                     horizontal:
//                         compact ? 12 : 22,
//                     vertical: 5,
//                   ),
//                   child: TextField(
//                     onChanged: (value) {
//                       setState(() {
//                         _search = value;
//                       });
//                     },
//                     style: const TextStyle(
//                       color: Colors.white,
//                     ),
//                     decoration: _decoration(
//                       'Search by name or category',
//                       Icons.search_rounded,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 5),

//                 // --------------------------------------------------
//                 // PRODUCT GRID
//                 // --------------------------------------------------

//                 Expanded(
//                   child: _loading
//                       ? const Center(
//                           child:
//                               CircularProgressIndicator(
//                             color: _purple,
//                           ),
//                         )
//                       : visibleProducts.isEmpty
//                           ? _emptyState()
//                           : RefreshIndicator(
//                               color: _purple,
//                               onRefresh:
//                                   _loadProducts,
//                               child: GridView.builder(
//                                 padding:
//                                     EdgeInsets.fromLTRB(
//                                   compact
//                                       ? 12
//                                       : 22,
//                                   8,
//                                   compact
//                                       ? 12
//                                       : 22,
//                                   24,
//                                 ),
//                                 gridDelegate:
//                                     SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount:
//                                       twoColumns
//                                           ? 2
//                                           : 1,
//                                   crossAxisSpacing:
//                                       10,
//                                   mainAxisSpacing:
//                                       10,

//                                   // Pixel 8 portrait:
//                                   // two compact cards per row.
//                                   childAspectRatio:
//                                       compact
//                                           ? 0.67
//                                           : 0.78,
//                                 ),
//                                 itemCount:
//                                     visibleProducts
//                                         .length,
//                                 itemBuilder:
//                                     (context, index) {
//                                   return _productCard(
//                                     visibleProducts[
//                                         index],
//                                   );
//                                 },
//                               ),
//                             ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _emptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment:
//             MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.inventory_2_outlined,
//             color: Colors.white24,
//             size: 55,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             _search.isEmpty
//                 ? 'No products yet'
//                 : 'No products found',
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 17,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }












import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fandom_verse/screens/admin/admin_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  String _searchQuery = '';

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _products = [];

  // Change these according to your project's actual categories.
  final List<String> _categories = [
    'Figures',
    'Clothing',
    'Accessories',
    'Collectibles',
    'Books',
    'Posters',
    'Toys',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // ============================================================
  // FETCH PRODUCTS
  // ============================================================

  Future<void> _fetchProducts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      if (!mounted) return;

      setState(() {
        _products = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback in case createdAt is missing on any old document.
      try {
        final snapshot =
            await _firestore.collection('products').get();

        if (!mounted) return;

        setState(() {
          _products = snapshot.docs;
          _isLoading = false;
        });
      } catch (error) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        _showError('Failed to fetch products: $error');
      }
    }
  }

  // ============================================================
  // IMAGE HELPERS
  // ============================================================

  Uint8List? _decodeBase64Image(dynamic value) {
    if (value == null) return null;

    try {
      String base64String = value.toString();

      // Supports:
      // data:image/png;base64,xxxx
      // and normal xxxx base64
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }

      return base64Decode(base64String);
    } catch (_) {
      return null;
    }
  }

  Widget _buildBase64Image(
    dynamic imageData, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    final bytes = _decodeBase64Image(imageData);

    if (bytes == null) {
      return Container(
        width: width,
        height: height,
        color: const Color(0xFF1A1E2D),
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white38,
          size: 42,
        ),
      );
    }

    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) {
        return Container(
          width: width,
          height: height,
          color: const Color(0xFF1A1E2D),
          child: const Icon(
            Icons.broken_image_outlined,
            color: Colors.white38,
            size: 42,
          ),
        );
      },
    );
  }

  Future<List<String>> _pickImages() async {
    try {
      final List<XFile> pickedImages = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      if (pickedImages.isEmpty) {
        return [];
      }

      final List<String> base64Images = [];

      for (final image in pickedImages) {
        final bytes = await image.readAsBytes();

        if (bytes.isNotEmpty) {
          base64Images.add(base64Encode(bytes));
        }
      }

      return base64Images;
    } catch (e) {
      _showError('Unable to select images: $e');
      return [];
    }
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  Future<void> _confirmDelete(
    QueryDocumentSnapshot<Map<String, dynamic>> product,
  ) async {
    final data = product.data();

    final String name =
        (data['name'] ?? 'Unnamed Product').toString();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111522),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Delete Product?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "$name"?\n\n'
            'This action cannot be undone.',
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully'),
        ),
      );

      await _fetchProducts();
    } catch (e) {
      _showError('Failed to delete product: $e');
    }
  }

  // ============================================================
  // EDIT CONFIRMATION
  // ============================================================

  Future<void> _confirmEdit(
    QueryDocumentSnapshot<Map<String, dynamic>> product,
  ) async {
    final data = product.data();

    final String name =
        (data['name'] ?? 'Unnamed Product').toString();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111522),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Edit Product?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Do you want to edit "$name"?',
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C5CFC),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await _showEditProductDialog(product);
  }

  // ============================================================
  // EDIT PRODUCT DIALOG
  // ============================================================

  Future<void> _showEditProductDialog(
    QueryDocumentSnapshot<Map<String, dynamic>> product,
  ) async {
    final data = product.data();

    final nameController = TextEditingController(
      text: (data['name'] ?? '').toString(),
    );

    final descriptionController = TextEditingController(
      text: (data['description'] ?? '').toString(),
    );

    final priceController = TextEditingController(
      text: (data['price'] ?? '').toString(),
    );

    final stockController = TextEditingController(
      text: (data['stock'] ?? '').toString(),
    );

    final currencyController = TextEditingController(
      text: (data['currency'] ?? 'PKR').toString(),
    );

    String selectedCategory =
        (data['category'] ?? '').toString();

    // Keep an existing category even if it is not currently
    // included in the hard-coded category list.
    if (selectedCategory.isEmpty) {
      selectedCategory = _categories.first;
    }

    final List<String> originalImages =
        List<String>.from(data['imageUrls'] ?? []);

    // IMPORTANT:
    // Copy the images so editing does not modify Firestore data
    // until Save is pressed.
    List<String> editedImages = List<String>.from(originalImages);

    bool isAvailable = data['isavailable'] == true;
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> addImages() async {
              final newImages = await _pickImages();

              if (newImages.isEmpty) return;

              setDialogState(() {
                editedImages.addAll(newImages);
              });
            }

            void removeImage(int index) {
              setDialogState(() {
                editedImages.removeAt(index);
              });
            }

            void moveImageToFirst(int index) {
              if (index == 0) return;

              setDialogState(() {
                final image = editedImages.removeAt(index);
                editedImages.insert(0, image);
              });
            }

            Future<void> saveChanges() async {
              if (nameController.text.trim().isEmpty) {
                _showError('Product name is required');
                return;
              }

              if (priceController.text.trim().isEmpty) {
                _showError('Price is required');
                return;
              }

              if (stockController.text.trim().isEmpty) {
                _showError('Stock is required');
                return;
              }

              if (editedImages.isEmpty) {
                _showError('Please add at least one product image');
                return;
              }

              final double? price = double.tryParse(
                priceController.text.trim(),
              );

              final int? stock = int.tryParse(
                stockController.text.trim(),
              );

              if (price == null) {
                _showError('Enter a valid price');
                return;
              }

              if (stock == null) {
                _showError('Enter a valid stock quantity');
                return;
              }

              setDialogState(() {
                isSaving = true;
              });

              try {
                // IMPORTANT:
                // createdBy is NOT included here.
                // createdAt is NOT modified.
                //
                // Only editable fields are updated.
                await _firestore
                    .collection('products')
                    .doc(product.id)
                    .update({
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'currency':
                      currencyController.text.trim().isEmpty
                          ? 'PKR'
                          : currencyController.text.trim(),
                  'imageUrls': editedImages,
                  'category': selectedCategory,
                  'price': price,
                  'stock': stock,
                  'isavailable': isAvailable,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                if (!mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Product updated successfully',
                    ),
                  ),
                );

                await _fetchProducts();
              } catch (e) {
                setDialogState(() {
                  isSaving = false;
                });

                _showError(
                  'Failed to update product: $e',
                );
              }
            }

            return Dialog(
              backgroundColor: const Color(0xFF111522),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 900,
                  maxHeight: 850,
                ),
                child: Column(
                  children: [
                    // HEADER
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        22,
                        20,
                        14,
                        14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C5CFC)
                                  .withOpacity(.15),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Color(0xFF9D87FF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Edit Product',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(
                                      dialogContext,
                                    ),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      color: Colors.white10,
                      height: 1,
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // ==================================================
                            // IMAGES
                            // ==================================================

                            Row(
                              children: [
                                const Text(
                                  'Product Images',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${editedImages.length} images',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  onPressed:
                                      isSaving ? null : addImages,
                                  icon: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Add Images',
                                  ),
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF7C5CFC),
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            if (editedImages.isEmpty)
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF171B2B),
                                  borderRadius:
                                      BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white10,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      color: Colors.white30,
                                      size: 42,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'No images',
                                      style: TextStyle(
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                itemCount: editedImages.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: .95,
                                ),
                                itemBuilder: (context, index) {
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(
                                          14,
                                        ),
                                        child: _buildBase64Image(
                                          editedImages[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                      // FIRST IMAGE BADGE
                                      if (index == 0)
                                        Positioned(
                                          left: 8,
                                          top: 8,
                                          child: Container(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal: 8,
                                              vertical: 5,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              color:
                                                  const Color(
                                                0xFF7C5CFC,
                                              ),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                8,
                                              ),
                                            ),
                                            child: const Text(
                                              'MAIN',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),

                                      // REMOVE BUTTON
                                      Positioned(
                                        right: 7,
                                        top: 7,
                                        child: InkWell(
                                          onTap: isSaving
                                              ? null
                                              : () =>
                                                  removeImage(
                                                    index,
                                                  ),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration:
                                                const BoxDecoration(
                                              color: Colors.black87,
                                              shape:
                                                  BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons
                                                  .delete_outline_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // MAKE MAIN
                                      if (index != 0)
                                        Positioned(
                                          bottom: 7,
                                          left: 7,
                                          right: 7,
                                          child: InkWell(
                                            onTap: isSaving
                                                ? null
                                                : () =>
                                                    moveImageToFirst(
                                                      index,
                                                    ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                vertical: 7,
                                              ),
                                              decoration:
                                                  BoxDecoration(
                                                color: Colors
                                                    .black87,
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                  8,
                                                ),
                                              ),
                                              child: const Text(
                                                'Make Main',
                                                textAlign:
                                                    TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight
                                                          .w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),

                            const SizedBox(height: 24),

                            // ==================================================
                            // NAME
                            // ==================================================

                            _buildField(
                              controller: nameController,
                              label: 'Product Name',
                              icon: Icons.inventory_2_outlined,
                            ),

                            const SizedBox(height: 14),

                            // ==================================================
                            // DESCRIPTION
                            // ==================================================

                            _buildField(
                              controller: descriptionController,
                              label: 'Description',
                              icon: Icons.description_outlined,
                              maxLines: 4,
                            ),

                            const SizedBox(height: 14),

                            // ==================================================
                            // PRICE + STOCK
                            // ==================================================

                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 550) {
                                  return Column(
                                    children: [
                                      _buildField(
                                        controller:
                                            priceController,
                                        label: 'Price',
                                        icon: Icons
                                            .payments_outlined,
                                        keyboardType:
                                            const TextInputType
                                                .numberWithOptions(
                                          decimal: true,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      _buildField(
                                        controller:
                                            stockController,
                                        label: 'Stock',
                                        icon: Icons
                                            .inventory_outlined,
                                        keyboardType:
                                            TextInputType.number,
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child: _buildField(
                                        controller:
                                            priceController,
                                        label: 'Price',
                                        icon: Icons
                                            .payments_outlined,
                                        keyboardType:
                                            const TextInputType
                                                .numberWithOptions(
                                          decimal: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _buildField(
                                        controller:
                                            stockController,
                                        label: 'Stock',
                                        icon: Icons
                                            .inventory_outlined,
                                        keyboardType:
                                            TextInputType.number,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            // ==================================================
                            // CURRENCY + CATEGORY
                            // ==================================================

                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 550) {
                                  return Column(
                                    children: [
                                      _buildField(
                                        controller:
                                            currencyController,
                                        label: 'Currency',
                                        icon: Icons
                                            .currency_exchange_rounded,
                                      ),
                                      const SizedBox(height: 14),
                                      _buildCategoryDropdown(
                                        selectedCategory,
                                        (value) {
                                          setDialogState(() {
                                            selectedCategory =
                                                value!;
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child: _buildField(
                                        controller:
                                            currencyController,
                                        label: 'Currency',
                                        icon: Icons
                                            .currency_exchange_rounded,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child:
                                          _buildCategoryDropdown(
                                        selectedCategory,
                                        (value) {
                                          setDialogState(() {
                                            selectedCategory =
                                                value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            // ==================================================
                            // AVAILABLE
                            // ==================================================

                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF171B2B),
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white10,
                                ),
                              ),
                              child: SwitchListTile(
                                value: isAvailable,
                                onChanged: isSaving
                                    ? null
                                    : (value) {
                                        setDialogState(() {
                                          isAvailable = value;
                                        });
                                      },
                                activeColor:
                                    const Color(0xFF7C5CFC),
                                title: const Text(
                                  'Product Available',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  isAvailable
                                      ? 'Customers can purchase this product'
                                      : 'Product is currently unavailable',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ==================================================
                            // SAVE
                            // ==================================================

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed:
                                    isSaving ? null : saveChanges,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF7C5CFC),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    currencyController.dispose();
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white54,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF9D87FF),
        ),
        filled: true,
        fillColor: const Color(0xFF171B2B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.white10,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.white10,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF7C5CFC),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY DROPDOWN
  // ============================================================

  Widget _buildCategoryDropdown(
    String value,
    ValueChanged<String?> onChanged,
  ) {
    final List<String> items = List<String>.from(_categories);

    if (!items.contains(value) && value.isNotEmpty) {
      items.insert(0, value);
    }

    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      dropdownColor: const Color(0xFF171B2B),
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: const TextStyle(
          color: Colors.white54,
        ),
        prefixIcon: const Icon(
          Icons.category_outlined,
          color: Color(0xFF9D87FF),
        ),
        filled: true,
        fillColor: const Color(0xFF171B2B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.white10,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.white10,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF7C5CFC),
            width: 1.5,
          ),
        ),
      ),
      items: items
          .map(
            (category) => DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductCard(
    QueryDocumentSnapshot<Map<String, dynamic>> product,
  ) {
    final data = product.data();

    final String name =
        (data['name'] ?? 'Unnamed Product').toString();

    final String description =
        (data['description'] ?? '').toString();

    final String currency =
        (data['currency'] ?? 'PKR').toString();

    final dynamic priceValue = data['price'];

    final String price = priceValue is num
        ? priceValue.toString()
        : priceValue?.toString() ?? '0';

    final dynamic stockValue = data['stock'];

    final String stock = stockValue is num
        ? stockValue.toString()
        : stockValue?.toString() ?? '0';

    final String category =
        (data['category'] ?? 'Other').toString();

    final bool isAvailable =
        data['isavailable'] == true;

    final List<String> images =
        List<String>.from(data['imageUrls'] ?? []);

    // IMPORTANT:
    // imageurls[0] is ALWAYS used as the main card image.
    final dynamic mainImage =
        images.isNotEmpty ? images[0] : null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111522),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white10,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // MAIN IMAGE
          // ======================================================

          AspectRatio(
            aspectRatio: 1.25,
            child: Stack(
              fit: StackFit.expand,
              children: [
                mainImage != null
                    ? _buildBase64Image(
                        mainImage,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: const Color(0xFF171B2B),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.white24,
                          size: 55,
                        ),
                      ),

                // Gradient
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(.55),
                        ],
                      ),
                    ),
                  ),
                ),

                // AVAILABLE BADGE
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? Colors.green.withOpacity(.9)
                          : Colors.redAccent.withOpacity(.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAvailable
                          ? 'AVAILABLE'
                          : 'UNAVAILABLE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // IMAGE COUNT
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.7),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_library_outlined,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // DETAILS
          // ======================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              14,
              13,
              14,
              14,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C5CFC)
                            .withOpacity(.13),
                        borderRadius:
                            BorderRadius.circular(7),
                      ),
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFB9AFFF),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                if (description.isNotEmpty)
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PRICE',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$currency $price',
                            style: const TextStyle(
                              color: Color(0xFFE0B45A),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white10,
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 14),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'STOCK',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              stock,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ==================================================
                // ACTION BUTTONS
                // ==================================================

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _confirmEdit(product),
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 17,
                        ),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              const Color(0xFFB9AFFF),
                          side: const BorderSide(
                            color: Color(0xFF7C5CFC),
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 11,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      height: 43,
                      child: OutlinedButton(
                        onPressed: () =>
                            _confirmDelete(product),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              Colors.redAccent,
                          side: BorderSide(
                            color: Colors.redAccent
                                .withOpacity(.45),
                          ),
                          padding: EdgeInsets.zero,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((product) {
      if (_searchQuery.trim().isEmpty) return true;

      final data = product.data();

      final name =
          (data['name'] ?? '').toString().toLowerCase();

      final category =
          (data['category'] ?? '').toString().toLowerCase();

      final query = _searchQuery.toLowerCase();

      return name.contains(query) || category.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF080A12),
      appBar: AppBar(title: Text("product management")),
      drawer: AdminDrawer(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;

            // Responsive breakpoints.
            // The card grid stays at 2 columns on phone/tablet,
            // then grows on wider screens so cards never become
            // excessively wide.
            final bool phone = width < 600;
            final bool veryNarrow = width < 360;

            final int columns;
            if (width >= 1200) {
              columns = 4;
            } else if (width >= 850) {
              columns = 3;
            } else if (width >= 600) {
              columns = 2;
            } else {
              // Keep 2 cards on Pixel 8 and normal phones.
              // Only extremely narrow devices use one card.
              columns = veryNarrow ? 1 : 2;
            }

            final double horizontalPadding = width >= 1200
                ? 32
                : width >= 850
                    ? 26
                    : phone
                        ? 12
                        : 20;

            final double gap = phone ? 10 : 16;
            final double availableGridWidth =
                width - (horizontalPadding * 2);
            final double cardWidth =
                (availableGridWidth - (gap * (columns - 1))) /
                    columns;

            // The product card contains a 1.25 image plus a
            // variable details section. Instead of a hard-coded
            // childAspectRatio (which causes overflow at some
            // widths), calculate the actual card height from the
            // card width.
            final double imageHeight = cardWidth / 1.25;
            final double detailsHeight = width < 360
                ? 190
                : width < 600
                    ? 196
                    : width < 850
                        ? 200
                        : 208;

            final double cardHeight =
                imageHeight + detailsHeight;

            final double cardAspectRatio = cardWidth / cardHeight;

            return Column(
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    phone ? 12 : 20,
                    horizontalPadding,
                    10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: phone ? 42 : 46,
                        height: phone ? 42 : 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C5CFC)
                              .withOpacity(.14),
                          borderRadius: BorderRadius.circular(
                            phone ? 11 : 13,
                          ),
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: const Color(0xFF9D87FF),
                          size: phone ? 22 : 24,
                        ),
                      ),
                      SizedBox(width: phone ? 10 : 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product Management',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: phone ? 18 : 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_products.length} products',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: phone ? 11 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: phone ? 2 : 8),
                      IconButton(
                        tooltip: 'Refresh',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 42,
                          minHeight: 42,
                        ),
                        onPressed:
                            _isLoading ? null : _fetchProducts,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // SEARCH
                // ==================================================

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 4,
                  ),
                  child: SizedBox(
                    height: phone ? 48 : 52,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Search products or categories...',
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontSize: phone ? 12 : 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF9D87FF),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF111522),
                        contentPadding:
                            EdgeInsets.symmetric(
                          horizontal: phone ? 12 : 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Colors.white10,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Colors.white10,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF7C5CFC),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ==================================================
                // PRODUCTS
                // ==================================================

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF7C5CFC),
                          ),
                        )
                      : filteredProducts.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              color: const Color(0xFF7C5CFC),
                              backgroundColor:
                                  const Color(0xFF111522),
                              onRefresh: _fetchProducts,
                              child: GridView.builder(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  8,
                                  horizontalPadding,
                                  30,
                                ),
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: gap,
                                  mainAxisSpacing: gap,
                                  childAspectRatio: cardAspectRatio,
                                ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  return _buildProductCard(
                                    filteredProducts[index],
                                  );
                                },
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF7C5CFC)
                    .withOpacity(.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF9D87FF),
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _searchQuery.isEmpty
                  ? 'No Products Yet'
                  : 'No Products Found',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              _searchQuery.isEmpty
                  ? 'Products you add will appear here.'
                  : 'Try another product name or category.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}