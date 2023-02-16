import 'dart:io';

import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:keep/core/domain/utils/string_extensions.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';
import 'package:keep/presentation/order_history/data/models/order_line_model.dart';
import 'package:keep/presentation/order_history/data/models/order_model.dart';
import 'package:keep/presentation/profile/data/models/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application/application.dart';
import 'application/domain/models/application_config.dart';

const String localizationFileName = 'assets/en.json';
String dirPathBase = '';
String contentBaseUrl = '';
String? appVersion;
String? buildNumber;
// Default is prod
String apiPublicKey = 'api key for prod here';
void main() async {
  commonMain(
    ApplicationConfig(
        apiKey:
        'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCTyQ69YqNkzFqnpR33K7t3AmwVk0zfnAmCyKKqG3VgfEUtLpH7pyOQgKV1gp06C2xnp1jN6xeHF8AssTZer0dWcw5O7hQ8oLG5J7xY8w2HtzAeB7o1234+cYx2J8D8aIBwVVA3YHo66PnA6A8XOAZHgKCFuC/UrW4TnrujbQA71wIDAQAB',
        apiUrl: 'http://actiontrak.ddns.net:5555',
        isApiLoggingEnabled: true,
        isApiDebuggerEnabled: true,
        isUiDebuggerEnabled: true,
        isProxyEnabled: true,
        baseContentUrl: 'http://actiontrak.ddns.net:5555',
        appVersion: '1.0.15',
        buildNumber: '1.0.15'),
  );
}

void commonMain(ApplicationConfig applicationConfig) async {
  // Flutter Optimization
  WidgetsFlutterBinding.ensureInitialized();

  Hive.initFlutter();
  Hive.registerAdapter(StockModelAdapter());
  Hive.registerAdapter(ProfileModelAdapter());
  Hive.registerAdapter(OrderModelAdapter());
  Hive.registerAdapter(OrderLineModelAdapter());

  // Set override for appVersion
  appVersion = applicationConfig.appVersion;
  buildNumber = applicationConfig.buildNumber;

  contentBaseUrl = applicationConfig.baseContentUrl;

  apiPublicKey = applicationConfig.apiKey ?? apiPublicKey;

  Catcher(
    rootWidget: Application(
      config: applicationConfig,
      sharedPreferences: await SharedPreferences.getInstance(),
    ),
    debugConfig: CatcherOptions(
      SilentReportMode(),
      <ReportHandler>[
        ConsoleLoggedHandler(),
      ],
    ),
    /*releaseConfig: CatcherOptions(
      SilentReportMode(),
      <ReportHandler>[
        // ConsoleLoggedHandler(),
        EmailAutoHandler(
          'smtp.gmail.com',
          587,
          // Email Sender
          'joven.parola@actiontrak.com',
          // Email Subject
          'ActionTRAK : Error Trace',
          // App Password for SMTP
          'glmrppjikttsctqi',
          // Mailing List
          <String>[
            'joven.parola@actiontrak.com',
          ],
        ),
      ],
    ),*/
  );
}

Future<bool> checkIfLocalizationAssetsIsAvailOnDisk() async {
  String filePath = await localizationFileName.getFilePath();

  return await File(filePath).exists();
}

class LogReportHandler extends ReportMode {
  @override
  void requestAction(Report report, BuildContext? context) {
    logger.e('App Error!\n${report.toJson()}');
    super.onActionConfirmed(report);
  }

  @override
  List<PlatformType> getSupportedPlatforms() =>
      <PlatformType>[PlatformType.web, PlatformType.android, PlatformType.iOS];
}

class ConsoleLoggedHandler extends ReportHandler {
  ConsoleLoggedHandler();

  @override
  Future<bool> handle(Report error, BuildContext? context) {
    String loggedString = '''
============================== CATCHER LOG ==============================
Crash occured on ${error.dateTime}

${_deviceParametersFormatted(error.deviceParameters)}

${_applicationParametersFormatted(error.applicationParameters)}

---------- ERROR ----------
${error.error}

${error.stackTrace != null ? _stackTraceFormatted(error.stackTrace as StackTrace) : null}

${_customParametersFormatted(error.customParameters)}

======================================================================
''';

    logger.wtf(loggedString);

    return Future<bool>.value(true);
  }

  String _deviceParametersFormatted(Map<String, dynamic> deviceParameters) {
    String builder = '------- DEVICE INFO -------';
    for (final MapEntry<String, dynamic> entry in deviceParameters.entries) {
      builder += '\n${entry.key}: ${entry.value}';
    }
    return builder;
  }

  String _applicationParametersFormatted(
      Map<String, dynamic> applicationParameters) {
    String builder = '------- APP INFO -------';
    for (final MapEntry<String, dynamic> entry
        in applicationParameters.entries) {
      builder += '\n${entry.key}: ${entry.value}';
    }
    return builder;
  }

  String _customParametersFormatted(Map<String, dynamic> customParameters) {
    String builder = '------- CUSTOM INFO -------';
    for (final MapEntry<String, dynamic> entry in customParameters.entries) {
      builder += '\n${entry.key}: ${entry.value}';
    }
    return builder;
  }

  String _stackTraceFormatted(StackTrace stackTrace) {
    String builder = '------- STACK TRACE -------';
    for (final String entry in stackTrace.toString().split('\n')) {
      builder += '\n' + entry;
    }
    return builder;
  }

  @override
  List<PlatformType> getSupportedPlatforms() =>
      <PlatformType>[PlatformType.android, PlatformType.iOS, PlatformType.web];
}
