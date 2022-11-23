import 'package:keep/presentation/registration/domain/repositories/registration_repository.dart';

class RegistrationRepoistoryImpl implements RegistrationRepository {
  RegistrationRepoistoryImpl();

  @override
  Future<String> createAccount(
      {required String username, required String password}) async {
    return '';
  }
}
