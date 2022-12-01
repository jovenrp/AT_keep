import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep/core/domain/utils/string_extensions.dart';
import 'package:keep/presentation/profile/bloc/profile_bloc.dart';

import '../../../application/domain/models/application_config.dart';
import '../../../core/domain/utils/constants/app_colors.dart';
import '../../../core/presentation/widgets/at_text.dart';
import '../../../core/presentation/widgets/at_textfield.dart';
import '../../../core/presentation/widgets/keep_elevated_button.dart';
import '../bloc/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, this.config, this.type}) : super(key: key);

  static const String routeName = '/profile';
  static const String screenName = 'profileScreen';

  final ApplicationConfig? config;
  final String? type;

  static ModalRoute<ProfileScreen> route(
          {ApplicationConfig? config, String? type}) =>
      MaterialPageRoute<ProfileScreen>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => ProfileScreen(
          config: config,
          type: type,
        ),
      );

  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      context.read<ProfileBloc>().getProfile(type: widget.type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (BuildContext context, ProfileState state) {
        log("asdasd ${state.isInit} ${state.profileModel?.lastname} ${emailController.text}");
        if (state.isInit) {
          emailController.text = state.profileModel?.email ?? '';
          firstnameController.text = state.profileModel?.firstname ?? '';
          lastnameController.text = state.profileModel?.lastname ?? '';
          phoneController.text = state.profileModel?.phoneNumber ?? '';
          addressController.text = state.profileModel?.address ?? '';
        }

        if (state.isSaved || state.isUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('${widget.type.toString().capitalizeFirstofEach()} information is ${state.isSaved == true ? 'saved' : 'updated'}.' ?? ''),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        if ((widget.type == 'profile' && state.isProfileExisting) ||
            (widget.type == 'vendor') && state.isVendorExisiting) {
          showDialog(
            context: context,
            builder: (BuildContext context) => Dialog(
              child: Container(
                height: MediaQuery.of(context).size.height * .4,
                padding: const EdgeInsets.only(
                    left: 18, right: 18, top: 30, bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ATText(
                      text: 'A ${widget.type} is already existing.',
                      weight: FontWeight.bold,
                      fontColor: AppColors.tertiary,
                      fontSize: 20,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ATText(
                      text:
                          'Are you sure you want to update the existing ${widget.type}?',
                      fontColor: AppColors.tertiary,
                      fontSize: 16,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: KeepElevatedButton(
                        isEnabled: !state.isLoading,
                        onPressed: () => context
                            .read<ProfileBloc>()
                            .saveProfile(
                                email: emailController.text,
                                firstname: firstnameController.text,
                                lastname: lastnameController.text,
                                phone: phoneController.text,
                                address: addressController.text,
                                type: widget.type)
                            .then((_) => Navigator.of(context).pop()),
                        text: 'Update',
                        color: AppColors.successGreen,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: KeepElevatedButton(
                        isEnabled: !state.isLoading,
                        onPressed: () => Navigator.of(context).pop(),
                        text: 'Cancel',
                        color: AppColors.atWarningRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
      builder: (BuildContext context, ProfileState state) {
        return SafeArea(
            child: WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: Scaffold(
              appBar: AppBar(
                  backgroundColor: AppColors.secondary,
                  iconTheme: const IconThemeData(color: AppColors.background),
                  title: ATText(
                    text: widget.type.toString().capitalizeFirstofEach(),
                    fontColor: AppColors.background,
                    fontSize: 18,
                    weight: FontWeight.bold,
                  )),
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ATText(
                        text: 'Fill up the ${widget.type} information form.',
                        fontSize: 20,
                        fontColor: AppColors.tertiary,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ATTextfield(
                        hintText: 'Email',
                        textEditingController: emailController,
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
                                hintText: 'First Name',
                                textEditingController: firstnameController,
                                textAlign: TextAlign.center,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: ATTextfield(
                                hintText: 'Last Name',
                                textEditingController: lastnameController,
                                textAlign: TextAlign.center,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ATTextfield(
                        hintText: 'Phone',
                        textEditingController: phoneController,
                        textAlign: TextAlign.start,
                        isSuffixIcon: true,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ATTextfield(
                        hintText: 'Address',
                        textEditingController: addressController,
                        textAlign: TextAlign.start,
                        isSuffixIcon: true,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: KeepElevatedButton(
                          isEnabled: !state.isLoading,
                          onPressed: () {
                            if (emailController.text.isEmpty || firstnameController.text.isEmpty || lastnameController.text.isEmpty || phoneController.text.isEmpty || addressController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text('Please fill up all the fields.'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            } else {
                              context
                                  .read<ProfileBloc>()
                                  .checkProfile(
                                  email: emailController.text,
                                  firstname: firstnameController.text,
                                  lastname: lastnameController.text,
                                  phone: phoneController.text,
                                  address: addressController.text,
                                  type: widget.type);
                            }
                          },
                          text: 'Create',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              )),
        ));
      },
    );
  }
}
