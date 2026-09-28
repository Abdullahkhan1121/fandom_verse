import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/bookmark_model.dart';
import '../../models/fandom/fandom_model.dart';
import '../../services/bookmark_service.dart';
import '../../services/fandom/fandom_service.dart';
import '../../widgets/fandom_image.dart';
import '../events/events_screen.dart';
import '../fandoms/discover_screen.dart';

// ============================================================
// BOOKMARKS SCREEN
// Tabs: Fandoms / Events / Resources / Images
// Reads the offline copy first, so it opens without internet.
// ============================================================

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final BookmarkService _service = BookmarkService();

  late final Stream<List<BookmarkModel>> _stream = _service.watchAll();

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Creates snapshots for fandoms bookmarked before this feature existed.
    unawaited(_service.syncLegacyFandoms());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------- actions ----------------

  Future<void> _remove(BookmarkModel bookmark) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _service.setBookmarked(bookmark, on: false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Removed "${bookmark.title}"'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => _service.setBookmarked(bookmark, on: true),
            ),
          ),
        );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not remove bookmark: $e')),
      );
    }
  }

  Future<void> _openFandom(BookmarkModel bookmark) async {
    FandomModel? fandom;
    try {
      fandom = await FandomService()
          .getFandomById(bookmark.refId)
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      fandom = null;
    }
    if (!mounted) return;

    // Online: the full fandom page. Offline (or deleted): the saved copy.
    final Widget page = fandom != null
        ? FandomDetailScreen(fandom: fandom)
        : _OfflineFandomReader(bookmark: bookmark);

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _openEvent(BookmarkModel bookmark) {
    DateTime date(String? value) =>
        DateTime.tryParse(value ?? '') ?? DateTime.now();

    final event = EventModel(
      id: bookmark.refId,
      title: bookmark.title,
      description: bookmark.meta['description'] ?? '',
      imageUrl: bookmark.imageUrl,
      category: bookmark.meta['category'] ?? '',
      location: bookmark.meta['location'] ?? '',
      city: bookmark.meta['city'] ?? '',
      ticketLink: bookmark.url,
      startAt: date(bookmark.meta['startAt']),
      endAt: date(bookmark.meta['endAt']),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
    );
  }

  Future<void> _openResource(BookmarkModel bookmark) async {
    final link = bookmark.url.trim();
    final uri = Uri.tryParse(link.startsWith('http') ? link : 'https://$link');

    bool opened = false;
    if (uri != null) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the link. Are you offline?'),
        ),
      );
    }
  }

  void _showFullImage(BookmarkModel bookmark) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                child: FandomImage(
                  imageUrl: bookmark.imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _resourceIcon(String type) {
    switch (type) {
      case 'video':
        return Icons.play_circle_fill;
      case 'podcast':
        return Icons.podcasts;
      default:
        return Icons.article;
    }
  }

  // ---------------- build ----------------

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookmarkModel>>(
      stream: _stream,
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <BookmarkModel>[];
        final query = _query.toLowerCase();

        List<BookmarkModel> of(BookmarkType type) => all.where((b) {
              if (b.type != type) return false;
              if (query.isEmpty) return true;
              return b.title.toLowerCase().contains(query) ||
                  b.subtitle.toLowerCase().contains(query);
            }).toList();

        final fandoms = of(BookmarkType.fandom);
        final events = of(BookmarkType.event);
        final resources = of(BookmarkType.resource);
        final images = of(BookmarkType.image);

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'My Bookmarks',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Fandoms (${fandoms.length})'),
                  Tab(text: 'Events (${events.length})'),
                  Tab(text: 'Resources (${resources.length})'),
                  Tab(text: 'Images (${images.length})'),
                ],
              ),
            ),
            body: !snapshot.hasData
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _query = v.trim()),
                          decoration: InputDecoration(
                            hintText: 'Search your bookmarks',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                  ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildFandoms(fandoms),
                            _buildEvents(events),
                            _buildResources(resources),
                            _buildImages(images),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // ---------------- tabs ----------------

  Widget _buildFandoms(List<BookmarkModel> items) {
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.auto_awesome,
        message: 'No bookmarked fandoms',
        hint: 'Tap the bookmark icon on any fandom in Discover.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FandomImage(imageUrl: item.imageUrl, width: 60, height: 60),
            ),
            title: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              item.meta['tagline']?.isNotEmpty == true
                  ? '${item.subtitle} · ${item.meta['tagline']}'
                  : item.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              tooltip: 'Remove bookmark',
              icon: const Icon(Icons.bookmark_remove, color: Colors.amberAccent),
              onPressed: () => _remove(item),
            ),
            onTap: () => _openFandom(item),
          ),
        );
      },
    );
  }

  Widget _buildEvents(List<BookmarkModel> items) {
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.event,
        message: 'No bookmarked events',
        hint: 'Open an event and tap the bookmark icon to add it to your agenda.',
      );
    }

    // Soonest event first, like an agenda.
    final sorted = [...items]..sort((a, b) {
        final aDate = DateTime.tryParse(a.meta['startAt'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = DateTime.tryParse(b.meta['startAt'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final item = sorted[index];
        final start = DateTime.tryParse(item.meta['startAt'] ?? '');

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FandomImage(imageUrl: item.imageUrl, width: 60, height: 60),
            ),
            title: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              [
                if (start != null) DateFormat('EEE, d MMM yyyy · h:mm a').format(start),
                if (item.subtitle.isNotEmpty) item.subtitle,
              ].join('\n'),
            ),
            isThreeLine: start != null && item.subtitle.isNotEmpty,
            trailing: IconButton(
              tooltip: 'Remove bookmark',
              icon: const Icon(Icons.bookmark_remove, color: Colors.amberAccent),
              onPressed: () => _remove(item),
            ),
            onTap: () => _openEvent(item),
          ),
        );
      },
    );
  }

  Widget _buildResources(List<BookmarkModel> items) {
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.link,
        message: 'No bookmarked resources',
        hint: 'Bookmark news, videos and podcasts from a fandom\'s Resources tab.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Icon(
              _resourceIcon(item.meta['resourceType'] ?? 'news'),
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(item.title),
            subtitle: Text(item.subtitle),
            trailing: IconButton(
              tooltip: 'Remove bookmark',
              icon: const Icon(Icons.bookmark_remove, color: Colors.amberAccent),
              onPressed: () => _remove(item),
            ),
            onTap: () => _openResource(item),
          ),
        );
      },
    );
  }

  Widget _buildImages(List<BookmarkModel> items) {
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.photo_library_outlined,
        message: 'No bookmarked images',
        hint: 'Bookmark pictures from a fandom\'s Gallery tab.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => _showFullImage(item),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                FandomImage(
                  imageUrl: item.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black54,
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: 'Remove bookmark',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.bookmark_remove,
                        color: Colors.amberAccent,
                      ),
                      onPressed: () => _remove(item),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// OFFLINE FANDOM READER
// Shown when the full fandom cannot be loaded (no internet).
// Uses only the text saved inside the bookmark.
// ============================================================

class _OfflineFandomReader extends StatelessWidget {
  const _OfflineFandomReader({required this.bookmark});

  final BookmarkModel bookmark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = bookmark.meta['category'] ?? '';
    final tagline = bookmark.meta['tagline'] ?? '';
    final description = bookmark.meta['description'] ?? '';
    final guide = bookmark.meta['beginnerGuide'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(bookmark.title, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off, color: theme.colorScheme.onSecondaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Saved copy. Connect to the internet to see the latest version.',
                    style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: FandomImage(
                imageUrl: bookmark.imageUrl,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (category.isNotEmpty) Wrap(children: [Chip(label: Text(category))]),
          const SizedBox(height: 8),
          Text(
            bookmark.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (tagline.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              tagline,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(description, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
          ],
          if (guide.isNotEmpty) ...[
            const SizedBox(height: 20),
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New here? Start here',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      guide,
                      style: TextStyle(
                        height: 1.5,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.hint,
  });

  final IconData icon;
  final String message;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Colors.white38),
            const SizedBox(height: 12),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
