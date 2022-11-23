import 'package:flutter/material.dart';
import 'package:keep/application/domain/models/application_config.dart';
import 'package:keep/presentation/splash/presentation/splash_screen.dart';
import 'package:pedantic/pedantic.dart';

mixin BackPressedMixin {
  bool onBackPressed(BuildContext context, bool isDoubleBackPressed,
      ApplicationConfig? config, Function(bool) onDismiss) {
    bool _isDoubleBackPressed = isDoubleBackPressed;
    if (_isDoubleBackPressed) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Navigator.of(context).pushReplacement(SplashScreen.route(config: config));

      return true;
    }
    if (!_isDoubleBackPressed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Press back again to return to landing page.'),
            duration: Duration(seconds: 5)),
      );
      isDoubleBackPressed = true;
    }

    unawaited(Future<void>.delayed(const Duration(seconds: 5)).then((_) {
      isDoubleBackPressed = false;
      onDismiss(isDoubleBackPressed);
    }));

    return isDoubleBackPressed;
  }
}
