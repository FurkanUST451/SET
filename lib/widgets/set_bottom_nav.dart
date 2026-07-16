import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Palet (uygulamanın geri kalanıyla aynı) ──────────────────────────────────
const _kNavBg = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kMuted = Color(0xFFB6AD9A);
const _kDivider = Color(0x12000000);

class SetNavItem {
  const SetNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class SetBottomNav extends StatelessWidget {
  const SetBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<SetNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kNavBg,
        border: Border(top: BorderSide(color: _kDivider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: _NavTile(
                    item: items[i],
                    selected: selected,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.selected});

  final SetNavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          item.label.toUpperCase(),
          style: GoogleFonts.spaceMono(
            fontSize: 10.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? _kGold : _kMuted,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: selected ? 18 : 0,
          height: 2,
          decoration: BoxDecoration(
            color: _kGold,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}
