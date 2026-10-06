import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/credit_input.dart';
import '../models/history_item.dart';
import '../models/prediction_response.dart';
import '../screens/risk_result_screen.dart';
import '../services/api_client.dart';

class HomeController extends GetxController {
  final ApiClient apiClient = ApiClient();

  final currentTab = 0.obs;
  final isLoading = false.obs;
  final isHistoryLoading = false.obs;
  final errorMessage = ''.obs;
  final history = <HistoryItem>[].obs;

  final formKey = GlobalKey<FormState>();

  final creditLimit = TextEditingController(text: '120000');
  final age = TextEditingController(text: '32');
  final currentBill = TextEditingController(text: '90000');
  final previousBill = TextEditingController(text: '85000');
  final latestPayment = TextEditingController(text: '5000');
  final previousPayment = TextEditingController(text: '5000');

  int recentPaymentStatus = 0;
  int previousPaymentStatus = 0;

  @override
  void onClose() {
    for (final controller in [
      creditLimit,
      age,
      currentBill,
      previousBill,
      latestPayment,
      previousPayment,
    ]) {
      controller.dispose();
    }
    super.onClose();
  }

  void loadDemo() {
    final demo = CreditInput.demo();

    creditLimit.text = demo.creditLimit.toStringAsFixed(0);
    age.text = demo.age.toString();
    currentBill.text = demo.currentBillAmount.toStringAsFixed(0);
    previousBill.text = demo.previousBillAmount.toStringAsFixed(0);
    latestPayment.text = demo.latestPaymentAmount.toStringAsFixed(0);
    previousPayment.text = demo.previousPaymentAmount.toStringAsFixed(0);

    recentPaymentStatus = demo.recentPaymentStatus;
    previousPaymentStatus = demo.previousPaymentStatus;

    update();
  }

  Future<void> assessRisk() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final input = CreditInput(
        creditLimit: double.parse(creditLimit.text.trim()),
        age: int.parse(age.text.trim()),
        recentPaymentStatus: recentPaymentStatus,
        previousPaymentStatus: previousPaymentStatus,
        currentBillAmount: double.parse(currentBill.text.trim()),
        previousBillAmount: double.parse(previousBill.text.trim()),
        latestPaymentAmount: double.parse(latestPayment.text.trim()),
        previousPaymentAmount: double.parse(previousPayment.text.trim()),
      );

      final result = await apiClient.predict(input);

      // History failure should never block the result page.
      loadHistory();

      await Get.to(
        () => RiskResultScreen(prediction: result),
        transition: Transition.cupertino,
      );
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadHistory() async {
    isHistoryLoading.value = true;
    try {
      history.assignAll(await apiClient.getHistory());
    } catch (_) {
      // Keep prediction flow available even when history cannot be loaded.
    } finally {
      isHistoryLoading.value = false;
    }
  }

  void changeTab(int index) {
    currentTab.value = index;
    if (index == 1) {
      loadHistory();
    }
  }
}
