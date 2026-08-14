import 'package:flutter/material.dart';
import 'package:ai_shopping_assistant/core/constants/app_colors.dart';

class CheckoutPreparationScreen extends StatelessWidget {
  const CheckoutPreparationScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFFBFF),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFFBFF),
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: const Text('Checkout', style: TextStyle(color: AppColors.indigo)),
    ),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 54, color: AppColors.indigo),
            SizedBox(height: 16),
            Text(
              'Checkout is being prepared',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'A checkout API has not been provided yet, so no order has been created.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    ),
  );
}
