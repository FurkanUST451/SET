import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/avatar_image.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/comment_model.dart';
import '../../../../data/models/work_model.dart';
import '../../../app/user_controller.dart';
import '../../../app/works_controller.dart';

// ─── Palet — client_discover_tab.dart / chat_detail_view.dart ile aynı ────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000);
const _kDivider = Color(0x12000000);

TextStyle _serif({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  bool italic = false,
}) =>
    GoogleFonts.cormorantGaramond(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.1,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );

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
      height: height,
    );

/// Keşfet kartındaki yorum ikonuna dokunulduğunda açılan yorum sayfası.
/// Yalnızca Firestore'a yüklenmiş gerçek işler için çağrılır (bkz.
/// WorkModel.isLive) — dummy kartların arkasında gerçek doküman olmadığı
/// için yorum akışı onlarda hiç açılmaz.
Future<void> showWorkCommentsSheet(BuildContext context, WorkModel work) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: _kCream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (ctx) => _CommentsSheet(work: work),
  );
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.work});

  final WorkModel work;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final WorksController _controller = Get.find<WorksController>();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _isSending = false;

  // Composer'daki her setState (gönderim başlıyor/bitiyor) build()'ı
  // yeniden çalıştırır; stream'i burada bir kez alıp saklamazsak, tam da
  // yeni yorum eklendiği anda dinleyici kapanıp yeniden açılır ve liste
  // kısa bir an yükleniyor durumuna döner.
  late final Stream<List<CommentModel>> _commentsStream =
      _controller.commentsStream(widget.work.id);

  Future<void> _send() async {
    final text = _input.text;
    if (text.trim().isEmpty || _isSending) return;
    setState(() => _isSending = true);
    final ok = await _controller.postComment(widget.work.id, text);
    if (!mounted) return;
    setState(() => _isSending = false);
    if (ok) {
      _input.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = (MediaQuery.sizeOf(context).width / 390).clamp(0.85, 1.15).toDouble();
    final myId = Get.find<UserController>().currentUser?.id;

    // Sabit yükseklik dışarıda tutulur (ekranın her zaman %82'si), klavye
    // açıldığında yalnızca içerik alanı daralır — böylece sheet klavyeyle
    // birlikte ekranın üstünden taşıp kırpılmaz.
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.82,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            _Handle(scale: s),
            _SheetHeader(scale: s, work: widget.work),
            const Divider(height: 1, thickness: 1, color: _kDivider),
            Expanded(
              child: StreamBuilder<List<CommentModel>>(
                stream: _commentsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _kGold),
                      ),
                    );
                  }
                  final comments = snapshot.data!;
                  if (comments.isEmpty) {
                    return _EmptyState(scale: s);
                  }
                  return ListView.separated(
                    controller: _scroll,
                    padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 16 * s),
                    itemCount: comments.length,
                    separatorBuilder: (_, _) => SizedBox(height: 18 * s),
                    itemBuilder: (_, i) {
                      final c = comments[i];
                      return _CommentRow(
                        scale: s,
                        comment: c,
                        isMine: c.authorId == myId,
                        onDelete: () =>
                            _controller.deleteComment(widget.work.id, c.id),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1, thickness: 1, color: _kDivider),
            _Composer(
              scale: s,
              controller: _input,
              isSending: _isSending,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sürükleme tutamacı ─────────────────────────────────────────────────────
class _Handle extends StatelessWidget {
  const _Handle({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.only(top: 10 * s, bottom: 4 * s),
      child: Container(
        width: 36 * s,
        height: 4 * s,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(2 * s),
        ),
      ),
    );
  }
}

// ─── Başlık ─────────────────────────────────────────────────────────────────
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.scale, required this.work});
  final double scale;
  final WorkModel work;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.fromLTRB(20 * s, 8 * s, 12 * s, 14 * s),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YORUMLAR',
                    style: _mono(
                        size: 9 * s,
                        weight: FontWeight.w700,
                        color: _kBlack,
                        spacing: 1.5)),
                SizedBox(height: 3 * s),
                Text(
                  '«${work.title}»',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _serif(
                      size: 14 * s, color: _kTaupe, italic: true),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(8 * s),
              child: Icon(Icons.close_rounded, size: 20 * s, color: _kInk),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Boş durum ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mode_comment_outlined,
              size: 28 * s, color: _kMuted.withValues(alpha: 0.6)),
          SizedBox(height: 10 * s),
          Text('HENÜZ YORUM YOK',
              style: _mono(size: 9 * s, color: _kBlack, spacing: 1.5)),
          SizedBox(height: 4 * s),
          Text('İlk yorumu sen yaz',
              style: _serif(size: 13 * s, color: _kTaupe, italic: true)),
        ],
      ),
    );
  }
}

// ─── Tek bir yorum satırı ───────────────────────────────────────────────────
class _CommentRow extends StatelessWidget {
  const _CommentRow({
    required this.scale,
    required this.comment,
    required this.isMine,
    required this.onDelete,
  });

  final double scale;
  final CommentModel comment;
  final bool isMine;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final avatarUrl = (comment.authorAvatar?.isNotEmpty ?? false)
        ? comment.authorAvatar!
        : placeholderAvatarFor(null, comment.authorId);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: buildAvatarImage(
            avatarUrl,
            size: 32 * s,
            placeholder: Container(color: _kMuted.withValues(alpha: 0.2)),
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      comment.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _serif(
                          size: 13 * s,
                          weight: FontWeight.w600,
                          color: _kInk),
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  Text(
                    Formatters.relativeTime(comment.createdAt),
                    style: _mono(size: 8 * s, color: _kBlack, spacing: 0.4),
                  ),
                  if (isMine) ...[
                    SizedBox(width: 8 * s),
                    GestureDetector(
                      onTap: onDelete,
                      behavior: HitTestBehavior.opaque,
                      child: Icon(Icons.close_rounded,
                          size: 14 * s, color: _kTaupe),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 4 * s),
              Text(
                comment.text,
                style: _mono(
                    size: 10 * s, color: _kBlack, height: 1.5, spacing: 0.2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Composer ─────────────────────────────────────────────────────────────
class _Composer extends StatelessWidget {
  const _Composer({
    required this.scale,
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final double scale;
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final me = Get.find<UserController>().currentUser;
    final avatarUrl = (me?.avatarUrl?.isNotEmpty ?? false)
        ? me!.avatarUrl!
        : placeholderAvatarFor(me?.gender, me?.id ?? 'me');

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16 * s, 10 * s, 16 * s, 12 * s),
        child: Row(
          children: [
            ClipOval(
              child: buildAvatarImage(
                avatarUrl,
                size: 32 * s,
                placeholder: Container(color: _kMuted.withValues(alpha: 0.2)),
              ),
            ),
            SizedBox(width: 10 * s),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * s),
                height: 44 * s,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: controller,
                  cursorColor: _kGold,
                  textInputAction: TextInputAction.send,
                  maxLength: 500,
                  style: _mono(size: 10 * s, color: _kBlack, spacing: 0.2, height: 1.2),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    counterText: '',
                    hintText: 'Yorum yaz...',
                    hintStyle: _mono(size: 10 * s, color: _kBlack, spacing: 0.2),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            SizedBox(width: 10 * s),
            GestureDetector(
              onTap: isSending ? null : onSend,
              child: Container(
                width: 44 * s,
                height: 44 * s,
                color: _kGold,
                alignment: Alignment.center,
                child: isSending
                    ? SizedBox(
                        width: 16 * s,
                        height: 16 * s,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(Icons.arrow_upward_rounded,
                        size: 18 * s, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
