@TestOn('browser && !firefox')
library polyer_app_layout.test.app_drawer_test;

import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'package:polymer_app_layout/app_drawer.dart';
import 'package:test/test.dart';
import 'package:web_components/web_components.dart';
import 'sinon/sinon.dart' as sinon;
import 'common.dart';


main() async {
  const num TRACK_SCALAR = 3.75;

  await initWebComponents();

  group
      ('basic features', () {
    AppDrawer drawer;
    Element scrim, contentContainer;
    sinon.Spy transformSpy;


    dynamic fireKeydownEvent(target, keyCode, shiftKey) {
      var event = new CustomEvent('keydown', canBubble: true, cancelable: true);
      var e = new JsObject.fromBrowserObject(event);
      e['keyCode'] = keyCode;
      e['shiftKey'] = shiftKey;
      target.dispatchEvent(event);
      return event;
    }

    void assertDrawerStyles(translateX, opacity, desc) {
      expect(transformSpy
          .getCall(transformSpy.callCount - 1)
          .args[0], equals('translate3d(${translateX.toInt()}px,0,0)'));
      expect(double.parse(scrim.style.opacity).toStringAsFixed(4), equals(opacity.toStringAsFixed(4)));
    }
    void assertDrawerStylesReset() {
      expect(scrim.style.opacity, equals(''));
      expect(transformSpy
          .getCall(transformSpy.callCount - 1)
          .args[0], '');
    }

    void assertTransitionDuration(duration) {
      expect(contentContainer.style.transitionDuration, equals(duration));
      expect(scrim.style.transitionDuration, equals(duration));
    }

    void assertTransitionDurationAbove(d) {
      expect(double.parse(contentContainer.style.transitionDuration.replaceAll(r'ms', '')), greaterThan(d));
      expect(double.parse(scrim.style.transitionDuration.replaceAll(r'ms', '')), greaterThan(d));
    }

    void assertTransitionTimingFunction(timingFunction) {
      expect(contentContainer.style.transitionTimingFunction, equals(timingFunction));
      expect(scrim.style.transitionTimingFunction, equals(timingFunction));
    }

    setUp(() async {
      drawer = fixture('testDrawer');
      scrim = drawer.$['scrim'];
      contentContainer = drawer.$['contentContainer'];
      transformSpy = sinon.spy(drawer.jsElement, 'transform');
      drawer.opened = false;
      drawer.persistent = false;
      drawer.align = 'left';
      drawer.swipeOpen = false;
      drawer.noFocusTrap = false;
    });


    test('default values', () {
      expect(drawer.opened, isFalse);
      expect(drawer.persistent, isFalse);
      expect(drawer.align, equals('left'));
      expect(drawer.swipeOpen, isFalse);
      expect(drawer.noFocusTrap, isFalse);
    });

    test('set scroll direction', () {
      expect(drawer.jsElement['__polymerGesturesTouchAction'], equals('pan-y'));
    });

    test('transitions are enabled after attached', () async {
      assertTransitionDuration('0s');

      await wait(350);
      assertTransitionDuration('');
    });


    test('computed position', () {
      expect(drawer.position, equals('left'));
      drawer.align = 'end';
      expect(drawer.position, equals('right'));
      drawer.align = 'left';
      expect(drawer.position, equals('left'));
      drawer.align = 'right';
      expect(drawer.position, equals('right'));
    });

    test('computed position for RTL', () {
      var rtlDrawer = fixture('rtlDrawer');
      rtlDrawer.align = 'start';
      expect(rtlDrawer.position, equals('right'));
      rtlDrawer.align = 'end';
      expect(drawer.position, equals('left'));
      rtlDrawer.align = 'right';
      expect(rtlDrawer.position, equals('right'));
      rtlDrawer.align = 'left';
      expect(rtlDrawer.position, equals('left'));
    });


    test('left drawer opens and closes', () {
      drawer.align = 'left';

      var contentContainerClientRect = contentContainer.getBoundingClientRect();
      expect(contentContainerClientRect.right, lessThanOrEqualTo(0));

      drawer.opened = true;

      contentContainerClientRect = contentContainer.getBoundingClientRect();
      expect(contentContainerClientRect.left, equals(0));

      drawer.opened = false;

      contentContainerClientRect = contentContainer.getBoundingClientRect();
      expect(contentContainerClientRect.right, lessThanOrEqualTo(0));
    });


    test('right drawer opens and closes', () {
      drawer.align = 'right';

      var contentContainerClientRect = contentContainer.getBoundingClientRect();
      expect(contentContainerClientRect.left, greaterThanOrEqualTo(window.innerWidth));

      drawer.opened = true;

      contentContainerClientRect = contentContainer.getBoundingClientRect();
      expect(contentContainerClientRect.right, equals(window.innerWidth));

      drawer.opened = false;

      contentContainerClientRect = contentContainer.getBoundingClientRect();
      expect(contentContainerClientRect.left, greaterThanOrEqualTo(window.innerWidth));
    });


    test('open(), close(), and toggle()', () {
      expect(drawer.opened, isFalse);

      drawer.open();

      expect(drawer.opened, isTrue);

      drawer.close();

      expect(drawer.opened, isFalse);

      drawer.toggle();

      expect(drawer.opened, isTrue);

      drawer.toggle();

      expect(drawer.opened, isFalse);
    });

    test('getWidth()', () {
      expect(drawer.getWidth(), equals(contentContainer.offsetWidth));
    });

    test('app-drawer-reset-layout', () async {
      var listenerSpy = sinon.spy();
      drawer.addEventListener('app-drawer-reset-layout', listenerSpy.eventListener);
      drawer.align = 'right';
      await wait(350);
      expect(listenerSpy.called, isTrue);
    });


    test('app-drawer-transitioned', () async {
      await wait(100);
      var listenerSpy = sinon.spy();
      drawer.addEventListener('app-drawer-transitioned', listenerSpy.eventListener);

      drawer.persistent = true;

      expect(listenerSpy.called, isFalse); //should not fire after toggling persistent when closed
      expect(drawer.opened, isFalse);

      drawer.opened = true;
      await wait(350);
      expect(listenerSpy.callCount, equals(1)); //should fire after toggling opened state

      drawer.persistent = false;
      await wait(350);

      expect(listenerSpy.callCount, equals(2)); //should fire after toggling persistent when opened

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': 0, 'ddx': 0});
      //drawer.fire('track', detail: { 'state': 'end', 'dx': -200 * TRACK_SCALAR, 'ddx': -200 * TRACK_SCALAR});
      drawer.fire('track', detail: { 'state': 'end', 'dx': -200 * TRACK_SCALAR, 'ddx': -200 * TRACK_SCALAR});

      await wait(350);
      expect(drawer.opened, isFalse);
      expect(listenerSpy.callCount, equals(3)); //should fire after flinging

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': 10 * TRACK_SCALAR, 'ddx': 10 * TRACK_SCALAR});
      drawer.fire('track', detail: { 'state': 'end', 'dx': 10 * TRACK_SCALAR, 'ddx': 0});

      await wait(350);
      expect(drawer.opened, isFalse);
      expect(listenerSpy.callCount, equals(4)); //should fire after swiping even if opened state unchanged

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': 200 * TRACK_SCALAR, 'ddx': 200 * TRACK_SCALAR});
      drawer.fire('track', detail: { 'state': 'end', 'dx': 200 * TRACK_SCALAR, 'ddx': 0});

      await wait(350);
      expect(drawer.opened, isTrue);
      expect(listenerSpy.callCount, equals(5)); //should fire after swiping

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': -1000 * TRACK_SCALAR, 'ddx': -1000 * TRACK_SCALAR});
      drawer.fire('track', detail: { 'state': 'end', 'dx': -1000 * TRACK_SCALAR, 'ddx': 0});

      await wait(350);
      expect(drawer.opened, isFalse);
      expect(listenerSpy.callCount, equals(6)); //should fire after swiping beyond end state
    });

    test('track events block user selection', () async {
      await wait(350);
      var ev = drawer.fire('track', cancelable: true);
      expect(ev.defaultPrevented, isTrue);
    });


    test('styles reset after swiping', () async {
      await wait(350);

      drawer.fire('track', detail: { 'state': 'start'});

      expect(drawer.style.getPropertyValue('visibility'), equals('visible'));
      assertTransitionDuration('0s');

      drawer.fire('track', detail: { 'state': 'track', 'dx': 200 * TRACK_SCALAR, 'ddx': 200 * TRACK_SCALAR});
      drawer.fire('track', detail: { 'state': 'end', 'dx': 200 * TRACK_SCALAR, 'ddx': 0});

      expect(drawer.style.getPropertyPriority('visibility'), equals(''));
      assertTransitionDuration('');
      assertDrawerStylesReset();
    });


    test('styles reset after swiping beyond the end state', () async {
      await wait(350);
      drawer.fire('track', detail: { 'state': 'start'});

      expect(drawer.style.getPropertyValue('visibility'), equals('visible'));
      assertTransitionDuration('0s');

      drawer.fire('track', detail: { 'state': 'track', 'dx': 1000 * TRACK_SCALAR, 'ddx': 1000 * TRACK_SCALAR});
      drawer.fire('track', detail: { 'state': 'end', 'dx': 1000 * TRACK_SCALAR, 'ddx': 0});

      expect(drawer.style.getPropertyValue('visibility'), equals(''));
      assertTransitionDuration('');
      assertDrawerStylesReset();
    });


    test('left drawer swiping', () async {
      await wait(350);
      var drawerWidth = drawer.getWidth();
      var halfWidth = drawerWidth / 2;
      drawer.align = 'left';
      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': -halfWidth, 'ddx': -halfWidth});

      assertDrawerStyles(-drawerWidth, 0.0, 'styles are lower bounded');

      drawer.fire('track', detail: { 'state': 'track', 'dx': halfWidth, 'ddx': drawerWidth});

      assertDrawerStyles(-halfWidth, 0.5, 'style by track distance');

      drawer.fire('track', detail: { 'state': 'track', 'dx': halfWidth + drawerWidth, 'ddx': drawerWidth});

      assertDrawerStyles(0, 1, 'styles are upper bounded');

      // Simulate break of track events.
      drawer.jsElement['_trackDetails'] = [];
      drawer.fire('track', detail: { 'state': 'end', 'dx': halfWidth, 'ddx': -drawerWidth});

      expect(drawer.opened, isFalse); //drawer stays closed when track distance is small

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': halfWidth + 1, 'ddx': halfWidth + 1});
      drawer.fire('track', detail: { 'state': 'end', 'dx': halfWidth + 1, 'ddx': 0});

      expect(drawer.opened, isTrue); //drawer opens when track distance is large

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': -halfWidth, 'ddx': -halfWidth});
      drawer.fire('track', detail: { 'state': 'end', 'dx': -halfWidth, 'ddx': 0});

      expect(drawer.opened, isTrue); //drawer stays opened when track distance is small

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': -halfWidth - 1, 'ddx': -halfWidth - 1});
      drawer.fire('track', detail: { 'state': 'end', 'dx': -halfWidth - 1, 'ddx': 0});

      expect(drawer.opened, isFalse); //drawer closes when track distance is large
    });


    test('right drawer swiping', () async {
      await wait(350);
      var drawerWidth = drawer.getWidth();
      var halfWidth = drawerWidth / 2;
      drawer.align = 'right';
      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': halfWidth, 'ddx': halfWidth});

      assertDrawerStyles(drawerWidth, 0.0, 'styles are lower bounded');

      drawer.fire('track', detail: { 'state': 'track', 'dx': -halfWidth, 'ddx': -drawerWidth});
      assertDrawerStyles(halfWidth, 0.5, 'style by track distance');

      drawer.fire('track', detail: { 'state': 'track', 'dx': -halfWidth - drawerWidth, 'ddx': -drawerWidth});

      assertDrawerStyles(0, 1, 'styles are upper bounded');

      // Simulate break of track events.
      drawer.jsElement['_trackDetails'] = [];
      drawer.fire('track', detail: { 'state': 'end', 'dx': -halfWidth, 'ddx': drawerWidth});

      expect(drawer.opened, isFalse); //drawer stays closed when track distance is small

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': -halfWidth - 1, 'ddx': -halfWidth - 1});
      drawer.fire('track', detail: { 'state': 'end', 'dx': -halfWidth - 1, 'ddx': 0});

      expect(drawer.opened, isTrue); //drawer opens when track distance is large

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': halfWidth, 'ddx': halfWidth});
      drawer.fire('track', detail: { 'state': 'end', 'dx': halfWidth, 'ddx': 0});

      expect(drawer.opened, isTrue); //drawer stays opened when track distance is small

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': halfWidth + 1, 'ddx': halfWidth + 1});
      drawer.fire('track', detail: { 'state': 'end', 'dx': halfWidth + 1, 'ddx': 0});

      expect(drawer.opened, isFalse); //drawer closes when track distance is large
    });


    test('styles reset after flinging', () async {
      await wait(350);
      drawer.fire('track', detail: { 'state': 'start'});

      expect(drawer.style.getPropertyValue('visibility'), equals('visible'));
      assertTransitionDuration('0s');

      drawer.fire('track', detail: { 'state': 'track', 'dx': 0, 'ddx': 0});
      drawer.fire('track', detail: { 'state': 'end', 'dx': 200 * TRACK_SCALAR, 'ddx': 200 * TRACK_SCALAR});

      await wait(350);
      expect(drawer.style.getPropertyValue('visibility'), equals(''));
      assertTransitionDuration('');
      assertTransitionTimingFunction('');
      assertDrawerStylesReset();
    });

    test('styles reset after flinging beyond the end state', () async {
      await wait(350);
      drawer.fire('track', detail: { 'state': 'start'});

      expect(drawer.style.getPropertyValue('visibility'), equals('visible'));
      assertTransitionDuration('0s');

      drawer.fire('track', detail: { 'state': 'track', 'dx': 0, 'ddx': 0});
      drawer.fire('track', detail: { 'state': 'end', 'dx': 1000 * TRACK_SCALAR, 'ddx': 1000 * TRACK_SCALAR});

      expect(drawer.style.getPropertyValue('visibility'), equals(''));
      assertTransitionDuration('');
      assertTransitionTimingFunction('');
      assertDrawerStylesReset();
    });

    test('left drawer swiping', () async {
      await wait(350);

      var drawerWidth = drawer.getWidth();
      var halfWidth = drawerWidth / 2;
      drawer.align = 'left';
      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': -halfWidth, 'ddx': -halfWidth});

      assertDrawerStyles(-drawerWidth, 0.0, 'styles are lower bounded');

      drawer.fire('track', detail: { 'state': 'track', 'dx': halfWidth, 'ddx': drawerWidth});

      assertDrawerStyles(-halfWidth, 0.5, 'style by track distance');

      drawer.fire('track', detail: { 'state': 'track', 'dx': halfWidth + drawerWidth, 'ddx': drawerWidth});

      assertDrawerStyles(0, 1, 'styles are upper bounded');

      // Simulate break of track events.
      drawer.jsElement['_trackDetails'] = [];
      drawer.fire('track', detail: { 'state': 'end', 'dx': halfWidth, 'ddx': -drawerWidth});

      expect(drawer.opened, isFalse); //drawer stays closed when track distance is small

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': halfWidth + 1, 'ddx': halfWidth + 1});
      drawer.fire('track', detail: { 'state': 'end', 'dx': halfWidth + 1, 'ddx': 0});

      expect(drawer.opened, isTrue); //drawer opens when track distance is large')

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': -halfWidth, 'ddx': -halfWidth});
      drawer.fire('track', detail: { 'state': 'end', 'dx': -halfWidth, 'ddx': 0});

      expect(drawer.opened, isTrue); //drawer stays opened when track distance is small

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': -halfWidth - 1, 'ddx': -halfWidth - 1});
      drawer.fire('track', detail: { 'state': 'end', 'dx': -halfWidth - 1, 'ddx': 0});

      expect(drawer.opened, isFalse); //drawer closes when track distance is large
    });


    test('right drawer swiping', () async {
      await wait(350);
      var drawerWidth = drawer.getWidth();
      var halfWidth = drawerWidth / 2;
      drawer.align = 'right';
      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': halfWidth, 'ddx': halfWidth});

      assertDrawerStyles(drawerWidth, 0, 'styles are lower bounded');

      drawer.fire('track', detail: { 'state': 'track', 'dx': -halfWidth, 'ddx': -drawerWidth});

      assertDrawerStyles(halfWidth, 0.5, 'style by track distance');

      drawer.fire('track', detail: { 'state': 'track', 'dx': -halfWidth - drawerWidth, 'ddx': -drawerWidth});

      assertDrawerStyles(0, 1, 'styles are upper bounded');

      // Simulate break of track events.
      drawer.jsElement['_trackDetails'] = [];
      drawer.fire('track', detail: { 'state': 'end', 'dx': -halfWidth, 'ddx': drawerWidth});

      expect(drawer.opened, isFalse); //drawer stays closed when track distance is small'

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': -halfWidth - 1, 'ddx': -halfWidth - 1});
      drawer.fire('track', detail: { 'state': 'end', 'dx': -halfWidth - 1, 'ddx': 0});

      expect(drawer.opened, isTrue); //drawer opens when track distance is large

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': halfWidth, 'ddx': halfWidth});
      drawer.fire('track', detail: { 'state': 'end', 'dx': halfWidth, 'ddx': 0});

      expect(drawer.opened, isTrue); //drawer stays opened when track distance is small

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': halfWidth + 1, 'ddx': halfWidth + 1});
      drawer.fire('track', detail: { 'state': 'end', 'dx': halfWidth + 1, 'ddx': 0});

      expect(drawer.opened, isFalse); //drawer closes when track distance is large'
    });

    test('styles reset after flinging', () async {
      await wait(350);
      drawer.fire('track', detail: { 'state': 'start'});

      expect(drawer.style.getPropertyValue('visibility'), equals('visible'));
      assertTransitionDuration('0s');

      drawer.fire('track', detail: { 'state': 'track', 'dx': 0, 'ddx': 0});
      drawer.fire('track', detail: { 'state': 'end', 'dx': 200 * TRACK_SCALAR, 'ddx': 200 * TRACK_SCALAR});

      await wait(350);
      expect(drawer.style.getPropertyValue('visibility'), equals(''));
      assertTransitionDuration('');
      assertTransitionTimingFunction('');
      assertDrawerStylesReset();
    });

    test('styles reset after flinging beyond the end state', () async {
      await wait(350);
      drawer.fire('track', detail: { 'state': 'start'});

      expect(drawer.style.getPropertyValue('visibility'), equals('visible'));
      assertTransitionDuration('0s');

      drawer.fire('track', detail: { 'state': 'track', 'dx': 0, 'ddx': 0});
      drawer.fire('track', detail: { 'state': 'end', 'dx': 1000 * TRACK_SCALAR, 'ddx': 1000 * TRACK_SCALAR});

      expect(drawer.style.getPropertyValue('visibility'), equals(''));
      assertTransitionDuration('');
      assertTransitionTimingFunction('');
      assertDrawerStylesReset();
    });

    test('left drawer flinging open', () async {
      await wait(350);
      drawer.align = 'left';
      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': 0, 'ddx': 0});
      drawer.fire('track', detail: { 'state': 'end', 'dx': 0.1, 'ddx': 0.1});

      expect(drawer.opened, isFalse); //drawer stays closed when velocity is small'
      assertTransitionDuration('');
      assertTransitionTimingFunction('');
      assertDrawerStylesReset();

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': 0, 'ddx': 0});
      drawer.fire('track', detail: { 'state': 'end', 'dx': 6, 'ddx': 6});

      expect(drawer.opened, isTrue); //drawer opens when velocity is large
      assertTransitionTimingFunction(drawer.jsElement['_FLING_TIMING_FUNCTION']);
      assertDrawerStylesReset();
      assertTransitionDurationAbove(60.0);
    });

    test('left drawer flinging close', () async {
      await wait(350);
      drawer.align = 'left';
      drawer.opened = true;
      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': 0, 'ddx': 0});
      drawer.fire('track', detail: { 'state': 'end', 'dx': -0.1, 'ddx': -0.1});

      expect(drawer.opened, isTrue); //drawer stays opened when velocity is small
      assertTransitionDuration('');
      assertTransitionTimingFunction('');
      assertDrawerStylesReset();

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': 0, 'ddx': 0});
      drawer.fire('track', detail: { 'state': 'end', 'dx': -6, 'ddx': -6});

      expect(drawer.opened, isFalse); //drawer closes when velocity is large
      assertTransitionDurationAbove(60.0);
      assertTransitionTimingFunction(drawer.jsElement['_FLING_TIMING_FUNCTION']);
      assertDrawerStylesReset();
    });

    test('right drawer flinging open', () async {
      await wait(350);
      drawer.align = 'right';
      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': 0, 'ddx': 0});
      drawer.fire('track', detail: { 'state': 'end', 'dx': -0.1, 'ddx': -0.1});

      expect(drawer.opened, isFalse); //drawer stays closed when velocity is small
      assertTransitionDuration('');
      assertTransitionTimingFunction('');
      assertDrawerStylesReset();

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': 0, 'ddx': 0});
      drawer.fire('track', detail: { 'state': 'end', 'dx': -6, 'ddx': -6});

      expect(drawer.opened, isTrue); //drawer opens when velocity is large
      assertTransitionDurationAbove(60.0);
      assertTransitionTimingFunction(drawer.jsElement['_FLING_TIMING_FUNCTION']);
      assertDrawerStylesReset();
    });

    test('right drawer flinging close', () async {
      await wait(350);
      drawer.align = 'right';
      drawer.opened = true;
      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': 0, 'ddx': 0});
      drawer.fire('track', detail: { 'state': 'end', 'dx': 0.1, 'ddx': 0.1});

      expect(drawer.opened, isTrue); //drawer stays opened when velocity is small
      assertTransitionDuration('');
      assertTransitionTimingFunction('');
      assertDrawerStylesReset();

      drawer.fire('track', detail: { 'state': 'start'});
      drawer.fire('track', detail: { 'state': 'track', 'dx': 0, 'ddx': 0});
      drawer.fire('track', detail: { 'state': 'end', 'dx': 6, 'ddx': 6});

      expect(drawer.opened, isFalse); //drawer closes when velocity is large
      assertTransitionDurationAbove(60.0);
      assertTransitionTimingFunction(drawer.jsElement['_FLING_TIMING_FUNCTION']);
      assertDrawerStylesReset();
    });

    test('doc scroll', () async {
      await wait(350);
      drawer.opened = true;

      await wait(350);
      expect(document.body.style.overflow, equals('hidden'));

      drawer.persistent = true;

      await wait(350);
      expect(document.body.style.overflow, equals('')); //should not block scrolling when persistent

      drawer.persistent = false;

      await wait(350);
      expect(document.body.style.overflow, equals('hidden'));

      drawer.opened = false;

      await wait(350);
      expect(document.body.style.overflow, equals('')); //should not block scrolling when closed
    });

    //TODO port focus trap tests$

    test('esc key handler', () async {
      drawer.opened = true;
      await wait(350);
      var e = fireKeydownEvent(document, 27, false);
      expect(drawer.opened, isFalse); //should close drawer on esc
      expect(e.defaultPrevented, isTrue); //should prevent default
    });


    test('scrim', () {
        scrim.style.transitionDuration = '0s';
        expect(scrim.getComputedStyle('scrim').opacity, equals('0'));
        drawer.opened = true;
        expect(scrim.getComputedStyle('scrim').opacity, equals('1'));
        drawer.persistent = true;
        expect(scrim.getComputedStyle('scrim').visibility, equals('hidden'));
      });

      test('tap on scrim closes drawer', () {
        drawer.opened = true;
        drawer.fire('tap', detail: null /* detail */, node: scrim);
        expect(drawer.opened, isFalse);
      });

      test('persistent drawer should not cover content', () async {
        drawer.opened = true;
        drawer.persistent = true;
        await wait(350);

        expect(document.elementFromPoint(20,20).tagName, isNot(equals('APP-DRAWER')));
      }, skip: 'FIXME');

      test('right persistent drawer should be in the correct position', () {
        drawer.align = 'right';
        drawer.opened = true;
        drawer.persistent = true;

        expect(drawer.getBoundingClientRect().right, equals(window.innerWidth));
      });



  });
}
