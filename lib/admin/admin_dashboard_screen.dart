import 'package:flutter/material.dart';

import 'package:studyverse/admin/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = AdminService();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text('S',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            const Text('관리자 패널',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '로그아웃',
            icon: const Icon(Icons.logout),
            onPressed: () => _service.signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          return ListView(
            padding: EdgeInsets.all(wide ? 24 : 12),
            children: [
              _StatsSection(service: _service, wide: wide),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('사용자 관리',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  SizedBox(
                    width: wide ? 280 : 160,
                    child: TextField(
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: '닉네임·이메일 검색',
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) =>
                          setState(() => _query = v.trim().toLowerCase()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _UserList(service: _service, query: _query, wide: wide),
            ],
          );
        },
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.service, required this.wide});

  final AdminService service;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminStats>(
      future: service.fetchStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        final cards = [
          _stat('전체 사용자', stats == null ? '—' : '${stats.totalUsers}',
              Icons.people_alt_rounded, const Color(0xFF1A73E8)),
          _stat('관리자', stats == null ? '—' : '${stats.adminCount}',
              Icons.admin_panel_settings_rounded, const Color(0xFF7C4DFF)),
          _stat('총 포인트', stats == null ? '—' : '${stats.totalPoints}',
              Icons.stars_rounded, const Color(0xFFFF6B35)),
          _stat(
              '총 공부시간',
              stats == null
                  ? '—'
                  : '${stats.totalStudyHours.toStringAsFixed(1)}h',
              Icons.timer_rounded,
              const Color(0xFF00B894)),
        ];
        return GridView.count(
          crossAxisCount: wide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: wide ? 1.9 : 1.6,
          children: cards,
        );
      },
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList(
      {required this.service, required this.query, required this.wide});

  final AdminService service;
  final String query;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AdminUser>>(
      stream: service.watchUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _message(
              'Firebase 연결 오류\n실제 google-services.json / web 구성을 추가하세요.');
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        var users = snapshot.data!;
        if (query.isNotEmpty) {
          users = users
              .where((u) =>
                  u.nickname.toLowerCase().contains(query) ||
                  u.email.toLowerCase().contains(query))
              .toList();
        }
        if (users.isEmpty) {
          return _message('표시할 사용자가 없습니다.');
        }
        return Column(
          children: users.map((u) => _UserCard(service: service, user: u)).toList(),
        );
      },
    );
  }

  Widget _message(String text) => Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54)),
      );
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.service, required this.user});

  final AdminService service;
  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                user.isAdmin ? const Color(0xFF7C4DFF) : const Color(0xFF1A73E8),
            child: Text(
              user.nickname.isNotEmpty ? user.nickname.substring(0, 1) : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(user.nickname,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    if (user.isAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C4DFF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('ADMIN',
                            style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF7C4DFF),
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                Text(user.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  'Lv.${user.level} · ${user.points}P · ${user.totalStudyHours.toStringAsFixed(1)}h · 🔥${user.streakDays}',
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => _onAction(context, v),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'role',
                child: Text(user.isAdmin ? '관리자 권한 해제' : '관리자로 지정'),
              ),
              const PopupMenuItem(value: 'points', child: Text('포인트 수정')),
              const PopupMenuItem(value: 'delete', child: Text('프로필 삭제')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onAction(BuildContext context, String action) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      switch (action) {
        case 'role':
          await service.setRole(user.uid, user.isAdmin ? 'user' : 'admin');
          messenger.showSnackBar(
              const SnackBar(content: Text('권한이 변경되었습니다.')));
        case 'points':
          final value = await _promptPoints(context);
          if (value != null) {
            await service.setPoints(user.uid, value);
            messenger.showSnackBar(
                const SnackBar(content: Text('포인트가 수정되었습니다.')));
          }
        case 'delete':
          final ok = await _confirmDelete(context);
          if (ok) {
            await service.deleteUserDoc(user.uid);
            messenger.showSnackBar(
                const SnackBar(content: Text('프로필이 삭제되었습니다.')));
          }
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('실패: $e')));
    }
  }

  Future<int?> _promptPoints(BuildContext context) async {
    final controller = TextEditingController(text: '${user.points}');
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('포인트 수정'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '포인트'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, int.tryParse(controller.text.trim())),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('프로필 삭제'),
        content: Text('${user.nickname} 님의 프로필 문서를 삭제하시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
