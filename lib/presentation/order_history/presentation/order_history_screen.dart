import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keep/core/domain/utils/string_extensions.dart';
import 'package:keep/presentation/order_history/bloc/order_history_bloc.dart';
import 'package:keep/presentation/order_history/bloc/order_history_state.dart';
import 'package:keep/presentation/order_history/presentation/order_line_history_screen.dart';

import '../../../application/domain/models/application_config.dart';
import '../../../core/domain/utils/constants/app_colors.dart';
import '../../../core/presentation/widgets/at_text.dart';
import '../../../core/presentation/widgets/at_textfield.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key, this.config}) : super(key: key);
  static const String routeName = '/orderHistory';
  static const String screenName = 'orderHistoryScreen';

  final ApplicationConfig? config;

  static ModalRoute<OrderHistoryScreen> route({ApplicationConfig? config}) => MaterialPageRoute<OrderHistoryScreen>(
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
                    text: 'Orders History',
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
                          itemCount: state.orderList?.length,
                          itemBuilder: (BuildContext context, index) {
                            List<String> userData = state.orderList?[index].source?.split(',') ?? <String>[];
                            String vendorName = userData[0];
                            //String vendorEmail = userData[1];
                            //String vendorContact = userData[2];
                            //String vendorAddress = userData[3];

                            return Card(
                                elevation: 4.0,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 16, top: 16),
                                      alignment: Alignment.centerLeft,
                                      child: ATText(text: state.orderList?[index].num, weight: FontWeight.bold, fontSize: 20,),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(left: 16),
                                      alignment: Alignment.centerLeft,
                                      child: ATText(text: state.orderList?[index].name, fontSize: 16,),
                                    ),
                                    const SizedBox(height: 20,),
                                    Container(
                                      padding: const EdgeInsets.only(left: 16),
                                      alignment: Alignment.centerLeft,
                                      child: ATText(text: 'Vendor: ${vendorName.toString().capitalizeFirstofEach()}', fontSize: 16, weight: FontWeight.bold,),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(left: 16),
                                      alignment: Alignment.centerLeft,
                                      child: ATText(text: DateFormat("MMM y dd HH:mm").add_jm().format(DateTime.parse(state.orderList?[index].createdDate ?? '')), fontSize: 14,),
                                    ),
                                    ButtonBar(
                                      children: [
                                        TextButton(
                                          child: const Text('VIEW STOCKS ORDER',),
                                          onPressed: () => Navigator.of(context)
                                              .push(OrderLineHistoryScreen.route(order: state.orderList?[index])),
                                        )
                                      ],
                                    )
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
