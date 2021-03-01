import 'package:history_adventures/api/app_api.dart';

class MainActions {
  AppAPI _appAPI = AppAPI();

  Future<String> getDataForPage({int index = 0}) async {
    return _appAPI.main.getDataForPage(pageNumber: index);
  }
}
