import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/fandom/fandom_model.dart';
import '../../services/fandom/fandom_service.dart';
import '../../widgets/fandom_image.dart';
import '../../models/bookmark_model.dart';
import '../../services/bookmark_service.dart';
import '../../widgets/bookmark_button.dart';

enum _SortOption { newest, nameAz, nameZa }

// ============================================================
// DISCOVER SCREEN
// Trending carousel + search + category filter + sort +
// like / bookmark (saved) fandoms.
// ============================================================

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final FandomService _service = FandomService();

  // Each stream is created once and listened to once.
  late final Stream<List<FandomModel>> _fandomsStream =
      _service.getActiveFandoms();
  late final Stream<Set<String>> _savedStream =
      _service.watchUserIds(FandomService.bookmarkedField);
  late final Stream<Set<String>> _likedStream =
      _service.watchUserIds(FandomService.likedField);

  final TextEditingController _searchController = TextEditingController();
  final PageController _carouselController =
      PageController(viewportFraction: 0.88);

  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _showSavedOnly = false;
  _SortOption _sort = _SortOption.newest;

  @override
  void dispose() {
    _searchController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  List<FandomModel> _applyFilters(
    List<FandomModel> fandoms,
    Set<String> saved,
  ) {
    final query = _searchQuery.toLowerCase();

    final result = fandoms.where((f) {
      if (_showSavedOnly && !saved.contains(f.id)) return false;
      if (_selectedCategory != 'All' && f.category != _selectedCategory) {
        return false;
      }
      if (query.isEmpty) return true;
      return f.name.toLowerCase().contains(query) ||
          f.tagline.toLowerCase().contains(query) ||
          f.category.toLowerCase().contains(query);
    }).toList();

    switch (_sort) {
      case _SortOption.nameAz:
        result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      case _SortOption.nameZa:
        result.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
      case _SortOption.newest:
        result.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
    }

    return result;
  }

  final BookmarkService _bookmarks = BookmarkService();

  Future<void> _toggleBookmark(FandomModel fandom, bool currentlyOn) async {
    try {
      await _bookmarks.setBookmarked(
        BookmarkModel.fandom(fandom),
        on: !currentlyOn,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update: $e')),
      );
    }
  }

  void _openDetail(FandomModel fandom) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FandomDetailScreen(fandom: fandom)),
    );
  }

  Future<void> _toggle(String field, String id, bool currentlyOn) async {
    try {
      await _service.setUserId(field: field, fandomId: id, add: !currentlyOn);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: _showSavedOnly ? 'Show all' : 'Show saved',
            icon: Icon(
              _showSavedOnly ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: () => setState(() => _showSavedOnly = !_showSavedOnly),
          ),
        ],
      ),
      body: StreamBuilder<List<FandomModel>>(
        stream: _fandomsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load fandoms.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final fandoms = snapshot.data ?? [];

          return StreamBuilder<Set<String>>(
            stream: _savedStream,
            initialData: const <String>{},
            builder: (context, savedSnap) {
              final saved = savedSnap.data ?? <String>{};

              return StreamBuilder<Set<String>>(
                stream: _likedStream,
                initialData: const <String>{},
                builder: (context, likedSnap) {
                  final liked = likedSnap.data ?? <String>{};
                  return _buildContent(fandoms, saved, liked);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(
    List<FandomModel> fandoms,
    Set<String> saved,
    Set<String> liked,
  ) {
    final theme = Theme.of(context);

    final categories = <String>{
      for (final f in fandoms)
        if (f.category.trim().isNotEmpty) f.category.trim(),
    }.toList()
      ..sort();

    final activeCategory =
        (_selectedCategory == 'All' || categories.contains(_selectedCategory))
            ? _selectedCategory
            : 'All';

    final filtered = _applyFilters(fandoms, saved);
    final trending = fandoms.where((f) => f.isTrending).toList();

    final showCarousel = trending.isNotEmpty &&
        !_showSavedOnly &&
        _searchQuery.isEmpty &&
        activeCategory == 'All';

    return CustomScrollView(
      slivers: [
        // ---------- HEADER + SEARCH + SORT ----------
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Your Fandom',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search fandoms',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    PopupMenuButton<_SortOption>(
                      tooltip: 'Sort',
                      icon: const Icon(Icons.sort),
                      initialValue: _sort,
                      onSelected: (v) => setState(() => _sort = v),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: _SortOption.newest,
                          child: Text('Newest first'),
                        ),
                        PopupMenuItem(
                          value: _SortOption.nameAz,
                          child: Text('Name A-Z'),
                        ),
                        PopupMenuItem(
                          value: _SortOption.nameZa,
                          child: Text('Name Z-A'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ---------- CATEGORY CHIPS ----------
        SliverToBoxAdapter(
          child: SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final category in ['All', ...categories])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: activeCategory == category,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ---------- TRENDING CAROUSEL ----------
        if (showCarousel) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orangeAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Trending Fandoms',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 190,
              child: PageView.builder(
                controller: _carouselController,
                itemCount: trending.length,
                itemBuilder: (context, index) => _TrendingCard(
                  fandom: trending[index],
                  onTap: () => _openDetail(trending[index]),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'All Fandoms',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],

        // ---------- GRID ----------
        if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showSavedOnly ? Icons.bookmark_border : Icons.search_off,
                      size: 56,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _showSavedOnly
                          ? 'No saved fandoms yet'
                          : 'No fandoms found',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final fandom = filtered[index];
                  final isLiked = liked.contains(fandom.id);
                  final isSaved = saved.contains(fandom.id);

                  return _FandomCard(
                    fandom: fandom,
                    isLiked: isLiked,
                    isSaved: isSaved,
                    onTap: () => _openDetail(fandom),
                    onLike: () =>
                        _toggle(FandomService.likedField, fandom.id, isLiked),
                    onSave: () => _toggleBookmark(fandom, isSaved),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================
// TRENDING CARD (carousel item)
// ============================================================

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.fandom, required this.onTap});

  final FandomModel fandom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FandomImage(
                imageUrl: fandom.imageUrl,
                width: double.infinity,
                height: double.infinity,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fandom.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (fandom.tagline.isNotEmpty)
                      Text(
                        fandom.tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FANDOM CARD (grid item)
// ============================================================

class _FandomCard extends StatelessWidget {
  const _FandomCard({
    required this.fandom,
    required this.isLiked,
    required this.isSaved,
    required this.onTap,
    required this.onLike,
    required this.onSave,
  });

  final FandomModel fandom;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FandomImage(
                    imageUrl: fandom.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Column(
                      children: [
                        _RoundIconButton(
                          icon: isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.pinkAccent : Colors.white,
                          onTap: onLike,
                        ),
                        const SizedBox(height: 6),
                        _RoundIconButton(
                          icon:
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? Colors.amberAccent : Colors.white,
                          onTap: onSave,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fandom.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fandom.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fandom.tagline.isNotEmpty
                        ? fandom.tagline
                        : fandom.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

// ============================================================
// FANDOM DETAIL SCREEN
// Tabs: Overview (beginner hub) / Glossary / Deep Dive /
//       Resources (news, video, podcast) / Gallery
// ============================================================

class FandomDetailScreen extends StatefulWidget {
  const FandomDetailScreen({super.key, required this.fandom});

  final FandomModel fandom;

  @override
  State<FandomDetailScreen> createState() => _FandomDetailScreenState();
}

class _FandomDetailScreenState extends State<FandomDetailScreen> {
  final FandomService _service = FandomService();

  late final Stream<Set<String>> _likedStream =
      _service.watchUserIds(FandomService.likedField);
  late final Stream<Set<String>> _savedStream =
      _service.watchUserIds(FandomService.bookmarkedField);

  final BookmarkService _bookmarks = BookmarkService();

  Future<void> _toggleBookmark(bool currentlyOn) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _bookmarks.setBookmarked(
        BookmarkModel.fandom(widget.fandom),
        on: !currentlyOn,
      );
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              currentlyOn ? 'Bookmark removed' : 'Saved for offline reading',
            ),
          ),
        );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not update: $e')),
      );
    }
  }

  Future<void> _toggle(String field, bool currentlyOn, String message) async {
    try {
      await _service.setUserId(
        field: field,
        fandomId: widget.fandom.id,
        add: !currentlyOn,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fandom = widget.fandom;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(fandom.name, overflow: TextOverflow.ellipsis),
          actions: [
            StreamBuilder<Set<String>>(
              stream: _likedStream,
              initialData: const <String>{},
              builder: (context, snap) {
                final isLiked = (snap.data ?? {}).contains(fandom.id);
                return IconButton(
                  tooltip: isLiked ? 'Unlike' : 'Like',
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.pinkAccent : null,
                  ),
                  onPressed: () => _toggle(
                    FandomService.likedField,
                    isLiked,
                    isLiked ? 'Removed from liked' : 'Added to liked fandoms',
                  ),
                );
              },
            ),
            StreamBuilder<Set<String>>(
              stream: _savedStream,
              initialData: const <String>{},
              builder: (context, snap) {
                final isSaved = (snap.data ?? {}).contains(fandom.id);
                return IconButton(
                  tooltip: isSaved ? 'Remove bookmark' : 'Bookmark',
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? Colors.amberAccent : null,
                  ),
                  onPressed: () => _toggleBookmark(isSaved),
                );
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Glossary'),
              Tab(text: 'Deep Dive'),
              Tab(text: 'Resources'),
              Tab(text: 'Gallery'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(fandom: fandom),
            _GlossaryTab(terms: fandom.glossary),
            _DeepDiveTab(facts: fandom.deepDive),
            _ResourcesTab(
              resources: fandom.resources,
              fandomId: fandom.id,
              fandomName: fandom.name,
            ),
            _GalleryTab(fandom: fandom),
          ],
        ),
      ),
    );
  }
}

// ---------------- OVERVIEW ----------------

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.fandom});

  final FandomModel fandom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: FandomImage(
              imageUrl: fandom.imageUrl,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text(fandom.category)),
            if (fandom.isTrending)
              const Chip(
                avatar: Icon(Icons.local_fire_department,
                    size: 18, color: Colors.orangeAccent),
                label: Text('Trending'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          fandom.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (fandom.tagline.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            fandom.tagline,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          fandom.description,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        if (fandom.beginnerGuide.isNotEmpty) ...[
          const SizedBox(height: 20),
          Card(
            color: theme.colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school,
                          color: theme.colorScheme.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        'New here? Start here',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fandom.beginnerGuide,
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
    );
  }
}

// ---------------- GLOSSARY ----------------

class _GlossaryTab extends StatelessWidget {
  const _GlossaryTab({required this.terms});

  final List<GlossaryTerm> terms;

  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) {
      return const _EmptyTab(
        icon: Icons.menu_book,
        message: 'No glossary terms yet',
      );
    }

    final sorted = [...terms]
      ..sort((a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final item = sorted[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(
              item.term,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(item.meaning),
            ),
          ),
        );
      },
    );
  }
}

// ---------------- DEEP DIVE ----------------

class _DeepDiveTab extends StatelessWidget {
  const _DeepDiveTab({required this.facts});

  final List<String> facts;

  @override
  Widget build(BuildContext context) {
    if (facts.isEmpty) {
      return const _EmptyTab(
        icon: Icons.lightbulb_outline,
        message: 'No deep-dive content yet',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: facts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Hidden trivia and advanced lore for expert fans.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb, color: Colors.amberAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    facts[index - 1],
                    style: const TextStyle(height: 1.4),
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

// ---------------- RESOURCES ----------------

class _ResourcesTab extends StatefulWidget {
  const _ResourcesTab({
    required this.resources,
    required this.fandomId,
    required this.fandomName,
  });

  final List<FandomResource> resources;
  final String fandomId;
  final String fandomName;

  @override
  State<_ResourcesTab> createState() => _ResourcesTabState();
}

class _ResourcesTabState extends State<_ResourcesTab> {
  String _type = 'all';

  IconData _iconFor(String type) {
    switch (type) {
      case 'video':
        return Icons.play_circle_fill;
      case 'podcast':
        return Icons.podcasts;
      default:
        return Icons.article;
    }
  }

  Future<void> _open(FandomResource resource) async {
    final link = resource.url.trim();
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
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.resources.isEmpty) {
      return const _EmptyTab(
        icon: Icons.link_off,
        message: 'No resources yet',
      );
    }

    final visible = widget.resources
        .where((r) => _type == 'all' || r.type == _type)
        .toList();

    const types = {
      'all': 'All',
      'news': 'News',
      'video': 'Videos',
      'podcast': 'Podcasts',
    };

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final entry in types.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: _type == entry.key,
                    onSelected: (_) => setState(() => _type = entry.key),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? const _EmptyTab(
                  icon: Icons.link_off,
                  message: 'Nothing in this section',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final item = visible[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          _iconFor(item.type),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(item.title),
                        subtitle: Text(item.type.toUpperCase()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BookmarkButton(
                              bookmark: BookmarkModel.resource(
                                fandomId: widget.fandomId,
                                fandomName: widget.fandomName,
                                resourceType: item.type,
                                title: item.title,
                                url: item.url,
                              ),
                            ),
                            const Icon(Icons.open_in_new),
                          ],
                        ),
                        onTap: () => _open(item),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------- GALLERY ----------------

class _GalleryTab extends StatelessWidget {
  const _GalleryTab({required this.fandom});

  final FandomModel fandom;

  @override
  Widget build(BuildContext context) {
    final images = fandom.images.isNotEmpty
        ? fandom.images
        : (fandom.imageUrl.isNotEmpty ? [fandom.imageUrl] : <String>[]);

    if (images.isEmpty) {
      return const _EmptyTab(
        icon: Icons.photo_library_outlined,
        message: 'No images yet',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showFullImage(context, images[index]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                FandomImage(
                  imageUrl: images[index],
                  width: double.infinity,
                  height: double.infinity,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: BookmarkButton(
                    overlay: true,
                    bookmark: BookmarkModel.image(
                      fandomId: fandom.id,
                      fandomName: fandom.name,
                      imageUrl: images[index],
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

  void _showFullImage(BuildContext context, String image) {
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
                  imageUrl: image,
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
}

// ---------------- SHARED EMPTY STATE ----------------

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: Colors.white38),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}