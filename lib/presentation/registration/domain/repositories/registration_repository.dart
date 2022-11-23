abstract class RegistrationRepository {
  Future<String> createAccount(
      {required String username, required String password});
}
