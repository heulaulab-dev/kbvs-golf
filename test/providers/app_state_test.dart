import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/providers/app_state.dart';

void main() {
  group('AppState caddy tips integration', () {
    test('initial yardage is null', () {
      final app = AppState();
      expect(app.currentYardage, isNull);
    });

    test('setYardage updates current yardage and notifies listeners', () {
      final app = AppState();
      var notifyCount = 0;
      app.addListener(() => notifyCount++);

      app.setYardage(150);

      expect(app.currentYardage, equals(150));
      expect(notifyCount, equals(1));
    });

    test('setYardage ignores duplicate values (no spurious notify)', () {
      final app = AppState();
      app.setYardage(150);
      var notifyCount = 0;
      app.addListener(() => notifyCount++);

      app.setYardage(150);

      expect(notifyCount, equals(0));
    });

    test('caddy tips disabled suppresses fee calculation', () {
      final app = AppState();
      app.toggleCaddyTips(); // disable
      expect(app.caddyTipsEnabled, isFalse);

      app.setYardage(200);

      // When tips disabled, fee is null — UI shows empty state
      expect(app.currentFee, isNull);
    });

    test('caddy tips enabled computes fee from yardage', () {
      final app = AppState();
      // caddyTipsEnabled is true by default
      expect(app.caddyTipsEnabled, isTrue);

      app.setYardage(100);
      // Base $2 + 100 * $0.50 = $52 — matches calculator logic (clamped distance at 300)
      expect(app.currentFee, equals(52.0));
    });

    test('zero yardage produces zero fee (no negative)', () {
      final app = AppState();
      app.setYardage(0);
      expect(app.currentFee, equals(0.0));
      expect(app.currentYardage, equals(0));
    });

    test('fee applies minimum cap of \$5', () {
      final app = AppState();
      app.setYardage(2); // base $2 + 2 * $0.50 = $3 → clamped to min $5
      expect(app.currentFee, equals(5.0));
    });

    test('fee applies distance cap at 300 yards', () {
      final app = AppState();
      app.setYardage(500); // distance capped at 300, fee = $2 + 300*$0.50 = $152
      expect(app.currentFee, equals(152.0));
    });

    test('resetYardage clears yardage and fee', () {
      final app = AppState();
      app.setYardage(150);
      expect(app.currentYardage, equals(150));
      expect(app.currentFee, isNotNull);

      app.resetYardage();

      expect(app.currentYardage, isNull);
      expect(app.currentFee, isNull);
    });
  });
}
