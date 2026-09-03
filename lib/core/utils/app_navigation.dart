import 'package:flutter/services.dart';

const _kNavigationChannel = MethodChannel('app.channel/navigation');

// Uygulamayı Home tuşuna basılmış gibi arka plana atar (activity kapanmaz,
// süreç yaşamaya devam eder) — SystemNavigator.pop() aksine state kaybolmaz.
Future<void> moveAppToBackground() async {
  await _kNavigationChannel.invokeMethod('moveTaskToBack');
}
