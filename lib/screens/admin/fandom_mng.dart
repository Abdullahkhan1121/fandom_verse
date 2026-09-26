// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';

// class ManageFandomsScreen extends StatefulWidget {
//   const ManageFandomsScreen({super.key});

//   @override
//   State<ManageFandomsScreen> createState() =>
//       _ManageFandomsScreenState();
// }

// class _ManageFandomsScreenState extends State<ManageFandomsScreen> {
//   final FirebaseFirestore _firestore =
//       FirebaseFirestore.instance;

//   final ImagePicker _picker = ImagePicker();

//   final TextEditingController _searchController =
//       TextEditingController();

//   String _searchQuery = '';
//   String _selectedCategory = 'All';

//   final List<String> _categories = [
//     'All',
//     'Anime',
//     'Movies',
//     'TV Shows',
//     'Comics',
//     'Games',
//     'Books',
//     'Music',
//     'Sports',
//     'Superheroes',
//     'Other',
//   ];

//   @override
//   void initState() {
//     super.initState();

//     _searchController.addListener(() {
//       setState(() {
//         _searchQuery =
//             _searchController.text.trim().toLowerCase();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // FIRESTORE STREAM
//   // ============================================================

//   Stream<QuerySnapshot<Map<String, dynamic>>>
//       _fandomStream() {
//     return _firestore
//         .collection('fandoms')
//         .orderBy(
//           'createdAt',
//           descending: true,
//         )
//         .snapshots();
//   }

//   // ============================================================
//   // FILTER FANDOMS
//   // ============================================================

//   List<QueryDocumentSnapshot<Map<String, dynamic>>>
//       _filterFandoms(
//     List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
//   ) {
//     return docs.where((doc) {
//       final data = doc.data();

//       final name =
//           (data['name'] ?? '').toString().toLowerCase();

//       final category =
//           (data['category'] ?? '').toString();

//       final matchesSearch =
//           _searchQuery.isEmpty ||
//           name.contains(_searchQuery) ||
//           category.toLowerCase().contains(_searchQuery);

//       final matchesCategory =
//           _selectedCategory == 'All' ||
//           category == _selectedCategory;

//       return matchesSearch && matchesCategory;
//     }).toList();
//   }

//   // ============================================================
//   // ADD FANDOM
//   // ============================================================

//   void _openAddFandom() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const AddFandomScreen(),
//       ),
//     );
//   }

//   // ============================================================
//   // EDIT CONFIRMATION
//   // ============================================================

//   Future<void> _confirmEdit(
//     DocumentSnapshot<Map<String, dynamic>> document,
//   ) async {
//     final data = document.data();

//     if (data == null) return;

//     final name = data['name'] ?? 'this fandom';

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF171B2B),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: const Text(
//             'Edit Fandom?',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to edit "$name"?',
//             style: const TextStyle(
//               color: Colors.white70,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () =>
//                   Navigator.pop(context, false),
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Colors.white60,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () =>
//                   Navigator.pop(context, true),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     const Color(0xFF7C5CFC),
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Continue'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed != true) return;

//     if (!mounted) return;

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => EditFandomScreen(
//           documentId: document.id,
//           fandomData: data,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // DELETE CONFIRMATION
//   // ============================================================

//   Future<void> _confirmDelete(
//     DocumentSnapshot<Map<String, dynamic>> document,
//   ) async {
//     final data = document.data();

//     if (data == null) return;

//     final name = data['name'] ?? 'this fandom';

//     final confirmed = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF171B2B),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(9),
//                 decoration: BoxDecoration(
//                   color:
//                       Colors.redAccent.withOpacity(.12),
//                   borderRadius:
//                       BorderRadius.circular(10),
//                 ),
//                 child: const Icon(
//                   Icons.delete_outline,
//                   color: Colors.redAccent,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Text(
//                   'Delete Fandom?',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           content: Text(
//             'Are you sure you want to permanently delete "$name"?\n\nThis action cannot be undone.',
//             style: const TextStyle(
//               color: Colors.white70,
//               height: 1.5,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () =>
//                   Navigator.pop(context, false),
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Colors.white60,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () =>
//                   Navigator.pop(context, true),
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

//     if (confirmed != true) return;

//     await _deleteFandom(document.id);
//   }

//   // ============================================================
//   // DELETE FANDOM
//   // ============================================================

//   Future<void> _deleteFandom(String documentId) async {
//     try {
//       await _firestore
//           .collection('fandoms')
//           .doc(documentId)
//           .delete();

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Fandom deleted successfully.',
//           ),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Failed to delete fandom: $e',
//           ),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     }
//   }

//   // ============================================================
//   // TOGGLE ACTIVE STATUS
//   // ============================================================

//   Future<void> _toggleActive(
//     String documentId,
//     bool currentValue,
//   ) async {
//     try {
//       await _firestore
//           .collection('fandoms')
//           .doc(documentId)
//           .update({
//         'isActive': !currentValue,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             currentValue
//                 ? 'Fandom deactivated.'
//                 : 'Fandom activated.',
//           ),
//           backgroundColor:
//               const Color(0xFF7C5CFC),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Failed to update status: $e',
//           ),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     }
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF080A12),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF080A12),
//         elevation: 0,
//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ),
//         title: const Text(
//           'Manage Fandoms',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final isDesktop =
//               constraints.maxWidth >= 900;

//           return StreamBuilder<
//               QuerySnapshot<Map<String, dynamic>>>(
//             stream: _fandomStream(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState ==
//                   ConnectionState.waiting) {
//                 return const Center(
//                   child: CircularProgressIndicator(
//                     color: Color(0xFF7C5CFC),
//                   ),
//                 );
//               }

//               if (snapshot.hasError) {
//                 return _buildError(
//                   snapshot.error.toString(),
//                 );
//               }

//               final docs =
//                   snapshot.data?.docs ?? [];

//               final fandoms =
//                   _filterFandoms(docs);

