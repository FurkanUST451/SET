import 'package:flutter/material.dart';

import 'app_fonts.dart';

/// SET tip ölçeği — tamamı [AppFonts] üzerinden beslenir.
///
/// Display katmanı Bricolage Grotesque, gövde/UI katmanı Inter'dir.
/// Renk burada tanımlanmaz; tema `copyWith(color: ...)` ile giydirir.
class AppTextStyles {
  AppTextStyles._();

  // ── Yeni ölçek token'ları (2026-08-31 spec: dev rakam / ekran başlığı / vb.)
  // Bricolage Grotesque ExtraBold katmanı — negatif tracking şart, yoksa
  // başlıklar dağınık durur. Değişken font değil; google_fonts her ağırlık
  // için ayrı statik kesim indirir, bu yüzden sahte-bold riski yok.

  /// Dev rakam — ana sayfa sayaç (07, 03). height 0.88 olmazsa üstte
  /// gereksiz boşluk kalır.
  static TextStyle get counterXL => AppFonts.display(
        fontSize: 104,
        fontWeight: FontWeight.w800,
        height: 0.88,
        letterSpacing: -3,
      );

  /// Ekran başlığı.
  static TextStyle get screenTitle => AppFonts.display(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.05,
        letterSpacing: -0.8,
      );

  /// Bölüm başlığı / isim (proje adı, kişi adı).
  static TextStyle get sectionTitle => AppFonts.display(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.4,
      );

  /// Liste ismi (freelancer satırı).
  static TextStyle get listName => AppFonts.display(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.2,
      );

  /// Rakam (istatistik) — puan, bütçe, süre.
  static TextStyle get statFigure => AppFonts.display(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.0,
        letterSpacing: -0.3,
      );

  /// Liste satırı (tek satırlık) — teslim edilenler.
  static TextStyle get listRow => AppFonts.display(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.2,
      );

  /// Gövde metni — bio, açıklama.
  static TextStyle get bodyText => AppFonts.ui(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  /// Alt satır / meta — grey, isim altı.
  static TextStyle get metaText => AppFonts.ui(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  /// Mikro etiket — UPPERCASE, letterSpacing px cinsinde (0.22em ≈ 2.2px @10px).
  static TextStyle get microLabel => AppFonts.ui(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 2.2,
      );

  /// Filtre / sekme — UPPERCASE.
  static TextStyle get tabLabel => AppFonts.ui(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 1.6,
      );

  // ── Mevcut ölçek (dokunulmadı — set_* widget'ları ve tema bunlara bağlı) ─
  static TextStyle get displayXL => AppFonts.display(
        fontSize: 48,
        fontWeight: FontWeight.w700, // → w800
        height: 1.02,
        letterSpacing: -0.96, // -0.02em
      );

  static TextStyle get displayL => AppFonts.display(
        fontSize: 40,
        fontWeight: FontWeight.w700, // → w800
        height: 1.02,
        letterSpacing: -0.8, // -0.02em
      );

  // ── Screen Title / H1 — Bricolage Grotesque 700 ─────────────────────────
  static TextStyle get heading1 => AppFonts.display(
        fontSize: 32,
        fontWeight: FontWeight.w600, // → w700
        height: 1.05,
        letterSpacing: -0.48, // -0.015em
      );

  static TextStyle get heading2 => AppFonts.display(
        fontSize: 26,
        fontWeight: FontWeight.w600, // → w700
        height: 1.08,
        letterSpacing: -0.39, // -0.015em
      );

  // ── Card / Section Title — Bricolage Grotesque 600 ──────────────────────
  static TextStyle get heading3 => AppFonts.display(
        fontSize: 20,
        fontWeight: FontWeight.w500, // → w600
        height: 1.15,
        letterSpacing: -0.4, // -0.02em
      );

  static TextStyle get cardTitle => AppFonts.display(
        fontSize: 18,
        fontWeight: FontWeight.w500, // → w600
        height: 1.15,
        letterSpacing: -0.36, // -0.02em
      );

  /// Cinematic wordmark — "SET" kilitli, sıkı tracking.
  static TextStyle get wordmark => AppFonts.display(
        fontSize: 36,
        fontWeight: FontWeight.w700, // → w800
        height: 1.0,
        letterSpacing: -1.1,
      );

  /// Onboarding / karşılama ekranlarındaki editoryal hero.
  static TextStyle get editorialDisplay => AppFonts.display(
        fontSize: 52,
        fontWeight: FontWeight.w700, // → w800
        height: 1.02,
        letterSpacing: -1.04, // -0.02em
      );

  // ── Gövde / UI — Inter ──────────────────────────────────────────────────
  /// Lead / alt başlık.
  static TextStyle get lead => AppFonts.ui(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get body1 => AppFonts.ui(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.55,
      );

  static TextStyle get body2 => AppFonts.ui(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get caption => AppFonts.ui(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.45,
        letterSpacing: 0.1,
      );

  static TextStyle get button => AppFonts.ui(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.3, // 0.02em
      );

  /// Eyebrow / label — Inter 600, UPPERCASE, geniş tracking.
  ///
  /// Metin kaynağında zaten büyük harfli değilse `String.toUpperCaseTr()`
  /// kullanılmalı; Dart'ın `toUpperCase()`'i "i" → "I" yaparak Türkçe'de
  /// "İ"yi bozar.
  static TextStyle get eyebrow => AppFonts.ui(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 1.65, // 0.15em
      );
}
