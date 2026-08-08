import 'package:flutter/material.dart';
import 'package:ai_shopping_assistant/features/onboaeding/presentation/ui_model/onboarding_item.dart';
import '../../../core/constants/app_size.dart';
import 'onboarding_text.dart';

class OnboardingBody extends StatelessWidget {
  const OnboardingBody({super.key, required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: Center(
            child: Image.asset(
              item.image,
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: AppSize.mdPadding),
        Expanded(
          flex: 3,
          child: OnboardingText(
            title: item.title,
            description: item.description,
          ),
        ),
      ],
    );
  }
}
