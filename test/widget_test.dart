import 'package:flutter_test/flutter_test.dart';
import 'package:fandom_verse/main.dart';

void main() {
  testWidgets('Fandom Verse app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const FandomVerseApp());
    expect(find.text('Welcome to Fandom Verse'), findsOneWidget);
    expect(find.text('Discover Fandoms'), findsOneWidget);
  });
}
