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
    expect(find.text('Create your Golfie account'), findsOneWidget);
  });

  testWidgets('shows sign in link and navigates to login', (tester) async {
    await pumpSignup(tester);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('password fields toggle visibility', (tester) async {
    await pumpSignup(tester);
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(3)); // email + password + confirm
    await tester.enterText(fields.at(1), 'abc123');
    await tester.tap(find.byIcon(Icons.visibility_off).first);
    await tester.pump();
    expect(find.text('abc123'), findsOneWidget);
  });
}