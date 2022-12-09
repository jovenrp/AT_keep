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
    this.orderCode,
    this.company,
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

  @HiveField(7)
  String? orderCode;

  @HiveField(8)
  String? company;

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'firstname': firstname.toString(),
        'lastname': lastname.toString(),
        'email': email.toString(),
        'phoneNumber': phoneNumber.toString(),
        'address': address.toString(),
        'type': type.toString(),
        'orderCode': orderCode.toString(),
        'company': company.toString(),
      };

  ProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    address = json['address'];
    type = json['type'];
    orderCode = json['orderCode'];
    company = json['company'];
  }
}
