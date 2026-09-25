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






import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fandom_verse/screens/admin/add_prd_form.dart';
import 'package:fandom_verse/screens/admin/admin_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const Color _backgroundColor = Color(0xFF080A12);
  static const Color _panelColor = Color(0xFF111522);
  static const Color _panelLightColor = Color(0xFF171B2B);
  static const Color _primaryColor = Color(0xFF7C5CFC);
  static const Color _primaryLightColor = Color(0xFF9D87FF);
  static const Color _goldColor = Color(0xFFE0B45A);
  static const Color _whiteColor = Color(0xFFF5F5F7);
  static const Color _mutedColor = Color(0xFF9CA3B5);
  static const Color _borderColor = Color(0xFF272D40);

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _whiteColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Manage Products',
          style: TextStyle(
            color: _whiteColor,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      drawer: AdminDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            const _BackgroundGlow(),
            LayoutBuilder(
              builder: (context, constraints) {
                final double horizontalPadding =
                    constraints.maxWidth < 600 ? 14 : 28;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    30,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1250,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopSection(constraints.maxWidth),
                          const SizedBox(height: 16),
                          _buildSearchBar(),
                          const SizedBox(height: 18),
                          _buildProducts(
                            constraints.maxWidth,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(double width) {
    final bool verySmall = width < 360;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Products',
                style: TextStyle(
                  color: _whiteColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage your products and inventory.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _mutedColor,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildAddButton(verySmall),
      ],
    );
  }

  Widget _buildAddButton(bool iconOnly) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: _openAddProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: iconOnly ? 12 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: iconOnly
            ? const Icon(
                Icons.add_rounded,
                size: 21,
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 19,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Add Item',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _borderColor,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: _whiteColor,
          fontSize: 13,
        ),
        cursorColor: _primaryLightColor,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: const TextStyle(
            color: _mutedColor,
            fontSize: 12,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _primaryLightColor,
            size: 20,
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear',
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: _mutedColor,
                    size: 18,
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildProducts(double width) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(
            snapshot.error.toString(),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final documents = snapshot.data?.docs ?? [];

        final filteredProducts = documents.where((document) {
          final data = document.data();

          final name = _lower(data['name']);
          final category = _lower(data['category']);
          final fandomId = _lower(data['fandomId']);
          final description = _lower(data['description']);

          if (_searchQuery.isEmpty) {
            return true;
          }

          return name.contains(_searchQuery) ||
              category.contains(_searchQuery) ||
              fandomId.contains(_searchQuery) ||
              description.contains(_searchQuery);
        }).toList();

        if (documents.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No products yet',
            message: 'Add your first product to get started.',
            showAddButton: true,
          );
        }

        if (filteredProducts.isEmpty) {
          return _buildEmptyState(
            icon: Icons.search_off_rounded,
            title: 'No products found',
            message: 'Try another search term.',
            showAddButton: false,
          );
        }

        final int crossAxisCount = width >= 1000 ? 4 : 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'All Products',
                  style: TextStyle(
                    color: _whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryColor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    '${filteredProducts.length}',
                    style: const TextStyle(
                      color: _primaryLightColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: width >= 1000 ? 0.88 : 0.78,
              ),
              itemBuilder: (context, index) {
                final document = filteredProducts[index];

                return _buildProductCard(
                  document.id,
                  document.data(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(
    String productId,
    Map<String, dynamic> data,
  ) {
    final String name = _stringValue(
      data['name'],
      'Unnamed Product',
    );

    final String category = _stringValue(
      data['category'],
      'Uncategorized',
    );

    final String currency = _stringValue(
      data['currency'],
      'PKR',
    );

    final double price = _getPrice(data['price']);
    final int stock = _getStock(data['stock']);
    final bool isAvailable = data['isAvailable'] == true;

    final List<String> imageUrls = _getImageUrls(data);

    return Container(
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _borderColor,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: _buildImageGallery(
              imageUrls,
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                11,
                9,
                11,
                9,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _whiteColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      _buildActionButtons(
                        productId,
                        data,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _primaryLightColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$currency ${price.toStringAsFixed(0)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _goldColor,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _buildAvailabilityBadge(
                        isAvailable,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        color: _mutedColor,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stock $stock',
                        style: const TextStyle(
                          color: _mutedColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (imageUrls.isNotEmpty)
                        Text(
                          '${imageUrls.length} photos',
                          style: const TextStyle(
                            color: _mutedColor,
                            fontSize: 9,
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
    );
  }

  Widget _buildImageGallery(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        width: double.infinity,
        color: _backgroundColor,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: _mutedColor,
            size: 32,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  color: _backgroundColor,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: _mutedColor,
                      size: 30,
                    ),
                  ),
                );
              },
              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return Container(
                  color: _backgroundColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _primaryLightColor,
                    ),
                  ),
                );
              },
            );
          },
        ),
        if (imageUrls.length > 1)
          Positioned(
            right: 7,
            top: 7,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white,
                    size: 11,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(
    String productId,
    Map<String, dynamic> data,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _smallIconButton(
          icon: Icons.edit_rounded,
          color: _primaryLightColor,
          tooltip: 'Edit',
          onPressed: () {
            _openEditProduct(
              productId,
              data,
            );
          },
        ),
        const SizedBox(width: 3),
        _smallIconButton(
          icon: Icons.delete_outline_rounded,
          color: Colors.redAccent,
          tooltip: 'Delete',
          onPressed: () {
            _confirmDelete(
              productId,
              _stringValue(
                data['name'],
                'this product',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _smallIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              color: color,
              size: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityBadge(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isAvailable
            ? Colors.greenAccent.withValues(alpha: 0.08)
            : Colors.redAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isAvailable ? 'Available' : 'Off',
        style: TextStyle(
          color: isAvailable
              ? Colors.greenAccent
              : Colors.redAccent,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Future<void> _openEditProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    final bool? updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _EditProductDialog(
          productId: productId,
          data: data,
        );
      },
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product updated successfully.',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    String productId,
    String productName,
  ) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _panelColor,
          title: const Text(
            'Delete Product?',
            style: TextStyle(
              color: _whiteColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "$productName"?\n\nThis action cannot be undone.',
            style: const TextStyle(
              color: _mutedColor,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: _mutedColor,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 17,
              ),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product deleted successfully.',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Delete failed: $error',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );
  }

  String _lower(dynamic value) {
    return value?.toString().toLowerCase() ?? '';
  }

  String _stringValue(
    dynamic value,
    String fallback,
  ) {
    final result = value?.toString().trim() ?? '';

    return result.isEmpty ? fallback : result;
  }

  int _getStock(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  double _getPrice(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  List<String> _getImageUrls(
    Map<String, dynamic> data,
  ) {
    final List<String> result = [];

    final dynamic imageUrlsValue = data['imageUrls'];

    if (imageUrlsValue is List) {
      for (final item in imageUrlsValue) {
        final url = item?.toString().trim() ?? '';

        if (url.isNotEmpty && !result.contains(url)) {
          result.add(url);
        }
      }
    }

    final String oldImageUrl =
        data['imageUrl']?.toString().trim() ?? '';

    if (oldImageUrl.isNotEmpty &&
        !result.contains(oldImageUrl)) {
      result.insert(0, oldImageUrl);
    }

    return result;
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      width: double.infinity,
      height: 250,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _primaryLightColor,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 40,
          ),
          const SizedBox(height: 10),
          const Text(
            'Could not load products',
            style: TextStyle(
              color: _whiteColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _mutedColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required bool showAddButton,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 55,
      ),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _borderColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: _primaryLightColor,
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: _whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _mutedColor,
              fontSize: 12,
            ),
          ),
          if (showAddButton) ...[
            const SizedBox(height: 18),
            _buildAddButton(false),
          ],
        ],
      ),
    );
  }
}

class _EditProductDialog extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> data;

  const _EditProductDialog({
    required this.productId,
    required this.data,
  });

  @override
  State<_EditProductDialog> createState() =>
      _EditProductDialogState();
}

class _EditProductDialogState extends State<_EditProductDialog> {
  static const Color _backgroundColor = Color(0xFF080A12);
  static const Color _panelColor = Color(0xFF111522);
  static const Color _primaryColor = Color(0xFF7C5CFC);
  static const Color _primaryLightColor = Color(0xFF9D87FF);
  static const Color _goldColor = Color(0xFFE0B45A);
  static const Color _whiteColor = Color(0xFFF5F5F7);
  static const Color _mutedColor = Color(0xFF9CA3B5);
  static const Color _borderColor = Color(0xFF272D40);

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _categoryController;
  late final TextEditingController _fandomIdController;
  late final TextEditingController _stockController;

  final ImagePicker _imagePicker = ImagePicker();

  List<String> _existingImageUrls = [];
  final List<XFile> _newImages = [];

  bool _isAvailable = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: _stringValue(widget.data['name']),
    );

    _descriptionController = TextEditingController(
      text: _stringValue(widget.data['description']),
    );

    _priceController = TextEditingController(
      text: _numberString(widget.data['price']),
    );

    _currencyController = TextEditingController(
      text: _stringValue(
        widget.data['currency'],
        fallback: 'PKR',
      ),
    );

    _categoryController = TextEditingController(
      text: _stringValue(widget.data['category']),
    );

    _fandomIdController = TextEditingController(
      text: _stringValue(widget.data['fandomId']),
    );

    _stockController = TextEditingController(
      text: _numberString(widget.data['stock']),
    );

    _isAvailable = widget.data['isAvailable'] == true;

    _existingImageUrls = _getImageUrls(
      widget.data,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _categoryController.dispose();
    _fandomIdController.dispose();
    _stockController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 20,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isSmall =
              constraints.maxWidth < 600;

          return Container(
            width: 760,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.92,
            ),
            decoration: BoxDecoration(
              color: _panelColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _borderColor,
              ),
            ),
            child: Column(
              children: [
                _buildDialogHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      isSmall ? 16 : 24,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            'Product Information',
                          ),
                          const SizedBox(height: 12),
                          _buildResponsiveFields(
                            isSmall,
                          ),
                          const SizedBox(height: 22),
                          _buildSectionTitle(
                            'Product Images',
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Existing images are shown below. Remove old images or add new ones.',
                            style: TextStyle(
                              color: _mutedColor,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildImagesGrid(
                            isSmall,
                          ),
                          const SizedBox(height: 12),
                          _buildAddImagesButton(),
                          const SizedBox(height: 20),
                          _buildAvailability(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildDialogActions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        14,
        18,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor.withValues(alpha: 0.35),
        border: const Border(
          bottom: BorderSide(
            color: _borderColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: _primaryLightColor,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Edit Product',
              style: TextStyle(
                color: _whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: _isSaving
                ? null
                : () {
                    Navigator.pop(context);
                  },
            icon: const Icon(
              Icons.close_rounded,
              color: _mutedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _whiteColor,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildResponsiveFields(bool isSmall) {
    if (isSmall) {
      return Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Product Name',
            icon: Icons.shopping_bag_outlined,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Enter product name';
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            icon: Icons.description_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _categoryController,
            label: 'Category',
            icon: Icons.category_outlined,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Enter category';
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _fandomIdController,
            label: 'Fandom ID',
            icon: Icons.auto_awesome_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _priceController,
                  label: 'Price',
                  icon: Icons.payments_outlined,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Required';
                    }

                    if (double.tryParse(
                          value.trim(),
                        ) ==
                        null) {
                      return 'Invalid';
                    }

                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  controller: _currencyController,
                  label: 'Currency',
                  icon: Icons.currency_exchange_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _stockController,
            label: 'Stock',
            icon: Icons.inventory_2_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Required';
              }

              if (int.tryParse(
                    value.trim(),
                  ) ==
                  null) {
                return 'Invalid';
              }

              return null;
            },
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _nameController,
                label: 'Product Name',
                icon: Icons.shopping_bag_outlined,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter product name';
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _categoryController,
                label: 'Category',
                icon: Icons.category_outlined,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter category';
                  }

                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          icon: Icons.description_outlined,
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _fandomIdController,
                label: 'Fandom ID',
                icon: Icons.auto_awesome_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _stockController,
                label: 'Stock',
                icon: Icons.inventory_2_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Required';
                  }

                  if (int.tryParse(
                        value.trim(),
                      ) ==
                      null) {
                    return 'Invalid';
                  }

                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _priceController,
                label: 'Price',
                icon: Icons.payments_outlined,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Required';
                  }

                  if (double.tryParse(
                        value.trim(),
                      ) ==
                      null) {
                    return 'Invalid';
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _currencyController,
                label: 'Currency',
                icon: Icons.currency_exchange_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: _whiteColor,
        fontSize: 13,
      ),
      cursorColor: _primaryLightColor,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: _mutedColor,
          fontSize: 12,
        ),
        prefixIcon: Icon(
          icon,
          color: _primaryLightColor,
          size: 19,
        ),
        filled: true,
        fillColor: _backgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _borderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _primaryColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildImagesGrid(bool isSmall) {
    final int totalImages =
        _existingImageUrls.length + _newImages.length;

    if (totalImages == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 30,
        ),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _borderColor,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              color: _mutedColor,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'No images selected',
              style: TextStyle(
                color: _mutedColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalImages,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index < _existingImageUrls.length) {
          return _buildExistingImage(
            index,
            _existingImageUrls[index],
          );
        }

        final int newIndex =
            index - _existingImageUrls.length;

        return _buildNewImage(
          newIndex,
          _newImages[newIndex],
        );
      },
    );
  }

  Widget _buildExistingImage(
    int index,
    String url,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return Container(
                color: _backgroundColor,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: _mutedColor,
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: _imageRemoveButton(
            onPressed: () {
              setState(() {
                _existingImageUrls.removeAt(index);
              });
            },
          ),
        ),
        if (index == 0)
          Positioned(
            left: 6,
            bottom: 6,
            child: _mainImageLabel(),
          ),
      ],
    );
  }

  Widget _buildNewImage(
    int index,
    XFile image,
  ) {
    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _primaryLightColor,
              ),
            ),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: _imageRemoveButton(
                onPressed: () {
                  setState(() {
                    _newImages.removeAt(index);
                  });
                },
              ),
            ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _imageRemoveButton({
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.70),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 15,
          ),
        ),
      ),
    );
  }

  Widget _mainImageLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'MAIN',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildAddImagesButton() {
    return OutlinedButton.icon(
      onPressed: _isSaving
          ? null
          : _pickAdditionalImages,
      icon: const Icon(
        Icons.add_photo_alternate_outlined,
        size: 18,
      ),
      label: const Text(
        'Add More Images',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryLightColor,
        side: BorderSide(
          color: _primaryColor.withValues(alpha: 0.45),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
      ),
    );
  }

  Widget _buildAvailability() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _borderColor,
        ),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: _isAvailable,
        onChanged: _isSaving
            ? null
            : (value) {
                setState(() {
                  _isAvailable = value;
                });
              },
        activeColor: _primaryLightColor,
        title: const Text(
          'Product Available',
          style: TextStyle(
            color: _whiteColor,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          _isAvailable
              ? 'Customers can purchase this product.'
              : 'Product is currently unavailable.',
          style: const TextStyle(
            color: _mutedColor,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildDialogActions() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: _borderColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isSaving
                ? null
                : () {
                    Navigator.pop(context);
                  },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: _mutedColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _isSaving
                ? null
                : _confirmUpdate,
            icon: _isSaving
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.save_rounded,
                    size: 17,
                  ),
            label: Text(
              _isSaving ? 'Saving...' : 'Update Product',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAdditionalImages() async {
    try {
      final List<XFile> images =
          await _imagePicker.pickMultiImage();

      if (images.isEmpty || !mounted) {
        return;
      }

      setState(() {
        for (final image in images) {
          final bool duplicate =
              _newImages.any(
            (existing) => existing.path == image.path,
          );

          if (!duplicate) {
            _newImages.add(image);
          }
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not select images: $error',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _panelColor,
          title: const Text(
            'Confirm Update',
            style: TextStyle(
              color: _whiteColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to update this product?',
            style: TextStyle(
              color: _mutedColor,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: _mutedColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _updateProduct();
  }

  Future<void> _updateProduct() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final List<String> finalImageUrls =
          List<String>.from(
        _existingImageUrls,
      );

      if (_newImages.isNotEmpty) {
        for (int index = 0;
            index < _newImages.length;
            index++) {
          final XFile image = _newImages[index];

          final Uint8List bytes =
              await image.readAsBytes();

          final String extension =
              _getExtension(image.name);

          final String fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${index}_$extension';

          final Reference storageRef =
              FirebaseStorage.instance
                  .ref()
                  .child('products')
                  .child(widget.productId)
                  .child(fileName);

          final SettableMetadata metadata =
              SettableMetadata(
            contentType: _contentType(extension),
          );

          await storageRef.putData(
            bytes,
            metadata,
          );

          final String downloadUrl =
              await storageRef.getDownloadURL();

          finalImageUrls.add(downloadUrl);
        }
      }

      final double price =
          double.parse(
        _priceController.text.trim(),
      );

      final int stock =
          int.parse(
        _stockController.text.trim(),
      );

      final Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'description':
            _descriptionController.text.trim(),
        'price': price,
        'currency':
            _currencyController.text.trim().isEmpty
                ? 'PKR'
                : _currencyController.text.trim(),
        'category':
            _categoryController.text.trim(),
        'fandomId':
            _fandomIdController.text.trim(),
        'stock': stock,
        'isAvailable': _isAvailable,
        'imageUrls': finalImageUrls,
        'imageUrl': finalImageUrls.isNotEmpty
            ? finalImageUrls.first
            : '',
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy':
            FirebaseAuth.instance.currentUser?.uid,
      };

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update(updateData);

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Update failed: $error',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  String _getExtension(String fileName) {
    final int dotIndex =
        fileName.lastIndexOf('.');

    if (dotIndex == -1) {
      return 'jpg';
    }

    return fileName
        .substring(dotIndex + 1)
        .toLowerCase();
  }

  String _contentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  String _stringValue(
    dynamic value, {
    String fallback = '',
  }) {
    final String result =
        value?.toString().trim() ?? '';

    return result.isEmpty ? fallback : result;
  }

  String _numberString(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is num) {
      return value.toString();
    }

    return value.toString();
  }

  List<String> _getImageUrls(
    Map<String, dynamic> data,
  ) {
    final List<String> result = [];

    final dynamic imageUrls =
        data['imageUrls'];

    if (imageUrls is List) {
      for (final item in imageUrls) {
        final String url =
            item?.toString().trim() ?? '';

        if (url.isNotEmpty &&
            !result.contains(url)) {
          result.add(url);
        }
      }
    }

    final String imageUrl =
        data['imageUrl']?.toString().trim() ?? '';

    if (imageUrl.isNotEmpty &&
        !result.contains(imageUrl)) {
      result.insert(0, imageUrl);
    }

    return result;
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFF7C5CFC,
                ).withValues(alpha: 0.055),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFFE0B45A,
                ).withValues(alpha: 0.025),
              ),
            ),
          ),
        ],
      ),
    );
  }
}