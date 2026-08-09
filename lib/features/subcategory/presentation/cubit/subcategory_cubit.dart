import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/subcategory_remote_datasource.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/entities/subcategory_entity.dart';

part 'subcategory_state.dart';

class SubcategoryCubit extends Cubit<SubcategoryState> {
  final SubcategoryRemoteDataSource dataSource;

  SubcategoryCubit(this.dataSource) : super(SubcategoryInitial());

  Future<void> fetchGroupedSubcategories() async {
    emit(SubcategoryLoading());
    try {
      final groups = await dataSource.getGroupedSubcategories();
      emit(SubcategoryLoaded(groups));
    } catch (e) {
      emit(SubcategoryError(e.toString()));
    }
  }

  Future<void> fetchMeals(String subcategoryId) async {
    emit(MealsLoading());
    try {
      final meals = await dataSource.getMealsBySubcategory(subcategoryId);
      emit(MealsLoaded(meals));
    } catch (e) {
      emit(SubcategoryError(e.toString()));
    }
  }
}
