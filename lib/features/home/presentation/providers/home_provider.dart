import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/features/home/data/home_repository.dart';
import 'package:studyverse/features/home/domain/models/home_model.dart';

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this._repository) : super(const HomeState.initial()) {
    fetchData();
  }

  final HomeRepository _repository;

  Future<void> fetchData() async {
    state = const HomeState.loading();
    try {
      final data = await _repository.fetchHomeData();
      state = HomeState.loaded(data);
    } catch (e) {
      state = HomeState.error(e.toString());
    }
  }

  Future<void> refresh() => fetchData();

  void startStudying() {
    state.whenOrNull(
      loaded: (data) => state = HomeState.loaded(data.copyWith(isStudying: true)),
    );
  }

  void stopStudying() {
    state.whenOrNull(
      loaded: (data) => state = HomeState.loaded(data.copyWith(isStudying: false)),
    );
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref.watch(homeRepositoryProvider));
});

/// Quick-access provider for the loaded data (returns null if not yet loaded).
final homeDataProvider = Provider<HomeData?>((ref) {
  return ref.watch(homeProvider).whenOrNull(loaded: (d) => d);
});
