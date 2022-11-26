// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actiontrak_api_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _ActionTRAKApiService implements ActionTRAKApiService {
  _ActionTRAKApiService(
    this._dio, {
    this.baseUrl,
  }) {
    baseUrl ??= 'https://api.gomo.ph/';
  }

  final Dio _dio;

  String? baseUrl;

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
