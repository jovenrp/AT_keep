import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:keep/core/domain/utils/string_extensions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../application/domain/models/application_config.dart';
import '../../../core/data/mixin/back_pressed_mixin.dart';
import '../../../core/domain/utils/constants/app_colors.dart';
import '../../../core/presentation/widgets/at_loading_indicator.dart';
import '../../../core/presentation/widgets/at_text.dart';
import '../../../core/presentation/widgets/at_textfield.dart';
import '../../../core/presentation/widgets/keep_elevated_button.dart';
import '../../manage_stock/bloc/manage_stock_bloc.dart';
import '../../manage_stock/bloc/manage_stock_state.dart';

class OrderStockScreen extends StatefulWidget {
  const OrderStockScreen({Key? key, this.config}) : super(key: key);

  static const String routeName = '/orderStock';
  static const String screenName = 'orderStockScreen';

  final ApplicationConfig? config;

  static ModalRoute<OrderStockScreen> route({ApplicationConfig? config}) => MaterialPageRoute<OrderStockScreen>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => OrderStockScreen(
          config: config,
        ),
      );

  @override
  _OrderStockScreen createState() => _OrderStockScreen();
}

class _OrderStockScreen extends State<OrderStockScreen> with BackPressedMixin {
  late TextEditingController searchController;
  late TextEditingController orderController;
  late FocusNode orderNode;

  bool? isShowAll = true;

  final RefreshController refreshController = RefreshController();
  bool canRefresh = true;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    orderController = TextEditingController();
    orderNode = FocusNode();

