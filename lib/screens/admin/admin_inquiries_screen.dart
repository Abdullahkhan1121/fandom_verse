import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/inquiry_service.dart';
import '../theme/app_theme.dart';
import 'admin_drawer.dart';

/// Admin panel screen listing Contact Us inquiries (`inquiries` collection),
/// newest first, with status filters, a detail view, and delete.
class AdminInquiriesScreen extends StatefulWidget {
  const AdminInquiriesScreen({super.key});

  @override
  State<AdminInquiriesScreen> createState() => _AdminInquiriesScreenState();
}

enum _Filter { all, newOnly, resolved }

class _AdminInquiriesScreenState extends State<AdminInquiriesScreen> {
  final InquiryService _service = InquiryService();
  _Filter _filter = _Filter.all;

  Future<void> _setStatus(String id, String status) async {
    try {
      await _service.setStatus(id, status);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not update status: $e', isError: true);
    }
  }

  Future<void> _delete(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data();
    final name = (data['name'] ?? 'this inquiry').toString();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete inquiry?'),
        content: Text(
          'Are you sure you want to delete the message from "$name"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.delete(doc.id);
      if (mounted) _showMessage('Inquiry deleted.');
    } catch (e) {
      if (mounted) _showMessage('Could not delete: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : null,
      ),
    );
  }

  void _openDetail(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _InquiryDetailScreen(
          doc: doc,
          onStatusChange: (status) => _setStatus(doc.id, status),
          onDelete: () => _delete(doc),
        ),
      ),
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilter(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    switch (_filter) {
      case _Filter.all:
        return docs;
      case _Filter.newOnly:
        return docs.where((d) => (d.data()['status'] ?? 'new') == 'new').toList();
      case _Filter.resolved:
        return docs
            .where((d) => (d.data()['status'] ?? 'new') == 'resolved')
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Inquiries')),
      drawer: const AdminDrawer(),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load inquiries: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            );
          }

          final all = snapshot.data?.docs ?? const [];
          final newCount =
              all.where((d) => (d.data()['status'] ?? 'new') == 'new').length;
          final docs = _applyFilter(all);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All (${all.length})',
                      selected: _filter == _Filter.all,
                      onTap: () => setState(() => _filter = _Filter.all),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'New ($newCount)',
                      selected: _filter == _Filter.newOnly,
                      onTap: () => setState(() => _filter = _Filter.newOnly),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Resolved',
                      selected: _filter == _Filter.resolved,
                      onTap: () => setState(() => _filter = _Filter.resolved),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: docs.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data();
                          final status = (data['status'] ?? 'new').toString();
                          final isNew = status == 'new';
                          final createdAt = data['createdAt'] as Timestamp?;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: AppTheme.card(),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isNew
                                      ? AppColors.gold
                                      : AppColors.success,
                                ),
                              ),
                              title: Text(
                                (data['name'] ?? 'Unknown').toString(),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${data['topic'] ?? 'General'} · '
                                    '${data['email'] ?? ''}',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (data['message'] ?? '').toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  if (createdAt != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('d MMM yyyy, h:mm a')
                                          .format(createdAt.toDate()),
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              isThreeLine: true,
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textMuted,
                              ),
                              onTap: () => _openDetail(doc),
                            ),
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
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primary.withValues(alpha: 0.35),
      onSelected: (_) => onTap(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mail_outline_rounded, size: 48, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'No inquiries here',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DETAIL SCREEN
// ============================================================

class _InquiryDetailScreen extends StatefulWidget {
  const _InquiryDetailScreen({
    required this.doc,
    required this.onStatusChange,
    required this.onDelete,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final ValueChanged<String> onStatusChange;
  final VoidCallback onDelete;

  @override
  State<_InquiryDetailScreen> createState() => _InquiryDetailScreenState();
}

class _InquiryDetailScreenState extends State<_InquiryDetailScreen> {
  late String _status = (widget.doc.data()['status'] ?? 'new').toString();
  bool _saving = false;

  Future<void> _toggleStatus() async {
    final next = _status == 'new' ? 'resolved' : 'new';
    setState(() => _saving = true);
    widget.onStatusChange(next);
    if (mounted) {
      setState(() {
        _status = next;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data();
    final createdAt = data['createdAt'] as Timestamp?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inquiry'),
        actions: [
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (data['name'] ?? 'Unknown').toString(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (data['email'] ?? '').toString(),
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text((data['topic'] ?? 'General').toString())),
                    Chip(
                      label: Text(_status),
                      backgroundColor: _status == 'new'
                          ? AppColors.gold.withValues(alpha: 0.25)
                          : AppColors.success.withValues(alpha: 0.25),
                    ),
                  ],
                ),
                if (createdAt != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    DateFormat('EEEE, d MMM yyyy · h:mm a')
                        .format(createdAt.toDate()),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.card(),
            width: double.infinity,
            child: Text(
              (data['message'] ?? '').toString(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _toggleStatus,
              icon: Icon(
                _status == 'new'
                    ? Icons.check_circle_outline_rounded
                    : Icons.undo_rounded,
              ),
              label: Text(
                _status == 'new' ? 'Mark as resolved' : 'Mark as new',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
