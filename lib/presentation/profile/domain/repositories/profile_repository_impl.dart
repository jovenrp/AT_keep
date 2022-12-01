import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:keep/presentation/profile/data/models/profile_model.dart';
import 'package:keep/presentation/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl();

  String boxName = 'profile_box';

  @override
  Future<Box> openBox() async {
    Box box = await Hive.openBox<ProfileModel>(boxName);
    return box;
  }

  @override
  List<ProfileModel> getProfile(Box box) {
    return box.values.toList() as List<ProfileModel>;
  }

  @override
  Future<void> addProfile(Box box, ProfileModel profileModel) async {
    await box.put(profileModel.id, profileModel);
    //await box.clear();
  }

  @override
  Future<void> deleteProfile(Box box, int index) async {
    await box.deleteAt(index);
  }

  @override
  Future<void> updateProfile(
      Box box, int index, ProfileModel profileModel) async {
    await box.putAt(index, profileModel);
  }
}
