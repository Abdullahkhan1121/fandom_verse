// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import '../../services/auth_service.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   Future<void> _logout(BuildContext context) async {
//     await AuthService().logout();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       return const Center(child: Text('No user is currently signed in.'));
//     }

//     return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//       stream: FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .snapshots(),
//       builder: (context, snapshot) {
//         final data = snapshot.data?.data();

//         final name =
//             data?['name'] as String? ?? user.displayName ?? 'Fandom User';

//         final email = data?['email'] as String? ?? user.email ?? '';

//         final role = data?['role'] as String? ?? 'user';

//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               CircleAvatar(
//                 radius: 48,
//                 child: Text(
//                   name.isNotEmpty ? name[0].toUpperCase() : 'F',
//                   style: const TextStyle(
//                     fontSize: 36,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 name,
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(email, style: Theme.of(context).textTheme.bodyLarge),
//               const SizedBox(height: 8),
//               Chip(
//                 label: Text(role.toUpperCase()),
//                 avatar: const Icon(Icons.verified_user_outlined),
//               ),
//               const SizedBox(height: 40),
//               Card(
//                 child: ListTile(
//                   leading: const Icon(Icons.person_outline),
//                   title: const Text('Account'),
//                   subtitle: Text('Role: $role'),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: () => _logout(context),
//                   icon: const Icon(Icons.logout),
//                   label: const Padding(
//                     padding: EdgeInsets.symmetric(vertical: 12),
//                     child: Text('Logout'),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/auth_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
  }

  String _formatJoinedDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat('MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('No user is currently signed in.'));
    }

    return Scaffold(
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
              child: Text('Error loading profile: ${snapshot.error}'),
            );
          }

          final data = snapshot.data?.data();

          final name =
              data?['name'] as String? ?? user.displayName ?? 'Fandom User';
          final email = data?['email'] as String? ?? user.email ?? '';
          final role = data?['role'] as String? ?? 'user';
          final photoUrl = data?['photoUrl'] as String?;
          final bio = data?['bio'] as String? ?? '';
          final favoriteFandomIds =
              (data?['favoriteFandomIds'] as List?) ?? const [];
          final joinedDate = _formatJoinedDate(
            data?['createdAt'] as Timestamp?,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  backgroundImage:
                      (photoUrl != null && photoUrl.isNotEmpty)
                          ? NetworkImage(photoUrl)
                          : null,
                  child:
                      (photoUrl == null || photoUrl.isEmpty)
                          ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'F',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                            ),
                          )
                          : null,
                ),
                const SizedBox(height: 16),

                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Chip(
                  label: Text(role.toUpperCase()),
                  avatar: const Icon(Icons.verified_user_outlined, size: 18),
                  visualDensity: VisualDensity.compact,
                ),

                // Bio (only shown if not empty)
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],

                const SizedBox(height: 20),

                // Stats row: Favorite Fandoms + Joined date
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatChip(
                      icon: Icons.favorite_outline,
                      label: '${favoriteFandomIds.length} Fandoms',
                    ),
                    if (joinedDate.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      _StatChip(
                        icon: Icons.calendar_today_outlined,
                        label: 'Joined $joinedDate',
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 32),

                // Account info card
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text('Role'),
                        subtitle: Text(role),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Email'),
                        subtitle: Text(email),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Edit Profile button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Edit Profile'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Logout'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}