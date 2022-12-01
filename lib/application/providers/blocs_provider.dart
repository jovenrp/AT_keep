import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep/presentation/landing/bloc/landing_screen_bloc.dart';
import 'package:keep/presentation/landing/domain/repositories/landing_repository_impl.dart';
import 'package:keep/presentation/profile/domain/repositories/profile_repository_impl.dart';
import 'package:keep/presentation/registration/bloc/registration_bloc.dart';
import 'package:keep/presentation/registration/domain/repositories/registration_repository_impl.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/data/services/persistence_service.dart';
import '../../presentation/login/bloc/loginscreen_bloc.dart';
import '../../presentation/login/data/services/login_api_service.dart';
import '../../presentation/login/domain/repositories/login_repository_impl.dart';
import '../../presentation/manage_stock/bloc/manage_stock_bloc.dart';
import '../../presentation/profile/bloc/profile_bloc.dart';
import '../../presentation/splash/bloc/splashscreen_bloc.dart';
import '../domain/bloc/application_bloc.dart';
import '../domain/repositories/base_storage_repository_impl.dart';

class BlocsProvider {
  static List<SingleChildWidget> provide({
    required Dio dio,
    required PersistenceService persistenceService,
    required String apiUrl,
    required ApplicationBloc appBloc,
    required GlobalKey<NavigatorState> navigatorKey,
  }) =>
      <SingleChildWidget>[
        BlocProvider<ApplicationBloc>(
          create: (_) => ApplicationBloc(),
        ),
        BlocProvider<SplashScreenBloc>(
          create: (_) =>
              SplashScreenBloc(persistenceService: persistenceService),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(
              profileRepository: ProfileRepositoryImpl(),
              persistenceService: persistenceService),
        ),
        BlocProvider<LandingScreenBloc>(
          create: (_) => LandingScreenBloc(
              landingRepository: LandingRepositoryImpl(),
              persistenceService: persistenceService),
        ),
        BlocProvider<ManageStockBloc>(
          create: (_) => ManageStockBloc(
              baseStorageRepository: BaseStorageRepositoryImpl(),
              persistenceService: persistenceService),
        ),
        BlocProvider<RegistrationBloc>(
          create: (_) => RegistrationBloc(
              registrationRepository: RegistrationRepoistoryImpl(),
              persistenceService: persistenceService),
        ),
      ];
}
