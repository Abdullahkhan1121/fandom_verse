// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';

// class AddProductScreen extends StatefulWidget {
//   const AddProductScreen({super.key});

//   @override
//   State<AddProductScreen> createState() => _AddProductScreenState();
// }

// class _AddProductScreenState extends State<AddProductScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _brandController = TextEditingController();
//   final _skuController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _salePriceController = TextEditingController();
//   final _stockController = TextEditingController();
//   final _tagsController = TextEditingController();

//   final ImagePicker _picker = ImagePicker();

//   final List<String> _images = [];

//   bool _isActive = true;
//   bool _isSaving = false;

//   String? _category;

//   final List<String> _categories = [
//     'Figures',
//     'Collectibles',
//     'Clothing',
//     'Accessories',
//     'Electronics',
//     'Gaming',
//     'Comics',
//     'Other',
//   ];

//   // ------------------------------------------------------------
//   // PICK MULTIPLE IMAGES
//   // ------------------------------------------------------------

//   Future<void> _pickImages() async {
//     try {
//       final pickedImages = await _picker.pickMultiImage(
//         imageQuality: 85,
//       );

//       if (pickedImages.isEmpty) return;

//       for (final pickedImage in pickedImages) {
//         final bytes = await pickedImage.readAsBytes();

//         final base64Image = await _convertToBase64(bytes);

//         if (base64Image != null) {
//           setState(() {
//             _images.add(base64Image);
//           });
//         }
//       }
//     } catch (e) {
//       _showMessage(
//         'Could not select images: $e',
//         isError: true,
//       );
//     }
//   }

//   // ------------------------------------------------------------
//   // CONVERT + COMPRESS IMAGE TO BASE64
//   // ------------------------------------------------------------

//   Future<String?> _convertToBase64(Uint8List bytes) async {
//     try {
//       final decoded = img.decodeImage(bytes);

//       if (decoded == null) {
//         return null;
//       }

//       // Resize large images.
//       img.Image resized = decoded;

//       const maxWidth = 1200;
//       const maxHeight = 1200;

//       if (decoded.width > maxWidth || decoded.height > maxHeight) {
//         resized = img.copyResize(
//           decoded,
//           width: decoded.width > decoded.height ? maxWidth : null,
//           height: decoded.height >= decoded.width ? maxHeight : null,
//         );
//       }

//       // JPEG compression.
//       final compressed = img.encodeJpg(
//         resized,
//         quality: 75,
//       );

//       final base64String = base64Encode(compressed);

//       return 'data:image/jpeg;base64,$base64String';
//     } catch (e) {
//       debugPrint('Image conversion error: $e');
//       return null;
//     }
//   }

//   // ------------------------------------------------------------
//   // REMOVE IMAGE
//   // ------------------------------------------------------------

//   void _removeImage(int index) {
//     setState(() {
//       _images.removeAt(index);
//     });
//   }

//   // ------------------------------------------------------------
//   // MOVE IMAGE
//   // ------------------------------------------------------------

//   void _moveImage(int oldIndex, int newIndex) {
//     setState(() {
//       if (newIndex > oldIndex) {
//         newIndex--;
//       }

//       final image = _images.removeAt(oldIndex);
//       _images.insert(newIndex, image);
//     });
//   }

//   // ------------------------------------------------------------
//   // SAVE PRODUCT
//   // ------------------------------------------------------------

//   Future<void> _saveProduct() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_images.isEmpty) {
//       _showMessage(
//         'Please add at least one product image.',
//         isError: true,
//       );
//       return;
//     }

//     if (_category == null) {
//       _showMessage(
//         'Please select a category.',
//         isError: true,
//       );
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       final productRef =
//           FirebaseFirestore.instance.collection('products').doc();

//       final tags = _tagsController.text
//           .split(',')
//           .map((tag) => tag.trim())
//           .where((tag) => tag.isNotEmpty)
//           .toList();

//       final price =
//           double.tryParse(_priceController.text.trim()) ?? 0;

//       final salePrice =
//           double.tryParse(_salePriceController.text.trim());

//       final stock =
//           int.tryParse(_stockController.text.trim()) ?? 0;

//       await productRef.set({
//         'id': productRef.id,

//         'name': _nameController.text.trim(),

//         'description':
//             _descriptionController.text.trim(),

//         'category': _category,

//         'brand': _brandController.text.trim(),

//         'sku': _skuController.text.trim(),

//         'price': price,

//         'salePrice': salePrice,

//         'stock': stock,

//         'tags': tags,

//         // First image = main image.
//         'thumbnail': _images.first,

//         // All images.
//         'images': _images,

//         'isActive': _isActive,

//         'createdAt': FieldValue.serverTimestamp(),

//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;

