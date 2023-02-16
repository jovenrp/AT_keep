import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:keep/core/domain/utils/string_extensions.dart';
import 'package:keep/core/presentation/widgets/at_text.dart';
import 'package:keep/core/presentation/widgets/keep_elevated_button.dart';
import 'package:keep/presentation/manage_stock/bloc/manage_stock_bloc.dart';
import 'package:keep/presentation/manage_stock/bloc/manage_stock_state.dart';
import 'package:location/location.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../application/domain/models/application_config.dart';
import '../../../core/data/mixin/back_pressed_mixin.dart';
import '../../../core/domain/utils/constants/app_colors.dart';
import '../../../core/presentation/utils/dialog_utils.dart';
import '../../../core/presentation/widgets/at_loading_indicator.dart';
import '../../../core/presentation/widgets/at_textfield.dart';
import '../../order_history/bloc/order_history_bloc.dart';
import '../../profile/data/models/profile_model.dart';
import '../../scanners/qr_screen.dart';
import '../data/models/form_model.dart';
import '../data/models/stocks_model.dart';

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
  bool? isShowAll = false;

  late PermissionStatus _permissionGranted;
  bool serviceEnabled = false;
  Location location = Location();
  late LocationData locationData;

  @override
  void initState() {
    super.initState();

    context.read<ManageStockBloc>().getStocks();
    context.read<OrderHistoryBloc>().getOrders();
    context.read<ManageStockBloc>().getProfiles();
    hasPermission();

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
        if (state.isPdfGenerated) {
          context.read<OrderHistoryBloc>().getOrders().then((value) => context.read<ManageStockBloc>().getStocks());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Order sent!'),
                  InkWell(
                    onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 5),
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
                backgroundColor: AppColors.secondary,
                iconTheme: const IconThemeData(color: AppColors.background),
                title: const ATText(
                  text: 'Manage Stock',
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
                            content: Text('Fill up the profile settings before send an order.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        bool isShareable = false;
                        for (StockModel item in state.stocksList ?? <StockModel>[]) {
                          if (item.isOrdered != true && double.parse(context.read<ManageStockBloc>().getQuantity(item).toString()) > 0) {
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
                            content: Text('Fill up the profile settings before send an order.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        bool isShareable = false;
                        for (StockModel item in state.stocksList ?? <StockModel>[]) {
                          if (item.isOrdered != true && double.parse(context.read<ManageStockBloc>().getQuantity(item).toString()) > 0) {
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
                        context.read<ManageStockBloc>().searchStocks(search: value ?? '');
                      },
                      onChanged: (String value) {
                        EasyDebounce.debounce('deebouncer1', const Duration(milliseconds: 500), () {
                          context.read<ManageStockBloc>().searchStocks(search: value);
                        });
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
                                text: 'Show orders only',
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
                            Container(
                              padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                              alignment: Alignment.centerRight,
                              color: AppColors.headerGrey,
                              child: const ATText(
                                text: 'Ord',
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
                          SizedBox(
                            height: 70,
                          ),
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 70,
                            color: AppColors.tertiary,
                          ),
                          ATText(
                            text: 'Click Add button to add a stock item',
                            fontSize: 18,
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
                            double minQuantity = state.stocksList?[index].minQuantity ?? 0;
                            double onHand = state.stocksList?[index].onHand ?? 0;
                            double onOrder = state.stocksList?[index].onOrder ?? 0;
                            double order = state.stocksList?[index].order ?? 0;
                            double quantity = double.parse(context.read<ManageStockBloc>().getQuantity(state.stocksList?[index]));

                            bool yellow = (onHand < minQuantity && (quantity > 0 && quantity < maxQuantity)) || (minQuantity <= 0 && maxQuantity <= 0 && quantity > 0);
                            bool red = onHand < minQuantity && (quantity > 0 && quantity >= maxQuantity);
                            bool green = minQuantity >= 0 && maxQuantity > 0;
                            bool grey = minQuantity <= 0 && maxQuantity <= 0 && quantity <= 0;

                            return Visibility(
                              visible: state.stocksList?[index].isActive?.toLowerCase() == 'y' && (isShowAll == false || double.parse(context.read<ManageStockBloc>().getQuantity(state.stocksList?[index])) > 0),
                              child: Slidable(
                                key: ValueKey<int>(index),
                                startActionPane: ActionPane(motion: const ScrollMotion(), extentRatio: 0.3, children: <Widget>[
                                  SlidableAction(
                                    onPressed: (BuildContext navContext) => openBottomModal(state: state, index: index, isFloatingButton: false),
                                    backgroundColor: AppColors.secondary,
                                    foregroundColor: AppColors.white,
                                    icon: Icons.edit,
                                  ),
                                  SlidableAction(
                                    onPressed: (BuildContext navContext) async {
                                      await showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          orderController.text = '';
                                          Future.delayed(const Duration(milliseconds: 100), () {
                                            orderController.selection = TextSelection.fromPosition(TextPosition(offset: orderController.text.length));

                                            orderNode.requestFocus();
                                          });

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
                                                                text: context.read<ManageStockBloc>().getQuantity(state.stocksList?[index]),
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
                                                    isNumbersOnly: false,
                                                    textInputType: TextInputType.number,
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
                                                      onPressed: () {
                                                        /*orderController.text = '0';
                                                      Future.delayed(const Duration(milliseconds: 100), () {
                                                        orderNode.requestFocus();
                                                      });*/
                                                        Navigator.of(context).pop();
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
                                    backgroundColor: AppColors.beachSea,
                                    foregroundColor: AppColors.white,
                                    icon: Icons.request_quote,
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
                                                          Container(
                                                            padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                                                            alignment: Alignment.centerRight,
                                                            color: AppColors.headerGrey,
                                                            child: const ATText(
                                                              text: 'Ord',
                                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
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
                                                          Container(
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
                                            color: yellow
                                                ? AppColors.warningOrange
                                                : red
                                                    ? AppColors.criticalRed
                                                    : grey
                                                        ? AppColors.subtleGrey
                                                        : AppColors.successGreen),
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
                                                visible: double.parse(context.read<ManageStockBloc>().getPending(state.stocksList?[index])) > 0,
                                                child: Container(
                                                  padding: const EdgeInsets.only(left: 8, right: 8, top: 5),
                                                  alignment: Alignment.centerLeft,
                                                  child: ATText(
                                                      text: 'pending: ${context.read<ManageStockBloc>().getPending(state.stocksList?[index])}',
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
    context.read<OrderHistoryBloc>().getOrders().then((value) => context.read<ManageStockBloc>().getStocks());
  }

  Future<void> hasPermission() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Location permission not granted, Location will not be saved.'),
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
            content: Text('Location service not granted, Location will not be saved.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      locationData = await location.getLocation();
      context.read<ManageStockBloc>().emitLocationData(locationData: locationData);
      /*ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Location captured.'),
          duration: Duration(seconds: 2),
        ),
      );*/
    }
  }
}
