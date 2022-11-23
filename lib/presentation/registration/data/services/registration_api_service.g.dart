// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_api_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _RegistrationApiService implements RegistrationApiService {
  _RegistrationApiService(this._dio, {this.baseUrl}) {
    baseUrl ??= 'http://166.70.31.151:5000';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<String> createAccount(uid, pwd) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'POST', headers: _headers, extra: _extra)
        .compose(
            _dio.options, '/userBasicLogin.html?useHdrs=true&uid=$uid&pwd=$pwd',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

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
