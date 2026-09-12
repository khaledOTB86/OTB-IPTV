import 'dart:convert';
import 'package:dio/dio.dart';

class XtreamService {
  final Dio _dio = Dio();

  String serverUrl = '';
  String username = '';
  String password = '';

  void configure(String url, String user, String pass) {
    String cleanUrl = url.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    serverUrl = cleanUrl;
    username = user.trim();
    password = pass.trim();
  }

  Future<Map<String, dynamic>> authenticate() async {
    final url = '$serverUrl/player_api.php?username=$username&password=$password';
    final response = await _dio.get(
      url,
      options: Options(responseType: ResponseType.plain),
    );

    if (response.statusCode == 200) {
      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      if (data is Map) {
        final userInfo = data['user_info'];
        if (userInfo != null && (userInfo['auth'] == 1 || userInfo['status'] == 'Active')) {
          return Map<String, dynamic>.from(data);
        }
      }
    }
    throw Exception('بيانات الدخول غير صحيحة أو السيرفر لا يستجيب');
  }

  Future<List<dynamic>> getLiveCategories() async {
    final url = '$serverUrl/player_api.php?username=$username&password=$password&action=get_live_categories';
    final response = await _dio.get(url, options: Options(responseType: ResponseType.plain));
    final data = jsonDecode(response.data.toString());
    return data is List ? data : [];
  }

  Future<List<dynamic>> getLiveStreams({String? categoryId}) async {
    String url = '$serverUrl/player_api.php?username=$username&password=$password&action=get_live_streams';
    if (categoryId != null && categoryId.isNotEmpty) url += '&category_id=$categoryId';
    final response = await _dio.get(url, options: Options(responseType: ResponseType.plain));
    final data = jsonDecode(response.data.toString());
    return data is List ? data : [];
  }

  Future<List<dynamic>> getVodCategories() async {
    final url = '$serverUrl/player_api.php?username=$username&password=$password&action=get_vod_categories';
    final response = await _dio.get(url, options: Options(responseType: ResponseType.plain));
    final data = jsonDecode(response.data.toString());
    return data is List ? data : [];
  }

  Future<List<dynamic>> getVodStreams({String? categoryId}) async {
    String url = '$serverUrl/player_api.php?username=$username&password=$password&action=get_vod_streams';
    if (categoryId != null && categoryId.isNotEmpty) url += '&category_id=$categoryId';
    final response = await _dio.get(url, options: Options(responseType: ResponseType.plain));
    final data = jsonDecode(response.data.toString());
    return data is List ? data : [];
  }

  Future<List<dynamic>> getSeriesCategories() async {
    final url = '$serverUrl/player_api.php?username=$username&password=$password&action=get_series_categories';
    final response = await _dio.get(url, options: Options(responseType: ResponseType.plain));
    final data = jsonDecode(response.data.toString());
    return data is List ? data : [];
  }

  Future<List<dynamic>> getSeries({String? categoryId}) async {
    String url = '$serverUrl/player_api.php?username=$username&password=$password&action=get_series';
    if (categoryId != null && categoryId.isNotEmpty) url += '&category_id=$categoryId';
    final response = await _dio.get(url, options: Options(responseType: ResponseType.plain));
    final data = jsonDecode(response.data.toString());
    return data is List ? data : [];
  }

  String buildLiveStreamUrl(dynamic streamId) {
    return '$serverUrl/live/$username/$password/$streamId.ts';
  }

  String buildVodStreamUrl(dynamic streamId, dynamic containerExtension) {
    final ext = containerExtension ?? 'mp4';
    return '$serverUrl/movie/$username/$password/$streamId.$ext';
  }
}
