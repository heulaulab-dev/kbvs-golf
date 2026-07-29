import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/widgets/golfie/golfie_torn_paper_section.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders eyebrow and title', (tester) async {
    await tester.pumpWidget(wrap(const GolfieTornPaperSection(
      eyebrow: 'Tips',
      title: 'Caddy Wisdom',
      child: Text('body'),
    )));
    expect(find.text('Tips'), findsOneWidget);
    expect(find.text('Caddy Wisdom'), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
  });
}