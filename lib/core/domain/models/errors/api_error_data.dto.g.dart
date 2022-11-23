// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error_data.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiErrorDataDto _$ApiErrorDataDtoFromJson(Map<String, dynamic> json) =>
    ApiErrorDataDto(
      unlockDuration: json['unlockDuration'] as String?,
      timesWrongPin: json['timesWrongPin'] as String?,
      timeRecovery: json['timeRecovery'] as String?,
      timesRemainInputPin: json['timesRemainInputPin'] as String?,
      timeBlock: json['timeBlock'] as String?,
      title: json['title'] as String?,
      timesSendEmail: json['timesSendEmail'] as String?,
      times: json['times'] as String?,
      timesSentEmailVerification: json['timesSentEmailVerification'] as int?,
      maxQuantity: json['maxQuantity'] as int?,
      description: json['description'] as String?,
      dawnToken: json['dwn_token'] as String?,
    );

Map<String, dynamic> _$ApiErrorDataDtoToJson(ApiErrorDataDto instance) =>
    <String, dynamic>{
      'unlockDuration': instance.unlockDuration,
      'timesWrongPin': instance.timesWrongPin,
      'timeRecovery': instance.timeRecovery,
      'timesRemainInputPin': instance.timesRemainInputPin,
      'timeBlock': instance.timeBlock,
      'title': instance.title,
      'timesSendEmail': instance.timesSendEmail,
      'times': instance.times,
      'timesSentEmailVerification': instance.timesSentEmailVerification,
      'maxQuantity': instance.maxQuantity,
      'description': instance.description,
      'dwn_token': instance.dawnToken,
    };
