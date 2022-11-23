import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keep/core/data/services/persistence_service.dart';
import 'package:keep/presentation/in_and_out/bloc/in_out_state.dart';
import 'package:keep/presentation/in_and_out/data/models/in_out_item.dart';
import 'package:keep/presentation/in_and_out/domain/repositories/in_out_repository.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';

import 'package:pdf/widgets.dart' as pw;

class InOutBloc extends Cubit<InOutState> {
  InOutBloc({
    required this.inOutRepository,
    required this.persistenceService,
  }) : super(InOutState());

  final InOutRepository inOutRepository;
  final PersistenceService persistenceService;

  Future<void> init() async {
    emit(state.copyWith(isLoading: false, inOutItem: <InOutItem>[]));
  }

  Future<void> getItems() async {
    emit(state.copyWith(isLoading: true));
    InOutItem item = const InOutItem(
        id: '10000',
        containerId: '10000',
        itemId: '12201',
        itemNum: '100011',
        sku: '101111',
        uom: 'EA',
        qty: '99',
        name: 'Esun PLA+ Filament 1.75mm');
    List<InOutItem> inOutItem = <InOutItem>[item];

    Future<void>.delayed(const Duration(seconds: 2), () {
      emit(state.copyWith(isLoading: false, inOutItem: inOutItem));
    });
  }

