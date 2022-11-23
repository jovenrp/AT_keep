import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:keep/core/domain/models/user_profile_model.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';

import '../data/models/form_model.dart';

part 'manage_stock_state.freezed.dart';

@freezed
class ManageStockState with _$ManageStockState {
  factory ManageStockState(
      {@Default(false) bool isLoading,
      @Default(false) bool isAdding,
      @Default(false) bool hasError,
      String? errorMessage,
      List<StockModel>? stocksList,
      FormModel? formResponse,
      @Default(false) bool isAdded,
      UserProfileModel? userProfileModel}) = _ManageStockState;
}
