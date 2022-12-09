import 'package:flutter/material.dart';
import 'package:keep/core/presentation/widgets/at_text.dart';
import 'package:keep/presentation/landing/bloc/landing_screen_bloc.dart';
import 'package:keep/presentation/profile/presentation/profile_screen.dart';

import '../../../core/domain/utils/constants/app_colors.dart';

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
            onTap: () => Navigator.of(context)
                .push(ProfileScreen.route(type: 'profile')),
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const ATText(
              text: 'Vendor',
            ),
            onTap: () =>
                Navigator.of(context).push(ProfileScreen.route(type: 'vendor')),
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
        ],
      );
}
