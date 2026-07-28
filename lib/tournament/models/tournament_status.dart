enum TournamentStatus {
  pending,
  approved,
  rejected,
  full;

  static TournamentStatus fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING': return TournamentStatus.pending;
      case 'APPROVED': return TournamentStatus.approved;
      case 'REJECTED': return TournamentStatus.rejected;
      case 'FULL': return TournamentStatus.full;
      default: throw FormatException('Unknown TournamentStatus: $value');
    }
  }
}
