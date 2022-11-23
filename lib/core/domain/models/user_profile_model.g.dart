// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      username: json['username'] as String,
      firstname: json['firstname'] as String?,
      middlename: json['middlename'] as String?,
      lastname: json['lastname'] as String?,
      nickname: json['nickname'] as String?,
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'firstname': instance.firstname,
      'middlename': instance.middlename,
      'lastname': instance.lastname,
      'nickname': instance.nickname,
    };
