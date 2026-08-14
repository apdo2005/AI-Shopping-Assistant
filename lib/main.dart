import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:ai_shopping_assistant/core/constants/api_constant.dart';
import 'package:ai_shopping_assistant/core/constants/dio_helper.dart';
import 'package:ai_shopping_assistant/features/splash/presentation/splash_screen.dart';
import 'package:ai_shopping_assistant/features/auth/presentation/logic/auth_bloc.dart';
import 'package:ai_shopping_assistant/features/auth/data/repository/auth_repository_impl.dart';
import 'package:ai_shopping_assistant/features/auth/data/datasource/auth_datasource_impl.dart';
import 'package:ai_shopping_assistant/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:ai_shopping_assistant/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:ai_shopping_assistant/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:ai_shopping_assistant/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:ai_shopping_assistant/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:ai_shopping_assistant/features/orders/presentation/bloc/orders_cubit.dart';

// EL main ya pro😎
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  DioHelper.init(baseUrl: ApiConstant.baseUrl);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: AuthRepositoryImpl(
              remoteDataSource: AuthDatasourceImpl(),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => OrdersCubit(
            OrdersRepositoryImpl(OrdersRemoteDataSource(DioHelper.dio)),
          )..load(),
        ),
        BlocProvider(
          create: (_) => CartCubit(
            CartRepositoryImpl(CartRemoteDataSourceImpl(DioHelper.dio)),
          )..load(),
        ),
      ],
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
