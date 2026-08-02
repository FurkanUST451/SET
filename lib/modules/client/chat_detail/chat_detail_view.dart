import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/utils/avatar_image.dart';
import '../../../data/models/brief_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/offer_model.dart';
import 'chat_detail_controller.dart';
import '../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB); // üst bar
const _kChatBg = Color(0xFFEDE8DC); // sohbet zemini
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kBubbleMe = Color(0xFF23212B); // giden balon (koyu)
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kAccepted = Color(0xFF6B8F71);
const _kDanger = Color(0xFFBE6A5A);
const _kCardBorder = Color(0x14000000);

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
  double height = 1.4,
}) =>
    AppFonts.ui(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: height);

const _monthsShort = [
  '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
  'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];


String _hhmm(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

String _dayLabel(DateTime dt) {
  final now = DateTime.now();
  final d0 = DateTime(now.year, now.month, now.day);
  final d = DateTime(dt.year, dt.month, dt.day);
  final diff = d0.difference(d).inDays;
  if (diff == 0) return 'BUGÜN';
  if (diff == 1) return 'DÜN';
  return '${dt.day} ${_monthsShort[dt.month]}'.toUpperCaseTr();
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

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
      canPop: Get.key.currentState?.canPop() ?? false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) controller.goBack();
      },
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
                        itemCount: msgs.length + 1,
                        itemBuilder: (_, i) {
                          if (i == 0) {
                            return _BriefCard(scale: s, controller: controller);
                          }
                          final msg = msgs[i - 1];
                          final showDay = i == 1 ||
                              !_sameDay(msgs[i - 2].createdAt, msg.createdAt);
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
                ClipOval(
                  child: Image.asset(
                    placeholderAvatarFor(null, controller.chatName),
                    width: 40 * s,
                    height: 40 * s,
                    fit: BoxFit.cover,
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
                        style: _display(
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
                                  ? 'ÇEVRİMİÇİ · ${controller.briefTitle.toUpperCaseTr()}'
                                  : 'ÇEVRİMİÇİ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  _ui(size: 7.5 * s, color: _kBlack, spacing: 1),
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

    if (msg.type == 'offer' && msg.offerId != null) {
      return Obx(() {
        final offer = controller.offers[msg.offerId];
        if (offer == null) return const SizedBox.shrink();
        return _OfferBubble(
          scale: s,
          offer: offer,
          isMe: isMe,
          time: time,
          onAccept: () => controller.respondToOffer(offer, true),
          onReject: () => controller.respondToOffer(offer, false),
        );
      });
    }

    return isMe
        ? _MyBubble(scale: s, text: msg.content, time: time)
        : _TheirBubble(scale: s, text: msg.content, time: time);
  }
}

// ─── Brief kartı (sohbetin en üstünde) ────────────────────────────────────────
class _BriefCard extends StatelessWidget {
  const _BriefCard({required this.scale, required this.controller});
  final double scale;
  final ChatDetailController controller;

  String _categoryAsset(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('video') || cat.contains('film')) {
      return 'assets/images/main_service_icons/video.png';
    } else if (cat.contains('fotoğraf') || cat.contains('photo')) {
      return 'assets/images/main_service_icons/foto.png';
    } else if (cat.contains('ses') || cat.contains('müzik')) {
      return 'assets/images/main_service_icons/ses.png';
    } else if (cat.contains('cgi') || cat.contains('vfx')) {
      return 'assets/images/main_service_icons/cgi.png';
    } else if (cat.contains('kurgu') || cat.contains('montaj')) {
      return 'assets/images/main_service_icons/kurgu.png';
    } else if (cat.contains('sosyal')) {
      return 'assets/images/main_service_icons/sosyal medya.png';
    }
    return 'assets/images/main_service_icons/grafiktasarim.png';
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Obx(() {
      final brief = controller.brief.value;
      final category =
          brief?.category.isNotEmpty == true ? brief!.category : controller.briefTitle;
      final shootingType = brief?.answers.shootingType;
      if (category.isEmpty) return SizedBox(height: 8 * s);

      return GestureDetector(
        onTap: brief == null ? null : () => _showBriefDetail(context, brief, s),
        child: Container(
          margin: EdgeInsets.only(bottom: 16 * s),
          padding: EdgeInsets.all(14 * s),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _kGold.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 38 * s,
                height: 38 * s,
                decoration: const BoxDecoration(color: Colors.white),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  _categoryAsset(category),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.work_outline_rounded, color: _kGold, size: 18 * s),
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: _display(size: 15 * s, weight: FontWeight.w600, color: _kInk),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (shootingType != null && shootingType.isNotEmpty) ...[
                      SizedBox(height: 2 * s),
                      Text(
                        shootingType,
                        style: _ui(size: 8 * s, color: _kBlack, spacing: 0.3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (brief != null)
                Icon(Icons.chevron_right, size: 18 * s, color: _kMuted),
            ],
          ),
        ),
      );
    });
  }

  void _showBriefDetail(BuildContext context, BriefModel brief, double s) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _kCream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => _BriefDetailSheet(brief: brief),
    );
  }
}

