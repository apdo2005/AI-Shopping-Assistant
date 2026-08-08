part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}
final class HomeLoading extends HomeState {}
final class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
final class HomeLoaded extends HomeState {
    final List<CategoryEntity> categories;
    final List<ProductEntity> products;
    HomeLoaded(this.categories, this.products);
}