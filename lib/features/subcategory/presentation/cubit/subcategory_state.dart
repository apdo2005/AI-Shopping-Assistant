part of 'subcategory_cubit.dart';

abstract class SubcategoryState {}

class SubcategoryInitial extends SubcategoryState {}

class SubcategoryLoading extends SubcategoryState {}

class SubcategoryLoaded extends SubcategoryState {
  final List<CategoryGroupEntity> groups;
  SubcategoryLoaded(this.groups);
}

class MealsLoading extends SubcategoryState {}

class MealsLoaded extends SubcategoryState {
  final List<MealEntity> meals;
  MealsLoaded(this.meals);
}

class SubcategoryError extends SubcategoryState {
  final String message;
  SubcategoryError(this.message);
}
