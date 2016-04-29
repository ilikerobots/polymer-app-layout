@TestOn('browser')
library polyer_app_layout.test.app_toolbar_test;

import 'dart:async';
import 'dart:html';
import 'package:polymer_app_layout/app_toolbar.dart';
import 'package:polymer_interop/polymer_interop.dart';
import 'package:web_components/web_components.dart';
import 'package:test/test.dart';
import 'common.dart';


main() async {
  await initWebComponents();

  group('basic features', () {
    AppToolbar toolbar;

    setUp(() async {
      toolbar = fixture('trivialToolbar');
      await new Future(() {});
    });


    test('Items', () {
      var barHeight = toolbar.offsetHeight;
      DivElement topItem = document.elementFromPoint(0, 0);
      var title = Polymer.dom(toolbar).querySelector('[title]');
      var titleRect = title.getBoundingClientRect();
      var barRect = toolbar.getBoundingClientRect();
      var bottomItem = document.elementFromPoint(0, barHeight - 1);

      expect(topItem.attributes.containsKey('top-item'), isTrue);
      expect(bottomItem.attributes.containsKey('bottom-item'), isTrue);
      expect(titleRect.top > 0 && barRect.bottom - titleRect.bottom > 0, isTrue);
    });
  });
}
