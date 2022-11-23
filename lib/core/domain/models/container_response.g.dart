// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContainerResponse _$ContainerResponseFromJson(Map<String, dynamic> json) =>
    ContainerResponse(
      error: json['error'] as bool?,
      message: json['message'] as String?,
      getContainers: (json['getContainers'] as List<dynamic>?)
          ?.map((e) => ContainerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ContainerResponseToJson(ContainerResponse instance) =>
    <String, dynamic>{
      'error': instance.error,
      'message': instance.message,
      'getContainers': instance.getContainers,
    };
