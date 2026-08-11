import 'package:ai_shopping_assistant/features/homescreen/domain/usecases/get_home_data_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetHomeDataUsecase getHomeDataUsecase;
  HomeCubit(this.getHomeDataUsecase) : super(HomeInitial());
  void fetchHomeData() async {
    emit(HomeLoading());
    final result = await getHomeDataUsecase.excute();
    result.fold(
      (error) {
        emit(HomeError(error));
      },
      (data) {
        emit(HomeLoaded(data['categories'], data['products']));
      },
    );
  }
}
