import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:keep/core/domain/utils/string_extensions.dart';
import 'package:keep/core/presentation/widgets/at_text.dart';
import 'package:keep/core/presentation/widgets/keep_elevated_button.dart';
import 'package:keep/presentation/manage_stock/bloc/manage_stock_bloc.dart';
import 'package:keep/presentation/manage_stock/bloc/manage_stock_state.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../application/domain/models/application_config.dart';
import '../../../core/data/mixin/back_pressed_mixin.dart';
import '../../../core/domain/utils/constants/app_colors.dart';
import '../../../core/presentation/utils/dialog_utils.dart';
import '../../../core/presentation/widgets/at_loading_indicator.dart';
import '../../../core/presentation/widgets/at_textfield.dart';
import '../../scanners/qr_screen.dart';
import '../data/models/form_model.dart';

class ManageStockScreen extends StatefulWidget {
  const ManageStockScreen({Key? key, this.config}) : super(key: key);

  static const String routeName = '/manageStock';
  static const String screenName = 'manageStockScreen';

  final ApplicationConfig? config;

  static ModalRoute<ManageStockScreen> route({ApplicationConfig? config}) => MaterialPageRoute<ManageStockScreen>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => ManageStockScreen(
          config: config,
        ),
      );

  @override
  _ManageStockScreen createState() => _ManageStockScreen();
}

class _ManageStockScreen extends State<ManageStockScreen> with BackPressedMixin {
  bool isFloatingShow = true;
  late TextEditingController searchController = TextEditingController();
  late TextEditingController skuController = TextEditingController();
  late TextEditingController nameController = TextEditingController();
  late TextEditingController numController = TextEditingController();
  late TextEditingController minController = TextEditingController();
  late TextEditingController maxController = TextEditingController();
  late TextEditingController orderController = TextEditingController();
  late TextEditingController adjustController = TextEditingController();
  late FocusNode searchNode = FocusNode();
  late FocusNode skuNode = FocusNode();
  late FocusNode numNode = FocusNode();
  late FocusNode nameNode = FocusNode();
  late FocusNode minNode = FocusNode();
  late FocusNode maxNode = FocusNode();
  late FocusNode orderNode = FocusNode();
  late FocusNode adjustNode = FocusNode();
  late FocusNode submitNode = FocusNode();

  final RefreshController refreshController = RefreshController();
  bool canRefresh = true;
  bool skuHasFocus = false;

  bool isSkuSort = false;
  bool isMinSort = false;
  bool isMaxSort = false;
  bool isOnHandSort = false;

