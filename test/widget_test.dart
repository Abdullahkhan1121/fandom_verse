// Smoke tests for Fandom Verse.
//
// The original Flutter counter test broke because the app now starts with
// Firebase + AuthGate (login / email verification / admin routing). Pumping
// the real FandomVerseApp in a unit test would throw "No Firebase App has
// been created", so these tests cover the parts that do NOT need Firebase:
// the dark theme system and the ProductModel purchase rules.
//
// Run with:  flutter test

import 'package:fandom_verse/models/product_model.dart';
import 'package:fandom_verse/screens/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ProductModel _product({required bool isAvailable, required int stock}) {
  return ProductModel(
    id: 'p1',
    name: 'Test Hoodie',
    description: 'A test product',
    price: 49.99,
    currency: 'USD',
    imageUrl: '',
    fandomId: 'f1',
    category: 'Apparel',
    stock: stock,
    isAvailable: isAvailable,
    createdBy: 'admin',
  );
}

void main() {
  group('AppTheme', () {
    test('dark theme uses the app colors', () {
      final theme = AppTheme.dark;

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.error, AppColors.danger);
    });

    testWidgets('renders a screen with the dark theme applied',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            appBar: AppBar(title: const Text('Fandom Verse')),
            body: const Center(child: Text('Welcome')),
          ),
        ),
      );

      expect(find.text('Fandom Verse'), findsOneWidget);
      expect(find.text('Welcome'), findsOneWidget);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final context = tester.element(find.byType(Scaffold));
      expect(Theme.of(context).scaffoldBackgroundColor, AppColors.background);
      expect(scaffold.appBar, isNotNull);
    });
  });

  group('ProductModel.canPurchase', () {
    test('true when available and in stock', () {
      expect(_product(isAvailable: true, stock: 5).canPurchase, isTrue);
    });

    test('false when out of stock', () {
      expect(_product(isAvailable: true, stock: 0).canPurchase, isFalse);
    });

    test('false when marked unavailable', () {
      expect(_product(isAvailable: false, stock: 5).canPurchase, isFalse);
    });
  });
}