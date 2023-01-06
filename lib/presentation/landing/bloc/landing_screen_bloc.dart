import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:keep/core/data/services/persistence_service.dart';
import 'package:keep/presentation/landing/domain/repositories/landing_repository.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../manage_stock/domain/repositories/stock_order_repository.dart';
import 'landing_screen_state.dart';

class LandingScreenBloc extends Cubit<LandingScreenState> {
  LandingScreenBloc({
    required this.landingRepository,
    required this.stockOrderRepository,
    required this.persistenceService,
  }) : super(LandingScreenState());

  final LandingRepository landingRepository;
  final StockOrderRepository stockOrderRepository;
  final PersistenceService persistenceService;

  Future<void> backupStocks() async {
    emit(state.copyWith(databaseStatus: 'saving stock'));
    Box stocksBox = await landingRepository.openStocksBox();
    Map<String, dynamic> stocksMap =
        await landingRepository.backupStocks(stocksBox);
    String stocksJson = jsonEncode(stocksMap);

    Box profileBox = await landingRepository.openProfileBox();
    Map<String, dynamic> profilesMap =
        await landingRepository.backupProfile(profileBox);
    String profilesJson = jsonEncode(profilesMap);

    Box orderBox = await landingRepository.openOrderBox();
    Map<String, dynamic> orderMap =
        await landingRepository.backupOrder(orderBox);
    String orderJson = jsonEncode(orderMap);

    Box orderLineBox = await landingRepository.openOrderLineBox();
    Map<String, dynamic> orderLineMap =
        await landingRepository.backupOrderLine(orderLineBox);
    String orderLineJson = jsonEncode(orderLineMap);
    PermissionStatus permissionStatus = await Permission.storage.request();
    if (permissionStatus.isGranted) {
      String formattedDate = DateFormat('MM-dd-yyyy HH:mm')
          .format(DateTime.now())
          .toString()
          .replaceAll('.', '-')
          .replaceAll(' ', '-')
          .replaceAll(':', '-');
      Directory dir = await _getBackupDirectory(formattedDate);
      String stocksPath =
          '${dir.path}Stocks_$formattedDate.json'; //Change .json to your desired file format(like .barbackup or .hive).
      File stocksFile = File(stocksPath);
      await stocksFile.writeAsString(stocksJson);

      String profilePath =
          '${dir.path}Profile_$formattedDate.json'; //Change .json to your desired file format(like .barbackup or .hive).
      File profileFile = File(profilePath);
      await profileFile.writeAsString(profilesJson);

      String orderPath =
          '${dir.path}Order_$formattedDate.json'; //Change .json to your desired file format(like .barbackup or .hive).
      File orderFile = File(orderPath);
      await orderFile.writeAsString(orderJson);

      String orderLinePath =
          '${dir.path}OrderLine_$formattedDate.json'; //Change .json to your desired file format(like .barbackup or .hive).
      File orderLineFile = File(orderLinePath);
      await orderLineFile.writeAsString(orderLineJson);

      emit(state.copyWith(databaseStatus: 'backup done'));
    } else {
      //permission denied
      emit(state.copyWith(databaseStatus: 'denied'));
    }
  }

  Future<void> restoreDatabase() async {
    emit(state.copyWith(databaseStatus: ''));
    Box stocksBox = await landingRepository.openStocksBox();
    await landingRepository.openProfileBox();
    await landingRepository.openOrderBox();
    await landingRepository.openOrderLineBox();
    String? result = await landingRepository.restoreStocks(stocksBox);

    emit(state.copyWith(databaseStatus: result));
  }

  Future<Directory> _getBackupDirectory(String? formattedDate) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    //String appDocPath = appDocDir.path;

    String pathExt =
        'KeepBackup/$formattedDate/'; //This is the name of the folder where the backup is stored
    //Directory newDirectory = Directory('$appDocPath' + pathExt);
    Directory newDirectory = Directory('/storage/emulated/0/' + pathExt);
    if (await newDirectory.exists() == false) {
      return newDirectory.create(recursive: true);
    }
    return newDirectory;
  }

  Future<void> createStockCSV() async {
    emit(state.copyWith(databaseStatus: ''));

    Box stocksBox = await stockOrderRepository.openBox();
    List<StockModel> stocks =
        await stockOrderRepository.getStockList(stocksBox);
    List<List<String>> data = <List<String>>[];
    List<String> value = <String>[
      'ID',
      'Name',
      'description',
      'Min Quantity',
      'Max Quantity',
      'Order',
      'On Hand',
      'SKU',
      'NUM',
    ];
    data.add(value);
    for (StockModel item in stocks) {
      List<String> value = <String>[
        item.id ?? '',
        item.name ?? '',
        item.description ?? '',
        item.minQuantity?.toString() ?? '',
        item.maxQuantity?.toString() ?? '',
        item.order.toString(),
        item.onHand.toString(),
        item.sku ?? '',
        item.num ?? '',
      ];
      data.add(value);
    }
    String csvData = const ListToCsvConverter().convert(data);

    PermissionStatus permissionStatus = await Permission.storage.request();
    if (permissionStatus.isGranted) {
      String formattedDate = DateFormat('MM-dd-yyyy HH:mm')
          .format(DateTime.now())
          .toString()
          .replaceAll('.', '-')
          .replaceAll(' ', '-')
          .replaceAll(':', '-');
      Directory dir = await _getCSVDirectory(formattedDate);
      String stocksPath =
          '${dir.path}Stocks_CSV_$formattedDate.csv'; //Change .json to your desired file format(like .barbackup or .hive).
      File stocksFile = File(stocksPath);
      await stocksFile.writeAsString(csvData);
    } else {
      //permission denied
      emit(state.copyWith(databaseStatus: 'denied'));
    }
  }

  Future<Directory> _getCSVDirectory(String? formattedDate) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    //String appDocPath = appDocDir.path;

    String pathExt =
        'KeepCSV/$formattedDate/'; //This is the name of the folder where the backup is stored
    //Directory newDirectory = Directory('$appDocPath' + pathExt);
    Directory newDirectory = Directory('/storage/emulated/0/' + pathExt);
    if (await newDirectory.exists() == false) {
      return newDirectory.create(recursive: true);
    }
    return newDirectory;
  }

  Future<void> importCSV(String action) async {
    emit(state.copyWith(databaseStatus: ''));
    Box stocksBox = await stockOrderRepository.openBox();
    String? result = await landingRepository.importCSV(stocksBox, action);

    emit(state.copyWith(databaseStatus: result));
  }
}
