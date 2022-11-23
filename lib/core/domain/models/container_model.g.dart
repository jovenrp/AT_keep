// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContainerModel _$ContainerModelFromJson(Map<String, dynamic> json) =>
    ContainerModel(
      id: json['id'] as String?,
      parentId: json['parentId'] as String?,
      isActive: json['isActive'] as String?,
      num: json['num'] as String?,
      name: json['name'] as String?,
      code: json['code'] as String?,
      isRoot: json['isRoot'] as String?,
    );

Map<String, dynamic> _$ContainerModelToJson(ContainerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parentId': instance.parentId,
      'isActive': instance.isActive,
      'num': instance.num,
      'name': instance.name,
      'code': instance.code,
      'isRoot': instance.isRoot,
    };