//       _showMessage(
//         'Product added successfully!',
//       );

//       Navigator.pop(context);
//     } catch (e) {
//       _showMessage(
//         'Failed to add product: $e',
//         isError: true,
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   // ------------------------------------------------------------
//   // VALIDATORS
//   // ------------------------------------------------------------

//   String? _required(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'This field is required';
//     }

//     return null;
//   }

//   String? _priceValidator(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Enter price';
//     }

//     final price = double.tryParse(value);

//     if (price == null || price < 0) {
//       return 'Enter a valid price';
//     }

//     return null;
//   }

//   String? _stockValidator(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Enter stock';
//     }

//     final stock = int.tryParse(value);

//     if (stock == null || stock < 0) {
//       return 'Enter valid stock';
//     }

//     return null;
//   }

//   // ------------------------------------------------------------
//   // MESSAGE
//   // ------------------------------------------------------------

//   void _showMessage(
//     String message, {
//     bool isError = false,
//   }) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor:
//             isError ? Colors.redAccent : Colors.green,
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // UI
//   // ------------------------------------------------------------

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF080A12),

//       appBar: AppBar(
//         backgroundColor: const Color(0xFF080A12),
//         elevation: 0,

//         title: const Text(
//           'Add Product',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//           ),
//         ),

//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ),
//       ),

//       body: SafeArea(
//         child: Form(
//           key: _formKey,

//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               final isDesktop = constraints.maxWidth >= 900;

//               return SingleChildScrollView(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isDesktop ? 32 : 16,
//                   vertical: 24,
//                 ),

//                 child: Center(
//                   child: ConstrainedBox(
//                     constraints: const BoxConstraints(
//                       maxWidth: 1300,
//                     ),

//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,

//                       children: [
//                         _buildHeader(),

//                         const SizedBox(height: 24),

//                         if (isDesktop)
//                           _buildDesktopLayout()
//                         else
//                           _buildMobileLayout(),

//                         const SizedBox(height: 30),

//                         _buildButtons(),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // HEADER
//   // ------------------------------------------------------------

//   Widget _buildHeader() {
//     return Column(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Create New Product',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 28,
//             fontWeight: FontWeight.w800,
//           ),
//         ),

//         const SizedBox(height: 6),

//         Text(
//           'Add a new product to your store.',
//           style: TextStyle(
//             color: Colors.white.withOpacity(.55),
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }

//   // ------------------------------------------------------------
//   // DESKTOP
//   // ------------------------------------------------------------

//   Widget _buildDesktopLayout() {
//     return Row(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,

//       children: [
//         Expanded(
//           flex: 4,
//           child: _buildImageCard(),
//         ),

//         const SizedBox(width: 24),

//         Expanded(
//           flex: 6,
//           child: Column(
//             children: [
//               _buildProductInfoCard(),
//               const SizedBox(height: 20),
//               _buildPricingCard(),
//               const SizedBox(height: 20),
//               _buildExtraCard(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // ------------------------------------------------------------
//   // MOBILE
//   // ------------------------------------------------------------

//   Widget _buildMobileLayout() {
//     return Column(
//       children: [
//         _buildImageCard(),

//         const SizedBox(height: 20),

//         _buildProductInfoCard(),

//         const SizedBox(height: 20),

//         _buildPricingCard(),

//         const SizedBox(height: 20),

//         _buildExtraCard(),
//       ],
//     );
//   }

//   // ------------------------------------------------------------
//   // CARD
//   // ------------------------------------------------------------

//   Widget _card({
//     required Widget child,
//   }) {
//     return Container(
//       width: double.infinity,

//       padding: const EdgeInsets.all(20),

//       decoration: BoxDecoration(
//         color: const Color(0xFF111522),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: Colors.white.withOpacity(.07),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.20),
//             blurRadius: 25,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),

//       child: child,
//     );
//   }

//   // ------------------------------------------------------------
//   // IMAGE CARD
//   // ------------------------------------------------------------

