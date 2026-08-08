import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_shopping_assistant/core/constants/app_size.dart';
import '../ui_model/ui_constant.dart';
import 'package:ai_shopping_assistant/features/onboaeding/widgets/onboarding_body.dart';
import 'package:ai_shopping_assistant/features/onboaeding/widgets/onboarding_footer.dart';
import 'package:ai_shopping_assistant/features/auth/presentation/screens/login_screen.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  int _pageIndex = 0;
  final PageController _pageController = PageController();

  Future<void> finishOnboarding() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool('seenOnboarding', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSize.mdPadding,
            vertical: 12,
          ),

          child: Column(
            children: [
              const Text(
                'AURA SHOP',
                style: TextStyle(
                  color: Color(0xFF0757B8),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: UiConstants.onboardingItems.length,
                  physics: const PageScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _pageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return OnboardingBody(
                      item: UiConstants.onboardingItems[index],
                    );
                  },
                ),
              ),
              OnboardingFooter(
                pageIndex: _pageIndex,
                onSkipPressed: finishOnboarding,
                onNextPressed: () {
                  if (_pageIndex ==
                      UiConstants.onboardingItems.length - 1) {
                    finishOnboarding();

                  } else {
                    _pageController.nextPage(
                      duration: const Duration(
                        milliseconds: 300,
                      ),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}