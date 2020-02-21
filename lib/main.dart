import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:save_gfy/blocs/shared_url_bloc.dart';
import 'package:save_gfy/pages/home.dart';
import 'package:save_gfy/pages/paste_url.dart';
import 'package:save_gfy/services/config_service.dart';
import 'package:save_gfy/services/file_service.dart';
import 'package:save_gfy/services/logger_service.dart';
import 'package:save_gfy/values/app_config.dart';
import 'package:save_gfy/values/routes.dart' as SaveGfyRoutes;

const appTitle = 'Save GFY';

const channelName = 'memeshart.com/save_gfy';

void run({String env}) async {
  WidgetsFlutterBinding.ensureInitialized();
  // load app config
  final config = await AppConfig.forEnvironment(FileService(), env);

  final level = LoggerService.levels[config.logLevel];

  Logger.level = level;

  runApp(MyApp(
    appConfig: config,
  ));
}

class MyApp extends StatelessWidget {
  MyApp({this.appConfig}) {
    Timer(Duration(milliseconds: 1000), () {
      platform.setMethodCallHandler(handleMethodCall);
      platform.invokeMethod('ready');
    });
  }

  final AppConfig appConfig;

  static const platform = const MethodChannel(channelName);

  Future<void> handleMethodCall(MethodCall call) async {
    loggerService.d('received method call from native');
    switch (call.method) {
      case 'sharedText':
        loggerService.d('sharedText MethodCall received');
        loggerService.d(call.arguments);
        sharedUrlBloc.add(call.arguments as String);

        return Future.value();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => ConfigService()..appConfig = appConfig,
        ),
      ],
      child: MaterialApp(
        title: appTitle,
        initialRoute: SaveGfyRoutes.Route.home.path,
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        routes: {
          SaveGfyRoutes.Route.home.path: (context) => Home(),
          SaveGfyRoutes.Route.pasteUrl.path: (context) => PasteUrl(),
        },
      ),
    );
  }
}
