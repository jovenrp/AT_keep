import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:keep/application/domain/repositories/base_storage_repository.dart';
import 'package:keep/core/data/services/persistence_service.dart';
import 'package:keep/core/domain/utils/string_extensions.dart';
import 'package:keep/presentation/manage_stock/data/models/form_model.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';

import '../domain/repository/repositories/manage_stock_repository.dart';
import 'manage_stock_state.dart';

class ManageStockBloc extends Cubit<ManageStockState> {
  ManageStockBloc({
    required this.baseStorageRepository,
    required this.manageStockRepository,
    required this.persistenceService,
  }) : super(ManageStockState());

  final BaseStorageRepository baseStorageRepository;
  final ManageStockRepository manageStockRepository;
  final PersistenceService persistenceService;

  Future<void> addStock(
      {String? sku,
      String? name,
      String? num,
      String? minQuantity,
      String? maxQuantity,
      String? orderQuantity}) async {
    emit(state.copyWith(isAdding: true));
    Box box = await baseStorageRepository.openBox();
    List<StockModel> stockList = baseStorageRepository.getStockList(box);

    StockModel stock = StockModel(
      id: stockList.isNotEmpty
          ? (int.parse(stockList[stockList.length - 1].id ?? '0') + 1)
              .toString()
              .padLeft(5, '0')
          : '00001',
      sku: sku,
      name: name ?? '',
      num: num ?? '',
      minQuantity: double.parse(minQuantity ?? '0'),
      maxQuantity: double.parse(maxQuantity ?? '0'),
      orderQuantity: double.parse(orderQuantity ?? '0'),
    );

    await baseStorageRepository.addStock(box, stock);
    emit(state.copyWith(isAdding: false));
  }

  Future<void> updateStock(int index, StockModel? stockModel,
      {String? sku,
      String? name,
      String? num,
      String? minQuantity,
      String? maxQuantity,
      String? orderQuantity}) async {
    emit(state.copyWith(isAdding: true));

    Box box = await baseStorageRepository.openBox();
    //List<StockModel> stockList = baseStorageRepository.getStockList(box);

    stockModel?.setSku(sku ?? '');
    stockModel?.setName(name ?? '');
    stockModel?.setNum(num ?? '');
    stockModel?.setMinQuantity(double.parse(minQuantity ?? '0'));
    stockModel?.setMaxQuantity(double.parse(maxQuantity ?? '0'));
    stockModel?.setOrderQuantity(double.parse(orderQuantity ?? '0'));

    await baseStorageRepository.updateStock(
        box, index, stockModel ?? StockModel());
    emit(state.copyWith(isAdding: false));
  }

  Future<void> getStocks() async {
    emit(state.copyWith(
        isLoading: true,
        stocksList: <StockModel>[],
        formResponse: FormModel(error: false, message: '')));

    Box box = await baseStorageRepository.openBox();
    List<StockModel> stockList = baseStorageRepository.getStockList(box);

    emit(state.copyWith(
        isLoading: false, hasError: false, stocksList: stockList));
  }

  Future<void> adjustStock(
      {StockModel? stockModel,
      required int index,
      required double quantity,
      bool? isIn}) async {
    Box box = await baseStorageRepository.openBox();
    double qty = 0;
    double currentQuantity = stockModel?.quantityOnHand ?? 0;
    if (isIn == true) {
      qty = currentQuantity += quantity;
    } else {
      qty = currentQuantity -= quantity;
    }

    stockModel?.setQuantityOnHand(qty);
    baseStorageRepository.updateStock(box, index, stockModel ?? StockModel());
  }

  Future<void> orderStock(
      {StockModel? stockModel,
      required int index,
      required double quantity,
      bool? isIn}) async {
    Box box = await baseStorageRepository.openBox();

    stockModel?.setOrderQuantity(quantity);
    baseStorageRepository.updateStock(box, index, stockModel ?? StockModel());
  }

  Future<void> deleteStock(StockModel? stockModel, int index) async {
    emit(state.copyWith(isLoading: true));

    Box box = await baseStorageRepository.openBox();
    baseStorageRepository.deleteStock(box, stockModel ?? StockModel(), index);
  }

  Future<void> displayErrorMessage(FormModel? response) async {
    emit(state.copyWith(
        isLoading: false, hasError: false, formResponse: response));
  }

  String getOrderQuantity(StockModel? stockModel) {
    String order = '0';
    if (stockModel!.minQuantity! <= 0 && stockModel.maxQuantity! <= 0) {
      order = stockModel.orderQuantity
          .toString()
          .removeDecimalZeroFormat(stockModel.orderQuantity ?? 0);
    } else if (stockModel.minQuantity! <= 0 &&
        stockModel.maxQuantity! > 0 &&
        stockModel.quantityOnHand! <= stockModel.minQuantity!) {
      if (stockModel.orderQuantity! > 0) {
        order = stockModel.orderQuantity
            .toString()
            .removeDecimalZeroFormat(stockModel.orderQuantity ?? 0);
      } else {
        order = stockModel.maxQuantity
            .toString()
            .removeDecimalZeroFormat(stockModel.maxQuantity ?? 0);
      }
    } else {
      if (stockModel.quantityOnHand! >= stockModel.maxQuantity!) {
        order = stockModel.orderQuantity
            .toString()
            .removeDecimalZeroFormat((stockModel.orderQuantity!));
      } else {
        order = (stockModel.maxQuantity! - stockModel.quantityOnHand!)
            .toString()
            .removeDecimalZeroFormat(
                (stockModel.maxQuantity! - stockModel.quantityOnHand!));
      }
    }
    return order;
  }
}
