import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:golfie/features/auth/providers/auth_provider.dart';
import 'package:golfie/features/auth/screens/login_screen.dart';
import 'package:golfie/features/auth/screens/signup_screen.dart';
import 'package:golfie/features/auth/screens/forgot_password_screen.dart';
import 'package:golfie/features/onboarding/providers/onboarding_provider.dart';

class _FakeOnboardingProvider extends OnboardingProvider {
  @override
  bool get completed => true;
}

void main() {
  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider.demo(),
          ),
          ChangeNotifierProvider<OnboardingProvider>(
            create: (_) => _FakeOnboardingProvider(),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders heading and email field', (tester) async {
    await pumpLogin(tester);
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsWidgets); // label + field hint
  });

  testWidgets('shows sign up link and navigates to signup', (tester) async {
    await pumpLogin(tester);
    // Scroll down to bring the "Create one" link into view
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pump();
    // Tap the "Create one" GestureDetector
    await tester.tap(find.byType(GestureDetector).last);
    await tester.pumpAndSettle();
    expect(find.byType(SignupScreen), findsOneWidget);
  });

  testWidgets('shows forgot password link and navigates to forgot',
      (tester) async {
    await pumpLogin(tester);
    // Tap the "Forgot password?" TextButton (last TextButton)
    await tester.tap(find.byType(TextButton).last);
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  });

  testWidgets('toggles password visibility', (tester) async {
    await pumpLogin(tester);
    await tester.enterText(find.byType(TextField).at(1), 'hunter22');
    expect(
      tester.widget<EditableText>(find.byType(EditableText).last).obscureText,
      isTrue,
    );
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText).last).obscureText,
      isFalse,
    );
  });
}