  @override
  void initState() {
    super.initState();

    context.read<ManageStockBloc>().getStocks();

    skuNode.addListener(() {
      setState(() {
        if (skuNode.hasFocus) {
          skuController.selection = TextSelection(baseOffset: 0, extentOffset: skuController.text.length);
        }
      });
    });

    numNode.addListener(() {
      setState(() {
        if (numNode.hasFocus) {
          numController.selection = TextSelection(baseOffset: 0, extentOffset: numController.text.length);
        }
      });
    });

    nameNode.addListener(() {
      setState(() {
        if (nameNode.hasFocus) {
          nameController.selection = TextSelection(baseOffset: 0, extentOffset: nameController.text.length);
        }
      });
    });

    minNode.addListener(() {
      setState(() {
        if (minNode.hasFocus) {
          minController.selection = TextSelection(baseOffset: 0, extentOffset: minController.text.length);
        }
      });
    });

    maxNode.addListener(() {
      setState(() {
        if (maxNode.hasFocus) {
          maxController.selection = TextSelection(baseOffset: 0, extentOffset: maxController.text.length);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManageStockBloc, ManageStockState>(
      listener: (BuildContext context, ManageStockState state) {
        if (!state.isLoading) {
          refreshController.refreshCompleted();
        }
        if (state.formResponse?.error == true) {
          DialogUtils.showToast(context, state.formResponse?.message ?? '');
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
                  backgroundColor: AppColors.secondary,
                  iconTheme: const IconThemeData(color: AppColors.background),
                  title: const ATText(
                    text: 'Manage Stock',
                    fontColor: AppColors.background,
                    fontSize: 18,
                    weight: FontWeight.bold,
                  )),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                    child: ATTextfield(
                      hintText: 'Search Item',
                      textEditingController: searchController,
                      onFieldSubmitted: (String? value) {
                        context.read<ManageStockBloc>().searchStocks(search: value ?? '');
                      },
                      onChanged: (String value) {
                        EasyDebounce.debounce('deebouncer1', const Duration(milliseconds: 500), () {
                          context.read<ManageStockBloc>().searchStocks(search: value);
                        });
                      },
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
                        //4: FlexColumnWidth(2),
                      },
                      children: <TableRow>[
                        TableRow(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                context.read<ManageStockBloc>().sortStockOrders(stockList: state.stocksList, column: 'sku', sortBy: isSkuSort);
                                setState(() {
                                  isSkuSort = !isSkuSort;
                                });
                              },
                              child: Container(
                                color: AppColors.headerGrey,
                                padding: const EdgeInsets.only(left: 18, top: 5, bottom: 5),
                                alignment: Alignment.centerLeft,
                                child: const ATText(
                                  text: 'SKU / DESC',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<ManageStockBloc>().sortStockOrders(stockList: state.stocksList, column: 'min', sortBy: isMinSort);
                                setState(() {
                                  isMinSort = !isMinSort;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                color: AppColors.headerGrey,
                                alignment: Alignment.centerRight,
                                child: const ATText(
                                  text: 'Min',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<ManageStockBloc>().sortStockOrders(stockList: state.stocksList, column: 'max', sortBy: isMaxSort);
                                setState(() {
                                  isMaxSort = !isMaxSort;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                alignment: Alignment.centerRight,
                                color: AppColors.headerGrey,
                                child: const ATText(
                                  text: 'Max',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<ManageStockBloc>().sortStockOrders(stockList: state.stocksList, column: 'onHand', sortBy: isOnHandSort);
                                setState(() {
                                  isOnHandSort = !isOnHandSort;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                alignment: Alignment.centerRight,
                                color: AppColors.headerGrey,
                                child: const ATText(
                                  text: 'OnHand',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                                ),
                              ),
                            ),
                            /*Container(
                              padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                              alignment: Alignment.centerRight,
                              color: AppColors.headerGrey,
                              child: const ATText(
                                text: 'Ord',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                              ),
                            ),*/
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
                            double maxQuantity = state.stocksList?[index].maxQuantity ?? 0;
                            double onHand = state.stocksList?[index].onHand ?? 0;
                            double onOrder = state.stocksList?[index].onOrder ?? 0;
                            double order = state.stocksList?[index].order ?? 0;
                            return Visibility(
                              visible: state.stocksList?[index].isActive?.toLowerCase() == 'y',
                              child: Slidable(
                                key: ValueKey<int>(index),
                                startActionPane: ActionPane(motion: const ScrollMotion(), extentRatio: 0.2, children: <Widget>[
                                  SlidableAction(
                                    onPressed: (BuildContext navContext) => openBottomModal(state: state, index: index, isFloatingButton: false),
                                    backgroundColor: AppColors.secondary,
                                    foregroundColor: AppColors.white,
                                    icon: Icons.edit,
                                  ),
                                ]),
                                endActionPane: ActionPane(motion: const ScrollMotion(), extentRatio: 0.2, children: <Widget>[
                                  SlidableAction(
                                    onPressed: (BuildContext navContext) {
                                      context
                                          .read<ManageStockBloc>()
                                          .deleteStock(state.stocksList?[index], index)
                                          .then((_) => context.read<ManageStockBloc>().getStocks());
                                    },
                                    backgroundColor: AppColors.criticalRed,
                                    foregroundColor: AppColors.white,
                                    icon: Icons.delete_forever_outlined,
                                  ),
                                ]),
                                child: GestureDetector(
                                  onTap: () async {
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        adjustController.text = '';
                                        adjustController.selection = TextSelection.fromPosition(TextPosition(offset: adjustController.text.length));

                                        Future<void>.delayed(const Duration(milliseconds: 200), () => adjustNode.requestFocus());

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
                                                      text: 'Adjust Stock Item',
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
                                                      //4: FlexColumnWidth(2),
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
                                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                            color: AppColors.headerGrey,
                                                            alignment: Alignment.centerRight,
                                                            child: const ATText(
                                                              text: 'Min',
                                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                            alignment: Alignment.centerRight,
                                                            color: AppColors.headerGrey,
                                                            child: const ATText(
                                                              text: 'Max',
                                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                            alignment: Alignment.centerRight,
                                                            color: AppColors.headerGrey,
                                                            child: const ATText(
                                                              text: 'OnHand',
                                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
                                                            ),
                                                          ),
                                                          /*Container(
                                                          padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                          alignment: Alignment.centerRight,
                                                          color: AppColors.headerGrey,
                                                          child: const ATText(
                                                            text: 'Ord',
                                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
                                                          ),
                                                        ),*/
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
                                                              text: maxQuantity.toString().removeDecimalZeroFormat(maxQuantity),
                                                              fontColor: AppColors.onboardingText,
                                                              fontSize: 16,
                                                              weight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                            alignment: Alignment.centerRight,
                                                            child: ATText(
                                                              text: onHand.toString().removeDecimalZeroFormat(onHand),
                                                              fontColor: AppColors.onboardingText,
                                                              fontSize: 16,
                                                              weight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          /*Container(
                                                          padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                          alignment: Alignment.centerRight,
                                                          child: ATText(
                                                            text: state.stocksList?[index].order
                                                                    .toString()
                                                                    .removeDecimalZeroFormat(state.stocksList?[index].order ?? 0) ??
                                                                '',
                                                            fontColor: AppColors.onboardingText,
                                                            fontSize: 16,
                                                            weight: FontWeight.bold,
                                                          ),
                                                        ),*/
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
                                                  hintText: 'Quantity',
                                                  textEditingController: adjustController,
                                                  focusNode: adjustNode,
                                                  textAlign: TextAlign.center,
                                                  textInputAction: TextInputAction.done,
                                                  isNumbersOnly: false,
                                                  textInputType: TextInputType.number,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 0),
                                                    child: SizedBox(
                                                      width: MediaQuery.of(context).size.width * .4,
                                                      child: KeepElevatedButton(
                                                        isEnabled: !state.isLoading,
                                                        color: AppColors.successGreen,
                                                        onPressed: () {
                                                          if (adjustController.text.trim().isNotEmpty) {
                                                            context
                                                                .read<ManageStockBloc>()
                                                                .adjustStock(
                                                                    stockModel: state.stocksList?[index],
                                                                    index: index,
                                                                    isIn: true,
                                                                    quantity: double.parse(adjustController.text))
                                                                .then((_) {
                                                              Navigator.of(context).pop();
                                                              context.read<ManageStockBloc>().getStocks();
                                                            });
                                                          } else {
                                                            context.read<ManageStockBloc>().displayErrorMessage(
                                                                FormModel(error: true, message: 'Adjust quantity cannot be empty on In.'));
                                                          }
                                                        },
                                                        text: 'IN',
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 0),
                                                    child: SizedBox(
                                                      width: MediaQuery.of(context).size.width * .4,
                                                      child: KeepElevatedButton(
                                                        color: AppColors.criticalRed,
                                                        isEnabled: !state.isLoading,
                                                        onPressed: () {
                                                          if (adjustController.text.trim().isNotEmpty) {
                                                            context
                                                                .read<ManageStockBloc>()
                                                                .adjustStock(
                                                                    stockModel: state.stocksList?[index],
                                                                    index: index,
                                                                    isIn: false,
                                                                    quantity: double.parse(adjustController.text))
                                                                .then((_) {
                                                              Navigator.of(context).pop();
                                                              context.read<ManageStockBloc>().getStocks();
                                                            });
                                                          } else {
                                                            context.read<ManageStockBloc>().displayErrorMessage(
                                                                FormModel(error: true, message: 'Adjust quantity cannot be empty on Out.'));
                                                          }
                                                        },
                                                        text: 'OUT',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
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
                                            color: maxQuantity == 0
                                                ? AppColors.subtleGrey
                                                : maxQuantity <= onHand
                                                    ? AppColors.successGreen
                                                    : onHand == 0
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
                                                      text: maxQuantity.toString().removeDecimalZeroFormat(maxQuantity),
                                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.only(right: 8),
                                                    alignment: Alignment.centerRight,
                                                    child: ATText(
                                                      text: onHand.toString().removeDecimalZeroFormat(onHand),
                                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                                                    ),
                                                  ),
                                                  /*Container(
                                                  padding: const EdgeInsets.only(right: 8),
                                                  alignment: Alignment.centerRight,
                                                  child: ATText(
                                                    text: state.stocksList?[index].order
                                                        .toString()
                                                        .removeDecimalZeroFormat(state.stocksList?[index].order ?? 0),
                                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                                                  ),
                                                ),*/
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                padding: const EdgeInsets.only(left: 8, right: 8, top: 5),
                                                alignment: Alignment.centerLeft,
                                                child: ATText(
                                                    text: state.stocksList?[index].name,
                                                    style: const TextStyle(fontSize: 18, color: AppColors.tertiary)),
                                              ),
                                              Visibility(
                                                visible: onOrder > 0 && order != onOrder,
                                                child: Container(
                                                  padding: const EdgeInsets.only(left: 8, right: 8, top: 5),
                                                  alignment: Alignment.centerLeft,
                                                  child: ATText(
                                                      text: 'pending: ${(onOrder - order).toString().removeDecimalZeroFormat(onOrder - order)}',
                                                      style: const TextStyle(fontSize: 16, color: AppColors.tertiary)),
                                                ),
                                              )
                                            ],
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
              floatingActionButton: Visibility(
                visible: isFloatingShow,
                child: FloatingActionButton(
                  onPressed: () => openBottomModal(state: state, isFloatingButton: true),
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void openBottomModal({required ManageStockState state, int index = 0, bool isFloatingButton = true}) {
    skuHasFocus = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        //double maxQuantity = state.stocksList?[index].maxQuantity ?? 0;
        if (!skuHasFocus) {
          skuHasFocus = true;
          skuController.text = isFloatingButton ? '' : state.stocksList?[index].sku ?? '';
          nameController.text = isFloatingButton ? '' : state.stocksList?[index].name ?? '';
          numController.text = isFloatingButton ? '' : state.stocksList?[index].num ?? '';
          minController.text = isFloatingButton
              ? ''
              : state.stocksList?[index].minQuantity.toString().removeDecimalZeroFormat(state.stocksList?[index].minQuantity ?? 0) ?? '';
          maxController.text = isFloatingButton
              ? ''
              : state.stocksList?[index].maxQuantity.toString().removeDecimalZeroFormat(state.stocksList?[index].maxQuantity ?? 0) ?? '';
          orderController.text =
              isFloatingButton ? '' : state.stocksList?[index].order.toString().removeDecimalZeroFormat(state.stocksList?[index].order ?? 0) ?? '';

          Future<void>.delayed(const Duration(milliseconds: 200), () {
            skuNode.requestFocus();
            skuController.selection = TextSelection.fromPosition(TextPosition(offset: skuController.text.length));
          });
        }

        return Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 30),
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: ATText(
                  text: isFloatingButton ? 'Add Stock Item' : 'Edit Stock Item',
                  fontColor: AppColors.onboardingText,
                  fontSize: 18,
                  weight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: ATTextfield(
                  hintText: 'SKU',
                  textEditingController: skuController,
                  focusNode: skuNode,
                  isScanner: true,
                  textInputAction: TextInputAction.next,
                  onPressed: () {
                    Future<void>.delayed(Duration.zero, () async {
                      String? scannedSku = await Navigator.push(context, MaterialPageRoute<String>(builder: (BuildContext context) {
                        return const QRScreen(scanner: 'serial');
                      }));
                      skuController.text = scannedSku ?? '';
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: ATTextfield(
                  hintText: 'Part Num',
                  textEditingController: numController,
                  focusNode: numNode,
                  textInputAction: TextInputAction.next,
                  onPressed: () {
                    Future<void>.delayed(Duration.zero, () async {
                      String? scannedSku = await Navigator.push(context, MaterialPageRoute<String>(builder: (BuildContext context) {
                        return const QRScreen(scanner: 'serial');
                      }));
                      numController.text = scannedSku ?? '';
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: ATTextfield(
                  hintText: 'Name',
                  textEditingController: nameController,
                  focusNode: nameNode,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ATTextfield(
                        hintText: 'Min Quantity',
                        textEditingController: minController,
                        focusNode: minNode,
                        textAlign: TextAlign.center,
                        textInputAction: TextInputAction.next,
                        isNumbersOnly: false,
                        textInputType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Expanded(
                      child: ATTextfield(
                        hintText: 'Max Quantity',
                        textEditingController: maxController,
                        focusNode: maxNode,
                        textAlign: TextAlign.center,
                        textInputAction: TextInputAction.next,
                        isNumbersOnly: false,
                        textInputType: TextInputType.number,
                      ),
                    ),
                    /*const SizedBox(
                      width: 7,
                    ),
                    Expanded(
                      child: ATTextfield(
                        hintText: 'Ord Quantity',
                        textEditingController: orderController,
                        textAlign: TextAlign.center,
                        focusNode: orderNode,
                        textInputAction: TextInputAction.done,
                        isNumbersOnly: false,
                        onFieldSubmitted: (String? value) =>
                            addOrder(state, index, isFloatingButton),
                      ),
                    ),*/
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: KeepElevatedButton(
                    isEnabled: !state.isLoading,
                    focusNode: submitNode,
                    onPressed: () => addOrder(state, index, isFloatingButton),
                    text: isFloatingButton ? 'Done' : 'Update',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void addOrder(ManageStockState state, int index, bool isFloatingButton) {
    FormModel response = formChecker();
    if (!response.error) {
      if (isFloatingButton) {
        context
            .read<ManageStockBloc>()
            .addStock(
              sku: skuController.text,
              name: nameController.text,
              num: numController.text,
              minQuantity: minController.text,
              maxQuantity: maxController.text,
              order: orderController.text,
            )
            .then((_) {
          Navigator.of(context).pop();
          context.read<ManageStockBloc>().getStocks().then((value) {
            BlocListener<ManageStockBloc, ManageStockState>(listener: (BuildContext context, ManageStockState state) {
              context.read<ManageStockBloc>().sortStockOrders(sortBy: state.sortOrder ?? false, stockList: state.stocksList, column: state.sortType);
            });
          });
        });
      } else {
        context
            .read<ManageStockBloc>()
            .updateStock(
              index,
              state.stocksList?[index],
              sku: skuController.text,
              name: nameController.text,
              num: numController.text,
              minQuantity: minController.text,
              maxQuantity: maxController.text,
              order: orderController.text,
            )
            .then((_) {
          Navigator.of(context).pop();
          context.read<ManageStockBloc>().getStocks().then((value) {
            BlocListener<ManageStockBloc, ManageStockState>(listener: (BuildContext context, ManageStockState state) {
              context.read<ManageStockBloc>().sortStockOrders(sortBy: state.sortOrder ?? false, stockList: state.stocksList, column: state.sortType);
            });
          });
        });
      }
    }
  }

  FormModel formChecker() {
    FormModel response = FormModel(error: false, message: '');
    if (skuController.text.trim().isEmpty) {
      response = FormModel(error: true, message: 'SKU cannot be empty.');
    } else if (nameController.text.trim().isEmpty) {
      response = FormModel(error: true, message: 'Name cannot be empty.');
    }
    if (minController.text.trim().isEmpty) {
      minController.text = '0';
    }
    if (maxController.text.trim().isEmpty) {
      maxController.text = '0';
    }
    if (orderController.text.trim().isEmpty) {
      orderController.text = '0';
    }
    context.read<ManageStockBloc>().displayErrorMessage(response);
    return response;
  }

  void _forcedRefresh() {
    canRefresh = true;
    context.read<ManageStockBloc>().getStocks();
  }
}
