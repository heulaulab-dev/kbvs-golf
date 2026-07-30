import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/widgets/golfie/golfie_hero.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders title and subtitle', (tester) async {
    await tester.pumpWidget(wrap(const GolfieHero(
      title: 'Welcome',
      subtitle: 'Golf tournament discovery',
    )));
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Golf tournament discovery'), findsOneWidget);
  });

  testWidgets('renders action when provided', (tester) async {
    await tester.pumpWidget(wrap(GolfieHero(
      title: 'Welcome',
      subtitle: 'Golf tournament discovery',
      action: ElevatedButton(
        onPressed: () {},
        child: const Text('Browse'),
      ),
    )));
    expect(find.text('Browse'), findsOneWidget);
  });
}