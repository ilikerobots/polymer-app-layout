# polymer-app-layout

[![Pub](https://img.shields.io/pub/v/polymer_app_layout.svg?maxAge=2592000?style=flat-square)](https://pub.dartlang.org/packages/polymer_app_layout)

Dart polymer wrappers for [PolymerLabs app-layout](https://github.com/PolymerLabs/app-layout) elements.

## Demos

[View demos at polyer-app-layout-demos](http://ilikerobots.github.io/polymer-app-layout-demos/)


## Rebuilding

To regenerate the Dart API from polymer source, follow the steps below.  The specific version used as a basis can be specified in the bower.json.

1. Fetch the polymer element source
```sh
bower install
```

2. Build the Dart wrapper API

```sh
pub run custom_element_apigen:update app_layout_dart.yaml
```

For more information on using custom_element_apigen, see <https://pub.dartlang.org/packages/custom_element_apigen>
