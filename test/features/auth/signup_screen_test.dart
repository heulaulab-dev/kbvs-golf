import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:golfie/features/auth/providers/auth_provider.dart';
import 'package:golfie/features/auth/screens/signup_screen.dart';
import 'package:golfie/features/auth/screens/login_screen.dart';

void main() {
  Future<void> pumpSignup(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider.demo(),
          ),
        ],
        child: const MaterialApp(home: SignupScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders heading', (tester) async {
    await pumpSignup(tester);
    expect(find.text('Registration'), findsOneWidget);
  });

  testWidgets('shows sign in link and navigates to login', (tester) async {
    await pumpSignup(tester);
    // Scroll down to bring the "Sign in" link into view
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pump();
    await tester.tap(find.byType(GestureDetector).last);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('password fields toggle visibility', (tester) async {
    await pumpSignup(tester);
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(4)); // name + email + password + confirm
    await tester.enterText(fields.at(2), 'abc123'); // password field
    final visibilityIcons = find.byIcon(Icons.visibility_off);
    expect(visibilityIcons, findsNWidgets(2));
    await tester.tap(visibilityIcons.at(1));
    await tester.pump();
    expect(find.text('abc123'), findsOneWidget);
  });
}