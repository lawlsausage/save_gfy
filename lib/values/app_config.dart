import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:save_gfy/values/config.dart';

class AppConfig implements Config {
  AppConfig({
    this.defaultUrl,
    this.gfycat,
    this.reddit,
    this.logLevel,
  });

  static AppConfig fromJson(Map<String, dynamic> json) {
    final resolvedJson = {
      'defaultUrl': null,
      'gfycat': null,
      'reddit': null,
      'logLevel': 'error',
      ...?json
    };

    return AppConfig(
      defaultUrl: resolvedJson['defaultUrl'] as String,
      gfycat: AppSiteConfig.fromJson(
          resolvedJson['gfycat'] as Map<String, dynamic>),
      reddit: AppSiteConfig.fromJson(
          resolvedJson['reddit'] as Map<String, dynamic>),
      logLevel: resolvedJson['logLevel'] as String,
    );
  }

  final String defaultUrl;

  final AppSiteConfig gfycat;

  final AppSiteConfig reddit;

  final String logLevel;

  static Future<AppConfig> forEnvironment(String env) async {
    env = env ?? 'dev';

    final configFilenames = [
      '$env.json',
      '$env-local.json',
    ];

    Map<String, dynamic> mergedJson = {};
    for (final filename in configFilenames) {
      final configJson = await _loadConfigFileToString(filename);
      mergedJson = {...mergedJson, ...configJson};
    }
    return fromJson(mergedJson);
  }

  static Future<Map<String, dynamic>> _loadConfigFileToString(
      String filename) async {
    Map<String, dynamic> json = {};
    try {
      String contents = await rootBundle.loadString('assets/config/$filename');
      json = jsonDecode(contents);
    } catch (err) {}

    return json;
  }
}

class AppSiteConfig {
  AppSiteConfig({this.hosts});

  static AppSiteConfig fromJson(Map<String, dynamic> json) {
    return AppSiteConfig(
      hosts: json != null ? json['hosts']?.cast<String>() : null,
    );
  }

  final List<String> hosts;
}
