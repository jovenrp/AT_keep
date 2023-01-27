import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:keep/core/domain/utils/string_extensions.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';
import 'package:location/location.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../application/domain/models/application_config.dart';
import '../../../core/data/mixin/back_pressed_mixin.dart';
import '../../../core/domain/utils/constants/app_colors.dart';
import '../../../core/presentation/widgets/at_loading_indicator.dart';
import '../../../core/presentation/widgets/at_text.dart';
import '../../../core/presentation/widgets/at_textfield.dart';
import '../../../core/presentation/widgets/keep_elevated_button.dart';
import '../../profile/data/models/profile_model.dart';
import '../bloc/manage_stock_bloc.dart';
import '../bloc/manage_stock_state.dart';

class OrderStockScreen extends StatefulWidget {
  const OrderStockScreen({Key? key, this.config}) : super(key: key);

  static const String routeName = '/orderStock';
  static const String screenName = 'orderStockScreen';

  final ApplicationConfig? config;

  static ModalRoute<OrderStockScreen> route({ApplicationConfig? config}) =>
      MaterialPageRoute<OrderStockScreen>(
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

  bool isSkuSort = false;
  bool isMinSort = false;
  bool isMaxSort = false;
  bool isOnHandSort = false;
  bool isQuantitySorty = false;

  late PermissionStatus _permissionGranted;
  bool serviceEnabled = false;
  Location location = Location();
  late LocationData locationData;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    orderController = TextEditingController();
    orderNode = FocusNode();

    context.read<ManageStockBloc>().getStocks();
    context.read<ManageStockBloc>().getProfiles();
    hasPermission();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManageStockBloc, ManageStockState>(
      listener: (BuildContext context, ManageStockState state) {
        if (!state.isLoading) {
          refreshController.refreshCompleted();
        }
        if (state.isPdfGenerated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Order sent!'),
                  InkWell(
                    onTap: () =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 100000000),
            ),
          );
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
              ScaffoldMessenger.of(context).clearSnackBars();
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
                ),
                actions: <Widget>[
                  InkWell(
                    onTap: () {
                      if (state.user == null || state.vendor == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                                'Fill up the profile settings before send an order.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        bool isShareable = false;
                        for (StockModel item
                            in state.stocksList ?? <StockModel>[]) {
                          if (item.isOrdered != true &&
                              double.parse(context
                                      .read<ManageStockBloc>()
                                      .getQuantity(item)
                                      .toString()) >
                                  0) {
                            isShareable = true;
                          }
                        }
                        if (isShareable) {
                          context.read<ManageStockBloc>().generatePdfOrder(
                              stockModel: state.stocksList,
                              user: state.user ?? ProfileModel(),
                              vendor: state.vendor ?? ProfileModel(),
                              action: 'view');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text('No stock order to be viewed.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 9, left: 9),
                      child: Icon(
                        Icons.preview_outlined,
                        size: 30,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      //share native
                      if (state.user == null || state.vendor == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                                'Fill up the profile settings before send an order.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        bool isShareable = false;
                        for (StockModel item
                            in state.stocksList ?? <StockModel>[]) {
                          if (item.isOrdered != true &&
                              double.parse(context
                                      .read<ManageStockBloc>()
                                      .getQuantity(item)
                                      .toString()) >
                                  0) {
                            isShareable = true;
                          }
                        }
                        if (isShareable) {
                          context.read<ManageStockBloc>().generatePdfOrder(
                              stockModel: state.stocksList,
                              user: state.user ?? ProfileModel(),
                              vendor: state.vendor ?? ProfileModel(),
                              action: 'share');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text('No stock order to be shared.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 18, left: 9),
                      child: Icon(
                        Icons.share,
                        size: 30,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
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
                            .read<ManageStockBloc>()
                            .searchStocks(search: value ?? '');
                      },
                      onChanged: (String value) {
                        EasyDebounce.debounce(
                            'deebouncer1', const Duration(milliseconds: 500),
                            () {
                          context
                              .read<ManageStockBloc>()
                              .searchStocks(search: value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  /*Padding(
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
                        */ /*Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  if (state.user == null || state.vendor == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        content: Text('Fill up the profile settings before send an order.'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  } else {
                                    context.read<ManageStockBloc>().generatePdfOrder(
                                          stockList: state.stocksList,
                                          user: state.user ?? ProfileModel(),
                                          vendor: state.vendor ?? ProfileModel(),
                                        );
                                  }
                                },
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
                                        Icons.share,
                                        color: AppColors.secondary,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )*/ /*
                      ],
                    ),
                  ),*/
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
                            GestureDetector(
                              onTap: () {
                                context.read<ManageStockBloc>().sortStockOrders(
                                    stockList: state.stocksList,
                                    column: 'sku',
                                    sortBy: isSkuSort);
                                setState(() {
                                  isSkuSort = !isSkuSort;
                                });
                              },
                              child: Container(
                                color: AppColors.headerGrey,
                                padding: const EdgeInsets.only(
                                    left: 18, top: 5, bottom: 5),
                                alignment: Alignment.centerLeft,
                                child: const ATText(
                                  text: 'SKU / DESC',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<ManageStockBloc>().sortStockOrders(
                                    stockList: state.stocksList,
                                    column: 'min',
                                    sortBy: isMinSort);
                                setState(() {
                                  isMinSort = !isMinSort;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    right: 8, top: 5, bottom: 5),
                                color: AppColors.headerGrey,
                                alignment: Alignment.centerRight,
                                child: const ATText(
                                  text: 'Min',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<ManageStockBloc>().sortStockOrders(
                                    stockList: state.stocksList,
                                    column: 'max',
                                    sortBy: isMaxSort);
                                setState(() {
                                  isMaxSort = !isMaxSort;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    right: 8, top: 5, bottom: 5),
                                alignment: Alignment.centerRight,
                                color: AppColors.headerGrey,
                                child: const ATText(
                                  text: 'Max',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<ManageStockBloc>().sortStockOrders(
                                    stockList: state.stocksList,
                                    column: 'onHand',
                                    sortBy: isOnHandSort);
                                setState(() {
                                  isOnHandSort = !isOnHandSort;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    right: 8, top: 5, bottom: 5),
                                alignment: Alignment.centerRight,
                                color: AppColors.headerGrey,
                                child: const ATText(
                                  text: 'OnHand',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<ManageStockBloc>().sortStockOrders(
                                    stockList: state.stocksList,
                                    column: 'quantity',
                                    sortBy: isQuantitySorty);
                                setState(() {
                                  isQuantitySorty = !isQuantitySorty;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    right: 8, top: 5, bottom: 5),
                                alignment: Alignment.centerRight,
                                color: AppColors.headerGrey,
                                child: const ATText(
                                  text: 'Qty',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white),
                                ),
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
                          SizedBox(
                            height: 70,
                          ),
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 70,
                            color: AppColors.tertiary,
                          ),
                          ATText(
                            text: 'Nothing to see here.',
                            fontSize: 20,
                            fontColor: AppColors.tertiary,
                          )
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
                              visible: state.stocksList?[index].isOrdered !=
                                      true &&
                                  double.parse(context
                                          .read<ManageStockBloc>()
                                          .getQuantity(state.stocksList?[index])
                                          .toString()) >
                                      0,
                              child: Slidable(
                                key: ValueKey<int>(index),
                                child: GestureDetector(
                                  onTap: () async {
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        orderController.text = '';
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          orderController.selection =
                                              TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset: orderController
                                                          .text.length));

                                          orderNode.requestFocus();
                                        });

                                        return Container(
                                          padding: EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 20,
                                              bottom: MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom +
                                                  30),
                                          child: Wrap(
                                            children: <Widget>[
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10),
                                                    child: ATText(
                                                      text: 'Order Stock Item',
                                                      fontColor: AppColors
                                                          .onboardingText,
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
                                                            color: AppColors
                                                                .headerGrey,
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 5,
                                                                    top: 5,
                                                                    bottom: 5),
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: const ATText(
                                                              text: 'SKU',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColors
                                                                      .white),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 8,
                                                                    top: 5,
                                                                    bottom: 5),
                                                            color: AppColors
                                                                .headerGrey,
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: const ATText(
                                                              text: 'Min',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColors
                                                                      .white),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 8,
                                                                    top: 5,
                                                                    bottom: 5),
                                                            alignment: Alignment
                                                                .centerRight,
                                                            color: AppColors
                                                                .headerGrey,
                                                            child: const ATText(
                                                              text: 'Max',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColors
                                                                      .white),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 8,
                                                                    top: 5,
                                                                    bottom: 5),
                                                            alignment: Alignment
                                                                .centerRight,
                                                            color: AppColors
                                                                .headerGrey,
                                                            child: const ATText(
                                                              text: 'OnHand',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColors
                                                                      .white),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 8,
                                                                    top: 5,
                                                                    bottom: 5),
                                                            alignment: Alignment
                                                                .centerRight,
                                                            color: AppColors
                                                                .headerGrey,
                                                            child: const ATText(
                                                              text: 'Qty',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColors
                                                                      .white),
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
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 8,
                                                                    top: 5,
                                                                    bottom: 5),
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: ATText(
                                                              text: state
                                                                  .stocksList?[
                                                                      index]
                                                                  .sku,
                                                              fontColor: AppColors
                                                                  .onboardingText,
                                                              fontSize: 16,
                                                              weight: FontWeight
                                                                  .bold,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 8,
                                                                    top: 5,
                                                                    bottom: 5),
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: ATText(
                                                              text: state
                                                                      .stocksList?[
                                                                          index]
                                                                      .minQuantity
                                                                      .toString()
                                                                      .removeDecimalZeroFormat(state
                                                                              .stocksList?[index]
                                                                              .minQuantity ??
                                                                          0) ??
                                                                  '',
                                                              fontColor: AppColors
                                                                  .onboardingText,
                                                              fontSize: 16,
                                                              weight: FontWeight
                                                                  .bold,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 8,
                                                                    top: 5,
                                                                    bottom: 5),
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: ATText(
                                                              text: state
                                                                      .stocksList?[
                                                                          index]
                                                                      .maxQuantity
                                                                      .toString()
                                                                      .removeDecimalZeroFormat(state
                                                                              .stocksList?[index]
                                                                              .maxQuantity ??
                                                                          0) ??
                                                                  '',
                                                              fontColor: AppColors
                                                                  .onboardingText,
                                                              fontSize: 16,
                                                              weight: FontWeight
                                                                  .bold,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 8,
                                                                    top: 5,
                                                                    bottom: 5),
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: ATText(
                                                              text: state
                                                                      .stocksList?[
                                                                          index]
                                                                      .onHand
                                                                      .toString()
                                                                      .removeDecimalZeroFormat(state
                                                                              .stocksList?[index]
                                                                              .onHand ??
                                                                          0) ??
                                                                  '',
                                                              fontColor: AppColors
                                                                  .onboardingText,
                                                              fontSize: 16,
                                                              weight: FontWeight
                                                                  .bold,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 8,
                                                                    top: 5,
                                                                    bottom: 5),
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: ATText(
                                                              text: context
                                                                  .read<
                                                                      ManageStockBloc>()
                                                                  .getQuantity(
                                                                      state.stocksList?[
                                                                          index]),
                                                              fontColor: AppColors
                                                                  .onboardingText,
                                                              fontSize: 16,
                                                              weight: FontWeight
                                                                  .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    child: ATText(
                                                      text: state
                                                          .stocksList?[index]
                                                          .name,
                                                      fontColor: AppColors
                                                          .onboardingText,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 20),
                                                child: ATTextfield(
                                                  hintText: 'Order',
                                                  focusNode: orderNode,
                                                  textEditingController:
                                                      orderController,
                                                  textAlign: TextAlign.center,
                                                  isNumbersOnly: false,
                                                  textInputType:
                                                      TextInputType.number,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: KeepElevatedButton(
                                                    isEnabled: !state.isLoading,
                                                    color:
                                                        AppColors.successGreen,
                                                    onPressed: () => context
                                                        .read<ManageStockBloc>()
                                                        .orderStock(
                                                            stockModel: state
                                                                    .stocksList?[
                                                                index],
                                                            index: index,
                                                            isIn: true,
                                                            quantity: double.parse(
                                                                orderController
                                                                    .text))
                                                        .then((_) {
                                                      Navigator.of(context)
                                                          .pop();
                                                      context
                                                          .read<
                                                              ManageStockBloc>()
                                                          .getStocks();
                                                    }),
                                                    text: 'Order',
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: KeepElevatedButton(
                                                    color:
                                                        AppColors.criticalRed,
                                                    isEnabled: !state.isLoading,
                                                    onPressed: () {
                                                      /*orderController.text = '0';
                                                      Future.delayed(const Duration(milliseconds: 100), () {
                                                        orderNode.requestFocus();
                                                      });*/
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
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
                                            color: state.stocksList?[index]
                                                        .maxQuantity ==
                                                    0
                                                ? AppColors.subtleGrey
                                                : double.parse(state
                                                                .stocksList?[
                                                                    index]
                                                                .maxQuantity
                                                                .toString() ??
                                                            '0') <=
                                                        double.parse(state
                                                                .stocksList?[
                                                                    index]
                                                                .onHand
                                                                .toString() ??
                                                            '0')
                                                    ? AppColors.successGreen
                                                    : state.stocksList?[index]
                                                                .onHand ==
                                                            0
                                                        ? AppColors.criticalRed
                                                        : AppColors
                                                            .warningOrange),
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 10),
                                      color: index % 2 == 1
                                          ? AppColors.lightBlue
                                          : AppColors.white,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: ATText(
                                                        text: state
                                                            .stocksList?[index]
                                                            .sku,
                                                        style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColors
                                                                .tertiary)),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8),
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: ATText(
                                                      text: state
                                                          .stocksList?[index]
                                                          .minQuantity
                                                          .toString()
                                                          .removeDecimalZeroFormat(state
                                                                  .stocksList?[
                                                                      index]
                                                                  .minQuantity ??
                                                              0),
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .tertiary),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8),
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: ATText(
                                                      text: state
                                                          .stocksList?[index]
                                                          .maxQuantity
                                                          .toString()
                                                          .removeDecimalZeroFormat(state
                                                                  .stocksList?[
                                                                      index]
                                                                  .maxQuantity ??
                                                              0),
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .tertiary),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 18),
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: ATText(
                                                      text: state
                                                          .stocksList?[index]
                                                          .onHand
                                                          .toString()
                                                          .removeDecimalZeroFormat(
                                                              state
                                                                      .stocksList?[
                                                                          index]
                                                                      .onHand ??
                                                                  0),
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .tertiary),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8),
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: ATText(
                                                      text: context
                                                          .read<
                                                              ManageStockBloc>()
                                                          .getQuantity(
                                                              state.stocksList?[
                                                                  index]),
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .tertiary),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(
                                                left: 8, right: 8, top: 5),
                                            alignment: Alignment.centerLeft,
                                            child: ATText(
                                                text: state
                                                    .stocksList?[index].name,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: AppColors.tertiary)),
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

  Future<void> hasPermission() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
                'Location permission not granted, Location will not be saved.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        hasLocationService();
      }
    } else {
      hasLocationService();
    }
  }

  Future<void> hasLocationService() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
                'Location service not granted, Location will not be saved.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      locationData = await location.getLocation();
      context
          .read<ManageStockBloc>()
          .emitLocationData(locationData: locationData);
      /*ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Location captured.'),
          duration: Duration(seconds: 2),
        ),
      );*/
    }
  }

  void _forcedRefresh() {
    canRefresh = true;
    context.read<ManageStockBloc>().getStocks();
  }
}
