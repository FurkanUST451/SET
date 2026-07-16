import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../widgets/set_bottom_nav.dart';
import 'freelancer_home_controller.dart';
import 'tabs/freelancer_chat_tab.dart';
import 'tabs/freelancer_discover_tab.dart';
import 'tabs/freelancer_job_offers_tab.dart';
import 'tabs/freelancer_profile_tab.dart';
import 'tabs/freelancer_projects_tab.dart';

class FreelancerHomeView extends GetView<FreelancerHomeController> {
  const FreelancerHomeView({super.key});

  static const _tabs = <Widget>[
    FreelancerDiscoverTab(),
    FreelancerJobOffersTab(),
    FreelancerChatTab(),
    FreelancerProjectsTab(),
    FreelancerProfileTab(),
  ];

  static const _navItems = <SetNavItem>[
    SetNavItem(icon: Icons.explore_outlined, label: AppStrings.tabDiscover),
    SetNavItem(icon: Icons.work_outline, label: AppStrings.tabJobOffers),
    SetNavItem(icon: Icons.chat_bubble_outline, label: AppStrings.tabChat),
    SetNavItem(icon: Icons.folder_outlined, label: AppStrings.tabMyProjects),
    SetNavItem(icon: Icons.person_outline, label: AppStrings.tabProfile),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