  Future<void> generateOrderPdf() async {
    final pdf = pw.Document();
    String formattedDate = DateFormat.yMMMEd().format(DateTime.now());

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
                  pw.SizedBox(
                    child: pw.Image(image, width: 100, height: 100),
                  ),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.SizedBox(height: 12),
                        pw.Text('ActionTRAK',
                            style: pw.TextStyle(
                                fontSize: 20, fontWeight: pw.FontWeight.bold)),
                        pw.Text('K E E P',
                            style: pw.TextStyle(
                                fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ]),
                  pw.Spacer(),
                  pw.Column(children: [
                    pw.SizedBox(height: 12),
                    pw.Text(formattedDate,
                        style: const pw.TextStyle(fontSize: 16)),
                  ])
                ]),
            pw.Divider(height: 1),
          ]); // Center
    }));

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    final file = File(appDocPath +
        '/' +
        'order_${DateTime.now().millisecondsSinceEpoch}.pdf');
    log('Save as file ${file.path} ...');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  Future<void> generateSalesOrder() async {
    final pdf = pw.Document();
    //String formattedDate = DateFormat.yMMMEd().format(DateTime.now());

    /*final image = pw.MemoryImage(
      (await rootBundle.load('assets/images/applogo.jpeg'))
          .buffer
          .asUint8List(),
    );*/

    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Sales Order',
                            style: const pw.TextStyle(
                              fontSize: 28,
                            )),
                        pw.SizedBox(height: 20),
                      ]),
                ]),
            pw.Divider(height: 1),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Table(columnWidths: {
                    0: const pw.FixedColumnWidth(50),
                    1: const pw.FixedColumnWidth(100),
                  }, children: [
                    pw.TableRow(children: [
                      pw.Text('From:'),
                      pw.Text('Main Office'),
                    ]),
                    pw.TableRow(children: [
                      pw.SizedBox(),
                      pw.Text('11479 S State St Unit A Draper, UT 84020'),
                    ]),
                    pw.TableRow(children: [
                      pw.SizedBox(height: 10),
                      pw.SizedBox(height: 10),
                    ]),
                    pw.TableRow(children: [
                      pw.Text('To:'),
                      pw.Text('Main Office'),
                    ]),
                    pw.TableRow(children: [
                      pw.SizedBox(),
                      pw.Text('11479 S State St Unit A Draper, UT 84020'),
                    ]),
                  ]),
                  pw.Table(columnWidths: {
                    0: const pw.FixedColumnWidth(70),
                    1: const pw.FixedColumnWidth(100),
                  }, children: [
                    pw.TableRow(children: [
                      pw.Text('SO Number:'),
                      pw.Text('10022'),
                    ]),
                    pw.TableRow(children: [
                      pw.Text('SO Date:'),
                      pw.Text('Dec 30, 2021'),
                    ]),
                    pw.TableRow(children: [
                      pw.Text('Status:'),
                      pw.Text('New'),
                    ]),
                    pw.TableRow(children: [
                      pw.SizedBox(height: 10),
                      pw.SizedBox(height: 10),
                    ]),
                    pw.TableRow(children: [
                      pw.Text('Carrier: '),
                      pw.Text('UPS'),
                    ]),
                    pw.TableRow(children: [
                      pw.Text('Method: '),
                      pw.Text('Ground'),
                    ]),
                  ])
                ]),
            pw.SizedBox(height: 20),
            pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                padding: const pw.EdgeInsets.all(5),
                child: pw.Table(columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FixedColumnWidth(30),
                  2: const pw.FixedColumnWidth(100),
                  3: const pw.FixedColumnWidth(50),
                  4: const pw.FixedColumnWidth(70),
                }, children: [
                  pw.TableRow(children: [
                    pw.Text('Qty'),
                    pw.Text('Item'),
                    pw.Text('Description'),
                    pw.Text('Price'),
                    pw.Text('Line Value'),
                  ]),
                ])),
            pw.SizedBox(height: 10),
            pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Table(columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FixedColumnWidth(30),
                  2: const pw.FixedColumnWidth(100),
                  3: const pw.FixedColumnWidth(50),
                  4: const pw.FixedColumnWidth(70),
                }, children: [
                  pw.TableRow(children: [
                    pw.Text('1'),
                    pw.Text('PK3'),
                    pw.Text('Mini Kit Party'),
                    pw.Text('19.13'),
                    pw.Text('19.13'),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('1'),
                    pw.Text('111370'),
                    pw.Text('100ct Lip/Tape 4.3x5.75 Bg'),
                    pw.Text('3.97'),
                    pw.Text('3.97'),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('1'),
                    pw.Text('111371'),
                    pw.Text('100ct Lip/Tape 8x10 Bg'),
                    pw.Text('6.97'),
                    pw.Text('6.97'),
                  ]),
                ])),
            pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Table(columnWidths: {
                  0: const pw.FixedColumnWidth(80),
                  1: const pw.FixedColumnWidth(80),
                  2: const pw.FixedColumnWidth(100),
                  3: const pw.FlexColumnWidth(),
                }, children: [
                  pw.TableRow(children: [
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.Divider(height: 1)
                  ]),
                ])),
            pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Table(columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FixedColumnWidth(30),
                  2: const pw.FixedColumnWidth(100),
                  3: const pw.FixedColumnWidth(50),
                  4: const pw.FixedColumnWidth(70),
                }, children: [
                  pw.TableRow(children: [
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.Text('Sub Total'),
                    pw.Text('30.07'),
                  ]),
                  pw.TableRow(children: [
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.Text('Tax'),
                    pw.Text('1.85'),
                  ]),
                  pw.TableRow(children: [
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.Text('Shipping'),
                    pw.Text('0.0'),
                  ]),
                ])),
            pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Table(columnWidths: {
                  0: const pw.FixedColumnWidth(80),
                  1: const pw.FixedColumnWidth(80),
                  2: const pw.FixedColumnWidth(100),
                  3: const pw.FlexColumnWidth(),
                }, children: [
                  pw.TableRow(children: [
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.Divider(height: 1)
                  ]),
                ])),
            pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Table(columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FixedColumnWidth(30),
                  2: const pw.FixedColumnWidth(100),
                  3: const pw.FixedColumnWidth(50),
                  4: const pw.FixedColumnWidth(70),
                }, children: [
                  pw.TableRow(children: [
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.Text('Total'),
                    pw.Text('31.92'),
                  ]),
                ])),
          ]); // Center
    }));

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    final file = File(appDocPath +
        '/' +
        'order_${DateTime.now().millisecondsSinceEpoch}.pdf');
    log('Save as file ${file.path} ...');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }
}
