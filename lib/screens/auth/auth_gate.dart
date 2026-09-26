import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fandom_verse/screens/home/home_screen.dart';
// import 'package:fandom_verse/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../services/auth_service.dart';
import '../admin/admin_panel_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userData = userSnapshot.data!.data();

            if (userData == null) {
              return const Scaffold(
                body: Center(child: Text('User profile could not be loaded.')),
              );
            }

            final role = userData['role'] as String?;

            if (role == 'admin') {
              return const AdminPanelScreen();
            }

            return const HomePage();
          },
        );
      },
    );
  }
}
