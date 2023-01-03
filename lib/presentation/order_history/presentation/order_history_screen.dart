import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keep/core/presentation/widgets/at_loading_indicator.dart';
import 'package:keep/presentation/order_history/bloc/order_history_bloc.dart';
import 'package:keep/presentation/order_history/bloc/order_history_state.dart';

import '../../../application/domain/models/application_config.dart';
import '../../../core/domain/utils/constants/app_colors.dart';
import '../../../core/presentation/widgets/at_text.dart';
import '../../../core/presentation/widgets/at_textfield.dart';
import 'order_line_history_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key, this.config}) : super(key: key);
  static const String routeName = '/orderHistory';
  static const String screenName = 'orderHistoryScreen';

  final ApplicationConfig? config;

  static ModalRoute<OrderHistoryScreen> route({ApplicationConfig? config}) =>
      MaterialPageRoute<OrderHistoryScreen>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => OrderHistoryScreen(
          config: config,
        ),
      );

  @override
  _OrderHistoryScreen createState() => _OrderHistoryScreen();
}

class _OrderHistoryScreen extends State<OrderHistoryScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OrderHistoryBloc>().getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderHistoryBloc, OrderHistoryState>(
        listener: (BuildContext context, OrderHistoryState state) {},
        builder: (BuildContext context, OrderHistoryState state) {
          return SafeArea(
            child: WillPopScope(
              onWillPop: () async {
                return true;
              },
              child: Scaffold(
                backgroundColor: AppColors.background,
                appBar: AppBar(
                  backgroundColor: AppColors.secondary,
                  iconTheme: const IconThemeData(color: AppColors.background),
                  title: const ATText(
                    text: 'Order History',
                    fontColor: AppColors.background,
                    fontSize: 18,
                    weight: FontWeight.bold,
                  ),
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 0),
                      child: ATTextfield(
                        hintText: 'Search Item',
                        textEditingController: searchController,
                        onFieldSubmitted: (String? value) {
                          context
                              .read<OrderHistoryBloc>()
                              .searchOrder(search: value ?? '');
                        },
                        onChanged: (String value) {
                          EasyDebounce.debounce(
                              'deebouncer1', const Duration(milliseconds: 500),
                              () {
                            context
                                .read<OrderHistoryBloc>()
                                .searchOrder(search: value);
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                              width: 10.0, color: AppColors.headerGrey),
                        ),
                      ),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                        },
                        children: <TableRow>[
                          TableRow(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 8, top: 5, bottom: 5),
                                alignment: Alignment.centerLeft,
                                color: AppColors.headerGrey,
                                child: const ATText(
                                  text: 'Order Num',
                                  fontColor: AppColors.white,
                                  fontSize: 16,
                                  weight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                alignment: Alignment.centerLeft,
                                color: AppColors.headerGrey,
                                child: const ATText(
                                  text: 'Date',
                                  fontColor: AppColors.white,
                                  fontSize: 16,
                                  weight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                alignment: Alignment.centerLeft,
                                color: AppColors.headerGrey,
                                child: const ATText(
                                  text: 'Status',
                                  fontColor: AppColors.white,
                                  fontSize: 16,
                                  weight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                    right: 8, top: 5, bottom: 5),
                                alignment: Alignment.centerRight,
                                color: AppColors.headerGrey,
                                child: const ATText(
                                  text: 'Lines',
                                  fontColor: AppColors.white,
                                  fontSize: 16,
                                  weight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0, right: 0),
                        child: state.isScreenLoading
                            ? const Center(
                                child: ATLoadingIndicator(
                                  width: 30,
                                  height: 30,
                                ),
                              )
                            : ListView.builder(
                                itemCount: state.orderList?.length,
                                itemBuilder: (BuildContext context, index) {
                                  List<String> userData = state
                                          .orderList?[index].source
                                          ?.split('|') ??
                                      <String>[];

                                  String vendorName = '';
                                  String vendorEmail = '';
                                  String vendorContact = '';
                                  String vendorAddress = '';
                                  String vendorCompany = '';
                                  if (userData.isNotEmpty) {
                                    vendorName = userData[0];
                                    vendorEmail = userData[1];
                                    vendorContact = userData[2];
                                    vendorAddress = userData[3];
                                    vendorCompany = userData[4];
                                  }

                                  //print('asasd ${state.orderList?[index].status} ${state.orderList?[index].name}');
                                  return InkWell(
                                    onTap: () => Navigator.of(context).push(
                                        OrderLineHistoryScreen.route(
                                            order: state.orderList?[index])),
                                    child: Container(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      decoration: BoxDecoration(
                                        color: index % 2 == 1
                                            ? AppColors.lightBlue
                                            : AppColors.white,
                                        border: Border(
                                          left: BorderSide(
                                              width: 10.0,
                                              color: state.orderList?[index]
                                                          .status
                                                          ?.toLowerCase() ==
                                                      'new'
                                                  ? AppColors.criticalRed
                                                  : state.orderList?[index]
                                                              .status
                                                              ?.toLowerCase() ==
                                                          'partial'
                                                      ? AppColors.warningOrange
                                                      : AppColors.successGreen),
                                        ),
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          Table(
                                            columnWidths: const {
                                              0: FlexColumnWidth(3),
                                              1: FlexColumnWidth(2),
                                              2: FlexColumnWidth(2),
                                              3: FlexColumnWidth(2),
                                            },
                                            children: <TableRow>[
                                              TableRow(
                                                children: <Widget>[
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            top: 5,
                                                            bottom: 5),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: ATText(
                                                      text: state
                                                          .orderList?[index]
                                                          .num,
                                                      fontColor:
                                                          AppColors.black,
                                                      fontSize: 16,
                                                      weight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5, bottom: 5),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: ATText(
                                                      text: DateFormat(
                                                              "MMM dd yyyy")
                                                          .format(DateTime.parse(state
                                                                  .orderList?[
                                                                      index]
                                                                  .createdDate ??
                                                              '')),
                                                      fontColor: AppColors
                                                          .onboardingText,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5, bottom: 5),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: ATText(
                                                      text: state
                                                          .orderList?[index]
                                                          .status,
                                                      fontColor: AppColors
                                                          .onboardingText,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8,
                                                            top: 5,
                                                            bottom: 5),
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: ATText(
                                                      text: state
                                                          .orderList?[index]
                                                          .lines,
                                                      fontColor: AppColors
                                                          .onboardingText,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    left: 8),
                                                alignment: Alignment.topLeft,
                                                child: ATText(
                                                  text:
                                                      vendorCompany.toString(),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .7,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: ATText(
                                                  text: state.orderList?[index]
                                                      .address,
                                                  fontSize: 14,
                                                  textAlign: TextAlign.right,
                                                  fontColor: AppColors.tertiary,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                  /*return InkWell(
                                    onTap: () => Navigator.of(context).push(
                                        OrderLineHistoryScreen.route(
                                            order: state.orderList?[index])),
                                    child: Card(
                                        elevation: 4.0,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16, top: 10),
                                                  alignment: Alignment.topLeft,
                                                  child: ATText(
                                                    text: state
                                                        .orderList?[index].num,
                                                    weight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    if (state.orderList?[index]
                                                                .latitude ==
                                                            0 &&
                                                        state.orderList?[index]
                                                                .longitude ==
                                                            0) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          content: Text(
                                                              'Location was not captured on this order.'),
                                                          duration: Duration(
                                                              seconds: 2),
                                                        ),
                                                      );
                                                    } else {
                                                      await placemarkFromCoordinates(
                                                              state
                                                                      .orderList?[
                                                                          index]
                                                                      .latitude ??
                                                                  0,
                                                              state
                                                                      .orderList?[
                                                                          index]
                                                                      .longitude ??
                                                                  0)
                                                          .then(
                                                        (List<Placemark>
                                                            placeMarks) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .hideCurrentSnackBar();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                              content: Text(
                                                                  '${placeMarks[0].street}, ${placeMarks[0].locality}, ${placeMarks[0].country}, ${placeMarks[0].postalCode}'),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          5),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 16, top: 10),
                                                    child: const Icon(
                                                      Icons.my_location,
                                                      size: 30,
                                                      color: AppColors.tertiary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 16),
                                              alignment: Alignment.centerLeft,
                                              child: ATText(
                                                text:
                                                    'Vendor: ${vendorName.toString().capitalizeFirstofEach()}',
                                                fontSize: 16,
                                                weight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 16, bottom: 10),
                                              alignment: Alignment.centerLeft,
                                              child: ATText(
                                                text: DateFormat(
                                                        "MMM y dd HH:mm a")
                                                    .format(DateTime.parse(state
                                                                .orderList?[
                                                                    index]
                                                                .createdDate ??
                                                            '')
                                                        .add(const Duration(
                                                            hours: 8))),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        )),
                                  );*/
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
