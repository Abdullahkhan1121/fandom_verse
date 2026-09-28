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
