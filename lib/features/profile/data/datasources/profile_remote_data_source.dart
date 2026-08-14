import 'package:dio/dio.dart';

import 'package:ai_shopping_assistant/core/constants/api_constant.dart';
import 'package:ai_shopping_assistant/core/error/exceptions.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../models/profile_model.dart';
import '../models/profile_update_result_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<String> uploadProfileImage(String filePath);
  Future<ProfileUpdateResultModel> updateProfileInfo(UpdateProfileParams params);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl(this.dio);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await dio.get(ApiConstant.getProfile);
      final statusCode = response.statusCode ?? 500;
      final body = response.data;

      if (statusCode < 200 || statusCode >= 300 ||
          body is! Map || body['success'] != true) {
        throw _profileException(response);
      }

      final data = body['data'];
      if (data is! Map) {
        throw ServerException('The profile response did not include profile data.');
      }

      return ProfileModel.fromJson(Map<String, dynamic>.from(data));
    } on AppException {
      rethrow;
    } on DioException catch (error) {
      throw NetworkException(_dioMessage(error));
    } catch (_) {
      throw ServerException('Unable to load your profile. Please try again.');
    }
  }

  @override
  Future<String> uploadProfileImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        ApiConstant.profileImageMultipartField: await MultipartFile.fromFile(filePath),
      });
      final response = await dio.post(ApiConstant.updateProfileImage, data: formData);
      final body = response.data;
      if ((response.statusCode ?? 500) < 200 ||
          (response.statusCode ?? 500) >= 300 ||
          body is! Map ||
          body['success'] != true) {
        throw _profileException(response);
      }
      final data = body['data'];
      final url = data is Map ? data['profile_image_url']?.toString() : null;
      if (url == null || url.isEmpty) {
        throw ServerException('The image upload response did not include an image URL.');
      }
      return url;
    } on AppException {
      rethrow;
    } on DioException catch (error) {
      throw NetworkException(_dioMessage(error));
    } catch (_) {
      throw ServerException('Unable to upload the profile image. Please try again.');
    }
  }

  @override
  Future<ProfileUpdateResultModel> updateProfileInfo(UpdateProfileParams params) async {
    try {
      final fields = <String, dynamic>{
        'username': params.username,
        'firstname': params.firstName,
        'lastname': params.lastName,
        'email': params.email,
        'phone': params.phone,
        'country_code': params.countryCode,
      };
      final language = params.preferredLanguage;
      if (language != null && language.isNotEmpty) {
        fields['preferred_languages[0]'] = language;
      }

      final response = await dio.put(
        ApiConstant.updateProfileInfo,
        data: fields,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final statusCode = response.statusCode ?? 500;
      final body = response.data;

      if (statusCode < 200 || statusCode >= 300 ||
          body is! Map || body['success'] != true) {
        throw _profileException(response);
      }

      final data = body['data'];
      if (data is! Map) {
        throw ServerException('The profile update response did not include profile data.');
      }

      return ProfileUpdateResultModel.fromJson(Map<String, dynamic>.from(data));
    } on AppException {
      rethrow;
    } on DioException catch (error) {
      throw NetworkException(_dioMessage(error));
    } catch (_) {
      throw ServerException('Unable to update your profile. Please try again.');
    }
  }
}

AppException _profileException(Response response) {
  final message = _message(response.data);
  if (response.statusCode == 401) {
    return AuthException(message ?? 'Your session has expired. Please sign in again.');
  }
  if (response.statusCode == 422) {
    return ValidationException(message ?? 'The profile request could not be processed.');
  }
  return ServerException(message ?? 'Unable to load your profile. Please try again.');
}

String _dioMessage(DioException error) =>
    _message(error.response?.data) ?? 'Check your connection and try again.';

String? _message(dynamic data) =>
    data is Map && data['message'] != null ? data['message'].toString() : null;
