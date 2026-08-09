import 'package:dio/dio.dart';
import '../models/subcategory_model.dart';
import '../models/meal_model.dart';
import '../../domain/entities/subcategory_entity.dart';

abstract class SubcategoryRemoteDataSource {
  Future<List<CategoryGroupEntity>> getGroupedSubcategories();
  Future<List<MealModel>> getMealsBySubcategory(String subcategoryId);
}

class SubcategoryRemoteDataSourceImpl implements SubcategoryRemoteDataSource {
  final Dio dio;
  SubcategoryRemoteDataSourceImpl(this.dio);

  List<dynamic> _extractList(dynamic responseData, List<String> keys) {
    if (responseData is List) return responseData;
    if (responseData is Map) {
      for (final key in keys) {
        if (responseData[key] is List) return responseData[key] as List;
      }
    }
    return [];
  }

  @override
  Future<List<CategoryGroupEntity>> getGroupedSubcategories() async {
    final response = await dio.get('/subcategories');
    final raw = _extractList(response.data, ['data', 'subcategories']);
    final jsonList = raw.cast<Map<String, dynamic>>();
    return groupSubcategoriesByCategory(jsonList);
  }

  @override
  Future<List<MealModel>> getMealsBySubcategory(String subcategoryId) async {
    final response = await dio.get('/subcategories/$subcategoryId/meals');
    final responseData = response.data;
    List<dynamic> data = [];

    if (responseData is Map) {
      // الـ response shape: { data: { meals: [...] } }
      final inner = responseData['data'];
      if (inner is Map && inner['meals'] is List) {
        data = inner['meals'] as List;
      } else if (responseData['meals'] is List) {
        data = responseData['meals'] as List;
      } else {
        data = _extractList(responseData, ['data', 'products']);
      }
    } else if (responseData is List) {
      data = responseData;
    }

    return data
        .map((e) => MealModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