class _BriefDetailSheet extends StatelessWidget {
  const _BriefDetailSheet({required this.brief});
  final BriefModel brief;

  @override
  Widget build(BuildContext context) {
    final s = (MediaQuery.sizeOf(context).width / 390).clamp(0.85, 1.15).toDouble();
    final a = brief.answers;
    final items = <(IconData, String, String)>[
      if (a.shootingType != null && a.shootingType!.isNotEmpty)
        (Icons.movie_creation_outlined, 'Çekim Türü', a.shootingType!),
      if (a.dateRange != null && a.dateRange!.isNotEmpty)
        (Icons.calendar_today_outlined, 'Çekim Tarihi', a.dateRange!),
      if (a.deliveryTime != null && a.deliveryTime!.isNotEmpty)
        (Icons.access_time_outlined, 'Teslim Süresi', a.deliveryTime!),
      if (a.budget != null && a.budget!.isNotEmpty)
        (Icons.attach_money_outlined, 'Bütçe', a.budget!),
      if (a.location != null && a.location!.isNotEmpty)
        (Icons.location_on_outlined, 'Lokasyon', a.location!),
      if (a.vibes != null && a.vibes!.isNotEmpty)
        (Icons.show_chart_rounded, 'Duygu', a.vibes!.join(', ')),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20 * s, 20 * s, 20 * s, 20 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              brief.category.isNotEmpty ? brief.category : 'İş',
              style: _display(size: 20 * s, weight: FontWeight.w600, color: _kInk),
            ),
            if (a.shootingType != null && a.shootingType!.isNotEmpty) ...[
              SizedBox(height: 2 * s),
              Text(
                a.shootingType!,
                style: _ui(size: 9 * s, color: _kBlack, spacing: 0.3),
              ),
            ],
            SizedBox(height: 18 * s),
            if (items.isNotEmpty)
              Wrap(
                spacing: 10 * s,
                runSpacing: 10 * s,
                children: items
                    .map((item) => _DetailChip(
                          scale: s,
                          icon: item.$1,
                          label: item.$2,
                          value: item.$3,
                        ))
                    .toList(),
              ),
            if (a.notes != null && a.notes!.isNotEmpty) ...[
              SizedBox(height: 18 * s),
              Text(
                'İŞ TARİFİ',
                style: _ui(size: 8 * s, weight: FontWeight.w700, color: _kBlack, spacing: 1.2),
              ),
              SizedBox(height: 8 * s),
              Text(
                a.notes!,
                style: _ui(size: 10 * s, color: _kBlack, height: 1.6, spacing: 0.2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.scale,
    required this.icon,
    required this.label,
    required this.value,
  });
  final double scale;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      constraints: BoxConstraints(minWidth: 130 * s),
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12 * s, color: _kTaupe),
              SizedBox(width: 4 * s),
              Text(label, style: _ui(size: 7 * s, color: _kBlack, spacing: 0.5)),
            ],
          ),
          SizedBox(height: 4 * s),
          Text(
            value,
            style: _ui(size: 10 * s, weight: FontWeight.w700, color: _kBlack, spacing: 0.2),
          ),
        ],
      ),
    );
  }
}

// ─── Teklif balonu ─────────────────────────────────────────────────────────────
class _OfferBubble extends StatelessWidget {
  const _OfferBubble({
    required this.scale,
    required this.offer,
    required this.isMe,
    required this.time,
    required this.onAccept,
    required this.onReject,
  });

  final double scale;
  final OfferModel offer;
  final bool isMe;
  final String time;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  String get _statusLabel {
    switch (offer.status) {
      case OfferStatus.accepted:
        return 'Kabul Edildi';
      case OfferStatus.rejected:
        return 'Reddedildi';
      case OfferStatus.pending:
        return isMe ? 'Yanıt Bekleniyor' : 'Yanıt Bekliyor';
    }
  }

