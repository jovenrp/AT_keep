import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keep/core/domain/utils/constants/app_colors.dart';
import 'package:keep/core/presentation/widgets/at_text.dart';

class DialogUtils {
  static Future<void> showToast(
    BuildContext context,
    String message, {
    bool? hasIcon,
    Icon? icon,
    Duration? duration,
  }) async {
    FToast().removeCustomToast();
    return FToast().init(context).showToast(
        gravity: ToastGravity.TOP,
        child: Container(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          width: MediaQuery.of(context).size.width * .9,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: AppColors.tertiary.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 3,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.cancel,
                size: 30,
                color: AppColors.criticalRed,
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .6,
                child: ATText(
                  text: message,
                  fontColor: AppColors.tertiary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ));
  }

/*static Future<void> showError(
    BuildContext context,
    String? error, {
    Duration? duration,
  }) async {
    return await showFlash(
      context: context,
      duration: duration ?? const Duration(seconds: 2),
      builder: (
        BuildContext context,
        FlashController<Object?> controller,
      ) {
        return Flash<dynamic>.bar(
          controller: controller,
          backgroundColor: Theme.of(context).colorScheme.background,
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(27),
          boxShadows: const <BoxShadow>[
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 16,
              offset: Offset(0, 6), // Shadow position
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 14),
            child: ATText(
              text: error,
              fontColor: AppColors.criticalRed,
            ),
          ),
        );
      },
    );
  }*/
}
