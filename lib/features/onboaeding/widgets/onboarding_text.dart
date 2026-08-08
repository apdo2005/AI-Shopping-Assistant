import 'package:flutter/material.dart';

class AppTextStyle {
  AppTextStyle._();

  static const TextStyle titleStyle = TextStyle(
    color: Colors.black,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle descriptionStyle = TextStyle(
    color: Color(0xFF555555),
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}

class OnboardingText extends StatelessWidget {
  const OnboardingText({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyle.titleStyle,
          ),

          const SizedBox(height: 12),

          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyle.descriptionStyle,
          ),
        ],
      ),
    );
  }
}
