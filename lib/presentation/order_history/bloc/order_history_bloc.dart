import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';
import 'package:keep/presentation/order_history/bloc/order_history_state.dart';

import '../../manage_stock/domain/repositories/stock_order_repository.dart';
import '../data/models/order_line_model.dart';
import '../data/models/order_model.dart';
import '../domain/repositories/order_line_repository.dart';
import '../domain/repositories/order_repository.dart';

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
        isScreenLoading: true,
      ),
    );

    Box box = await orderRepository.openBox();
    List<OrderModel> orderList = orderRepository.getOrderList(box);

    Box orderLineBox = await orderLineRepository.openBox();
    for (OrderModel item in orderList) {
      List<OrderLineModel> orderLineList =
          orderLineRepository.getOrderLineList(orderLineBox);
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
        if (item.id == ordLineModel.orderId) {
          orderLine.add(ordLineModel);
        }
      }

      List<OrderLineModel> lines = await getOrderLines(order: item);
      item.setLines(lines.length.toString());

      String address = '';
      if (item.latitude == 0 && item.longitude == 0) {
        address = 'Location was not captured on this order.';
      } else {
        await placemarkFromCoordinates(item.latitude ?? 0, item.longitude ?? 0)
            .then(
          (List<Placemark> placeMarks) {
            address =
                '${placeMarks[0].street}, ${placeMarks[0].locality}, ${placeMarks[0].country}, ${placeMarks[0].postalCode}';
          },
        );
      }
      item.setAddress(address);
    }

    List<OrderModel> sorted = orderList;
    sorted.sort((OrderModel? a, OrderModel? b) {
      String aa = a?.createdDate ?? '';
      String bb = b?.createdDate ?? '';
      return bb.toLowerCase().compareTo(aa.toLowerCase());
    });

    emit(state.copyWith(
        isScreenLoading: false, hasError: false, orderList: orderList));
  }

  Future<List<OrderLineModel>> getOrderLines(
      {OrderModel? order, bool isInOrderScreen = false}) async {
    emit(
      state.copyWith(
        isLoading: true,
        orderLineList: <OrderLineModel>[],
      ),
    );

    Box box = await orderLineRepository.openBox();
    List<OrderLineModel> orderLineList =
        orderLineRepository.getOrderLineList(box);
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

    return returnLine;
  }

  Future<void> receieveOrder(
      {required StockModel stock,
      required OrderLineModel orderLine,
      double? onOrder,
      String? isFlipped,
      required OrderModel? orderModel}) async {
    emit(state.copyWith(isLoading: true));

    double onOrderVal = onOrder ?? 0;
    double onHand = stock.onHand ?? 0;
    double quantity = orderLine.quantity ?? 0;

    if (isFlipped == 'pending') {
      orderLine.setStatus('pending');
      stock.setonHand(0);
      //stock.setOnOrder(orderLine.originalQuantity ?? 0);
      stock.setorder(0);
      orderLine.setQuantity(0);
    } else if (isFlipped == 'received') {
      orderLine.setStatus('received');
      stock.setonHand(orderLine.originalQuantity ?? 0);
      stock.setorder(orderLine.originalQuantity ?? 0);
      orderLine.setQuantity(orderLine.originalQuantity ?? 0);
    } else {
      double onHandValue = onHand + onOrderVal;
      double onOrderValue = onOrderVal;
      //stock.setonHand(onHandValue);
      //stock.setOnOrder(onOrderValue);
      orderLine.setQuantity(onOrderValue);
      stock.setonHand(onOrderValue);
      stock.setorder(onOrderValue);
      orderLine.setIsChecked(onOrderValue > 0 ? true : false);
      orderLine.setStatus(
          onOrderValue == orderLine.originalQuantity ? 'received' : 'partial');
    }

    Box stockBox = await stockOrderRepository.openBox();
    stockOrderRepository.updateStock(stockBox, stock);

    Box orderLineBox = await orderLineRepository.openBox();
    orderLineRepository.addOrderLine(orderLineBox, orderLine);

    updateOrderStatus(orderModel ?? OrderModel());
    emit(state.copyWith(isLoading: false));
  }

  Future<void> updateCheckbox(OrderLineModel? orderLineModel, bool? value) async {
    orderLineModel?.setIsChecked(value ?? false);
    Box stockBox = await orderLineRepository.openBox();
    orderLineRepository.addOrderLine(stockBox, orderLineModel ?? OrderLineModel());
  }

  Future<void> updateOrderStatus(OrderModel order) async {
    int itemReceivedCounter = 0;
    for (OrderLineModel item in state.orderLineList ?? <OrderLineModel>[]) {
      if (item.status != 'partial' &&
          item.status != 'pending' &&
          item.status != null) {
        itemReceivedCounter++;
      }
    }

    if (itemReceivedCounter == state.orderLineList?.length) {
      order.setStatus('Received');
    } else {
      order.setStatus('Partial');
    }
    Box orderBox = await orderRepository.openBox();
    orderRepository.addOrder(orderBox, order);
  }

  Future<void> searchOrder({required String search}) async {
    emit(state.copyWith(isLoading: true, orderList: <OrderModel>[]));

    Box box = await orderRepository.openBox();
    List<OrderModel> orderList = orderRepository.getOrderList(box);

    Box orderLineBox = await orderLineRepository.openBox();
    for (OrderModel item in orderList) {
      List<OrderLineModel> orderLineList =
          orderLineRepository.getOrderLineList(orderLineBox);
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
        if (item.id == ordLineModel.orderId) {
          orderLine.add(ordLineModel);
        }
      }
    }

    List<OrderModel> sorted = orderList;
    sorted.sort((OrderModel? a, OrderModel? b) {
      String aa = a?.createdDate ?? '';
      String bb = b?.createdDate ?? '';
      return bb.toLowerCase().compareTo(aa.toLowerCase());
    });

    String searchText = search.toLowerCase();
    List<OrderModel> values = sorted.where((OrderModel item) {
      String createdDate = DateFormat("MMM y dd HH:mm a")
              .format(DateTime.parse(item.createdDate ?? '')
                  .add(const Duration(hours: 8)))
              .toLowerCase() ??
          '';
      String num = item.num?.toLowerCase() ?? '';
      String name = item.name?.toLowerCase() ?? '';
      String source = item.source?.toLowerCase() ?? '';

      return createdDate.contains(searchText) ||
          num.contains((searchText)) ||
          source.contains((searchText)) ||
          name.contains(searchText);
    }).toList();
    emit(state.copyWith(isLoading: false, hasError: false, orderList: values));
  }

  Future<void> searchOrderLine(
      {required String search, OrderModel? order}) async {
    emit(state.copyWith(isLoading: true, orderLineList: <OrderLineModel>[]));

    Box box = await orderLineRepository.openBox();
    List<OrderLineModel> orderLineList =
        orderLineRepository.getOrderLineList(box);
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

    List<OrderLineModel> sorted = returnLine;
    sorted.sort((OrderLineModel? a, OrderLineModel? b) {
      String aa = a?.createdDate ?? '';
      String bb = b?.createdDate ?? '';
      return bb.toLowerCase().compareTo(aa.toLowerCase());
    });

    String searchText = search.toLowerCase();
    List<OrderLineModel> values = sorted.where((OrderLineModel item) {
      String createdDate = DateFormat("MMM y dd HH:mm a")
              .format(DateTime.parse(item.createdDate ?? '')
                  .add(const Duration(hours: 8)))
              .toLowerCase() ??
          '';
      String quantity = item.quantity.toString().toLowerCase() ?? '';
      String sku = item.stockModel?.sku?.toLowerCase() ?? '';
      String name = item.stockModel?.name?.toLowerCase() ?? '';
      String onHand = item.stockModel?.onHand?.toString().toLowerCase() ?? '';
      String status = item.status?.toLowerCase() ?? '';

      return createdDate.contains(searchText) ||
          quantity.contains((searchText)) ||
          name.contains((searchText)) ||
          onHand.contains((searchText)) ||
          status.contains((searchText)) ||
          sku.contains(searchText);
    }).toList();
    emit(state.copyWith(
        isLoading: false, hasError: false, orderLineList: values));
  }

/*Future<void> getLocation(int index) async {
    String address = '';
    if (state.orderList?[index].latitude == 0 &&
        state.orderList?[index].longitude == 0) {
      address = 'Location was not captured on this order.';
    } else {
      await placemarkFromCoordinates(state.orderList?[index].latitude ?? 0,
              state.orderList?[index].longitude ?? 0)
          .then(
        (List<Placemark> placeMarks) {
          address =
              '${placeMarks[0].street}, ${placeMarks[0].locality}, ${placeMarks[0].country}, ${placeMarks[0].postalCode}';
        },
      );
    }
    state.orderList?[index].setAddress(address);

    emit(state.copyWith(orderList: state.orderList));
  }*/
}
