import 'package:dio/dio.dart';

class MainAPI {
  Dio _dio = Dio();

  String _pageUrl =
      'https://revolutions.historyadventures.app/new_revolutions/pages/*.html';

  Future<String> getDataForPage({int pageNumber = 0}) async {
    String path = _pageUrl.replaceAll('*', pageNumber.toString());
    Response response = await _dio.get(path);
    return response.data;
  }
}
