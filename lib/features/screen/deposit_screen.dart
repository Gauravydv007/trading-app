import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/deposit_controller.dart';

class DepositScreen extends StatelessWidget {
  const DepositScreen({super.key});

  static const _bg = Color(0xFF0D0D1A);
  static const _surface = Color(0xFF161627);
  static const _accent = Color(0xFF00E676);

  @override
  Widget build(BuildContext context) {
    final depositCtrl = Get.put(DepositController());
    final amountCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text(
          'Deposit Funds',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter Amount',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: const TextStyle(
                  color: _accent,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.1),
                  fontSize: 32,
                ),
                filled: true,
                fillColor: _surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2A2A45)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2A2A45)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _accent),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick amounts
            Row(
              children: [25, 50, 100, 250].map((amt) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => amountCtrl.text = amt.toString(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2A2A45)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '\$$amt',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2A2A45)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.credit_card, color: Colors.white38, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Powered by Stripe',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                  Spacer(),
                  Icon(Icons.lock_outline, color: _accent, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Secure',
                    style: TextStyle(color: _accent, fontSize: 13),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Obx(
              () => SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: depositCtrl.isLoading.value
                      ? null
                      : () {
                          final amount = double.tryParse(amountCtrl.text) ?? 0;
                          if (amount <= 0) {
                            Get.snackbar('Invalid', 'Enter a valid amount');
                            return;
                          }
                          depositCtrl.processDeposit(amount);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: depositCtrl.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Deposit via Stripe',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
