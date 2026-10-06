import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HistoryScreen extends GetView<HomeController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isHistoryLoading.value && controller.history.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.history.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.loadHistory,
          child: ListView(
            children: const [
              SizedBox(height: 180),
              Center(child: Text('No predictions yet.')),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadHistory,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.history.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = controller.history[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${(item.defaultProbability * 100).round()}')),
                title: Text('${item.riskBand.toUpperCase()} risk'),
                subtitle: Text('${item.createdAt.toLocal()} • ${item.modelName}'),
                trailing: Icon(
                  item.predictedDefault == 1 ? Icons.warning_amber : Icons.check_circle_outline,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