//               return SingleChildScrollView(
//                 padding: EdgeInsets.all(
//                   isDesktop ? 30 : 16,
//                 ),
//                 child: Center(
//                   child: ConstrainedBox(
//                     constraints:
//                         const BoxConstraints(
//                       maxWidth: 1400,
//                     ),
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         _buildHeader(
//                           total: docs.length,
//                         ),

//                         const SizedBox(height: 25),

//                         _buildSearchArea(
//                           isDesktop,
//                         ),

//                         const SizedBox(height: 25),

//                         if (fandoms.isEmpty)
//                           _buildEmptyState()
//                         else
//                           _buildFandomGrid(
//                             fandoms,
//                             isDesktop,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader({
//     required int total,
//   }) {
//     return Row(
//       crossAxisAlignment:
//           CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Fandoms',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 '$total fandom${total == 1 ? '' : 's'} in your collection',
//                 style: const TextStyle(
//                   color: Colors.white54,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         ElevatedButton.icon(
//           onPressed: _openAddFandom,
//           icon: const Icon(
//             Icons.add,
//             size: 20,
//           ),
//           label: const Text(
//             'Add Fandom',
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor:
//                 const Color(0xFF7C5CFC),
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 15,
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(14),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // SEARCH
//   // ============================================================

//   Widget _buildSearchArea(bool isDesktop) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: const Color(0xFF111522),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: Colors.white.withOpacity(.06),
//         ),
//       ),
//       child: isDesktop
//           ? Row(
//               children: [
//                 Expanded(
//                   child: _buildSearchField(),
//                 ),
//                 const SizedBox(width: 15),
//                 SizedBox(
//                   width: 230,
//                   child: _buildCategoryFilter(),
//                 ),
//               ],
//             )
//           : Column(
//               children: [
//                 _buildSearchField(),
//                 const SizedBox(height: 14),
//                 _buildCategoryFilter(),
//               ],
//             ),
//     );
//   }

//   Widget _buildSearchField() {
//     return TextField(
//       controller: _searchController,
//       style: const TextStyle(
//         color: Colors.white,
//       ),
//       decoration: InputDecoration(
//         hintText:
//             'Search by fandom name or category...',
//         hintStyle: const TextStyle(
//           color: Colors.white38,
//         ),
//         prefixIcon: const Icon(
//           Icons.search,
//           color: Color(0xFF9D87FF),
//         ),
//         suffixIcon:
//             _searchController.text.isNotEmpty
//                 ? IconButton(
//                     onPressed: () {
//                       _searchController.clear();
//                     },
//                     icon: const Icon(
//                       Icons.clear,
//                       color: Colors.white54,
//                     ),
//                   )
//                 : null,
//         filled: true,
//         fillColor: const Color(0xFF171B2B),
//         border: OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(14),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(14),
//           borderSide: BorderSide(
//             color: Colors.white.withOpacity(.06),
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Color(0xFF7C5CFC),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryFilter() {
//     return DropdownButtonFormField<String>(
//       value: _selectedCategory,
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
//           borderRadius:
//               BorderRadius.circular(14),
//           borderSide: BorderSide.none,
//         ),
//       ),
//       items: _categories.map((category) {
//         return DropdownMenuItem<String>(
//           value: category,
//           child: Text(category),
//         );
//       }).toList(),
//       onChanged: (value) {
//         setState(() {
//           _selectedCategory =
//               value ?? 'All';
//         });
//       },
//     );
//   }

//   // ============================================================
//   // FANDOM GRID
//   // ============================================================

//   Widget _buildFandomGrid(
//     List<QueryDocumentSnapshot<Map<String, dynamic>>>
//         fandoms,
//     bool isDesktop,
//   ) {
//     int crossAxisCount;

//     if (!isDesktop) {
//       crossAxisCount = 1;
//     } else if (MediaQuery.of(context).size.width >=
//         1250) {
//       crossAxisCount = 3;
//     } else {
//       crossAxisCount = 2;
//     }

//     return GridView.builder(
//       shrinkWrap: true,
//       physics:
//           const NeverScrollableScrollPhysics(),
//       itemCount: fandoms.length,
//       gridDelegate:
//           SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         crossAxisSpacing: 18,
//         mainAxisSpacing: 18,
//         childAspectRatio:
//             crossAxisCount == 1 ? 2.5 : 1.15,
//       ),
//       itemBuilder: (context, index) {
//         return _buildFandomCard(
//           fandoms[index],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // FANDOM CARD
//   // ============================================================

//   Widget _buildFandomCard(
//     QueryDocumentSnapshot<Map<String, dynamic>>
//         document,
//   ) {
//     final data = document.data();

//     final String name =
//         (data['name'] ?? 'Unnamed Fandom')
//             .toString();

//     final String description =
//         (data['description'] ?? '')
//             .toString();

//     final String category =
//         (data['category'] ?? 'Other')
//             .toString();

//     final String status =
//         (data['status'] ?? 'pending')
//             .toString();

//     final bool isActive =
//         data['isActive'] == true;

//     final String imageUrl =
//         (data['imageUrl'] ?? '')
//             .toString();

//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF111522),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: Colors.white.withOpacity(.06),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.18),
//             blurRadius: 25,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 5,
//             child: Stack(
//               children: [
//                 Positioned.fill(
//                   child: ClipRRect(
//                     borderRadius:
//                         const BorderRadius.vertical(
//                       top: Radius.circular(20),
//                     ),
//                     child: _buildFandomImage(
//                       imageUrl,
//                     ),
//                   ),
//                 ),

//                 Positioned(
//                   top: 12,
//                   left: 12,
//                   child: _badge(
//                     category,
//                     const Color(0xFF7C5CFC),
//                   ),
//                 ),

//                 Positioned(
//                   top: 12,
//                   right: 12,
//                   child: _statusBadge(
//                     status,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Expanded(
//             flex: 4,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           name,
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight:
//                                 FontWeight.bold,
//                           ),
//                         ),
//                       ),

//                       PopupMenuButton<String>(
//                         color:
//                             const Color(0xFF171B2B),
//                         icon: const Icon(
//                           Icons.more_vert,
//                           color: Colors.white54,
//                         ),
//                         onSelected: (value) {
//                           if (value == 'edit') {
//                             _confirmEdit(
//                               document,
//                             );
//                           }

//                           if (value == 'delete') {
//                             _confirmDelete(
//                               document,
//                             );
//                           }
//                         },
//                         itemBuilder: (_) => [
//                           const PopupMenuItem(
//                             value: 'edit',
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.edit_outlined,
//                                   color:
//                                       Color(0xFF9D87FF),
//                                 ),
//                                 SizedBox(width: 10),
//                                 Text(
//                                   'Edit',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const PopupMenuItem(
//                             value: 'delete',
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.delete_outline,
//                                   color:
//                                       Colors.redAccent,
//                                 ),
//                                 SizedBox(width: 10),
//                                 Text(
//                                   'Delete',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 7),

//                   Expanded(
//                     child: Text(
//                       description.isEmpty
//                           ? 'No description available.'
//                           : description,
//                       maxLines: 2,
//                       overflow:
//                           TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         color: Colors.white54,
//                         fontSize: 12,
//                         height: 1.4,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 8),

//                   Row(
//                     children: [
//                       Expanded(
//                         child: Row(
//                           children: [
//                             Icon(
//                               isActive
//                                   ? Icons.check_circle
//                                   : Icons
//                                       .cancel_outlined,
//                               size: 16,
//                               color: isActive
//                                   ? Colors.greenAccent
//                                   : Colors.white38,
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               isActive
//                                   ? 'Active'
//                                   : 'Inactive',
//                               style: TextStyle(
//                                 color: isActive
//                                     ? Colors.greenAccent
//                                     : Colors.white38,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       IconButton(
//                         tooltip: 'Edit fandom',
//                         onPressed: () =>
//                             _confirmEdit(
//                           document,
//                         ),
//                         icon: const Icon(
//                           Icons.edit_outlined,
//                           color:
//                               Color(0xFF9D87FF),
//                           size: 20,
//                         ),
//                       ),

//                       IconButton(
//                         tooltip: 'Delete fandom',
//                         onPressed: () =>
//                             _confirmDelete(
//                           document,
//                         ),
//                         icon: const Icon(
//                           Icons.delete_outline,
//                           color: Colors.redAccent,
//                           size: 20,
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

//   // ============================================================
//   // IMAGE
//   // ============================================================

//   Widget _buildFandomImage(
//     String imageUrl,
//   ) {
//     if (imageUrl.isEmpty) {
//       return _imagePlaceholder();
//     }

//     try {
//       if (imageUrl.startsWith(
//         'data:image',
//       )) {
//         final bytes =
//             _base64ToBytes(imageUrl);

//         return Image.memory(
//           bytes,
//           fit: BoxFit.cover,
//           errorBuilder:
//               (_, __, ___) =>
//                   _imagePlaceholder(),
//         );
//       }

//       return Image.network(
//         imageUrl,
//         fit: BoxFit.cover,
//         errorBuilder:
//             (_, __, ___) =>
//                 _imagePlaceholder(),
//       );
//     } catch (_) {
//       return _imagePlaceholder();
//     }
//   }

//   Widget _imagePlaceholder() {
//     return Container(
//       color: const Color(0xFF171B2B),
//       child: const Center(
//         child: Icon(
//           Icons.auto_awesome,
//           color: Color(0xFF7C5CFC),
//           size: 42,
//         ),
//       ),
//     );
//   }

//   Uint8List _base64ToBytes(
//     String base64Image,
//   ) {
//     final base64String =
//         base64Image.split(',').last;

//     return base64Decode(base64String);
//   }

//   // ============================================================
//   // BADGES
//   // ============================================================

//   Widget _badge(
//     String text,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 10,
//         vertical: 6,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(.65),
//         borderRadius: BorderRadius.circular(9),
//         border: Border.all(
//           color: color.withOpacity(.5),
//         ),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 10,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _statusBadge(
//     String status,
//   ) {
//     Color color;

//     switch (status.toLowerCase()) {
//       case 'approved':
//         color = Colors.greenAccent;
//         break;

//       case 'rejected':
//         color = Colors.redAccent;
//         break;

//       default:
//         color = const Color(0xFFE0B45A);
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 10,
//         vertical: 6,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(.7),
//         borderRadius:
//             BorderRadius.circular(9),
//         border: Border.all(
//           color: color.withOpacity(.5),
//         ),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         style: TextStyle(
//           color: color,
//           fontSize: 9,
//           fontWeight: FontWeight.bold,
//           letterSpacing: .5,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY
//   // ============================================================

//   Widget _buildEmptyState() {
//     final hasFilter =
//         _searchQuery.isNotEmpty ||
//         _selectedCategory != 'All';

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(
//         vertical: 70,
//         horizontal: 20,
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xFF111522),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: Colors.white.withOpacity(.06),
//         ),
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(18),
//             decoration: BoxDecoration(
//               color: const Color(0xFF7C5CFC)
//                   .withOpacity(.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.auto_awesome_outlined,
//               color: Color(0xFF9D87FF),
//               size: 42,
//             ),
//           ),

//           const SizedBox(height: 18),

//           Text(
//             hasFilter
//                 ? 'No fandoms found'
//                 : 'No fandoms yet',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 8),

//           Text(
//             hasFilter
//                 ? 'Try changing your search or category filter.'
//                 : 'Start building your fandom collection.',
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: Colors.white54,
//               fontSize: 13,
//             ),
//           ),

//           if (!hasFilter) ...[
//             const SizedBox(height: 22),
//             ElevatedButton.icon(
//               onPressed: _openAddFandom,
//               icon: const Icon(Icons.add),
//               label: const Text(
//                 'Add First Fandom',
//               ),
//               style:
//                   ElevatedButton.styleFrom(
//                 backgroundColor:
//                     const Color(0xFF7C5CFC),
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // ERROR
//   // ============================================================

//   Widget _buildError(
//     String error,
//   ) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.error_outline,
//               color: Colors.redAccent,
//               size: 55,
//             ),
//             const SizedBox(height: 15),
//             const Text(
//               'Unable to load fandoms',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               error,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white54,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ==================================================================
// // EDIT FANDOM SCREEN
// // ==================================================================

// class EditFandomScreen extends StatefulWidget {
//   final String documentId;
//   final Map<String, dynamic> fandomData;

//   const EditFandomScreen({
//     super.key,
//     required this.documentId,
//     required this.fandomData,
//   });

//   @override
//   State<EditFandomScreen> createState() =>
//       _EditFandomScreenState();
// }

// class _EditFandomScreenState
//     extends State<EditFandomScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final _nameController =
//       TextEditingController();

//   final _descriptionController =
//       TextEditingController();

//   final ImagePicker _picker = ImagePicker();

//   final List<String> _images = [];

//   String? _category;
//   bool _isActive = true;
//   bool _isSaving = false;

//   final List<String> _categories = [
//     'Anime',
//     'Movies',
//     'TV Shows',
//     'Comics',
//     'Games',
//     'Books',
//     'Music',
//     'Sports',
//     'Superheroes',
//     'Other',
//   ];

//   @override
//   void initState() {
//     super.initState();

//     _nameController.text =
//         (widget.fandomData['name'] ?? '')
//             .toString();

//     _descriptionController.text =
//         (widget.fandomData['description'] ?? '')
//             .toString();

//     _category =
//         widget.fandomData['category']
//             ?.toString();

//     _isActive =
//         widget.fandomData['isActive'] == true;

//     final existingImages =
//         widget.fandomData['images'];

//     if (existingImages is List) {
//       _images.addAll(
//         existingImages
//             .map((e) => e.toString())
//             .where((e) => e.isNotEmpty),
//       );
//     }

//     // Backwards compatibility if only imageUrl exists.
//     if (_images.isEmpty) {
//       final mainImage =
//           widget.fandomData['imageUrl']
//               ?.toString();

//       if (mainImage != null &&
//           mainImage.isNotEmpty) {
//         _images.add(mainImage);
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // PICK IMAGES
//   // ============================================================

//   Future<void> _pickImages() async {
//     try {
//       final pickedImages =
//           await _picker.pickMultiImage(
//         imageQuality: 85,
//       );

//       if (pickedImages.isEmpty) return;

//       setState(() {
//         _isSaving = true;
//       });

//       for (final pickedImage in pickedImages) {
//         final bytes =
//             await pickedImage.readAsBytes();

//         final base64Image =
//             await _convertToBase64(bytes);

//         if (base64Image != null) {
//           setState(() {
//             _images.add(base64Image);
//           });
//         }
//       }
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Failed to select images: $e',
//           ),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // BASE64
//   // ============================================================

//   Future<String?> _convertToBase64(
//     Uint8List bytes,
//   ) async {
//     try {
//       final decodedImage =
//           img.decodeImage(bytes);

//       if (decodedImage == null) {
//         return null;
//       }

//       img.Image resizedImage =
//           decodedImage;

//       const maxSize = 1200;

//       if (decodedImage.width > maxSize ||
//           decodedImage.height > maxSize) {
//         resizedImage = img.copyResize(
//           decodedImage,
//           width:
//               decodedImage.width >
//                       decodedImage.height
//                   ? maxSize
//                   : null,
//           height:
//               decodedImage.height >=
//                       decodedImage.width
//                   ? maxSize
//                   : null,
//         );
//       }

//       final compressedBytes =
//           img.encodeJpg(
//         resizedImage,
//         quality: 75,
//       );

//       final base64String =
//           base64Encode(compressedBytes);

//       return 'data:image/jpeg;base64,$base64String';
//     } catch (e) {
//       debugPrint(
//         'Image conversion error: $e',
//       );
//       return null;
//     }
//   }

//   // ============================================================
//   // REMOVE IMAGE
//   // ============================================================

//   void _removeImage(int index) {
//     setState(() {
//       _images.removeAt(index);
//     });
//   }

//   // ============================================================
//   // UPDATE
//   // ============================================================

//   Future<void> _updateFandom() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_category == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         const SnackBar(
//           content:
//               Text('Please select a category'),
//         ),
//       );
//       return;
//     }

//     if (_images.isEmpty) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Please select at least one image',
//           ),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       await FirebaseFirestore.instance
//           .collection('fandoms')
//           .doc(widget.documentId)
//           .update({
//         'name':
//             _nameController.text.trim(),
//         'description':
//             _descriptionController.text.trim(),
//         'imageUrl': _images.first,
//         'images': _images,
//         'category': _category,
//         'isActive': _isActive,
//         'updatedAt':
//             FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Fandom updated successfully.',
//           ),
//           backgroundColor:
//               Color(0xFF7C5CFC),
//         ),
//       );

//       Navigator.pop(context);
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Failed to update fandom: $e',
//           ),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF080A12),
//       appBar: AppBar(
//         backgroundColor:
//             const Color(0xFF080A12),
//         elevation: 0,
//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ),
//         title: const Text(
//           'Edit Fandom',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final isDesktop =
//               constraints.maxWidth >= 900;

//           return SingleChildScrollView(
//             padding: EdgeInsets.all(
//               isDesktop ? 30 : 16,
//             ),
//             child: Center(
//               child: ConstrainedBox(
//                 constraints:
//                     const BoxConstraints(
//                   maxWidth: 1200,
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                     children: [
//                       _buildEditHeader(),

//                       const SizedBox(height: 25),

//                       if (isDesktop)
//                         Row(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child:
//                                   _buildImagesCard(),
//                             ),
//                             const SizedBox(
//                               width: 22,
//                             ),
//                             Expanded(
//                               child: Column(
//                                 children: [
//                                   _buildInfoCard(),
//                                   const SizedBox(
//                                     height: 20,
//                                   ),
//                                   _buildStatusCard(),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         )
//                       else
//                         Column(
//                           children: [
//                             _buildImagesCard(),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             _buildInfoCard(),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             _buildStatusCard(),
//                           ],
//                         ),

//                       const SizedBox(height: 25),

//                       _buildActionButtons(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildEditHeader() {
//     return Column(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Update Fandom',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           'Modify the fandom information and images.',
//           style: TextStyle(
//             color: Colors.white.withOpacity(.5),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // IMAGE CARD
//   // ============================================================

//   Widget _buildImagesCard() {
//     return _card(
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           _sectionTitle(
//             Icons.photo_library_outlined,
//             'Fandom Images',
//           ),

//           const SizedBox(height: 8),

//           const Text(
//             'The first image is used as the main fandom image.',
//             style: TextStyle(
//               color: Colors.white54,
//               fontSize: 12,
//             ),
//           ),

//           const SizedBox(height: 18),

//           if (_images.isEmpty)
//             _emptyImage()
//           else
//             GridView.builder(
//               shrinkWrap: true,
//               physics:
//                   const NeverScrollableScrollPhysics(),
//               itemCount: _images.length,
//               gridDelegate:
//                   const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//               ),
//               itemBuilder:
//                   (context, index) {
//                 return Stack(
//                   children: [
//                     Positioned.fill(
//                       child: ClipRRect(
//                         borderRadius:
//                             BorderRadius.circular(
//                           15,
//                         ),
//                         child: _imageWidget(
//                           _images[index],
//                         ),
//                       ),
//                     ),

//                     if (index == 0)
//                       Positioned(
//                         top: 9,
//                         left: 9,
//                         child: Container(
//                           padding:
//                               const EdgeInsets
//                                   .symmetric(
//                             horizontal: 8,
//                             vertical: 5,
//                           ),
//                           decoration:
//                               BoxDecoration(
//                             color:
//                                 const Color(
//                               0xFFE0B45A,
//                             ),
//                             borderRadius:
//                                 BorderRadius
//                                     .circular(
//                               7,
//                             ),
//                           ),
//                           child: const Text(
//                             'MAIN',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 9,
//                               fontWeight:
//                                   FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),

//                     Positioned(
//                       top: 7,
//                       right: 7,
//                       child: GestureDetector(
//                         onTap: () =>
//                             _removeImage(
//                           index,
//                         ),
//                         child: Container(
//                           padding:
//                               const EdgeInsets
//                                   .all(6),
//                           decoration:
//                               const BoxDecoration(
//                             color: Colors.black87,
//                             shape:
//                                 BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.close,
//                             color: Colors.white,
//                             size: 17,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),

//           const SizedBox(height: 16),

//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed:
//                   _isSaving
//                       ? null
//                       : _pickImages,
//               icon: const Icon(
//                 Icons.add_photo_alternate_outlined,
//               ),
//               label: const Text(
//                 'Add More Images',
//               ),
//               style:
//                   OutlinedButton.styleFrom(
//                 foregroundColor:
//                     const Color(0xFF9D87FF),
//                 side: const BorderSide(
//                   color: Color(0xFF7C5CFC),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(
//                   vertical: 15,
//                 ),
//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(
//                     13,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // INFO CARD
//   // ============================================================

//   Widget _buildInfoCard() {
//     return _card(
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           _sectionTitle(
//             Icons.auto_awesome_outlined,
//             'Fandom Information',
//           ),

//           const SizedBox(height: 20),

//           _textField(
//             controller: _nameController,
//             label: 'Fandom Name',
//             hint: 'Enter fandom name',
//             icon: Icons.movie_filter_outlined,
//             validator: (value) {
//               if (value == null ||
//                   value.trim().isEmpty) {
//                 return 'Please enter fandom name';
//               }

//               return null;
//             },
//           ),

//           const SizedBox(height: 17),

//           _textField(
//             controller:
//                 _descriptionController,
//             label: 'Description',
//             hint: 'Describe this fandom...',
//             icon:
//                 Icons.description_outlined,
//             maxLines: 5,
//             validator: (value) {
//               if (value == null ||
//                   value.trim().isEmpty) {
//                 return 'Please enter description';
//               }

//               return null;
//             },
//           ),

//           const SizedBox(height: 17),

//           DropdownButtonFormField<String>(
//             value: _category,
//             dropdownColor:
//                 const Color(0xFF171B2B),
//             style: const TextStyle(
//               color: Colors.white,
//             ),
//             decoration: _inputDecoration(
//               label: 'Category',
//               hint: 'Select category',
//               icon:
//                   Icons.category_outlined,
//             ),
//             items: _categories
//                 .map(
//                   (category) =>
//                       DropdownMenuItem<String>(
//                     value: category,
//                     child: Text(category),
//                   ),
//                 )
//                 .toList(),
//             onChanged: (value) {
//               setState(() {
//                 _category = value;
//               });
//             },
//             validator: (value) {
//               if (value == null) {
//                 return 'Please select category';
//               }

//               return null;
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // STATUS
//   // ============================================================

//   Widget _buildStatusCard() {
//     final status =
//         (widget.fandomData['status'] ??
//                 'pending')
//             .toString();

//     return _card(
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           _sectionTitle(
//             Icons.settings_outlined,
//             'Fandom Status',
//           ),

//           const SizedBox(height: 16),

//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Active',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight:
//                             FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Control whether this fandom is active.',
//                       style: TextStyle(
//                         color: Colors.white
//                             .withOpacity(.45),
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Switch(
//                 value: _isActive,
//                 activeThumbColor:
//                     const Color(0xFF7C5CFC),
//                 onChanged: (value) {
//                   setState(() {
//                     _isActive = value;
//                   });
//                 },
//               ),
//             ],
//           ),

//           const SizedBox(height: 14),

//           Container(
//             padding:
//                 const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: const Color(0xFF171B2B),
//               borderRadius:
//                   BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.info_outline,
//                   color:
//                       Color(0xFFE0B45A),
//                   size: 19,
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     'Current approval status: ${status.toUpperCase()}',
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // ACTION BUTTONS
//   // ============================================================

//   Widget _buildActionButtons() {
//     return Row(
//       mainAxisAlignment:
//           MainAxisAlignment.end,
//       children: [
//         OutlinedButton(
//           onPressed: _isSaving
//               ? null
//               : () => Navigator.pop(
//                     context,
//                   ),
//           style:
//               OutlinedButton.styleFrom(
//             foregroundColor:
//                 Colors.white70,
//             side: BorderSide(
//               color: Colors.white
//                   .withOpacity(.15),
//             ),
//             padding:
//                 const EdgeInsets.symmetric(
//               horizontal: 25,
//               vertical: 16,
//             ),
//             shape:
//                 RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(13),
//             ),
//           ),
//           child: const Text('Cancel'),
//         ),

//         const SizedBox(width: 12),

//         ElevatedButton.icon(
//           onPressed: _isSaving
//               ? null
//               : _updateFandom,
//           icon: _isSaving
//               ? const SizedBox(
//                   width: 17,
//                   height: 17,
//                   child:
//                       CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.white,
//                   ),
//                 )
//               : const Icon(
//                   Icons.save_outlined,
//                 ),
//           label: Text(
//             _isSaving
//                 ? 'Updating...'
//                 : 'Update Fandom',
//           ),
//           style:
//               ElevatedButton.styleFrom(
//             backgroundColor:
//                 const Color(0xFF7C5CFC),
//             foregroundColor: Colors.white,
//             padding:
//                 const EdgeInsets.symmetric(
//               horizontal: 25,
//               vertical: 16,
//             ),
//             shape:
//                 RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(13),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // IMAGE WIDGET
//   // ============================================================

//   Widget _imageWidget(
//     String image,
//   ) {
//     if (image.startsWith('data:image')) {
//       try {
//         return Image.memory(
//           _base64ToBytes(image),
//           fit: BoxFit.cover,
//           errorBuilder:
//               (_, __, ___) =>
//                   _emptyImage(),
//         );
//       } catch (_) {
//         return _emptyImage();
//       }
//     }

//     return Image.network(
//       image,
//       fit: BoxFit.cover,
//       errorBuilder:
//           (_, __, ___) =>
//               _emptyImage(),
//     );
//   }

//   Uint8List _base64ToBytes(
//     String value,
//   ) {
//     return base64Decode(
//       value.split(',').last,
//     );
//   }

//   Widget _emptyImage() {
//     return Container(
//       color: const Color(0xFF171B2B),
//       child: const Center(
//         child: Icon(
//           Icons.image_outlined,
//           color: Colors.white30,
//           size: 40,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // TEXT FIELD
//   // ============================================================

//   Widget _textField({
//     required TextEditingController
//         controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     int maxLines = 1,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       style: const TextStyle(
//         color: Colors.white,
//       ),
//       validator: validator,
//       decoration: _inputDecoration(
//         label: label,
//         hint: hint,
//         icon: icon,
//       ),
//     );
//   }

//   InputDecoration _inputDecoration({
//     required String label,
//     required String hint,
//     required IconData icon,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       labelStyle: const TextStyle(
//         color: Colors.white60,
//       ),
//       hintStyle: const TextStyle(
//         color: Colors.white30,
//       ),
//       prefixIcon: Icon(
//         icon,
//         color: const Color(0xFF9D87FF),
//       ),
//       filled: true,
//       fillColor: const Color(0xFF111522),
//       border: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(14),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(14),
//         borderSide: BorderSide(
//           color: Colors.white
//               .withOpacity(.06),
//         ),
//       ),
//       focusedBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(14),
//         borderSide: const BorderSide(
//           color: Color(0xFF7C5CFC),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CARD
//   // ============================================================

//   Widget _card({
//     required Widget child,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(21),
//       decoration: BoxDecoration(
//         color: const Color(0xFF111522),
//         borderRadius:
//             BorderRadius.circular(20),
//         border: Border.all(
//           color:
//               Colors.white.withOpacity(.06),
//         ),
//       ),
//       child: child,
//     );
//   }

//   // ============================================================
//   // SECTION TITLE
//   // ============================================================

//   Widget _sectionTitle(
//     IconData icon,
//     String title,
//   ) {
//     return Row(
//       children: [
//         Container(
//           padding:
//               const EdgeInsets.all(9),
//           decoration: BoxDecoration(
//             color: const Color(0xFF7C5CFC)
//                 .withOpacity(.12),
//             borderRadius:
//                 BorderRadius.circular(10),
//           ),
//           child: Icon(
//             icon,
//             color:
//                 const Color(0xFF9D87FF),
//             size: 20,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           title,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 17,
//             fontWeight:
//                 FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // EMPTY IMAGE
//   // ============================================================
// }

// // ==================================================================
// // ADD FANDOM SCREEN
// // ==================================================================
// // This is included so the "Add Fandom" button works.
// // If you already have the AddFandomScreen from the previous message,
// // you can remove this class and keep your existing one.
// // ==================================================================

// class AddFandomScreen extends StatefulWidget {
//   const AddFandomScreen({super.key});

//   @override
//   State<AddFandomScreen> createState() =>
//       _AddFandomScreenState();
// }

// class _AddFandomScreenState
//     extends State<AddFandomScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final _nameController =
//       TextEditingController();

//   final _descriptionController =
//       TextEditingController();

//   final ImagePicker _picker = ImagePicker();

//   final List<String> _images = [];

//   bool _isSaving = false;
//   bool _isActive = true;
//   String? _category;

//   final List<String> _categories = [
//     'Anime',
//     'Movies',
//     'TV Shows',
//     'Comics',
//     'Games',
//     'Books',
//     'Music',
//     'Sports',
//     'Superheroes',
//     'Other',
//   ];

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImages() async {
//     try {
//       final pickedImages =
//           await _picker.pickMultiImage(
//         imageQuality: 85,
//       );

//       if (pickedImages.isEmpty) return;

//       setState(() {
//         _isSaving = true;
//       });

//       for (final pickedImage
//           in pickedImages) {
//         final bytes =
//             await pickedImage.readAsBytes();

//         final base64Image =
//             await _convertToBase64(bytes);

//         if (base64Image != null) {
//           setState(() {
//             _images.add(base64Image);
//           });
//         }
//       }
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Failed to select images: $e',
//           ),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   Future<String?> _convertToBase64(
//     Uint8List bytes,
//   ) async {
//     try {
//       final decodedImage =
//           img.decodeImage(bytes);

//       if (decodedImage == null) {
//         return null;
//       }

//       img.Image resizedImage =
//           decodedImage;

//       const maxSize = 1200;

//       if (decodedImage.width > maxSize ||
//           decodedImage.height > maxSize) {
//         resizedImage = img.copyResize(
//           decodedImage,
//           width:
//               decodedImage.width >
//                       decodedImage.height
//                   ? maxSize
//                   : null,
//           height:
//               decodedImage.height >=
//                       decodedImage.width
//                   ? maxSize
//                   : null,
//         );
//       }

//       final compressedBytes =
//           img.encodeJpg(
//         resizedImage,
//         quality: 75,
//       );

//       return 'data:image/jpeg;base64,${base64Encode(compressedBytes)}';
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<void> _saveFandom() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_images.isEmpty) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Please select at least one image.',
//           ),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       final user =
//           FirebaseAuth.instance.currentUser;

//       if (user == null) {
//         throw Exception(
//           'You must be logged in.',
//         );
//       }

//       final ref = FirebaseFirestore
//           .instance
//           .collection('fandoms')
//           .doc();

//       final fandomId =
//           'FND-${ref.id.substring(0, 12).toUpperCase()}';

//       await ref.set({
//         'name':
//             _nameController.text.trim(),
//         'description':
//             _descriptionController
//                 .text
//                 .trim(),
//         'imageUrl': _images.first,
//         'images': _images,
//         'category': _category,
//         'fandomId': fandomId,
//         'status': 'pending',
//         'isActive': _isActive,
//         'createdAt':
//             FieldValue.serverTimestamp(),
//         'updatedAt':
//             FieldValue.serverTimestamp(),
//         'createdBy': user.uid,
//       });

//       if (!mounted) return;

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Fandom submitted successfully.',
//           ),
//           backgroundColor:
//               Color(0xFF7C5CFC),
//         ),
//       );

//       Navigator.pop(context);
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Failed to add fandom: $e',
//           ),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           const Color(0xFF080A12),
//       appBar: AppBar(
//         backgroundColor:
//             const Color(0xFF080A12),
//         elevation: 0,
//         iconTheme:
//             const IconThemeData(
//           color: Colors.white,
//         ),
//         title: const Text(
//           'Add Fandom',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: LayoutBuilder(
//         builder:
//             (context, constraints) {
//           final desktop =
//               constraints.maxWidth >= 900;

//           return SingleChildScrollView(
//             padding: EdgeInsets.all(
//               desktop ? 30 : 16,
//             ),
//             child: Center(
//               child: ConstrainedBox(
//                 constraints:
//                     const BoxConstraints(
//                   maxWidth: 1200,
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       if (desktop)
//                         Row(
//                           crossAxisAlignment:
//                               CrossAxisAlignment
//                                   .start,
//                           children: [
//                             Expanded(
//                               child:
//                                   _imageCard(),
//                             ),
//                             const SizedBox(
//                               width: 22,
//                             ),
//                             Expanded(
//                               child:
//                                   _formCard(),
//                             ),
//                           ],
//                         )
//                       else
//                         Column(
//                           children: [
//                             _imageCard(),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             _formCard(),
//                           ],
//                         ),

//                       const SizedBox(
//                         height: 25,
//                       ),

//                       _buttons(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _imageCard() {
//     return _card(
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           _title(
//             Icons.photo_library_outlined,
//             'Fandom Images',
//           ),
//           const SizedBox(height: 18),
//           if (_images.isEmpty)
//             Container(
//               height: 240,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color:
//                     const Color(0xFF171B2B),
//                 borderRadius:
//                     BorderRadius.circular(
//                   16,
//                 ),
//               ),
//               child: const Center(
//                 child: Icon(
//                   Icons.image_outlined,
//                   color: Colors.white30,
//                   size: 50,
//                 ),
//               ),
//             )
//           else
//             GridView.builder(
//               shrinkWrap: true,
//               physics:
//                   const NeverScrollableScrollPhysics(),
//               itemCount: _images.length,
//               gridDelegate:
//                   const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//               ),
//               itemBuilder:
//                   (context, index) {
//                 return Stack(
//                   children: [
//                     Positioned.fill(
//                       child: ClipRRect(
//                         borderRadius:
//                             BorderRadius
//                                 .circular(14),
//                         child: Image.memory(
//                           base64Decode(
//                             _images[index]
//                                 .split(',')
//                                 .last,
//                           ),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     if (index == 0)
//                       Positioned(
//                         top: 7,
//                         left: 7,
//                         child: Container(
//                           padding:
//                               const EdgeInsets
//                                   .symmetric(
//                             horizontal: 7,
//                             vertical: 4,
//                           ),
//                           color:
//                               const Color(
//                             0xFFE0B45A,
//                           ),
//                           child: const Text(
//                             'MAIN',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 9,
//                               fontWeight:
//                                   FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     Positioned(
//                       top: 6,
//                       right: 6,
//                       child: GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _images
//                                 .removeAt(
//                               index,
//                             );
//                           });
//                         },
//                         child: Container(
//                           padding:
//                               const EdgeInsets
//                                   .all(6),
//                           decoration:
//                               const BoxDecoration(
//                             color: Colors.black87,
//                             shape:
//                                 BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.close,
//                             color: Colors.white,
//                             size: 16,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           const SizedBox(height: 15),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed:
//                   _isSaving
//                       ? null
//                       : _pickImages,
//               icon: const Icon(
//                 Icons.add_photo_alternate_outlined,
//               ),
//               label: const Text(
//                 'Select Multiple Images',
//               ),
//               style:
//                   OutlinedButton.styleFrom(
//                 foregroundColor:
//                     const Color(0xFF9D87FF),
//                 side: const BorderSide(
//                   color: Color(0xFF7C5CFC),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(
//                   vertical: 15,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _formCard() {
//     return _card(
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           _title(
//             Icons.auto_awesome_outlined,
//             'Fandom Information',
//           ),
//           const SizedBox(height: 20),

//           _field(
//             _nameController,
//             'Fandom Name',
//             'e.g. Marvel',
//             Icons.movie_filter_outlined,
//           ),

//           const SizedBox(height: 16),

//           _field(
//             _descriptionController,
//             'Description',
//             'Describe this fandom...',
//             Icons.description_outlined,
//             maxLines: 5,
//           ),

//           const SizedBox(height: 16),

//           DropdownButtonFormField<String>(
//             value: _category,
//             dropdownColor:
//                 const Color(0xFF171B2B),
//             style: const TextStyle(
//               color: Colors.white,
//             ),
//             decoration: _decoration(
//               'Category',
//               'Select category',
//               Icons.category_outlined,
//             ),
//             items: _categories
//                 .map(
//                   (e) =>
//                       DropdownMenuItem(
//                     value: e,
//                     child: Text(e),
//                   ),
//                 )
//                 .toList(),
//             onChanged: (v) {
//               setState(() {
//                 _category = v;
//               });
//             },
//             validator: (v) =>
//                 v == null
//                     ? 'Select category'
//                     : null,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buttons() {
//     return Row(
//       mainAxisAlignment:
//           MainAxisAlignment.end,
//       children: [
//         OutlinedButton(
//           onPressed: _isSaving
//               ? null
//               : () => Navigator.pop(
//                     context,
//                   ),
//           child: const Text('Cancel'),
//         ),
//         const SizedBox(width: 12),
//         ElevatedButton.icon(
//           onPressed:
//               _isSaving
//                   ? null
//                   : _saveFandom,
//           icon: _isSaving
//               ? const SizedBox(
//                   height: 17,
//                   width: 17,
//                   child:
//                       CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.white,
//                   ),
//                 )
//               : const Icon(
//                   Icons.add,
//                 ),
//           label: Text(
//             _isSaving
//                 ? 'Adding...'
//                 : 'Add Fandom',
//           ),
//           style:
//               ElevatedButton.styleFrom(
//             backgroundColor:
//                 const Color(0xFF7C5CFC),
//             foregroundColor:
//                 Colors.white,
//             padding:
//                 const EdgeInsets.symmetric(
//               horizontal: 25,
//               vertical: 16,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _field(
//     TextEditingController controller,
//     String label,
//     String hint,
//     IconData icon, {
//     int maxLines = 1,
//   }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       style: const TextStyle(
//         color: Colors.white,
//       ),
//       validator: (value) =>
//           value == null ||
//                   value.trim().isEmpty
//               ? 'Please enter $label'
//               : null,
//       decoration: _decoration(
//         label,
//         hint,
//         icon,
//       ),
//     );
//   }

//   InputDecoration _decoration(
//     String label,
//     String hint,
//     IconData icon,
//   ) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       labelStyle:
//           const TextStyle(
//         color: Colors.white60,
//       ),
//       hintStyle:
//           const TextStyle(
//         color: Colors.white30,
//       ),
//       prefixIcon: Icon(
//         icon,
//         color:
//             const Color(0xFF9D87FF),
//       ),
//       filled: true,
//       fillColor:
//           const Color(0xFF111522),
//       border: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(
//           14,
//         ),
//         borderSide:
//             BorderSide.none,
//       ),
//       focusedBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(
//           14,
//         ),
//         borderSide:
//             const BorderSide(
//           color:
//               Color(0xFF7C5CFC),
//         ),
//       ),
//     );
//   }

//   Widget _card({
//     required Widget child,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding:
//           const EdgeInsets.all(21),
//       decoration: BoxDecoration(
//         color:
//             const Color(0xFF111522),
//         borderRadius:
//             BorderRadius.circular(
//           20,
//         ),
//         border: Border.all(
//           color: Colors.white
//               .withOpacity(.06),
//         ),
//       ),
//       child: child,
//     );
//   }

//   Widget _title(
//     IconData icon,
//     String title,
//   ) {
//     return Row(
//       children: [
//         Container(
//           padding:
//               const EdgeInsets.all(9),
//           decoration: BoxDecoration(
//             color:
//                 const Color(0xFF7C5CFC)
//                     .withOpacity(.12),
//             borderRadius:
//                 BorderRadius.circular(
//               10,
//             ),
//           ),
//           child: Icon(
//             icon,
//             color:
//                 const Color(0xFF9D87FF),
//             size: 20,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           title,
//           style:
//               const TextStyle(
//             color: Colors.white,
//             fontSize: 17,
//             fontWeight:
//                 FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
// }





// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fandom_verse/screens/admin/addfandom.dart';
// import 'package:fandom_verse/screens/admin/admin_drawer.dart';
// // import 'package:fandom_verse/screens/admin/add_fandom.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class FandomManagementScreen extends StatefulWidget {
//   const FandomManagementScreen({super.key});

//   @override
//   State<FandomManagementScreen> createState() =>
//       _FandomManagementScreenState();
// }

// class _FandomManagementScreenState extends State<FandomManagementScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ImagePicker _imagePicker = ImagePicker();

//   final TextEditingController _searchController = TextEditingController();

//   String _searchQuery = '';
//   String _selectedCategory = 'All';

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

//   CollectionReference<Map<String, dynamic>> get _fandomsCollection =>
//       _firestore.collection('fandoms');

//   // ---------------------------------------------------------------------------
//   // HELPERS
//   // ---------------------------------------------------------------------------

//   void _showSnackBar(
//     String message, {
//     bool error = false,
//   }) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(
//           content: Text(message),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor:
//               error ? const Color(0xFFD64545) : const Color(0xFF242A3B),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//   }

//   String _stringValue(dynamic value) {
//     if (value == null) return '';
//     return value.toString();
//   }

//   List<String> _getImages(Map<String, dynamic> data) {
//     final List<String> result = [];

//     final dynamic imagesValue = data['images'];

//     if (imagesValue is List) {
//       for (final item in imagesValue) {
//         if (item != null && item.toString().trim().isNotEmpty) {
//           result.add(item.toString());
//         }
//       }
//     }

//     final String mainImage = _stringValue(data['imageUrl']).trim();

//     if (mainImage.isNotEmpty && !result.contains(mainImage)) {
//       result.insert(0, mainImage);
//     }

//     return result;
//   }

//   Uint8List? _decodeBase64Image(String value) {
//     try {
//       if (value.trim().isEmpty) return null;

//       String base64String = value.trim();

//       if (base64String.contains(',')) {
//         base64String = base64String.split(',').last;
//       }

//       return base64Decode(base64String);
//     } catch (_) {
//       return null;
//     }
//   }

//   bool _matchesSearch(Map<String, dynamic> data) {
//     final String name =
//         _stringValue(data['name']).toLowerCase().trim();

//     final String category =
//         _stringValue(data['category']).toLowerCase().trim();

//     final bool matchesText =
//         name.contains(_searchQuery) ||
//         category.contains(_searchQuery);

//     if (_selectedCategory == 'All') {
//       return matchesText;
//     }

//     return matchesText &&
//         category == _selectedCategory.toLowerCase();
//   }

//   List<String> _getCategories(
//     List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
//   ) {
//     final Set<String> categories = {};

//     for (final document in documents) {
//       final String category =
//           _stringValue(document.data()['category']).trim();

//       if (category.isNotEmpty) {
//         categories.add(category);
//       }
//     }

//     final List<String> result = categories.toList();

//     result.sort(
//       (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
//     );

//     return ['All', ...result];
//   }

//   // ---------------------------------------------------------------------------
//   // ADD
//   // ---------------------------------------------------------------------------

//   void _openAddFandom() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const AddFandomScreen(),
//       ),
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // DELETE
//   // ---------------------------------------------------------------------------

//   Future<void> _confirmDelete(
//     DocumentSnapshot<Map<String, dynamic>> document,
//   ) async {
//     final data = document.data() ?? {};

//     final String name = _stringValue(data['name']).trim();

//     final bool? confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF111522),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           title: const Text(
//             'Delete Fandom?',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           content: RichText(
//             text: TextSpan(
//               style: const TextStyle(
//                 color: Color(0xFFB8BDCC),
//                 fontSize: 14,
//                 height: 1.5,
//               ),
//               children: [
//                 const TextSpan(
//                   text: 'Are you sure you want to permanently delete ',
//                 ),
//                 TextSpan(
//                   text: name.isEmpty ? 'this fandom' : '"$name"',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const TextSpan(
//                   text: '?\n\nThis action cannot be undone.',
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext, false),
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Color(0xFFB8BDCC),
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFD64545),
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () => Navigator.pop(dialogContext, true),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed != true) return;

//     try {
//       await _fandomsCollection.doc(document.id).delete();

//       _showSnackBar(
//         name.isEmpty
//             ? 'Fandom deleted successfully.'
//             : '"$name" deleted successfully.',
//       );
//     } catch (e) {
//       _showSnackBar(
//         'Unable to delete fandom. Please try again.',
//         error: true,
//       );
//     }
//   }

//   // ---------------------------------------------------------------------------
//   // EDIT
//   // ---------------------------------------------------------------------------

//   Future<void> _openEditDialog(
//     DocumentSnapshot<Map<String, dynamic>> document,
//   ) async {
//     final data = document.data() ?? {};

//     final TextEditingController nameController = TextEditingController(
//       text: _stringValue(data['name']),
//     );

//     final TextEditingController categoryController = TextEditingController(
//       text: _stringValue(data['category']),
//     );

//     final TextEditingController descriptionController =
//         TextEditingController(
//       text: _stringValue(data['description']),
//     );

//     String selectedStatus =
//         _stringValue(data['status']).trim().isEmpty
//             ? 'approved'
//             : _stringValue(data['status']).trim();

//     bool isActive = data['isActive'] == true;

//     final List<String> images = List<String>.from(
//       _getImages(data),
//     );

//     bool isSaving = false;
//     bool isPickingImages = false;

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             Future<void> pickImages() async {
//               if (isPickingImages) return;

//               setDialogState(() {
//                 isPickingImages = true;
//               });

//               try {
//                 final List<XFile> pickedFiles =
//                     await _imagePicker.pickMultiImage(
//                   imageQuality: 82,
//                   maxWidth: 1600,
//                 );

//                 if (pickedFiles.isEmpty) {
//                   setDialogState(() {
//                     isPickingImages = false;
//                   });
//                   return;
//                 }

//                 final List<String> newImages = [];

//                 for (final file in pickedFiles) {
//                   final Uint8List bytes = await file.readAsBytes();

//                   if (bytes.isEmpty) continue;

//                   final String extension =
//                       file.name.toLowerCase().split('.').last;

//                   String mimeType = 'image/jpeg';

//                   if (extension == 'png') {
//                     mimeType = 'image/png';
//                   } else if (extension == 'webp') {
//                     mimeType = 'image/webp';
//                   } else if (extension == 'gif') {
//                     mimeType = 'image/gif';
//                   }

//                   final String base64Image =
//                       'data:$mimeType;base64,${base64Encode(bytes)}';

//                   newImages.add(base64Image);
//                 }

//                 if (newImages.isNotEmpty) {
//                   images.addAll(newImages);
//                 }
//               } catch (e) {
//                 _showSnackBar(
//                   'Unable to select images.',
//                   error: true,
//                 );
//               } finally {
//                 setDialogState(() {
//                   isPickingImages = false;
//                 });
//               }
//             }

//             Future<void> saveChanges() async {
//               if (isSaving) return;

//               final String name = nameController.text.trim();
//               final String category = categoryController.text.trim();
//               final String description =
//                   descriptionController.text.trim();

//               if (name.isEmpty) {
//                 _showSnackBar(
//                   'Please enter a fandom name.',
//                   error: true,
//                 );
//                 return;
//               }

//               if (category.isEmpty) {
//                 _showSnackBar(
//                   'Please enter a category.',
//                   error: true,
//                 );
//                 return;
//               }

//               if (description.isEmpty) {
//                 _showSnackBar(
//                   'Please enter a description.',
//                   error: true,
//                 );
//                 return;
//               }

//               if (images.isEmpty) {
//                 _showSnackBar(
//                   'Please add at least one fandom image.',
//                   error: true,
//                 );
//                 return;
//               }

//               final bool? confirmed = await showDialog<bool>(
//                 context: context,
//                 builder: (confirmContext) {
//                   return AlertDialog(
//                     backgroundColor: const Color(0xFF111522),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(18),
//                     ),
//                     title: const Text(
//                       'Confirm Update',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     content: const Text(
//                       'Are you sure you want to update this fandom?',
//                       style: TextStyle(
//                         color: Color(0xFFB8BDCC),
//                         height: 1.5,
//                       ),
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () =>
//                             Navigator.pop(confirmContext, false),
//                         child: const Text(
//                           'Cancel',
//                           style: TextStyle(
//                             color: Color(0xFFB8BDCC),
//                           ),
//                         ),
//                       ),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF7C5CFC),
//                           foregroundColor: Colors.white,
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         onPressed: () =>
//                             Navigator.pop(confirmContext, true),
//                         child: const Text('Update'),
//                       ),
//                     ],
//                   );
//                 },
//               );

//               if (confirmed != true) return;

//               setDialogState(() {
//                 isSaving = true;
//               });

//               try {
//                 final List<String> finalImages =
//                     List<String>.from(images);

//                 await _fandomsCollection.doc(document.id).update({
//                   'name': name,
//                   'category': category,
//                   'description': description,
//                   'status': selectedStatus,
//                   'isActive': isActive,

//                   // Keep the first image as the main image.
//                   'imageUrl': finalImages.first,

//                   // Save all images as Base64 strings.
//                   'images': finalImages,

//                   'updatedAt': FieldValue.serverTimestamp(),
//                 });

//                 if (dialogContext.mounted) {
//                   Navigator.pop(dialogContext);
//                 }

//                 _showSnackBar(
//                   '"$name" updated successfully.',
//                 );
//               } catch (e) {
//                 setDialogState(() {
//                   isSaving = false;
//                 });

//                 _showSnackBar(
//                   'Unable to update fandom. Please try again.',
//                   error: true,
//                 );
//               }
//             }

//             return Dialog(
//               backgroundColor: const Color(0xFF111522),
//               insetPadding: const EdgeInsets.symmetric(
//                 horizontal: 18,
//                 vertical: 20,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(22),
//               ),
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(
//                   maxWidth: 850,
//                   maxHeight: 850,
//                 ),
//                 child: Column(
//                   children: [
//                     // ---------------------------------------------------------
//                     // HEADER
//                     // ---------------------------------------------------------
//                     Container(
//                       padding: const EdgeInsets.fromLTRB(
//                         22,
//                         20,
//                         16,
//                         18,
//                       ),
//                       decoration: const BoxDecoration(
//                         border: Border(
//                           bottom: BorderSide(
//                             color: Color(0xFF252B3D),
//                           ),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             height: 42,
//                             width: 42,
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF7C5CFC)
//                                   .withOpacity(.14),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: const Icon(
//                               Icons.edit_rounded,
//                               color: Color(0xFF9D87FF),
//                               size: 21,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           const Expanded(
//                             child: Column(
//                               crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Edit Fandom',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 19,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                                 SizedBox(height: 3),
//                                 Text(
//                                   'Update fandom information',
//                                   style: TextStyle(
//                                     color: Color(0xFF858B9D),
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: isSaving
//                                 ? null
//                                 : () =>
//                                     Navigator.pop(dialogContext),
//                             icon: const Icon(
//                               Icons.close_rounded,
//                               color: Color(0xFF9CA2B3),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     // ---------------------------------------------------------
//                     // BODY
//                     // ---------------------------------------------------------
//                     Expanded(
//                       child: SingleChildScrollView(
//                         padding: const EdgeInsets.all(22),
//                         child: Column(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                           children: [
//                             _editLabel('Fandom Name'),
//                             const SizedBox(height: 8),
//                             _editTextField(
//                               controller: nameController,
//                               hintText: 'Enter fandom name',
//                               icon: Icons.auto_awesome_rounded,
//                             ),

//                             const SizedBox(height: 18),

//                             _editLabel('Category'),
//                             const SizedBox(height: 8),
//                             _editTextField(
//                               controller: categoryController,
//                               hintText: 'e.g. Movies, Anime, Games',
//                               icon: Icons.category_rounded,
//                             ),

//                             const SizedBox(height: 18),

//                             _editLabel('Description'),
//                             const SizedBox(height: 8),
//                             _editTextField(
//                               controller: descriptionController,
//                               hintText: 'Enter fandom description',
//                               icon: Icons.description_rounded,
//                               maxLines: 5,
//                             ),

//                             const SizedBox(height: 18),

//                             _editLabel('Status'),
//                             const SizedBox(height: 8),
//                             DropdownButtonFormField<String>(
//                               value: selectedStatus,
//                               dropdownColor:
//                                   const Color(0xFF171B2B),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14,
//                               ),
//                               decoration: InputDecoration(
//                                 prefixIcon: const Icon(
//                                   Icons.verified_rounded,
//                                   color: Color(0xFF858B9D),
//                                   size: 20,
//                                 ),
//                                 filled: true,
//                                 fillColor:
//                                     const Color(0xFF171B2B),
//                                 border: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.circular(12),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.circular(12),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xFF252B3D),
//                                   ),
//                                 ),
//                               ),
//                               items: const [
//                                 DropdownMenuItem(
//                                   value: 'approved',
//                                   child: Text('Approved'),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 'pending',
//                                   child: Text('Pending'),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 'rejected',
//                                   child: Text('Rejected'),
//                                 ),
//                               ],
//                               onChanged: isSaving
//                                   ? null
//                                   : (value) {
//                                       if (value == null) return;

//                                       setDialogState(() {
//                                         selectedStatus = value;
//                                       });
//                                     },
//                             ),

//                             const SizedBox(height: 12),

//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 12,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF171B2B),
//                                 borderRadius:
//                                     BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: const Color(0xFF252B3D),
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.power_settings_new_rounded,
//                                     color: Color(0xFF9D87FF),
//                                     size: 20,
//                                   ),
//                                   const SizedBox(width: 10),
//                                   const Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Active Fandom',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontWeight:
//                                                 FontWeight.w600,
//                                           ),
//                                         ),
//                                         SizedBox(height: 2),
//                                         Text(
//                                           'Show this fandom as active',
//                                           style: TextStyle(
//                                             color:
//                                                 Color(0xFF858B9D),
//                                             fontSize: 11,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Switch(
//                                     value: isActive,
//                                     activeColor:
//                                         const Color(0xFF7C5CFC),
//                                     onChanged: isSaving
//                                         ? null
//                                         : (value) {
//                                             setDialogState(() {
//                                               isActive = value;
//                                             });
//                                           },
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             const SizedBox(height: 22),

//                             // -------------------------------------------------
//                             // IMAGES
//                             // -------------------------------------------------
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _editLabel(
//                                     'Fandom Images',
//                                   ),
//                                 ),
//                                 Text(
//                                   '${images.length} image${images.length == 1 ? '' : 's'}',
//                                   style: const TextStyle(
//                                     color: Color(0xFF858B9D),
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 10),

//                             if (images.isEmpty)
//                               _emptyImageBox()
//                             else
//                               Wrap(
//                                 spacing: 12,
//                                 runSpacing: 12,
//                                 children: List.generate(
//                                   images.length,
//                                   (index) {
//                                     return _editableImageCard(
//                                       image: images[index],
//                                       index: index,
//                                       onRemove: isSaving
//                                           ? null
//                                           : () {
//                                               setDialogState(() {
//                                                 images.removeAt(index);
//                                               });
//                                             },
//                                     );
//                                   },
//                                 ),
//                               ),

//                             const SizedBox(height: 14),

//                             SizedBox(
//                               width: double.infinity,
//                               child: OutlinedButton.icon(
//                                 onPressed:
//                                     isSaving || isPickingImages
//                                         ? null
//                                         : pickImages,
//                                 icon: isPickingImages
//                                     ? const SizedBox(
//                                         height: 17,
//                                         width: 17,
//                                         child:
//                                             CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           color:
//                                               Color(0xFF9D87FF),
//                                         ),
//                                       )
//                                     : const Icon(
//                                         Icons.add_photo_alternate_rounded,
//                                         size: 19,
//                                       ),
//                                 label: Text(
//                                   isPickingImages
//                                       ? 'Selecting Images...'
//                                       : 'Add / Replace Images',
//                                 ),
//                                 style: OutlinedButton.styleFrom(
//                                   foregroundColor:
//                                       const Color(0xFF9D87FF),
//                                   side: const BorderSide(
//                                     color: Color(0xFF383F57),
//                                   ),
//                                   padding:
//                                       const EdgeInsets.symmetric(
//                                     vertical: 14,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: 8),

//                             const Text(
//                               'The first image will be used as the main fandom image.',
//                               style: TextStyle(
//                                 color: Color(0xFF6F7688),
//                                 fontSize: 11,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     // ---------------------------------------------------------
//                     // FOOTER
//                     // ---------------------------------------------------------
//                     Container(
//                       padding: const EdgeInsets.fromLTRB(
//                         22,
//                         15,
//                         22,
//                         18,
//                       ),
//                       decoration: const BoxDecoration(
//                         border: Border(
//                           top: BorderSide(
//                             color: Color(0xFF252B3D),
//                           ),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment:
//                             MainAxisAlignment.end,
//                         children: [
//                           TextButton(
//                             onPressed: isSaving
//                                 ? null
//                                 : () =>
//                                     Navigator.pop(dialogContext),
//                             child: const Text(
//                               'Cancel',
//                               style: TextStyle(
//                                 color: Color(0xFF9CA2B3),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           ElevatedButton.icon(
//                             onPressed:
//                                 isSaving ? null : saveChanges,
//                             icon: isSaving
//                                 ? const SizedBox(
//                                     height: 17,
//                                     width: 17,
//                                     child:
//                                         CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                 : const Icon(
//                                     Icons.save_rounded,
//                                     size: 18,
//                                   ),
//                             label: Text(
//                               isSaving
//                                   ? 'Updating...'
//                                   : 'Update Fandom',
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   const Color(0xFF7C5CFC),
//                               foregroundColor: Colors.white,
//                               elevation: 0,
//                               padding:
//                                   const EdgeInsets.symmetric(
//                                 horizontal: 18,
//                                 vertical: 13,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius:
//                                     BorderRadius.circular(11),
//                               ),
//                             ),
//                           ),
//                         ],
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
//     categoryController.dispose();
//     descriptionController.dispose();
//   }

//   // ---------------------------------------------------------------------------
//   // EDIT WIDGETS
//   // ---------------------------------------------------------------------------

//   Widget _editLabel(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//         color: Colors.white,
//         fontSize: 13,
//         fontWeight: FontWeight.w600,
//       ),
//     );
//   }

//   Widget _editTextField({
//     required TextEditingController controller,
//     required String hintText,
//     required IconData icon,
//     int maxLines = 1,
//   }) {
//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       style: const TextStyle(
//         color: Colors.white,
//         fontSize: 14,
//       ),
//       decoration: InputDecoration(
//         hintText: hintText,
//         hintStyle: const TextStyle(
//           color: Color(0xFF62697A),
//           fontSize: 13,
//         ),
//         prefixIcon: Padding(
//           padding: EdgeInsets.only(
//             bottom: maxLines > 1 ? 70 : 0,
//           ),
//           child: Icon(
//             icon,
//             color: const Color(0xFF858B9D),
//             size: 20,
//           ),
//         ),
//         filled: true,
//         fillColor: const Color(0xFF171B2B),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: Color(0xFF252B3D),
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: Color(0xFF7C5CFC),
//           ),
//         ),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 14,
//         ),
//       ),
//     );
//   }

//   Widget _emptyImageBox() {
//     return Container(
//       width: double.infinity,
//       height: 150,
//       decoration: BoxDecoration(
//         color: const Color(0xFF171B2B),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: const Color(0xFF252B3D),
//         ),
//       ),
//       child: const Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.image_not_supported_outlined,
//             color: Color(0xFF62697A),
//             size: 35,
//           ),
//           SizedBox(height: 8),
//           Text(
//             'No images selected',
//             style: TextStyle(
//               color: Color(0xFF858B9D),
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _editableImageCard({
//     required String image,
//     required int index,
//     required VoidCallback? onRemove,
//   }) {
//     final Uint8List? bytes = _decodeBase64Image(image);

//     return SizedBox(
//       width: 115,
//       height: 145,
//       child: Stack(
//         children: [
//           Container(
//             width: 115,
//             height: 145,
//             decoration: BoxDecoration(
//               color: const Color(0xFF171B2B),
//               borderRadius: BorderRadius.circular(13),
//               border: Border.all(
//                 color: index == 0
//                     ? const Color(0xFF7C5CFC)
//                     : const Color(0xFF252B3D),
//               ),
//             ),
//             clipBehavior: Clip.antiAlias,
//             child: bytes == null
//                 ? const Center(
//                     child: Icon(
//                       Icons.broken_image_outlined,
//                       color: Color(0xFF62697A),
//                       size: 30,
//                     ),
//                   )
//                 : Image.memory(
//                     bytes,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) {
//                       return const Center(
//                         child: Icon(
//                           Icons.broken_image_outlined,
//                           color: Color(0xFF62697A),
//                           size: 30,
//                         ),
//                       );
//                     },
//                   ),
//           ),

//           if (index == 0)
//             Positioned(
//               left: 7,
//               bottom: 7,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 7,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF7C5CFC),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: const Text(
//                   'MAIN',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 9,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//             ),

//           if (onRemove != null)
//             Positioned(
//               top: 6,
//               right: 6,
//               child: Material(
//                 color: Colors.black.withOpacity(.7),
//                 shape: const CircleBorder(),
//                 child: InkWell(
//                   customBorder: const CircleBorder(),
//                   onTap: onRemove,
//                   child: const Padding(
//                     padding: EdgeInsets.all(6),
//                     child: Icon(
//                       Icons.close_rounded,
//                       color: Colors.white,
//                       size: 15,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // MAIN PAGE
//   // ---------------------------------------------------------------------------

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF080A12),
//       drawer: const AdminDrawer(),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF080A12),
//         elevation: 0,
//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ),
//         title: const Text(
//           'Fandom Management',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//             fontSize: 19,
//           ),
//         ),
//       ),
//       body: StreamBuilder<
//           QuerySnapshot<Map<String, dynamic>>>(
//         stream: _fandomsCollection
//             .orderBy(
//               'createdAt',
//               descending: true,
//             )
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return _errorState();
//           }

//           if (snapshot.connectionState ==
//               ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(
//                 color: Color(0xFF7C5CFC),
//               ),
//             );
//           }

//           final documents = snapshot.data?.docs ?? [];

//           final filteredDocuments = documents
//               .where(
//                 (document) =>
//                     _matchesSearch(document.data()),
//               )
//               .toList();

//           final categories = _getCategories(documents);

//           return LayoutBuilder(
//             builder: (context, constraints) {
//               final bool isMobile =
//                   constraints.maxWidth < 650;

//               return SingleChildScrollView(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isMobile ? 12 : 24,
//                   vertical: isMobile ? 14 : 22,
//                 ),
//                 child: Center(
//                   child: ConstrainedBox(
//                     constraints: const BoxConstraints(
//                       maxWidth: 1400,
//                     ),
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         // -----------------------------------------------------
//                         // TOP HEADER
//                         // -----------------------------------------------------
//                         Row(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.center,
//                           children: [
//                             const Expanded(
//                               child: Column(
//                                 crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Manage Fandoms',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 24,
//                                       fontWeight:
//                                           FontWeight.w800,
//                                     ),
//                                   ),
//                                   SizedBox(height: 5),
//                                   Text(
//                                     'Create, update and manage your fandom collection.',
//                                     style: TextStyle(
//                                       color: Color(0xFF858B9D),
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             const SizedBox(width: 10),

//                             // Compact responsive button.
//                             ElevatedButton.icon(
//                               onPressed: _openAddFandom,
//                               icon: const Icon(
//                                 Icons.add_rounded,
//                                 size: 18,
//                               ),
//                               label: Text(
//                                 isMobile
//                                     ? 'Add'
//                                     : 'Add Fandom',
//                               ),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor:
//                                     const Color(0xFF7C5CFC),
//                                 foregroundColor: Colors.white,
//                                 elevation: 0,
//                                 padding:
//                                     EdgeInsets.symmetric(
//                                   horizontal:
//                                       isMobile ? 12 : 16,
//                                   vertical: 12,
//                                 ),
//                                 minimumSize: Size(
//                                   isMobile ? 60 : 0,
//                                   42,
//                                 ),
//                                 shape:
//                                     RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadius.circular(11),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 20),

//                         // -----------------------------------------------------
//                         // SEARCH / FILTER BAR
//                         // -----------------------------------------------------
//                         Container(
//                           padding: EdgeInsets.all(
//                             isMobile ? 12 : 14,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF111522),
//                             borderRadius:
//                                 BorderRadius.circular(16),
//                             border: Border.all(
//                               color: const Color(0xFF202638),
//                             ),
//                           ),
//                           child: isMobile
//                               ? Column(
//                                   children: [
//                                     _searchField(),
//                                     const SizedBox(height: 10),
//                                     _categoryDropdown(
//                                       categories,
//                                     ),
//                                   ],
//                                 )
//                               : Row(
//                                   children: [
//                                     Expanded(
//                                       child: _searchField(),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     SizedBox(
//                                       width: 210,
//                                       child:
//                                           _categoryDropdown(
//                                         categories,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                         ),

//                         const SizedBox(height: 18),

//                         // -----------------------------------------------------
//                         // COUNT
//                         // -----------------------------------------------------
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.library_books_rounded,
//                               color: Color(0xFF9D87FF),
//                               size: 17,
//                             ),
//                             const SizedBox(width: 7),
//                             Text(
//                               '${filteredDocuments.length} fandom${filteredDocuments.length == 1 ? '' : 's'} found',
//                               style: const TextStyle(
//                                 color: Color(0xFF9CA2B3),
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 10),

//                         // -----------------------------------------------------
//                         // LIST
//                         // -----------------------------------------------------
//                         if (filteredDocuments.isEmpty)
//                           _emptyState()
//                         else
//                           ListView.separated(
//                             shrinkWrap: true,
//                             physics:
//                                 const NeverScrollableScrollPhysics(),
//                             itemCount:
//                                 filteredDocuments.length,
//                             separatorBuilder: (_, __) =>
//                                 const SizedBox(height: 10),
//                             itemBuilder: (context, index) {
//                               final document =
//                                   filteredDocuments[index];

//                               return _fandomRow(
//                                 document,
//                                 isMobile,
//                               );
//                             },
//                           ),

//                         const SizedBox(height: 30),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // SEARCH
//   // ---------------------------------------------------------------------------

//   Widget _searchField() {
//     return TextField(
//       controller: _searchController,
//       style: const TextStyle(
//         color: Colors.white,
//         fontSize: 13,
//       ),
//       decoration: InputDecoration(
//         hintText: 'Search by fandom name or category...',
//         hintStyle: const TextStyle(
//           color: Color(0xFF62697A),
//           fontSize: 12,
//         ),
//         prefixIcon: const Icon(
//           Icons.search_rounded,
//           color: Color(0xFF858B9D),
//           size: 20,
//         ),
//         suffixIcon: _searchQuery.isNotEmpty
//             ? IconButton(
//                 onPressed: () {
//                   _searchController.clear();
//                 },
//                 icon: const Icon(
//                   Icons.close_rounded,
//                   color: Color(0xFF858B9D),
//                   size: 18,
//                 ),
//               )
//             : null,
//         filled: true,
//         fillColor: const Color(0xFF171B2B),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(11),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(11),
//           borderSide: const BorderSide(
//             color: Color(0xFF252B3D),
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(11),
//           borderSide: const BorderSide(
//             color: Color(0xFF7C5CFC),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _categoryDropdown(List<String> categories) {
//     final String value =
//         categories.contains(_selectedCategory)
//             ? _selectedCategory
//             : 'All';

//     return DropdownButtonFormField<String>(
//       value: value,
//       dropdownColor: const Color(0xFF171B2B),
//       style: const TextStyle(
//         color: Colors.white,
//         fontSize: 13,
//       ),
//       decoration: InputDecoration(
//         prefixIcon: const Icon(
//           Icons.category_rounded,
//           color: Color(0xFF858B9D),
//           size: 19,
//         ),
//         filled: true,
//         fillColor: const Color(0xFF171B2B),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(11),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(11),
//           borderSide: const BorderSide(
//             color: Color(0xFF252B3D),
//           ),
//         ),
//       ),
//       items: categories.map((category) {
//         return DropdownMenuItem<String>(
//           value: category,
//           child: Text(
//             category,
//             overflow: TextOverflow.ellipsis,
//           ),
//         );
//       }).toList(),
//       onChanged: (value) {
//         if (value == null) return;

//         setState(() {
//           _selectedCategory = value;
//         });
//       },
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // FANDOM ROW
//   // ---------------------------------------------------------------------------

//   Widget _fandomRow(
//     DocumentSnapshot<Map<String, dynamic>> document,
//     bool isMobile,
//   ) {
//     final Map<String, dynamic> data =
//         document.data() ?? {};

//     final String name =
//         _stringValue(data['name']).trim();

//     final String category =
//         _stringValue(data['category']).trim();

//     final String description =
//         _stringValue(data['description']).trim();

//     final String status =
//         _stringValue(data['status']).trim();

//     final bool isActive = data['isActive'] == true;

//     final List<String> images =
//         _getImages(data);

//     final Uint8List? imageBytes = images.isNotEmpty
//         ? _decodeBase64Image(images.first)
//         : null;

//     return Container(
//       padding: EdgeInsets.all(
//         isMobile ? 11 : 14,
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xFF111522),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFF202638),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // ---------------------------------------------------------------
//           // IMAGE
//           // ---------------------------------------------------------------
//           Container(
//             width: isMobile ? 72 : 92,
//             height: isMobile ? 72 : 92,
//             decoration: BoxDecoration(
//               color: const Color(0xFF171B2B),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             clipBehavior: Clip.antiAlias,
//             child: imageBytes == null
//                 ? const Icon(
//                     Icons.image_outlined,
//                     color: Color(0xFF62697A),
//                     size: 30,
//                   )
//                 : Image.memory(
//                     imageBytes,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) {
//                       return const Icon(
//                         Icons.broken_image_outlined,
//                         color: Color(0xFF62697A),
//                         size: 30,
//                       );
//                     },
//                   ),
//           ),

//           const SizedBox(width: 14),

//           // ---------------------------------------------------------------
//           // CONTENT
//           // ---------------------------------------------------------------
//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Wrap(
//                   spacing: 7,
//                   runSpacing: 5,
//                   crossAxisAlignment:
//                       WrapCrossAlignment.center,
//                   children: [
//                     Text(
//                       name.isEmpty ? 'Unnamed Fandom' : name,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: isMobile ? 14 : 16,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     if (category.isNotEmpty)
//                       _smallTag(
//                         category,
//                         const Color(0xFF7C5CFC),
//                       ),
//                   ],
//                 ),

//                 const SizedBox(height: 6),

//                 if (description.isNotEmpty)
//                   Text(
//                     description,
//                     maxLines: isMobile ? 2 : 3,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: Color(0xFF858B9D),
//                       fontSize: 12,
//                       height: 1.45,
//                     ),
//                   ),

//                 const SizedBox(height: 8),

//                 Wrap(
//                   spacing: 7,
//                   runSpacing: 5,
//                   children: [
//                     if (status.isNotEmpty)
//                       _smallTag(
//                         status.toUpperCase(),
//                         status.toLowerCase() ==
//                                 'approved'
//                             ? const Color(0xFF38B27A)
//                             : status.toLowerCase() ==
//                                     'rejected'
//                                 ? const Color(0xFFD64545)
//                                 : const Color(0xFFE0B45A),
//                       ),
//                     _smallTag(
//                       isActive ? 'ACTIVE' : 'INACTIVE',
//                       isActive
//                           ? const Color(0xFF38B27A)
//                           : const Color(0xFF62697A),
//                     ),
//                     _smallTag(
//                       '${images.length} image${images.length == 1 ? '' : 's'}',
//                       const Color(0xFF5D86E8),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(width: 8),

//           // ---------------------------------------------------------------
//           // ACTIONS
//           // ---------------------------------------------------------------
//           if (isMobile)
//             PopupMenuButton<String>(
//               color: const Color(0xFF171B2B),
//               icon: const Icon(
//                 Icons.more_vert_rounded,
//                 color: Color(0xFF9CA2B3),
//               ),
//               onSelected: (value) {
//                 if (value == 'edit') {
//                   _openEditDialog(document);
//                 } else if (value == 'delete') {
//                   _confirmDelete(document);
//                 }
//               },
//               itemBuilder: (_) => const [
//                 PopupMenuItem(
//                   value: 'edit',
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.edit_rounded,
//                         color: Color(0xFF9D87FF),
//                         size: 18,
//                       ),
//                       SizedBox(width: 10),
//                       Text(
//                         'Edit',
//                         style: TextStyle(
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 PopupMenuItem(
//                   value: 'delete',
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.delete_outline_rounded,
//                         color: Color(0xFFD64545),
//                         size: 18,
//                       ),
//                       SizedBox(width: 10),
//                       Text(
//                         'Delete',
//                         style: TextStyle(
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             )
//           else
//             Row(
//               children: [
//                 _actionButton(
//                   icon: Icons.edit_rounded,
//                   tooltip: 'Edit fandom',
//                   color: const Color(0xFF9D87FF),
//                   onPressed: () =>
//                       _openEditDialog(document),
//                 ),
//                 const SizedBox(width: 7),
//                 _actionButton(
//                   icon: Icons.delete_outline_rounded,
//                   tooltip: 'Delete fandom',
//                   color: const Color(0xFFD64545),
//                   onPressed: () =>
//                       _confirmDelete(document),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _smallTag(
//     String text,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 7,
//         vertical: 4,
//       ),
//       decoration: BoxDecoration(
//         color: color.withOpacity(.10),
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(
//           color: color.withOpacity(.22),
//         ),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: color,
//           fontSize: 9,
//           fontWeight: FontWeight.w700,
//           letterSpacing: .2,
//         ),
//       ),
//     );
//   }

//   Widget _actionButton({
//     required IconData icon,
//     required String tooltip,
//     required Color color,
//     required VoidCallback onPressed,
//   }) {
//     return Tooltip(
//       message: tooltip,
//       child: Material(
//         color: color.withOpacity(.10),
//         borderRadius: BorderRadius.circular(9),
//         child: InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(9),
//           child: SizedBox(
//             width: 38,
//             height: 38,
//             child: Icon(
//               icon,
//               color: color,
//               size: 19,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // STATES
//   // ---------------------------------------------------------------------------

//   Widget _emptyState() {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(top: 8),
//       padding: const EdgeInsets.symmetric(
//         vertical: 60,
//         horizontal: 20,
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xFF111522),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFF202638),
//         ),
//       ),
//       child: const Column(
//         children: [
//           Icon(
//             Icons.search_off_rounded,
//             color: Color(0xFF62697A),
//             size: 45,
//           ),
//           SizedBox(height: 12),
//           Text(
//             'No fandoms found',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           SizedBox(height: 5),
//           Text(
//             'Try changing your search or category filter.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Color(0xFF858B9D),
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _errorState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.error_outline_rounded,
//               color: Color(0xFFD64545),
//               size: 48,
//             ),
//             const SizedBox(height: 14),
//             const Text(
//               'Unable to load fandoms',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 17,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 7),
//             const Text(
//               'Please check your Firestore connection and try again.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Color(0xFF858B9D),
//                 fontSize: 12,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {});
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     const Color(0xFF7C5CFC),
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fandom_verse/screens/admin/addfandom.dart';
import 'package:fandom_verse/screens/admin/admin_drawer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FandomManagementScreen extends StatefulWidget {
  const FandomManagementScreen({super.key});

  @override
  State<FandomManagementScreen> createState() =>
      _FandomManagementScreenState();
}

class _FandomManagementScreenState extends State<FandomManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';

  static const Color _background = Color(0xFF080A12);
  static const Color _panel = Color(0xFF111522);
  static const Color _panel2 = Color(0xFF171B2B);
  static const Color _border = Color(0xFF252B3D);
  static const Color _violet = Color(0xFF7C5CFC);
  static const Color _violetLight = Color(0xFF9D87FF);
  static const Color _muted = Color(0xFF858B9D);

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  CollectionReference<Map<String, dynamic>> get _fandomsCollection =>
      _firestore.collection('fandoms');

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  void _showSnackBar(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              error ? const Color(0xFFD64545) : const Color(0xFF242A3B),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  String _stringValue(dynamic value) {
    return value?.toString() ?? '';
  }

  List<String> _getImages(Map<String, dynamic> data) {
    final List<String> result = [];

    final dynamic imagesValue = data['images'];

    if (imagesValue is List) {
      for (final item in imagesValue) {
        if (item == null) continue;

        final String value = item.toString().trim();

        if (value.isNotEmpty && !result.contains(value)) {
          result.add(value);
        }
      }
    }

    final String mainImage = _stringValue(data['imageUrl']).trim();

    if (mainImage.isNotEmpty && !result.contains(mainImage)) {
      result.insert(0, mainImage);
    }

    return result;
  }

  Uint8List? _decodeBase64Image(String value) {
    try {
      String base64String = value.trim();

      if (base64String.isEmpty) return null;

      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }

      return base64Decode(base64String);
    } catch (_) {
      return null;
    }
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    final String name = _stringValue(
      data['name'],
    ).trim().toLowerCase();

    final String category = _stringValue(
      data['category'],
    ).trim().toLowerCase();

    final bool matchesSearch =
        _searchQuery.isEmpty ||
        name.contains(_searchQuery) ||
        category.contains(_searchQuery);

    if (_selectedCategory == 'All') {
      return matchesSearch;
    }

    return matchesSearch &&
        category == _selectedCategory.trim().toLowerCase();
  }

  List<String> _getCategories(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    final Set<String> categories = {};

    for (final document in documents) {
      final String category = _stringValue(
        document.data()['category'],
      ).trim();

      if (category.isNotEmpty) {
        categories.add(category);
      }
    }

    final List<String> result = categories.toList();

    result.sort(
      (a, b) => a.toLowerCase().compareTo(
        b.toLowerCase(),
      ),
    );

    return ['All', ...result];
  }

  // ===========================================================================
  // ADD
  // ===========================================================================

  void _openAddFandom() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddFandomScreen(),
      ),
    );
  }

  // ===========================================================================
  // DELETE
  // ===========================================================================

  Future<void> _confirmDelete(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final Map<String, dynamic> data = document.data() ?? {};

    final String name = _stringValue(
      data['name'],
    ).trim();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _panel,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            22,
            22,
            22,
            8,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            22,
            5,
            22,
            10,
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFD64545).withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFD64545),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Delete Fandom?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            name.isEmpty
                ? 'Are you sure you want to permanently delete this fandom?\n\nThis action cannot be undone.'
                : 'Are you sure you want to permanently delete "$name"?\n\nThis action cannot be undone.',
            style: const TextStyle(
              color: Color(0xFFB8BDCC),
              fontSize: 13,
              height: 1.55,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            18,
            5,
            18,
            16,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: _muted,
                ),
              ),
            ),
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD64545),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _fandomsCollection.doc(document.id).delete();

      _showSnackBar(
        name.isEmpty
            ? 'Fandom deleted successfully.'
            : '"$name" deleted successfully.',
      );
    } catch (_) {
      _showSnackBar(
        'Unable to delete fandom. Please try again.',
        error: true,
      );
    }
  }

  // ===========================================================================
  // EDIT
  // ===========================================================================

  Future<void> _openEditDialog(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final Map<String, dynamic> data = document.data() ?? {};

    final TextEditingController nameController = TextEditingController(
      text: _stringValue(data['name']),
    );

    final TextEditingController categoryController = TextEditingController(
      text: _stringValue(data['category']),
    );

    final TextEditingController descriptionController =
        TextEditingController(
      text: _stringValue(data['description']),
    );

    String selectedStatus =
        _stringValue(data['status']).trim().isEmpty
            ? 'approved'
            : _stringValue(data['status']).trim();

    const List<String> allowedStatuses = [
      'approved',
      'pending',
      'rejected',
    ];

    if (!allowedStatuses.contains(selectedStatus)) {
      selectedStatus = 'approved';
    }

    bool isActive = data['isActive'] == true;

    final List<String> images = List<String>.from(
      _getImages(data),
    );

    bool isSaving = false;
    bool isPickingImages = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final double screenWidth = MediaQuery.of(context).size.width;
            final double screenHeight = MediaQuery.of(context).size.height;

            final bool smallScreen = screenWidth < 600;

            Future<void> pickImages() async {
              if (isPickingImages) return;

              setDialogState(() {
                isPickingImages = true;
              });

              try {
                final List<XFile> pickedFiles =
                    await _imagePicker.pickMultiImage(
                  imageQuality: 82,
                  maxWidth: 1600,
                );

                if (pickedFiles.isEmpty) {
                  return;
                }

                final List<String> newImages = [];

                for (final XFile file in pickedFiles) {
                  final Uint8List bytes = await file.readAsBytes();

                  if (bytes.isEmpty) continue;

                  final String extension =
                      file.name.toLowerCase().split('.').last;

                  String mimeType = 'image/jpeg';

                  if (extension == 'png') {
                    mimeType = 'image/png';
                  } else if (extension == 'webp') {
                    mimeType = 'image/webp';
                  } else if (extension == 'gif') {
                    mimeType = 'image/gif';
                  }

                  newImages.add(
                    'data:$mimeType;base64,${base64Encode(bytes)}',
                  );
                }

                if (newImages.isNotEmpty) {
                  setDialogState(() {
                    images.addAll(newImages);
                  });
                }
              } catch (_) {
                _showSnackBar(
                  'Unable to select images.',
                  error: true,
                );
              } finally {
                if (context.mounted) {
                  setDialogState(() {
                    isPickingImages = false;
                  });
                }
              }
            }

            Future<void> saveChanges() async {
              if (isSaving) return;

              final String name = nameController.text.trim();
              final String category = categoryController.text.trim();
              final String description =
                  descriptionController.text.trim();

              if (name.isEmpty) {
                _showSnackBar(
                  'Please enter a fandom name.',
                  error: true,
                );
                return;
              }

              if (category.isEmpty) {
                _showSnackBar(
                  'Please enter a category.',
                  error: true,
                );
                return;
              }

              if (description.isEmpty) {
                _showSnackBar(
                  'Please enter a description.',
                  error: true,
                );
                return;
              }

              if (images.isEmpty) {
                _showSnackBar(
                  'Please add at least one fandom image.',
                  error: true,
                );
                return;
              }

              final bool? confirmed = await showDialog<bool>(
                context: dialogContext,
                builder: (confirmContext) {
                  return AlertDialog(
                    backgroundColor: _panel,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    title: const Text(
                      'Confirm Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    content: const Text(
                      'Are you sure you want to save these changes to this fandom?',
                      style: TextStyle(
                        color: Color(0xFFB8BDCC),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(confirmContext, false);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: _muted,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(confirmContext, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _violet,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Update'),
                      ),
                    ],
                  );
                },
              );

              if (confirmed != true) return;

              setDialogState(() {
                isSaving = true;
              });

              try {
                final List<String> finalImages =
                    List<String>.from(images);

                await _fandomsCollection.doc(document.id).update({
                  'name': name,
                  'category': category,
                  'description': description,
                  'status': selectedStatus,
                  'isActive': isActive,
                  'imageUrl': finalImages.first,
                  'images': finalImages,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                _showSnackBar(
                  '"$name" updated successfully.',
                );
              } catch (_) {
                setDialogState(() {
                  isSaving = false;
                });

                _showSnackBar(
                  'Unable to update fandom. Please try again.',
                  error: true,
                );
              }
            }

            return Dialog(
              backgroundColor: _panel,
              surfaceTintColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(
                horizontal: smallScreen ? 10 : 24,
                vertical: smallScreen ? 10 : 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  smallScreen ? 16 : 22,
                ),
              ),
              child: SizedBox(
                width: smallScreen
                    ? screenWidth - 20
                    : 760,
                height: smallScreen
                    ? screenHeight - 20
                    : screenHeight * .88,
                child: Column(
                  children: [
                    // =========================================================
                    // DIALOG HEADER
                    // =========================================================
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        smallScreen ? 16 : 22,
                        smallScreen ? 15 : 20,
                        smallScreen ? 10 : 16,
                        smallScreen ? 15 : 18,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _border,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _violet.withOpacity(.13),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: _violetLight,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 11),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edit Fandom',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Update fandom information',
                                  style: TextStyle(
                                    color: _muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: isSaving
                                ? null
                                : () {
                                    Navigator.pop(dialogContext);
                                  },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF9CA2B3),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =========================================================
                    // DIALOG BODY
                    // =========================================================
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.all(
                          smallScreen ? 16 : 22,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _editLabel('Fandom Name'),
                            const SizedBox(height: 7),
                            _editTextField(
                              controller: nameController,
                              hintText: 'Enter fandom name',
                              icon: Icons.auto_awesome_rounded,
                            ),

                            const SizedBox(height: 16),

                            _editLabel('Category'),
                            const SizedBox(height: 7),
                            _editTextField(
                              controller: categoryController,
                              hintText: 'Movies, Anime, Games...',
                              icon: Icons.category_rounded,
                            ),

                            const SizedBox(height: 16),

                            _editLabel('Description'),
                            const SizedBox(height: 7),
                            _editTextField(
                              controller: descriptionController,
                              hintText: 'Enter fandom description',
                              icon: Icons.description_rounded,
                              maxLines: 5,
                            ),

                            const SizedBox(height: 16),

                            _editLabel('Status'),
                            const SizedBox(height: 7),

                            DropdownButtonFormField<String>(
                              value: selectedStatus,
                              dropdownColor: _panel2,
                              isExpanded: true,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.verified_rounded,
                                  color: _muted,
                                  size: 19,
                                ),
                                filled: true,
                                fillColor: _panel2,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 13,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(11),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(11),
                                  borderSide: const BorderSide(
                                    color: _border,
                                  ),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'approved',
                                  child: Text('Approved'),
                                ),
                                DropdownMenuItem(
                                  value: 'pending',
                                  child: Text('Pending'),
                                ),
                                DropdownMenuItem(
                                  value: 'rejected',
                                  child: Text('Rejected'),
                                ),
                              ],
                              onChanged: isSaving
                                  ? null
                                  : (value) {
                                      if (value == null) return;

                                      setDialogState(() {
                                        selectedStatus = value;
                                      });
                                    },
                            ),

                            const SizedBox(height: 12),

                            // =================================================
                            // ACTIVE SWITCH
                            // =================================================

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _panel2,
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                  color: _border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: _violet.withOpacity(.10),
                                      borderRadius:
                                          BorderRadius.circular(9),
                                    ),
                                    child: const Icon(
                                      Icons.power_settings_new_rounded,
                                      color: _violetLight,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Active Fandom',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Make this fandom visible as active',
                                          style: TextStyle(
                                            color: _muted,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isActive,
                                    activeColor: _violet,
                                    onChanged: isSaving
                                        ? null
                                        : (value) {
                                            setDialogState(() {
                                              isActive = value;
                                            });
                                          },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // =================================================
                            // IMAGES HEADER
                            // =================================================

                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Fandom Images',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _violet.withOpacity(.10),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${images.length}',
                                    style: const TextStyle(
                                      color: _violetLight,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            if (images.isEmpty)
                              _emptyImageBox()
                            else
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final double availableWidth =
                                      constraints.maxWidth;

                                  final int columns;

                                  if (availableWidth < 360) {
                                    columns = 2;
                                  } else if (availableWidth < 550) {
                                    columns = 3;
                                  } else if (availableWidth < 700) {
                                    columns = 4;
                                  } else {
                                    columns = 5;
                                  }

                                  const double spacing = 10;

                                  final double itemWidth =
                                      (availableWidth -
                                              ((columns - 1) *
                                                  spacing)) /
                                          columns;

                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      crossAxisSpacing: spacing,
                                      mainAxisSpacing: spacing,
                                      childAspectRatio: .82,
                                    ),
                                    itemCount: images.length,
                                    itemBuilder:
                                        (context, index) {
                                      return _editableImageCard(
                                        image: images[index],
                                        index: index,
                                        onRemove: isSaving
                                            ? null
                                            : () {
                                                setDialogState(() {
                                                  images.removeAt(index);
                                                });
                                              },
                                      );
                                    },
                                  );
                                },
                              ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed:
                                    isSaving || isPickingImages
                                        ? null
                                        : pickImages,
                                icon: isPickingImages
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: _violetLight,
                                        ),
                                      )
                                    : const Icon(
                                        Icons
                                            .add_photo_alternate_rounded,
                                        size: 18,
                                      ),
                                label: Text(
                                  isPickingImages
                                      ? 'Selecting...'
                                      : 'Add / Replace Images',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _violetLight,
                                  side: const BorderSide(
                                    color: Color(0xFF383F57),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(11),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 7),

                            const Text(
                              'The first image is automatically used as the main fandom image.',
                              style: TextStyle(
                                color: Color(0xFF6F7688),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // =========================================================
                    // FOOTER
                    // =========================================================

                    Container(
                      padding: EdgeInsets.fromLTRB(
                        smallScreen ? 14 : 22,
                        12,
                        smallScreen ? 14 : 22,
                        smallScreen ? 14 : 18,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: _border,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: isSaving
                                  ? null
                                  : () {
                                      Navigator.pop(
                                        dialogContext,
                                      );
                                    },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: _muted,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  isSaving ? null : saveChanges,
                              icon: isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.save_rounded,
                                      size: 17,
                                    ),
                              label: Text(
                                isSaving
                                    ? 'Updating...'
                                    : 'Update',
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _violet,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
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
    categoryController.dispose();
    descriptionController.dispose();
  }

  // ===========================================================================
  // EDIT WIDGETS
  // ===========================================================================

  Widget _editLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _editTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF62697A),
          fontSize: 12,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            bottom: maxLines > 1 ? 55 : 0,
          ),
          child: Icon(
            icon,
            color: _muted,
            size: 19,
          ),
        ),
        filled: true,
        fillColor: _panel2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: _border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: _violet,
          ),
        ),
      ),
    );
  }

  Widget _emptyImageBox() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: _panel2,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: _border,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFF62697A),
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            'No images selected',
            style: TextStyle(
              color: _muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _editableImageCard({
    required String image,
    required int index,
    required VoidCallback? onRemove,
  }) {
    final Uint8List? bytes = _decodeBase64Image(image);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: _panel2,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: index == 0
                      ? _violet
                      : _border,
                  width: index == 0 ? 1.4 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: bytes == null
                  ? const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Color(0xFF62697A),
                        size: 28,
                      ),
                    )
                  : Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Color(0xFF62697A),
                            size: 28,
                          ),
                        );
                      },
                    ),
            ),

            if (index == 0)
              Positioned(
                left: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _violet,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'MAIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

            if (onRemove != null)
              Positioned(
                top: 5,
                right: 5,
                child: Material(
                  color: Colors.black.withOpacity(.72),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onRemove,
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // MAIN BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleSpacing: 0,
        title: const Text(
          'Fandom Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _fandomsCollection
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _errorState();
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: _violet,
              ),
            );
          }

          final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
              snapshot.data?.docs ?? [];

          final List<QueryDocumentSnapshot<Map<String, dynamic>>>
              filteredDocuments = documents
                  .where(
                    (document) =>
                        _matchesSearch(document.data()),
                  )
                  .toList();

          final List<String> categories =
              _getCategories(documents);

          return LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;

              final bool mobile = width < 600;
              final bool tablet = width >= 600 && width < 950;

              final double horizontalPadding = mobile
                  ? 12
                  : tablet
                      ? 18
                      : 28;

              return Scrollbar(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    mobile ? 12 : 20,
                    horizontalPadding,
                    35,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1450,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // ===================================================
                          // HEADER
                          // ===================================================

                          _buildPageHeader(
                            mobile: mobile,
                          ),

                          SizedBox(
                            height: mobile ? 16 : 20,
                          ),

                          // ===================================================
                          // SEARCH
                          // ===================================================

                          _buildSearchPanel(
                            categories: categories,
                            mobile: mobile,
                          ),

                          const SizedBox(height: 18),

                          // ===================================================
                          // RESULTS HEADER
                          // ===================================================

                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: _violet,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${filteredDocuments.length} fandom${filteredDocuments.length == 1 ? '' : 's'}',
                                style: const TextStyle(
                                  color: Color(0xFFB8BDCC),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              if (_searchQuery.isNotEmpty ||
                                  _selectedCategory != 'All')
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();

                                    setState(() {
                                      _selectedCategory = 'All';
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                  ),
                                  child: const Text(
                                    'Clear filters',
                                    style: TextStyle(
                                      color: _violetLight,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // ===================================================
                          // LIST
                          // ===================================================

                          if (filteredDocuments.isEmpty)
                            _emptyState()
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount: filteredDocuments.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 9),
                              itemBuilder: (context, index) {
                                return _fandomRow(
                                  filteredDocuments[index],
                                  mobile: mobile,
                                  tablet: tablet,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ===========================================================================
  // PAGE HEADER
  // ===========================================================================

  Widget _buildPageHeader({
    required bool mobile,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Fandoms',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: mobile ? 21 : 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Create, edit and manage your fandom collection.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Compact Add button.
        SizedBox(
          height: 40,
          child: ElevatedButton.icon(
            onPressed: _openAddFandom,
            icon: const Icon(
              Icons.add_rounded,
              size: 17,
            ),
            label: Text(
              mobile ? 'Add' : 'Add Fandom',
              overflow: TextOverflow.ellipsis,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _violet,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: mobile ? 11 : 15,
              ),
              minimumSize: Size(
                mobile ? 60 : 0,
                40,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SEARCH PANEL
  // ===========================================================================

  Widget _buildSearchPanel({
    required List<String> categories,
    required bool mobile,
  }) {
    return Container(
      padding: EdgeInsets.all(
        mobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _border,
        ),
      ),
      child: mobile
          ? Column(
              children: [
                _searchField(),
                const SizedBox(height: 9),
                _categoryDropdown(categories),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _searchField(),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 220,
                  child: _categoryDropdown(categories),
                ),
              ],
            ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      decoration: InputDecoration(
        hintText: 'Search by name or category...',
        hintStyle: const TextStyle(
          color: Color(0xFF62697A),
          fontSize: 11,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _muted,
          size: 19,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                tooltip: 'Clear',
                onPressed: () {
                  _searchController.clear();
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: _muted,
                  size: 17,
                ),
              )
            : null,
        filled: true,
        fillColor: _panel2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: _border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: _violet,
          ),
        ),
      ),
    );
  }

  Widget _categoryDropdown(List<String> categories) {
    final String value = categories.contains(
      _selectedCategory,
    )
        ? _selectedCategory
        : 'All';

    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: _panel2,
      isExpanded: true,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.category_rounded,
          color: _muted,
          size: 18,
        ),
        filled: true,
        fillColor: _panel2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: _border,
          ),
        ),
      ),
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(
            category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  // ===========================================================================
  // FANDOM ROW
  // ===========================================================================

  Widget _fandomRow(
    DocumentSnapshot<Map<String, dynamic>> document, {
    required bool mobile,
    required bool tablet,
  }) {
    final Map<String, dynamic> data =
        document.data() ?? {};

    final String name = _stringValue(
      data['name'],
    ).trim();

    final String category = _stringValue(
      data['category'],
    ).trim();

    final String description = _stringValue(
      data['description'],
    ).trim();

    final String status = _stringValue(
      data['status'],
    ).trim();

    final bool isActive = data['isActive'] == true;

    final List<String> images = _getImages(data);

    final Uint8List? imageBytes = images.isNotEmpty
        ? _decodeBase64Image(images.first)
        : null;

    if (mobile) {
      return _mobileFandomCard(
        document: document,
        name: name,
        category: category,
        description: description,
        status: status,
        isActive: isActive,
        images: images,
        imageBytes: imageBytes,
      );
    }

    return _desktopFandomCard(
      document: document,
      name: name,
      category: category,
      description: description,
      status: status,
      isActive: isActive,
      images: images,
      imageBytes: imageBytes,
      tablet: tablet,
    );
  }

  // ===========================================================================
  // DESKTOP CARD
  // ===========================================================================

  Widget _desktopFandomCard({
    required DocumentSnapshot<Map<String, dynamic>> document,
    required String name,
    required String category,
    required String description,
    required String status,
    required bool isActive,
    required List<String> images,
    required Uint8List? imageBytes,
    required bool tablet,
  }) {
    final double imageSize = tablet ? 74 : 86;

    return Container(
      padding: EdgeInsets.all(
        tablet ? 11 : 13,
      ),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Row(
        children: [
          _mainImage(
            bytes: imageBytes,
            size: imageSize,
          ),

          SizedBox(width: tablet ? 11 : 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name.isEmpty
                            ? 'Unnamed Fandom'
                            : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: tablet ? 14 : 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (category.isNotEmpty) ...[
                      const SizedBox(width: 7),
                      Flexible(
                        child: _smallTag(
                          category,
                          _violet,
                        ),
                      ),
                    ],
                  ],
                ),

                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: tablet ? 2 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ],

                const SizedBox(height: 7),

                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    if (status.isNotEmpty)
                      _statusTag(status),
                    _smallTag(
                      isActive ? 'ACTIVE' : 'INACTIVE',
                      isActive
                          ? const Color(0xFF38B27A)
                          : const Color(0xFF62697A),
                    ),
                    _smallTag(
                      '${images.length} image${images.length == 1 ? '' : 's'}',
                      const Color(0xFF5D86E8),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          _actionButtons(document),
        ],
      ),
    );
  }

  // ===========================================================================
  // MOBILE CARD
  // ===========================================================================

  Widget _mobileFandomCard({
    required DocumentSnapshot<Map<String, dynamic>> document,
    required String name,
    required String category,
    required String description,
    required String status,
    required bool isActive,
    required List<String> images,
    required Uint8List? imageBytes,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _mainImage(
                bytes: imageBytes,
                size: 72,
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty
                          ? 'Unnamed Fandom'
                          : name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    if (category.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      _smallTag(
                        category,
                        _violet,
                      ),
                    ],

                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 10.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    if (status.isNotEmpty)
                      _statusTag(status),
                    _smallTag(
                      isActive ? 'ACTIVE' : 'INACTIVE',
                      isActive
                          ? const Color(0xFF38B27A)
                          : const Color(0xFF62697A),
                    ),
                    _smallTag(
                      '${images.length} image${images.length == 1 ? '' : 's'}',
                      const Color(0xFF5D86E8),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _mobileActionMenu(document),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // IMAGE
  // ===========================================================================

  Widget _mainImage({
    required Uint8List? bytes,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _panel2,
        borderRadius: BorderRadius.circular(11),
      ),
      clipBehavior: Clip.antiAlias,
      child: bytes == null
          ? const Icon(
              Icons.image_outlined,
              color: Color(0xFF62697A),
              size: 28,
            )
          : Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.broken_image_outlined,
                  color: Color(0xFF62697A),
                  size: 28,
                );
              },
            ),
    );
  }

  // ===========================================================================
  // ACTIONS
  // ===========================================================================

  Widget _actionButtons(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionButton(
          icon: Icons.edit_rounded,
          tooltip: 'Edit',
          color: _violetLight,
          onPressed: () {
            _openEditDialog(document);
          },
        ),
        const SizedBox(width: 6),
        _actionButton(
          icon: Icons.delete_outline_rounded,
          tooltip: 'Delete',
          color: const Color(0xFFD64545),
          onPressed: () {
            _confirmDelete(document);
          },
        ),
      ],
    );
  }

  Widget _mobileActionMenu(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      color: _panel2,
      elevation: 8,
      icon: const Icon(
        Icons.more_vert_rounded,
        color: Color(0xFF9CA2B3),
        size: 21,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        if (value == 'edit') {
          _openEditDialog(document);
        } else if (value == 'delete') {
          _confirmDelete(document);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: _violetLight,
                size: 18,
              ),
              SizedBox(width: 9),
              Text(
                'Edit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFD64545),
                size: 18,
              ),
              SizedBox(width: 9),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAGS
  // ===========================================================================

  Widget _statusTag(String status) {
    final String normalized = status.toLowerCase();

    final Color color = normalized == 'approved'
        ? const Color(0xFF38B27A)
        : normalized == 'rejected'
            ? const Color(0xFFD64545)
            : const Color(0xFFE0B45A);

    return _smallTag(
      status.toUpperCase(),
      color,
    );
  }

  Widget _smallTag(
    String text,
    Color color,
  ) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 180,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(.20),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          letterSpacing: .15,
        ),
      ),
    );
  }

  // ===========================================================================
  // EMPTY / ERROR
  // ===========================================================================

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 60,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: Color(0xFF62697A),
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'No fandoms found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try changing your search or category filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFD64545).withOpacity(.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFD64545),
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load fandoms',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please check your Firestore connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _violet,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
