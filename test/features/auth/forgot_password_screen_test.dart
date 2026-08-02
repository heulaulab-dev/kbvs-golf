import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:golfie/features/auth/providers/auth_provider.dart';
import 'package:golfie/features/auth/screens/forgot_password_screen.dart';

void main() {
  testWidgets('renders email field and send button', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider.demo(),
          ),
        ],
        child: const MaterialApp(home: ForgotPasswordScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('Forgot your password?'), findsOneWidget);
    expect(find.text('Enter email to receive reset link'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Send Link'), findsOneWidget);
  });
}