import 'package:hive_flutter/hive_flutter.dart';
import '../tournament/models/tournament.dart';

/// Persistent data store for mock tournament data using Hive.
/// Stores tournaments as JSON maps keyed by tournament ID.
class MockDataStore {
  static const _boxName = 'mock_tournaments';
  late Box _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _initialized = true;
  }

  Future<List<Tournament>> loadAll() async {
    if (!_initialized || _box.isEmpty) return [];
    final List<Tournament> result = [];
    for (final key in _box.keys) {
      final json = _box.get(key);
      if (json is Map<String, dynamic>) {
        result.add(Tournament.fromJson(json));
      }
    }
    return result;
  }

  Future<void> saveAll(List<Tournament> tournaments) async {
    if (!_initialized) throw StateError('MockDataStore not initialized');
    final Map<dynamic, dynamic> data = {};
    for (final tournament in tournaments) {
      data[tournament.id] = tournament.toJson();
    }
    await _box.putAll(data);
  }

  Future<void> update(Tournament tournament) async {
    if (!_initialized) throw StateError('MockDataStore not initialized');
    await _box.put(tournament.id, tournament.toJson());
  }

  Future<void> close() async {
    if (_initialized) {
      await _box.close();
      _initialized = false;
    }
  }
}
