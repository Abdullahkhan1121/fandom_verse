import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/about/about_screen.dart';
import '../screens/bookmarks/bookmarks_screen.dart';
import '../screens/chatbot/chatbot_screen.dart';
import '../screens/contact/contact_screen.dart';
import '../screens/events/events_screen.dart';
import '../screens/fandoms/discover_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/products/wishlist_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/theme/app_theme.dart';
import 'user_avatar.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _logout(BuildContext context) async {
    // Grab these before signing out: AuthGate rebuilds right after and
    // this drawer's context is gone by then.
    final navigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await FirebaseAuth.instance.signOut();

      // Close the drawer AND every screen pushed on top of AuthGate,
      // leaving only the login screen.
      navigator.popUntil((route) => route.isFirst);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _open(BuildContext context, Widget page) {
    final navigator = Navigator.of(context);
    navigator.pop(); // close drawer
    navigator.push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            const _DrawerHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  const _SectionLabel('EXPLORE'),
                  _DrawerItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    selected: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.explore_rounded,
                    label: 'Discover',
                    onTap: () => _open(context, const DiscoverScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.event_rounded,
                    label: 'Events',
                    onTap: () => _open(context, const EventsScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.shopping_bag_rounded,
                    label: 'Store',
                    onTap: () => _open(context, const ProductsScreen()),
                  ),
                  const _SectionLabel('MY SPACE'),
                  _DrawerItem(
                    icon: Icons.person_rounded,
                    label: 'My Profile',
                    onTap: () => _open(context, const ProfileScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.favorite_rounded,
                    label: 'Wishlist',
                    onTap: () => _open(context, const WishlistScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.bookmark_rounded,
                    label: 'Bookmarks',
                    onTap: () => _open(context, const BookmarksScreen()),
                  ),
                  const _SectionLabel('ASSISTANT'),
                  _DrawerItem(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI Fan Helper',
                    onTap: () => _open(context, const ChatbotScreen()),
                  ),
                  const _SectionLabel('HELP'),
                  _DrawerItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About Us',
                    onTap: () => _open(context, const AboutScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.mail_outline_rounded,
                    label: 'Contact Us',
                    onTap: () => _open(context, const ContactScreen()),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text('Logout'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final Stream<Map<String, dynamic>?> stream = user == null
        ? Stream.value(null)
        : FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .map((doc) => doc.data());

    return StreamBuilder<Map<String, dynamic>?>(
      stream: stream,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final name =
            (data?['name'] as String?) ?? user?.displayName ?? 'Fandom User';
        final email = (data?['email'] as String?) ?? user?.email ?? '';
        final photoUrl = (data?['photoUrl'] as String?) ?? user?.photoURL;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.30),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'FANDOM VERSE',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  UserAvatar(name: name, photoUrl: photoUrl, radius: 26),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 18, 10, 6),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? AppColors.primaryLight : AppColors.textMuted,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textPrimary.withValues(alpha: 0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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