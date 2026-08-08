import 'package:flutter/material.dart';

import 'onboarding_color.dart';

class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    super.key,
    required this.pageIndex,
    required this.onNextPressed,
    required this.onSkipPressed,
  });

  final int pageIndex;
  final VoidCallback onNextPressed;
  final VoidCallback onSkipPressed;

  @override
  Widget build(BuildContext context) {
    if (pageIndex == 2) {
      return Column(
        children: [
          _buildIndicators(),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 70,
          child: TextButton(
            onPressed: onSkipPressed,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        _buildIndicators(),

        SizedBox(
          width: 70,
          child: TextButton(
            onPressed: onNextPressed,
            child: const Text(
              'Next',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) {
          final bool isActive = pageIndex == index;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 9 : 8,
            height: isActive ? 9 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.primary
                  : Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }
}