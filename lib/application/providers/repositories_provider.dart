import 'package:dio/dio.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/data/services/api_services/actiontrak_api_service.dart';

class RepositoriesProvider {
  static List<SingleChildWidget> provide({
    required Dio dio,
    required String apiUrl,
    required ActionTRAKApiService actionTRAKApiService,
  }) =>
      <SingleChildWidget>[
        /*Provider<SplashRepository>.value(
          value: SplashRepositoryImpl(
            SplashApiService(dio, baseUrl: apiUrl),
          ),
        ),*/
      ];
}
