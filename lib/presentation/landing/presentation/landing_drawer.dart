import 'package:flutter/material.dart';
import 'package:keep/core/presentation/widgets/at_text.dart';

import '../../../core/domain/utils/constants/app_colors.dart';

class LandingDrawer extends StatelessWidget {
  const LandingDrawer({Key? key}) : super(key: key);

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
              text: 'Settings 1',
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const ATText(
              text: 'Settings 2',
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const ATText(
              text: 'Settings 3',
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.store_mall_directory_outlined),
            title: const ATText(
              text: 'Settings 4',
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const ATText(
              text: 'Settings 5',
            ),
            onTap: () {},
          ),
        ],
      );
}