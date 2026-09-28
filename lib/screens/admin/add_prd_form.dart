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

  // Fandom this product belongs to (real document id from `fandoms`).
  String? _selectedFandomId;
  List<Map<String, String>> _fandoms = [];
  bool _loadingFandoms = true;

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
  // LOAD FANDOMS (for the fandom dropdown)
  // ============================================================

  @override
  void initState() {
    super.initState();
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
      setState(() {
        _fandoms = list;
        _loadingFandoms = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingFandoms = false);
    }
  }

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

    // Fandom validation
    if (_selectedFandomId == null || _selectedFandomId!.isEmpty) {
      _showMessage(
        'Please select a fandom',
        isError: true,
      );

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

        // Real fandom document id chosen in the dropdown
        'fandomId': _selectedFandomId,

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
      _selectedFandomId = null;
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
                // FANDOM
                // ==================================================

                const Text(
                  'Fandom',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  initialValue: _selectedFandomId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: _loadingFandoms
                        ? 'Loading fandoms...'
                        : (_fandoms.isEmpty
                            ? 'No fandoms found'
                            : 'Select fandom'),
                    border: const OutlineInputBorder(),
                  ),
                  items: _fandoms
                      .map(
                        (fandom) => DropdownMenuItem<String>(
                          value: fandom['id'],
                          child: Text(
                            fandom['name'] ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFandomId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a fandom';
                    }

                    return null;
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