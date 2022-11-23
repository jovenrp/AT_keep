import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:keep/core/domain/models/errors/actiontrak_api_error.dart';
import 'package:keep/core/domain/models/user_profile_model.dart';

import '../data/models/in_out_item.dart';

part 'in_out_state.freezed.dart';

@freezed
class InOutState with _$InOutState {
  factory InOutState(
      {@Default(false) bool isLoading,
      @Default(false) bool hasError,
      ActionTRAKApiErrorCode? errorCode,
      String? errorMessage,
      List<InOutItem>? inOutItem,
      @Default(false) bool didFinish,
      @Default(false) bool isInvalid,
      UserProfileModel? userProfileModel}) = _InOutState;
}
