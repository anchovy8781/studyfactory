import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// English dictionary backed by the free dictionaryapi.dev service.
///
/// Looks up a word and shows phonetics, part-of-speech, definitions, examples
/// and synonyms — useful for vocabulary study.
class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final _ctrl = TextEditingController();
  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 12),
  ));

  bool _loading = false;
  String? _error;
  String _word = '';
  String _phonetic = '';
  List<_Meaning> _meanings = [];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _ctrl.text.trim().toLowerCase();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _meanings = [];
    });
    try {
      final resp = await _dio.get(
        'https://api.dictionaryapi.dev/api/v2/entries/en/${Uri.encodeComponent(query)}',
      );
      final list = resp.data as List;
      if (list.isEmpty) {
        setState(() => _error = '결과가 없습니다.');
        return;
      }
      final entry = list.first as Map;
      final word = (entry['word'] as String?) ?? query;
      // Pick the first non-empty phonetic text.
      var phonetic = (entry['phonetic'] as String?) ?? '';
      if (phonetic.isEmpty) {
        final phonetics = (entry['phonetics'] as List?) ?? [];
        for (final p in phonetics) {
          final t = (p as Map)['text'] as String?;
          if (t != null && t.isNotEmpty) {
            phonetic = t;
            break;
          }
        }
      }
      final meanings = <_Meaning>[];
      for (final m in (entry['meanings'] as List?) ?? []) {
        final mm = m as Map;
        final pos = (mm['partOfSpeech'] as String?) ?? '';
        final defs = <_Definition>[];
        for (final d in (mm['definitions'] as List?) ?? []) {
          final dd = d as Map;
          defs.add(_Definition(
            (dd['definition'] as String?) ?? '',
            (dd['example'] as String?) ?? '',
          ));
        }
        final synonyms = ((mm['synonyms'] as List?) ?? [])
            .map((e) => e.toString())
            .take(8)
            .toList();
        meanings.add(_Meaning(pos, defs, synonyms));
      }
      setState(() {
        _word = word;
        _phonetic = phonetic;
        _meanings = meanings;
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.statusCode == 404
            ? '"$query" 단어를 찾을 수 없습니다.'
            : '검색에 실패했습니다. 네트워크를 확인해주세요.';
      });
    } catch (_) {
      setState(() => _error = '검색에 실패했습니다.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text('영어 사전', style: AppTextStyles.titleLarge),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: '영어 단어를 입력하세요',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  onPressed: _search,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _centerText(_error!);
    }
    if (_meanings.isEmpty) {
      return _centerText('단어를 검색해 뜻과 예문을 확인하세요.');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(_word,
                  style: AppTextStyles.headlineSmall
                      .copyWith(fontWeight: FontWeight.w800)),
            ),
            if (_phonetic.isNotEmpty)
              Text(_phonetic,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18),
              color: AppColors.textSecondary,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _word));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('단어를 복사했습니다.')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._meanings.map(_buildMeaningCard),
      ],
    );
  }

  Widget _buildMeaningCard(_Meaning m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (m.partOfSpeech.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(m.partOfSpeech,
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          const SizedBox(height: 10),
          ...m.definitions.asMap().entries.map((e) {
            final i = e.key + 1;
            final d = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$i. ${d.definition}',
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.4)),
                  if (d.example.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 14),
                      child: Text('"${d.example}"',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic)),
                    ),
                ],
              ),
            );
          }),
          if (m.synonyms.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: m.synonyms
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(s,
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.textSecondary)),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _centerText(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ),
      );
}

class _Meaning {
  _Meaning(this.partOfSpeech, this.definitions, this.synonyms);
  final String partOfSpeech;
  final List<_Definition> definitions;
  final List<String> synonyms;
}

class _Definition {
  _Definition(this.definition, this.example);
  final String definition;
  final String example;
}
