import 'package:dio/dio.dart';
import 'package:ai_shopping_assistant/core/constants/api_constant.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getRecommendations();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl(this.dio);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await dio.get(ApiConstant.category); // '/categories'
    final responseData = response.data;

    List<dynamic> data = [];
    if (responseData is Map) {
      data =
          (responseData['data'] ?? responseData['categories'] ?? []) as List? ??
          [];
    } else if (responseData is List) {
      data = responseData;
    }

    return data
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProductModel>> getRecommendations() async {
    final response = await dio.get(
      ApiConstant.recommendations,
    ); // '/meals/recommendations'
    final responseData = response.data;

    List<dynamic> data = [];
    if (responseData is Map) {
      data =
          (responseData['data'] ??
                  responseData['products'] ??
                  responseData['recommendations'] ??
                  [])
              as List? ??
          [];
    } else if (responseData is List) {
      data = responseData;
    }

    return data
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
