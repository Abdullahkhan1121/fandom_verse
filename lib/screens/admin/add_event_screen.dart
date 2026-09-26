import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  List<Map<String, dynamic>> _fandoms = [];

  String? _selectedFandomId;

  DateTime? _startAt;
  DateTime? _endAt;

  bool _isPublished = true;
  bool _isLoadingFandoms = true;
  bool _isSaving = false;

  /// Every image is stored as a Base64 string.
  ///
  /// Example:
  /// [
  ///   "data:image/jpeg;base64,/9j/4AAQ...",
  ///   "data:image/png;base64,iVBORw0KGgo..."
  /// ]
  final List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _loadFandoms();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD FANDOMS
  // ============================================================

  Future<void> _loadFandoms() async {
    try {
      final snapshot = await _firestore
          .collection('fandoms')
          .orderBy('name')
          .get();

      final fandoms = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unnamed Fandom',
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        _fandoms = fandoms;
        _isLoadingFandoms = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingFandoms = false;
      });

      _showMessage(
        'Failed to load fandoms: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // PICK MULTIPLE IMAGES
  // ============================================================

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedImages =
          await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      if (pickedImages.isEmpty) return;

      for (final XFile image in pickedImages) {
        final Uint8List bytes = await image.readAsBytes();

        final String extension =
            image.name.split('.').last.toLowerCase();

        String mimeType = 'image/jpeg';

        if (extension == 'png') {
          mimeType = 'image/png';
        } else if (extension == 'webp') {
          mimeType = 'image/webp';
        } else if (extension == 'gif') {
          mimeType = 'image/gif';
        }

        final String base64Image =
            'data:$mimeType;base64,${base64Encode(bytes)}';

        if (!_imageUrls.contains(base64Image)) {
          _imageUrls.add(base64Image);
        }
      }

      if (!mounted) return;

      setState(() {});
    } catch (e) {
      _showMessage(
        'Failed to select images: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // REMOVE IMAGE
  // ============================================================

  void _removeImage(int index) {
    if (index < 0 || index >= _imageUrls.length) return;

    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  // ============================================================
  // PICK START DATE/TIME
  // ============================================================

  Future<void> _pickStartDateTime() async {
    final DateTime now = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _startAt ?? now,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _startAt != null
          ? TimeOfDay.fromDateTime(_startAt!)
          : TimeOfDay.now(),
    );

    if (time == null) return;

    final DateTime selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _startAt = selected;

      // Automatically clear invalid end date.
      if (_endAt != null && !_endAt!.isAfter(selected)) {
        _endAt = null;
      }
    });
  }

  // ============================================================
  // PICK END DATE/TIME
  // ============================================================

  Future<void> _pickEndDateTime() async {
    if (_startAt == null) {
      _showMessage(
        'Please select the event start date and time first.',
        isError: true,
      );
      return;
    }

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _endAt ?? _startAt!,
      firstDate: _startAt!,
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _endAt != null
          ? TimeOfDay.fromDateTime(_endAt!)
          : TimeOfDay.fromDateTime(_startAt!),
    );

    if (time == null) return;

    final DateTime selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (!selected.isAfter(_startAt!)) {
      _showMessage(
        'End time must be after start time.',
        isError: true,
      );
      return;
    }

    setState(() {
      _endAt = selected;
    });
  }

  // ============================================================
  // VALIDATE
  // ============================================================

  bool _validateEvent() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_selectedFandomId == null ||
        _selectedFandomId!.trim().isEmpty) {
      _showMessage(
        'Please select a fandom.',
        isError: true,
      );
      return false;
    }

    if (_startAt == null) {
      _showMessage(
        'Please select the event start date and time.',
        isError: true,
      );
      return false;
    }

    if (_endAt == null) {
      _showMessage(
        'Please select the event end date and time.',
        isError: true,
      );
      return false;
    }

    if (!_endAt!.isAfter(_startAt!)) {
      _showMessage(
        'Event end time must be after start time.',
        isError: true,
      );
      return false;
    }

    if (_imageUrls.isEmpty) {
      _showMessage(
        'Please select at least one event image.',
        isError: true,
      );
      return false;
    }

    return true;
  }

  // ============================================================
  // CREATE EVENT
  // ============================================================

  Future<void> _createEvent() async {
    if (_isSaving) return;

    if (!_validateEvent()) return;

    final User? user = _auth.currentUser;

    if (user == null) {
      _showMessage(
        'No authenticated user found.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Generate Firestore document ID first.
      final DocumentReference eventReference =
          _firestore.collection('events').doc();

      final String eventId = eventReference.id;

      final Timestamp startTimestamp =
          Timestamp.fromDate(_startAt!);

      final Timestamp endTimestamp =
          Timestamp.fromDate(_endAt!);

      final Timestamp nowTimestamp = Timestamp.now();

      final Map<String, dynamic> eventData = {
        'eventId': eventId,

        'title': _titleController.text.trim(),

        'description':
            _descriptionController.text.trim(),

        /// Multiple Base64 images.
        'imageUrls': List<String>.from(_imageUrls),

        /// Keep imageUrl as the first image too if your
        /// user-side code expects a single imageUrl.
        'imageUrl':
            _imageUrls.isNotEmpty ? _imageUrls.first : '',

        /// IMPORTANT:
        /// This is the actual document ID from `fandoms`.
        'fandomId': _selectedFandomId,

        'category':
            _categoryController.text.trim(),

        'location':
            _locationController.text.trim(),

        'startAt': startTimestamp,

        'endAt': endTimestamp,

        'isPublished': _isPublished,

        'createdAt': nowTimestamp,

        'updatedAt': nowTimestamp,

        'createdBy': user.uid,
      };

      await eventReference.set(eventData);

      if (!mounted) return;

      _showMessage(
        'Event created successfully.',
      );

      // Clear the form after successful creation.
      _clearForm();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to create event: $e',
        isError: true,
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });
    }
  }

  // ============================================================
  // CLEAR FORM
  // ============================================================

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    _locationController.clear();

    setState(() {
      _selectedFandomId = null;
      _startAt = null;
      _endAt = null;
      _isPublished = true;
      _imageUrls.clear();
    });
  }

  // ============================================================
  // HELPERS
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

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Not selected';
    }

    final String day =
        dateTime.day.toString().padLeft(2, '0');

    final String month =
        dateTime.month.toString().padLeft(2, '0');

    final String year =
        dateTime.year.toString();

    final String hour =
        dateTime.hour.toString().padLeft(2, '0');

    final String minute =
        dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Event title is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // FANDOM DROPDOWN
              _isLoadingFandoms
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : DropdownButtonFormField<String>(
                      value: _selectedFandomId,
                      decoration: const InputDecoration(
                        labelText: 'Fandom',
                        border: OutlineInputBorder(),
                      ),
                      items: _fandoms.map((fandom) {
                        return DropdownMenuItem<String>(
                          value: fandom['id'] as String,
                          child: Text(
                            fandom['name'] as String,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFandomId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please select a fandom';
                        }
                        return null;
                      },
                    ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'Meetup, Convention, Competition...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // START DATE
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Start Date & Time',
                ),
                subtitle: Text(
                  _formatDateTime(_startAt),
                ),
                trailing: ElevatedButton(
                  onPressed: _pickStartDateTime,
                  child: const Text('Select'),
                ),
              ),

              const SizedBox(height: 8),

              // END DATE
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'End Date & Time',
                ),
                subtitle: Text(
                  _formatDateTime(_endAt),
                ),
                trailing: ElevatedButton(
                  onPressed: _pickEndDateTime,
                  child: const Text('Select'),
                ),
              ),

              const SizedBox(height: 20),

              // IMAGES
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Event Images',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(
                      Icons.add_photo_alternate,
                    ),
                    label: const Text('Add Images'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (_imageUrls.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No images selected',
                  ),
                )
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
                  itemCount: _imageUrls.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10),
                          child: Image.memory(
                            _decodeBase64Image(
                              _imageUrls[index],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),

                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () =>
                                _removeImage(index),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(5),
                              decoration:
                                  const BoxDecoration(
                                color: Colors.red,
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
                ),

              const SizedBox(height: 20),

              // PUBLISHED
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Published',
                ),
                subtitle: Text(
                  _isPublished
                      ? 'Users can see this event'
                      : 'Event is hidden from users',
                ),
                value: _isPublished,
                onChanged: (value) {
                  setState(() {
                    _isPublished = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      _isSaving ? null : _createEvent,
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create Event',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BASE64 DECODER
  // ============================================================

  Uint8List _decodeBase64Image(String value) {
    String base64String = value;

    // Handles:
    // data:image/jpeg;base64,...
    // data:image/png;base64,...
    // plain base64 strings
    if (base64String.contains(',')) {
      base64String =
          base64String.split(',').last;
    }

    return base64Decode(base64String);
  }
}