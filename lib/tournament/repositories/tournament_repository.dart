import '../models/tournament.dart';

/// Abstract repository interface for tournament data.
///
/// All implementations (mock, real HTTP) must satisfy this contract.
abstract class TournamentRepository {
  /// Returns the paginated list of tournaments (first page).
  /// Tuple: (tournaments, totalCount, hasMorePages)
  Future<(List<Tournament>, int, bool)> getFirstPage();

  /// Returns next page given cursor/token or null if no more page.
  /// Tuple: (tournaments, totalCount, hasMorePages)
  Future<(List<Tournament>, int, bool)> nextPage({String? cursor});

  /// Returns previous page given cursor/token or null if no more page.
  /// Tuple: (tournaments, totalCount, hasMorePages)
  Future<(List<Tournament>, int, bool)> prevPage({String? cursor});

  /// Returns a single tournament by ID.
  Future<Tournament> getById(String id);

  /// Returns all tournaments matching [query] (empty string = all).
  /// Tuple: (tournaments, totalCount, hasMorePages)
  Future<(List<Tournament>, int, bool)> search(String query);

  /// Registers the user for the tournament with given [id].
  /// Updates the tournament's registered count.
  Future<void> register(String tournamentId);
}
