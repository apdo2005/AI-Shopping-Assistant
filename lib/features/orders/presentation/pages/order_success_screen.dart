import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/order_entity.dart';
import 'package:ai_shopping_assistant/features/homescreen/presentation/pages/home_screen.dart';
import 'order_details_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderEntity order;
  const OrderSuccessScreen({super.key, required this.order});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfffaf9ff),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(
                  color: Color(0xffe0f5eb),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 45,
                  color: Color(0xff159b63),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Order placed!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                order.number.isEmpty
                    ? 'We’re preparing your order.'
                    : 'Order #${order.number} is being prepared.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff89859c),
                ),
              ),
              const SizedBox(height: 26),
              FilledButton(
                onPressed: () {
                  if (order.id != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsScreen(
                          orderId: order.id!,
                          initial: order,
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainWrapperScreen(initialIndex: 1),
                    ),
                    (_) => false,
                  );
                },
                child: Text(
                  order.id == null ? 'View Orders' : 'View Order Details',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
