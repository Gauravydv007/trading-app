import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import '../service/stripe_service.dart';

class DepositController extends GetxController {
  final StripeService _stripeService = StripeService();

  final isLoading = false.obs;
  final depositAmount = 0.0.obs;

  String? get _userId => Get.find<AuthController>().userId;

  Future<bool> processDeposit(double amount) async {
    final uid = _userId;
    if (uid == null) throw Exception('Not authenticated');

    isLoading.value = true;
    try {
      final result = await _stripeService.createPaymentIntent(
        amount: amount,
        currency: 'usd',
        userId: uid,
      );

      final clientSecret = result['clientSecret'] as String;
      final paymentIntentId = result['paymentIntentId'] as String;

      await _stripeService.openStripePaymentSheet(clientSecret: clientSecret);

      await _stripeService.confirmDeposit(
        userId: uid,
        amount: amount,
        paymentIntentId: paymentIntentId,
      );

      Get.snackbar('Success', 'Deposited \$${amount.toStringAsFixed(2)}');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      if (e.toString().contains('cancelled')) {
        Get.snackbar('Cancelled', 'Payment was cancelled');
      } else {
        Get.snackbar('Error', 'Deposit failed: ${e.toString()}');
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
