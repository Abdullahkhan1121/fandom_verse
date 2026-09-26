import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fandom_verse/screens/admin/admin_drawer.dart';
import 'package:fandom_verse/screens/admin/add_event_screen.dart';
import 'package:flutter/material.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
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

  Stream<QuerySnapshot<Map<String, dynamic>>> _eventsStream() {
    return _firestore
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ============================================================
  // SEARCH
  // ONLY:
  // 1. NAME / TITLE
  // 2. CATEGORY
  // 3. LOCATION
  // ============================================================

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterEvents(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> events,
  ) {
    if (_searchText.isEmpty) {
      return events;
    }

    return events.where((doc) {
      final data = doc.data();

      final String title =
          (data['title'] ?? '').toString().toLowerCase();

      final String category =
          (data['category'] ?? '').toString().toLowerCase();

      final String location =
          (data['location'] ?? '').toString().toLowerCase();

      return title.contains(_searchText) ||
          category.contains(_searchText) ||
          location.contains(_searchText);
    }).toList();
  }

  // ============================================================
  // DELETE EVENT
  // ============================================================

  Future<void> _deleteEvent(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final data = document.data();

    final String title =
        (data['title'] ?? 'this event').toString();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Event?'),
          content: Text(
            'Are you sure you want to delete "$title"?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await document.reference.delete();

      if (!mounted) return;

      _showMessage(
        'Event deleted successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to delete event: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // TOGGLE PUBLISHED
  // ============================================================

  Future<void> _togglePublished(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
    bool value,
  ) async {
    try {
      await document.reference.update({
        'isPublished': value,
        'updatedAt': Timestamp.now(),
      });

      if (!mounted) return;

      _showMessage(
        value
            ? 'Event published.'
            : 'Event unpublished.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to update event: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // EDIT EVENT
  // ============================================================

  void _editEvent(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    /*
     * Replace this navigation with your EditEventScreen
     * when you create it.
     *
     * Example:
     *
     * Navigator.push(
     *   context,
     *   MaterialPageRoute(
     *     builder: (_) => EditEventScreen(
     *       eventId: document.id,
     *     ),
     *   ),
     * );
     */

    _showMessage(
      'Edit screen can be connected here.',
    );
  }

  // ============================================================
  // IMAGE DECODER
  // ============================================================

  Uint8List? _decodeBase64Image(dynamic value) {
    if (value == null) return null;

    final String image = value.toString().trim();

    if (image.isEmpty) return null;

    try {
      String base64String = image;

      if (base64String.contains(',')) {
        base64String =
            base64String.split(',').last;
      }

      return base64Decode(base64String);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // GET EVENT IMAGE
  // ============================================================

  String? _getFirstImage(
    Map<String, dynamic> data,
  ) {
    final dynamic images = data['imageUrls'];

    if (images is List && images.isNotEmpty) {
      final String first =
          images.first.toString();

      if (first.isNotEmpty) {
        return first;
      }
    }

    final dynamic singleImage =
        data['imageUrl'];

    if (singleImage != null &&
        singleImage.toString().isNotEmpty) {
      return singleImage.toString();
    }

    return null;
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(dynamic value) {
    if (value == null) {
      return 'No date';
    }

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }

    if (date == null) {
      return 'Invalid date';
    }

    final String day =
        date.day.toString().padLeft(2, '0');

    final String month =
        date.month.toString().padLeft(2, '0');

    final String year =
        date.year.toString();

    final String hour =
        date.hour.toString().padLeft(2, '0');

    final String minute =
        date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red : Colors.green,
        ),
      );
  }

  // ============================================================
  // ADD EVENT
  // ============================================================

  void _openAddEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEventScreen(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text(
          'Manage Events',
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile =
              constraints.maxWidth < 700;

          return Column(
            children: [
              // ==================================================
              // TOP BAR
              // ==================================================

              Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 28,
                  20,
                  isMobile ? 16 : 28,
                  12,
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          _buildSearchField(),
                          const SizedBox(height: 12),
                          _buildAddButton(),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildSearchField(),
                          ),
                          const SizedBox(width: 16),
                          _buildAddButton(),
                        ],
                      ),
              ),

              // ==================================================
              // EVENTS
              // ==================================================

              Expanded(
                child: StreamBuilder<
                    QuerySnapshot<Map<String, dynamic>>>(
                  stream: _eventsStream(),
                  builder: (
                    context,
                    snapshot,
                  ) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return _buildErrorState(
                        snapshot.error.toString(),
                      );
                    }

                    if (!snapshot.hasData) {
                      return _buildEmptyState(
                        'No events found.',
                      );
                    }

                    final List<
                            QueryDocumentSnapshot<
                                Map<String, dynamic>>>
                        allEvents =
                        snapshot.data!.docs;

                    final List<
                            QueryDocumentSnapshot<
                                Map<String, dynamic>>>
                        filteredEvents =
                        _filterEvents(allEvents);

                    if (filteredEvents.isEmpty) {
                      return _buildEmptyState(
                        _searchText.isEmpty
                            ? 'No events found.'
                            : 'No events match your search.',
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 16 : 28,
                        8,
                        isMobile ? 16 : 28,
                        30,
                      ),
                      itemCount:
                          filteredEvents.length,
                      separatorBuilder: (
                        context,
                        index,
                      ) =>
                          const SizedBox(height: 14),
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        return _buildEventCard(
                          filteredEvents[index],
                          isMobile,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // SEARCH FIELD
  // ============================================================

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText:
            'Search by name, category or location...',
        prefixIcon: const Icon(
          Icons.search,
        ),
        suffixIcon: _searchText.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                },
                icon: const Icon(
                  Icons.clear,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }

  // ============================================================
  // ADD BUTTON
  // ============================================================

  Widget _buildAddButton() {
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: _openAddEvent,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Add Event',
        ),
      ),
    );
  }

  // ============================================================
  // EVENT CARD
  // ============================================================

  Widget _buildEventCard(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
    bool isMobile,
  ) {
    final Map<String, dynamic> data =
        document.data();

    final String title =
        (data['title'] ?? 'Untitled Event')
            .toString();

    final String description =
        (data['description'] ?? '')
            .toString();

    final String category =
        (data['category'] ?? 'Uncategorized')
            .toString();

    final String location =
        (data['location'] ?? 'No location')
            .toString();

    final bool isPublished =
        data['isPublished'] == true;

    final String? image =
        _getFirstImage(data);

    final dynamic imageBytes =
        image == null
            ? null
            : _decodeBase64Image(image);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(
          isMobile ? 12 : 16,
        ),
        child: isMobile
            ? _buildMobileCard(
                data,
                document,
                title,
                description,
                category,
                location,
                isPublished,
                imageBytes,
              )
            : _buildDesktopCard(
                data,
                document,
                title,
                description,
                category,
                location,
                isPublished,
                imageBytes,
              ),
      ),
    );
  }

  // ============================================================
  // DESKTOP CARD
  // ============================================================

  Widget _buildDesktopCard(
    Map<String, dynamic> data,
    QueryDocumentSnapshot<Map<String, dynamic>> document,
    String title,
    String description,
    String category,
    String location,
    bool isPublished,
    Uint8List? imageBytes,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildImage(
          imageBytes,
          width: 180,
          height: 130,
        ),

        const SizedBox(width: 20),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatus(
                    isPublished,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _buildInfoRow(
                Icons.category_outlined,
                category,
              ),

              const SizedBox(height: 5),

              _buildInfoRow(
                Icons.location_on_outlined,
                location,
              ),

              const SizedBox(height: 5),

              _buildInfoRow(
                Icons.calendar_today_outlined,
                _formatDate(
                  data['startAt'],
                ),
              ),

              if (description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  description,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 16),

        _buildActions(
          document,
          isPublished,
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE CARD
  // ============================================================

  Widget _buildMobileCard(
    Map<String, dynamic> data,
    QueryDocumentSnapshot<Map<String, dynamic>> document,
    String title,
    String description,
    String category,
    String location,
    bool isPublished,
    Uint8List? imageBytes,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildImage(
              imageBytes,
              width: 100,
              height: 85,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  _buildStatus(
                    isPublished,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _buildInfoRow(
          Icons.category_outlined,
          category,
        ),

        const SizedBox(height: 6),

        _buildInfoRow(
          Icons.location_on_outlined,
          location,
        ),

        const SizedBox(height: 6),

        _buildInfoRow(
          Icons.calendar_today_outlined,
          _formatDate(data['startAt']),
        ),

        if (description.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 12),

        const Divider(),

        _buildActions(
          document,
          isPublished,
        ),
      ],
    );
  }

  // ============================================================
  // IMAGE
  // ============================================================

  Widget _buildImage(
    Uint8List? imageBytes, {
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(10),
        color: Colors.grey.shade200,
      ),
      child: imageBytes != null
          ? Image.memory(
              imageBytes,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.broken_image_outlined,
                  size: 35,
                );
              },
            )
          : const Icon(
              Icons.event_outlined,
              size: 40,
            ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildStatus(bool published) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),
        color: published
            ? Colors.green.withOpacity(.12)
            : Colors.orange.withOpacity(.12),
      ),
      child: Text(
        published ? 'Published' : 'Draft',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: published
              ? Colors.green
              : Colors.orange,
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
    bool isPublished,
  ) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 4,
      children: [
        IconButton(
          tooltip: 'Edit Event',
          onPressed: () {
            _editEvent(document);
          },
          icon: const Icon(
            Icons.edit_outlined,
          ),
        ),

        IconButton(
          tooltip: isPublished
              ? 'Unpublish'
              : 'Publish',
          onPressed: () {
            _togglePublished(
              document,
              !isPublished,
            );
          },
          icon: Icon(
            isPublished
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),

        IconButton(
          tooltip: 'Delete Event',
          onPressed: () {
            _deleteEvent(document);
          },
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState(
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState(
    String error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 65,
              color: Colors.red,
            ),
            const SizedBox(height: 15),
            const Text(
              'Unable to load events.',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}