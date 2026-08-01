import '../utils/turkish_case.dart';

extension StringX on String {
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCaseTr()}${substring(1)}';
  }

  String get initials {
    final trimmed = trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCaseTr();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCaseTr();
  }

  bool get isValidEmail {
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(this);
  }
}
