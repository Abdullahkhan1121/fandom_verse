import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../../widgets/user_avatar.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../products/wishlist_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    // This screen is pushed on top of AuthGate, so after signing out we
    // also pop back to the root route, which now shows the login screen.
    final navigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseAuth.instance.signOut();
      navigator.popUntil((route) => route.isFirst);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  String _formatJoinedDate(Timestamp? timestamp) {
    if (timestamp == null) return '—';
    return DateFormat('MMM yyyy').format(timestamp.toDate());
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user is currently signed in.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _push(context, const EditProfileScreen()),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading profile: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            );
          }

          final data = snapshot.data?.data();

          final name =
              data?['name'] as String? ?? user.displayName ?? 'Fandom User';
          final email = data?['email'] as String? ?? user.email ?? '';
          final role = data?['role'] as String? ?? 'user';
          final photoUrl = (data?['photoUrl'] as String?) ?? user.photoURL;
          final bio = data?['bio'] as String? ?? '';
          final favoriteCount =
              ((data?['favoriteFandomIds'] as List?) ?? const []).length;
          final wishlistCount =
              ((data?['wishlistProductIds'] as List?) ?? const []).length;
          final joined = _formatJoinedDate(data?['createdAt'] as Timestamp?);
          final isAdmin = role == 'admin';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              // ---------------- HEADER ----------------
              Container(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.32),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                      child: UserAvatar(
                        name: name,
                        photoUrl: photoUrl,
                        radius: 44,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAdmin
                                ? Icons.admin_panel_settings_rounded
                                : Icons.verified_user_rounded,
                            size: 15,
                            color: isAdmin ? AppColors.gold : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            role.toUpperCase(),
                            style: TextStyle(
                              color: isAdmin ? AppColors.gold : Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        bio,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---------------- STATS ----------------
              Row(
                children: [
                  _StatTile(
                    icon: Icons.favorite_rounded,
                    color: AppColors.danger,
                    value: '$favoriteCount',
                    label: 'Fandoms',
                  ),
                  const SizedBox(width: 12),
                  _StatTile(
                    icon: Icons.shopping_bag_rounded,
                    color: AppColors.success,
                    value: '$wishlistCount',
                    label: 'Wishlist',
                  ),
                  const SizedBox(width: 12),
                  _StatTile(
                    icon: Icons.calendar_month_rounded,
                    color: AppColors.gold,
                    value: joined,
                    label: 'Joined',
                    smallValue: true,
                  ),
                ],
              ),

              const SizedBox(height: 26),
              const _GroupTitle('My Space'),
              Container(
                decoration: AppTheme.card(),
                child: Column(
                  children: [
                    _MenuTile(
                      icon: Icons.bookmark_rounded,
                      title: 'My Bookmarks',
                      subtitle: 'Fandoms, events, resources, images',
                      onTap: () => _push(context, const BookmarksScreen()),
                    ),
                    Divider(color: AppColors.border),
                    _MenuTile(
                      icon: Icons.favorite_rounded,
                      title: 'My Wishlist',
                      subtitle: 'Products you saved for later',
                      onTap: () => _push(context, const WishlistScreen()),
                    ),
                    Divider(color: AppColors.border),
                    _MenuTile(
                      icon: Icons.edit_rounded,
                      title: 'Edit Profile',
                      subtitle: 'Change your name and bio',
                      onTap: () => _push(context, const EditProfileScreen()),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),
              const _GroupTitle('Account'),
              Container(
                decoration: AppTheme.card(),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: email,
                    ),
                    Divider(color: AppColors.border),
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Role',
                      value: role,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(
                      color: AppColors.danger.withValues(alpha: 0.5),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.smallValue = false,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final bool smallValue;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: AppTheme.card(),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: smallValue ? 15 : 21,
                fontWeight: FontWeight.w800,
                height: smallValue ? 1.6 : 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: AppColors.primaryLight, size: 21),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 21),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}