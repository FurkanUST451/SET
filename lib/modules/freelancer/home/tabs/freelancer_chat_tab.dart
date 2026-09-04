import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_fonts.dart';

import '../../../../core/utils/avatar_image.dart';
import '../../../../modules/app/user_controller.dart';
import '../../../../routes/app_routes.dart';
import '../freelancer_chats_controller.dart';
import '../../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kDivider = Color(0x12000000);

TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
}) =>
    AppFonts.display(
        fontSize: size, fontWeight: weight, color: color, height: height);

TextStyle _ui({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
}) =>
    AppFonts.ui(
        fontSize: size, fontWeight: weight, color: color, letterSpacing: spacing);

const _monthsShort = [
  '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
  'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];
const _weekdaysShort = ['', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];


class FreelancerChatTab extends StatefulWidget {
  const FreelancerChatTab({super.key});

  @override
  State<FreelancerChatTab> createState() => _FreelancerChatTabState();
}

class _FreelancerChatTabState extends State<FreelancerChatTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FreelancerChatsController>();
    final myId = Get.find<UserController>().currentUser?.id ?? '';
    final width = MediaQuery.sizeOf(context).width;
    final double s = (width / 390).clamp(0.85, 1.15).toDouble();

    return ColoredBox(
      color: _kCream,
      child: MediaQuery.withNoTextScaling(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopStrip(s),
              SizedBox(height: 18 * s),
              _buildHeader(s),
              SizedBox(height: 16 * s),
              _buildSearch(s),
              SizedBox(height: 22 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 26 * s),
                child: Row(
                  children: [
                    Container(width: 18 * s, height: 2, color: _kGold),
                    SizedBox(width: 10 * s),
                    Text('SON SOHBETLER',
                        style: _ui(
                            size: 10 * s,
                            weight: FontWeight.w700,
                            color: _kBlack,
                            spacing: 1.8)),
                  ],
                ),
              ),
              SizedBox(height: 8 * s),
              Expanded(
                child: Obx(() {
                  final all = controller.chats;
                  final q = _query.trim().toLowerCase();
                  final chats = q.isEmpty
                      ? all
                      : all.where((c) {
                          final n = c.otherUserName(myId).toLowerCase();
                          final m = (c.lastMessage ?? '').toLowerCase();
                          final b = c.briefTitle.toLowerCase();
                          return n.contains(q) || m.contains(q) || b.contains(q);
                        }).toList();

                  if (chats.isEmpty) {
                    return _EmptyState(scale: s, hasQuery: q.isNotEmpty);
                  }

                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(26 * s, 4 * s, 26 * s, 130 * s),
                    itemCount: chats.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, thickness: 1, color: _kDivider),
                    itemBuilder: (_, i) {
                      final chat = chats[i];
                      final name = chat.otherUserName(myId);
                      return _ChatRow(
                        scale: s,
                        name: name,
                        snippet: (chat.lastMessage?.isNotEmpty ?? false)
                            ? chat.lastMessage!
                            : chat.briefTitle,
                        eyebrow: chat.briefTitle,
                        time: chat.lastMessageAt != null
                            ? _fmtListTime(chat.lastMessageAt!)
                            : '',
                        onTap: () => Get.toNamed(
                          AppRoutes.chatDetail,
                          arguments: {
                            'chatId': chat.id,
                            'otherUserName': name,
                            'briefTitle': chat.briefTitle,
                            'returnRoute': AppRoutes.freelancerHome,
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStrip(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(26 * s, 6 * s, 26 * s, 12 * s),
          child: Text('SET · MESAJLAR',
              style: _ui(size: 10 * s, color: _kBlack, spacing: 2)),
        ),
        Container(height: 1, color: _kDivider),
      ],
    );
  }

  Widget _buildHeader(double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(26 * s, 0, 18 * s, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sohbetler',
              style: _display(size: 32 * s, weight: FontWeight.w600, color: _kInk)),
        ],
      ),
    );
  }

  Widget _buildSearch(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26 * s),
      child: Container(
        height: 46 * s,
        padding: EdgeInsets.symmetric(horizontal: 14 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 18 * s, color: _kMuted),
            SizedBox(width: 10 * s),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                cursorColor: _kGold,
                style: _ui(size: 10 * s, color: _kBlack, spacing: 0.2),
                decoration: InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: 'Sohbet veya kişi ara',
                  hintStyle: _ui(size: 10 * s, color: _kBlack, spacing: 0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtListTime(DateTime dt) {
    final now = DateTime.now();
    final d0 = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    final diff = d0.difference(d).inDays;
    if (diff == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff == 1) return 'Dün';
    if (diff < 7) return _weekdaysShort[dt.weekday];
    return '${dt.day} ${_monthsShort[dt.month]}';
  }
}

// ─── Sohbet satırı ────────────────────────────────────────────────
class _ChatRow extends StatelessWidget {
  const _ChatRow({
    required this.scale,
    required this.name,
    required this.snippet,
    required this.eyebrow,
    required this.time,
    required this.onTap,
  });

  final double scale;
  final String name;
  final String snippet;
  final String eyebrow;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16 * s),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: Image.asset(
                placeholderAvatarFor(null, name),
                width: 46 * s,
                height: 46 * s,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 14 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _display(
                              size: 19 * s, weight: FontWeight.w600, color: _kInk),
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      Text(time, style: _ui(size: 13 * s, color: _kBlack, spacing: 0.5)),
                    ],
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    snippet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ui(size: 13 * s, color: _kBlack, spacing: 0.2),
                  ),
                  if (eyebrow.isNotEmpty) ...[
                    SizedBox(height: 5 * s),
                    Text(
                      eyebrow.toUpperCaseTr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _ui(size: 10 * s, color: _kBlack, spacing: 1.2),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Boş durum ────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scale, required this.hasQuery});
  final double scale;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64 * s,
              height: 64 * s,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
              ),
              child: Icon(Icons.forum_outlined, size: 28 * s, color: _kMuted),
            ),
            SizedBox(height: 16 * s),
            Text(
              hasQuery ? 'Sonuç bulunamadı' : 'Henüz mesajın yok',
              style: _display(size: 24 * s, weight: FontWeight.w600, color: _kInk),
            ),
            SizedBox(height: 6 * s),
            Text(
              hasQuery
                  ? 'Farklı bir arama dene.'
                  : 'Bir teklifi kabul ettiğinde sohbet burada başlar.',
              textAlign: TextAlign.center,
              style: _ui(size: 13 * s, color: _kBlack, spacing: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}
