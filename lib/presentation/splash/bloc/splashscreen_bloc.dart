import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep/application/domain/models/application_config.dart';
import 'package:keep/core/data/services/persistence_service.dart';
import 'package:keep/core/domain/models/user_profile_model.dart';
import 'package:keep/presentation/splash/bloc/splashscreen_state.dart';

class SplashScreenBloc extends Cubit<SplashScreenState> {
  SplashScreenBloc({this.persistenceService}) : super(SplashScreenState());

  final PersistenceService? persistenceService;

  void loadSplashScreen({ApplicationConfig? config}) async {
    emit(state.copyWith(isLoading: true));

    UserProfileModel? userProfileModel =
        await persistenceService?.userProfile.get();
    String? token = await persistenceService?.dwnToken.get();
    String loginTimestamp =
        await persistenceService?.loginTimestamp.get() ?? '0';
    int currentTimestamp = DateTime.now().microsecondsSinceEpoch;
    bool isExpire =
        currentTimestamp > (int.parse(loginTimestamp) + (43200 * 1000));

    //print('${currentTimestamp} ${int.parse(loginTimestamp) + (43200 * 1000)}');
    await persistenceService?.appConfiguration.set(config?.toJson());

    String? currentApi = await persistenceService?.preferredApi.get();
    if (currentApi?.isEmpty == null) {
      currentApi = config?.apiUrl;
    }
    emit(state.copyWith(apiUrl: currentApi));

    Timer(const Duration(milliseconds: 500), () {
      emit(state.copyWith(isLoading: false));
      if (token == null || isExpire == true) {
        emit(state.copyWith(isAlreadySignedIn: false, apiUrl: currentApi));
      } else {
        emit(state.copyWith(
            userProfileModel: userProfileModel,
            token: token,
            isAlreadySignedIn: true,
            apiUrl: currentApi));
      }
    });
  }
}
