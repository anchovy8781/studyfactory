import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studyverse/features/home/domain/models/home_model.dart';

class HomeRepository {
  HomeRepository({required Dio dio, required FlutterSecureStorage secureStorage})
      : _dio = dio,
        _secureStorage = secureStorage;

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  Future<HomeData> fetchHomeData() async {
    final token = await _secureStorage.read(key: 'access_token');

    try {
      final response = await _dio.get(
        '/home',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      return HomeData.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      // Return mock data so the UI is always functional during development.
      return _mockHomeData();
    } catch (_) {
      return _mockHomeData();
    }
  }

  HomeData _mockHomeData() {
    return const HomeData(
      userNickname: '공부왕',
      todayStudyHours: 3.75,
      targetHours: 5.0,
      streakDays: 21,
      bestStreak: 45,
      points: 12480,
      focusScore: 92.0,
      recentSessions: 3,
      isStudying: false,
    );
  }
}

// ── Providers ──────────────────────────────────────────────────────────────

final _homeRepoDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://api.studyverse.app/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
});

final _homeRepoStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(
    dio: ref.watch(_homeRepoDioProvider),
    secureStorage: ref.watch(_homeRepoStorageProvider),
  );
});
