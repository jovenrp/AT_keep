import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:keep/core/domain/models/user_profile_model.dart';

import '../data/models/order_line_model.dart';
import '../data/models/order_model.dart';

part 'order_history_state.freezed.dart';

@freezed
class OrderHistoryState with _$OrderHistoryState {
  factory OrderHistoryState(
      {@Default(false) bool isLoading,
      @Default(false) bool isAdding,
      @Default(false) bool isScreenLoading,
      @Default(false) bool hasError,
      String? errorMessage,
      List<OrderModel>? orderList,
      List<OrderLineModel>? orderLineList,
      UserProfileModel? userProfileModel}) = _OrderHistoryState;
}
