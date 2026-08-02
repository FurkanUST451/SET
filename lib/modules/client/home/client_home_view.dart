import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_navigation.dart';
import '../../../widgets/set_bottom_nav.dart';
import 'client_home_controller.dart';
import 'tabs/client_chat_tab.dart';
import 'tabs/client_discover_tab.dart';
import 'tabs/client_home_tab.dart';
import 'tabs/client_profile_tab.dart';
import 'tabs/client_projects_tab.dart';

class ClientHomeView extends GetView<ClientHomeController> {
  const ClientHomeView({super.key});

  static const _tabs = <Widget>[
    ClientDiscoverTab(),
    ClientChatTab(),
    ClientHomeTab(),
    ClientProjectsTab(),
    ClientProfileTab(),
  ];

  static const _navItems = <SetNavItem>[
    SetNavItem(icon: Icons.explore_outlined, label: AppStrings.tabDiscover),
    SetNavItem(icon: Icons.chat_bubble_outline, label: AppStrings.tabChat),
    SetNavItem(icon: Icons.home_outlined, label: AppStrings.tabHome),
    SetNavItem(
        icon: Icons.folder_outlined, label: AppStrings.tabMyProjects),
    SetNavItem(icon: Icons.person_outline, label: AppStrings.tabProfile),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.handleBackPress()) moveAppToBackground();
      },
      child: Scaffold(
        extendBody: true,
        body: Obx(() => IndexedStack(
              index: controller.currentIndex.value,
              children: _tabs,
            )),
        bottomNavigationBar: Obx(() => SetBottomNav(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changeTab,
              items: _navItems,
            )),
      ),
    );
  }
}
