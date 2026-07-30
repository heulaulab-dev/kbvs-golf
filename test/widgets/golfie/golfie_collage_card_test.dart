import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/core/theme/golfie_colors.dart';
import 'package:golfie/widgets/golfie/golfie_collage_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders child', (tester) async {
    await tester.pumpWidget(wrap(const GolfieCollageCard(child: Text('hello'))));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('renders Periwinkle accent when accentCorner=topRight', (tester) async {
    await tester.pumpWidget(wrap(const GolfieCollageCard(
      child: Text('hello'),
      accentCorner: GolfieAccentCorner.topRight,
    )));
    final containers = tester.widgetList<Container>(find.byType(Container));
    final hasPeriwinkle = containers.any((c) {
      final decoration = c.decoration;
      if (decoration is BoxDecoration && decoration.color == GolfieColors.periwinkle) {
        return true;
      }
      return false;
    });
    expect(hasPeriwinkle, isTrue);
  });

  testWidgets('no accent when accentCorner=none (default)', (tester) async {
    await tester.pumpWidget(wrap(const GolfieCollageCard(child: Text('hello'))));
    final containers = tester.widgetList<Container>(find.byType(Container));
    final hasPeriwinkle = containers.any((c) {
      final decoration = c.decoration;
      if (decoration is BoxDecoration && decoration.color == GolfieColors.periwinkle) {
        return true;
      }
      return false;
    });
    expect(hasPeriwinkle, isFalse);
  });
}
