import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/widgets/golfie/golfie_pill_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders label', (tester) async {
    await tester.pumpWidget(wrap(GolfiePillButton(
      label: 'Submit',
      onPressed: () {},
    )));
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('invokes onPressed when tapped', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(wrap(GolfiePillButton(
      label: 'Submit',
      onPressed: () => tapped++,
    )));
    await tester.tap(find.byType(GolfiePillButton));
    expect(tapped, 1);
  });

  testWidgets('renders with icon', (tester) async {
    await tester.pumpWidget(wrap(GolfiePillButton(
      label: 'Tip',
      icon: Icons.local_florist,
      onPressed: () {},
    )));
    expect(find.byIcon(Icons.local_florist), findsOneWidget);
  });

  testWidgets('disabled button does not invoke onPressed', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(wrap(const GolfiePillButton(
      label: 'Disabled',
      onPressed: null,
    )));
    await tester.tap(find.byType(GolfiePillButton));
    expect(tapped, 0);
  });
}