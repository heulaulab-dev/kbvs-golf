import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/widgets/golfie/golfie_ghost_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders label', (tester) async {
    await tester.pumpWidget(wrap(GolfieGhostButton(
      label: 'Cancel',
      onPressed: () {},
    )));
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('invokes onPressed when tapped', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(wrap(GolfieGhostButton(
      label: 'Cancel',
      onPressed: () => tapped++,
    )));
    await tester.tap(find.byType(GolfieGhostButton));
    expect(tapped, 1);
  });

  testWidgets('disabled button does not invoke onPressed', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(wrap(const GolfieGhostButton(
      label: 'Cancel',
      onPressed: null,
    )));
    await tester.tap(find.byType(GolfieGhostButton));
    expect(tapped, 0);
  });
}