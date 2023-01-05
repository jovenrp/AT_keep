import 'package:flutter/material.dart';
import 'package:keep/core/presentation/widgets/at_text.dart';
import 'package:keep/presentation/landing/bloc/landing_screen_bloc.dart';
import 'package:keep/presentation/profile/presentation/profile_screen.dart';

import '../../../core/domain/utils/constants/app_colors.dart';
import '../../../core/presentation/widgets/keep_elevated_button.dart';

class LandingDrawer extends StatelessWidget {
  const LandingDrawer({Key? key, required this.landingBloc}) : super(key: key);

  final LandingScreenBloc landingBloc;

  @override
  Widget build(BuildContext context) => Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[buildMenuItems(context)],
          ),
        ),
      );

  Widget buildHeader(BuildContext context) => Container(
        padding: const EdgeInsets.only(top: 40, bottom: 50),
        color: AppColors.tertiary,
        child: Column(
          children: const <Widget>[
            ATText(
              text: 'Joven Parola',
              fontSize: 18,
              weight: FontWeight.bold,
              fontColor: AppColors.background,
            ),
            ATText(
              text: 'joven.parola@actiontrak.com',
              fontSize: 14,
              fontColor: AppColors.background,
            ),
          ],
        ),
      );

  Widget buildMenuItems(BuildContext context) => Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.arrow_forward),
            title: const ATText(
              text: 'Close',
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const ATText(
              text: 'Profile',
            ),
            onTap: () => Navigator.of(context).push(ProfileScreen.route(type: 'profile')),
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const ATText(
              text: 'Vendor',
            ),
            onTap: () => Navigator.of(context).push(ProfileScreen.route(type: 'vendor')),
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const ATText(
              text: 'Backup Database',
            ),
            onTap: () {
              Navigator.of(context).pop();
              landingBloc.backupStocks();
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const ATText(
              text: 'Restore Database',
            ),
            onTap: () {
              Navigator.of(context).pop();
              landingBloc.restoreDatabase();
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const ATText(
              text: 'Export Stock',
            ),
            onTap: () {
              Navigator.of(context).pop();
              landingBloc.createStockCSV();
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const ATText(
              text: 'Import Stock',
            ),
            onTap: () {
              //Navigator.of(context).pop();
              //landingBloc.importCSV();
              showDialog(
                context: context,
                builder: (BuildContext context) => Dialog(
                  child: Container(
                    height: MediaQuery.of(context).size.height * .35,
                    padding: const EdgeInsets.only(
                        left: 18, right: 18, top: 20, bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const ATText(
                          text:
                          'Import CSV',
                          fontColor: AppColors.tertiary,
                          weight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const ATText(
                          text:
                          'Do you want to overwrite exisiting stock or append the new stock?',
                          fontColor: AppColors.tertiary,
                          fontSize: 16,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: KeepElevatedButton(
                            isEnabled: true,
                            onPressed: () => landingBloc
                                .importCSV('append')
                                .then((_) => Navigator.of(context).pop()),
                            text: 'Append',
                            color: AppColors.successGreen,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: KeepElevatedButton(
                            isEnabled: true,
                            onPressed: () => landingBloc
                                .importCSV('overwrite')
                                .then((_) => Navigator.of(context).pop()),
                            text: 'Overwrite',
                            color: AppColors.atWarningRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
}
