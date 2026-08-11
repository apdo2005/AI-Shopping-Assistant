import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_shopping_assistant/core/constants/app_colors.dart';
import 'package:ai_shopping_assistant/core/constants/dio_helper.dart';
import 'package:ai_shopping_assistant/features/homescreen/data/datasources/home_remote_data_source.dart';
import 'package:ai_shopping_assistant/features/homescreen/data/repositories/home_repository_impl.dart';
import 'package:ai_shopping_assistant/features/homescreen/domain/usecases/get_home_data_usecase.dart';
import 'package:ai_shopping_assistant/features/homescreen/presentation/bloc/home_cubit.dart';
import 'package:ai_shopping_assistant/features/chatbot/presentation/screens/chatbot_screen.dart';
import 'home_content.dart';

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  int _currentIndex = 0;
  final _navKey = GlobalKey<CurvedNavigationBarState>();

  final List<Widget> _screens = [
    const HomeContent(),
    const Center(child: Text('Search Screen')),
    const ChatbotScreen(),
    const Center(child: Text('Cart Screen')),
    const Center(child: Text('Profile Screen')),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(
        GetHomeDataUsecase(
          HomeRepositoryImpl(HomeRemoteDataSourceImpl(DioHelper.dio)),
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: CurvedNavigationBar(
          key: _navKey,
          index: _currentIndex,
          height: 60,
          backgroundColor: Colors.transparent, // شفاف عشان extendBody يشتغل
          color: Colors.white,
          buttonBackgroundColor: AppColors.blue,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 400),
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            // Home
            _buildNavIcon(Icons.home_rounded, 0),
            // Search
            _buildNavIcon(Icons.search_rounded, 1),
            // Chatbot (middle)
            _buildChatbotIcon(2),
            // Cart
            _buildNavIcon(Icons.shopping_cart_rounded, 3),
            // Profile
            _buildNavIcon(Icons.person_rounded, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isActive = _currentIndex == index;
    return Icon(
      icon,
      size: 28,
      color: isActive ? Colors.white : AppColors.blue,
    );
  }

  Widget _buildChatbotIcon(int index) {
    final isActive = _currentIndex == index;
    return Icon(
      Icons.auto_awesome_rounded,
      size: 28,
      color: isActive ? Colors.white : AppColors.blue,
    );
  }
}
