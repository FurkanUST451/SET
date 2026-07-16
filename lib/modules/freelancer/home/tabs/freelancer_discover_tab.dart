import 'package:flutter/material.dart';

import '../../../client/home/tabs/client_discover_tab.dart';

/// Keşfet, hem hizmet alan hem hizmet veren için aynı ortak SET akışıdır
/// (herkesin son işlerini gösteren tek bir vitrin) — bu yüzden aynı
/// ekranı birebir yeniden kullanıyoruz.
class FreelancerDiscoverTab extends StatelessWidget {
  const FreelancerDiscoverTab({super.key});

  @override
  Widget build(BuildContext context) => const ClientDiscoverTab();
}
