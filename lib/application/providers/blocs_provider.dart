import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep/application/domain/repositories/base_storage_repository.dart';
import 'package:keep/presentation/in_and_out/bloc/in_out_bloc.dart';
import 'package:keep/presentation/in_and_out/data/services/in_out_api_service.dart';
import 'package:keep/presentation/in_and_out/domain/repositories/in_out_repository_impl.dart';
import 'package:keep/presentation/landing/bloc/landing_screen_bloc.dart';
import 'package:keep/presentation/landing/domain/repositories/landing_repository_impl.dart';
import 'package:keep/presentation/manage_stock/domain/repository/repositories/manage_stock_repository_impl.dart';
import 'package:keep/presentation/registration/bloc/registration_bloc.dart';
import 'package:keep/presentation/registration/data/services/registration_api_service.dart';
import 'package:keep/presentation/registration/domain/repositories/registration_repository_impl.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/data/services/persistence_service.dart';
import '../../presentation/login/bloc/loginscreen_bloc.dart';
import '../../presentation/login/data/services/login_api_service.dart';
import '../../presentation/login/domain/repositories/login_repository_impl.dart';
import '../../presentation/manage_stock/bloc/manage_stock_bloc.dart';
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
        BlocProvider<LoginScreenBloc>(
          create: (_) => LoginScreenBloc(
              loginRepository: LoginRepositoryImpl(
                LoginApiService(dio, baseUrl: apiUrl),
              ),
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
              manageStockRepository: ManageStockRepoistoryImpl(),
              persistenceService: persistenceService),
        ),
        BlocProvider<RegistrationBloc>(
          create: (_) => RegistrationBloc(
              registrationRepository: RegistrationRepoistoryImpl(),
              persistenceService: persistenceService),
        ),
        BlocProvider<InOutBloc>(
          create: (_) => InOutBloc(
              inOutRepository: InOutRepositoryImpl(
                InOutApiService(dio, baseUrl: apiUrl),
              ),
              persistenceService: persistenceService),
        ),
        /*BlocProvider<ForgotPasswordBloc>(
          create: (_) =>
              ForgotPasswordBloc(persistenceService: persistenceService),
        ),
        BlocProvider<DashboardScreenBloc>(
          create: (_) =>
              DashboardScreenBloc(persistenceService: persistenceService),
        ),
        BlocProvider<SettingsScreenBloc>(
          create: (_) =>
              SettingsScreenBloc(persistenceService: persistenceService),
        ),
        BlocProvider<PickTicketsBloc>(
          create: (_) => PickTicketsBloc(
              pickTicketsRepository: PickTicketsRepositoryImpl(
                  PickTicketsApiService(dio, baseUrl: apiUrl)),
              persistenceService: persistenceService),
        ),
        BlocProvider<PickTicketDetailsBloc>(
          create: (_) => PickTicketDetailsBloc(
              pickTicketDetailsRepository: PickTicketDetailsRepositoryImpl(
                  PickTicketDetailsApiService(dio, baseUrl: apiUrl)),
              persistenceService: persistenceService),
        ),
        BlocProvider<SkuDetailsBloc>(
          create: (_) => SkuDetailsBloc(
              pickTicketDetailsRepository: PickTicketDetailsRepositoryImpl(
                  PickTicketDetailsApiService(dio, baseUrl: apiUrl)),
              persistenceService: persistenceService),
        ),
        BlocProvider<LocationMapperBloc>(
          create: (_) => LocationMapperBloc(
              locationMapperRepository: LocationMapperRepositoryImpl(
                  LocationMapperApiService(dio, baseUrl: apiUrl)),
              persistenceService: persistenceService),
        ),
        BlocProvider<ParentLocationBloc>(
          create: (_) => ParentLocationBloc(
              locationMapperRepository: LocationMapperRepositoryImpl(
                  LocationMapperApiService(dio, baseUrl: apiUrl)),
              persistenceService: persistenceService),
        ),
        BlocProvider<CountTicketsBloc>(
          create: (_) => CountTicketsBloc(
              countTicketsRepository: CountTicketsRepositoryImpl(
                  CountTicketsApiService(dio, baseUrl: apiUrl)),
              persistenceService: persistenceService),
        ),
        BlocProvider<CountTicketDetailsBloc>(
          create: (_) => CountTicketDetailsBloc(
              countTicketDetailsRepository: CountTicketDetailsRepositoryImpl(
                  CountTicketDetailsApiService(dio, baseUrl: apiUrl)),
              persistenceService: persistenceService),
        ),
        BlocProvider<CountTicketSkusBloc>(
          create: (_) => CountTicketSkusBloc(
              countTicketSkusRepository: CountTicketSkusRepositoryImpl(
                  CountTicketSkusApiService(dio, baseUrl: apiUrl)),
              persistenceService: persistenceService),
        ),
        BlocProvider<ItemLookupBloc>(
          create: (_) => ItemLookupBloc(
              itemLookupRepository: ItemLookupRepositoryImpl(
                  ItemLookupApiService(dio, baseUrl: apiUrl)),
              persistenceService: persistenceService),
        ),
        BlocProvider<StockAdjustBloc>(
          create: (_) => StockAdjustBloc(
              stockAdjustRepository: StockAdjustRepositoryImpl(
                  StockAdjustApiService(dio, baseUrl: apiUrl)),
              itemLookupRepository: ItemLookupRepositoryImpl(
                  ItemLookupApiService(dio, baseUrl: apiUrl)),
              persistenceService: persistenceService),
        ),
        BlocProvider<ContainerMoveBloc>(
          create: (_) => ContainerMoveBloc(
              containerMoveRepository: ContainerMoveRepositoryImpl(
                  ContainerMoveApiService(dio, baseUrl: apiUrl)),
              persistenceService: persistenceService),
        ),
        BlocProvider<ReceiveTicketsBloc>(
          create: (_) => ReceiveTicketsBloc(
              receiveTicketsRepository: ReceiveTicketsRepositoryImpl(
                  ReceiveTicketsApiService(dio, baseUrl: apiUrl)),
              persistenceService: persistenceService),
        ),
        BlocProvider<ReceiveTicketDetailsBloc>(
          create: (_) => ReceiveTicketDetailsBloc(
              receiveTicketDetailsRepository:
                  ReceiveTicketDetailsRepositoryImpl(
                      ReceiveTicketDetailsApiService(dio, baseUrl: apiUrl)),
              persistenceService: persistenceService),
        ),*/
      ];
}
