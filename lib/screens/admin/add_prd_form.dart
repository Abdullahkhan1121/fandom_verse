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




// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
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

//   // ============================================================
//   // CONTROLLERS
//   // ============================================================

//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _stockController = TextEditingController();

//   // ============================================================
//   // IMAGE
//   // ============================================================

//   final ImagePicker _picker = ImagePicker();

//   final List<String> _images = [];

//   // ============================================================
//   // STATE
//   // ============================================================

//   bool _isAvailable = true;
//   bool _isSaving = false;

//   String? _currency;
//   String? _category;

//   // ============================================================
//   // CATEGORIES
//   // ============================================================

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

//   // ============================================================
//   // CURRENCIES
//   // ============================================================

//   final List<String> _currencies = [
//     'PKR',
//     'USD',
//     'EUR',
//     'GBP',
//     'AED',
//     'SAR',
//   ];

//   // ============================================================
//   // PICK MULTIPLE IMAGES
//   // ============================================================

//   Future<void> _pickImages() async {
//     try {
//       final pickedImages = await _picker.pickMultiImage(
//         imageQuality: 85,
//       );

//       if (pickedImages.isEmpty) {
//         return;
//       }

//       for (final pickedImage in pickedImages) {
//         final bytes = await pickedImage.readAsBytes();

//         final base64Image = await _convertToBase64(bytes);

//         if (base64Image != null) {
//           if (!mounted) return;

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

//   // ============================================================
//   // CONVERT + COMPRESS IMAGE TO BASE64
//   // ============================================================

//   Future<String?> _convertToBase64(
//     Uint8List bytes,
//   ) async {
//     try {
//       final decoded = img.decodeImage(bytes);

//       if (decoded == null) {
//         return null;
//       }

//       img.Image resized = decoded;

//       const maxWidth = 1200;
//       const maxHeight = 1200;

//       if (decoded.width > maxWidth ||
//           decoded.height > maxHeight) {
//         resized = img.copyResize(
//           decoded,
//           width: decoded.width > decoded.height
//               ? maxWidth
//               : null,
//           height: decoded.height >= decoded.width
//               ? maxHeight
//               : null,
//         );
//       }

//       final compressed = img.encodeJpg(
//         resized,
//         quality: 75,
//       );

//       final base64String = base64Encode(
//         compressed,
//       );

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
//   // MOVE IMAGE
//   // ============================================================

//   void _moveImage(
//     int oldIndex,
//     int newIndex,
//   ) {
//     setState(() {
//       if (newIndex > oldIndex) {
//         newIndex--;
//       }

//       final image = _images.removeAt(
//         oldIndex,
//       );

//       _images.insert(
//         newIndex,
//         image,
//       );
//     });
//   }

//   // ============================================================
//   // GENERATE RANDOM FANDOM ID
//   // ============================================================

//   String _generateFandomId() {
//     final documentId = FirebaseFirestore
//         .instance
//         .collection('products')
//         .doc()
//         .id;

//     return 'FND-${documentId.substring(0, 12).toUpperCase()}';
//   }

//   // ============================================================
//   // SAVE PRODUCT
//   // ============================================================

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

//     if (_currency == null) {
//       _showMessage(
//         'Please select a currency.',
//         isError: true,
//       );

//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       final productRef = FirebaseFirestore
//           .instance
//           .collection('products')
//           .doc();

//       final fandomId = _generateFandomId();

//       final currentUser =
//           FirebaseAuth.instance.currentUser;

//       final price = double.tryParse(
//             _priceController.text.trim(),
//           ) ??
//           0;

//       final stock = int.tryParse(
//             _stockController.text.trim(),
//           ) ??
//           0;

//       final now = FieldValue.serverTimestamp();

//       await productRef.set({
//         // ======================================================
//         // REQUIRED PRODUCT FIELDS
//         // ======================================================

//         'name': _nameController.text.trim(),

//         'description':
//             _descriptionController.text.trim(),

//         'price': price,

//         'currency': _currency,

//         // First Base64 image
//         'imageUrl': _images.first,

//         // Random fandom ID
//         'fandomId': fandomId,

//         'category': _category,

//         'stock': stock,

//         'isAvailable': _isAvailable,

//         'createdAt': now,

//         'updatedAt': now,

//         'createdBy': currentUser?.uid,
//       });

//       if (!mounted) {
//         return;
//       }

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

//   // ============================================================
//   // VALIDATORS
//   // ============================================================

//   String? _required(String? value) {
//     if (value == null ||
//         value.trim().isEmpty) {
//       return 'This field is required';
//     }

//     return null;
//   }

//   String? _priceValidator(
//     String? value,
//   ) {
//     if (value == null ||
//         value.trim().isEmpty) {
//       return 'Enter price';
//     }

//     final price = double.tryParse(
//       value.trim(),
//     );

//     if (price == null || price < 0) {
//       return 'Enter a valid price';
//     }

//     return null;
//   }

//   String? _stockValidator(
//     String? value,
//   ) {
//     if (value == null ||
//         value.trim().isEmpty) {
//       return 'Enter stock';
//     }

//     final stock = int.tryParse(
//       value.trim(),
//     );

//     if (stock == null || stock < 0) {
//       return 'Enter valid stock';
//     }

//     return null;
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//     String message, {
//     bool isError = false,
//   }) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior:
//             SnackBarBehavior.floating,
//         backgroundColor: isError
//             ? Colors.redAccent
//             : Colors.green,
//       ),
//     );
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           const Color(0xFF080A12),

//       appBar: AppBar(
//         backgroundColor:
//             const Color(0xFF080A12),

//         elevation: 0,

//         title: const Text(
//           'Add Product',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight:
//                 FontWeight.w700,
//           ),
//         ),

//         iconTheme:
//             const IconThemeData(
//           color: Colors.white,
//         ),
//       ),

//       body: SafeArea(
//         child: Form(
//           key: _formKey,

//           child: LayoutBuilder(
//             builder:
//                 (context, constraints) {
//               final isDesktop =
//                   constraints.maxWidth >=
//                       900;

//               return SingleChildScrollView(
//                 padding:
//                     EdgeInsets.symmetric(
//                   horizontal:
//                       isDesktop ? 32 : 16,
//                   vertical: 24,
//                 ),

//                 child: Center(
//                   child: ConstrainedBox(
//                     constraints:
//                         const BoxConstraints(
//                       maxWidth: 1300,
//                     ),

//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment
//                               .start,

//                       children: [
//                         _buildHeader(),

//                         const SizedBox(
//                           height: 24,
//                         ),

//                         if (isDesktop)
//                           _buildDesktopLayout()
//                         else
//                           _buildMobileLayout(),

//                         const SizedBox(
//                           height: 30,
//                         ),

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

//   // ============================================================
//   // HEADER
//   // ============================================================

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
//             fontWeight:
//                 FontWeight.w800,
//           ),
//         ),

//         const SizedBox(
//           height: 6,
//         ),

//         Text(
//           'Add a new product to your store.',
//           style: TextStyle(
//             color: Colors.white
//                 .withOpacity(.55),
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // DESKTOP LAYOUT
//   // ============================================================

//   Widget _buildDesktopLayout() {
//     return Row(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,

//       children: [
//         Expanded(
//           flex: 4,
//           child:
//               _buildImageCard(),
//         ),

//         const SizedBox(
//           width: 24,
//         ),

//         Expanded(
//           flex: 6,

//           child: Column(
//             children: [
//               _buildProductInfoCard(),

//               const SizedBox(
//                 height: 20,
//               ),

//               _buildPricingCard(),

//               const SizedBox(
//                 height: 20,
//               ),

//               _buildAvailabilityCard(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // MOBILE LAYOUT
//   // ============================================================

//   Widget _buildMobileLayout() {
//     return Column(
//       children: [
//         _buildImageCard(),

//         const SizedBox(
//           height: 20,
//         ),

//         _buildProductInfoCard(),

//         const SizedBox(
//           height: 20,
//         ),

//         _buildPricingCard(),

//         const SizedBox(
//           height: 20,
//         ),