  Color get _statusColor {
    switch (offer.status) {
      case OfferStatus.accepted:
        return _kAccepted;
      case OfferStatus.rejected:
        return _kDanger;
      case OfferStatus.pending:
        return _kGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * s),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(14 * s),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _kGold.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.payments_outlined, size: 16 * s, color: _kGold),
                  SizedBox(width: 6 * s),
                  Text('FİYAT TEKLİFİ',
                      style: _ui(size: 8 * s, color: _kBlack, spacing: 0.8)),
                  const Spacer(),
                  Text(
                    _statusLabel,
                    style: _ui(
                        size: 8 * s,
                        weight: FontWeight.w700,
                        color: _statusColor,
                        spacing: 0.4),
                  ),
                ],
              ),
              SizedBox(height: 6 * s),
              Text(
                '${offer.amount.toStringAsFixed(0)} ₺',
                style: _display(size: 22 * s, weight: FontWeight.w600, color: _kInk),
              ),
              if (offer.message.isNotEmpty) ...[
                SizedBox(height: 4 * s),
                Text(offer.message,
                    style: _ui(size: 9 * s, color: _kBlack, spacing: 0.2)),
              ],
              if (!isMe && offer.status == OfferStatus.pending) ...[
                SizedBox(height: 10 * s),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onReject,
                        child: Container(
                          height: 38 * s,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(color: _kDanger)),
                          child: Text('Reddet',
                              style: _ui(
                                  size: 9 * s,
                                  weight: FontWeight.w700,
                                  color: _kDanger,
                                  spacing: 0.4)),
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: GestureDetector(
                        onTap: onAccept,
                        child: Container(
                          height: 38 * s,
                          alignment: Alignment.center,
                          color: _kGold,
                          child: Text('Kabul Et',
                              style: _ui(
                                  size: 9 * s,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                  spacing: 0.4)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 4 * s),
              Text(time, style: _ui(size: 7.5 * s, color: _kBlack, spacing: 0.5)),
            ],
          ),
        ),
      ),
    );
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
        child: Text(label, style: _ui(size: 8 * s, color: _kBlack, spacing: 1.5)),
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
                style: _ui(size: 10 * s, color: _kBlack, spacing: 0.2),
                children: _highlightSpans(text, _kGold),
              ),
            ),
            SizedBox(height: 4 * s),
            Align(
              alignment: Alignment.centerRight,
              child: Text(time,
                  style: _ui(size: 7.5 * s, color: _kBlack, spacing: 0.5)),
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
                style: _ui(
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
                    style: _ui(
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
              GestureDetector(
                onTap: () => _showOfferSheet(context, controller, s),
                child: Container(
                  width: 46 * s,
                  height: 46 * s,
                  margin: EdgeInsets.only(right: 10 * s),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _kGold.withValues(alpha: 0.5)),
                  ),
                  child: Icon(Icons.payments_outlined, size: 19 * s, color: _kGold),
                ),
              ),
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
                    style: _ui(size: 10 * s, color: _kBlack, spacing: 0.2, height: 1.2),
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
                          _ui(size: 10 * s, color: _kBlack, spacing: 0.2),
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

void _showOfferSheet(
    BuildContext context, ChatDetailController controller, double s) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: _kCream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20 * s,
          20 * s,
          20 * s,
          MediaQuery.of(ctx).viewInsets.bottom + 20 * s,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fiyat Teklifi Gönder',
                style: _display(size: 20 * s, weight: FontWeight.w600, color: _kInk)),
            SizedBox(height: 16 * s),
            TextField(
              controller: controller.offerAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: _ui(size: 11 * s, color: _kBlack, spacing: 0.2),
              cursorColor: _kGold,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Tutar (₺)',
                hintStyle: _ui(size: 11 * s, color: _kBlack, spacing: 0.2),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 14 * s, vertical: 14 * s),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: _kGold),
                ),
              ),
            ),
            SizedBox(height: 10 * s),
            TextField(
              controller: controller.offerNoteController,
              maxLines: 2,
              style: _ui(size: 11 * s, color: _kBlack, spacing: 0.2),
              cursorColor: _kGold,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Not (opsiyonel)',
                hintStyle: _ui(size: 11 * s, color: _kBlack, spacing: 0.2),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 14 * s, vertical: 14 * s),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: _kGold),
                ),
              ),
            ),
            SizedBox(height: 18 * s),
            SizedBox(
              width: double.infinity,
              child: Obx(() => GestureDetector(
                    onTap: controller.isSendingOffer.value
                        ? null
                        : controller.sendOffer,
                    child: Container(
                      height: 50 * s,
                      color: _kGold,
                      alignment: Alignment.center,
                      child: controller.isSendingOffer.value
                          ? SizedBox(
                              width: 18 * s,
                              height: 18 * s,
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text('Teklifi Gönder',
                              style: _ui(
                                  size: 10 * s,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                  spacing: 0.6)),
                    ),
                  )),
            ),
          ],
        ),
      );
    },
  );
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
