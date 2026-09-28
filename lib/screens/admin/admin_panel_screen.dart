// import 'package:flutter/material.dart';

// import '../../services/auth_service.dart';

// class AdminPanelScreen extends StatelessWidget {
//   const AdminPanelScreen({super.key});

//   Future<void> _logout(BuildContext context) async {
//     await AuthService().logout();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin Panel'),
//         automaticallyImplyLeading: false,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 12),
//               Icon(
//                 Icons.admin_panel_settings,
//                 size: 72,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Welcome, Admin',
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Manage Fandom Verse content from here.',
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context).textTheme.bodyLarge,
//               ),
//               const SizedBox(height: 32),
//               _AdminCard(
//                 icon: Icons.auto_awesome,
//                 title: 'Manage Fandoms',
//                 description: 'Create, edit, and delete fandoms.',
//                 onTap: () {},
//               ),
//               const SizedBox(height: 16),
//               _AdminCard(
//                 icon: Icons.event,
//                 title: 'Manage Events',
//                 description: 'Create, edit, and delete events.',
//                 onTap: () {},
//               ),
//               const SizedBox(height: 16),
//               _AdminCard(
//                 icon: Icons.shopping_bag,
//                 title: 'Manage Products',
//                 description: 'Create, edit, and delete products.',
//                 onTap: () {},
//               ),
//               const SizedBox(height: 16),
//               _AdminCard(
//                 icon: Icons.people_outline,
//                 title: 'Manage Users',
//                 description: 'View registered users.',
//                 onTap: () {},
//               ),
//               const SizedBox(height: 32),
//               OutlinedButton.icon(
//                 onPressed: () => _logout(context),
//                 icon: const Icon(Icons.logout),
//                 label: const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   child: Text('Logout'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _AdminCard extends StatelessWidget {
//   const _AdminCard({
//     required this.icon,
//     required this.title,
//     required this.description,
//     required this.onTap,
//   });

//   final IconData icon;
//   final String title;
//   final String description;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Row(
//             children: [
//               Icon(
//                 icon,
//                 size: 40,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(description),
//                   ],
//                 ),
//               ),
//               const Icon(Icons.arrow_forward_ios, size: 18),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fandom_verse/screens/admin/admin_drawer.dart';
import 'package:flutter/material.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  static const Color _backgroundColor = Color(0xFF080A12);
  static const Color _panelColor = Color(0xFF111522);
  static const Color _panelColorLight = Color(0xFF171B2B);
  static const Color _primaryColor = Color(0xFF7C5CFC);
  static const Color _primaryLightColor = Color(0xFF9D87FF);
  static const Color _goldColor = Color(0xFFE0B45A);
  static const Color _whiteColor = Color(0xFFF5F5F7);
  static const Color _mutedColor = Color(0xFF9CA3B5);

  Stream<int> _collectionCount(String collection) {
    return FirebaseFirestore.instance
        .collection(collection)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> _userCount() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      drawer: AdminDrawer(),
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            const _BackgroundGlow(top: -100, right: -80, size: 260),
            const _BackgroundGlow(bottom: -120, left: -100, size: 280),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _buildHeader(),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
                  sliver: SliverToBoxAdapter(
                    child: _buildDashboardContent(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primaryColor, _primaryLightColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withValues(alpha: 0.28),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.dashboard_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: _whiteColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage your Fandom Verse platform',
                style: TextStyle(
                  color: _mutedColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeCard(),
        const SizedBox(height: 28),
        const Text(
          'Overview',
          style: TextStyle(
            color: _whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final bool isSmallScreen = width < 600;
            final int crossAxisCount = isSmallScreen ? 1 : 2;

            return GridView.builder(
              itemCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isSmallScreen ? 1.65 : 1.35,
              ),
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return _buildManagementCard(
                      context: context,
                      title: 'Users',
                      description: 'Registered users',
                      icon: Icons.people_alt_rounded,
                      iconColor: const Color(0xFF62A8FF),
                      stream: _userCount(),
                    );

                  case 1:
                    return _buildManagementCard(
                      context: context,
                      title: 'Fandoms',
                      description: 'Available fandoms',
                      icon: Icons.auto_awesome_rounded,
                      iconColor: _primaryLightColor,
                      stream: _collectionCount('fandoms'),
                    );

                  case 2:
                    return _buildManagementCard(
                      context: context,
                      title: 'Events',
                      description: 'Platform events',
                      icon: Icons.event_rounded,
                      iconColor: _goldColor,
                      stream: _collectionCount('events'),
                    );

                  case 3:
                    return _buildManagementCard(
                      context: context,
                      title: 'Products',
                      description: 'Store products',
                      icon: Icons.shopping_bag_rounded,
                      iconColor: const Color(0xFF63D5A5),
                      stream: _collectionCount('products'),
                    );

                  default:
                    return const SizedBox.shrink();
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_panelColorLight, _panelColor.withValues(alpha: 0.92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _primaryColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _goldColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: _goldColor,
              size: 27,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Admin',
                  style: TextStyle(
                    color: _whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Everything you need to manage Fandom Verse is here.',
                  style: TextStyle(
                    color: _mutedColor,
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

  Widget _buildManagementCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Stream<int> stream,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: iconColor, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _whiteColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: const TextStyle(
              color: _mutedColor,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<int>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  '--',
                  style: TextStyle(
                    color: _whiteColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _primaryLightColor,
                  ),
                );
              }

              return Text(
                '${snapshot.data}',
                style: const TextStyle(
                  color: _whiteColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              );
            },
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: _buildManageButton(context, title),
          ),
        ],
      ),
    );
  }

  Widget _buildManageButton(BuildContext context, String title) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title management will be available soon.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _panelColorLight,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: const Text(
        'Manage',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double size;

  const _BackgroundGlow({
    this.top,
    this.right,
    this.bottom,
    this.left,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF7C5CFC).withValues(alpha: 0.055),
          ),
        ),
      ),
    );
  }
}
