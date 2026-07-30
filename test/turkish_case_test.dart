import 'package:flutter_test/flutter_test.dart';
import 'package:setdeneme1/core/utils/turkish_case.dart';

void main() {
  test('Türkçe büyük harf: i → İ, ı → I', () {
    expect('istanbul'.toUpperCaseTr(), 'İSTANBUL');
    expect('ışık'.toUpperCaseTr(), 'IŞIK');
    expect('video çekim'.toUpperCaseTr(), 'VİDEO ÇEKİM');
    expect('ses tasarımı'.toUpperCaseTr(), 'SES TASARIMI');
    expect('projelerim'.toUpperCaseTr(), 'PROJELERİM');
    expect('ğüşiöç'.toUpperCaseTr(), 'ĞÜŞİÖÇ');
    expect(''.toUpperCaseTr(), '');
  });

  test('Türkçe küçük harf: I → ı, İ → i', () {
    expect('ISIK'.toLowerCaseTr(), 'ısık');
    expect('İSTANBUL'.toLowerCaseTr(), 'istanbul');
  });

  test('capitalizedTr', () {
    expect('istanbul'.capitalizedTr, 'İstanbul');
  });
}
