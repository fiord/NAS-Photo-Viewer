import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:logger/logger.dart';
import 'package:nas_photo_viewer/data/shared_preference/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class HttpRepository {
  late PersistCookieJar _cookieJar;
  String? _nasUrl;
  final List<Cookie> _cookies = [];
  final Dio _dio = Dio();

  HttpRepository();

  Future<void> init() async {
    // Directory appDocDir = await getApplicationDocumentsDirectory();
    // String appDocPath = appDocDir.path;
    // _cookieJar =
    // PersistCookieJar(storage: FileStorage('$appDocPath/.cookies/'));
    _nasUrl ??= await SharedPreference.getString(key: "nasUrl");
  }

  Future<void> setNasUrl(String url) async {
    _nasUrl = url;
    await SharedPreference.setString(key: "nasUrl", value: url);
    await setCookieInfo();
  }

  String getNasUrl() {
    return _nasUrl ?? '';
  }

  Map<String, Map<String, Map<String, SerializableCookie>>> getCookies() {
    return _cookieJar.hostCookies;
  }

  Future<void> setCookieInfo() async {
    // get set-cookie info
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    _cookieJar =
        PersistCookieJar(storage: FileStorage('$appDocPath/.cookies/'));
    // Logger().d('save from response: ${_cookies.toString()}');
    _cookieJar.saveFromResponse(Uri.parse(getNasUrl()), _cookies);
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  Future<void> printCookieInfo() async {
    Logger().d(await _cookieJar.loadForRequest(Uri.parse(getNasUrl())));
  }

  Future<Response> get(String url) async {
    final uri = Uri.parse(url);
    final res = await _dio.getUri(uri,
        options: Options(
          validateStatus: (status) => (status ?? 500) < 500,
        ));
    switch (res.statusCode) {
      case 200:
      case 201:
        return res;
      default:
        throw Exception('status: ${res.statusCode}\n${res.toString()}');
    }
  }

  Future<Response> post(Uri uri, Map<String, dynamic> map) async {
    final res = await _dio.postUri(
      uri,
      data: map,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        followRedirects: false,
        validateStatus: (status) => (status ?? 500) < 500,
      ),
    );
    switch (res.statusCode) {
      case 200:
      case 201:
      case 302:
        return res;
      default:
        throw Exception('status: ${res.statusCode}\n${res.toString()}');
    }
  }

  // Future<http.Response> put(String path, Map<String, dynamic> map) async {
  //   final uri = Uri.parse(API_URL + path);
  //   final res = await http.put(
  //     uri,
  //     headers: await getHeaders(),
  //     body: jsonEncode(map),
  //   );
  //   switch (res.statusCode) {
  //     case 200:
  //     case 201:
  //       return res;
  //     default:
  //       throw Exception('status: ${res.statusCode}\n${res.body}');
  //   }
  // }

  // Future<http.Response> delete(String path) async {
  //   final uri = Uri.parse(API_URL + path);
  //   final res = await http.delete(
  //     uri,
  //     headers: await getHeaders(),
  //   );
  //   switch (res.statusCode) {
  //     case 200:
  //     case 201:
  //       return res;
  //     default:
  //       throw Exception('status: ${res.statusCode}\n${res.body}');
  //   }
  // }
}
