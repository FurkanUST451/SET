/// Türkçe farkında harf dönüşümleri.
///
/// Dart'ın `String.toUpperCase()` metodu invariant (Unicode varsayılan)
/// casing uygular: "i" → "I". Türkçe'de doğrusu "i" → "İ" ve "ı" → "I"dır.
/// Bu yüzden kullanıcıya görünen hiçbir metinde çıplak `toUpperCase()`
/// kullanılmamalı; bunun yerine [TurkishCase.toUpperCaseTr] çağrılmalıdır.
///
/// Aynı sorun küçültmede de var: "I" → "ı", "İ" → "i" olmalıdır.
extension TurkishCase on String {
  static const int _lowerDottedI = 0x69; // i
  static const int _lowerDotlessI = 0x131; // ı
  static const int _upperDotlessI = 0x49; // I
  static const int _upperDottedI = 0x130; // İ

  /// Türkçe kurallarına göre büyük harfe çevirir (i → İ, ı → I).
  String toUpperCaseTr() {
    if (isEmpty) return this;
    final buffer = StringBuffer();
    for (final rune in runes) {
      if (rune == _lowerDottedI) {
        buffer.write('İ'); // İ
      } else if (rune == _lowerDotlessI) {
        buffer.write('I'); // I
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString().toUpperCase();
  }

  /// Türkçe kurallarına göre küçük harfe çevirir (I → ı, İ → i).
  String toLowerCaseTr() {
    if (isEmpty) return this;
    final buffer = StringBuffer();
    for (final rune in runes) {
      if (rune == _upperDotlessI) {
        buffer.write('ı'); // ı
      } else if (rune == _upperDottedI) {
        buffer.write('i'); // i
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString().toLowerCase();
  }

  /// İlk harfi Türkçe kurallarına göre büyütür.
  String get capitalizedTr {
    if (isEmpty) return this;
    return '${this[0].toUpperCaseTr()}${substring(1)}';
  }
}
