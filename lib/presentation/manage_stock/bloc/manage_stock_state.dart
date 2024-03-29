import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:keep/core/domain/models/user_profile_model.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';
import 'package:keep/presentation/profile/data/models/profile_model.dart';
import 'package:location/location.dart';

import '../../order_history/data/models/order_line_model.dart';
import '../data/models/form_model.dart';

part 'manage_stock_state.freezed.dart';

@freezed
class ManageStockState with _$ManageStockState {
  factory ManageStockState(
      {@Default(false) bool isLoading,
      @Default(false) bool isAdding,
      @Default(false) bool hasError,
      String? errorMessage,
      bool? sortOrder,
      String? sortType,
      List<StockModel>? stocksList,
      FormModel? formResponse,
      ProfileModel? user,
      ProfileModel? vendor,
      LocationData? locationData,
      List<OrderLineModel>? orderLineList,
      Box? orderLineBox,
      @Default(false) bool isAdded,
      @Default(false) bool isPdfGenerated,
      UserProfileModel? userProfileModel}) = _ManageStockState;
}
