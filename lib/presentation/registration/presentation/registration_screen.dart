import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep/presentation/registration/bloc/registration_bloc.dart';
import 'package:keep/presentation/registration/bloc/registration_state.dart';

import '../../../application/domain/models/application_config.dart';
import '../../../core/domain/utils/constants/app_colors.dart';
import '../../../core/presentation/widgets/application_logo.dart';
import '../../../core/presentation/widgets/at_appbar.dart';
import '../../../core/presentation/widgets/at_text.dart';
import '../../../core/presentation/widgets/at_textfield.dart';
import '../../../core/presentation/widgets/keep_elevated_button.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key, this.config}) : super(key: key);

  static const String routeName = '/registration';
  static const String screenName = 'registrationScreen';

  final ApplicationConfig? config;

  static ModalRoute<RegistrationScreen> route({ApplicationConfig? config}) =>
      MaterialPageRoute<RegistrationScreen>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => RegistrationScreen(
          config: config,
        ),
      );

  @override
  _RegistrationScreen createState() => _RegistrationScreen();
}

class _RegistrationScreen extends State<RegistrationScreen> {
  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController fnController;
  late TextEditingController lnController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    fnController = TextEditingController();
    lnController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegistrationBloc, RegistrationState>(
      listener: (BuildContext context, RegistrationState state) {},
      builder: (BuildContext context, RegistrationState state) {
        return SafeArea(
            child: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
              backgroundColor: AppColors.secondary,
              appBar: ATAppBar(
                title: 'Registration',
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                  size: 24.0,
                ),
                rotation: 0,
                onTap: () => Navigator.of(context).pop(),
              ),
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: MediaQuery.of(context).size.height * .1),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: AppColors.background,
                    child: Column(
                      children: <Widget>[
                        const ApplicationLogo(
                          height: 80,
                          width: 80,
                        ),
                        ATText(
                          text: 'KEEP',
                          style: TextStyle(
                            letterSpacing:
                                MediaQuery.of(context).size.width * .03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ATTextfield(
                          hintText: 'email',
                          textEditingController: emailController,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ATTextfield(
                          hintText: 'username',
                          textEditingController: usernameController,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: ATTextfield(
                                  hintText: 'first name',
                                  textEditingController: fnController,
                                  textAlign: TextAlign.center,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: ATTextfield(
                                  hintText: 'last name',
                                  textEditingController: lnController,
                                  textAlign: TextAlign.center,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ATTextfield(
                          hintText: 'password',
                          textEditingController: passwordController,
                          textAlign: TextAlign.start,
                          isPasswordField: true,
                          isSuffixIcon: true,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: KeepElevatedButton(
                            isEnabled: !state.isLoading,
                            onPressed: () => context
                                .read<RegistrationBloc>()
                                .saveUser(username: usernameController.text),
                            text: 'Create',
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ));
      },
    );
  }
}
