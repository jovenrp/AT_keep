import 'package:flutter/material.dart';
import 'package:keep/core/presentation/widgets/at_loading_indicator.dart';

import '../../domain/utils/constants/app_colors.dart';
import '../../domain/utils/constants/app_text_style.dart';

class KeepElevatedButton extends StatelessWidget {
  const KeepElevatedButton({
    Key? key,
    required this.text,
    this.isEnabled = true,
    this.disableText,
    this.color,
    this.disabledColor,
    this.focusNode,
    required this.onPressed,
  }) : super(key: key);

  final String text;
  final bool isEnabled;
  final Widget? disableText;
  final Color? color;
  final Color? disabledColor;
  final FocusNode? focusNode;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      focusNode: focusNode,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith(
          (Set<MaterialState> states) {
            const Set<MaterialState> disabledStates = <MaterialState>{
              MaterialState.disabled,
              MaterialState.error,
            };

            if (states.any(disabledStates.contains)) {
              return disabledColor ?? AppColors.disabledButton;
            }

            return color ?? Theme.of(context).primaryColor;
          },
        ),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 11.0, bottom: 13.0),
        child: isEnabled
            ? Text(
                text,
                style: AppTextStyle.size_16_medium.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : disableText ?? const ATLoadingIndicator(
                color: AppColors.background,
              ),
      ),
    );
  }
}
