import 'onboarding_item.dart';

class UiConstants {
  UiConstants._();

  static const List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      image: 'assets/images/onboarding1.png',
      title: 'Shop Smarter with AI',
      description:
          'Find exactly what you need using natural language. Our AI assistant does the hard work for you.',
    ),
    OnboardingItem(
      image: 'assets/images/onboarding2.png',
      title: 'Discover What You Love',
      description:
          'Explore products that match your style and preferences with smart recommendations.',
    ),
    OnboardingItem(
      image: 'assets/images/onboarding3.jpeg',
      title: 'Your Shopping Assistant',
      description:
          'Get personalized help and make every shopping experience easier and smarter.',
    ),
  ];
}