//         _buildAvailabilityCard(),
//       ],
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

//       padding:
//           const EdgeInsets.all(20),

//       decoration: BoxDecoration(
//         color:
//             const Color(0xFF111522),

//         borderRadius:
//             BorderRadius.circular(20),

//         border: Border.all(
//           color: Colors.white
//               .withOpacity(.07),
//         ),

//         boxShadow: [
//           BoxShadow(
//             color: Colors.black
//                 .withOpacity(.20),

//             blurRadius: 25,

//             offset:
//                 const Offset(0, 10),
//           ),
//         ],
//       ),

//       child: child,
//     );
//   }

//   // ============================================================
//   // IMAGE CARD
//   // ============================================================

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

//           const SizedBox(
//             height: 18,
//           ),

//           if (_images.isEmpty)
//             _buildUploadBox()
//           else
//             _buildImageGrid(),

//           const SizedBox(
//             height: 12,
//           ),

//           Text(
//             'First image will be used as the product image.',
//             style: TextStyle(
//               color: Colors.white
//                   .withOpacity(.45),
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // UPLOAD BOX
//   // ============================================================

//   Widget _buildUploadBox() {
//     return InkWell(
//       onTap: _pickImages,

//       borderRadius:
//           BorderRadius.circular(16),

//       child: Container(
//         height: 280,

//         width: double.infinity,

//         decoration:
//             BoxDecoration(
//           color:
//               const Color(0xFF171B2B),

//           borderRadius:
//               BorderRadius.circular(16),

//           border: Border.all(
//             color:
//                 const Color(0xFF7C5CFC)
//                     .withOpacity(.35),

//             width: 1.5,
//           ),
//         ),

//         child: const Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             Icon(
//               Icons
//                   .cloud_upload_outlined,
//               color:
//                   Color(0xFF9D87FF),
//               size: 50,
//             ),

//             SizedBox(
//               height: 14,
//             ),

//             Text(
//               'Upload Product Images',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight:
//                     FontWeight.w700,
//               ),
//             ),

//             SizedBox(
//               height: 6,
//             ),

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

//   // ============================================================
//   // IMAGE GRID
//   // ============================================================

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

//       itemCount:
//           _images.length + 1,

//       itemBuilder:
//           (context, index) {
//         if (index ==
//             _images.length) {
//           return _buildAddImageButton();
//         }

//         return _buildImageItem(
//           index,
//         );
//       },
//     );
//   }

//   // ============================================================
//   // IMAGE ITEM
//   // ============================================================

//   Widget _buildImageItem(
//     int index,
//   ) {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius:
//               BorderRadius.circular(14),

//           child: Image.memory(
//             base64Decode(
//               _images[index]
//                   .split(',')
//                   .last,
//             ),

//             width:
//                 double.infinity,

//             height:
//                 double.infinity,

//             fit: BoxFit.cover,
//           ),
//         ),

//         // MAIN IMAGE LABEL
//         if (index == 0)
//           Positioned(
//             left: 8,
//             top: 8,

//             child: Container(
//               padding:
//                   const EdgeInsets
//                       .symmetric(
//                 horizontal: 8,
//                 vertical: 5,
//               ),

//               decoration:
//                   BoxDecoration(
//                 color:
//                     const Color(
//                         0xFF7C5CFC),

//                 borderRadius:
//                     BorderRadius
//                         .circular(8),
//               ),

//               child: const Text(
//                 'MAIN',
//                 style: TextStyle(
//                   color:
//                       Colors.white,

//                   fontSize: 10,

//                   fontWeight:
//                       FontWeight.w800,
//                 ),
//               ),
//             ),
//           ),

//         // REMOVE
//         Positioned(
//           right: 7,
//           top: 7,

//           child:
//               GestureDetector(
//             onTap: () =>
//                 _removeImage(index),

//             child: Container(
//               padding:
//                   const EdgeInsets
//                       .all(6),

//               decoration:
//                   const BoxDecoration(
//                 color:
//                     Colors.black87,
//                 shape:
//                     BoxShape.circle,
//               ),

//               child: const Icon(
//                 Icons.close,
//                 color:
//                     Colors.white,
//                 size: 16,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // ADD IMAGE BUTTON
//   // ============================================================

//   Widget _buildAddImageButton() {
//     return InkWell(
//       onTap: _pickImages,

//       borderRadius:
//           BorderRadius.circular(14),

//       child: Container(
//         decoration:
//             BoxDecoration(
//           color:
//               const Color(0xFF171B2B),

//           borderRadius:
//               BorderRadius.circular(14),

//           border: Border.all(
//             color: Colors.white
//                 .withOpacity(.08),
//           ),
//         ),

//         child: const Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             Icon(
//               Icons
//                   .add_photo_alternate_outlined,
//               color:
//                   Color(0xFF9D87FF),
//               size: 35,
//             ),

//             SizedBox(
//               height: 8,
//             ),

//             Text(
//               'Add Images',
//               style: TextStyle(
//                 color:
//                     Colors.white70,
//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PRODUCT INFORMATION
//   // ============================================================

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

//           const SizedBox(
//             height: 20,
//           ),

//           // NAME
//           _field(
//             controller:
//                 _nameController,

//             label:
//                 'Product Name',

//             hint:
//                 'Enter product name',

//             icon:
//                 Icons.shopping_bag_outlined,

//             validator:
//                 _required,
//           ),

//           const SizedBox(
//             height: 16,
//           ),

//           // DESCRIPTION
//           _field(
//             controller:
//                 _descriptionController,

//             label:
//                 'Description',

//             hint:
//                 'Describe your product...',

//             icon:
//                 Icons.description_outlined,

//             maxLines: 5,

//             validator:
//                 _required,
//           ),

//           const SizedBox(
//             height: 16,
//           ),

//           // CATEGORY
//           _categoryDropdown(),

//           const SizedBox(
//             height: 16,
//           ),

//           // CURRENCY
//           _currencyDropdown(),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PRICING
//   // ============================================================

