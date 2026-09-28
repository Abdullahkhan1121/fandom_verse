import 'package:flutter/material.dart';

import '../../config/app_info.dart';
import '../contact/contact_screen.dart';
import '../theme/app_theme.dart';

/// About Us: what the app is, what it offers and who built it.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<_Feature> _features = [
    _Feature(Icons.explore_rounded, 'Discover',
        'Fandom guides, glossaries, deep dives and trending fandoms.'),
    _Feature(Icons.event_rounded, 'Events',
        'Conventions, meetups and screenings, filtered by city.'),
    _Feature(Icons.shopping_bag_rounded, 'Store',
        'Official merchandise with a wishlist and simulated checkout.'),
    _Feature(Icons.bookmark_rounded, 'Offline Bookmarks',
        'Save fandoms and read them without internet.'),
    _Feature(Icons.auto_awesome_rounded, 'AI Fan Helper',
        'Quick answers to common fandom and app questions.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const _Hero(),
          const SizedBox(height: 24),
          const _SectionTitle('Our Mission'),
          Text(
            AppInfo.mission,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14.5,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),
          const _SectionTitle('What You Can Do'),
          for (final f in _features) _FeatureTile(feature: f),
          const SizedBox(height: 28),
          const _SectionTitle('Meet the Team'),
          for (final m in AppInfo.team) _TeamCard(member: m),
          const SizedBox(height: 28),
          const _SectionTitle('Built With'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in AppInfo.techStack) Chip(label: Text(t)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ContactScreen()),
              ),
              icon: const Icon(Icons.mail_outline_rounded),
              label: const Text('Get in touch'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${AppInfo.fullName}  ·  v${AppInfo.version}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/fandom-logo.png',
              fit: BoxFit.contain,
              // Falls back to an icon if the asset is missing or renamed.
              errorBuilder: (_, __, ___) => const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            AppInfo.fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppInfo.tagline,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Feature {
  const _Feature(this.icon, this.title, this.description);
  final IconData icon;
  final String title;
  final String description;
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature});
  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.card(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: AppColors.primaryLight, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.member});
  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Icon(member.icon, color: AppColors.primaryLight),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.role,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  member.bio,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
