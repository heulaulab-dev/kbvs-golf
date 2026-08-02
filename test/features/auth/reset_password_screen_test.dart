import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:golfie/features/auth/providers/auth_provider.dart';
import 'package:golfie/features/auth/screens/reset_password_screen.dart';

void main() {
  testWidgets('renders expired-link state when no token', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider.demo(),
          ),
        ],
        child: const MaterialApp(home: ResetPasswordScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.text('Go Back'), findsOneWidget);
  });
}