import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:save_gfy/blocs/shared_url_bloc.dart';
import 'package:save_gfy/pages/home.dart';
import 'package:save_gfy/pages/paste_url.dart';
import 'package:save_gfy/services/config_service.dart';
import 'package:save_gfy/services/download_service.dart';
import 'package:save_gfy/services/file_service.dart';
import 'package:save_gfy/services/http_client_service.dart';
import 'package:save_gfy/services/logger_service.dart';
import 'package:save_gfy/services/video_service.dart';
import 'package:save_gfy/values/app_config.dart';
import 'package:save_gfy/values/routes.dart' as SaveGfyRoutes;

const appTitle = 'Save GFY';

const channelName = 'memeshart.com/save_gfy';

void run({String env}) async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.level = Level.error;
  final loggerService = LoggerService(Logger());
  final fileService = FileService(
    (filePath) => File(filePath),
    loggerService,
    appAssetBundle: rootBundle,
  );

  // load app config
  final config = await AppConfig.forEnvironment(fileService, env);
  Logger.level = LoggerService.levels[config.logLevel];

  final httpClientService = HttpClientService(() => HttpClient());

  final downloadService =
      DownloadService(httpClientService.httpClient, fileService, loggerService);

  final flutterFFmpegFactory = () => FlutterFFmpeg();

  runApp(MyApp(
    appConfig: config,
    httpClientService: httpClientService,
    downloadService: downloadService,
    flutterFFmpegFactory: flutterFFmpegFactory,
    appAssetBundle: rootBundle,
    loggerService: loggerService,
  ));
}

class MyApp extends StatelessWidget {
  MyApp({
    this.appConfig,
    this.httpClientService,
    this.downloadService,
    this.flutterFFmpegFactory,
    this.appAssetBundle,
    this.loggerService,
  }) {
    Timer(Duration(milliseconds: 1000), () {
      platform.setMethodCallHandler(handleMethodCall);
      platform.invokeMethod('ready');
    });
  }

  final AppConfig appConfig;

  final HttpClientService httpClientService;

  final DownloadService downloadService;

  final FlutterFFmpeg Function() flutterFFmpegFactory;

  final AssetBundle appAssetBundle;

  final LoggerService loggerService;

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
          create: (context) {
            return ConfigService(loggerService)..appConfig = appConfig;
          },
        ),
        Provider(
          create: (_) => httpClientService,
        ),
        Provider(
          create: (_) => FileService(
            (filePath) => File(filePath),
            loggerService,
            appAssetBundle: appAssetBundle,
          ),
        ),
        Provider(create: (_) => downloadService),
        Provider(create: (_) => VideoService(flutterFFmpegFactory())),
        Provider(
          create: (_) => loggerService,
          dispose: (_, LoggerService service) => service.close(),
        ),
      ],
      child: MaterialApp(
        title: appTitle,
        initialRoute: SaveGfyRoutes.Route.home.path,
        theme: ThemeData(
          // This is the theme of your application.
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
