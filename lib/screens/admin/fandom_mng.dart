import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ManageFandomsScreen extends StatefulWidget {
  const ManageFandomsScreen({super.key});

  @override
  State<ManageFandomsScreen> createState() =>
      _ManageFandomsScreenState();
}

class _ManageFandomsScreenState extends State<ManageFandomsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final ImagePicker _picker = ImagePicker();

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
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
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery =
            _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // FIRESTORE STREAM
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _fandomStream() {
    return _firestore
        .collection('fandoms')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // ============================================================
  // FILTER FANDOMS
  // ============================================================

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      _filterFandoms(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.where((doc) {
      final data = doc.data();

      final name =
          (data['name'] ?? '').toString().toLowerCase();

      final category =
          (data['category'] ?? '').toString();

      final matchesSearch =
          _searchQuery.isEmpty ||
          name.contains(_searchQuery) ||
          category.toLowerCase().contains(_searchQuery);

      final matchesCategory =
          _selectedCategory == 'All' ||
          category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // ============================================================
  // ADD FANDOM
  // ============================================================

  void _openAddFandom() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddFandomScreen(),
      ),
    );
  }

  // ============================================================
  // EDIT CONFIRMATION
  // ============================================================

  Future<void> _confirmEdit(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final data = document.data();

    if (data == null) return;

    final name = data['name'] ?? 'this fandom';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF171B2B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Fandom?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to edit "$name"?',
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white60,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF7C5CFC),
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditFandomScreen(
          documentId: document.id,
          fandomData: data,
        ),
      ),
    );
  }

  // ============================================================
  // DELETE CONFIRMATION
  // ============================================================

  Future<void> _confirmDelete(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final data = document.data();

    if (data == null) return;

    final name = data['name'] ?? 'this fandom';

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF171B2B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color:
                      Colors.redAccent.withOpacity(.12),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Delete Fandom?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to permanently delete "$name"?\n\nThis action cannot be undone.',
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white60,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _deleteFandom(document.id);
  }

  // ============================================================
  // DELETE FANDOM
  // ============================================================

  Future<void> _deleteFandom(String documentId) async {
    try {
      await _firestore
          .collection('fandoms')
          .doc(documentId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fandom deleted successfully.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete fandom: $e',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ============================================================
  // TOGGLE ACTIVE STATUS
  // ============================================================

  Future<void> _toggleActive(
    String documentId,
    bool currentValue,
  ) async {
    try {
      await _firestore
          .collection('fandoms')
          .doc(documentId)
          .update({
        'isActive': !currentValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentValue
                ? 'Fandom deactivated.'
                : 'Fandom activated.',
          ),
          backgroundColor:
              const Color(0xFF7C5CFC),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update status: $e',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080A12),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Manage Fandoms',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop =
              constraints.maxWidth >= 900;

          return StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
            stream: _fandomStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF7C5CFC),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _buildError(
                  snapshot.error.toString(),
                );
              }

              final docs =
                  snapshot.data?.docs ?? [];

              final fandoms =
                  _filterFandoms(docs);

              return SingleChildScrollView(
                padding: EdgeInsets.all(
                  isDesktop ? 30 : 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 1400,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildHeader(
                          total: docs.length,
                        ),

                        const SizedBox(height: 25),

                        _buildSearchArea(
                          isDesktop,
                        ),

                        const SizedBox(height: 25),

                        if (fandoms.isEmpty)
                          _buildEmptyState()
                        else
                          _buildFandomGrid(
                            fandoms,
                            isDesktop,
                          ),
                      ],
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader({
    required int total,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Fandoms',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$total fandom${total == 1 ? '' : 's'} in your collection',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        ElevatedButton.icon(
          onPressed: _openAddFandom,
          icon: const Icon(
            Icons.add,
            size: 20,
          ),
          label: const Text(
            'Add Fandom',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF7C5CFC),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchArea(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111522),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(.06),
        ),
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                  child: _buildSearchField(),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 230,
                  child: _buildCategoryFilter(),
                ),
              ],
            )
          : Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 14),
                _buildCategoryFilter(),
              ],
            ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText:
            'Search by fandom name or category...',
        hintStyle: const TextStyle(
          color: Colors.white38,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF9D87FF),
        ),
        suffixIcon:
            _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.white54,
                    ),
                  )
                : null,
        filled: true,
        fillColor: const Color(0xFF171B2B),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF7C5CFC),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
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
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory =
              value ?? 'All';
        });
      },
    );
  }

  // ============================================================
  // FANDOM GRID
  // ============================================================

  Widget _buildFandomGrid(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        fandoms,
    bool isDesktop,
  ) {
    int crossAxisCount;

    if (!isDesktop) {
      crossAxisCount = 1;
    } else if (MediaQuery.of(context).size.width >=
        1250) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: fandoms.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio:
            crossAxisCount == 1 ? 2.5 : 1.15,
      ),
      itemBuilder: (context, index) {
        return _buildFandomCard(
          fandoms[index],
        );
      },
    );
  }

  // ============================================================
  // FANDOM CARD
  // ============================================================

  Widget _buildFandomCard(
    QueryDocumentSnapshot<Map<String, dynamic>>
        document,
  ) {
    final data = document.data();

    final String name =
        (data['name'] ?? 'Unnamed Fandom')
            .toString();

    final String description =
        (data['description'] ?? '')
            .toString();

    final String category =
        (data['category'] ?? 'Other')
            .toString();

    final String status =
        (data['status'] ?? 'pending')
            .toString();

    final bool isActive =
        data['isActive'] == true;

    final String imageUrl =
        (data['imageUrl'] ?? '')
            .toString();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111522),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: _buildFandomImage(
                      imageUrl,
                    ),
                  ),
                ),

                Positioned(
                  top: 12,
                  left: 12,
                  child: _badge(
                    category,
                    const Color(0xFF7C5CFC),
                  ),
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: _statusBadge(
                    status,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      PopupMenuButton<String>(
                        color:
                            const Color(0xFF171B2B),
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white54,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _confirmEdit(
                              document,
                            );
                          }

                          if (value == 'delete') {
                            _confirmDelete(
                              document,
                            );
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  color:
                                      Color(0xFF9D87FF),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color:
                                      Colors.redAccent,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  Expanded(
                    child: Text(
                      description.isEmpty
                          ? 'No description available.'
                          : description,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              isActive
                                  ? Icons.check_circle
                                  : Icons
                                      .cancel_outlined,
                              size: 16,
                              color: isActive
                                  ? Colors.greenAccent
                                  : Colors.white38,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isActive
                                  ? 'Active'
                                  : 'Inactive',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.greenAccent
                                    : Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        tooltip: 'Edit fandom',
                        onPressed: () =>
                            _confirmEdit(
                          document,
                        ),
                        icon: const Icon(
                          Icons.edit_outlined,
                          color:
                              Color(0xFF9D87FF),
                          size: 20,
                        ),
                      ),

                      IconButton(
                        tooltip: 'Delete fandom',
                        onPressed: () =>
                            _confirmDelete(
                          document,
                        ),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 20,
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

  // ============================================================
  // IMAGE
  // ============================================================

  Widget _buildFandomImage(
    String imageUrl,
  ) {
    if (imageUrl.isEmpty) {
      return _imagePlaceholder();
    }

    try {
      if (imageUrl.startsWith(
        'data:image',
      )) {
        final bytes =
            _base64ToBytes(imageUrl);

        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) =>
                  _imagePlaceholder(),
        );
      }

      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) =>
                _imagePlaceholder(),
      );
    } catch (_) {
      return _imagePlaceholder();
    }
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFF171B2B),
      child: const Center(
        child: Icon(
          Icons.auto_awesome,
          color: Color(0xFF7C5CFC),
          size: 42,
        ),
      ),
    );
  }

  Uint8List _base64ToBytes(
    String base64Image,
  ) {
    final base64String =
        base64Image.split(',').last;

    return base64Decode(base64String);
  }

  // ============================================================
  // BADGES
  // ============================================================

  Widget _badge(
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.65),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withOpacity(.5),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statusBadge(
    String status,
  ) {
    Color color;

    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.greenAccent;
        break;

      case 'rejected':
        color = Colors.redAccent;
        break;

      default:
        color = const Color(0xFFE0B45A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.7),
        borderRadius:
            BorderRadius.circular(9),
        border: Border.all(
          color: color.withOpacity(.5),
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: .5,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    final hasFilter =
        _searchQuery.isNotEmpty ||
        _selectedCategory != 'All';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 70,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111522),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(.06),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF7C5CFC)
                  .withOpacity(.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              color: Color(0xFF9D87FF),
              size: 42,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            hasFilter
                ? 'No fandoms found'
                : 'No fandoms yet',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            hasFilter
                ? 'Try changing your search or category filter.'
                : 'Start building your fandom collection.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),

          if (!hasFilter) ...[
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: _openAddFandom,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add First Fandom',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF7C5CFC),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
    String error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 55,
            ),
            const SizedBox(height: 15),
            const Text(
              'Unable to load fandoms',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// EDIT FANDOM SCREEN
// ==================================================================

class EditFandomScreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> fandomData;

  const EditFandomScreen({
    super.key,
    required this.documentId,
    required this.fandomData,
  });

  @override
  State<EditFandomScreen> createState() =>
      _EditFandomScreenState();
}

class _EditFandomScreenState
    extends State<EditFandomScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();

  final List<String> _images = [];

  String? _category;
  bool _isActive = true;
  bool _isSaving = false;

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
  void initState() {
    super.initState();

    _nameController.text =
        (widget.fandomData['name'] ?? '')
            .toString();

    _descriptionController.text =
        (widget.fandomData['description'] ?? '')
            .toString();

    _category =
        widget.fandomData['category']
            ?.toString();

    _isActive =
        widget.fandomData['isActive'] == true;

    final existingImages =
        widget.fandomData['images'];

    if (existingImages is List) {
      _images.addAll(
        existingImages
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty),
      );
    }

    // Backwards compatibility if only imageUrl exists.
    if (_images.isEmpty) {
      final mainImage =
          widget.fandomData['imageUrl']
              ?.toString();

      if (mainImage != null &&
          mainImage.isNotEmpty) {
        _images.add(mainImage);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK IMAGES
  // ============================================================

  Future<void> _pickImages() async {
    try {
      final pickedImages =
          await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (pickedImages.isEmpty) return;

      setState(() {
        _isSaving = true;
      });

      for (final pickedImage in pickedImages) {
        final bytes =
            await pickedImage.readAsBytes();

        final base64Image =
            await _convertToBase64(bytes);

        if (base64Image != null) {
          setState(() {
            _images.add(base64Image);
          });
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to select images: $e',
          ),
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
  // BASE64
  // ============================================================

  Future<String?> _convertToBase64(
    Uint8List bytes,
  ) async {
    try {
      final decodedImage =
          img.decodeImage(bytes);

      if (decodedImage == null) {
        return null;
      }

      img.Image resizedImage =
          decodedImage;

      const maxSize = 1200;

      if (decodedImage.width > maxSize ||
          decodedImage.height > maxSize) {
        resizedImage = img.copyResize(
          decodedImage,
          width:
              decodedImage.width >
                      decodedImage.height
                  ? maxSize
                  : null,
          height:
              decodedImage.height >=
                      decodedImage.width
                  ? maxSize
                  : null,
        );
      }

      final compressedBytes =
          img.encodeJpg(
        resizedImage,
        quality: 75,
      );

      final base64String =
          base64Encode(compressedBytes);

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
  // UPDATE
  // ============================================================

  Future<void> _updateFandom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_category == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Please select a category'),
        ),
      );
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one image',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('fandoms')
          .doc(widget.documentId)
          .update({
        'name':
            _nameController.text.trim(),
        'description':
            _descriptionController.text.trim(),
        'imageUrl': _images.first,
        'images': _images,
        'category': _category,
        'isActive': _isActive,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Fandom updated successfully.',
          ),
          backgroundColor:
              Color(0xFF7C5CFC),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update fandom: $e',
          ),
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A12),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF080A12),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Edit Fandom',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop =
              constraints.maxWidth >= 900;

          return SingleChildScrollView(
            padding: EdgeInsets.all(
              isDesktop ? 30 : 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 1200,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildEditHeader(),

                      const SizedBox(height: 25),

                      if (isDesktop)
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child:
                                  _buildImagesCard(),
                            ),
                            const SizedBox(
                              width: 22,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildInfoCard(),
                                  const SizedBox(
                                    height: 20,
                                  ),
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
                            const SizedBox(
                              height: 20,
                            ),
                            _buildInfoCard(),
                            const SizedBox(
                              height: 20,
                            ),
                            _buildStatusCard(),
                          ],
                        ),

                      const SizedBox(height: 25),

                      _buildActionButtons(),
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

  Widget _buildEditHeader() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Update Fandom',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Modify the fandom information and images.',
          style: TextStyle(
            color: Colors.white.withOpacity(.5),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IMAGE CARD
  // ============================================================

  Widget _buildImagesCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.photo_library_outlined,
            'Fandom Images',
          ),

          const SizedBox(height: 8),

          const Text(
            'The first image is used as the main fandom image.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 18),

          if (_images.isEmpty)
            _emptyImage()
          else
            GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: _images.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder:
                  (context, index) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                        child: _imageWidget(
                          _images[index],
                        ),
                      ),
                    ),

                    if (index == 0)
                      Positioned(
                        top: 9,
                        left: 9,
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
                              0xFFE0B45A,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              7,
                            ),
                          ),
                          child: const Text(
                            'MAIN',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    Positioned(
                      top: 7,
                      right: 7,
                      child: GestureDetector(
                        onTap: () =>
                            _removeImage(
                          index,
                        ),
                        child: Container(
                          padding:
                              const EdgeInsets
                                  .all(6),
                          decoration:
                              const BoxDecoration(
                            color: Colors.black87,
                            shape:
                                BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  _isSaving
                      ? null
                      : _pickImages,
              icon: const Icon(
                Icons.add_photo_alternate_outlined,
              ),
              label: const Text(
                'Add More Images',
              ),
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(0xFF9D87FF),
                side: const BorderSide(
                  color: Color(0xFF7C5CFC),
                ),
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.auto_awesome_outlined,
            'Fandom Information',
          ),

          const SizedBox(height: 20),

          _textField(
            controller: _nameController,
            label: 'Fandom Name',
            hint: 'Enter fandom name',
            icon: Icons.movie_filter_outlined,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Please enter fandom name';
              }

              return null;
            },
          ),

          const SizedBox(height: 17),

          _textField(
            controller:
                _descriptionController,
            label: 'Description',
            hint: 'Describe this fandom...',
            icon:
                Icons.description_outlined,
            maxLines: 5,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Please enter description';
              }

              return null;
            },
          ),

          const SizedBox(height: 17),

          DropdownButtonFormField<String>(
            value: _category,
            dropdownColor:
                const Color(0xFF171B2B),
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: _inputDecoration(
              label: 'Category',
              hint: 'Select category',
              icon:
                  Icons.category_outlined,
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
                _category = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select category';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildStatusCard() {
    final status =
        (widget.fandomData['status'] ??
                'pending')
            .toString();

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.settings_outlined,
            'Fandom Status',
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Control whether this fandom is active.',
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(.45),
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

          const SizedBox(height: 14),

          Container(
            padding:
                const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF171B2B),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color:
                      Color(0xFFE0B45A),
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Current approval status: ${status.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
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
  // ACTION BUTTONS
  // ============================================================

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.pop(
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
                const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 16,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(13),
            ),
          ),
          child: const Text('Cancel'),
        ),

        const SizedBox(width: 12),

        ElevatedButton.icon(
          onPressed: _isSaving
              ? null
              : _updateFandom,
          icon: _isSaving
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.save_outlined,
                ),
          label: Text(
            _isSaving
                ? 'Updating...'
                : 'Update Fandom',
          ),
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF7C5CFC),
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 16,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(13),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IMAGE WIDGET
  // ============================================================

  Widget _imageWidget(
    String image,
  ) {
    if (image.startsWith('data:image')) {
      try {
        return Image.memory(
          _base64ToBytes(image),
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) =>
                  _emptyImage(),
        );
      } catch (_) {
        return _emptyImage();
      }
    }

    return Image.network(
      image,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) =>
              _emptyImage(),
    );
  }

  Uint8List _base64ToBytes(
    String value,
  ) {
    return base64Decode(
      value.split(',').last,
    );
  }

  Widget _emptyImage() {
    return Container(
      color: const Color(0xFF171B2B),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.white30,
          size: 40,
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required TextEditingController
        controller,
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
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white
              .withOpacity(.06),
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF7C5CFC),
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
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: const Color(0xFF111522),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              Colors.white.withOpacity(.06),
        ),
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
          padding:
              const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: const Color(0xFF7C5CFC)
                .withOpacity(.12),
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color:
                const Color(0xFF9D87FF),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY IMAGE
  // ============================================================
}

