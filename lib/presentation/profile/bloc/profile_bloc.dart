import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:keep/core/data/services/persistence_service.dart';
import 'package:keep/presentation/profile/bloc/profile_state.dart';
import 'package:keep/presentation/profile/data/models/profile_model.dart';
import 'package:keep/presentation/profile/domain/repositories/profile_repository.dart';

class ProfileBloc extends Cubit<ProfileState> {
  ProfileBloc({
    required this.profileRepository,
    required this.persistenceService,
  }) : super(ProfileState());

  final ProfileRepository profileRepository;
  final PersistenceService persistenceService;

  Future<void> getProfile({String? type}) async {
    Box box = await profileRepository.openBox();
    List<ProfileModel> profileList = profileRepository.getProfile(box);
    ProfileModel profileModel = ProfileModel();
    bool isProfileExist = false;
    bool isVendorExist = false;

    for (ProfileModel item in profileList) {
      if (item.type == 'profile' && type == 'profile') {
        profileModel = item;
        isProfileExist = true;
      } else if (item.type == 'vendor' && type == 'vendor') {
        profileModel = item;
        isVendorExist = true;
      }
    }

    emit(state.copyWith(
        isInit: true,
        isProfileButton: isProfileExist,
        isVendorButton: isVendorExist,
        isVendorExisiting: false,
        isProfileExisting: false,
        isUpdated: false,
        isSaved: false,
        profileModel: profileModel));
  }

  Future<void> checkProfile(
      {String? email,
      String? firstname,
      String? lastname,
      String? phone,
      String? address,
      String? type,
      String? orderCode,
      String? company}) async {
    emit(state.copyWith(
      isLoading: false,
      isProfileExisting: false,
      isVendorExisiting: false,
      isUpdated: false,
      isSaved: false,
      isInit: false,
    ));
    Box box = await profileRepository.openBox();
    List<ProfileModel> profileList = profileRepository.getProfile(box);
    bool isExist = false;
    for (ProfileModel item in profileList) {
      if (item.type == 'profile' && type == 'profile') {
        //already has a profile saved
        isExist = true;
        emit(state.copyWith(
          isLoading: false,
          isProfileExisting: true,
        ));
      } else if (item.type == 'vendor' && type == 'vendor') {
        isExist = true;
        //already has a vendor saved
        emit(state.copyWith(
          isLoading: false,
          isVendorExisiting: true,
        ));
      }
    }
    if (!isExist) {
      ProfileModel profile = ProfileModel(
        id: profileList.isNotEmpty
            ? (int.parse(profileList[profileList.length - 1].id ?? '0') + 1)
                .toString()
                .padLeft(5, '0')
            : '00001',
        firstname: firstname,
        lastname: lastname,
        email: email,
        address: address,
        phoneNumber: phone,
        type: type,
        orderCode: orderCode,
        company: company,
      );

      await profileRepository.addProfile(box, profile);
      emit(state.copyWith(isLoading: false, isUpdated: true));
    }
  }

  Future<void> saveProfile({
    String? email,
    String? firstname,
    String? lastname,
    String? phone,
    String? address,
    String? city,
    String? states,
    String? zipCode,
    String? type,
    String? orderCode,
    String? company,
  }) async {
    emit(state.copyWith(
        isLoading: false,
        isProfileExisting: false,
        isVendorExisiting: false,
        isUpdated: false,
        isSaved: false));

    Box box = await profileRepository.openBox();
    List<ProfileModel> profileList = profileRepository.getProfile(box);

    ProfileModel profile = ProfileModel(
      id: profileList.isNotEmpty
          ? (int.parse(profileList[profileList.length - 1].id ?? '0') + 1)
              .toString()
              .padLeft(5, '0')
          : '00001',
      firstname: firstname,
      lastname: lastname,
      email: email,
      address: address,
      city: city,
      state: states,
      zipCode: zipCode,
      phoneNumber: phone,
      type: type,
      orderCode: orderCode,
      company: company,
    );

    await profileRepository.addProfile(box, profile);
    emit(state.copyWith(isLoading: false, isSaved: true));
  }
}
