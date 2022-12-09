import 'dart:developer';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keep/presentation/manage_stock/bloc/manage_stock_bloc.dart';
import 'package:keep/presentation/order_history/bloc/order_history_bloc.dart';
import 'package:keep/presentation/order_history/bloc/order_history_state.dart';

import '../../../application/domain/models/application_config.dart';
import '../../../core/domain/utils/constants/app_colors.dart';
import '../../../core/presentation/widgets/at_text.dart';
import '../../../core/presentation/widgets/at_textfield.dart';
import '../data/models/order_model.dart';

class OrderLineHistoryScreen extends StatefulWidget {
  const OrderLineHistoryScreen({Key? key, this.config, this.order})
      : super(key: key);
  static const String routeName = '/orderLineHistory';
  static const String screenName = 'orderLineHistoryScreen';

  final ApplicationConfig? config;
  final OrderModel? order;

  static ModalRoute<OrderLineHistoryScreen> route(
          {ApplicationConfig? config, OrderModel? order}) =>
      MaterialPageRoute<OrderLineHistoryScreen>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => OrderLineHistoryScreen(
          config: config,
          order: order,
        ),
      );

  @override
  _OrderLineHistoryScreen createState() => _OrderLineHistoryScreen();
}

class _OrderLineHistoryScreen extends State<OrderLineHistoryScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OrderHistoryBloc>().getOrderLines(order: widget.order);
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
                  title: ATText(
                    text: 'Order ${widget.order?.num}',
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
                          /*context
                              .read<OrderHistoryBloc>()
                              .searchStocks(search: value ?? '');*/
                        },
                        onChanged: (String value) {
                          EasyDebounce.debounce(
                              'deebouncer1', const Duration(milliseconds: 500),
                              () {
                            /*context
                                    .read<ManageStockBloc>()
                                    .searchStocks(search: value);*/
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 18, right: 18),
                        child: ListView.builder(
                          itemCount: state.orderLineList?.length,
                          itemBuilder: (BuildContext context, index) {
                            return Card(
                                elevation: 4.0,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.only(
                                              left: 16, top: 16),
                                          alignment: Alignment.centerLeft,
                                          child: ATText(
                                            text: state.orderLineList?[index]
                                                .stockModel?.sku
                                                .toString(),
                                            weight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              top: 16, right: 16),
                                          alignment: Alignment.centerLeft,
                                          child: ATText(
                                            text:
                                                'QTY: ${context.read<ManageStockBloc>().getQuantity(state.orderLineList?[index].stockModel)}',
                                            weight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(left: 16),
                                      alignment: Alignment.centerLeft,
                                      child: ATText(
                                        text: state.orderLineList?[index]
                                            .stockModel?.name,
                                        fontSize: 18,
                                      ),
                                    ),
                                    /*Container(
                                      padding: const EdgeInsets.only(left: 16),
                                      alignment: Alignment.centerLeft,
                                      child: ATText(
                                        text: DateFormat("MMM y dd HH:mm")
                                            .add_jm()
                                            .format(DateTime.parse(state
                                                    .orderLineList?[index]
                                                    .createdDate ??
                                                '')),
                                        fontSize: 14,
                                      ),
                                    ),*/
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ));
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
