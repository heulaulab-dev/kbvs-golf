import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:golfie/features/auth/providers/auth_provider.dart';
import 'package:golfie/features/auth/screens/splash_screen.dart';
import 'package:golfie/features/onboarding/providers/onboarding_provider.dart';
import 'package:golfie/widgets/golfie/golfie_hero.dart';

void main() {
  testWidgets('shows brand hero and loading indicator', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider.demo(),
          ),
          ChangeNotifierProvider<OnboardingProvider>(
            create: (_) => OnboardingProvider(),
          ),
        ],
        child: const MaterialApp(home: SplashScreen()),
      ),
    );
    await tester.pump();
    expect(find.byType(GolfieHero), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Let the 1s splash timer fire so no timers are pending at teardown.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
