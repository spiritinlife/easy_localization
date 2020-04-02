import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

abstract class AssetLoader {
  const AssetLoader();
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
  Future<Map<String, dynamic>> load(String localePath) async {
    log('easy localization: Load asset from $localePath');
    return json.decode(await rootBundle.loadString(localePath));
  }
      

  @override
  Future<bool> localeExists(String localePath) =>
      rootBundle.load(localePath).then((v) => true).catchError((e) => false);
}
