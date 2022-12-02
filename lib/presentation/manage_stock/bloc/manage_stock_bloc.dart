import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:keep/application/domain/repositories/base_storage_repository.dart';
import 'package:keep/core/data/services/persistence_service.dart';
import 'package:keep/core/domain/utils/string_extensions.dart';
import 'package:keep/presentation/manage_stock/data/models/form_model.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';

import 'manage_stock_state.dart';

class ManageStockBloc extends Cubit<ManageStockState> {
  ManageStockBloc({
    required this.baseStorageRepository,
    required this.persistenceService,
  }) : super(ManageStockState());

  final BaseStorageRepository baseStorageRepository;
  final PersistenceService persistenceService;

  Future<void> addStock({String? sku, String? name, String? num, String? minQuantity, String? maxQuantity, String? order}) async {
    emit(state.copyWith(isAdding: true));
    Box box = await baseStorageRepository.openBox();
    List<StockModel> stockList = baseStorageRepository.getStockList(box);

    StockModel stock = StockModel(
      id: stockList.isNotEmpty ? (int.parse(stockList[stockList.length - 1].id ?? '0') + 1).toString().padLeft(5, '0') : '00001',
      sku: sku,
      name: name ?? '',
      num: num ?? '',
      minQuantity: double.parse(minQuantity ?? '0'),
      maxQuantity: double.parse(maxQuantity ?? '0'),
      order: double.parse(order ?? '0'),
    );

    await baseStorageRepository.addStock(box, stock);
    emit(state.copyWith(isAdding: false));
  }

  Future<void> updateStock(int index, StockModel? stockModel,
      {String? sku, String? name, String? num, String? minQuantity, String? maxQuantity, String? order}) async {
    emit(state.copyWith(isAdding: true));


    Box box = await baseStorageRepository.openBox();
    //List<StockModel> stockList = baseStorageRepository.getStockList(box);

    stockModel?.setSku(sku ?? '');
    stockModel?.setName(name ?? '');
    stockModel?.setNum(num ?? '');
    stockModel?.setMinQuantity(double.parse(minQuantity ?? '0'));
    stockModel?.setMaxQuantity(double.parse(maxQuantity ?? '0'));
    stockModel?.setorder(double.parse(order ?? '0'));
    log('index $index ${box.keyAt(index)}');
    await baseStorageRepository.updateStock(box, index, stockModel ?? StockModel());
    emit(state.copyWith(isAdding: false));
  }

  Future<void> getStocks() async {
    emit(state.copyWith(isLoading: true, stocksList: <StockModel>[], formResponse: FormModel(error: false, message: '')));

    Box box = await baseStorageRepository.openBox();
    List<StockModel> stockList = baseStorageRepository.getStockList(box);

    emit(state.copyWith(isLoading: false, hasError: false, stocksList: stockList));
  }

  Future<void> searchStocks({required String search}) async {
    emit(state.copyWith(isLoading: true, stocksList: <StockModel>[], formResponse: FormModel(error: false, message: '')));

    Box box = await baseStorageRepository.openBox();
    List<StockModel> stockList = baseStorageRepository.getStockList(box);

    String searchText = search.toLowerCase();
    List<StockModel> values = stockList.where((StockModel item) {
      String sku = item.sku?.toLowerCase() ?? '';
      String num = item.num?.toLowerCase() ?? '';
      String name = item.name?.toLowerCase() ?? '';
      return sku.contains(searchText) || num.contains((searchText)) || name.contains(searchText);
    }).toList();

    emit(state.copyWith(isLoading: false, hasError: false, stocksList: values));
  }

  Future<void> adjustStock({StockModel? stockModel, required int index, required double quantity, bool? isIn}) async {
    Box box = await baseStorageRepository.openBox();
    double qty = 0;
    double currentQuantity = stockModel?.onHand ?? 0;
    if (isIn == true) {
      qty = currentQuantity += quantity;
    } else {
      qty = currentQuantity -= quantity;
    }

    stockModel?.setonHand(qty);
    baseStorageRepository.updateStock(box, index, stockModel ?? StockModel());
  }

  Future<void> orderStock({StockModel? stockModel, required int index, required double quantity, bool? isIn}) async {
    Box box = await baseStorageRepository.openBox();

    stockModel?.setQuantity(quantity);
    baseStorageRepository.updateStock(box, index, stockModel ?? StockModel());
  }

  Future<void> deleteStock(StockModel? stockModel, int index) async {
    emit(state.copyWith(isLoading: true));

    Box box = await baseStorageRepository.openBox();
    baseStorageRepository.deleteStock(box, stockModel ?? StockModel(), index);
  }

  Future<void> displayErrorMessage(FormModel? response) async {
    emit(state.copyWith(isLoading: false, hasError: false, formResponse: response));
  }

  String getQuantity(StockModel? stockModel) {
    double quantity = 0;
    double min = stockModel?.minQuantity ?? 0;
    double max = stockModel?.maxQuantity ?? 0;
    double onHand = stockModel?.onHand ?? 0;
    double qtyOrder = stockModel?.quantity ?? 0;

    if (qtyOrder >= 0 && min == 0 && max == 0 && onHand == 0) {
      quantity = qtyOrder;
    } else {
      if ((onHand < min) || (onHand == 0) && min == 0) {
        quantity = (max >= min) ? max - onHand : 0;
      }
    }

    /*if (qtyOrder > 0) {
      if (onHand < max) {
        quantity = onHand + qtyOrder > max ? max - onHand : qtyOrder;
      } else {
        quantity = 0;
      }
      return quantity.toString().removeDecimalZeroFormat(quantity);
    }
    if (onHand < min || (onHand == 0 && min == 0)) {
      quantity = max - onHand;
    }*/

    return quantity.toString().removeDecimalZeroFormat(quantity);
  }

  Future<void> sortStockOrders({List<StockModel>? stockList, String? column, required bool sortBy}) async {
    List<StockModel> sorted = stockList ?? <StockModel>[];
    sorted.sort((StockModel? a, StockModel? b) {
      switch (column) {
        case 'sku':
          String aa = a?.sku ?? '';
          String bb = b?.sku ?? '';
          return sortBy ? bb.toLowerCase().compareTo(aa.toLowerCase()) : aa.toLowerCase().compareTo(bb.toLowerCase());
        case 'min':
          double aa = a?.minQuantity ?? 0;
          double bb = b?.minQuantity ?? 0;
          return sortBy ? bb.compareTo(aa) : aa.compareTo(bb);
        case 'max':
          double aa = a?.maxQuantity ?? 0;
          double bb = b?.maxQuantity ?? 0;
          return sortBy ? bb.compareTo(aa) : aa.compareTo(bb);
        case 'onHand':
          double aa = a?.onHand ?? 0;
          double bb = b?.onHand ?? 0;
          return sortBy ? bb.compareTo(aa) : aa.compareTo(bb);
        case 'quantity':
          double aa = a?.quantity ?? 0;
          double bb = b?.quantity ?? 0;
          return sortBy ? bb.compareTo(aa) : aa.compareTo(bb);
        default:
          String aa = a?.sku ?? '';
          String bb = b?.sku ?? '';
          return sortBy ? bb.toLowerCase().compareTo(aa.toLowerCase()) : aa.toLowerCase().compareTo(bb.toLowerCase());
      }
    });
    emit(state.copyWith(isLoading: false, stocksList: sorted, hasError: false));
  }
}
