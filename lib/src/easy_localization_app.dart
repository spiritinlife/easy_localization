import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'asset_loader.dart';
import 'localization.dart';

class EasyLocalization extends StatefulWidget {
  final Widget child;
  final List<Locale> supportedLocales;
  final _EasyLocalizationDelegate delegate;
  final String basePath;

  EasyLocalization({
    @required this.child,
    @required this.supportedLocales,
    @required this.basePath,
    AssetLoader assetLoader = const RootBundleAssetLoader(),
  })  : assert(child != null &&
            supportedLocales != null &&
            basePath != null &&
            assetLoader != null),
        delegate = _EasyLocalizationDelegate(
          basePath: basePath,
          supportedLocales: supportedLocales,
          assetLoader: assetLoader,
        );

  _EasyLocalizationState createState() => _EasyLocalizationState();

  static _EasyLocalizationState of(BuildContext context) =>
      _EasyLocalizationProvider.of(context).data;

  /// ensureInitialized needs to be called in main
  /// so that savedLocale is loaded and used from the
  /// start.
  static ensureInitialized() async =>
      await _EasyLocalizationLocale.initSavedAppLocale();
}

class _EasyLocalizationLocale extends ChangeNotifier {
  Locale _locale;
  List<Locale> _supportedLocales;
  static Locale _savedLocale;

  // TODO: maybe add assertion to ensure that ensureInitialized has been called and that _savedLocale is set.
  _EasyLocalizationLocale(this._supportedLocales)
      : this._locale = _savedLocale ?? _supportedLocales.first;

  Locale get locale => _locale;
  set locale(Locale l) {
    if (!_supportedLocales.contains(l))
      throw new Exception("Locale $l is not supported by this app.");

    _locale = l;

    if (_locale != null)
      Intl.defaultLocale = Intl.canonicalizedLocale(
          l.countryCode == null || l.countryCode.isEmpty
              ? l.languageCode
              : l.toLanguageTag());

    _saveLocale(_locale);

    notifyListeners();
  }

  _saveLocale(Locale locale) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('codeCa', locale.countryCode);
    await _preferences.setString('codeLa', locale.languageCode);
  }

  static initSavedAppLocale() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    final String _languageCode = _preferences.getString('codeLa');
    final String _countryCode = _preferences.getString('codeCa');

    _savedLocale =
        _languageCode != null ? Locale(_languageCode, _countryCode) : null;
  }
}

class _EasyLocalizationState extends State<EasyLocalization> {
  _EasyLocalizationLocale _locale;
  Locale get locale => _locale.locale;

  set locale(Locale l) => _locale.locale = l;

  List<Locale> get supportedLocales => widget.supportedLocales;
  _EasyLocalizationDelegate get delegate => widget.delegate;

  @override
  void initState() {
    _locale = _EasyLocalizationLocale(widget.supportedLocales);
    _locale.addListener(() {
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _locale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _EasyLocalizationProvider(
        data: this,
        child: widget.child,
      );
}

class _EasyLocalizationProvider extends InheritedWidget {
  _EasyLocalizationProvider({Key key, this.child, this.data})
      : super(key: key, child: child);
  final _EasyLocalizationState data;
  final Widget child;

  static _EasyLocalizationProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_EasyLocalizationProvider>();

  @override
  bool updateShouldNotify(_EasyLocalizationProvider oldWidget) => true;
}

class _EasyLocalizationDelegate extends LocalizationsDelegate<Localization> {
  final String basePath;
  final AssetLoader assetLoader;
  final List<Locale> supportedLocales;

  _EasyLocalizationDelegate({
    @required this.basePath,
    @required this.supportedLocales,
    @required this.assetLoader,
  }) : assert(basePath != null &&
            supportedLocales != null &&
            assetLoader != null);

  @override
  bool isSupported(Locale locale) => supportedLocales.contains(locale);

  @override
  Future<Localization> load(Locale value) async {
    await Localization.load(
      value,
      basePath: basePath,
      assetLoader: assetLoader,
    );
    return Localization.instance;
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}
