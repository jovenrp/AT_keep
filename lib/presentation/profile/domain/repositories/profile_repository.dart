import 'package:hive/hive.dart';
import 'package:keep/presentation/profile/data/models/profile_model.dart';

abstract class ProfileRepository {
  Future<Box> openBox();
  List<ProfileModel> getProfile(Box box);
  Future<void> addProfile(Box box, ProfileModel profileModel);
  Future<void> updateProfile(Box box, int index, ProfileModel profileModel);
  Future<void> deleteProfile(Box box, int index);
}