//   Widget _buildPricingCard() {
//     return _card(
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           _sectionTitle(
//             'Pricing & Inventory',
//             'Set product price and stock',
//           ),

//           const SizedBox(
//             height: 20,
//           ),

//           LayoutBuilder(
//             builder:
//                 (context, constraints) {
//               if (constraints
//                       .maxWidth <
//                   500) {
//                 return Column(
//                   children: [
//                     _field(
//                       controller:
//                           _priceController,

//                       label:
//                           'Price',

//                       hint:
//                           '0.00',

//                       icon:
//                           Icons.payments_outlined,

//                       keyboardType:
//                           const TextInputType
//                               .numberWithOptions(
//                         decimal:
//                             true,
//                       ),

//                       validator:
//                           _priceValidator,
//                     ),

//                     const SizedBox(
//                       height: 16,
//                     ),

//                     _field(
//                       controller:
//                           _stockController,

//                       label:
//                           'Stock',

//                       hint:
//                           '0',

//                       icon:
//                           Icons.inventory_2_outlined,

//                       keyboardType:
//                           TextInputType
//                               .number,

//                       validator:
//                           _stockValidator,
//                     ),
//                   ],
//                 );
//               }

//               return Row(
//                 children: [
//                   Expanded(
//                     child: _field(
//                       controller:
//                           _priceController,

//                       label:
//                           'Price',

//                       hint:
//                           '0.00',

//                       icon:
//                           Icons
//                               .payments_outlined,

//                       keyboardType:
//                           const TextInputType
//                               .numberWithOptions(
//                         decimal:
//                             true,
//                       ),

//                       validator:
//                           _priceValidator,
//                     ),
//                   ),

//                   const SizedBox(
//                     width: 14,
//                   ),

//                   Expanded(
//                     child: _field(
//                       controller:
//                           _stockController,

//                       label:
//                           'Stock',

//                       hint:
//                           '0',

//                       icon:
//                           Icons
//                               .inventory_2_outlined,

//                       keyboardType:
//                           TextInputType
//                               .number,

//                       validator:
//                           _stockValidator,
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // AVAILABILITY
//   // ============================================================

//   Widget _buildAvailabilityCard() {
//     return _card(
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           _sectionTitle(
//             'Product Availability',
//             'Control whether the product is available',
//           ),

//           const SizedBox(
//             height: 12,
//           ),

//           SwitchListTile(
//             contentPadding:
//                 EdgeInsets.zero,

//             title: const Text(
//               'Available for Sale',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),

//             subtitle: Text(
//               _isAvailable
//                   ? 'Product is currently available'
//                   : 'Product is currently unavailable',

//               style: TextStyle(
//                 color: Colors.white
//                     .withOpacity(.45),
//               ),
//             ),

//             value: _isAvailable,

//             activeColor:
//                 const Color(
//                     0xFF7C5CFC),

//             onChanged:
//                 (value) {
//               setState(() {
//                 _isAvailable =
//                     value;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY DROPDOWN
//   // ============================================================

//   Widget _categoryDropdown() {
//     return DropdownButtonFormField<
//         String>(
//       value: _category,

//       dropdownColor:
//           const Color(0xFF171B2B),

//       style: const TextStyle(
//         color: Colors.white,
//       ),

//       decoration:
//           _inputDecoration(
//         label: 'Category',
//         icon:
//             Icons.category_outlined,
//       ),

//       items: _categories
//           .map(
//             (category) =>
//                 DropdownMenuItem<
//                     String>(
//               value: category,
//               child:
//                   Text(category),
//             ),
//           )
//           .toList(),

//       onChanged: (value) {
//         setState(() {
//           _category = value;
//         });
//       },

//       validator: (value) {
//         if (value == null) {
//           return 'Select category';
//         }

//         return null;
//       },
//     );
//   }

//   // ============================================================
//   // CURRENCY DROPDOWN
//   // ============================================================

//   Widget _currencyDropdown() {
//     return DropdownButtonFormField<
//         String>(
//       value: _currency,

//       dropdownColor:
//           const Color(0xFF171B2B),

//       style: const TextStyle(
//         color: Colors.white,
//       ),

//       decoration:
//           _inputDecoration(
//         label: 'Currency',
//         icon:
//             Icons.currency_exchange,
//       ),

//       items: _currencies
//           .map(
//             (currency) =>
//                 DropdownMenuItem<
//                     String>(
//               value: currency,
//               child:
//                   Text(currency),
//             ),
//           )
//           .toList(),

//       onChanged: (value) {
//         setState(() {
//           _currency = value;
//         });
//       },

//       validator: (value) {
//         if (value == null) {
//           return 'Select currency';
//         }

//         return null;
//       },
//     );
//   }

//   // ============================================================
//   // TEXT FIELD
//   // ============================================================

//   Widget _field({
//     required TextEditingController
//         controller,

//     required String label,

//     required String hint,

//     required IconData icon,

//     String? Function(String?)?
//         validator,

//     int maxLines = 1,

//     TextInputType? keyboardType,
//   }) {
//     return TextFormField(
//       controller: controller,

//       maxLines: maxLines,

//       keyboardType:
//           keyboardType,

//       validator: validator,

//       style: const TextStyle(
//         color: Colors.white,
//       ),

//       cursorColor:
//           const Color(0xFF9D87FF),

//       decoration:
//           _inputDecoration(
//         label: label,
//         hint: hint,
//         icon: icon,
//       ),
//     );
//   }

//   // ============================================================
//   // INPUT DECORATION
//   // ============================================================

//   InputDecoration _inputDecoration({
//     required String label,
//     String? hint,
//     required IconData icon,
//   }) {
//     return InputDecoration(
//       labelText: label,

//       hintText: hint,

//       labelStyle: TextStyle(
//         color: Colors.white
//             .withOpacity(.65),
//       ),

//       hintStyle: TextStyle(
//         color: Colors.white
//             .withOpacity(.25),
//       ),

//       prefixIcon: Icon(
//         icon,
//         color:
//             const Color(0xFF9D87FF),
//       ),

//       filled: true,

//       fillColor:
//           const Color(0xFF171B2B),

//       border:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(
//           12,
//         ),

//         borderSide:
//             BorderSide.none,
//       ),

//       enabledBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(
//           12,
//         ),

//         borderSide:
//             BorderSide(
//           color: Colors.white
//               .withOpacity(.06),
//         ),
//       ),

//       focusedBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(
//           12,
//         ),

//         borderSide:
//             const BorderSide(
//           color:
//               Color(0xFF7C5CFC),

//           width: 1.5,
//         ),
//       ),

//       errorBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(
//           12,
//         ),

//         borderSide:
//             const BorderSide(
//           color:
//               Colors.redAccent,
//         ),
//       ),

//       focusedErrorBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(
//           12,
//         ),

//         borderSide:
//             const BorderSide(
//           color:
//               Colors.redAccent,
//         ),
//       ),

//       contentPadding:
//           const EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: 17,
//       ),
//     );
//   }

//   // ============================================================
//   // SECTION TITLE
//   // ============================================================

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

//           style:
//               const TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight:
//                 FontWeight.w800,
//           ),
//         ),

//         const SizedBox(
//           height: 4,
//         ),

//         Text(
//           subtitle,

//           style: TextStyle(
//             color: Colors.white
//                 .withOpacity(.42),

//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // BUTTONS
//   // ============================================================

//   Widget _buildButtons() {
//     return Row(
//       mainAxisAlignment:
//           MainAxisAlignment.end,

//       children: [
//         OutlinedButton(
//           onPressed: _isSaving
//               ? null
//               : () =>
//                   Navigator.pop(
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
//                 const EdgeInsets
//                     .symmetric(
//               horizontal: 24,
//               vertical: 16,
//             ),

//             shape:
//                 RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(
//                 12,
//               ),
//             ),
//           ),

//           child:
//               const Text('Cancel'),
//         ),

//         const SizedBox(
//           width: 12,
//         ),

//         ElevatedButton(
//           onPressed: _isSaving
//               ? null
//               : _saveProduct,

//           style:
//               ElevatedButton.styleFrom(
//             backgroundColor:
//                 const Color(
//                     0xFF7C5CFC),

//             foregroundColor:
//                 Colors.white,

//             padding:
//                 const EdgeInsets
//                     .symmetric(
//               horizontal: 28,
//               vertical: 16,
//             ),

//             shape:
//                 RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(
//                 12,
//               ),
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
//                     color:
//                         Colors.white,
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

//                     SizedBox(
//                       width: 8,
//                     ),

//                     Text(
//                       'Add Product',
//                       style:
//                           TextStyle(
//                         fontWeight:
//                             FontWeight
//                                 .w700,
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // DISPOSE
//   // ============================================================

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _priceController.dispose();
//     _stockController.dispose();

//     super.dispose();
//   }
// }






// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
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

//   // ============================================================
//   // CONTROLLERS
//   // ============================================================

//   final TextEditingController _nameController =
//       TextEditingController();

//   final TextEditingController _descriptionController =
//       TextEditingController();

//   final TextEditingController _priceController =
//       TextEditingController();

//   final TextEditingController _stockController =
//       TextEditingController();

//   // ============================================================
//   // IMAGE PICKER
//   // ============================================================

//   final ImagePicker _picker = ImagePicker();

//   /// Every selected image is stored here as:
//   /// data:image/jpeg;base64,...
//   final List<String> _images = [];

//   // ============================================================
//   // STATE
//   // ============================================================

//   bool _isAvailable = true;
//   bool _isSaving = false;
//   bool _isPickingImages = false;

//   String? _currency;
//   String? _category;

//   // ============================================================
//   // CATEGORIES
//   // ============================================================

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

//   // ============================================================
//   // CURRENCIES
//   // ============================================================

//   final List<String> _currencies = [
//     'PKR',
//     'USD',
//     'EUR',
//     'GBP',
//     'AED',
//     'SAR',
//   ];

//   // ============================================================
//   // PICK MULTIPLE IMAGES
//   // ============================================================

//   Future<void> _pickImages() async {
//     if (_isPickingImages || _isSaving) {
//       return;
//     }

//     try {
//       setState(() {
//         _isPickingImages = true;
//       });

//       final List<XFile> pickedImages =
//           await _picker.pickMultiImage(
//         imageQuality: 100,
//       );

//       if (pickedImages.isEmpty) {
//         return;
//       }

//       int addedCount = 0;

//       for (final XFile pickedImage in pickedImages) {
//         try {
//           final Uint8List bytes =
//               await pickedImage.readAsBytes();

//           final String? base64Image =
//               await _convertToBase64(bytes);

//           if (base64Image != null &&
//               base64Image.isNotEmpty) {
//             _images.add(base64Image);
//             addedCount++;
//           }
//         } catch (e) {
//           debugPrint(
//             'Failed to process image: $e',
//           );
//         }
//       }

//       if (!mounted) {
//         return;
//       }

//       setState(() {});

//       if (addedCount > 0) {
//         _showMessage(
//           '$addedCount image${addedCount == 1 ? '' : 's'} added successfully.',
//         );
//       } else {
//         _showMessage(
//           'Could not process the selected images.',
//           isError: true,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         _showMessage(
//           'Could not select images: $e',
//           isError: true,
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isPickingImages = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // COMPRESS IMAGE + CONVERT TO BASE64
//   // ============================================================

//   Future<String?> _convertToBase64(
//     Uint8List bytes,
//   ) async {
//     try {
//       final img.Image? decoded =
//           img.decodeImage(bytes);

//       if (decoded == null) {
//         return null;
//       }

//       // Fix camera orientation.
//       final img.Image oriented =
//           img.bakeOrientation(decoded);

//       // --------------------------------------------------------
//       // Keep images reasonably small.
//       //
//       // IMPORTANT:
//       // Every image is stored in its own Firestore document,
//       // so multiple images won't make the product document
//       // exceed Firestore's 1 MiB document limit.
//       // --------------------------------------------------------

//       const int maxWidth = 900;
//       const int maxHeight = 900;

//       img.Image resized = oriented;

//       if (oriented.width > maxWidth ||
//           oriented.height > maxHeight) {
//         resized = img.copyResize(
//           oriented,
//           width: oriented.width >= oriented.height
//               ? maxWidth
//               : null,
//           height: oriented.height > oriented.width
//               ? maxHeight
//               : null,
//           interpolation:
//               img.Interpolation.average,
//         );
//       }

//       // Quality 65 gives a good balance between
//       // visual quality and Firestore document size.
//       final List<int> compressed =
//           img.encodeJpg(
//         resized,
//         quality: 65,
//       );

//       final String base64String =
//           base64Encode(compressed);

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
//     if (index < 0 ||
//         index >= _images.length) {
//       return;
//     }

//     setState(() {
//       _images.removeAt(index);
//     });
//   }

//   // ============================================================
//   // MOVE IMAGE
//   // ============================================================

//   void _moveImage(
//     int oldIndex,
//     int newIndex,
//   ) {
//     if (oldIndex < 0 ||
//         oldIndex >= _images.length ||
//         newIndex < 0 ||
//         newIndex > _images.length) {
//       return;
//     }

//     setState(() {
//       if (newIndex > oldIndex) {
//         newIndex--;
//       }

//       final String image =
//           _images.removeAt(oldIndex);

//       _images.insert(
//         newIndex,
//         image,
//       );
//     });
//   }

//   // ============================================================
//   // GENERATE FANDOM ID
//   // ============================================================

//   String _generateFandomId() {
//     final String documentId =
//         FirebaseFirestore.instance
//             .collection('products')
//             .doc()
//             .id;

//     return 'FND-${documentId.substring(0, 12).toUpperCase()}';
//   }

//   // ============================================================
//   // SAVE PRODUCT
//   // ============================================================

//   Future<void> _saveProduct() async {
//     FocusScope.of(context).unfocus();

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

//     if (_currency == null) {
//       _showMessage(
//         'Please select a currency.',
//         isError: true,
//       );

//       return;
//     }

//     if (_isSaving) {
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       final FirebaseFirestore firestore =
//           FirebaseFirestore.instance;

//       // --------------------------------------------------------
//       // CREATE PRODUCT DOCUMENT
//       // --------------------------------------------------------

//       final DocumentReference<Map<String, dynamic>>
//           productRef =
//           firestore.collection('products').doc();

//       final String fandomId =
//           _generateFandomId();

//       final User? currentUser =
//           FirebaseAuth.instance.currentUser;

//       final double price =
//           double.tryParse(
//                 _priceController.text.trim(),
//               ) ??
//               0;

//       final int stock =
//           int.tryParse(
//                 _stockController.text.trim(),
//               ) ??
//               0;

//       // --------------------------------------------------------
//       // MAIN PRODUCT DOCUMENT
//       //
//       // IMPORTANT:
//       // We DO NOT store all Base64 images here.
//       // Only the first/main image is stored here.
//       // Every image is stored in the images subcollection.
//       // --------------------------------------------------------

//       await productRef.set({
//         'name': _nameController.text.trim(),

//         'description':
//             _descriptionController.text.trim(),

//         'price': price,

//         'currency': _currency,

//         // First selected image = main image.
//         'imageUrl': _images.first,

//         // Helpful fields for displaying/counting images.
//         'imageCount': _images.length,

//         'fandomId': fandomId,

//         'category': _category,

//         'stock': stock,

//         'isAvailable': _isAvailable,

//         'createdAt':
//             FieldValue.serverTimestamp(),

//         'updatedAt':
//             FieldValue.serverTimestamp(),

//         'createdBy': currentUser?.uid,
//       });

//       // --------------------------------------------------------
//       // SAVE EVERY IMAGE
//       //
//       // products
//       //    └── productId
//       //         └── images
//       //              ├── imageId1
//       //              ├── imageId2
//       //              ├── imageId3
//       //              └── ...
//       // --------------------------------------------------------

//       final CollectionReference<
//           Map<String, dynamic>> imagesRef =
//           productRef.collection('images');

//       // Firestore batches support up to 500 operations.
//       // We commit in chunks so this also works if the user
//       // selects a large number of images.
//       WriteBatch batch =
//           firestore.batch();

//       int batchCount = 0;

//       for (int i = 0; i < _images.length; i++) {
//         final DocumentReference<Map<String, dynamic>>
//             imageRef =
//             imagesRef.doc();

//         batch.set(imageRef, {
//           'imageUrl': _images[i],

//           // Original order.
//           'order': i,

//           // First image is the main image.
//           'isMain': i == 0,

//           'createdAt':
//               FieldValue.serverTimestamp(),
//         });

//         batchCount++;

//         // Commit every 400 operations.
//         if (batchCount >= 400) {
//           await batch.commit();

//           batch =
//               firestore.batch();

//           batchCount = 0;
//         }
//       }

//       // Commit remaining images.
//       if (batchCount > 0) {
//         await batch.commit();
//       }

//       if (!mounted) {
//         return;
//       }

//       _showMessage(
//         '${_images.length} image${_images.length == 1 ? '' : 's'} and product added successfully!',
//       );

//       Navigator.pop(context);
//     } catch (e) {
//       debugPrint(
//         'Save product error: $e',
//       );

//       if (mounted) {
//         _showMessage(
//           'Failed to add product: $e',
//           isError: true,
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // VALIDATORS
//   // ============================================================

//   String? _required(
//     String? value,
//   ) {
//     if (value == null ||
//         value.trim().isEmpty) {
//       return 'This field is required';
//     }

//     return null;
//   }

//   String? _priceValidator(
//     String? value,
//   ) {
//     if (value == null ||
//         value.trim().isEmpty) {
//       return 'Enter price';
//     }

//     final double? price =
//         double.tryParse(
//       value.trim(),
//     );

//     if (price == null ||
//         price < 0) {
//       return 'Enter a valid price';
//     }

//     return null;
//   }

//   String? _stockValidator(
//     String? value,
//   ) {
//     if (value == null ||
//         value.trim().isEmpty) {
//       return 'Enter stock';
//     }

//     final int? stock =
//         int.tryParse(
//       value.trim(),
//     );

//     if (stock == null ||
//         stock < 0) {
//       return 'Enter valid stock';
//     }

//     return null;
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//     String message, {
//     bool isError = false,
//   }) {
//     if (!mounted) {
//       return;
//     }

//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(
//             color: Colors.white,
//           ),
//         ),
//         behavior:
//             SnackBarBehavior.floating,
//         backgroundColor: isError
//             ? Colors.redAccent
//             : Colors.green,
//       ),
//     );
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(
//     BuildContext context,
//   ) {
//     return Scaffold(
//       backgroundColor:
//           const Color(0xFF080A12),

//       appBar: AppBar(
//         backgroundColor:
//             const Color(0xFF080A12),

//         elevation: 0,

//         title: const Text(
//           'Add Product',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight:
//                 FontWeight.w700,
//           ),
//         ),

//         iconTheme:
//             const IconThemeData(
//           color: Colors.white,
//         ),
//       ),

//       body: SafeArea(
//         child: Form(
//           key: _formKey,

//           child: LayoutBuilder(
//             builder:
//                 (context, constraints) {
//               final bool isDesktop =
//                   constraints.maxWidth >=
//                       900;

//               return SingleChildScrollView(
//                 padding:
//                     EdgeInsets.symmetric(
//                   horizontal:
//                       isDesktop ? 32 : 16,
//                   vertical: 24,
//                 ),

//                 child: Center(
//                   child: ConstrainedBox(
//                     constraints:
//                         const BoxConstraints(
//                       maxWidth: 1300,
//                     ),

//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment
//                               .start,

//                       children: [
//                         _buildHeader(),

//                         const SizedBox(
//                           height: 24,
//                         ),

//                         if (isDesktop)
//                           _buildDesktopLayout()
//                         else
//                           _buildMobileLayout(),

//                         const SizedBox(
//                           height: 30,
//                         ),

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

//   // ============================================================
//   // HEADER
//   // ============================================================

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
//             fontWeight:
//                 FontWeight.w800,
//           ),
//         ),

//         const SizedBox(
//           height: 6,
//         ),

//         Text(
//           'Add a new product to your store.',
//           style: TextStyle(
//             color: Colors.white
//                 .withOpacity(.55),
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // DESKTOP LAYOUT
//   // ============================================================

//   Widget _buildDesktopLayout() {
//     return Row(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 4,
//           child:
//               _buildImageCard(),
//         ),

//         const SizedBox(
//           width: 24,
//         ),

//         Expanded(
//           flex: 6,
//           child: Column(
//             children: [
//               _buildProductInfoCard(),

//               const SizedBox(
//                 height: 20,
//               ),

//               _buildPricingCard(),

//               const SizedBox(
//                 height: 20,
//               ),

//               _buildAvailabilityCard(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // MOBILE LAYOUT
//   // ============================================================

//   Widget _buildMobileLayout() {
//     return Column(
//       children: [
//         _buildImageCard(),

//         const SizedBox(
//           height: 20,
//         ),

//         _buildProductInfoCard(),

//         const SizedBox(
//           height: 20,
//         ),

//         _buildPricingCard(),

//         const SizedBox(
//           height: 20,
//         ),

//         _buildAvailabilityCard(),
//       ],
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

//       padding:
//           const EdgeInsets.all(20),

//       decoration: BoxDecoration(
//         color:
//             const Color(0xFF111522),

//         borderRadius:
//             BorderRadius.circular(20),

//         border: Border.all(
//           color: Colors.white
//               .withOpacity(.07),
//         ),

//         boxShadow: [
//           BoxShadow(
//             color: Colors.black
//                 .withOpacity(.20),
//             blurRadius: 25,
//             offset:
//                 const Offset(0, 10),
//           ),
//         ],
//       ),

//       child: child,
//     );
//   }

//   // ============================================================
//   // IMAGE CARD
//   // ============================================================

//   Widget _buildImageCard() {
//     return _card(
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           _sectionTitle(
//             'Product Images',
//             _images.isEmpty
//                 ? 'Add multiple images'
//                 : '${_images.length} image${_images.length == 1 ? '' : 's'} selected',
//           ),

//           const SizedBox(
//             height: 18,
//           ),

//           if (_images.isEmpty)
//             _buildUploadBox()
//           else
//             _buildImageGrid(),

//           const SizedBox(
//             height: 12,
//           ),

//           Text(
//             'The first image is used as the main product image.',
//             style: TextStyle(
//               color: Colors.white
//                   .withOpacity(.45),
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // UPLOAD BOX
//   // ============================================================

//   Widget _buildUploadBox() {
//     return InkWell(
//       onTap: _isPickingImages
//           ? null
//           : _pickImages,

//       borderRadius:
//           BorderRadius.circular(16),

//       child: Container(
//         height: 280,
//         width: double.infinity,

//         decoration:
//             BoxDecoration(
//           color:
//               const Color(0xFF171B2B),

//           borderRadius:
//               BorderRadius.circular(16),

//           border: Border.all(
//             color:
//                 const Color(0xFF7C5CFC)
//                     .withOpacity(.35),
//             width: 1.5,
//           ),
//         ),

//         child: _isPickingImages
//             ? const Center(
//                 child:
//                     CircularProgressIndicator(
//                   color:
//                       Color(0xFF9D87FF),
//                 ),
//               )
//             : const Column(
//                 mainAxisAlignment:
//                     MainAxisAlignment
//                         .center,
//                 children: [
//                   Icon(
//                     Icons
//                         .cloud_upload_outlined,
//                     color:
//                         Color(0xFF9D87FF),
//                     size: 50,
//                   ),

//                   SizedBox(
//                     height: 14,
//                   ),

//                   Text(
//                     'Upload Product Images',
//                     style:
//                         TextStyle(
//                       color:
//                           Colors.white,
//                       fontSize: 16,
//                       fontWeight:
//                           FontWeight
//                               .w700,
//                     ),
//                   ),

//                   SizedBox(
//                     height: 6,
//                   ),

//                   Text(
//                     'Select multiple images',
//                     style:
//                         TextStyle(
//                       color:
//                           Colors.white54,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   // ============================================================
//   // IMAGE GRID
//   // ============================================================

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

//       itemCount:
//           _images.length + 1,

//       itemBuilder:
//           (context, index) {
//         if (index == _images.length) {
//           return _buildAddImageButton();
//         }

//         return _buildImageItem(
//           index,
//         );
//       },
//     );
//   }

//   // ============================================================
//   // IMAGE ITEM
//   // ============================================================

//   Widget _buildImageItem(
//     int index,
//   ) {
//     return Stack(
//       children: [
//         Positioned.fill(
//           child: ClipRRect(
//             borderRadius:
//                 BorderRadius.circular(14),

//             child: Image.memory(
//               base64Decode(
//                 _images[index]
//                     .split(',')
//                     .last,
//               ),

//               fit: BoxFit.cover,

//               errorBuilder:
//                   (
//                 context,
//                 error,
//                 stackTrace,
//               ) {
//                 return Container(
//                   color:
//                       const Color(
//                     0xFF171B2B,
//                   ),
//                   child:
//                       const Center(
//                     child: Icon(
//                       Icons
//                           .broken_image_outlined,
//                       color:
//                           Colors.white54,
//                       size: 35,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),

//         // --------------------------------------------------------
//         // IMAGE NUMBER
//         // --------------------------------------------------------

//         Positioned(
//           left: 8,
//           bottom: 8,
//           child: Container(
//             padding:
//                 const EdgeInsets
//                     .symmetric(
//               horizontal: 8,
//               vertical: 5,
//             ),

//             decoration:
//                 BoxDecoration(
//               color:
//                   Colors.black87,
//               borderRadius:
//                   BorderRadius.circular(
//                 8,
//               ),
//             ),

//             child: Text(
//               '#${index + 1}',
//               style:
//                   const TextStyle(
//                 color: Colors.white,
//                 fontSize: 10,
//                 fontWeight:
//                     FontWeight.w800,
//               ),
//             ),
//           ),
//         ),

//         // --------------------------------------------------------
//         // MAIN IMAGE LABEL
//         // --------------------------------------------------------

//         if (index == 0)
//           Positioned(
//             left: 8,
//             top: 8,
//             child: Container(
//               padding:
//                   const EdgeInsets
//                       .symmetric(
//                 horizontal: 8,
//                 vertical: 5,
//               ),

//               decoration:
//                   BoxDecoration(
//                 color:
//                     const Color(
//                   0xFF7C5CFC,
//                 ),
//                 borderRadius:
//                     BorderRadius.circular(
//                   8,
//                 ),
//               ),

//               child:
//                   const Text(
//                 'MAIN',
//                 style:
//                     TextStyle(
//                   color:
//                       Colors.white,
//                   fontSize: 10,
//                   fontWeight:
//                       FontWeight.w800,
//                 ),
//               ),
//             ),
//           ),

//         // --------------------------------------------------------
//         // REMOVE BUTTON
//         // --------------------------------------------------------

//         Positioned(
//           right: 7,
//           top: 7,
//           child:
//               GestureDetector(
//             onTap: _isSaving
//                 ? null
//                 : () =>
//                     _removeImage(
//                       index,
//                     ),

//             child: Container(
//               padding:
//                   const EdgeInsets.all(
//                 6,
//               ),

//               decoration:
//                   const BoxDecoration(
//                 color:
//                     Colors.black87,
//                 shape:
//                     BoxShape.circle,
//               ),

//               child:
//                   const Icon(
//                 Icons.close,
//                 color:
//                     Colors.white,
//                 size: 16,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // ADD IMAGE BUTTON
//   // ============================================================

//   Widget _buildAddImageButton() {
//     return InkWell(
//       onTap: _isPickingImages
//           ? null
//           : _pickImages,

//       borderRadius:
//           BorderRadius.circular(14),

//       child: Container(
//         decoration:
//             BoxDecoration(
//           color:
//               const Color(0xFF171B2B),

//           borderRadius:
//               BorderRadius.circular(14),

//           border: Border.all(
//             color: Colors.white
//                 .withOpacity(.08),
//           ),
//         ),

//         child: _isPickingImages
//             ? const Center(
//                 child:
//                     CircularProgressIndicator(
//                   color:
//                       Color(0xFF9D87FF),
//                 ),
//               )
//             : const Column(
//                 mainAxisAlignment:
//                     MainAxisAlignment
//                         .center,
//                 children: [
//                   Icon(
//                     Icons
//                         .add_photo_alternate_outlined,
//                     color:
//                         Color(0xFF9D87FF),
//                     size: 35,
//                   ),

//                   SizedBox(
//                     height: 8,
//                   ),

//                   Text(
//                     'Add Images',
//                     style:
//                         TextStyle(
//                       color:
//                           Colors.white70,
//                       fontWeight:
//                           FontWeight
//                               .w600,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   // ============================================================
//   // PRODUCT INFORMATION
//   // ============================================================

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

//           const SizedBox(
//             height: 20,
//           ),

//           _field(
//             controller:
//                 _nameController,
//             label:
//                 'Product Name',
//             hint:
//                 'Enter product name',
//             icon:
//                 Icons.shopping_bag_outlined,
//             validator:
//                 _required,
//           ),

//           const SizedBox(
//             height: 16,
//           ),

//           _field(
//             controller:
//                 _descriptionController,
//             label:
//                 'Description',
//             hint:
//                 'Describe your product...',
//             icon:
//                 Icons.description_outlined,
//             maxLines: 5,
//             validator:
//                 _required,
//           ),

//           const SizedBox(
//             height: 16,
//           ),

//           _categoryDropdown(),

//           const SizedBox(
//             height: 16,
//           ),

//           _currencyDropdown(),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PRICING
//   // ============================================================

//   Widget _buildPricingCard() {
//     return _card(
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           _sectionTitle(
//             'Pricing & Inventory',
//             'Set product price and stock',
//           ),

//           const SizedBox(
//             height: 20,
//           ),

//           LayoutBuilder(
//             builder:
//                 (context, constraints) {
//               if (constraints
//                       .maxWidth <
//                   500) {
//                 return Column(
//                   children: [
//                     _field(
//                       controller:
//                           _priceController,
//                       label:
//                           'Price',
//                       hint:
//                           '0.00',
//                       icon:
//                           Icons.payments_outlined,
//                       keyboardType:
//                           const TextInputType
//                               .numberWithOptions(
//                         decimal:
//                             true,
//                       ),
//                       validator:
//                           _priceValidator,
//                     ),

//                     const SizedBox(
//                       height: 16,
//                     ),

//                     _field(
//                       controller:
//                           _stockController,
//                       label:
//                           'Stock',
//                       hint:
//                           '0',
//                       icon:
//                           Icons.inventory_2_outlined,
//                       keyboardType:
//                           TextInputType
//                               .number,
//                       validator:
//                           _stockValidator,
//                     ),
//                   ],
//                 );
//               }

//               return Row(
//                 children: [
//                   Expanded(
//                     child: _field(
//                       controller:
//                           _priceController,
//                       label:
//                           'Price',
//                       hint:
//                           '0.00',
//                       icon:
//                           Icons
//                               .payments_outlined,
//                       keyboardType:
//                           const TextInputType
//                               .numberWithOptions(
//                         decimal:
//                             true,
//                       ),
//                       validator:
//                           _priceValidator,
//                     ),
//                   ),

//                   const SizedBox(
//                     width: 14,
//                   ),

//                   Expanded(
//                     child: _field(
//                       controller:
//                           _stockController,
//                       label:
//                           'Stock',
//                       hint:
//                           '0',
//                       icon:
//                           Icons
//                               .inventory_2_outlined,
//                       keyboardType:
//                           TextInputType
//                               .number,
//                       validator:
//                           _stockValidator,
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // AVAILABILITY
//   // ============================================================

//   Widget _buildAvailabilityCard() {
//     return _card(
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           _sectionTitle(
//             'Product Availability',
//             'Control whether the product is available',
//           ),

//           const SizedBox(
//             height: 12,
//           ),

//           SwitchListTile(
//             contentPadding:
//                 EdgeInsets.zero,

//             title: const Text(
//               'Available for Sale',
//               style:
//                   TextStyle(
//                 color:
//                     Colors.white,
//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),

//             subtitle: Text(
//               _isAvailable
//                   ? 'Product is currently available'
//                   : 'Product is currently unavailable',
//               style: TextStyle(
//                 color: Colors.white
//                     .withOpacity(.45),
//               ),
//             ),

//             value:
//                 _isAvailable,

//             activeColor:
//                 const Color(
//               0xFF7C5CFC,
//             ),

//             onChanged:
//                 _isSaving
//                     ? null
//                     : (value) {
//                         setState(() {
//                           _isAvailable =
//                               value;
//                         });
//                       },
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY DROPDOWN
//   // ============================================================

//   Widget _categoryDropdown() {
//     return DropdownButtonFormField<
//         String>(
//       value: _category,

//       dropdownColor:
//           const Color(0xFF171B2B),

//       style: const TextStyle(
//         color: Colors.white,
//       ),

//       decoration:
//           _inputDecoration(
//         label:
//             'Category',
//         icon:
//             Icons.category_outlined,
//       ),

//       items: _categories
//           .map(
//             (category) =>
//                 DropdownMenuItem<
//                     String>(
//               value:
//                   category,
//               child:
//                   Text(category),
//             ),
//           )
//           .toList(),

//       onChanged:
//           _isSaving
//               ? null
//               : (value) {
//                   setState(() {
//                     _category =
//                         value;
//                   });
//                 },

//       validator: (value) {
//         if (value == null) {
//           return 'Select category';
//         }

//         return null;
//       },
//     );
//   }

//   // ============================================================
//   // CURRENCY DROPDOWN
//   // ============================================================

//   Widget _currencyDropdown() {
//     return DropdownButtonFormField<
//         String>(
//       value: _currency,

//       dropdownColor:
//           const Color(0xFF171B2B),

//       style: const TextStyle(
//         color: Colors.white,
//       ),

//       decoration:
//           _inputDecoration(
//         label:
//             'Currency',
//         icon:
//             Icons.currency_exchange,
//       ),

//       items: _currencies
//           .map(
//             (currency) =>
//                 DropdownMenuItem<
//                     String>(
//               value:
//                   currency,
//               child:
//                   Text(currency),
//             ),
//           )
//           .toList(),

//       onChanged:
//           _isSaving
//               ? null
//               : (value) {
//                   setState(() {
//                     _currency =
//                         value;
//                   });
//                 },

//       validator: (value) {
//         if (value == null) {
//           return 'Select currency';
//         }

//         return null;
//       },
//     );
//   }

//   // ============================================================
//   // TEXT FIELD
//   // ============================================================

//   Widget _field({
//     required TextEditingController
//         controller,

//     required String label,

//     required String hint,

//     required IconData icon,

//     String? Function(String?)?
//         validator,

//     int maxLines = 1,

//     TextInputType? keyboardType,
//   }) {
//     return TextFormField(
//       controller:
//           controller,

//       maxLines:
//           maxLines,

//       keyboardType:
//           keyboardType,

//       validator:
//           validator,

//       style:
//           const TextStyle(
//         color:
//             Colors.white,
//       ),

//       cursorColor:
//           const Color(
//         0xFF9D87FF,
//       ),

//       decoration:
//           _inputDecoration(
//         label:
//             label,
//         hint:
//             hint,
//         icon:
//             icon,
//       ),
//     );
//   }

//   // ============================================================
//   // INPUT DECORATION
//   // ============================================================

//   InputDecoration _inputDecoration({
//     required String label,
//     String? hint,
//     required IconData icon,
//   }) {
//     return InputDecoration(
//       labelText:
//           label,

//       hintText:
//           hint,

//       labelStyle:
//           TextStyle(
//         color: Colors.white
//             .withOpacity(.65),
//       ),

//       hintStyle:
//           TextStyle(
//         color: Colors.white
//             .withOpacity(.25),
//       ),

//       prefixIcon:
//           Icon(
//         icon,
//         color:
//             const Color(
//           0xFF9D87FF,
//         ),
//       ),

//       filled:
//           true,

//       fillColor:
//           const Color(
//         0xFF171B2B,
//       ),

//       border:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(
//           12,
//         ),
//         borderSide:
//             BorderSide.none,
//       ),

//       enabledBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(
//           12,
//         ),
//         borderSide:
//             BorderSide(
//           color: Colors.white
//               .withOpacity(.06),
//         ),
//       ),

//       focusedBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(
//           12,
//         ),
//         borderSide:
//             const BorderSide(
//           color:
//               Color(0xFF7C5CFC),
//           width:
//               1.5,
//         ),
//       ),

//       errorBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(
//           12,
//         ),
//         borderSide:
//             const BorderSide(
//           color:
//               Colors.redAccent,
//         ),
//       ),

//       focusedErrorBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(
//           12,
//         ),
//         borderSide:
//             const BorderSide(
//           color:
//               Colors.redAccent,
//         ),
//       ),

//       contentPadding:
//           const EdgeInsets.symmetric(
//         horizontal:
//             16,
//         vertical:
//             17,
//       ),
//     );
//   }

//   // ============================================================
//   // SECTION TITLE
//   // ============================================================

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
//           style:
//               const TextStyle(
//             color:
//                 Colors.white,
//             fontSize:
//                 18,
//             fontWeight:
//                 FontWeight.w800,
//           ),
//         ),

//         const SizedBox(
//           height: 4,
//         ),

//         Text(
//           subtitle,
//           style:
//               TextStyle(
//             color: Colors.white
//                 .withOpacity(.42),
//             fontSize:
//                 12,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // BUTTONS
//   // ============================================================

//   Widget _buildButtons() {
//     return Row(
//       mainAxisAlignment:
//           MainAxisAlignment.end,
//       children: [
//         OutlinedButton(
//           onPressed:
//               _isSaving
//                   ? null
//                   : () {
//                       Navigator.pop(
//                         context,
//                       );
//                     },

//           style:
//               OutlinedButton.styleFrom(
//             foregroundColor:
//                 Colors.white70,

//             side:
//                 BorderSide(
//               color: Colors.white
//                   .withOpacity(.15),
//             ),

//             padding:
//                 const EdgeInsets
//                     .symmetric(
//               horizontal:
//                   24,
//               vertical:
//                   16,
//             ),

//             shape:
//                 RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(
//                 12,
//               ),
//             ),
//           ),

//           child:
//               const Text(
//             'Cancel',
//           ),
//         ),

//         const SizedBox(
//           width: 12,
//         ),

//         ElevatedButton(
//           onPressed:
//               (_isSaving ||
//                       _isPickingImages)
//                   ? null
//                   : _saveProduct,

//           style:
//               ElevatedButton.styleFrom(
//             backgroundColor:
//                 const Color(
//               0xFF7C5CFC,
//             ),

//             foregroundColor:
//                 Colors.white,

//             padding:
//                 const EdgeInsets
//                     .symmetric(
//               horizontal:
//                   28,
//               vertical:
//                   16,
//             ),

//             shape:
//                 RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(
//                 12,
//               ),
//             ),

//             elevation:
//                 0,
//           ),

//           child: _isSaving
//               ? const SizedBox(
//                   width:
//                       20,
//                   height:
//                       20,
//                   child:
//                       CircularProgressIndicator(
//                     strokeWidth:
//                         2,
//                     color:
//                         Colors.white,
//                   ),
//                 )
//               : const Row(
//                   mainAxisSize:
//                       MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.add,
//                       size:
//                           20,
//                     ),

//                     SizedBox(
//                       width:
//                           8,
//                     ),

//                     Text(
//                       'Add Product',
//                       style:
//                           TextStyle(
//                         fontWeight:
//                             FontWeight
//                                 .w700,
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // DISPOSE
//   // ============================================================

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _priceController.dispose();
//     _stockController.dispose();

//     super.dispose();
//   }
// }




import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _descController =
      TextEditingController();

  final TextEditingController _priceController =
      TextEditingController();

  final TextEditingController _stockController =
      TextEditingController();

  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final ImagePicker _picker = ImagePicker();

  // ============================================================
  // VARIABLES
  // ============================================================

  String _currency = 'PKR';

  String? _selectedCategory;

  bool _isAvailable = true;

  bool _isSaving = false;

  // ============================================================
  // CATEGORIES
  // ============================================================

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Shoes',
    'Accessories',
    'Beauty',
    'Home',
    'Sports',
    'Books',
    'Toys',
    'Other',
  ];

  // ============================================================
  // IMAGES
  // ============================================================

  // Base64 strings stored in Firestore
  final List<String> _imageUrls = [];

  // Image bytes used only for UI preview
  final List<Uint8List> _imagePreviews = [];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK MULTIPLE IMAGES
  // ============================================================

  Future<void> _pickImages() async {
    try {
      final List<XFile> images =
          await _picker.pickMultiImage(
        imageQuality: 70,
      );

      if (images.isEmpty) {
        return;
      }

      for (final XFile image in images) {
        final Uint8List bytes =
            await image.readAsBytes();

        final String base64Image =
            base64Encode(bytes);

        _imageUrls.add(base64Image);

        _imagePreviews.add(bytes);
      }

      if (!mounted) {
        return;
      }

      setState(() {});
    } catch (e) {
      _showMessage(
        'Error selecting images: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // REMOVE IMAGE
  // ============================================================

  void _removeImage(int index) {
    if (index < 0 ||
        index >= _imageUrls.length ||
        index >= _imagePreviews.length) {
      return;
    }

    setState(() {
      _imageUrls.removeAt(index);
      _imagePreviews.removeAt(index);
    });
  }

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  Future<void> _addProduct() async {
    // Prevent double clicks
    if (_isSaving) {
      return;
    }

    // Form validation
    final FormState? form =
        _formKey.currentState;

    if (form == null) {
      return;
    }

    if (!form.validate()) {
      return;
    }

    // Category validation
    if (_selectedCategory == null ||
        _selectedCategory!.trim().isEmpty) {
      _showMessage(
        'Please select a category',
        isError: true,
      );

      return;
    }

    // Image validation
    if (_imageUrls.isEmpty) {
      _showMessage(
        'Please select at least one product image',
        isError: true,
      );

      return;
    }

    // Price validation
    final String priceText =
        _priceController.text.trim();

    final double? price =
        double.tryParse(priceText);

    if (price == null || price < 0) {
      _showMessage(
        'Please enter a valid price',
        isError: true,
      );

      return;
    }

    // Stock validation
    final String stockText =
        _stockController.text.trim();

    final int? stock =
        int.tryParse(stockText);

    if (stock == null || stock < 0) {
      _showMessage(
        'Please enter a valid stock quantity',
        isError: true,
      );

      return;
    }

    // Check Firebase user
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showMessage(
        'Please login before adding a product',
        isError: true,
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // ==========================================================
      // CREATE DOCUMENT REFERENCE
      // ==========================================================

      final DocumentReference<Map<String, dynamic>>
          productRef =
          _firestore.collection('products').doc();

      // ==========================================================
      // FIRESTORE TIMESTAMP
      // ==========================================================

      final Timestamp now =
          Timestamp.now();

      // ==========================================================
      // COPY IMAGE ARRAY
      //
      // This creates a separate List so Firestore receives
      // a stable list instead of the mutable UI list.
      // ==========================================================

      final List<String> imageUrls =
          List<String>.from(_imageUrls);

      // ==========================================================
      // SAVE PRODUCT
      // ==========================================================

      await productRef.set({
        // Product name
        'name': _nameController.text.trim(),

        // Product description
        'description': _descController.text.trim(),

        // Product price
        'price': price,

        // Currency
        'currency': _currency,

        // Multiple Base64 images
        'imageUrls': imageUrls,

        // Auto-generated ID
        'fandomId': productRef.id,

        // Category
        'category': _selectedCategory,

        // Stock
        'stock': stock,

        // Availability
        'isAvailable': _isAvailable,

        // Firebase Auth UID
        'createdBy': currentUser.uid,

        // Timestamps
        'createdAt': now,
        'updatedAt': now,
      });

      if (!mounted) {
        return;
      }

      _showMessage(
        'Product added successfully',
      );

      _clearForm();
    } catch (e) {
      if (!mounted) {
        return;
      }

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
  // CLEAR FORM
  // ============================================================

  void _clearForm() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _stockController.clear();

    setState(() {
      _currency = 'PKR';
      _selectedCategory = null;
      _isAvailable = true;

      _imageUrls.clear();
      _imagePreviews.clear();
    });
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Product',
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // ==================================================
                // PRODUCT NAME
                // ==================================================

                const Text(
                  'Product Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _nameController,

                  decoration:
                      const InputDecoration(
                    hintText:
                        'Enter product name',
                    border:
                        OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return
                          'Product name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // DESCRIPTION
                // ==================================================

                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _descController,

                  maxLines: 5,

                  decoration:
                      const InputDecoration(
                    hintText:
                        'Enter product description',
                    border:
                        OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return
                          'Description is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // PRICE
                // ==================================================

                const Text(
                  'Price',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _priceController,

                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  decoration:
                      InputDecoration(
                    hintText:
                        'Enter product price',

                    border:
                        const OutlineInputBorder(),

                    prefixText:
                        '$_currency ',
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return
                          'Price is required';
                    }

                    final double? price =
                        double.tryParse(
                      value.trim(),
                    );

                    if (price == null ||
                        price < 0) {
                      return
                          'Enter a valid price';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // CURRENCY
                // ==================================================

                const Text(
                  'Currency',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  initialValue: _currency,

                  decoration:
                      const InputDecoration(
                    border:
                        OutlineInputBorder(),
                  ),

                  items: const [
                    DropdownMenuItem(
                      value: 'PKR',
                      child: Text(
                        'PKR - Pakistani Rupee',
                      ),
                    ),

                    DropdownMenuItem(
                      value: 'USD',
                      child: Text(
                        'USD - US Dollar',
                      ),
                    ),

                    DropdownMenuItem(
                      value: 'EUR',
                      child: Text(
                        'EUR - Euro',
                      ),
                    ),

                    DropdownMenuItem(
                      value: 'GBP',
                      child: Text(
                        'GBP - British Pound',
                      ),
                    ),
                  ],

                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _currency = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // CATEGORY
                // ==================================================

                const Text(
                  'Category',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  initialValue:
                      _selectedCategory,

                  decoration:
                      const InputDecoration(
                    hintText:
                        'Select category',
                    border:
                        OutlineInputBorder(),
                  ),

                  items: _categories
                      .map(
                        (category) =>
                            DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),

                  onChanged: (value) {
                    setState(() {
                      _selectedCategory =
                          value;
                    });
                  },

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return
                          'Please select a category';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // STOCK
                // ==================================================

                const Text(
                  'Stock',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller:
                      _stockController,

                  keyboardType:
                      TextInputType.number,

                  decoration:
                      const InputDecoration(
                    hintText:
                        'Enter stock quantity',
                    border:
                        OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return
                          'Stock is required';
                    }

                    final int? stock =
                        int.tryParse(
                      value.trim(),
                    );

                    if (stock == null ||
                        stock < 0) {
                      return
                          'Enter a valid stock number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // AVAILABILITY
                // ==================================================

                Container(
                  decoration:
                      BoxDecoration(
                    border: Border.all(
                      color:
                          Colors.grey.shade300,
                    ),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),

                  child:
                      SwitchListTile(
                    title: const Text(
                      'Product Available',
                    ),

                    subtitle: Text(
                      _isAvailable
                          ? 'Customers can purchase this product'
                          : 'Product is currently unavailable',
                    ),

                    value:
                        _isAvailable,

                    onChanged: (value) {
                      setState(() {
                        _isAvailable =
                            value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // IMAGES
                // ==================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    const Expanded(
                      child: Text(
                        'Product Images',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed:
                          _isSaving
                              ? null
                              : _pickImages,

                      icon: const Icon(
                        Icons
                            .add_photo_alternate,
                      ),

                      label: const Text(
                        'Add Images',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ==================================================
                // NO IMAGES
                // ==================================================

                if (_imagePreviews.isEmpty)
                  Container(
                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets.all(30),

                    decoration:
                        BoxDecoration(
                      border: Border.all(
                        color:
                            Colors.grey.shade300,
                      ),

                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    child:
                        const Column(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 50,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 10),

                        Text(
                          'No images selected',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )

                // ==================================================
                // IMAGE GRID
                // ==================================================

                else
                  GridView.builder(
                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),

                    itemCount:
                        _imagePreviews.length,

                    itemBuilder:
                        (context, index) {
                      return Stack(
                        children: [

                          Positioned.fill(
                            child:
                                ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(10),

                              child:
                                  Image.memory(
                                _imagePreviews[
                                    index],

                                fit:
                                    BoxFit.cover,
                              ),
                            ),
                          ),

                          Positioned(
                            top: 5,
                            right: 5,

                            child:
                                GestureDetector(
                              onTap: () {
                                _removeImage(
                                  index,
                                );
                              },

                              child:
                                  Container(
                                padding:
                                    const EdgeInsets.all(5),

                                decoration:
                                    const BoxDecoration(
                                  color: Colors.red,
                                  shape:
                                      BoxShape.circle,
                                ),

                                child:
                                    const Icon(
                                  Icons.close,
                                  color:
                                      Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 30),

                // ==================================================
                // ADD PRODUCT BUTTON
                // ==================================================

                SizedBox(
                  width:
                      double.infinity,

                  height: 52,

                  child:
                      ElevatedButton(
                    onPressed:
                        _isSaving
                            ? null
                            : _addProduct,

                    child:
                        _isSaving
                            ? const SizedBox(
                                height: 24,
                                width: 24,

                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Add Product',

                                style:
                                    TextStyle(
                                  fontSize: 16,
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
      ),
    );
  }
}
