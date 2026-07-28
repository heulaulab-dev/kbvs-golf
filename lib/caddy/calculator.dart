// Caddy fee calculator — pure Dart logic
// Business rule: $2 base fee + $0.50 per yard, capped at 300-yard distance
// Minimum fee $5 even at zero distance (policy floor)

class CaddyFeeCalculator {
  static const double baseFee = 2.0;
  static const double perYardRate = 0.5;
  static const double minimumFee = 5.0;
  static const int maxDistance = 300;

  const CaddyFeeCalculator();

  double calculateFee(int distance) {
    final clampedDistance = distance.clamp(0, maxDistance);
    final distanceFee = baseFee + (clampedDistance * perYardRate);
    return distanceFee < minimumFee ? minimumFee : distanceFee;
  }
}