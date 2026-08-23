import 'package:get/get.dart';

import 'auth_controller.dart';
import '../model/transaction_model.dart';
import '../service/transaction_service.dart';

class TransactionController extends GetxController {
  final TransactionService _transactionService = TransactionService();

  final transactions = <TransactionModel>[].obs;

  String? get _userId => Get.find<AuthController>().userId;

  @override
  void onInit() {
    super.onInit();
    ever(
      Get.find<AuthController>().currentUser,
      (_) => _listenToTransactions(),
    );
    _listenToTransactions();
  }

  void _listenToTransactions() {
    final uid = _userId;
    if (uid == null) return;
    transactions.bindStream(_transactionService.transactionsStream(uid));
  }
}
