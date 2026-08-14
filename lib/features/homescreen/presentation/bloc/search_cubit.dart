import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../../../core/constants/dio_helper.dart';
import '../../../../core/constants/api_constant.dart';
import '../../data/models/product_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<ProductEntity> products;
  SearchLoaded(this.products);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    try {
      // Pass the query to the API
      final response = await DioHelper.get(
        path: ApiConstant.getProducts,
        query: {
          'search': query,
        }, // Adjust query parameter based on actual API if needed
      );

      final responseData = response.data;
      List<dynamic> data = [];
      if (responseData is Map) {
        data =
            (responseData['data'] ?? responseData['products'] ?? []) as List? ??
            [];
      } else if (responseData is List) {
        data = responseData;
      }

      List<ProductEntity> products = data
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Fallback: local filtering if backend doesn't filter
      if (products.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        products = products
            .where(
              (p) =>
                  p.title.toLowerCase().contains(lowerQuery) ||
                  p.description.toLowerCase().contains(lowerQuery),
            )
            .toList();
      }

      emit(SearchLoaded(products));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
