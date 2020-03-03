import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';

abstract class AssetLoader {
  const AssetLoader();

  String pathResolutionCallback(Locale locale, String basePath) {
    final String _languageCode = locale.languageCode;
    final String _countryCode = locale.countryCode;
    final String localePath = '$basePath/$_languageCode';

    return _countryCode != null
        ? '$localePath-$_countryCode.json'
        : '$localePath.json';
  }

  Future<Map<String, dynamic>> load(String localePath);
  Future<bool> localeExists(String localePath);
}

//
//
//
// default used is RootBundleAssetLoader which uses flutter's assetloader
class RootBundleAssetLoader extends AssetLoader {
  const RootBundleAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String localePath) async =>
      json.decode(await rootBundle.loadString(localePath));

  @override
  Future<bool> localeExists(String localePath) =>
      rootBundle.load(localePath).then((v) => true).catchError((e) => false);
}
