import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep/application/domain/models/application_config.dart';
import 'package:keep/core/presentation/widgets/application_logo.dart';
import 'package:keep/core/presentation/widgets/at_loading_indicator.dart';
import 'package:keep/core/presentation/widgets/at_text.dart';
import 'package:keep/generated/i18n.dart';
import 'package:keep/presentation/landing/presentation/landing_screen.dart';
import 'package:keep/presentation/splash/bloc/splashscreen_bloc.dart';
import 'package:keep/presentation/splash/bloc/splashscreen_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key, this.config}) : super(key: key);

  static const String routeName = '/splash';
  static const String screenName = 'splashScreen';

  final ApplicationConfig? config;

  static ModalRoute<SplashScreen> route({ApplicationConfig? config}) =>
      MaterialPageRoute<SplashScreen>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => SplashScreen(config: config),
      );

  @override
  Widget build(BuildContext context) {
    context.read<SplashScreenBloc>().loadSplashScreen(config: config);
    return BlocConsumer<SplashScreenBloc, SplashScreenState>(
        listener: (BuildContext context, SplashScreenState state) {
      if (!state.isLoading) {
        Navigator.of(context).pushReplacement(
          LandingScreen.route(config: config),
        );
      }
    }, builder: (BuildContext context, SplashScreenState state) {
      return Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).application_name),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * .2),
                const ApplicationLogo(
                  width: 120,
                  height: 120,
                ),
                ATText(
                  text: 'KEEP',
                  style: TextStyle(
                    letterSpacing: MediaQuery.of(context).size.width * .05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                const ATLoadingIndicator()
                /*Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(I18n.of(context).powered_by,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
                    )),
                const SizedBox(
                  width: 5,
                ),
                CompanyName(
                  firstname: I18n.of(context).company_firstname,
                  lastname: I18n.of(context).company_lastname,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ATText(
                  text: state.apiUrl,
                  fontSize: 12,
                  fontColor: AppColors.black,
                )
              ],
            )*/
              ],
            )
          ],
        ),
      );
    });
  }
}
