import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// 우리 학교 급식 조회 (NEIS 교육정보 개방 포털 API 연동).
class SchoolMealScreen extends StatefulWidget {
  const SchoolMealScreen({super.key});

  @override
  State<SchoolMealScreen> createState() => _SchoolMealScreenState();
}

class _SchoolMealScreenState extends State<SchoolMealScreen> {
  final _dio = Dio();
  final _searchCtrl = TextEditingController();

  String? _office; // ATPT_OFCDC_SC_CODE
  String? _code; // SD_SCHUL_CODE
  String? _schoolName;
  List<Map<String, dynamic>> _results = [];
  List<String> _meals = [];
  bool _loading = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final p = await SharedPreferences.getInstance();
    _office = p.getString('meal_office');
    _code = p.getString('meal_code');
    _schoolName = p.getString('meal_school');
    if (_office != null && _code != null) {
      _fetchMeal();
    } else {
      setState(() {});
    }
  }

  Future<void> _searchSchools() async {
    final name = _searchCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _loading = true;
      _status = null;
      _results = [];
    });
    try {
      final resp = await _dio.get(
        'https://open.neis.go.kr/hub/schoolInfo',
        queryParameters: {'Type': 'json', 'pSize': 30, 'SCHUL_NM': name},
      );
      final rows = _extractRows(resp.data, 'schoolInfo');
      if (rows.isEmpty) {
        setState(() => _status = '검색 결과가 없습니다. 학교 이름을 확인해 주세요.');
      } else {
        setState(() => _results = rows);
      }
    } catch (e) {
      setState(() => _status = '검색 중 오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectSchool(Map<String, dynamic> s) async {
    final p = await SharedPreferences.getInstance();
    _office = s['ATPT_OFCDC_SC_CODE'] as String?;
    _code = s['SD_SCHUL_CODE'] as String?;
    _schoolName = s['SCHUL_NM'] as String?;
    await p.setString('meal_office', _office ?? '');
    await p.setString('meal_code', _code ?? '');
    await p.setString('meal_school', _schoolName ?? '');
    setState(() => _results = []);
    _fetchMeal();
  }

  Future<void> _fetchMeal() async {
    if (_office == null || _code == null) return;
    setState(() {
      _loading = true;
      _status = null;
      _meals = [];
    });
    final now = DateTime.now();
    final ymd =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    try {
      final resp = await _dio.get(
        'https://open.neis.go.kr/hub/mealServiceDietInfo',
        queryParameters: {
          'Type': 'json',
          'ATPT_OFCDC_SC_CODE': _office,
          'SD_SCHUL_CODE': _code,
          'MLSV_YMD': ymd,
        },
      );
      final rows = _extractRows(resp.data, 'mealServiceDietInfo');
      if (rows.isEmpty) {
        setState(() => _status = '오늘($ymd)은 급식 정보가 없습니다. (주말·방학 등)');
      } else {
        final meals = <String>[];
        for (final r in rows) {
          final type = r['MMEAL_SC_NM'] as String? ?? '';
          final dish = (r['DDISH_NM'] as String? ?? '')
              .replaceAll('<br/>', '\n')
              .replaceAll(RegExp(r'\s*\([0-9.]+\)'), ''); // remove allergens
          meals.add('[$type]\n$dish');
        }
        setState(() => _meals = meals);
      }
    } catch (e) {
      setState(() => _status = '급식 정보를 불러오지 못했습니다.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _extractRows(dynamic data, String key) {
    try {
      final section = data[key];
      if (section is! List) return [];
      for (final part in section) {
        if (part is Map && part['row'] is List) {
          return (part['row'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
        title: Text('우리 학교 급식', style: AppTextStyles.titleLarge),
        actions: [
          if (_schoolName != null)
            IconButton(
                onPressed: _fetchMeal,
                icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onSubmitted: (_) => _searchSchools(),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '학교 이름 검색 (예: 서울고)',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _searchSchools,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                child: const Text('검색'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceLg),
          if (_loading) const Center(child: CircularProgressIndicator()),
          // School search results
          ..._results.map((s) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  title: Text(s['SCHUL_NM'] as String? ?? ''),
                  subtitle: Text(s['ORG_RDNMA'] as String? ?? '',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _selectSchool(s),
                ),
              )),
          if (_schoolName != null && _results.isEmpty) ...[
            Text('🏫 $_schoolName',
                style: AppTextStyles.titleMedium
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.spaceMd),
          ],
          if (_status != null && !_loading)
            Container(
              padding: const EdgeInsets.all(AppSizes.spaceLg),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Text(_status!,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ..._meals.map((m) => Container(
                margin: const EdgeInsets.only(bottom: AppSizes.spaceMd),
                padding: const EdgeInsets.all(AppSizes.spaceLg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Text(m,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.7)),
              )),
          const SizedBox(height: AppSizes.spaceLg),
          Text('데이터 제공: NEIS 교육정보 개방 포털',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }
}
