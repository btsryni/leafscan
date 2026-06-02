import 'package:flutter_test/flutter_test.dart';
import 'package:beta_project/main.dart';

void main() {
  testWidgets('App bootstrap smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame with onboarding active.
    await tester.pumpWidget(const MyApp(showOnboarding: true));

    // Verify that the brand name "LeafScan" is visible on the welcome splash page.
    expect(find.text('LeafScan'), findsOneWidget);
  });
}
