import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:keep/core/domain/models/errors/actiontrak_api_error.dart';
import 'package:keep/core/domain/models/user_profile_model.dart';

part 'registration_state.freezed.dart';

@freezed
class RegistrationState with _$RegistrationState {
  factory RegistrationState(
      {@Default(false) bool isLoading,
      @Default(false) bool hasError,
      ActionTRAKApiErrorCode? errorCode,
      String? errorMessage,
      @Default(false) bool didFinish,
      @Default(false) bool isInvalid,
      UserProfileModel? userProfileModel}) = _RegistrationState;
}
