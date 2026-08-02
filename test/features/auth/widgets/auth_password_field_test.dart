import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/features/auth/widgets/auth_password_field.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('hides text by default', (tester) async {
    final controller = TextEditingController(text: 'secret123');
    addTearDown(controller.dispose);
    await tester.pumpWidget(wrap(AuthPasswordField(controller: controller)));
    // find.text matches EditableText's stored value even when obscured —
    // assert the obscureText flag instead.
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.obscureText, isTrue);
  });

  testWidgets('toggle reveals then hides text', (tester) async {
    final controller = TextEditingController(text: 'secret123');
    addTearDown(controller.dispose);
    await tester.pumpWidget(wrap(AuthPasswordField(controller: controller)));
    // Reveal
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isFalse,
    );
    // Hide again
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isTrue,
    );
  });

  testWidgets('shows hint text', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(wrap(AuthPasswordField(
      controller: controller,
      hintText: 'Password',
    )));
    expect(find.text('Password'), findsOneWidget);
  });
}