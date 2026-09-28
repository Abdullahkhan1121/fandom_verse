import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/fandom/fandom_model.dart';
import '../../models/product_model.dart';
import '../../services/fandom/fandom_service.dart';
import '../../services/product_service.dart';
import '../theme/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/fandom_image.dart';
import '../../widgets/user_avatar.dart';
import '../cart/cart_and_checkout.dart';
import '../chatbot/chatbot_screen.dart';
import '../events/events_screen.dart';
import '../fandoms/discover_screen.dart';
import '../products/product_detail_screen.dart';
import '../products/products_screen.dart';
import '../profile/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? _user = FirebaseAuth.instance.currentUser;

  late final Stream<Map<String, dynamic>?> _profileStream = _user == null
      ? Stream.value(null)
      : FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .snapshots()
          .map((doc) => doc.data());

  late final Stream<List<FandomModel>> _fandomsStream =
      FandomService().getActiveFandoms().map((list) {
    final sorted = [...list]..sort(
        (a, b) => (b.isTrending ? 1 : 0).compareTo(a.isTrending ? 1 : 0),
      );
    return sorted.take(8).toList();
  });

  // Filtering/sorting happens in Dart so no Firestore index is needed
  // (same approach as EventsScreen).
  late final Stream<List<EventModel>> _eventsStream = FirebaseFirestore.instance
      .collection('events')
      .where('isPublished', isEqualTo: true)
      .snapshots()
      .map((snap) {
    final upcoming = snap.docs
        .map(EventModel.fromFirestore)
        .where((e) => e.isUpcoming)
        .toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    return upcoming.take(3).toList();
  });

  late final Stream<List<ProductModel>> _productsStream =
      ProductService().streamProducts().map(
            (list) => list.where((p) => p.isAvailable).take(8).toList(),
          );

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  void _go(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _profileStream,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final name = (data?['name'] as String?) ??
            _user?.displayName ??
            'Fandom Fan';
        final photoUrl = (data?['photoUrl'] as String?) ?? _user?.photoURL;
        final firstName = name.trim().isEmpty ? 'Fan' : name.trim().split(' ').first;

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: const AppDrawer(),
          appBar: AppBar(
            title: const Text('Fandom Verse'),
            actions: [
              IconButton(
                tooltip: 'Cart',
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => _go(const CartScreen()),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14, left: 4),
                child: GestureDetector(
                  onTap: () => _go(const ProfileScreen()),
                  child: UserAvatar(
                    name: name,
                    photoUrl: photoUrl,
                    radius: 16,
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              _Hero(
                greeting: _greeting(),
                firstName: firstName,
                onExplore: () => _go(const DiscoverScreen()),
              ),
              const SizedBox(height: 22),
              _QuickActions(
                onDiscover: () => _go(const DiscoverScreen()),
                onEvents: () => _go(const EventsScreen()),
                onStore: () => _go(const ProductsScreen()),
                onAi: () => _go(const ChatbotScreen()),
              ),
              const SizedBox(height: 28),
              _SectionHeader(
                title: 'Trending Fandoms',
                onSeeAll: () => _go(const DiscoverScreen()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 196,
                child: StreamBuilder<List<FandomModel>>(
                  stream: _fandomsStream,
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return const _EmptyHint('Could not load fandoms.');
                    }
                    if (!snap.hasData) return const _Loading();
                    final fandoms = snap.data!;
                    if (fandoms.isEmpty) {
                      return const _EmptyHint('No fandoms yet. Check back soon.');
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: fandoms.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, i) => _FandomTile(
                        fandom: fandoms[i],
                        onTap: () =>
                            _go(FandomDetailScreen(fandom: fandoms[i])),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              _SectionHeader(
                title: 'Upcoming Events',
                onSeeAll: () => _go(const EventsScreen()),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<EventModel>>(
                stream: _eventsStream,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return const _EmptyHint('Could not load events.');
                  }
                  if (!snap.hasData) {
                    return const SizedBox(height: 120, child: _Loading());
                  }
                  final events = snap.data!;
                  if (events.isEmpty) {
                    return const _EmptyHint('No upcoming events right now.');
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        for (final e in events)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _EventTile(
                              event: e,
                              onTap: () => _go(EventDetailScreen(event: e)),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _SectionHeader(
                title: 'From the Store',
                onSeeAll: () => _go(const ProductsScreen()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 232,
                child: StreamBuilder<List<ProductModel>>(
                  stream: _productsStream,
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return const _EmptyHint('Could not load products.');
                    }
                    if (!snap.hasData) return const _Loading();
                    final products = snap.data!;
                    if (products.isEmpty) {
                      return const _EmptyHint('The store is empty for now.');
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, i) => _ProductTile(
                        product: products[i],
                        onTap: () =>
                            _go(ProductDetailScreen(product: products[i])),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// HERO
// ============================================================

class _Hero extends StatelessWidget {
  const _Hero({
    required this.greeting,
    required this.firstName,
    required this.onExplore,
  });

  final String greeting;
  final String firstName;
  final VoidCallback onExplore;

  Widget _circle(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(top: -50, right: -30, child: _circle(170, 0.10)),
            Positioned(bottom: -60, right: 70, child: _circle(130, 0.07)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    firstName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Dive into your favorite worlds, find events near you\nand grab the merch you love.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onExplore,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDeep,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.explore_rounded, size: 20),
                    label: const Text('Explore fandoms'),
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

// ============================================================
// QUICK ACTIONS
// ============================================================

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onDiscover,
    required this.onEvents,
    required this.onStore,
    required this.onAi,
  });

  final VoidCallback onDiscover;
  final VoidCallback onEvents;
  final VoidCallback onStore;
  final VoidCallback onAi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _QuickAction(
            icon: Icons.explore_rounded,
            label: 'Discover',
            color: AppColors.primaryLight,
            onTap: onDiscover,
          ),
          const SizedBox(width: 12),
          _QuickAction(
            icon: Icons.event_rounded,
            label: 'Events',
            color: AppColors.gold,
            onTap: onEvents,
          ),
          const SizedBox(width: 12),
          _QuickAction(
            icon: Icons.shopping_bag_rounded,
            label: 'Store',
            color: AppColors.success,
            onTap: onStore,
          ),
          const SizedBox(width: 12),
          _QuickAction(
            icon: Icons.auto_awesome_rounded,
            label: 'AI Helper',
            color: AppColors.accent,
            onTap: onAi,
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 23),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

// ============================================================
// SECTION HEADER / STATES
// ============================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.card(),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
        ),
      ),
    );
  }
}

// ============================================================
// FANDOM TILE
// ============================================================

class _FandomTile extends StatelessWidget {
  const _FandomTile({required this.fandom, required this.onTap});

  final FandomModel fandom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(child: FandomImage(imageUrl: fandom.imageUrl)),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.35, 0.65, 1],
                    ),
                  ),
                ),
              ),
              if (fandom.isTrending)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 13,
                          color: AppColors.gold,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Trending',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (fandom.category.isNotEmpty)
                      Text(
                        fandom.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    const SizedBox(height: 3),
                    Text(
                      fandom.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
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
// EVENT TILE
// ============================================================

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.onTap});

  final EventModel event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMM').format(event.startAt).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      DateFormat('d').format(event.startAt),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (event.location.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('EEE, h:mm a').format(event.startAt),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCT TILE
// ============================================================

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: AppTheme.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: FandomImage(imageUrl: product.imageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                '${product.currency} ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}