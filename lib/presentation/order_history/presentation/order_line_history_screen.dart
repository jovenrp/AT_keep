import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:keep/core/domain/utils/string_extensions.dart';
import 'package:keep/presentation/order_history/bloc/order_history_bloc.dart';
import 'package:keep/presentation/order_history/bloc/order_history_state.dart';
import 'package:keep/presentation/order_history/data/models/order_line_model.dart';

import '../../../application/domain/models/application_config.dart';
import '../../../core/domain/utils/constants/app_colors.dart';
import '../../../core/presentation/utils/dialog_utils.dart';
import '../../../core/presentation/widgets/at_text.dart';
import '../../../core/presentation/widgets/at_textfield.dart';
import '../../../core/presentation/widgets/keep_elevated_button.dart';
import '../../manage_stock/data/models/stocks_model.dart';
import '../data/models/order_model.dart';

class OrderLineHistoryScreen extends StatefulWidget {
  const OrderLineHistoryScreen({Key? key, this.config, this.order}) : super(key: key);
  static const String routeName = '/orderLineHistory';
  static const String screenName = 'orderLineHistoryScreen';

  final ApplicationConfig? config;
  final OrderModel? order;

  static ModalRoute<OrderLineHistoryScreen> route({ApplicationConfig? config, OrderModel? order}) => MaterialPageRoute<OrderLineHistoryScreen>(
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
  TextEditingController orderController = TextEditingController();
  FocusNode orderNode = FocusNode();

  bool isCheckedAll = false;
  bool isOrderReceived = false;

  @override
  void initState() {
    super.initState();
    context.read<OrderHistoryBloc>().getOrderLines(order: widget.order).then((List<OrderLineModel> list) {
      int itemReceivedCounter = 0;
      for (OrderLineModel item in list) {
        if (item.status != 'partial' && item.status != 'pending' && item.status != null) {
          itemReceivedCounter++;
        }
      }
      if (itemReceivedCounter == list.length) {
        isCheckedAll = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderHistoryBloc, OrderHistoryState>(listener: (BuildContext context, OrderHistoryState state) {
      if (!state.isLoading) {
        showAllChecker(state);
      }
    }, builder: (BuildContext context, OrderHistoryState state) {
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
              actions: <Widget>[
                SizedBox(
                  width: 150,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      unselectedWidgetColor: Colors.white,
                    ),
                    child: CheckboxListTile(
                        contentPadding: const EdgeInsets.only(right: 10),
                        value: isCheckedAll,
                        title: Transform.translate(
                          offset: const Offset(35, 0),
                          child: const ATText(
                            text: 'Receive all',
                            fontColor: AppColors.white,
                          ),
                        ),
                        activeColor: isCheckedAll == true ? AppColors.white : AppColors.white,
                        checkColor: AppColors.successGreen,
                        onChanged: (bool? value) {
                          setState(
                            () {
                              isCheckedAll = !isCheckedAll;
                              for (int index = 0; index < state.orderLineList!.length; index++) {
                                //_controller[index].toggleCard();
                                if (isCheckedAll == true) {
                                  context.read<OrderHistoryBloc>().receieveOrder(
                                        stock: state.orderLineList?[index].stockModel ?? StockModel(),
                                        orderLine: state.orderLineList?[index] ?? OrderLineModel(),
                                        isFlipped: 'received',
                                        orderModel: widget.order,
                                      );
                                } else {
                                  context.read<OrderHistoryBloc>().receieveOrder(
                                        stock: state.orderLineList?[index].stockModel ?? StockModel(),
                                        orderLine: state.orderLineList?[index] ?? OrderLineModel(),
                                        isFlipped: 'pending',
                                        orderModel: widget.order,
                                      );
                                }
                                context.read<OrderHistoryBloc>().updateCheckbox(state.orderLineList?[index], isCheckedAll);
                              }
                            },
                          );
                        }),
                  ),
                )
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
                  child: ATTextfield(
                    hintText: 'Search Item',
                    textEditingController: searchController,
                    onFieldSubmitted: (String? value) {
                      context.read<OrderHistoryBloc>().searchOrderLine(search: value ?? '', order: widget.order);
                    },
                    onChanged: (String value) {
                      EasyDebounce.debounce('deebouncer1', const Duration(milliseconds: 500), () {
                        context.read<OrderHistoryBloc>().searchOrderLine(search: value, order: widget.order);
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
                    child: state.orderLineList?.isNotEmpty == true
                        ? ListView.builder(
                            itemCount: state.orderLineList?.length,
                            itemBuilder: (BuildContext context, index) {
                              bool checkboxValue = state.orderLineList?[index].isChecked ?? false;
                              print('${state.orderLineList?[index].quantity} ${state.orderLineList?[index].ordered}');
                              return Slidable(
                                closeOnScroll: true,
                                startActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  extentRatio: 0.2,
                                  children: <Widget>[
                                    SlidableAction(
                                      onPressed: (BuildContext navContext) async {
                                        await showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) {
                                            orderController.text = '';
                                            orderController.selection = TextSelection.fromPosition(TextPosition(offset: orderController.text.length));

                                            orderNode.requestFocus();

                                            final double onHand = state.orderLineList?[index].stockModel?.onHand ?? 0;
                                            final double quantity = state.orderLineList?[index].quantity ?? 0;
                                            return Container(
                                              padding: EdgeInsets.only(
                                                  left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 30),
                                              child: Wrap(
                                                children: <Widget>[
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      const Padding(
                                                        padding: EdgeInsets.only(bottom: 10),
                                                        child: ATText(
                                                          text: 'Receieve Stock Item',
                                                          fontColor: AppColors.onboardingText,
                                                          fontSize: 18,
                                                          weight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Table(
                                                        columnWidths: const {
                                                          0: FlexColumnWidth(3),
                                                          1: FlexColumnWidth(2),
                                                          2: FlexColumnWidth(2),
                                                          3: FlexColumnWidth(2),
                                                          4: FlexColumnWidth(2),
                                                        },
                                                        children: <TableRow>[
                                                          TableRow(
                                                            children: <Widget>[
                                                              Container(
                                                                color: AppColors.headerGrey,
                                                                padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
                                                                alignment: Alignment.centerLeft,
                                                                child: const ATText(
                                                                  text: 'SKU',
                                                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white),
                                                                ),
                                                              ),
                                                              Container(
                                                                padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                                alignment: Alignment.centerRight,
                                                                color: AppColors.headerGrey,
                                                                child: const ATText(
                                                                  text: 'Ordered',
                                                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white),
                                                                ),
                                                              ),
                                                              Container(
                                                                padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                                alignment: Alignment.centerRight,
                                                                color: AppColors.headerGrey,
                                                                child: const ATText(
                                                                  text: 'Received',
                                                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Table(
                                                        columnWidths: const {
                                                          0: FlexColumnWidth(3),
                                                          1: FlexColumnWidth(2),
                                                          2: FlexColumnWidth(2),
                                                          3: FlexColumnWidth(2),
                                                          4: FlexColumnWidth(2),
                                                        },
                                                        children: <TableRow>[
                                                          TableRow(
                                                            children: <Widget>[
                                                              Container(
                                                                padding: const EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                                alignment: Alignment.centerLeft,
                                                                child: ATText(
                                                                  text: state.orderLineList?[index].stockModel?.sku,
                                                                  fontColor: AppColors.onboardingText,
                                                                  fontSize: 16,
                                                                  weight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              Container(
                                                                padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                                alignment: Alignment.centerRight,
                                                                child: ATText(
                                                                  text: state.orderLineList?[index].ordered
                                                                      .toString()
                                                                      .removeDecimalZeroFormat(state.orderLineList?[index].stockModel?.onOrder ?? 0),
                                                                  fontColor: AppColors.onboardingText,
                                                                  fontSize: 16,
                                                                  weight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              Container(
                                                                padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                                alignment: Alignment.centerRight,
                                                                child: ATText(
                                                                  text: state.orderLineList?[index].quantity
                                                                      .toString()
                                                                      .removeDecimalZeroFormat(state.orderLineList?[index].quantity ?? 0),
                                                                  fontColor: AppColors.onboardingText,
                                                                  fontSize: 16,
                                                                  weight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 10),
                                                        child: ATText(
                                                          text: state.orderLineList?[index].stockModel?.name,
                                                          fontColor: AppColors.onboardingText,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 20),
                                                    child: ATTextfield(
                                                      hintText: 'Receive',
                                                      focusNode: orderNode,
                                                      isNumbersOnly: true,
                                                      textInputType: TextInputType.number,
                                                      textEditingController: orderController,
                                                      textAlign: TextAlign.center,
                                                      textInputAction: TextInputAction.done,

                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 10),
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: KeepElevatedButton(
                                                        isEnabled: !state.isLoading,
                                                        color: AppColors.successGreen,
                                                        onPressed: () => orderController.text.isNotEmpty
                                                            ? context
                                                                .read<OrderHistoryBloc>()
                                                                .receieveOrder(
                                                                  stock: state.orderLineList?[index].stockModel ?? StockModel(),
                                                                  orderLine: state.orderLineList?[index] ?? OrderLineModel(),
                                                                  onOrder: double.parse(
                                                                    orderController.text,
                                                                  ),
                                                                  orderModel: widget.order,
                                                                )
                                                                .then((value) => Navigator.of(context).pop())
                                                            : DialogUtils.showToast(context, 'Item to receive cannot be empty.'),
                                                        text: 'Receive',
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 10),
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: KeepElevatedButton(
                                                        isEnabled: !state.isLoading,
                                                        color: AppColors.criticalRed,
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        text: 'Cancel',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      backgroundColor: AppColors.successGreen,
                                      foregroundColor: AppColors.white,
                                      icon: Icons.edit,
                                    ),
                                  ],
                                ),
                                child: Card(
                                  elevation: 4.0,
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            bool value = state.orderLineList?[index].isChecked ?? false;
                                            value = !value;
                                            context.read<OrderHistoryBloc>().updateCheckbox(state.orderLineList?[index], value);
                                            if (value == true) {
                                              context.read<OrderHistoryBloc>().receieveOrder(
                                                    stock: state.orderLineList?[index].stockModel ?? StockModel(),
                                                    orderLine: state.orderLineList?[index] ?? OrderLineModel(),
                                                    isFlipped: 'received',
                                                    orderModel: widget.order,
                                                  );
                                            } else {
                                              context.read<OrderHistoryBloc>().receieveOrder(
                                                    stock: state.orderLineList?[index].stockModel ?? StockModel(),
                                                    orderLine: state.orderLineList?[index] ?? OrderLineModel(),
                                                    isFlipped: 'pending',
                                                    orderModel: widget.order,
                                                  );
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.only(left: 0, right: 16, top: 0, bottom: 0),
                                          width: double.infinity,
                                          color: !isOrderReceived
                                              ? double.parse(state.orderLineList?[index].quantity.toString() ?? '0') > 0 &&
                                                      double.parse(state.orderLineList?[index].quantity.toString() ?? '0') <
                                                          double.parse(state.orderLineList?[index].ordered.toString() ?? '0')
                                                  ? AppColors.warningOrange
                                                  : double.parse(state.orderLineList?[index].ordered.toString() ?? '0') <=
                                                          double.parse(state.orderLineList?[index].quantity.toString() ?? '0')
                                                      ? AppColors.successGreen
                                                      : AppColors.criticalRed
                                              : AppColors.successGreen,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                width: 45,
                                                height: 45,
                                                child: Checkbox(
                                                    value: checkboxValue,
                                                    activeColor: isCheckedAll == true ? AppColors.white : AppColors.white,
                                                    checkColor: AppColors.successGreen,
                                                    side: MaterialStateBorderSide.resolveWith(
                                                      (states) => const BorderSide(width: 2, color: AppColors.white),
                                                    ),
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        context.read<OrderHistoryBloc>().updateCheckbox(state.orderLineList?[index], value);
                                                        if (value == true) {
                                                          context.read<OrderHistoryBloc>().receieveOrder(
                                                                stock: state.orderLineList?[index].stockModel ?? StockModel(),
                                                                orderLine: state.orderLineList?[index] ?? OrderLineModel(),
                                                                isFlipped: 'received',
                                                                orderModel: widget.order,
                                                              );
                                                        } else {
                                                          context.read<OrderHistoryBloc>().receieveOrder(
                                                                stock: state.orderLineList?[index].stockModel ?? StockModel(),
                                                                orderLine: state.orderLineList?[index] ?? OrderLineModel(),
                                                                isFlipped: 'pending',
                                                                orderModel: widget.order,
                                                              );
                                                        }
                                                      });
                                                    }),
                                              ),
                                              ATText(
                                                text: !isOrderReceived
                                                    ? double.parse(state.orderLineList?[index].quantity.toString() ?? '0') > 0 &&
                                                            double.parse(state.orderLineList?[index].quantity.toString() ?? '0') <
                                                                double.parse(state.orderLineList?[index].ordered.toString() ?? '0')
                                                        ? 'Partial'
                                                        : double.parse(state.orderLineList?[index].ordered.toString() ?? '0') <=
                                                                double.parse(state.orderLineList?[index].quantity.toString() ?? '0')
                                                            ? 'Received!'
                                                            : 'Pending'
                                                    : 'Received!',
                                                fontSize: 15,
                                                fontColor: AppColors.white,
                                                weight: FontWeight.bold,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(3),
                                          1: FlexColumnWidth(2),
                                          2: FlexColumnWidth(2),
                                          3: FlexColumnWidth(2),
                                          4: FlexColumnWidth(2),
                                        },
                                        children: <TableRow>[
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                color: AppColors.headerGrey,
                                                padding: const EdgeInsets.only(left: 8, top: 5, bottom: 5),
                                                alignment: Alignment.centerLeft,
                                                child: const ATText(
                                                  text: 'SKU',
                                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                alignment: Alignment.centerRight,
                                                color: AppColors.headerGrey,
                                                child: const ATText(
                                                  text: 'Ordered',
                                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                alignment: Alignment.centerRight,
                                                color: AppColors.headerGrey,
                                                child: const ATText(
                                                  text: 'Received',
                                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(3),
                                          1: FlexColumnWidth(2),
                                          2: FlexColumnWidth(2),
                                          3: FlexColumnWidth(2),
                                          4: FlexColumnWidth(2),
                                        },
                                        children: <TableRow>[
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding: const EdgeInsets.only(left: 8, top: 5, bottom: 5),
                                                alignment: Alignment.centerLeft,
                                                child: ATText(
                                                  text: state.orderLineList?[index].stockModel?.sku,
                                                  fontColor: AppColors.onboardingText,
                                                  fontSize: 16,
                                                  weight: FontWeight.bold,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                alignment: Alignment.centerRight,
                                                child: ATText(
                                                  text: state.orderLineList?[index].ordered
                                                      .toString()
                                                      .removeDecimalZeroFormat(state.orderLineList?[index].ordered ?? 0),
                                                  fontColor: AppColors.onboardingText,
                                                  fontSize: 16,
                                                  weight: FontWeight.bold,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                alignment: Alignment.centerRight,
                                                child: ATText(
                                                  text: state.orderLineList?[index].quantity
                                                      .toString()
                                                      .removeDecimalZeroFormat(state.orderLineList?[index].quantity ?? 0),
                                                  fontColor: AppColors.onboardingText,
                                                  fontSize: 16,
                                                  weight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 8),
                                        alignment: Alignment.centerLeft,
                                        child: ATText(
                                          text: state.orderLineList?[index].stockModel?.name,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget itemCard(OrderHistoryState state, int index, {bool isOrderReceived = false}) {
    bool isChecked = false;
    return Card(
      elevation: 4.0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
            width: double.infinity,
            color: !isOrderReceived
                ? double.parse(state.orderLineList?[index].stockModel?.onHand.toString() ?? '0') > 0 &&
                        double.parse(state.orderLineList?[index].stockModel?.onHand.toString() ?? '0') <
                            double.parse(state.orderLineList?[index].originalQuantity.toString() ?? '0')
                    ? AppColors.warningOrange
                    : double.parse(state.orderLineList?[index].stockModel?.onOrder.toString() ?? '0') ==
                            double.parse(state.orderLineList?[index].stockModel?.order.toString() ?? '0')
                        ? AppColors.successGreen
                        : AppColors.criticalRed
                : AppColors.successGreen,
            child: Row(
              children: <Widget>[
                Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = !isChecked;
                      });
                    }),
                ATText(
                  text: !isOrderReceived
                      ? double.parse(state.orderLineList?[index].quantity.toString() ?? '0') > 0 &&
                              double.parse(state.orderLineList?[index].quantity.toString() ?? '0') <
                                  double.parse(state.orderLineList?[index].ordered.toString() ?? '0')
                          ? 'Partial'
                          : double.parse(state.orderLineList?[index].ordered.toString() ?? '0') ==
                                  double.parse(state.orderLineList?[index].quantity.toString() ?? '0')
                              ? 'Received!'
                              : 'Pending'
                      : 'Received!',
                  fontSize: 15,
                  fontColor: AppColors.white,
                  weight: FontWeight.bold,
                )
              ],
            ),
          ),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
              4: FlexColumnWidth(2),
            },
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  Container(
                    color: AppColors.headerGrey,
                    padding: const EdgeInsets.only(left: 8, top: 5, bottom: 5),
                    alignment: Alignment.centerLeft,
                    child: const ATText(
                      text: 'SKU',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                    alignment: Alignment.centerRight,
                    color: AppColors.headerGrey,
                    child: const ATText(
                      text: 'Ordered',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                    alignment: Alignment.centerRight,
                    color: AppColors.headerGrey,
                    child: const ATText(
                      text: 'Received',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
              4: FlexColumnWidth(2),
            },
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(left: 8, top: 5, bottom: 5),
                    alignment: Alignment.centerLeft,
                    child: ATText(
                      text: state.orderLineList?[index].stockModel?.sku,
                      fontColor: AppColors.onboardingText,
                      fontSize: 16,
                      weight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                    alignment: Alignment.centerRight,
                    child: ATText(
                      text: state.orderLineList?[index].ordered.toString().removeDecimalZeroFormat(state.orderLineList?[index].ordered ?? 0),
                      fontColor: AppColors.onboardingText,
                      fontSize: 16,
                      weight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                    alignment: Alignment.centerRight,
                    child: ATText(
                      text: state.orderLineList?[index].quantity.toString().removeDecimalZeroFormat(state.orderLineList?[index].quantity ?? 0),
                      fontColor: AppColors.onboardingText,
                      fontSize: 16,
                      weight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(left: 8),
            alignment: Alignment.centerLeft,
            child: ATText(
              text: state.orderLineList?[index].stockModel?.name,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  void showAllChecker(OrderHistoryState state) {
    int itemReceivedCounter = 0;
    for (OrderLineModel item in state.orderLineList ?? <OrderLineModel>[]) {
      if (item.status != 'partial' && item.status != 'pending' && item.status != null) {
        itemReceivedCounter++;
      }
    }
    if (itemReceivedCounter == state.orderLineList?.length) {
      isCheckedAll = true;
    } else {
      isCheckedAll = false;
    }
  }
}
