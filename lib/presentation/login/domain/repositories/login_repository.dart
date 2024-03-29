import 'package:keep/presentation/login/data/models/login_response_model.dart';

abstract class LoginRepository {
  Future<LoginResponseModel> login(
      {required String username, required String password});
}
