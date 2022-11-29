import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep/application/domain/models/application_config.dart';
import 'package:keep/core/data/mixin/back_pressed_mixin.dart';
import 'package:keep/core/domain/utils/constants/app_colors.dart';
import 'package:keep/core/presentation/widgets/application_logo.dart';
import 'package:keep/core/presentation/widgets/at_text.dart';
import 'package:keep/presentation/landing/bloc/landing_screen_bloc.dart';
import 'package:keep/presentation/landing/bloc/landing_screen_state.dart';
import 'package:keep/presentation/landing/presentation/landing_drawer.dart';
import 'package:keep/presentation/order_stock/presentation/order_stock_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/presentation/widgets/keep_elevated_button.dart';
import '../../manage_stock/presentation/manage_stock_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key, this.config}) : super(key: key);

  static const String routeName = '/landing';
  static const String screenName = 'landingScreen';

  final ApplicationConfig? config;

  static ModalRoute<LandingScreen> route({ApplicationConfig? config}) =>
      MaterialPageRoute<LandingScreen>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => LandingScreen(
          config: config,
        ),
      );

  @override
  _LandingScreen createState() => _LandingScreen();
}

class _LandingScreen extends State<LandingScreen> with BackPressedMixin {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  bool isEditApi = false;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();

    context.read<LandingScreenBloc>().init();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LandingScreenBloc, LandingScreenState>(
        listener: (BuildContext context, LandingScreenState state) {
      if (!state.isLoading) {
        /*if (state.isLoggedIn) {
          Navigator.of(context).pushReplacement(DashboardScreen.route(
              userProfileModel: state.userProfileModel,
              config: widget.config,
              username: usernameController.text));
          //Navigator.of(context).pushReplacement(StockAdjustScreen.route());
        }*/
      }
    }, builder: (BuildContext context, LandingScreenState state) {
      return SafeArea(
          child: WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Scaffold(
                appBar: AppBar(
                  /*title: ATText(
                    text: 'ActionTRAK',
                    style: TextStyle(
                        letterSpacing: MediaQuery.of(context).size.width * .01, fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.black),
                  ),*/
                  backgroundColor: AppColors.transparent,
                  iconTheme: const IconThemeData(color: AppColors.background),
                  actions: <Widget>[
                    Builder(
                      builder: (BuildContext buildContext) {
                        return IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: AppColors.black,
                          ),
                          onPressed: () {
                            Scaffold.of(buildContext).openEndDrawer();
                          },
                        );
                      },
                    )
                  ],
                ),
                endDrawer: const LandingDrawer(),
                body: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .03,
                        ),
                        ATText(
                          text: 'ActionTRAK',
                          style: TextStyle(
                              letterSpacing:
                                  MediaQuery.of(context).size.width * .01,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                              color: AppColors.tertiary),
                        ),
                        const ApplicationLogo(
                          height: 120,
                          width: 120,
                        ),
                        ATText(
                          text: 'KEEP',
                          style: TextStyle(
                            letterSpacing:
                                MediaQuery.of(context).size.width * .05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const ATText(
                          text: 'Personal Inventory Manager',
                          style: TextStyle(fontSize: 16),
                        ),
                        /*const ATText(
                          text: 'Total Items: 0',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),*/
                        const SizedBox(height: 60),
                        SizedBox(
                          width: double.infinity,
                          child: KeepElevatedButton(
                            isEnabled: !state.isLoading,
                            onPressed: () => Navigator.of(context)
                                .push(ManageStockScreen.route()),
                            text: 'Manage',
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: KeepElevatedButton(
                            isEnabled: !state.isLoading,
                            onPressed: () => Navigator.of(context)
                                .push(OrderStockScreen.route()),
                            text: 'Order',
                          ),
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        /*SizedBox(
                          width: MediaQuery.of(context).size.width * .30,
                          child: QrImage(
                            data: "1234567890",
                            version: QrVersions.auto,
                          ),
                        ),*/
                        const SizedBox(
                          height: 130,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                const ATText(
                                  text: 'Scan to Share',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * .2,
                                  child: QrImage(
                                    data: "1234567890",
                                    version: QrVersions.auto,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                const ATText(
                                  text: 'Copyright ActionTRAK 2022',
                                  style: TextStyle(fontSize: 12),
                                ),
                                const ATText(
                                  text: 'All Rights Reserved',
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 10,),
                                ATText(
                                  text: 'v${widget.config?.appVersion}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
