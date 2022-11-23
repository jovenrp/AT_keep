import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep/core/presentation/widgets/at_loading_indicator.dart';
import 'package:keep/core/presentation/widgets/at_text.dart';
import 'package:keep/core/presentation/widgets/keep_elevated_button.dart';
import 'package:keep/presentation/in_and_out/bloc/in_out_bloc.dart';
import 'package:keep/presentation/in_and_out/bloc/in_out_state.dart';
import '../../../application/domain/models/application_config.dart';
import '../../../core/data/mixin/back_pressed_mixin.dart';
import '../../../core/domain/utils/constants/app_colors.dart';
import '../../../core/presentation/widgets/at_textfield.dart';
import 'navigation_drawer.dart';

class InOutScreen extends StatefulWidget {
  const InOutScreen({Key? key, this.config}) : super(key: key);

  static const String routeName = '/inout';
  static const String screenName = 'inoutScreen';

  final ApplicationConfig? config;

  static ModalRoute<InOutScreen> route({ApplicationConfig? config}) =>
      MaterialPageRoute<InOutScreen>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => InOutScreen(
          config: config,
        ),
      );

  @override
  _InOutScreen createState() => _InOutScreen();
}

class _InOutScreen extends State<InOutScreen> with BackPressedMixin {
  bool _isDoubleBackPressed = false;
  late TextEditingController searchController;
  late TextEditingController adjustmentsController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    adjustmentsController = TextEditingController();
    context.read<InOutBloc>().init();
    //context.read<InOutBloc>().generateOrderPdf();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InOutBloc, InOutState>(
      listener: (BuildContext context, InOutState state) {},
      builder: (BuildContext context, InOutState state) {
        return SafeArea(
          child: WillPopScope(
            onWillPop: () async {
              if (Platform.isAndroid) {
                _isDoubleBackPressed = onBackPressed(
                    context, _isDoubleBackPressed, widget.config, (bool value) {
                  _isDoubleBackPressed = value;
                  //print(_isDoubleBackPressed);
                });
                return false;
              } else {
                return true;
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                  backgroundColor: AppColors.secondary,
                  iconTheme: const IconThemeData(color: AppColors.background),
                  title: const ATText(
                    text: 'In & Out',
                    fontColor: AppColors.background,
                    fontSize: 18,
                    weight: FontWeight.bold,
                  )),
              drawer: const NavigationDrawer(),
              body: Padding(
                padding: const EdgeInsets.only(left: 18, right: 18, top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: ATTextfield(
                        hintText: 'search',
                        textEditingController: searchController,
                        onFieldSubmitted: (String? value) {
                          context.read<InOutBloc>().getItems();
                        },
                      ),
                    ),
                    Visibility(
                      visible: state.isLoading,
                      child: const SizedBox(
                        height: 70,
                      ),
                    ),
                    Visibility(
                      visible: state.isLoading,
                      child: const Center(
                        child: ATLoadingIndicator(),
                      ),
                    ),
                    Visibility(
                      visible: !state.isLoading &&
                          state.inOutItem?.isNotEmpty == true,
                      child: Flexible(
                        child: ListView.builder(
                          itemCount: state.inOutItem?.length,
                          itemBuilder: (BuildContext context, index) {
                            return Column(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ATText(
                                        text: state.inOutItem?[index].name,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Table(
                                        children: <TableRow>[
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                color: AppColors.onSecondary,
                                                alignment: Alignment.centerLeft,
                                                child: const ATText(
                                                  text: 'Item ID',
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                color: AppColors.secondary,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: ATText(
                                                  text: state
                                                      .inOutItem?[index].itemId,
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.background),
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                color: AppColors.onSecondary,
                                                alignment: Alignment.centerLeft,
                                                child: const ATText(
                                                  text: 'On - Hand',
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                color: AppColors.secondary,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: ATText(
                                                  text:
                                                      '${state.inOutItem?[index].qty} ${state.inOutItem?[index].uom}',
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.background),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !state.isLoading &&
                          state.inOutItem?.isNotEmpty == true,
                      child: Flexible(
                        child: ATTextfield(
                          hintText: 'adjustments',
                          textAlign: TextAlign.center,
                          textEditingController: adjustmentsController,
                          isNumbersOnly: true,
                          onFieldSubmitted: (String? value) {
                            context.read<InOutBloc>().getItems();
                          },
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !state.isLoading &&
                          state.inOutItem?.isNotEmpty == true,
                      child: SizedBox(
                        width: double.infinity,
                        child: KeepElevatedButton(
                          isEnabled: !state.isLoading,
                          onPressed: () =>
                              Navigator.of(context).pushReplacement(
                            InOutScreen.route(config: widget.config),
                          ),
                          text: 'IN',
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !state.isLoading &&
                          state.inOutItem?.isNotEmpty == true,
                      child: SizedBox(
                        width: double.infinity,
                        child: KeepElevatedButton(
                          color: AppColors.error,
                          disabledColor: AppColors.atSemiRed,
                          isEnabled: !state.isLoading,
                          onPressed: () =>
                              Navigator.of(context).pushReplacement(
                            InOutScreen.route(config: widget.config),
                          ),
                          text: 'OUT',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Visibility(
                      visible: !state.isLoading &&
                          state.inOutItem?.isNotEmpty == true,
                      child: SizedBox(
                        width: double.infinity,
                        child: KeepElevatedButton(
                          color: AppColors.error,
                          disabledColor: AppColors.atSemiRed,
                          isEnabled: !state.isLoading,
                          onPressed: () =>
                              context.read<InOutBloc>().generateSalesOrder(),
                          text: 'Generate Sales Order',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
