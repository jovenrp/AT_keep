import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:keep/presentation/manage_stock/domain/repositories/stock_order_repository.dart';
import 'package:keep/core/data/services/persistence_service.dart';
import 'package:keep/core/domain/utils/string_extensions.dart';
import 'package:keep/presentation/manage_stock/data/models/form_model.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';
import 'package:keep/presentation/profile/domain/repositories/profile_repository.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/domain/utils/constants/app_colors.dart' as pc;
import '../../../core/domain/utils/constants/app_colors.dart';
import '../../../core/presentation/widgets/at_text.dart';
import '../../profile/data/models/profile_model.dart';
import '../domain/repositories/stock_order_repository.dart';
import 'manage_stock_state.dart';

class ManageStockBloc extends Cubit<ManageStockState> {
  ManageStockBloc({
    required this.stockOrderRepository,
    required this.profileRepository,
    required this.persistenceService,
  }) : super(ManageStockState());

  final StockOrderRepository stockOrderRepository;
  final ProfileRepository profileRepository;
  final PersistenceService persistenceService;

  Future<void> getProfiles() async {
    Box box = await profileRepository.openBox();
    List<ProfileModel> profileList = profileRepository.getProfile(box);

    for (ProfileModel item in profileList) {
      if (item.type == 'profile') {
        emit(state.copyWith(user: item));
      } else if (item.type == 'vendor') {
        emit(state.copyWith(vendor: item));
      }
    }
  }

  Future<void> addStock(
      {String? sku,
      String? name,
      String? num,
      String? minQuantity,
      String? maxQuantity,
      String? order}) async {
    emit(state.copyWith(isAdding: true));
    Box box = await stockOrderRepository.openBox();
    List<StockModel> stockList = stockOrderRepository.getStockList(box);

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
      order: double.parse(order ?? '0'),
    );

