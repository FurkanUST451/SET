import 'dart:io';
import 'package:image/image.dart' as img;

// Arka planlar (alpha yok) → resize + JPEG 90 → .jpg olarak kaydedilir
const _backgrounds = [
  ('assets/images/welcome_pages/welcom_page_bg_1.png',
   'assets/images/welcome_pages/welcom_page_bg_1.jpg', 1080, 90),
  ('assets/images/welcome_pages/welcome_page_bg_2.png',
   'assets/images/welcome_pages/welcome_page_bg_2.jpg', 1080, 90),
  ('assets/images/welcome_pages/welcome_page_bg_3.png',
   'assets/images/welcome_pages/welcome_page_bg_3.jpg', 1080, 90),
  ('assets/images/role_selection/freelancer.png',
   'assets/images/role_selection/freelancer.jpg', 1080, 90),
  ('assets/images/role_selection/project_client.png',
   'assets/images/role_selection/project_client.jpg', 1080, 90),
];

// Maskotlar ve logolar (alpha kanalı olabilir) → resize + PNG → aynı .png
const _alphaPngs = [
  ('assets/images/welcome_pages/welcome_page_mascot_1.png', 1080),
  ('assets/images/welcome_pages/welcome_page_mascot_2.png', 1080),
  ('assets/images/welcome_pages/welcome_page_mascot_3.png', 1080),
  ('assets/images/login_pages/login_apple.png', 128),
  ('assets/images/login_pages/login_email.png', 128),
  ('assets/images/login_pages/login_google.png', 128),
  ('assets/images/login_pages/logo.png', 256),
];

// Tamamen silinecek (hiçbir yerde kullanılmıyor)
const _toDelete = [
  'assets/images/login_pages/login_bg.png',
];

void main() async {
  print('=== SET Asset Compression Tool ===\n');

  // 1. Kullanılmayanları sil
  for (final path in _toDelete) {
    final f = File(path);
    if (await f.exists()) {
      final size = await f.length();
      await f.delete();
      print('DELETED  ${_mb(size)} MB  $path');
    }
  }
  print('');

  int totalOld = 0, totalNew = 0;

  // 2. Arka planlar → JPEG
  for (final (src, dst, maxW, quality) in _backgrounds) {
    final srcFile = File(src);
    if (!await srcFile.exists()) { print('SKIP     $src'); continue; }

    final srcSize = await srcFile.length();
    stdout.write('BG  $src\n    Decoding... ');
    var image = img.decodeImage(await srcFile.readAsBytes());
    if (image == null) { print('ERROR'); continue; }

    if (image.width > maxW) {
      stdout.write('resizing to ${maxW}px... ');
      image = img.copyResize(image, width: maxW,
          interpolation: img.Interpolation.linear);
    }

    stdout.write('encoding JPEG $quality... ');
    final jpgBytes = img.encodeJpg(image, quality: quality);
    await File(dst).writeAsBytes(jpgBytes);
    await srcFile.delete();

    totalOld += srcSize;
    totalNew += jpgBytes.length;
    final pct = ((1 - jpgBytes.length / srcSize) * 100).toStringAsFixed(0);
    print('done  ${_mb(srcSize)} MB → ${_mb(jpgBytes.length)} MB  (-$pct%)');
  }

  // 3. Alpha PNG'ler → resize + PNG
  for (final (src, maxW) in _alphaPngs) {
    final srcFile = File(src);
    if (!await srcFile.exists()) { print('SKIP     $src'); continue; }

    final srcSize = await srcFile.length();
    stdout.write('PNG $src\n    Decoding... ');
    var image = img.decodeImage(await srcFile.readAsBytes());
    if (image == null) { print('ERROR'); continue; }

    if (image.width > maxW) {
      stdout.write('resizing to ${maxW}px... ');
      image = img.copyResize(image, width: maxW,
          interpolation: img.Interpolation.linear);
    }

    stdout.write('encoding PNG... ');
    final pngBytes = img.encodePng(image);
    await srcFile.writeAsBytes(pngBytes);

    totalOld += srcSize;
    totalNew += pngBytes.length;
    final pct = ((1 - pngBytes.length / srcSize) * 100).toStringAsFixed(0);
    print('done  ${_mb(srcSize)} MB → ${_mb(pngBytes.length)} MB  (-$pct%)');
  }

  print('\n=== ÖZET ===');
  print('Önce  : ${_mb(totalOld)} MB');
  print('Sonra : ${_mb(totalNew)} MB');
  if (totalOld > 0) {
    final pct = ((1 - totalNew / totalOld) * 100).toStringAsFixed(0);
    print('Kazanç: ${_mb(totalOld - totalNew)} MB  (-$pct%)');
  }
  print('\nSonraki adım: app_assets.dart içinde bg dosyalarının uzantısını .jpg yap.');
}

String _mb(int b) => (b / 1024 / 1024).toStringAsFixed(2);