    context.read<ManageStockBloc>().getStocks();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManageStockBloc, ManageStockState>(
      listener: (BuildContext context, ManageStockState state) {
        if (!state.isLoading) {
          refreshController.refreshCompleted();
        }
        if (state.formResponse?.error == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 300.0),
              content: Text(state.formResponse?.message ?? ''),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      builder: (BuildContext context, ManageStockState state) {
        return SafeArea(
          child: WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                  backgroundColor: AppColors.gomoRedOverlay,
                  iconTheme: const IconThemeData(color: AppColors.background),
                  title: const ATText(
                    text: 'Order Stock',
                    fontColor: AppColors.background,
                    fontSize: 18,
                    weight: FontWeight.bold,
                  )),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
                    child: ATTextfield(
                      hintText: 'Search Item',
                      textEditingController: searchController,
                      onFieldSubmitted: (String? value) {
                        context.read<ManageStockBloc>().searchStocks(search: value ?? '');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: CheckboxListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.all(0),
                            title: Transform.translate(
                              offset: const Offset(-20, 0),
                              child: const ATText(
                                text: 'Show all',
                                weight: FontWeight.bold,
                                fontSize: 14,
                                fontColor: AppColors.tertiary,
                              ),
                            ),
                            activeColor: AppColors.successGreen,
                            value: isShowAll,
                            onChanged: (bool? value) {
                              setState(() {
                                isShowAll = value;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20, left: 100),
                            child: Row(
                              children: const <Widget>[
                                ATText(
                                  text: 'Send',
                                  weight: FontWeight.bold,
                                  fontSize: 14,
                                  fontColor: AppColors.tertiary,
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.send,
                                  color: AppColors.secondary,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: state.isLoading,
                    child: const Center(
                      child: ATLoadingIndicator(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Table(
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
                              padding: const EdgeInsets.only(left: 18, top: 5, bottom: 5),
                              alignment: Alignment.centerLeft,
                              child: const ATText(
                                text: 'SKU',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                              color: AppColors.headerGrey,
                              alignment: Alignment.centerRight,
                              child: const ATText(
                                text: 'Min',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                              alignment: Alignment.centerRight,
                              color: AppColors.headerGrey,
                              child: const ATText(
                                text: 'Max',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                              alignment: Alignment.centerRight,
                              color: AppColors.headerGrey,
                              child: const ATText(
                                text: 'OnHand',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                              alignment: Alignment.centerRight,
                              color: AppColors.headerGrey,
                              child: const ATText(
                                text: 'Qty',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: state.stocksList?.isEmpty == true,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          SizedBox(height: 70,),
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 70,
                            color: AppColors.tertiary,
                          ),
                          ATText(text: 'No orders at the moment.', fontSize: 20, fontColor: AppColors.tertiary,)
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SmartRefresher(
                      enablePullDown: canRefresh,
                      onRefresh: _forcedRefresh,
                      controller: refreshController,
                      header: const WaterDropMaterialHeader(
                        color: AppColors.white,
                        backgroundColor: AppColors.greyHeader,
                      ),
                      child: ListView.builder(
                          itemCount: state.stocksList?.length,
                          itemBuilder: (BuildContext context, index) {
                            return Visibility(
                              visible: isShowAll == true ||
                                  (double.parse(context.read<ManageStockBloc>().getQuantity(state.stocksList?[index]).toString()) > 0),
                              child: Slidable(
                                key: ValueKey<int>(index),
                                child: GestureDetector(
                                  onTap: () async {
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        orderController.text = '';
                                        orderController.selection = TextSelection.fromPosition(TextPosition(offset: orderController.text.length));

                                        orderNode.requestFocus();

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
                                                      text: 'Order Stock Item',
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
                                                            color: AppColors.headerGrey,
                                                            alignment: Alignment.centerRight,
                                                            child: const ATText(
                                                              text: 'Min',
                                                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                            alignment: Alignment.centerRight,
                                                            color: AppColors.headerGrey,
                                                            child: const ATText(
                                                              text: 'Max',
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
                                                            padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                            alignment: Alignment.centerLeft,
                                                            child: ATText(
                                                              text: state.stocksList?[index].sku,
                                                              fontColor: AppColors.onboardingText,
                                                              fontSize: 16,
                                                              weight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                            alignment: Alignment.centerRight,
                                                            child: ATText(
                                                              text: state.stocksList?[index].minQuantity
                                                                      .toString()
                                                                      .removeDecimalZeroFormat(state.stocksList?[index].minQuantity ?? 0) ??
                                                                  '',
                                                              fontColor: AppColors.onboardingText,
                                                              fontSize: 16,
                                                              weight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                            alignment: Alignment.centerRight,
                                                            child: ATText(
                                                              text: state.stocksList?[index].maxQuantity
                                                                      .toString()
                                                                      .removeDecimalZeroFormat(state.stocksList?[index].maxQuantity ?? 0) ??
                                                                  '',
                                                              fontColor: AppColors.onboardingText,
                                                              fontSize: 16,
                                                              weight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                            alignment: Alignment.centerRight,
                                                            child: ATText(
                                                              text: state.stocksList?[index].onHand
                                                                      .toString()
                                                                      .removeDecimalZeroFormat(state.stocksList?[index].onHand ?? 0) ??
                                                                  '',
                                                              fontColor: AppColors.onboardingText,
                                                              fontSize: 16,
                                                              weight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                            alignment: Alignment.centerRight,
                                                            child: ATText(
                                                              text: state.stocksList?[index].quantity
                                                                      .toString()
                                                                      .removeDecimalZeroFormat(state.stocksList?[index].quantity ?? 0) ??
                                                                  '',
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
                                                      text: state.stocksList?[index].name,
                                                      fontColor: AppColors.onboardingText,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 20),
                                                child: ATTextfield(
                                                  hintText: 'Order',
                                                  focusNode: orderNode,
                                                  textEditingController: orderController,
                                                  textAlign: TextAlign.center,
                                                  textInputAction: TextInputAction.next,
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
                                                    onPressed: () => context
                                                        .read<ManageStockBloc>()
                                                        .orderStock(
                                                            stockModel: state.stocksList?[index],
                                                            index: index,
                                                            isIn: true,
                                                            quantity: double.parse(orderController.text))
                                                        .then((_) {
                                                      Navigator.of(context).pop();
                                                      context.read<ManageStockBloc>().getStocks();
                                                    }),
                                                    text: 'Order',
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 5),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: KeepElevatedButton(
                                                    color: AppColors.criticalRed,
                                                    isEnabled: !state.isLoading,
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                            width: 10.0,
                                            color: state.stocksList?[index].maxQuantity == 0
                                                ? AppColors.subtleGrey
                                                : double.parse(state.stocksList?[index].maxQuantity.toString() ?? '0') <=
                                                        double.parse(state.stocksList?[index].onHand.toString() ?? '0')
                                                    ? AppColors.successGreen
                                                    : state.stocksList?[index].onHand == 0
                                                        ? AppColors.criticalRed
                                                        : AppColors.warningOrange),
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 10),
                                      color: index % 2 == 1 ? AppColors.lightBlue : AppColors.white,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
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
                                                    padding: const EdgeInsets.only(left: 8),
                                                    alignment: Alignment.centerLeft,
                                                    child: ATText(
                                                        text: state.stocksList?[index].sku,
                                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tertiary)),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.only(right: 8),
                                                    alignment: Alignment.centerRight,
                                                    child: ATText(
                                                      text: state.stocksList?[index].minQuantity
                                                          .toString()
                                                          .removeDecimalZeroFormat(state.stocksList?[index].minQuantity ?? 0),
                                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.only(right: 8),
                                                    alignment: Alignment.centerRight,
                                                    child: ATText(
                                                      text: state.stocksList?[index].maxQuantity
                                                          .toString()
                                                          .removeDecimalZeroFormat(state.stocksList?[index].maxQuantity ?? 0),
                                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.only(right: 18),
                                                    alignment: Alignment.centerRight,
                                                    child: ATText(
                                                      text: state.stocksList?[index].onHand
                                                          .toString()
                                                          .removeDecimalZeroFormat(state.stocksList?[index].onHand ?? 0),
                                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.only(right: 8),
                                                    alignment: Alignment.centerRight,
                                                    child: ATText(
                                                      text: context.read<ManageStockBloc>().getQuantity(state.stocksList?[index]),
                                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(left: 8, right: 8, top: 5),
                                            alignment: Alignment.centerLeft,
                                            child: ATText(
                                                text: state.stocksList?[index].name, style: const TextStyle(fontSize: 15, color: AppColors.tertiary)),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _forcedRefresh() {
    canRefresh = true;
    context.read<ManageStockBloc>().getStocks();
  }
}
