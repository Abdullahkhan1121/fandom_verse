import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class AddFandomScreen extends StatefulWidget {
  const AddFandomScreen({super.key});

  @override
  State<AddFandomScreen> createState() => _AddFandomScreenState();
}

class _AddFandomScreenState extends State<AddFandomScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  final List<String> _images = [];

  bool _isSaving = false;
  bool _isActive = true;
  bool _isTrending = false;

  // New hub content (all optional)
  final _taglineController = TextEditingController();
  final _guideController = TextEditingController();
  final _glossaryController = TextEditingController();
  final _deepDiveController = TextEditingController();
  final _resourcesController = TextEditingController();

  /// Firestore documents are limited to 1 MiB, so keep total image text
  /// (Base64) safely below that. The main image is stored twice.
  static const int _maxImageChars = 800000;
  String? _category;

  final List<String> _categories = [
    'Anime',
    'Movies',
    'TV Shows',
    'Comics',
    'Games',
    'Books',
    'Music',
    'Sports',
    'Superheroes',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _taglineController.dispose();
    _guideController.dispose();
    _glossaryController.dispose();
    _deepDiveController.dispose();
    _resourcesController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK MULTIPLE IMAGES
  // ============================================================

  Future<void> _pickImages() async {
    try {
      final pickedImages = await _picker.pickMultiImage(
        imageQuality: 70,
      );

      if (pickedImages.isEmpty) return;

      setState(() {
        _isSaving = true;
      });

      for (final pickedImage in pickedImages) {
        final bytes = await pickedImage.readAsBytes();

        final base64Image = await _convertToBase64(bytes);

        if (base64Image != null) {
          setState(() {
            _images.add(base64Image);
          });
        }
      }

      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select images: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ============================================================
  // BASE64 CONVERSION + RESIZE + COMPRESSION
  // ============================================================

  Future<String?> _convertToBase64(Uint8List bytes) async {
    try {
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        return null;
      }

      img.Image resizedImage = decodedImage;

      const maxSize = 800;

      if (decodedImage.width > maxSize ||
          decodedImage.height > maxSize) {
        resizedImage = img.copyResize(
          decodedImage,
          width: decodedImage.width > decodedImage.height
              ? maxSize
              : null,
          height: decodedImage.height >= decodedImage.width
              ? maxSize
              : null,
        );
      }

      final compressedBytes = img.encodeJpg(
        resizedImage,
        quality: 70,
      );

      final base64String = base64Encode(compressedBytes);

      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('Image conversion error: $e');
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
  // PARSE TEXT BOXES INTO LISTS
  // Glossary  : one per line ->  Term: meaning
  // Deep dive : one fact per line
  // Resources : one per line ->  type | title | url
  //             (type = news, video or podcast)
  // Lines that don't match the format are skipped.
  // ============================================================

  List<String> _lines(String text) {
    return text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<Map<String, String>> _parseGlossary(String text) {
    final result = <Map<String, String>>[];

    for (final line in _lines(text)) {
      final index = line.indexOf(':');
      if (index <= 0) continue;

      final term = line.substring(0, index).trim();
      final meaning = line.substring(index + 1).trim();

      if (term.isNotEmpty && meaning.isNotEmpty) {
        result.add({'term': term, 'meaning': meaning});
      }
    }

    return result;
  }

  List<Map<String, String>> _parseResources(String text) {
    const allowedTypes = {'news', 'video', 'podcast'};
    final result = <Map<String, String>>[];

    for (final line in _lines(text)) {
      final parts = line.split('|').map((p) => p.trim()).toList();
      if (parts.length < 3) continue;

      final type = parts[0].toLowerCase();
      final title = parts[1];
      final url = parts.sublist(2).join('|').trim();

      if (allowedTypes.contains(type) && title.isNotEmpty && url.isNotEmpty) {
        result.add({'type': type, 'title': title, 'url': url});
      }
    }

    return result;
  }

  // ============================================================
  // GENERATE RANDOM FANDOM ID
  // ============================================================

  String _generateFandomId() {
    final documentId =
        FirebaseFirestore.instance.collection('fandoms').doc().id;

    return 'FND-${documentId.substring(0, 12).toUpperCase()}';
  }

  // ============================================================
  // SAVE FANDOM
  // ============================================================

  Future<void> _saveFandom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
        ),
      );
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one image'),
        ),
      );
      return;
    }

    final int totalImageChars =
        _images.fold<int>(0, (sum, image) => sum + image.length) +
            _images.first.length;

    if (totalImageChars > _maxImageChars) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Images are too large to save. Remove one or use fewer images.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('User is not logged in.');
      }

      final fandomRef =
          FirebaseFirestore.instance.collection('fandoms').doc();

      final fandomId = _generateFandomId();

      await fandomRef.set({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),

        // Main image
        'imageUrl': _images.first,

        // All selected images
        'images': _images,

        'category': _category,

        // Hub content
        'tagline': _taglineController.text.trim(),
        'beginnerGuide': _guideController.text.trim(),
        'glossary': _parseGlossary(_glossaryController.text),
        'deepDive': _lines(_deepDiveController.text),
        'resources': _parseResources(_resourcesController.text),
        'isTrending': _isTrending,

        // Automatically generated
        'fandomId': fandomId,

        // User-created fandom starts pending
        'status': 'pending',

        'isActive': _isActive,

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),

        // Logged-in user's Firebase UID
        'createdBy': currentUser.uid,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fandom submitted successfully! Waiting for approval.',
          ),
          backgroundColor: Color(0xFF7C5CFC),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add fandom: $e'),
          backgroundColor: Colors.redAccent,
        ),
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
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A12),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF080A12),
        title: const Text(
          'Create Fandom',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          return SingleChildScrollView(
            padding: EdgeInsets.all(
              isDesktop ? 32 : 18,
            ),
            child: Form(
              key: _formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1250,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),

                      const SizedBox(height: 28),

                      if (isDesktop)
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildImagesCard(),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildInformationCard(),
                                  const SizedBox(height: 20),
                                  _buildStatusCard(),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildImagesCard(),
                            const SizedBox(height: 20),
                            _buildInformationCard(),
                            const SizedBox(height: 20),
                            _buildStatusCard(),
                          ],
                        ),

                      const SizedBox(height: 30),

                      _buildButtons(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create a New Fandom',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Share a fandom with the Fandom Verse community.',
          style: TextStyle(
            color: Colors.white.withOpacity(.55),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IMAGES CARD
  // ============================================================

  Widget _buildImagesCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.photo_library_outlined,
            'Fandom Images',
          ),

          const SizedBox(height: 8),

          Text(
            'Add multiple images. The first image will be used as the main image.',
            style: TextStyle(
              color: Colors.white.withOpacity(.5),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

          if (_images.isEmpty)
            _emptyImageBox()
          else
            _imageGrid(),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _pickImages,
              icon: const Icon(
                Icons.add_photo_alternate_outlined,
              ),
              label: const Text(
                'Select Multiple Images',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF9D87FF),
                side: const BorderSide(
                  color: Color(0xFF7C5CFC),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyImageBox() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF111522),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 55,
            color: Colors.white.withOpacity(.25),
          ),
          const SizedBox(height: 12),
          Text(
            'No images selected',
            style: TextStyle(
              color: Colors.white.withOpacity(.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _images.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  _base64ToBytes(_images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Main badge
            if (index == 0)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0B45A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'MAIN',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Delete button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Uint8List _base64ToBytes(String base64Image) {
    final base64String = base64Image.split(',').last;
    return base64Decode(base64String);
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInformationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.auto_awesome_outlined,
            'Fandom Information',
          ),

          const SizedBox(height: 22),

          _buildTextField(
            controller: _nameController,
            label: 'Fandom Name',
            hint: 'e.g. Marvel, Naruto, Harry Potter',
            icon: Icons.movie_filter_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter fandom name';
              }

              if (value.trim().length < 2) {
                return 'Fandom name is too short';
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Describe this fandom...',
            icon: Icons.description_outlined,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          _buildCategoryDropdown(),

          const SizedBox(height: 18),

          _buildTextField(
            controller: _taglineController,
            label: 'Tagline',
            hint: 'One short line, e.g. Your friendly neighborhood hero',
            icon: Icons.short_text,
          ),

          const SizedBox(height: 18),

          _buildTextField(
            controller: _guideController,
            label: 'Beginner Guide',
            hint: 'Where should a new fan start? Which show/game/book first?',
            icon: Icons.school_outlined,
            maxLines: 4,
          ),

          const SizedBox(height: 18),

          _buildTextField(
            controller: _glossaryController,
            label: 'Glossary (one per line)',
            hint: 'Term: meaning\nCanon: the official story',
            icon: Icons.menu_book_outlined,
            maxLines: 5,
          ),

          const SizedBox(height: 18),

          _buildTextField(
            controller: _deepDiveController,
            label: 'Deep Dive facts (one per line)',
            hint: 'Hidden trivia, advanced lore, behind-the-scenes facts',
            icon: Icons.lightbulb_outline,
            maxLines: 5,
          ),

          const SizedBox(height: 18),

          _buildTextField(
            controller: _resourcesController,
            label: 'Resources (one per line)',
            hint: 'type | title | url\nvideo | Official trailer | https://...',
            icon: Icons.link,
            maxLines: 5,
          ),

          const SizedBox(height: 8),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: const Color(0xFF7C5CFC),
            title: const Text(
              'Show in Trending carousel',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Featured at the top of the Discover screen.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            value: _isTrending,
            onChanged: (value) => setState(() => _isTrending = value),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY DROPDOWN
  // ============================================================

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _category,
      dropdownColor: const Color(0xFF171B2B),
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: _inputDecoration(
        label: 'Category',
        hint: 'Select fandom category',
        icon: Icons.category_outlined,
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _category = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a category';
        }

        return null;
      },
    );
  }

  // ============================================================
  // STATUS CARD
  // ============================================================

  Widget _buildStatusCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.verified_outlined,
            'Fandom Status',
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111522),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C5CFC)
                        .withOpacity(.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.public,
                    color: Color(0xFF9D87FF),
                  ),
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Fandom',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Enable this fandom after approval.',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Switch(
                  value: _isActive,
                  activeThumbColor:
                      const Color(0xFF7C5CFC),
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE0B45A).withOpacity(.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE0B45A).withOpacity(.2),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFFE0B45A),
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'User-created fandoms are submitted for admin approval before becoming publicly visible.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUTTONS
  // ============================================================

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: BorderSide(
              color: Colors.white.withOpacity(.15),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 17,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Cancel'),
        ),

        const SizedBox(width: 14),

        ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveFandom,
          icon: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send_outlined),
          label: Text(
            _isSaving
                ? 'Submitting...'
                : 'Submit Fandom',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C5CFC),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 17,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
      ),
      validator: validator,
      decoration: _inputDecoration(
        label: label,
        hint: hint,
        icon: icon,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: Colors.white60,
      ),
      hintStyle: const TextStyle(
        color: Colors.white30,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF9D87FF),
      ),
      filled: true,
      fillColor: const Color(0xFF111522),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(.06),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF7C5CFC),
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111522),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: const Color(0xFF7C5CFC).withOpacity(.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF9D87FF),
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}