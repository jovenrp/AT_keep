import 'package:flutter/material.dart';
import 'package:keep/core/domain/utils/constants/app_colors.dart';
import 'package:keep/core/presentation/widgets/at_text.dart';

class ATAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ATAppBar(
      {Key? key,
      this.appBarHeight,
      this.title,
      this.icon,
      this.barColor,
      this.onTap,
      this.rotation,
      this.actions})
      : super(key: key);

  final double? appBarHeight;
  final String? title;
  final Icon? icon;
  final Color? barColor;
  final VoidCallback? onTap;
  final int? rotation;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: barColor ?? AppColors.black.withOpacity(.3),
      title: ATText(
          text: title ?? '',
          style: const TextStyle(
              fontSize: 18,
              color: AppColors.white,
              fontWeight: FontWeight.w700)),
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: onTap ??
            () {
              Navigator.pop(context);
            },
        child: RotatedBox(
          quarterTurns: rotation ?? 0,
          child: icon ??
              const Icon(
                Icons.arrow_back_sharp,
                color: AppColors.white,
                size: 24.0,
              ),
        ),
      ),
      actions: actions ?? <Widget>[],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight ?? kToolbarHeight);
}
