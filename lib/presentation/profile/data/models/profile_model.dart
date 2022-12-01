import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 1)
class ProfileModel {
  ProfileModel({
    this.id,
    this.firstname,
    this.lastname,
    this.email,
    this.phoneNumber,
    this.address,
    this.type,
  });

  @HiveField(0)
  String? id;

  @HiveField(1)
  String? firstname;

  @HiveField(2)
  String? lastname;

  @HiveField(3)
  String? email;

  @HiveField(4)
  String? phoneNumber;

  @HiveField(5)
  String? address;

  @HiveField(6)
  String? type;
}
