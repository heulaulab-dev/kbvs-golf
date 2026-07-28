import 'package:flutter_test/flutter_test.dart';
import 'package:kbvs_golf/caddy/calculator.dart';

void main() {
  group('CaddyFeeCalculator', () {
    test('calculates caddy fee correctly for standard distance', () {
      // Arrange
      const calculator = CaddyFeeCalculator();

      // Act & Assert — expects $2 base + $0.5 per yard up to standard cap
      expect(calculator.calculateFee(100), 2 + 100 * 0.5);
      expect(calculator.calculateFee(200), 2 + 200 * 0.5);
    });

    test('applies minimum fee when distance is zero', () {
      const calculator = CaddyFeeCalculator();
      // Minimum fee of $5 regardless of distance (policy rule)
      expect(calculator.calculateFee(0), 5);
    });

    test('applies maximum fee at distance cap of 300 yards', () {
      const calculator = CaddyFeeCalculator();
      // Max fee at 300 yards: $2 + 300 * 0.5 = $152
      expect(calculator.calculateFee(300), 2 + 300 * 0.5);
    });

    test('caps fee at maximum for distances over limit', () {
      const calculator = CaddyFeeCalculator();
      // Any distance > 300 should still be capped at 300-yard rate
      expect(calculator.calculateFee(400), 2 + 300 * 0.5);
      expect(calculator.calculateFee(500), 2 + 300 * 0.5);
    });

    test('handles negative input by treating as zero', () {
      const calculator = CaddyFeeCalculator();
      expect(calculator.calculateFee(-50), 5); // min fee at 0
    });
  });
}
