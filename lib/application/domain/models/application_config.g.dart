// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationConfig _$ApplicationConfigFromJson(Map<String, dynamic> json) =>
    ApplicationConfig(
      apiUrl: json['apiUrl'] as String,
      isApiLoggingEnabled: json['isApiLoggingEnabled'] as bool,
      isApiDebuggerEnabled: json['isApiDebuggerEnabled'] as bool,
      isUiDebuggerEnabled: json['isUiDebuggerEnabled'] as bool,
      isProxyEnabled: json['isProxyEnabled'] as bool? ?? false,
      baseContentUrl: json['baseContentUrl'] as String,
      apiKey: json['apiKey'] as String?,
      appVersion: json['appVersion'] as String?,
      buildNumber: json['buildNumber'] as String?,
    );

Map<String, dynamic> _$ApplicationConfigToJson(ApplicationConfig instance) =>
    <String, dynamic>{
      'apiUrl': instance.apiUrl,
      'apiKey': instance.apiKey,
      'isProxyEnabled': instance.isProxyEnabled,
      'isApiLoggingEnabled': instance.isApiLoggingEnabled,
      'isApiDebuggerEnabled': instance.isApiDebuggerEnabled,
      'isUiDebuggerEnabled': instance.isUiDebuggerEnabled,
      'baseContentUrl': instance.baseContentUrl,
      'appVersion': instance.appVersion,
      'buildNumber': instance.buildNumber,
    };
