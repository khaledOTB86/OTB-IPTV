import 'package:dio/dio.dart';

class XtreamService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  String serverUrl = '';
  String username = '';
  String password = '';

  void configure(String url, String user, String pass) {
    serverUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    username = user;
    password = pass;
  }

  Future<Map<String, dynamic>> authenticate() async {
    final url = '$serverUrl/player_api.php?username=$username&password=$password';
    final response = await _dio.get(url);
    if (response.statusCode == 200 && response.data is Map) {
      final userInfo = response.data['user_info'];
      if (userInfo != null && userInfo['auth'] == 1) {
        return Map<String, dynamic>.from(response.data);
      }
    }
    throw Exception('بيانات الدخول غير صحيحة');
  }

  Future<List<dynamic>> getLiveCategories() async {
    final response = await _dio.get('$serverUrl/player_api.php?username=$username&password=$password&action=get_live_categories');
    return response.data is List ? response.data : [];
  }

  Future<List<dynamic>> getLiveStreams({String? categoryId}) async {
    String url = '$serverUrl/player_api.php?username=$username&password=$password&action=get_live_streams';
    if (categoryId != null && categoryId.isNotEmpty) url += '&category_id=$categoryId';
    final response = await _dio.get(url);
    return response.data is List ? response.data : [];
  }

  Future<List<dynamic>> getVodCategories() async {
    final response = await _dio.get('$serverUrl/player_api.php?username=$username&password=$password&action=get_vod_categories');
    return response.data is List ? response.data : [];
  }

  Future<List<dynamic>> getVodStreams({String? categoryId}) async {
    String url = '$serverUrl/player_api.php?username=$username&password=$password&action=get_vod_streams';
    if (categoryId != null && categoryId.isNotEmpty) url += '&category_id=$categoryId';
    final response = await _dio.get(url);
    return response.data is List ? response.data : [];
  }

  Future<List<dynamic>> getSeriesCategories() async {
    final response = await _dio.get('$serverUrl/player_api.php?username=$username&password=$password&action=get_series_categories');
    return response.data is List ? response.data : [];
  }

  Future<List<dynamic>> getSeries({String? categoryId}) async {
    String url = '$serverUrl/player_api.php?username=$username&password=$password&action=get_series';
    if (categoryId != null && categoryId.isNotEmpty) url += '&category_id=$categoryId';
    final response = await _dio.get(url);
    return response.data is List ? response.data : [];
  }

  String buildLiveStreamUrl(dynamic streamId) {
    return '$serverUrl/live/$username/$password/$streamId.ts';
  }

  String buildVodStreamUrl(dynamic streamId, dynamic containerExtension) {
    final ext = containerExtension ?? 'mp4';
    return '$serverUrl/movie/$username/$password/$streamId.$ext';
  }
}
