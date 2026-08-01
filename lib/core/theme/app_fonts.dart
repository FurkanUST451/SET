import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SET tipografi sisteminin tek kaynağı.
///
/// İki aile kullanılır:
///  * [display] → **Bricolage Grotesque** (600–800): hero, ekran başlıkları,
///    kart/bölüm başlıkları. Sıkı optik tracking (≈ -0.02em) ve dar satır
///    yüksekliği (1.02–1.15) ile editoryal bir display sesi verir.
///  * [ui]      → **Inter** (400–600): gövde, açıklama, buton, chip/tab,
///    form alanı, placeholder ve UPPERCASE eyebrow/label'lar.
///
/// Ekran dosyalarındaki yerel `_display` / `_ui` yardımcıları doğrudan bu iki
/// metoda delege eder; böylece aile, ağırlık bandı ve varsayılan tracking tek
/// yerden yönetilir. Renk, boşluk, radius ve layout burada belirlenmez.
///
/// **Asset olarak bundle etmek için:** `.ttf` dosyalarını `assets/fonts/`
/// altına koyup pubspec.yaml'a `fonts:` bölümünü ekleyin (Bricolage 600/700/800,
/// Inter 400/500/600), sonra aşağıdaki iki gövdeyi
/// `TextStyle(fontFamily: 'BricolageGrotesque' | 'Inter', ...)` ile değiştirin.
/// Uygulamanın tamamı bu iki metottan beslendiği için başka hiçbir dosyaya
/// dokunmak gerekmez; bu, google_fonts'un runtime indirme/flash/offline
/// davranışını da ortadan kaldırır.
class AppFonts {
  AppFonts._();

  /// Display ailesinin varsayılan satır yüksekliği (spec: 1.02–1.15).
  static const double _displayHeight = 1.05;

  /// Display için optik tracking oranı (spec: ≈ -0.02em).
  static const double _displayTracking = -0.02;

  /// Bricolage Grotesque — display / başlık ailesi.
  ///
  /// Ağırlık, çağrı yerindeki niyet korunarak 600–800 bandına taşınır:
  /// eski serif ailesi ince kesildiği için birebir aktarım Bricolage'da fazla
  /// hafif kalırdı. w400/w500 → 600, w600 → 700, w700+ → 800.
  static TextStyle display({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    List<Shadow>? shadows,
  }) {
    final size = fontSize ?? 16;
    return GoogleFonts.bricolageGrotesque(
      fontSize: fontSize,
      fontWeight: displayWeight(fontWeight),
      color: color,
      height: height ?? _displayHeight,
      letterSpacing: letterSpacing ?? size * _displayTracking,
      fontStyle: fontStyle,
      decoration: decoration,
      shadows: shadows,
    );
  }

  /// Inter — gövde / UI ailesi.
  ///
  /// Ağırlık 400–600 bandına sabitlenir (spec); satır yüksekliği ve tracking
  /// verilmezse font kendi metriklerini kullanır, böylece mevcut yerleşim
  /// bozulmaz.
  static TextStyle ui({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: uiWeight(fontWeight),
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      decoration: decoration,
      shadows: shadows,
    );
  }

  /// Çağrı yerinin ağırlığını Bricolage'ın 600–800 display bandına taşır.
  static FontWeight displayWeight(FontWeight? weight) {
    if (weight == null) return FontWeight.w600;
    if (weight.value <= FontWeight.w500.value) return FontWeight.w600;
    if (weight.value == FontWeight.w600.value) return FontWeight.w700;
    return FontWeight.w800;
  }

  /// Çağrı yerinin ağırlığını Inter'in 400–600 UI bandına sıkıştırır.
  static FontWeight uiWeight(FontWeight? weight) {
    if (weight == null) return FontWeight.w400;
    return weight.value > FontWeight.w600.value ? FontWeight.w600 : weight;
  }
}
