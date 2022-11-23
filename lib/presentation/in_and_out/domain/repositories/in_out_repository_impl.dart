import 'package:keep/application/application.dart';
import 'package:keep/presentation/in_and_out/data/services/in_out_api_service.dart';

import 'in_out_repository.dart';

class InOutRepositoryImpl implements InOutRepository {
  InOutRepositoryImpl(this._apiService);

  final InOutApiService _apiService;

  @override
  Future<String> login(
      {required String username, required String password}) async {
    try {
      String token = await _apiService.authenticateUser(
        username,
        password,
      );

      //return LoginResponseModel(token: token, isError: false);
      return token;
    } catch (_) {
      logger.e(_);
      //Todo Create a proper way to handle login error
      return '';
      /*return const LoginResponseModel(
          isError: true,
          errorMessage: 'Wrong username or password entered.',
          token: null);*/
    }
  }
}
