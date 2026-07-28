enum TournamentFormat {
  matchPlay,
  stableford,
  scramble,
  bestBall,
  championship;

  static TournamentFormat fromApi(String value) {
    switch (value.toLowerCase()) {
      case 'match-play': return TournamentFormat.matchPlay;
      case 'stableford': return TournamentFormat.stableford;
      case 'scramble': return TournamentFormat.scramble;
      case 'best-ball': return TournamentFormat.bestBall;
      case 'championship': return TournamentFormat.championship;
      default: throw FormatException('Unknown TournamentFormat: $value');
    }
  }
}
