@TestOn('browser && !firefox')
library polyer_app_layout.test.app_drawer_layout_test;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:polymer_app_layout/app_drawer_layout.dart';
import 'package:polymer_app_layout/app_drawer.dart';
import 'package:polymer_interop/polymer_interop.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_elements/iron_resizable_behavior.dart';
import 'package:test/test.dart';
import 'sinon/sinon.dart' as sinon;
import 'common.dart';


main() async {
  await initWebComponents();


  group
      ('basic features', () {
    AppDrawerLayout drawerLayout;
    AppDrawer drawer;

    setUp(() async {
      drawerLayout = fixture('testDrawerLayout');
      drawer = drawerLayout.querySelector('app-drawer');
    });

    test('default values', () {
      expect(drawerLayout.forceNarrow, isFalse);
      expect(drawerLayout.responsiveWidth, equals('640px'));
    });


    test('get drawer', () {
      expect(drawerLayout.drawer, equals(drawer));
    });

    test('forceNarrow', () {
      drawerLayout.responsiveWidth = '0px';
      drawerLayout.forceNarrow = true;

      expect(drawerLayout.narrow, isTrue);
    });

    test('responsiveWidth', () async {
      var drawerToggle = drawerLayout.querySelector('[drawer-toggle]');
      drawerLayout.responsiveWidth = '0px';

      await wait(50);
      expect(drawerLayout.narrow, isFalse);
      expect(drawerToggle.getComputedStyle('drawerToggle').display, equals('none'));

      drawerLayout.responsiveWidth = '10000px';

      await wait(50);
      expect(drawerLayout.narrow, isTrue);
      expect(drawerToggle.getComputedStyle('drawerToggle').display, isNot(equals('none')));
    });

    test('drawer-toggle', () {
      drawerLayout.responsiveWidth = '10000px';
      expect(drawer.opened, isFalse);

      fireEvent('tap', null, drawerLayout.querySelector('p'));
      expect(drawer.opened, isFalse);

      fireEvent('tap', null, drawerLayout.querySelector('[drawer-toggle]'));
      expect(drawer.opened, isTrue);
    });

    test('content layout', () async {
      var listenerSpy = sinon.spy();
      var xResizeable = drawerLayout.querySelector('x-resizeable');
      xResizeable.addEventListener('iron-resize', listenerSpy.eventListener);
      drawerLayout.responsiveWidth = '10000px';

      await wait(50);
      expect(drawerLayout.$['contentContainer'].style.marginLeft, equals(''));
      expect(drawerLayout.$['contentContainer'].style.marginRight, equals(''));
      expect(listenerSpy.called, isTrue);
      listenerSpy.reset();

      drawerLayout.responsiveWidth = '0px';

      await wait(50);
      expect(drawerLayout.$['contentContainer'].style.marginLeft, equals('256px'));
      expect(drawerLayout.$['contentContainer'].style.marginRight, equals(''));
      expect(listenerSpy.called, isTrue);
      listenerSpy.reset();

      drawer.align = 'end';

      await wait(50);
      expect(drawerLayout.$['contentContainer'].style.marginLeft, equals(''));
      expect(drawerLayout.$['contentContainer'].style.marginRight, equals('256px'));
      expect(listenerSpy.called, isTrue);
    });
  });
}

@PolymerRegister('x-resizeable')
class XResizeable extends PolymerElement with IronResizableBehavior {
  XResizeable.created() : super.created();
}

