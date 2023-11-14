import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/http.dart';

part 'manage_stock_api_service.g.dart';

@RestApi(baseUrl: 'http://166.70.31.151:5000')
abstract class ManageStockApi {
  factory ManageStockApi(Dio dio, {String baseUrl}) = _ManageStockApi;

  @GET('https://product-lookup-by-upc-or-ean.p.rapidapi.com/code/{code}')
  @Headers({
    'X-RapidAPI-Key': 'd5b294698bmshc32c3dfbb9c1525p1610b9jsn5a7e3413b5e1',
    'X-RapidAPI-Host': 'product-lookup-by-upc-or-ean.p.rapidapi.com',
  })
  Future<String> getUpc(@Path('code') String code);
}
