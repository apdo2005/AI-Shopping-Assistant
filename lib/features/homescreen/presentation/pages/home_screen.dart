import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_shopping_assistant/core/constants/dio_helper.dart';
import 'package:ai_shopping_assistant/features/homescreen/data/datasources/home_remote_data_source.dart';
import 'package:ai_shopping_assistant/features/homescreen/data/repositories/home_repository_impl.dart';
import 'package:ai_shopping_assistant/features/homescreen/domain/usecases/get_home_data_usecase.dart';
import 'package:ai_shopping_assistant/features/homescreen/presentation/bloc/home_cubit.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'home_content.dart';

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const Center(child: Text('Search Screen')),
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
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}
