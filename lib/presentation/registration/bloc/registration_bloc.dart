import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:keep/core/data/services/persistence_service.dart';
import 'package:keep/presentation/registration/bloc/registration_state.dart';
import 'package:keep/presentation/registration/domain/repositories/registration_repository.dart';

class RegistrationBloc extends Cubit<RegistrationState> {
  RegistrationBloc({
    required this.registrationRepository,
    required this.persistenceService,
  }) : super(RegistrationState());

  final RegistrationRepository registrationRepository;
  final PersistenceService persistenceService;

  Future<void> init() async {
    /*String? currentApi = await persistenceService.preferredApi.get();
    ApplicationConfig? config = await persistenceService.appConfiguration.get();
    if (currentApi?.isEmpty == null) {
      currentApi = config?.apiUrl;
    }

    emit(state.copyWith(
        isLoading: false,
        hasError: false,
        errorMessage: '',
        isLoggedIn: false,
        apiUrl: currentApi));*/
  }

  Future<void> saveUser({String? username}) async {
    //var path = Directory.current.path;
    await Hive.initFlutter();

    var box = await Hive.openBox('testBox');

    box.put('username', username);

    //print('Name: ${box.get('username')}');
  }
}
