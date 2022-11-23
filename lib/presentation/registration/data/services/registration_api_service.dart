import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/http.dart';

part 'registration_api_service.g.dart';

@RestApi(baseUrl: 'http://166.70.31.151:5000')
abstract class RegistrationApiService {
  factory RegistrationApiService(Dio dio, {String baseUrl}) =
      _RegistrationApiService;

  @POST('/userBasicLogin.html?useHdrs=true&uid={uid}&pwd={pwd}')
  Future<String> createAccount(
      @Path('uid') String uid, @Path('pwd') String pwd);
}
