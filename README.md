# polymer-app-layout
Dart polymer wrappers for [PolymerLabs app-layout](https://github.com/PolymerLabs/app-layout) elements.

## Building

1. Fetch the polymer element source
```sh
bower install
```

2. Build the Dart wrapper API

```sh
pub run custom_element_apigen:update app_layout_dart.yaml
```

For more information on using custom\_element\_apigen, see <https://pub.dartlang.org/packages/custom\_element\_apigen>
