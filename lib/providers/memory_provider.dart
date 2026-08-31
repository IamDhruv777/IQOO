import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/memory.dart';
import '../services/database_service.dart';

/// Central provider for all memories stored on-device.
/// Exposes async loading, insertion, update, and deletion.
class MemoriesNotifier extends AsyncNotifier<List<Memory>> {
  final _db = DatabaseService();

  @override
  Future<List<Memory>> build() => _db.getAllMemories();

  Future<void> addMemory(Memory memory) async {
    state = const AsyncLoading();
    await _db.insertMemory(memory);
    state = AsyncData(await _db.getAllMemories());
  }

  Future<void> updateMemory(Memory memory) async {
    await _db.updateMemory(memory);
    // Update in-place without full reload for responsiveness
    state = state.whenData((memories) =>
        memories.map((m) => m.id == memory.id ? memory : m).toList());
  }

  Future<void> deleteMemory(String id) async {
    await _db.deleteMemory(id);
    state = state.whenData(
        (memories) => memories.where((m) => m.id != id).toList());
  }

  Future<void> refresh() async {
    state = AsyncData(await _db.getAllMemories());
  }
}

final memoriesProvider =
    AsyncNotifierProvider<MemoriesNotifier, List<Memory>>(MemoriesNotifier.new);

/// Provider for the current search query string.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for search results — either AI-ranked or keyword fallback.
/// Populated by the SearchScreen after a query is executed.
final searchResultsProvider = StateProvider<List<Memory>>((ref) => []);

/// Tracks whether the app has already inserted seed demo data.
final seedInsertedProvider = StateProvider<bool>((ref) => false);