    await stockOrderRepository.addStock(box, stock);
    emit(state.copyWith(isAdding: false));
  }

  Future<void> updateStock(int index, StockModel? stockModel,
      {String? sku,
      String? name,
      String? num,
      String? minQuantity,
      String? maxQuantity,
      String? order}) async {
    emit(state.copyWith(isAdding: true));

    Box box = await stockOrderRepository.openBox();
    //List<StockModel> stockList = StockOrderRepository.getStockList(box);

    stockModel?.setSku(sku ?? '');
    stockModel?.setName(name ?? '');
    stockModel?.setNum(num ?? '');
    stockModel?.setMinQuantity(double.parse(minQuantity ?? '0'));
    stockModel?.setMaxQuantity(double.parse(maxQuantity ?? '0'));
    stockModel?.setorder(double.parse(order ?? '0'));
    stockModel?.setIsOrdered(false);

    await stockOrderRepository.updateStock(
        box, index, stockModel ?? StockModel());
    emit(state.copyWith(isAdding: false));
  }

  Future<void> getStocks() async {
    emit(state.copyWith(
        isLoading: true,
        isPdfGenerated: false,
        stocksList: <StockModel>[],
        formResponse: FormModel(error: false, message: '')));

    Box box = await stockOrderRepository.openBox();
    List<StockModel> stockList = stockOrderRepository.getStockList(box);

    emit(state.copyWith(
        isLoading: false, hasError: false, stocksList: stockList));
  }

  Future<void> searchStocks({required String search}) async {
    emit(state.copyWith(
        isLoading: true,
        stocksList: <StockModel>[],
        formResponse: FormModel(error: false, message: '')));

    Box box = await stockOrderRepository.openBox();
    List<StockModel> stockList = stockOrderRepository.getStockList(box);

    String searchText = search.toLowerCase();
    List<StockModel> values = stockList.where((StockModel item) {
      String sku = item.sku?.toLowerCase() ?? '';
      String num = item.num?.toLowerCase() ?? '';
      String name = item.name?.toLowerCase() ?? '';
      return sku.contains(searchText) ||
          num.contains((searchText)) ||
          name.contains(searchText);
    }).toList();

    emit(state.copyWith(isLoading: false, hasError: false, stocksList: values));
  }

  Future<void> adjustStock(
      {StockModel? stockModel,
      required int index,
      required double quantity,
      bool? isIn}) async {
    Box box = await stockOrderRepository.openBox();
    double qty = 0;
    double currentQuantity = stockModel?.onHand ?? 0;
    if (isIn == true) {
      qty = currentQuantity += quantity;
    } else {
      qty = currentQuantity -= quantity;
    }

    stockModel?.setonHand(qty);
    stockModel?.setIsOrdered(false);
    stockOrderRepository.updateStock(box, index, stockModel ?? StockModel());
  }

  Future<void> orderStock(
      {StockModel? stockModel,
      required int index,
      required double quantity,
      bool? isIn}) async {
    Box box = await stockOrderRepository.openBox();

    stockModel?.setQuantity(quantity);
    stockModel?.setIsOrdered(false);
    stockOrderRepository.updateStock(box, index, stockModel ?? StockModel());
  }

  Future<void> deleteStock(StockModel? stockModel, int index) async {
    emit(state.copyWith(isLoading: true));

    Box box = await stockOrderRepository.openBox();
    stockOrderRepository.deleteStock(box, stockModel ?? StockModel(), index);
  }

  Future<void> clearStocks({required List<StockModel> stockList}) async {
    emit(state.copyWith(isLoading: true));

    for (StockModel item in stockList) {
      item.setIsOrdered(true);
    }

    emit(state.copyWith(isPdfGenerated: true));
    Future.delayed(const Duration(milliseconds: 200), () => getStocks());
  }

  Future<void> displayErrorMessage(FormModel? response) async {
    emit(state.copyWith(
        isLoading: false, hasError: false, formResponse: response));
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

  Future<void> sortStockOrders(
      {List<StockModel>? stockList,
      String? column,
      required bool sortBy}) async {
    List<StockModel> sorted = stockList ?? <StockModel>[];
    sorted.sort((StockModel? a, StockModel? b) {
      switch (column) {
        case 'sku':
          String aa = a?.sku ?? '';
          String bb = b?.sku ?? '';
          return sortBy
              ? bb.toLowerCase().compareTo(aa.toLowerCase())
              : aa.toLowerCase().compareTo(bb.toLowerCase());
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
          return sortBy
              ? bb.toLowerCase().compareTo(aa.toLowerCase())
              : aa.toLowerCase().compareTo(bb.toLowerCase());
      }
    });
    emit(state.copyWith(isLoading: false, stocksList: sorted, hasError: false));
  }

  Future<void> generatePdfOrder(
      {required List<StockModel>? stockList,
      required ProfileModel user,
      required ProfileModel vendor,
      required String? action}) async {
    String formattedDate = DateFormat.yMMMEd().format(DateTime.now());
    String? orderNumber = '1000';
    final pdf = pw.Document();

    final image = pw.MemoryImage(
      (await rootBundle.load('assets/images/applogo.jpeg'))
          .buffer
          .asUint8List(),
    );

    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  /*pw.SizedBox(
                    child: pw.Image(image, width: 100, height: 100),
                  ),*/
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 12),
                      pw.Text(
                        '${vendor.firstname.toString().capitalizeFirstofEach()} ${vendor.lastname.toString().capitalizeFirstofEach()}',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Container(
                        width: 200,
                        child: pw.Text(
                          vendor.address.toString().capitalizeFirstofEach(),
                          style: const pw.TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        vendor.phoneNumber.toString().capitalizeFirstofEach(),
                        style: const pw.TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(height: 12),
                      pw.Text(formattedDate,
                          style: const pw.TextStyle(fontSize: 18)),
                      pw.Text('Order # $orderNumber',
                          style: const pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                ]),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                /*pw.SizedBox(
                    child: pw.Image(image, width: 100, height: 100),
                  ),*/
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 12),
                    pw.Text(
                      '${user.firstname.toString().capitalizeFirstofEach()} ${user.lastname.toString().capitalizeFirstofEach()}',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Container(
                      width: 200,
                      child: pw.Text(
                        user.address.toString().capitalizeFirstofEach(),
                        style: const pw.TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      user.phoneNumber.toString().capitalizeFirstofEach(),
                      style: const pw.TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(height: 1),
            pw.SizedBox(height: 20),
            pw.Expanded(
              child: pw.ListView.builder(
                  itemCount: stockList?.length ?? 0,
                  itemBuilder: (pw.Context context, index) {
                    return pw.Container(
                      /*decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                          width: 10.0,
                          color: PdfColor.fromInt(state.stocksList?[index].maxQuantity == 0
                              ? pc.AppColors.subtleGrey.value
                              : double.parse(state.stocksList?[index].maxQuantity.toString() ?? '0') <=
                              double.parse(state.stocksList?[index].onHand.toString() ?? '0')
                              ? pc.AppColors.successGreen.value
                              : state.stocksList?[index].onHand == 0
                              ? pc.AppColors.criticalRed.value
                              : pc.AppColors.warningOrange.value)),
                    ),
                  ),*/
                      child: pw.Container(
                        padding: const pw.EdgeInsets.only(top: 10),
                        color: PdfColor.fromInt(index % 2 == 1
                            ? AppColors.lightBlue.value
                            : AppColors.white.value),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: <pw.Widget>[
                            pw.Table(
                              columnWidths: const {
                                0: pw.FlexColumnWidth(3),
                                1: pw.FlexColumnWidth(2),
                                2: pw.FlexColumnWidth(2),
                                3: pw.FlexColumnWidth(2),
                                4: pw.FlexColumnWidth(2),
                              },
                              children: <pw.TableRow>[
                                pw.TableRow(
                                  children: <pw.Widget>[
                                    pw.Container(
                                      padding:
                                          const pw.EdgeInsets.only(left: 8),
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text(
                                          stockList?[index].sku ?? '',
                                          style: pw.TextStyle(
                                              fontSize: 18,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColor.fromInt(
                                                  AppColors.tertiary.value))),
                                    ),
                                    pw.Container(
                                      padding:
                                          const pw.EdgeInsets.only(right: 8),
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Text(
                                        state.stocksList?[index].minQuantity
                                                .toString()
                                                .removeDecimalZeroFormat(state
                                                        .stocksList?[index]
                                                        .minQuantity ??
                                                    0) ??
                                            '',
                                        style: pw.TextStyle(
                                          fontSize: 18,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColor.fromInt(
                                            AppColors.tertiary.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                    pw.Container(
                                      padding:
                                          const pw.EdgeInsets.only(right: 8),
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Text(
                                        state.stocksList?[index].maxQuantity
                                                .toString()
                                                .removeDecimalZeroFormat(state
                                                        .stocksList?[index]
                                                        .maxQuantity ??
                                                    0) ??
                                            '',
                                        style: pw.TextStyle(
                                          fontSize: 18,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColor.fromInt(
                                            AppColors.tertiary.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                    pw.Container(
                                      padding:
                                          const pw.EdgeInsets.only(right: 18),
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Text(
                                        state.stocksList?[index].onHand
                                                .toString()
                                                .removeDecimalZeroFormat(state
                                                        .stocksList?[index]
                                                        .onHand ??
                                                    0) ??
                                            '',
                                        style: pw.TextStyle(
                                          fontSize: 18,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColor.fromInt(
                                            AppColors.tertiary.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                    pw.Container(
                                      padding:
                                          const pw.EdgeInsets.only(right: 8),
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Text(
                                        getQuantity(state.stocksList?[index]),
                                        style: pw.TextStyle(
                                          fontSize: 18,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColor.fromInt(
                                            AppColors.tertiary.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.only(
                                  left: 8, right: 8, top: 5),
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text(
                                stockList?[index].name ?? '',
                                style: pw.TextStyle(
                                  fontSize: 15,
                                  color: PdfColor.fromInt(
                                    AppColors.tertiary.value,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            )
          ]); // Center
    }));

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    final file = File(appDocPath + '/' + 'StockOrder.pdf');
    log('Save as file ${file.path} ...');
    await file.writeAsBytes(await pdf.save());

    if (action == 'share') {
      ShareResult result = await Share.shareFilesWithResult(
          ['$appDocPath/StockOrder.pdf'],
          subject: 'Stock Order');

      if (result.status.name == 'success') {
        clearStocks(stockList: stockList ?? <StockModel>[]);
      }
    } else {
      await OpenFile.open(file.path);
    }
  }
}