// ==================================================================
// ADD FANDOM SCREEN
// ==================================================================
// This is included so the "Add Fandom" button works.
// If you already have the AddFandomScreen from the previous message,
// you can remove this class and keep your existing one.
// ==================================================================

class AddFandomScreen extends StatefulWidget {
  const AddFandomScreen({super.key});

  @override
  State<AddFandomScreen> createState() =>
      _AddFandomScreenState();
}

class _AddFandomScreenState
    extends State<AddFandomScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();

  final List<String> _images = [];

  bool _isSaving = false;
  bool _isActive = true;
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
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final pickedImages =
          await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (pickedImages.isEmpty) return;

      setState(() {
        _isSaving = true;
      });

      for (final pickedImage
          in pickedImages) {
        final bytes =
            await pickedImage.readAsBytes();

        final base64Image =
            await _convertToBase64(bytes);

        if (base64Image != null) {
          setState(() {
            _images.add(base64Image);
          });
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to select images: $e',
          ),
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

  Future<String?> _convertToBase64(
    Uint8List bytes,
  ) async {
    try {
      final decodedImage =
          img.decodeImage(bytes);

      if (decodedImage == null) {
        return null;
      }

      img.Image resizedImage =
          decodedImage;

      const maxSize = 1200;

      if (decodedImage.width > maxSize ||
          decodedImage.height > maxSize) {
        resizedImage = img.copyResize(
          decodedImage,
          width:
              decodedImage.width >
                      decodedImage.height
                  ? maxSize
                  : null,
          height:
              decodedImage.height >=
                      decodedImage.width
                  ? maxSize
                  : null,
        );
      }

      final compressedBytes =
          img.encodeJpg(
        resizedImage,
        quality: 75,
      );

      return 'data:image/jpeg;base64,${base64Encode(compressedBytes)}';
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveFandom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one image.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          'You must be logged in.',
        );
      }

      final ref = FirebaseFirestore
          .instance
          .collection('fandoms')
          .doc();

      final fandomId =
          'FND-${ref.id.substring(0, 12).toUpperCase()}';

      await ref.set({
        'name':
            _nameController.text.trim(),
        'description':
            _descriptionController
                .text
                .trim(),
        'imageUrl': _images.first,
        'images': _images,
        'category': _category,
        'fandomId': fandomId,
        'status': 'pending',
        'isActive': _isActive,
        'createdAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
        'createdBy': user.uid,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Fandom submitted successfully.',
          ),
          backgroundColor:
              Color(0xFF7C5CFC),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add fandom: $e',
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF080A12),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF080A12),
        elevation: 0,
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Add Fandom',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder:
            (context, constraints) {
          final desktop =
              constraints.maxWidth >= 900;

          return SingleChildScrollView(
            padding: EdgeInsets.all(
              desktop ? 30 : 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 1200,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (desktop)
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Expanded(
                              child:
                                  _imageCard(),
                            ),
                            const SizedBox(
                              width: 22,
                            ),
                            Expanded(
                              child:
                                  _formCard(),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _imageCard(),
                            const SizedBox(
                              height: 20,
                            ),
                            _formCard(),
                          ],
                        ),

                      const SizedBox(
                        height: 25,
                      ),

                      _buttons(),
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

  Widget _imageCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _title(
            Icons.photo_library_outlined,
            'Fandom Images',
          ),
          const SizedBox(height: 18),
          if (_images.isEmpty)
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                    const Color(0xFF171B2B),
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.white30,
                  size: 50,
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: _images.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder:
                  (context, index) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius
                                .circular(14),
                        child: Image.memory(
                          base64Decode(
                            _images[index]
                                .split(',')
                                .last,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (index == 0)
                      Positioned(
                        top: 7,
                        left: 7,
                        child: Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          color:
                              const Color(
                            0xFFE0B45A,
                          ),
                          child: const Text(
                            'MAIN',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _images
                                .removeAt(
                              index,
                            );
                          });
                        },
                        child: Container(
                          padding:
                              const EdgeInsets
                                  .all(6),
                          decoration:
                              const BoxDecoration(
                            color: Colors.black87,
                            shape:
                                BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  _isSaving
                      ? null
                      : _pickImages,
              icon: const Icon(
                Icons.add_photo_alternate_outlined,
              ),
              label: const Text(
                'Select Multiple Images',
              ),
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(0xFF9D87FF),
                side: const BorderSide(
                  color: Color(0xFF7C5CFC),
                ),
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _title(
            Icons.auto_awesome_outlined,
            'Fandom Information',
          ),
          const SizedBox(height: 20),

          _field(
            _nameController,
            'Fandom Name',
            'e.g. Marvel',
            Icons.movie_filter_outlined,
          ),

          const SizedBox(height: 16),

          _field(
            _descriptionController,
            'Description',
            'Describe this fandom...',
            Icons.description_outlined,
            maxLines: 5,
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _category,
            dropdownColor:
                const Color(0xFF171B2B),
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: _decoration(
              'Category',
              'Select category',
              Icons.category_outlined,
            ),
            items: _categories
                .map(
                  (e) =>
                      DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(() {
                _category = v;
              });
            },
            validator: (v) =>
                v == null
                    ? 'Select category'
                    : null,
          ),
        ],
      ),
    );
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.pop(
                    context,
                  ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed:
              _isSaving
                  ? null
                  : _saveFandom,
          icon: _isSaving
              ? const SizedBox(
                  height: 17,
                  width: 17,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.add,
                ),
          label: Text(
            _isSaving
                ? 'Adding...'
                : 'Add Fandom',
          ),
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF7C5CFC),
            foregroundColor:
                Colors.white,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
      ),
      validator: (value) =>
          value == null ||
                  value.trim().isEmpty
              ? 'Please enter $label'
              : null,
      decoration: _decoration(
        label,
        hint,
        icon,
      ),
    );
  }

  InputDecoration _decoration(
    String label,
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle:
          const TextStyle(
        color: Colors.white60,
      ),
      hintStyle:
          const TextStyle(
        color: Colors.white30,
      ),
      prefixIcon: Icon(
        icon,
        color:
            const Color(0xFF9D87FF),
      ),
      filled: true,
      fillColor:
          const Color(0xFF111522),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        borderSide:
            BorderSide.none,
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        borderSide:
            const BorderSide(
          color:
              Color(0xFF7C5CFC),
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color:
            const Color(0xFF111522),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: Colors.white
              .withOpacity(.06),
        ),
      ),
      child: child,
    );
  }

  Widget _title(
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color:
                const Color(0xFF7C5CFC)
                    .withOpacity(.12),
            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
          child: Icon(
            icon,
            color:
                const Color(0xFF9D87FF),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }
}