//   Widget _buildImageCard() {
//     return _card(
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           _sectionTitle(
//             'Product Images',
//             'Add multiple images',
//           ),

//           const SizedBox(height: 18),

//           if (_images.isEmpty)
//             _buildUploadBox()
//           else
//             _buildImageGrid(),

//           const SizedBox(height: 12),

//           Text(
//             'First image will be used as the product thumbnail.',
//             style: TextStyle(
//               color: Colors.white.withOpacity(.45),
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // UPLOAD BOX
//   // ------------------------------------------------------------

//   Widget _buildUploadBox() {
//     return InkWell(
//       onTap: _pickImages,

//       borderRadius: BorderRadius.circular(16),

//       child: Container(
//         height: 280,
//         width: double.infinity,

//         decoration: BoxDecoration(
//           color: const Color(0xFF171B2B),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: const Color(0xFF7C5CFC)
//                 .withOpacity(.35),
//             width: 1.5,
//           ),
//         ),

//         child: const Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             Icon(
//               Icons.cloud_upload_outlined,
//               color: Color(0xFF9D87FF),
//               size: 50,
//             ),

//             SizedBox(height: 14),

//             Text(
//               'Upload Product Images',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),

//             SizedBox(height: 6),

//             Text(
//               'Select multiple images',
//               style: TextStyle(
//                 color: Colors.white54,
//                 fontSize: 13,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // IMAGE GRID
//   // ------------------------------------------------------------

//   Widget _buildImageGrid() {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics:
//           const NeverScrollableScrollPhysics(),

//       gridDelegate:
//           const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: 1,
//       ),

//       itemCount: _images.length + 1,

//       itemBuilder: (context, index) {
//         if (index == _images.length) {
//           return _buildAddImageButton();
//         }

//         return _buildImageItem(
//           index,
//         );
//       },
//     );
//   }

//   // ------------------------------------------------------------
//   // IMAGE ITEM
//   // ------------------------------------------------------------

//   Widget _buildImageItem(int index) {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(14),

//           child: Image.memory(
//             base64Decode(
//               _images[index].split(',').last,
//             ),

//             width: double.infinity,
//             height: double.infinity,

//             fit: BoxFit.cover,
//           ),
//         ),

//         if (index == 0)
//           Positioned(
//             left: 8,
//             top: 8,

//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 8,
//                 vertical: 5,
//               ),

//               decoration: BoxDecoration(
//                 color: const Color(0xFF7C5CFC),
//                 borderRadius:
//                     BorderRadius.circular(8),
//               ),

//               child: const Text(
//                 'MAIN',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ),
//           ),

//         Positioned(
//           right: 7,
//           top: 7,

//           child: GestureDetector(
//             onTap: () => _removeImage(index),

//             child: Container(
//               padding: const EdgeInsets.all(6),

//               decoration: const BoxDecoration(
//                 color: Colors.black87,
//                 shape: BoxShape.circle,
//               ),

//               child: const Icon(
//                 Icons.close,
//                 color: Colors.white,
//                 size: 16,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ------------------------------------------------------------
//   // ADD IMAGE BUTTON
//   // ------------------------------------------------------------

//   Widget _buildAddImageButton() {
//     return InkWell(
//       onTap: _pickImages,

//       borderRadius: BorderRadius.circular(14),

//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFF171B2B),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: Colors.white.withOpacity(.08),
//           ),
//         ),

//         child: const Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             Icon(
//               Icons.add_photo_alternate_outlined,
//               color: Color(0xFF9D87FF),
//               size: 35,
//             ),

//             SizedBox(height: 8),

//             Text(
//               'Add Images',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // PRODUCT INFORMATION
//   // ------------------------------------------------------------

//   Widget _buildProductInfoCard() {
//     return _card(
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           _sectionTitle(
//             'Product Information',
//             'Basic product details',
//           ),

//           const SizedBox(height: 20),

//           _field(
//             controller: _nameController,
//             label: 'Product Name',
//             hint: 'Enter product name',
//             icon: Icons.shopping_bag_outlined,
//             validator: _required,
//           ),

//           const SizedBox(height: 16),

//           _field(
//             controller: _descriptionController,
//             label: 'Description',
//             hint: 'Describe your product...',
//             icon: Icons.description_outlined,
//             maxLines: 5,
//             validator: _required,
//           ),

//           const SizedBox(height: 16),

//           Row(
//             children: [
//               Expanded(
//                 child: _dropdown(),
//               ),

//               const SizedBox(width: 14),

//               Expanded(
//                 child: _field(
//                   controller: _brandController,
//                   label: 'Brand',
//                   hint: 'Brand name',
//                   icon: Icons.workspace_premium_outlined,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           _field(
//             controller: _skuController,
//             label: 'SKU',
//             hint: 'e.g. FV-001',
//             icon: Icons.qr_code_2_outlined,
//           ),
//         ],
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // PRICING
//   // ------------------------------------------------------------

//   Widget _buildPricingCard() {
//     return _card(
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           _sectionTitle(
//             'Pricing & Inventory',
//             'Set price and stock',
//           ),

//           const SizedBox(height: 20),

//           Row(
//             children: [
//               Expanded(
//                 child: _field(
//                   controller: _priceController,
//                   label: 'Price',
//                   hint: '0.00',
//                   icon: Icons.payments_outlined,
//                   keyboardType:
//                       const TextInputType.numberWithOptions(
//                     decimal: true,
//                   ),
//                   validator: _priceValidator,
//                 ),
//               ),

//               const SizedBox(width: 14),

//               Expanded(
//                 child: _field(
//                   controller: _salePriceController,
//                   label: 'Sale Price',
//                   hint: 'Optional',
//                   icon: Icons.local_offer_outlined,
//                   keyboardType:
//                       const TextInputType.numberWithOptions(
//                     decimal: true,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           _field(
//             controller: _stockController,
//             label: 'Stock Quantity',
//             hint: '0',
//             icon: Icons.inventory_2_outlined,
//             keyboardType:
//                 TextInputType.number,
//             validator: _stockValidator,
//           ),
//         ],
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // EXTRA
//   // ------------------------------------------------------------

//   Widget _buildExtraCard() {
//     return _card(
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           _sectionTitle(
//             'Additional Information',
//             'Tags and visibility',
//           ),

//           const SizedBox(height: 20),

//           _field(
//             controller: _tagsController,
//             label: 'Tags',
//             hint: 'figure, anime, collectible',
//             icon: Icons.tag_outlined,
//           ),

//           const SizedBox(height: 12),

//           SwitchListTile(
//             contentPadding: EdgeInsets.zero,

//             title: const Text(
//               'Product Active',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),

//             subtitle: Text(
//               'Make this product visible in the store',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(.45),
//               ),
//             ),

//             value: _isActive,

//             activeColor:
//                 const Color(0xFF7C5CFC),

//             onChanged: (value) {
//               setState(() {
//                 _isActive = value;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // DROPDOWN
//   // ------------------------------------------------------------

//   Widget _dropdown() {
//     return DropdownButtonFormField<String>(
//       value: _category,

//       dropdownColor:
//           const Color(0xFF171B2B),

//       style: const TextStyle(
//         color: Colors.white,
//       ),

//       decoration: _inputDecoration(
//         label: 'Category',
//         icon: Icons.category_outlined,
//       ),

//       items: _categories
//           .map(
//             (category) =>
//                 DropdownMenuItem<String>(
//               value: category,
//               child: Text(category),
//             ),
//           )
//           .toList(),

//       onChanged: (value) {
//         setState(() {
//           _category = value;
//         });
//       },
//     );
//   }

//   // ------------------------------------------------------------
//   // TEXT FIELD
//   // ------------------------------------------------------------

//   Widget _field({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     String? Function(String?)? validator,
//     int maxLines = 1,
//     TextInputType? keyboardType,
//   }) {
//     return TextFormField(
//       controller: controller,

//       maxLines: maxLines,

//       keyboardType: keyboardType,

//       validator: validator,

//       style: const TextStyle(
//         color: Colors.white,
//       ),

//       cursorColor:
//           const Color(0xFF9D87FF),

//       decoration: _inputDecoration(
//         label: label,
//         hint: hint,
//         icon: icon,
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // INPUT DECORATION
//   // ------------------------------------------------------------

//   InputDecoration _inputDecoration({
//     required String label,
//     String? hint,
//     required IconData icon,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,

//       labelStyle: TextStyle(
//         color: Colors.white.withOpacity(.65),
//       ),

//       hintStyle: TextStyle(
//         color: Colors.white.withOpacity(.25),
//       ),

//       prefixIcon: Icon(
//         icon,
//         color: const Color(0xFF9D87FF),
//       ),

//       filled: true,

//       fillColor:
//           const Color(0xFF171B2B),

//       border: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),

//       enabledBorder: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(12),
//         borderSide: BorderSide(
//           color: Colors.white.withOpacity(.06),
//         ),
//       ),

//       focusedBorder: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Color(0xFF7C5CFC),
//           width: 1.5,
//         ),
//       ),

//       errorBorder: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Colors.redAccent,
//         ),
//       ),

//       focusedErrorBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Colors.redAccent,
//         ),
//       ),

//       contentPadding:
//           const EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: 17,
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // SECTION TITLE
//   // ------------------------------------------------------------

//   Widget _sectionTitle(
//     String title,
//     String subtitle,
//   ) {
//     return Column(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,

//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.w800,
//           ),
//         ),

//         const SizedBox(height: 4),

//         Text(
//           subtitle,
//           style: TextStyle(
//             color: Colors.white.withOpacity(.42),
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }

//   // ------------------------------------------------------------
//   // BUTTONS
//   // ------------------------------------------------------------

//   Widget _buildButtons() {
//     return Row(
//       mainAxisAlignment:
//           MainAxisAlignment.end,

//       children: [
//         OutlinedButton(
//           onPressed: _isSaving
//               ? null
//               : () => Navigator.pop(context),

//           style: OutlinedButton.styleFrom(
//             foregroundColor: Colors.white70,

//             side: BorderSide(
//               color: Colors.white.withOpacity(.15),
//             ),

//             padding:
//                 const EdgeInsets.symmetric(
//               horizontal: 24,
//               vertical: 16,
//             ),

//             shape:
//                 RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(12),
//             ),
//           ),

//           child: const Text('Cancel'),
//         ),

//         const SizedBox(width: 12),

//         ElevatedButton(
//           onPressed:
//               _isSaving ? null : _saveProduct,

//           style: ElevatedButton.styleFrom(
//             backgroundColor:
//                 const Color(0xFF7C5CFC),

//             foregroundColor: Colors.white,

//             padding:
//                 const EdgeInsets.symmetric(
//               horizontal: 28,
//               vertical: 16,
//             ),

//             shape:
//                 RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(12),
//             ),

//             elevation: 0,
//           ),

//           child: _isSaving
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child:
//                       CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.white,
//                   ),
//                 )
//               : const Row(
//                   mainAxisSize:
//                       MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.add,
//                       size: 20,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       'Add Product',
//                       style: TextStyle(
//                         fontWeight:
//                             FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _brandController.dispose();
//     _skuController.dispose();
//     _priceController.dispose();
//     _salePriceController.dispose();
//     _stockController.dispose();
//     _tagsController.dispose();

//     super.dispose();
//   }
// }




import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  // ============================================================
  // IMAGE
  // ============================================================

  final ImagePicker _picker = ImagePicker();

  final List<String> _images = [];

  // ============================================================
  // STATE
  // ============================================================

  bool _isAvailable = true;
  bool _isSaving = false;

  String? _currency;
  String? _category;

  // ============================================================
  // CATEGORIES
  // ============================================================

  final List<String> _categories = [
    'Figures',
    'Collectibles',
    'Clothing',
    'Accessories',
    'Electronics',
    'Gaming',
    'Comics',
    'Other',
  ];

  // ============================================================
  // CURRENCIES
  // ============================================================

  final List<String> _currencies = [
    'PKR',
    'USD',
    'EUR',
    'GBP',
    'AED',
    'SAR',
  ];

  // ============================================================
  // PICK MULTIPLE IMAGES
  // ============================================================

  Future<void> _pickImages() async {
    try {
      final pickedImages = await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (pickedImages.isEmpty) {
        return;
      }

      for (final pickedImage in pickedImages) {
        final bytes = await pickedImage.readAsBytes();

        final base64Image = await _convertToBase64(bytes);

        if (base64Image != null) {
          if (!mounted) return;

          setState(() {
            _images.add(base64Image);
          });
        }
      }
    } catch (e) {
      _showMessage(
        'Could not select images: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // CONVERT + COMPRESS IMAGE TO BASE64
  // ============================================================

  Future<String?> _convertToBase64(
    Uint8List bytes,
  ) async {
    try {
      final decoded = img.decodeImage(bytes);

      if (decoded == null) {
        return null;
      }

      img.Image resized = decoded;

      const maxWidth = 1200;
      const maxHeight = 1200;

      if (decoded.width > maxWidth ||
          decoded.height > maxHeight) {
        resized = img.copyResize(
          decoded,
          width: decoded.width > decoded.height
              ? maxWidth
              : null,
          height: decoded.height >= decoded.width
              ? maxHeight
              : null,
        );
      }

      final compressed = img.encodeJpg(
        resized,
        quality: 75,
      );

      final base64String = base64Encode(
        compressed,
      );

      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint(
        'Image conversion error: $e',
      );

      return null;
    }
  }

  // ============================================================
  // REMOVE IMAGE
  // ============================================================

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // ============================================================
  // MOVE IMAGE
  // ============================================================

  void _moveImage(
    int oldIndex,
    int newIndex,
  ) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex--;
      }

      final image = _images.removeAt(
        oldIndex,
      );

      _images.insert(
        newIndex,
        image,
      );
    });
  }

  // ============================================================
  // GENERATE RANDOM FANDOM ID
  // ============================================================

  String _generateFandomId() {
    final documentId = FirebaseFirestore
        .instance
        .collection('products')
        .doc()
        .id;

    return 'FND-${documentId.substring(0, 12).toUpperCase()}';
  }

  // ============================================================
  // SAVE PRODUCT
  // ============================================================

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_images.isEmpty) {
      _showMessage(
        'Please add at least one product image.',
        isError: true,
      );

      return;
    }

    if (_category == null) {
      _showMessage(
        'Please select a category.',
        isError: true,
      );

      return;
    }

    if (_currency == null) {
      _showMessage(
        'Please select a currency.',
        isError: true,
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final productRef = FirebaseFirestore
          .instance
          .collection('products')
          .doc();

      final fandomId = _generateFandomId();

      final currentUser =
          FirebaseAuth.instance.currentUser;

      final price = double.tryParse(
            _priceController.text.trim(),
          ) ??
          0;

      final stock = int.tryParse(
            _stockController.text.trim(),
          ) ??
          0;

      final now = FieldValue.serverTimestamp();

      await productRef.set({
        // ======================================================
        // REQUIRED PRODUCT FIELDS
        // ======================================================

        'name': _nameController.text.trim(),

        'description':
            _descriptionController.text.trim(),

        'price': price,

        'currency': _currency,

        // First Base64 image
        'imageUrl': _images.first,

        // Random fandom ID
        'fandomId': fandomId,

        'category': _category,

        'stock': stock,

        'isAvailable': _isAvailable,

        'createdAt': now,

        'updatedAt': now,

        'createdBy': currentUser?.uid,
      });

      if (!mounted) {
        return;
      }

      _showMessage(
        'Product added successfully!',
      );

      Navigator.pop(context);
    } catch (e) {
      _showMessage(
        'Failed to add product: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // VALIDATORS
  // ============================================================

  String? _required(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? _priceValidator(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Enter price';
    }

    final price = double.tryParse(
      value.trim(),
    );

    if (price == null || price < 0) {
      return 'Enter a valid price';
    }

    return null;
  }

  String? _stockValidator(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Enter stock';
    }

    final stock = int.tryParse(
      value.trim(),
    );

    if (stock == null || stock < 0) {
      return 'Enter valid stock';
    }

    return null;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
        backgroundColor: isError
            ? Colors.redAccent
            : Colors.green,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF080A12),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF080A12),

        elevation: 0,

        title: const Text(
          'Add Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: LayoutBuilder(
            builder:
                (context, constraints) {
              final isDesktop =
                  constraints.maxWidth >=
                      900;

              return SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(
                  horizontal:
                      isDesktop ? 32 : 16,
                  vertical: 24,
                ),

                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 1300,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        _buildHeader(),

                        const SizedBox(
                          height: 24,
                        ),

                        if (isDesktop)
                          _buildDesktopLayout()
                        else
                          _buildMobileLayout(),

                        const SizedBox(
                          height: 30,
                        ),

                        _buildButtons(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          'Create New Product',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          'Add a new product to your store.',
          style: TextStyle(
            color: Colors.white
                .withOpacity(.55),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DESKTOP LAYOUT
  // ============================================================

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Expanded(
          flex: 4,
          child:
              _buildImageCard(),
        ),

        const SizedBox(
          width: 24,
        ),

        Expanded(
          flex: 6,

          child: Column(
            children: [
              _buildProductInfoCard(),

              const SizedBox(
                height: 20,
              ),

              _buildPricingCard(),

              const SizedBox(
                height: 20,
              ),

              _buildAvailabilityCard(),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE LAYOUT
  // ============================================================

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildImageCard(),

        const SizedBox(
          height: 20,
        ),

        _buildProductInfoCard(),

        const SizedBox(
          height: 20,
        ),

        _buildPricingCard(),

        const SizedBox(
          height: 20,
        ),

        _buildAvailabilityCard(),
      ],
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color:
            const Color(0xFF111522),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Colors.white
              .withOpacity(.07),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.20),

            blurRadius: 25,

            offset:
                const Offset(0, 10),
          ),
        ],
      ),

      child: child,
    );
  }

  // ============================================================
  // IMAGE CARD
  // ============================================================

  Widget _buildImageCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _sectionTitle(
            'Product Images',
            'Add multiple images',
          ),

          const SizedBox(
            height: 18,
          ),

          if (_images.isEmpty)
            _buildUploadBox()
          else
            _buildImageGrid(),

          const SizedBox(
            height: 12,
          ),

          Text(
            'First image will be used as the product image.',
            style: TextStyle(
              color: Colors.white
                  .withOpacity(.45),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UPLOAD BOX
  // ============================================================

  Widget _buildUploadBox() {
    return InkWell(
      onTap: _pickImages,

      borderRadius:
          BorderRadius.circular(16),

      child: Container(
        height: 280,

        width: double.infinity,

        decoration:
            BoxDecoration(
          color:
              const Color(0xFF171B2B),

          borderRadius:
              BorderRadius.circular(16),

          border: Border.all(
            color:
                const Color(0xFF7C5CFC)
                    .withOpacity(.35),

            width: 1.5,
          ),
        ),

        child: const Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons
                  .cloud_upload_outlined,
              color:
                  Color(0xFF9D87FF),
              size: 50,
            ),

            SizedBox(
              height: 14,
            ),

            Text(
              'Upload Product Images',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            SizedBox(
              height: 6,
            ),

            Text(
              'Select multiple images',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE GRID
  // ============================================================

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,

        crossAxisSpacing: 12,

        mainAxisSpacing: 12,

        childAspectRatio: 1,
      ),

      itemCount:
          _images.length + 1,

      itemBuilder:
          (context, index) {
        if (index ==
            _images.length) {
          return _buildAddImageButton();
        }

        return _buildImageItem(
          index,
        );
      },
    );
  }

  // ============================================================
  // IMAGE ITEM
  // ============================================================

  Widget _buildImageItem(
    int index,
  ) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius:
              BorderRadius.circular(14),

          child: Image.memory(
            base64Decode(
              _images[index]
                  .split(',')
                  .last,
            ),

            width:
                double.infinity,

            height:
                double.infinity,

            fit: BoxFit.cover,
          ),
        ),

        // MAIN IMAGE LABEL
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
                        0xFF7C5CFC),

                borderRadius:
                    BorderRadius
                        .circular(8),
              ),

              child: const Text(
                'MAIN',
                style: TextStyle(
                  color:
                      Colors.white,

                  fontSize: 10,

                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),

        // REMOVE
        Positioned(
          right: 7,
          top: 7,

          child:
              GestureDetector(
            onTap: () =>
                _removeImage(index),

            child: Container(
              padding:
                  const EdgeInsets
                      .all(6),

              decoration:
                  const BoxDecoration(
                color:
                    Colors.black87,
                shape:
                    BoxShape.circle,
              ),

              child: const Icon(
                Icons.close,
                color:
                    Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ADD IMAGE BUTTON
  // ============================================================

  Widget _buildAddImageButton() {
    return InkWell(
      onTap: _pickImages,

      borderRadius:
          BorderRadius.circular(14),

      child: Container(
        decoration:
            BoxDecoration(
          color:
              const Color(0xFF171B2B),

          borderRadius:
              BorderRadius.circular(14),

          border: Border.all(
            color: Colors.white
                .withOpacity(.08),
          ),
        ),

        child: const Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons
                  .add_photo_alternate_outlined,
              color:
                  Color(0xFF9D87FF),
              size: 35,
            ),

            SizedBox(
              height: 8,
            ),

            Text(
              'Add Images',
              style: TextStyle(
                color:
                    Colors.white70,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT INFORMATION
  // ============================================================

  Widget _buildProductInfoCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _sectionTitle(
            'Product Information',
            'Basic product details',
          ),

          const SizedBox(
            height: 20,
          ),

          // NAME
          _field(
            controller:
                _nameController,

            label:
                'Product Name',

            hint:
                'Enter product name',

            icon:
                Icons.shopping_bag_outlined,

            validator:
                _required,
          ),

          const SizedBox(
            height: 16,
          ),

          // DESCRIPTION
          _field(
            controller:
                _descriptionController,

            label:
                'Description',

            hint:
                'Describe your product...',

            icon:
                Icons.description_outlined,

            maxLines: 5,

            validator:
                _required,
          ),

          const SizedBox(
            height: 16,
          ),

          // CATEGORY
          _categoryDropdown(),

          const SizedBox(
            height: 16,
          ),

          // CURRENCY
          _currencyDropdown(),
        ],
      ),
    );
  }

  // ============================================================
  // PRICING
  // ============================================================

  Widget _buildPricingCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _sectionTitle(
            'Pricing & Inventory',
            'Set product price and stock',
          ),

          const SizedBox(
            height: 20,
          ),

          LayoutBuilder(
            builder:
                (context, constraints) {
              if (constraints
                      .maxWidth <
                  500) {
                return Column(
                  children: [
                    _field(
                      controller:
                          _priceController,

                      label:
                          'Price',

                      hint:
                          '0.00',

                      icon:
                          Icons.payments_outlined,

                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal:
                            true,
                      ),

                      validator:
                          _priceValidator,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _field(
                      controller:
                          _stockController,

                      label:
                          'Stock',

                      hint:
                          '0',

                      icon:
                          Icons.inventory_2_outlined,

                      keyboardType:
                          TextInputType
                              .number,

                      validator:
                          _stockValidator,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _field(
                      controller:
                          _priceController,

                      label:
                          'Price',

                      hint:
                          '0.00',

                      icon:
                          Icons
                              .payments_outlined,

                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal:
                            true,
                      ),

                      validator:
                          _priceValidator,
                    ),
                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  Expanded(
                    child: _field(
                      controller:
                          _stockController,

                      label:
                          'Stock',

                      hint:
                          '0',

                      icon:
                          Icons
                              .inventory_2_outlined,

                      keyboardType:
                          TextInputType
                              .number,

                      validator:
                          _stockValidator,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AVAILABILITY
  // ============================================================

  Widget _buildAvailabilityCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _sectionTitle(
            'Product Availability',
            'Control whether the product is available',
          ),

          const SizedBox(
            height: 12,
          ),

          SwitchListTile(
            contentPadding:
                EdgeInsets.zero,

            title: const Text(
              'Available for Sale',
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            subtitle: Text(
              _isAvailable
                  ? 'Product is currently available'
                  : 'Product is currently unavailable',

              style: TextStyle(
                color: Colors.white
                    .withOpacity(.45),
              ),
            ),

            value: _isAvailable,

            activeColor:
                const Color(
                    0xFF7C5CFC),

            onChanged:
                (value) {
              setState(() {
                _isAvailable =
                    value;
              });
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY DROPDOWN
  // ============================================================

  Widget _categoryDropdown() {
    return DropdownButtonFormField<
        String>(
      value: _category,

      dropdownColor:
          const Color(0xFF171B2B),

      style: const TextStyle(
        color: Colors.white,
      ),

      decoration:
          _inputDecoration(
        label: 'Category',
        icon:
            Icons.category_outlined,
      ),

      items: _categories
          .map(
            (category) =>
                DropdownMenuItem<
                    String>(
              value: category,
              child:
                  Text(category),
            ),
          )
          .toList(),

      onChanged: (value) {
        setState(() {
          _category = value;
        });
      },

      validator: (value) {
        if (value == null) {
          return 'Select category';
        }

        return null;
      },
    );
  }

  // ============================================================
  // CURRENCY DROPDOWN
  // ============================================================

  Widget _currencyDropdown() {
    return DropdownButtonFormField<
        String>(
      value: _currency,

      dropdownColor:
          const Color(0xFF171B2B),

      style: const TextStyle(
        color: Colors.white,
      ),

      decoration:
          _inputDecoration(
        label: 'Currency',
        icon:
            Icons.currency_exchange,
      ),

      items: _currencies
          .map(
            (currency) =>
                DropdownMenuItem<
                    String>(
              value: currency,
              child:
                  Text(currency),
            ),
          )
          .toList(),

      onChanged: (value) {
        setState(() {
          _currency = value;
        });
      },

      validator: (value) {
        if (value == null) {
          return 'Select currency';
        }

        return null;
      },
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _field({
    required TextEditingController
        controller,

    required String label,

    required String hint,

    required IconData icon,

    String? Function(String?)?
        validator,

    int maxLines = 1,

    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,

      maxLines: maxLines,

      keyboardType:
          keyboardType,

      validator: validator,

      style: const TextStyle(
        color: Colors.white,
      ),

      cursorColor:
          const Color(0xFF9D87FF),

      decoration:
          _inputDecoration(
        label: label,
        hint: hint,
        icon: icon,
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,

      hintText: hint,

      labelStyle: TextStyle(
        color: Colors.white
            .withOpacity(.65),
      ),

      hintStyle: TextStyle(
        color: Colors.white
            .withOpacity(.25),
      ),

      prefixIcon: Icon(
        icon,
        color:
            const Color(0xFF9D87FF),
      ),

      filled: true,

      fillColor:
          const Color(0xFF171B2B),

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),

        borderSide:
            BorderSide.none,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),

        borderSide:
            BorderSide(
          color: Colors.white
              .withOpacity(.06),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),

        borderSide:
            const BorderSide(
          color:
              Color(0xFF7C5CFC),

          width: 1.5,
        ),
      ),

      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),

        borderSide:
            const BorderSide(
          color:
              Colors.redAccent,
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),

        borderSide:
            const BorderSide(
          color:
              Colors.redAccent,
        ),
      ),

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          subtitle,

          style: TextStyle(
            color: Colors.white
                .withOpacity(.42),

            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUTTONS
  // ============================================================

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.end,

      children: [
        OutlinedButton(
          onPressed: _isSaving
              ? null
              : () =>
                  Navigator.pop(
                    context,
                  ),

          style:
              OutlinedButton.styleFrom(
            foregroundColor:
                Colors.white70,

            side: BorderSide(
              color: Colors.white
                  .withOpacity(.15),
            ),

            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 24,
              vertical: 16,
            ),

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
          ),

          child:
              const Text('Cancel'),
        ),

        const SizedBox(
          width: 12,
        ),

        ElevatedButton(
          onPressed: _isSaving
              ? null
              : _saveProduct,

          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(
                    0xFF7C5CFC),

            foregroundColor:
                Colors.white,

            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 28,
              vertical: 16,
            ),

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            elevation: 0,
          ),

          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,

                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                        Colors.white,
                  ),
                )
              : const Row(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    Icon(
                      Icons.add,
                      size: 20,
                    ),

                    SizedBox(
                      width: 8,
                    ),

                    Text(
                      'Add Product',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();

    super.dispose();
  }
}