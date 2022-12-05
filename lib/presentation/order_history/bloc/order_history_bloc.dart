import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:keep/presentation/manage_stock/data/models/order_model.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';
import 'package:keep/presentation/order_history/bloc/order_history_state.dart';

import '../../manage_stock/data/models/order_line_model.dart';
import '../domain/repositories/order_line_repository.dart';
import '../domain/repositories/order_repository.dart';
import '../../manage_stock/domain/repositories/stock_order_repository.dart';

class OrderHistoryBloc extends Cubit<OrderHistoryState> {
  OrderHistoryBloc({
    required this.stockOrderRepository,
    required this.orderRepository,
    required this.orderLineRepository,
  }) : super(OrderHistoryState());

  final StockOrderRepository stockOrderRepository;
  final OrderLineRepository orderLineRepository;
  final OrderRepository orderRepository;

  Future<void> getOrders() async {
    emit(
      state.copyWith(
        isLoading: true,
      ),
    );

    Box box = await orderRepository.openBox();
    List<OrderModel> orderList = orderRepository.getOrderList(box);

    Box orderLineBox = await orderLineRepository.openBox();
    for (OrderModel item in orderList) {
      List<OrderLineModel> orderLineList = orderLineRepository.getOrderLineList(orderLineBox);
      List<OrderLineModel> orderLine = <OrderLineModel>[];

      Box stockBox = await stockOrderRepository.openBox();
      List<StockModel> stockList = stockOrderRepository.getStockList(stockBox);

      for (OrderLineModel ordLineModel in orderLineList) {
        for (StockModel stkModel in stockList) {
          if (ordLineModel.stockId == stkModel.id) {
            ordLineModel.setStock(stkModel);
          }
        }
      }

      for (OrderLineModel ordLineModel in orderLineList) {
        for (StockModel stkModel in stockList) {
          if (item.id == ordLineModel.orderId) {
            orderLine.add(ordLineModel);
          }
        }
      }


      /*item.setOrderLineList(orderLineList);
      Box stockBox = await stockOrderRepository.openBox();
      List<StockModel> stockList = stockOrderRepository.getStockList(stockBox);
      for (OrderLineModel orderLineItem in orderLineList) {
        for (StockModel stockItem in stockList) {
          if (orderLineItem.stockId == stockItem.id) {
            orderLineItem.setStock(stockItem);
          }
        }
      }*/
    }
    emit(state.copyWith(
        isLoading: false, hasError: false, orderList: orderList));
  }

  Future<void> getOrderLines({OrderModel? order}) async {
    emit(
      state.copyWith(
        isLoading: true,
      ),
    );

    Box box = await orderLineRepository.openBox();
    List<OrderLineModel> orderLineList = orderLineRepository.getOrderLineList(box);
    List<OrderLineModel> returnLine = <OrderLineModel>[];

    for (OrderLineModel item in orderLineList) {
      Box stockBox = await stockOrderRepository.openBox();
      List<StockModel> stockList = stockOrderRepository.getStockList(stockBox);


      for (StockModel stkModel in stockList) {
        if (item.stockId == stkModel.id && item.orderId == order?.id) {
          item.setStock(stkModel);
          returnLine.add(item);
        }
      }

    }
    emit(state.copyWith(
        isLoading: false, hasError: false, orderLineList: returnLine));
  }
}
