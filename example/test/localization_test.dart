import 'package:easy_localization/localization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('localization', () {
    test('is a localization object', () {
      expect(Localization.instance, isInstanceOf<Localization>());
    });
    test('is a singleton', () {
      expect(Localization.instance, Localization.instance);
    });
  });
}
