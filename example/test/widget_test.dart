import 'package:flutter_test/flutter_test.dart';

import 'package:visual_effects_kit_example/main.dart';

void main() {
  testWidgets('example app renders the control surface', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const VisualEffectsKitExampleApp());
    await tester.pump(const Duration(milliseconds: 16));

    expect(
      find.text('Procedural motion for modern Flutter surfaces.'),
      findsOneWidget,
    );
    expect(find.text('Controls'), findsOneWidget);
  });
}
