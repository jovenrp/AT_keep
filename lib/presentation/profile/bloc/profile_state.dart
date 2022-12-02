import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:keep/core/domain/models/user_profile_model.dart';

import '../data/models/profile_model.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  factory ProfileState(
      {@Default(false) bool isLoading,
      @Default(false) bool hasError,
      String? errorMessage,
      @Default(false) bool isProfileExisting,
      @Default(false) bool isProfileButton,
      @Default(false) bool isVendorExisiting,
      @Default(false) bool isVendorButton,
      @Default(false) bool isSaved,
      @Default(false) bool isUpdated,
      @Default(false) bool isInit,
      ProfileModel? profileModel,
      UserProfileModel? userProfileModel}) = _ProfileState;
}
