// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manage_stock_api_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _ManageStockApi implements ManageStockApi {
  _ManageStockApi(
    this._dio, {
    this.baseUrl,
  }) {
    baseUrl ??= 'http://166.70.31.151:5000';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<String> getUpc(code) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{
      r'X-RapidAPI-Key': 'd5b294698bmshc32c3dfbb9c1525p1610b9jsn5a7e3413b5e1',
      r'X-RapidAPI-Host': 'product-lookup-by-upc-or-ean.p.rapidapi.com',
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          'https://product-lookup-by-upc-or-ean.p.rapidapi.com/code/$code',
          queryParameters: queryParameters,
          data: _data,
        )
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
