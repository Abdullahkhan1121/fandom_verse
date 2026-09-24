import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fandom_verse/screens/auth/login_screen.dart';
import 'package:fandom_verse/services/auth_service.dart';

class FakeAuthService implements AuthServiceBase {
  @override
  Future<void> logout() async {}

  @override
  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  User? get currentUser => null;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();
}

void main() {
  testWidgets('Login screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(authService: FakeAuthService())),
    );

    expect(find.text('Welcome to Fandom Verse'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create an Account'), findsOneWidget);
  });
}
