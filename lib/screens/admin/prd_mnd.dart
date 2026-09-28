import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fandom_verse/screens/admin/add_prd_form.dart';
import 'package:fandom_verse/screens/admin/admin_drawer.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState
    extends State<ProductManagementScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  String _searchQuery = '';

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _products =
      [];

  // Same list as the Add Product form so both screens agree.
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

  // Fandoms for the "Fandom" dropdown in the edit dialog.
  List<Map<String, String>> _fandoms = [];

  static const int _maxImagePayloadChars = 850000;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _loadFandoms();
  }

  Future<void> _loadFandoms() async {
    try {
      final snapshot =
          await _firestore.collection('fandoms').orderBy('name').get();

      final list = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': (doc.data()['name'] ?? 'Unnamed Fandom').toString(),
              })
          .toList();

      if (!mounted) return;
      setState(() => _fandoms = list);
    } catch (_) {
      // The dropdown just stays empty if fandoms cannot be loaded.
    }
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

        _showError(
          'Failed to fetch products: $error',
        );
      }
    }
  }

  // ============================================================
  // FIELD HELPERS
  // ============================================================

  List<String> _getImages(
    Map<String, dynamic> data,
  ) {
    final dynamic value =
        data['imageUrls'] ?? data['imageurls'];

    if (value is List) {
      return value
          .map((e) => e.toString())
          .toList();
    }

    return <String>[];
  }

  String _getCategory(
    Map<String, dynamic> data,
  ) {
    return (
      data['category'] ??
      data['catgory'] ??
      'Other'
    ).toString();
  }

  // Products are saved with `isAvailable`. Older edits saved a lowercase
  // `isavailable`, so accept both.
  bool _getIsAvailable(Map<String, dynamic> data) {
    return (data['isAvailable'] ?? data['isavailable']) == true;
  }

  dynamic _getStock(
    Map<String, dynamic> data,
  ) {
    return data['stock'] ??
        data['stcok'] ??
        0;
  }

  // IMPORTANT:
  // Product field is "description".
  String _getDescription(
    Map<String, dynamic> data,
  ) {
    return (
      data['description'] ??
      ''
    ).toString();
  }

  // ============================================================
  // IMAGE HELPERS
  // ============================================================

  Uint8List? _decodeBase64Image(
    dynamic value,
  ) {
    if (value == null) return null;

    try {
      String base64String =
          value.toString();

      if (base64String.contains(',')) {
        base64String =
            base64String.split(',').last;
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
    final bytes =
        _decodeBase64Image(imageData);

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
      final pickedImages =
          await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedImages.isEmpty) {
        return [];
      }

      final List<String> base64Images = [];

      for (final image in pickedImages) {
        final bytes =
            await image.readAsBytes();

        if (bytes.isEmpty) continue;

        final compressed =
            _compressImageBytes(bytes);

        if (compressed != null &&
            compressed.isNotEmpty) {
          base64Images.add(
            base64Encode(compressed),
          );
        }
      }

      return base64Images;
    } catch (e) {
      _showError(
        'Unable to select images: $e',
      );

      return [];
    }
  }

  Uint8List? _compressImageBytes(
    Uint8List originalBytes, {
    int maxWidth = 1000,
    int maxHeight = 1000,
    int quality = 70,
  }) {
    try {
      final decoded =
          img.decodeImage(originalBytes);

      if (decoded == null) return null;

      img.Image resized = decoded;

      if (decoded.width > maxWidth ||
          decoded.height > maxHeight) {
        resized = img.copyResize(
          decoded,
          width: decoded.width >= decoded.height
              ? maxWidth
              : null,
          height: decoded.height > decoded.width
              ? maxHeight
              : null,
          maintainAspect: true,
          interpolation:
              img.Interpolation.linear,
        );
      }

      return Uint8List.fromList(
        img.encodeJpg(
          resized,
          quality: quality,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<String>>
      _prepareImagesForFirestore(
    List<String> images,
  ) async {
    if (images.isEmpty) return [];

    List<String> encodePass({
      required int maxWidth,
      required int maxHeight,
      required int quality,
    }) {
      final List<String> result = [];

      for (final image in images) {
        final bytes =
            _decodeBase64Image(image);

        if (bytes == null ||
            bytes.isEmpty) {
          throw Exception(
            'One of the product images is invalid.',
          );
        }

        final compressed =
            _compressImageBytes(
          bytes,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          quality: quality,
        );

        if (compressed == null ||
            compressed.isEmpty) {
          throw Exception(
            'One of the product images could not be compressed.',
          );
        }

        result.add(
          base64Encode(compressed),
        );
      }

      return result;
    }

    for (final quality
        in [70, 60, 50, 40, 32, 25]) {
      final result = encodePass(
        maxWidth:
            quality <= 50 ? 900 : 1000,
        maxHeight:
            quality <= 50 ? 900 : 1000,
        quality: quality,
      );

      final totalChars =
          result.fold<int>(
        0,
        (sum, item) =>
            sum + item.length,
      );

      if (totalChars <=
          _maxImagePayloadChars) {
        return result;
      }
    }

    throw Exception(
      'The selected images are still too large for Firestore. '
      'Please remove one or more images and try again.',
    );
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  Future<void> _confirmDelete(
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        product,
  ) async {
    final data = product.data();

    final String name =
        (data['name'] ??
                'Unnamed Product')
            .toString();

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF111522),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
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
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.redAccent,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child:
                  const Text('Delete'),
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Product deleted successfully',
          ),
        ),
      );

      await _fetchProducts();
    } catch (e) {
      _showError(
        'Failed to delete product: $e',
      );
    }
  }

  // ============================================================
  // EDIT CONFIRMATION
  // ============================================================

  Future<void> _confirmEdit(
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        product,
  ) async {
    final data = product.data();

    final String name =
        (data['name'] ??
                'Unnamed Product')
            .toString();

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF111522),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
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
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF7C5CFC),
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child: const Text(
                'Continue',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    await _showEditProductDialog(
      product,
    );
  }

  // ============================================================
  // EDIT PRODUCT DIALOG
  // ============================================================

  Future<void> _showEditProductDialog(
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        product,
  ) async {
    final data = product.data();

    final nameController =
        TextEditingController(
      text:
          (data['name'] ?? '').toString(),
    );

    final descriptionController =
        TextEditingController(
      text: _getDescription(data),
    );

    final priceController =
        TextEditingController(
      text:
          (data['price'] ?? '').toString(),
    );

    final stockController =
        TextEditingController(
      text: _getStock(data).toString(),
    );

    final currencyController =
        TextEditingController(
      text:
          (data['currency'] ??
                  'PKR')
              .toString(),
    );

    String selectedCategory =
        _getCategory(data);

    if (selectedCategory.isEmpty) {
      selectedCategory =
          _categories.first;
    }

    final List<String> originalImages =
        _getImages(data);

    List<String> editedImages =
        List<String>.from(
      originalImages,
    );

    bool isAvailable = _getIsAvailable(data);

    // Only keep the current fandom if it really exists (older products
    // stored a wrong id here).
    String? selectedFandomId =
        (data['fandomId'] ?? '').toString();
    if (!_fandoms.any((f) => f['id'] == selectedFandomId)) {
      selectedFandomId = null;
    }

    bool isSaving = false;
    bool imagesChanged = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) {
            Future<void> addImages() async {
              final newImages =
                  await _pickImages();

              if (newImages.isEmpty) {
                return;
              }

              setDialogState(() {
                editedImages.addAll(
                  newImages,
                );
                imagesChanged = true;
              });
            }

            void removeImage(int index) {
              setDialogState(() {
                editedImages.removeAt(
                  index,
                );
                imagesChanged = true;
              });
            }

            void moveImageToFirst(
              int index,
            ) {
              if (index == 0) return;

              setDialogState(() {
                final image =
                    editedImages
                        .removeAt(index);

                editedImages.insert(
                  0,
                  image,
                );

                imagesChanged = true;
              });
            }

            Future<void> saveChanges() async {
              if (nameController.text
                  .trim()
                  .isEmpty) {
                _showError(
                  'Product name is required',
                );
                return;
              }

              if (priceController.text
                  .trim()
                  .isEmpty) {
                _showError(
                  'Price is required',
                );
                return;
              }

              if (stockController.text
                  .trim()
                  .isEmpty) {
                _showError(
                  'Stock is required',
                );
                return;
              }

              final double? price =
                  double.tryParse(
                priceController.text
                    .trim(),
              );

              final int? stock =
                  int.tryParse(
                stockController.text
                    .trim(),
              );

              if (price == null) {
                _showError(
                  'Enter a valid price',
                );
                return;
              }

              if (stock == null) {
                _showError(
                  'Enter a valid stock quantity',
                );
                return;
              }

              setDialogState(() {
                isSaving = true;
              });

              try {
                final updateData =
                    <String, dynamic>{
                  'name':
                      nameController.text
                          .trim(),
                  'description':
                      descriptionController
                          .text
                          .trim(),
                  'currency':
                      currencyController
                              .text
                              .trim()
                              .isEmpty
                          ? 'PKR'
                          : currencyController
                              .text
                              .trim(),
                  'category':
                      selectedCategory,
                  'price': price,
                  'stock': stock,
                  'isAvailable':
                      isAvailable,

                  // Remove the old misspelled fields if they exist.
                  'catgory':
                      FieldValue.delete(),
                  'stcok':
                      FieldValue.delete(),
                  'isavailable':
                      FieldValue.delete(),
                  'updatedAt':
                      FieldValue
                          .serverTimestamp(),
                };

                if (selectedFandomId != null) {
                  updateData['fandomId'] =
                      selectedFandomId;
                }

                if (imagesChanged) {
                  final List<String> prepared =
                      await _prepareImagesForFirestore(
                    editedImages,
                  );

                  // The store reads `imageUrl` (main image) and the admin
                  // screens read `imageUrls` (all images).
                  updateData['imageUrls'] =
                      prepared;
                  updateData['imageUrl'] =
                      prepared.isEmpty
                          ? ''
                          : prepared.first;
                  updateData['imageurls'] =
                      FieldValue.delete();
                }

                await _firestore
                    .collection('products')
                    .doc(product.id)
                    .update(
                      updateData,
                    );

                if (!mounted) return;

                Navigator.pop(
                  dialogContext,
                );

                ScaffoldMessenger.of(
                        context)
                    .showSnackBar(
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
              backgroundColor:
                  const Color(0xFF111522),
              insetPadding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 900,
                  maxHeight: 850,
                ),
                child: Column(
                  children: [
                    // HEADER
                    Padding(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
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
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFF7C5CFC,
                              ).withOpacity(.15),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),
                            child:
                                const Icon(
                              Icons
                                  .edit_rounded,
                              color: Color(
                                0xFF9D87FF,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          const Expanded(
                            child: Text(
                              'Edit Product',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 21,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () =>
                                    Navigator.pop(
                                      dialogContext,
                                    ),
                            icon:
                                const Icon(
                              Icons
                                  .close_rounded,
                              color: Colors
                                  .white70,
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
                      child:
                          SingleChildScrollView(
                        padding:
                            const EdgeInsets
                                .all(22),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            // IMAGES
                            Row(
                              children: [
                                const Text(
                                  'Product Images',
                                  style:
                                      TextStyle(
                                    color: Colors
                                        .white,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  '${editedImages.length} images',
                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .white38,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton
                                    .icon(
                                  onPressed:
                                      isSaving
                                          ? null
                                          : addImages,
                                  icon:
                                      const Icon(
                                    Icons
                                        .add_photo_alternate_outlined,
                                    size: 18,
                                  ),
                                  label:
                                      const Text(
                                    'Add Images',
                                  ),
                                  style:
                                      ElevatedButton
                                          .styleFrom(
                                    backgroundColor:
                                        const Color(
                                      0xFF7C5CFC,
                                    ),
                                    foregroundColor:
                                        Colors
                                            .white,
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal:
                                          14,
                                      vertical:
                                          12,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            if (editedImages
                                .isEmpty)
                              Container(
                                height: 150,
                                width:
                                    double.infinity,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFF171B2B,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    15,
                                  ),
                                  border:
                                      Border.all(
                                    color: Colors
                                        .white10,
                                  ),
                                ),
                                child:
                                    const Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Icon(
                                      Icons
                                          .image_outlined,
                                      color: Colors
                                          .white30,
                                      size: 42,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'No images',
                                      style:
                                          TextStyle(
                                        color: Colors
                                            .white54,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap:
                                    true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                itemCount:
                                    editedImages
                                        .length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      3,
                                  crossAxisSpacing:
                                      10,
                                  mainAxisSpacing:
                                      10,
                                  childAspectRatio:
                                      .95,
                                ),
                                itemBuilder:
                                    (context,
                                        index) {
                                  return Stack(
                                    fit: StackFit
                                        .expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          14,
                                        ),
                                        child:
                                            _buildBase64Image(
                                          editedImages[
                                              index],
                                          fit: BoxFit
                                              .cover,
                                        ),
                                      ),

                                      if (index ==
                                          0)
                                        Positioned(
                                          left: 8,
                                          top: 8,
                                          child:
                                              Container(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal:
                                                  8,
                                              vertical:
                                                  5,
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
                                            child:
                                                const Text(
                                              'MAIN',
                                              style:
                                                  TextStyle(
                                                color:
                                                    Colors.white,
                                                fontSize:
                                                    10,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),

                                      Positioned(
                                        right: 7,
                                        top: 7,
                                        child:
                                            InkWell(
                                          onTap: isSaving
                                              ? null
                                              : () =>
                                                  removeImage(
                                                    index,
                                                  ),
                                          child:
                                              Container(
                                            width: 32,
                                            height: 32,
                                            decoration:
                                                const BoxDecoration(
                                              color: Colors
                                                  .black87,
                                              shape: BoxShape
                                                  .circle,
                                            ),
                                            child:
                                                const Icon(
                                              Icons
                                                  .delete_outline_rounded,
                                              color: Colors
                                                  .white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),

                                      if (index !=
                                          0)
                                        Positioned(
                                          bottom: 7,
                                          left: 7,
                                          right: 7,
                                          child:
                                              InkWell(
                                            onTap: isSaving
                                                ? null
                                                : () =>
                                                    moveImageToFirst(
                                                      index,
                                                    ),
                                            child:
                                                Container(
                                              padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                vertical:
                                                    7,
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
                                              child:
                                                  const Text(
                                                'Make Main',
                                                textAlign:
                                                    TextAlign.center,
                                                style:
                                                    TextStyle(
                                                  color:
                                                      Colors.white,
                                                  fontSize:
                                                      11,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),

                            const SizedBox(
                              height: 24,
                            ),

                            // NAME
                            _buildField(
                              controller:
                                  nameController,
                              label:
                                  'Product Name',
                              icon: Icons
                                  .inventory_2_outlined,
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            // DESCRIPTION
                            _buildField(
                              controller:
                                  descriptionController,
                              label:
                                  'Description',
                              icon: Icons
                                  .description_outlined,
                              maxLines: 4,
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            // PRICE + STOCK
                            LayoutBuilder(
                              builder: (context,
                                  constraints) {
                                if (constraints
                                        .maxWidth <
                                    550) {
                                  return Column(
                                    children: [
                                      _buildField(
                                        controller:
                                            priceController,
                                        label:
                                            'Price',
                                        icon: Icons
                                            .payments_outlined,
                                        keyboardType:
                                            const TextInputType
                                                .numberWithOptions(
                                          decimal:
                                              true,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 14,
                                      ),
                                      _buildField(
                                        controller:
                                            stockController,
                                        label:
                                            'Stock',
                                        icon: Icons
                                            .inventory_outlined,
                                        keyboardType:
                                            TextInputType
                                                .number,
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child:
                                          _buildField(
                                        controller:
                                            priceController,
                                        label:
                                            'Price',
                                        icon: Icons
                                            .payments_outlined,
                                        keyboardType:
                                            const TextInputType
                                                .numberWithOptions(
                                          decimal:
                                              true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 14,
                                    ),
                                    Expanded(
                                      child:
                                          _buildField(
                                        controller:
                                            stockController,
                                        label:
                                            'Stock',
                                        icon: Icons
                                            .inventory_outlined,
                                        keyboardType:
                                            TextInputType
                                                .number,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            // CURRENCY + CATEGORY
                            LayoutBuilder(
                              builder: (context,
                                  constraints) {
                                if (constraints
                                        .maxWidth <
                                    550) {
                                  return Column(
                                    children: [
                                      _buildField(
                                        controller:
                                            currencyController,
                                        label:
                                            'Currency',
                                        icon: Icons
                                            .currency_exchange_rounded,
                                      ),
                                      const SizedBox(
                                        height: 14,
                                      ),
                                      _buildCategoryDropdown(
                                        selectedCategory,
                                        (value) {
                                          setDialogState(
                                            () {
                                              selectedCategory =
                                                  value!;
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child:
                                          _buildField(
                                        controller:
                                            currencyController,
                                        label:
                                            'Currency',
                                        icon: Icons
                                            .currency_exchange_rounded,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 14,
                                    ),
                                    Expanded(
                                      child:
                                          _buildCategoryDropdown(
                                        selectedCategory,
                                        (value) {
                                          setDialogState(
                                            () {
                                              selectedCategory =
                                                  value!;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            // FANDOM
                            _buildFandomDropdown(
                              selectedFandomId,
                              (value) {
                                setDialogState(
                                  () {
                                    selectedFandomId =
                                        value;
                                  },
                                );
                              },
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            // AVAILABLE
                            Container(
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFF171B2B,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                                border:
                                    Border.all(
                                  color: Colors
                                      .white10,
                                ),
                              ),
                              child:
                                  SwitchListTile(
                                value:
                                    isAvailable,
                                onChanged:
                                    isSaving
                                        ? null
                                        : (value) {
                                            setDialogState(
                                              () {
                                                isAvailable =
                                                    value;
                                              },
                                            );
                                          },
                                activeColor:
                                    const Color(
                                  0xFF7C5CFC,
                                ),
                                title:
                                    const Text(
                                  'Product Available',
                                  style:
                                      TextStyle(
                                    color: Colors
                                        .white,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                                subtitle:
                                    Text(
                                  isAvailable
                                      ? 'Customers can purchase this product'
                                      : 'Product is currently unavailable',
                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .white54,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 24,
                            ),

                            // SAVE
                            SizedBox(
                              width:
                                  double.infinity,
                              height: 52,
                              child:
                                  ElevatedButton(
                                onPressed:
                                    isSaving
                                        ? null
                                        : saveChanges,
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      const Color(
                                    0xFF7C5CFC,
                                  ),
                                  foregroundColor:
                                      Colors.white,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                  ),
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2,
                                          color: Colors
                                              .white,
                                        ),
                                      )
                                    : const Text(
                                        'Save Changes',
                                        style:
                                            TextStyle(
                                          fontSize:
                                              15,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
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
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color: Colors.white10,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color: Colors.white10,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
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
    final List<String> items =
        List<String>.from(
      _categories,
    );

    if (!items.contains(value) &&
        value.isNotEmpty) {
      items.insert(0, value);
    }

    return DropdownButtonFormField<String>(
      value: value.isEmpty
          ? null
          : value,
      dropdownColor:
          const Color(0xFF171B2B),
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle:
            const TextStyle(
          color: Colors.white54,
        ),
        prefixIcon: const Icon(
          Icons.category_outlined,
          color: Color(0xFF9D87FF),
        ),
        filled: true,
        fillColor:
            const Color(0xFF171B2B),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color: Colors.white10,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color: Colors.white10,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color: Color(0xFF7C5CFC),
            width: 1.5,
          ),
        ),
      ),
      items: items
          .map(
            (category) =>
                DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildFandomDropdown(
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor:
          const Color(0xFF171B2B),
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: 'Fandom',
        hintText: _fandoms.isEmpty
            ? 'No fandoms found'
            : 'Select fandom',
        labelStyle:
            const TextStyle(
          color: Colors.white54,
        ),
        hintStyle: const TextStyle(
          color: Colors.white38,
        ),
        prefixIcon: const Icon(
          Icons.auto_awesome_rounded,
          color: Color(0xFF9D87FF),
        ),
        filled: true,
        fillColor:
            const Color(0xFF171B2B),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color: Colors.white10,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color: Colors.white10,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color: Color(0xFF7C5CFC),
            width: 1.5,
          ),
        ),
      ),
      items: _fandoms
          .map(
            (fandom) =>
                DropdownMenuItem<String>(
              value: fandom['id'],
              child: Text(
                fandom['name'] ?? '',
                overflow:
                    TextOverflow.ellipsis,
              ),
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
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        product,
  ) {
    final data = product.data();

    final String name =
        (data['name'] ??
                'Unnamed Product')
            .toString();

    // IMPORTANT:
    // Use "description", NOT "desc".
    final String description =
        _getDescription(data);

    final String currency =
        (data['currency'] ??
                'PKR')
            .toString();

    final dynamic priceValue =
        data['price'];

    final String price =
        priceValue is num
            ? priceValue.toString()
            : priceValue?.toString() ??
                '0';

    final dynamic stockValue =
        _getStock(data);

    final String stock =
        stockValue is num
            ? stockValue.toString()
            : stockValue?.toString() ??
                '0';

    final String category =
        _getCategory(data);

    final bool isAvailable = _getIsAvailable(data);

    final List<String> images =
        _getImages(data);

    final dynamic mainImage =
        images.isNotEmpty
            ? images[0]
            : null;

    return Container(
      decoration: BoxDecoration(
        color:
            const Color(0xFF111522),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white10,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              .18,
            ),
            blurRadius: 18,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior:
          Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
                        color:
                            const Color(
                          0xFF171B2B,
                        ),
                        child:
                            const Icon(
                          Icons
                              .image_outlined,
                          color: Colors
                              .white24,
                          size: 55,
                        ),
                      ),

                // GRADIENT
                Positioned.fill(
                  child:
                      DecoratedBox(
                    decoration:
                        BoxDecoration(
                      gradient:
                          LinearGradient(
                        begin:
                            Alignment
                                .topCenter,
                        end:
                            Alignment
                                .bottomCenter,
                        colors: [
                          Colors
                              .transparent,
                          Colors.black
                              .withOpacity(
                            .55,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // AVAILABLE BADGE
                Positioned(
                  top: 10,
                  left: 10,
                  child:
                      Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          isAvailable
                              ? Colors.green
                                  .withOpacity(
                                  .9,
                                )
                              : Colors
                                  .redAccent
                                  .withOpacity(
                                  .9,
                                ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        8,
                      ),
                    ),
                    child: Text(
                      isAvailable
                          ? 'AVAILABLE'
                          : 'UNAVAILABLE',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 9,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ),

                // IMAGE COUNT
                Positioned(
                  bottom: 10,
                  left: 10,
                  child:
                      Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors
                          .black
                          .withOpacity(
                        .7,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        7,
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize
                              .min,
                      children: [
                        const Icon(
                          Icons
                              .photo_library_outlined,
                          size: 13,
                          color: Colors
                              .white,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          '${images.length}',
                          style:
                              const TextStyle(
                            color: Colors
                                .white,
                            fontSize: 11,
                            fontWeight:
                                FontWeight
                                    .w600,
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
            padding:
                const EdgeInsets
                    .fromLTRB(
              14,
              13,
              14,
              14,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                // NAME + CATEGORY
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color: Colors
                              .white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Flexible(
                      child:
                          Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFF7C5CFC,
                          ).withOpacity(
                            .13,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            7,
                          ),
                        ),
                        child: Text(
                          category,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color: Color(
                              0xFFB9AFFF,
                            ),
                            fontSize: 9,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 7,
                ),

                // ==================================================
                // DESCRIPTION
                // ==================================================
                //
                // IMPORTANT:
                // Only ONE line is displayed.
                // Long descriptions automatically get "..."
                // This keeps every product card the same height.
                //
                if (description.isNotEmpty)
                  SizedBox(
                    height: 17,
                    width: double.infinity,
                    child: Text(
                      description,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color:
                            Colors.white54,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  )
                else
                  const SizedBox(
                    height: 17,
                  ),

                const SizedBox(
                  height: 12,
                ),

                // PRICE + STOCK
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            'PRICE',
                            style:
                                TextStyle(
                              color: Colors
                                  .white38,
                              fontSize: 9,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            '$currency $price',
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color: Color(
                                0xFFE0B45A,
                              ),
                              fontSize: 15,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color:
                          Colors.white10,
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          left: 14,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              'STOCK',
                              style:
                                  TextStyle(
                                color: Colors
                                    .white38,
                                fontSize: 9,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              stock,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color: Colors
                                    .white,
                                fontSize: 15,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // ACTION BUTTONS
                // ==================================================

                Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton
                              .icon(
                        onPressed: () =>
                            _confirmEdit(
                          product,
                        ),
                        icon:
                            const Icon(
                          Icons
                              .edit_outlined,
                          size: 17,
                        ),
                        label:
                            const Text(
                          'Edit',
                        ),
                        style:
                            OutlinedButton
                                .styleFrom(
                          foregroundColor:
                              const Color(
                            0xFFB9AFFF,
                          ),
                          side:
                              const BorderSide(
                            color: Color(
                              0xFF7C5CFC,
                            ),
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 11,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                      width: 48,
                      height: 43,
                      child:
                          OutlinedButton(
                        onPressed: () =>
                            _confirmDelete(
                          product,
                        ),
                        style:
                            OutlinedButton
                                .styleFrom(
                          foregroundColor:
                              Colors
                                  .redAccent,
                          side: BorderSide(
                            color: Colors
                                .redAccent
                                .withOpacity(
                              .45,
                            ),
                          ),
                          padding:
                              EdgeInsets.zero,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                        ),
                        child:
                            const Icon(
                          Icons
                              .delete_outline_rounded,
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

  void _showError(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            Colors.redAccent,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final filteredProducts =
        _products.where(
      (product) {
        if (_searchQuery
            .trim()
            .isEmpty) {
          return true;
        }

        final data =
            product.data();

        final name =
            (data['name'] ?? '')
                .toString()
                .toLowerCase();

        final category =
            _getCategory(data)
                .toLowerCase();

        final query =
            _searchQuery
                .toLowerCase();

        return name.contains(query) ||
            category.contains(query);
      },
    ).toList();

    return Scaffold(
      backgroundColor:
          const Color(0xFF080A12),

      appBar: AppBar(
        title: const Text(
          'Product Management',
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(
              right: 10,
            ),
            child: Center(
              child: SizedBox(
                height: 38,
                child:
                    ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AddProductScreen(),
                      ),
                    );

                    if (mounted) {
                      await _fetchProducts();
                    }
                  },
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 17,
                  ),
                  label: const Text(
                    'Add Product',
                  ),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF7C5CFC,
                    ),
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                    ),
                    minimumSize:
                        const Size(
                      0,
                      38,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        10,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      drawer: AdminDrawer(),

      body: SafeArea(
        child:
            LayoutBuilder(
          builder:
              (context, constraints) {
            final double width =
                constraints.maxWidth;

            final bool phone =
                width < 600;

            final bool veryNarrow =
                width < 360;

            final int columns;

            if (width >= 1200) {
              columns = 4;
            } else if (width >= 850) {
              columns = 3;
            } else if (width >= 600) {
              columns = 2;
            } else {
              columns =
                  veryNarrow ? 1 : 2;
            }

            final double
                horizontalPadding =
                width >= 1200
                    ? 32
                    : width >= 850
                        ? 26
                        : phone
                            ? 12
                            : 20;

            final double gap =
                phone ? 10 : 16;

            final double
                availableGridWidth =
                width -
                    (horizontalPadding *
                        2);

            final double cardWidth =
                (availableGridWidth -
                        (gap *
                            (columns -
                                1))) /
                    columns;

            // Main image height.
            final double imageHeight =
                cardWidth / 1.25;

            // Fixed details height.
            //
            // Description is now ALWAYS one line,
            // so all cards remain equal height.
            final double detailsHeight =
                width < 360
                    ? 190
                    : width < 600
                        ? 196
                        : width < 850
                            ? 200
                            : 208;

            final double cardHeight =
                imageHeight +
                    detailsHeight;

            final double
                cardAspectRatio =
                cardWidth /
                    cardHeight;

            return Column(
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Padding(
                  padding:
                      EdgeInsets.fromLTRB(
                    horizontalPadding,
                    phone ? 12 : 20,
                    horizontalPadding,
                    10,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .center,
                    children: [
                      Container(
                        width:
                            phone ? 42 : 46,
                        height:
                            phone ? 42 : 46,
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFF7C5CFC,
                          ).withOpacity(
                            .14,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            phone ? 11 : 13,
                          ),
                        ),
                        child: Icon(
                          Icons
                              .inventory_2_outlined,
                          color:
                              const Color(
                            0xFF9D87FF,
                          ),
                          size:
                              phone ? 22 : 24,
                        ),
                      ),

                      SizedBox(
                        width:
                            phone ? 10 : 13,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Product Management',
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  TextStyle(
                                color: Colors
                                    .white,
                                fontSize:
                                    phone
                                        ? 18
                                        : 21,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            Text(
                              '${_products.length} products',
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  TextStyle(
                                color: Colors
                                    .white54,
                                fontSize:
                                    phone
                                        ? 11
                                        : 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        width:
                            phone ? 2 : 8,
                      ),

                      IconButton(
                        tooltip:
                            'Refresh',
                        padding:
                            EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(
                          minWidth: 42,
                          minHeight: 42,
                        ),
                        onPressed:
                            _isLoading
                                ? null
                                : _fetchProducts,
                        icon:
                            const Icon(
                          Icons
                              .refresh_rounded,
                          color: Colors
                              .white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // SEARCH
                // ==================================================

                Padding(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal:
                        horizontalPadding,
                    vertical: 4,
                  ),
                  child: SizedBox(
                    height:
                        phone ? 48 : 52,
                    child: TextField(
                      onChanged:
                          (value) {
                        setState(() {
                          _searchQuery =
                              value;
                        });
                      },
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                      ),
                      decoration:
                          InputDecoration(
                        hintText:
                            'Search products or categories...',
                        hintStyle:
                            TextStyle(
                          color: Colors
                              .white38,
                          fontSize:
                              phone
                                  ? 12
                                  : 13,
                        ),
                        prefixIcon:
                            const Icon(
                          Icons
                              .search_rounded,
                          color: Color(
                            0xFF9D87FF,
                          ),
                        ),
                        filled: true,
                        fillColor:
                            const Color(
                          0xFF111522,
                        ),
                        contentPadding:
                            EdgeInsets
                                .symmetric(
                          horizontal:
                              phone
                                  ? 12
                                  : 16,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                          borderSide:
                              const BorderSide(
                            color:
                                Colors
                                    .white10,
                          ),
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                          borderSide:
                              const BorderSide(
                            color:
                                Colors
                                    .white10,
                          ),
                        ),
                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                          borderSide:
                              const BorderSide(
                            color: Color(
                              0xFF7C5CFC,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                // ==================================================
                // PRODUCTS
                // ==================================================

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child:
                              CircularProgressIndicator(
                            color: Color(
                              0xFF7C5CFC,
                            ),
                          ),
                        )
                      : filteredProducts
                              .isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              color:
                                  const Color(
                                0xFF7C5CFC,
                              ),
                              backgroundColor:
                                  const Color(
                                0xFF111522,
                              ),
                              onRefresh:
                                  _fetchProducts,
                              child:
                                  GridView.builder(
                                padding:
                                    EdgeInsets
                                        .fromLTRB(
                                  horizontalPadding,
                                  8,
                                  horizontalPadding,
                                  30,
                                ),
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      columns,
                                  crossAxisSpacing:
                                      gap,
                                  mainAxisSpacing:
                                      gap,
                                  childAspectRatio:
                                      cardAspectRatio,
                                ),
                                itemCount:
                                    filteredProducts
                                        .length,
                                itemBuilder:
                                    (context,
                                        index) {
                                  return _buildProductCard(
                                    filteredProducts[
                                        index],
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

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFF7C5CFC,
                ).withOpacity(.10),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons
                    .inventory_2_outlined,
                color: Color(
                  0xFF9D87FF,
                ),
                size: 38,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Text(
              _searchQuery.isEmpty
                  ? 'No Products Yet'
                  : 'No Products Found',
              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 7,
            ),
            Text(
              _searchQuery.isEmpty
                  ? 'Products you add will appear here.'
                  : 'Try another product name or category.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
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