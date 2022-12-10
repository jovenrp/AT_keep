import 'package:easy_debounce/easy_debounce.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
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

  final List<FlipCardController> _controller = <FlipCardController>[];
  @override
  void initState() {
    super.initState();
    context.read<OrderHistoryBloc>().getOrderLines(order: widget.order);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderHistoryBloc, OrderHistoryState>(
        listener: (BuildContext context, OrderHistoryState state) {
          for (OrderLineModel item in state.orderLineList ?? <OrderLineModel>[]) {
            _controller.add(FlipCardController());
          }
        },
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
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
                      child: ATTextfield(
                        hintText: 'Search Item',
                        textEditingController: searchController,
                        onFieldSubmitted: (String? value) {
                          /*context
                              .read<OrderHistoryBloc>()
                              .searchStocks(search: value ?? '');*/
                        },
                        onChanged: (String value) {
                          EasyDebounce.debounce('deebouncer1', const Duration(milliseconds: 500), () {
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

                            return Slidable(
                              closeOnScroll: true,
                              endActionPane: ActionPane(
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
                                            padding:
                                                EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 30),
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
                                                                text: 'OnHand',
                                                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white),
                                                              ),
                                                            ),
                                                            Container(
                                                              padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                              alignment: Alignment.centerRight,
                                                              color: AppColors.headerGrey,
                                                              child: const ATText(
                                                                text: 'Qty',
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
                                                                text: state.orderLineList?[index].stockModel?.onHand
                                                                    .toString()
                                                                    .removeDecimalZeroFormat(state.orderLineList?[index].stockModel?.onHand ?? 0),
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
                                                    textEditingController: orderController,
                                                    textAlign: TextAlign.center,
                                                    textInputAction: TextInputAction.done,
                                                    isNumbersOnly: true,
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
                                                          ? quantity > onHand
                                                              ? context
                                                                  .read<OrderHistoryBloc>()
                                                                  .receieveOrder(
                                                                    stock: state.orderLineList?[index].stockModel ?? StockModel(),
                                                                    orderLine: state.orderLineList?[index] ?? OrderLineModel(),
                                                                    onOrder: double.parse(orderController.text),
                                                                  )
                                                                  .then((value) => Navigator.of(context).pop())
                                                              : DialogUtils.showToast(
                                                                  context, 'Quantity to receive cannot be greater than the order.')
                                                          : DialogUtils.showToast(context, 'Item to receive cannot be empty.'),
                                                      text: 'Receive',
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
                              child: GestureDetector(
                                onDoubleTap: () {
                                  context.read<OrderHistoryBloc>().receieveOrder(
                                    stock: state.orderLineList?[index].stockModel ?? StockModel(),
                                    orderLine: state.orderLineList?[index] ?? OrderLineModel(),
                                    isFlipped: 'pending',
                                  );
                                  _controller[index].toggleCard();
                                },
                                child: FlipCard(
                                  controller: _controller[index],
                                  direction: FlipDirection.VERTICAL,
                                  flipOnTouch: state.orderLineList?[index].quantity == 0 ? false : true,
                                  onFlipDone: (bool? flip) {
                                    if (flip == true) {
                                      context.read<OrderHistoryBloc>().receieveOrder(
                                        stock: state.orderLineList?[index].stockModel ?? StockModel(),
                                        orderLine: state.orderLineList?[index] ?? OrderLineModel(),
                                        isFlipped: 'received',
                                      );
                                    } else {
                                      context.read<OrderHistoryBloc>().receieveOrder(
                                        stock: state.orderLineList?[index].stockModel ?? StockModel(),
                                        orderLine: state.orderLineList?[index] ?? OrderLineModel(),
                                        isFlipped: 'pending',
                                      );
                                    }
                                  },
                                  front: state.orderLineList?[index].quantity == 0 ? frontCard(state, index, isOrderReceived: true) : frontCard(state, index, isOrderReceived: false),
                                  back: frontCard(state, index, isOrderReceived: true),
                                ),
                              ),
                            );
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

  Widget frontCard(OrderHistoryState state, int index, {bool isOrderReceived = false}) {
    return Card(
      elevation: 4.0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
            width: double.infinity,
            color: !isOrderReceived ?  double.parse(state.orderLineList?[index].stockModel?.onHand.toString() ?? '0') > 0 && double.parse(state.orderLineList?[index].stockModel?.onHand.toString() ?? '0') < double.parse(state.orderLineList?[index].originalQuantity.toString() ?? '0') ? AppColors.warningOrange : AppColors.criticalRed : AppColors.successGreen,
            child: ATText(
              text: !isOrderReceived ?  double.parse(state.orderLineList?[index].stockModel?.onHand.toString() ?? '0') > 0 && double.parse(state.orderLineList?[index].stockModel?.onHand.toString() ?? '0') < double.parse(state.orderLineList?[index].originalQuantity.toString() ?? '0') ? 'Partial' : 'Pending' : 'Received!',
              fontSize: 15,
              fontColor: AppColors.white,
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
                      text: 'OnHand',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                    alignment: Alignment.centerRight,
                    color: AppColors.headerGrey,
                    child: const ATText(
                      text: 'Qty',
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
                      text: state.orderLineList?[index].stockModel?.onHand
                          .toString()
                          .removeDecimalZeroFormat(state.orderLineList?[index].stockModel?.onHand ?? 0),
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
    );
  }
}
