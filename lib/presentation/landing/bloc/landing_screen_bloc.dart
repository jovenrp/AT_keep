import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep/core/data/services/persistence_service.dart';
import 'package:keep/presentation/landing/domain/repositories/landing_repository.dart';

import 'landing_screen_state.dart';

class LandingScreenBloc extends Cubit<LandingScreenState> {
  LandingScreenBloc({
    required this.landingRepository,
    required this.persistenceService,
  }) : super(LandingScreenState());

  final LandingRepository landingRepository;
  final PersistenceService persistenceService;

  Future<void> init() async {}
}
