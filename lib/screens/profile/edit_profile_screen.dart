import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _loadCurrentName();
  }

  Future<void> _loadCurrentName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final currentName =
          doc.data()?['name'] as String? ?? user.displayName ?? '';
      final currentBio = doc.data()?['bio'] as String? ?? '';

      _nameController.text = currentName;
      _bioController.text = currentBio;
    } catch (_) {
      _nameController.text = user.displayName ?? '';
    } finally {
      if (mounted) {
        setState(() => _isFetching = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Name cannot be empty';
    }
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (trimmed.length > 50) {
      return 'Name must be under 50 characters';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newName = _nameController.text.trim();
    final newBio = _bioController.text.trim();

    setState(() => _isLoading = true);

    try {
      // Update Firebase Auth display name
      await user.updateDisplayName(newName);

      // Update Firestore user document
      // Note: role is intentionally NOT touched here.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': newName,
        'bio': newBio,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body:
          _isFetching
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateName,
                        enabled: !_isLoading,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Bio (optional)',
                          prefixIcon: Icon(Icons.info_outline),
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 150,
                        maxLines: 3,
                        enabled: !_isLoading,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text('Save Changes'),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}