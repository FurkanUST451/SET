import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/message_model.dart';
import 'chat_detail_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB); // üst bar
const _kChatBg = Color(0xFFEDE8DC); // sohbet zemini
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kBubbleMe = Color(0xFF23212B); // giden balon (koyu)
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kAvatarBg = Color(0xFFEADCBB);

TextStyle _serif({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
}) =>
    GoogleFonts.cormorantGaramond(
        fontSize: size, fontWeight: weight, color: color, height: height);

TextStyle _mono({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
  double height = 1.4,
}) =>
    GoogleFonts.spaceMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: height);

const _monthsShort = [
  '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
  'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];

String _initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  final t = name.trim();
  return t.isEmpty ? '?' : t.substring(0, t.length >= 2 ? 2 : 1).toUpperCase();
}

String _hhmm(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

String _dayLabel(DateTime dt) {
  final now = DateTime.now();
  final d0 = DateTime(now.year, now.month, now.day);
  final d = DateTime(dt.year, dt.month, dt.day);
  final diff = d0.difference(d).inDays;
  if (diff == 0) return 'BUGÜN';
  if (diff == 1) return 'DÜN';
  return '${dt.day} ${_monthsShort[dt.month]}'.toUpperCase();
}

// « » içindeki metni altın renkle vurgular.
List<TextSpan> _highlightSpans(String text, Color accent) {
  final spans = <TextSpan>[];
  final reg = RegExp(r'«[^»]*»');
  var last = 0;
  for (final m in reg.allMatches(text)) {
    if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
    spans.add(TextSpan(
      text: m.group(0),
      style: TextStyle(color: accent, fontWeight: FontWeight.w700),
    ));
    last = m.end;
  }
  if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
  return spans;
}

class ChatDetailView extends GetView<ChatDetailController> {
  const ChatDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final double s = (width / 390).clamp(0.85, 1.15).toDouble();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => controller.goBack(),
      child: MediaQuery.withNoTextScaling(
        child: Scaffold(
          backgroundColor: _kChatBg,
          appBar: _buildAppBar(s),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    const Positioned.fill(child: _DotBackground()),
                    Obx(() {
                      final msgs = controller.messages;
                      return ListView.builder(
                        padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 16 * s),
                        itemCount: msgs.length,
                        itemBuilder: (_, i) {
                          final msg = msgs[i];
                          final showDay = i == 0 ||
                              !_sameDay(msgs[i - 1].createdAt, msg.createdAt);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (showDay) _DayChip(scale: s, label: _dayLabel(msg.createdAt)),
                              _buildMessage(s, msg),
                            ],
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
              _Composer(scale: s, controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  PreferredSizeWidget _buildAppBar(double s) {
    return PreferredSize(
      preferredSize: Size.fromHeight(64 * s),
      child: Container(
        decoration: const BoxDecoration(
          color: _kCream,
          border: Border(bottom: BorderSide(color: Color(0x14000000))),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 64 * s,
            child: Row(
              children: [
                SizedBox(width: 6 * s),
                GestureDetector(
                  onTap: controller.goBack,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(10 * s),
                    child: Icon(Icons.arrow_back_rounded, size: 20 * s, color: _kInk),
                  ),
                ),
                SizedBox(width: 2 * s),
                Container(
                  width: 40 * s,
                  height: 40 * s,
                  decoration: BoxDecoration(
                    color: _kAvatarBg,
                    borderRadius: BorderRadius.zero,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initialsOf(controller.chatName),
                    style: _mono(
                        size: 11 * s,
                        weight: FontWeight.w700,
                        color: _kInk,
                        spacing: 0.5),
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.chatName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _serif(
                            size: 19 * s, weight: FontWeight.w600, color: _kInk),
                      ),
                      SizedBox(height: 2 * s),
                      Row(
                        children: [
                          Container(
                            width: 6 * s,
                            height: 6 * s,
                            color: _kGold,
                          ),
                          SizedBox(width: 6 * s),
                          Flexible(
                            child: Text(
                              controller.briefTitle.isNotEmpty
                                  ? 'ÇEVRİMİÇİ · ${controller.briefTitle.toUpperCase()}'
                                  : 'ÇEVRİMİÇİ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  _mono(size: 7.5 * s, color: _kTaupe, spacing: 1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8 * s),
                _SquareBtn(scale: s, icon: Icons.call_outlined, onTap: () {}),
                SizedBox(width: 8 * s),
                _SquareBtn(scale: s, icon: Icons.videocam_outlined, onTap: () {}),
                SizedBox(width: 14 * s),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(double s, MessageModel msg) {
    final isMe = msg.senderId == controller.myId;
    final time = _hhmm(msg.createdAt);
    return isMe
        ? _MyBubble(scale: s, text: msg.content, time: time)
        : _TheirBubble(scale: s, text: msg.content, time: time);
  }
}

// ─── Nokta desenli zemin ──────────────────────────────────────────
class _DotBackground extends StatelessWidget {
  const _DotBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotPainter(), size: Size.infinite);
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _kInk.withValues(alpha: 0.05);
    const gap = 22.0;
    const r = 1.1;
    for (double y = 10; y < size.height; y += gap) {
      for (double x = 10; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Gün ayracı ───────────────────────────────────────────────────
class _DayChip extends StatelessWidget {
  const _DayChip({required this.scale, required this.label});
  final double scale;
  final String label;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12 * s),
        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 5 * s),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.zero,
        ),
        child: Text(label, style: _mono(size: 8 * s, color: _kTaupe, spacing: 1.5)),
      ),
    );
  }
}

// ─── Gelen balon (beyaz) ──────────────────────────────────────────
class _TheirBubble extends StatelessWidget {
  const _TheirBubble({required this.scale, required this.text, required this.time});
  final double scale;
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * s, right: 40 * s),
        padding: EdgeInsets.fromLTRB(14 * s, 12 * s, 14 * s, 8 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: _mono(size: 10 * s, color: _kInk, spacing: 0.2),
                children: _highlightSpans(text, _kGold),
              ),
            ),
            SizedBox(height: 4 * s),
            Align(
              alignment: Alignment.centerRight,
              child: Text(time,
                  style: _mono(size: 7.5 * s, color: _kMuted, spacing: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Giden balon (koyu) ───────────────────────────────────────────
class _MyBubble extends StatelessWidget {
  const _MyBubble({required this.scale, required this.text, required this.time});
  final double scale;
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * s, left: 40 * s),
        padding: EdgeInsets.fromLTRB(14 * s, 12 * s, 14 * s, 8 * s),
        decoration: BoxDecoration(
          color: _kBubbleMe,
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: _mono(
                    size: 10 * s,
                    color: Colors.white.withValues(alpha: 0.92),
                    spacing: 0.2),
                children: _highlightSpans(text, _kGold),
              ),
            ),
            SizedBox(height: 4 * s),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(time,
                    style: _mono(
                        size: 7.5 * s,
                        color: Colors.white.withValues(alpha: 0.45),
                        spacing: 0.5)),
                SizedBox(width: 4 * s),
                Icon(Icons.done_all_rounded, size: 12 * s, color: _kGold),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bar ikon butonu ──────────────────────────────────────────────
class _SquareBtn extends StatelessWidget {
  const _SquareBtn({required this.scale, required this.icon, required this.onTap});
  final double scale;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40 * s,
        height: 40 * s,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
        ),
        child: Icon(icon, size: 18 * s, color: _kInk),
      ),
    );
  }
}

// ─── Composer ─────────────────────────────────────────────────────
class _Composer extends StatelessWidget {
  const _Composer({required this.scale, required this.controller});
  final double scale;
  final ChatDetailController controller;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      decoration: const BoxDecoration(
        color: _kCream,
        border: Border(top: BorderSide(color: Color(0x14000000))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16 * s, 10 * s, 16 * s, 12 * s),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16 * s),
                  height: 46 * s,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.zero,
                    border:
                        Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: controller.messageController,
                    cursorColor: _kGold,
                    style: _mono(size: 10 * s, color: _kInk, spacing: 0.2, height: 1.2),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: 'Mesaj yaz...',
                      hintStyle:
                          _mono(size: 10 * s, color: _kMuted, spacing: 0.2),
                    ),
                    onSubmitted: (_) => controller.send(),
                  ),
                ),
              ),
              SizedBox(width: 10 * s),
              Obx(() => _SendBtn(
                    scale: s,
                    onTap: controller.send,
                    isLoading: controller.isSending.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendBtn extends StatelessWidget {
  const _SendBtn({required this.scale, required this.onTap, required this.isLoading});
  final double scale;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 46 * s,
        height: 46 * s,
        decoration: BoxDecoration(
          color: _kGold,
          borderRadius: BorderRadius.zero,
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 18 * s,
                height: 18 * s,
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(Icons.arrow_upward_rounded, size: 20 * s, color: Colors.white),
      ),
    );
  }
}
