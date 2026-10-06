import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import 'history_screen.dart';
import 'prediction_screen.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = const [PredictionScreen(), HistoryScreen()];
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(controller.currentTab.value == 0 ? 'CreditGuard' : 'Prediction History'),
          centerTitle: false,
        ),
        body: IndexedStack(
          index: controller.currentTab.value,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentTab.value,
          onDestinationSelected: controller.changeTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.assessment_outlined),
              selectedIcon: Icon(Icons.assessment),
              label: 'Assess',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
