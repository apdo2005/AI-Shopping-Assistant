import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'package:ai_shopping_assistant/core/constants/api_constant.dart';
import 'package:ai_shopping_assistant/core/constants/dio_helper.dart';
import 'package:ai_shopping_assistant/features/splash/presentation/splash_screen.dart';
import 'package:ai_shopping_assistant/features/auth/presentation/logic/auth_bloc.dart';
import 'package:ai_shopping_assistant/features/auth/data/repository/auth_repository_impl.dart';
import 'package:ai_shopping_assistant/features/auth/data/datasource/auth_datasource_impl.dart';
// EL main ya pro😎
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  DioHelper.init(
    baseUrl: ApiConstant.baseUrl,
  );

  runApp(
    BlocProvider(
      create: (context) => AuthBloc(
        authRepository: AuthRepositoryImpl(
          remoteDataSource: AuthDatasourceImpl(),
        ),
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}