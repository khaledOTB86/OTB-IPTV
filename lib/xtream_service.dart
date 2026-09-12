import 'package:dio/dio.dart';

class XtreamService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  String? baseUrl;
  String? username;
  String? password;

  void configure({required String url, required String user, required String pass}) {
    baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    username = user;
    password = pass;
  }

  Future<Map<String, dynamic>> authenticate() async {
    final response = await _dio.get('$baseUrl/player_api.php', queryParameters: {
      'username': username,
      'password': password,
    });
    return response.data;
  }

  Future<List<dynamic>> getLiveCategories() async {
    final response = await _dio.get('$baseUrl/player_api.php', queryParameters: {
      'username': username,
      'password': password,
      'action': 'get_live_categories',
    });
    return response.data is List ? response.data : [];
  }

  Future<List<dynamic>> getLiveStreams({String? categoryId}) async {
    final params = {
      'username': username,
      'password': password,
      'action': 'get_live_streams',
    };
    if (categoryId != null && categoryId.isNotEmpty) {
      params['category_id'] = categoryId;
    }
    final response = await _dio.get('$baseUrl/player_api.php', queryParameters: params);
    return response.data is List ? response.data : [];
  }

  String buildStreamUrl(dynamic streamId, {String extension = 'm3u8'}) {
    return '$baseUrl/live/$username/$password/$streamId.$extension';
  }
}
