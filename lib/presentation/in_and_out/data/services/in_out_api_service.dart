import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/http.dart';

part 'in_out_api_service.g.dart';

@RestApi(baseUrl: 'http://166.70.31.151:5000')
abstract class InOutApiService {
  factory InOutApiService(Dio dio, {String baseUrl}) = _InOutApiService;

  @POST('/userBasicLogin.html?useHdrs=true&uid={uid}&pwd={pwd}')
  Future<String> authenticateUser(
      @Path('uid') String uid, @Path('pwd') String pwd);
}
