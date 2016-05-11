# polymer-app-layout

[![Pub](https://img.shields.io/pub/v/polymer_app_layout.svg?maxAge=2592000?style=flat-square)](https://pub.dartlang.org/packages/polymer_app_layout)
[![Travis](https://img.shields.io/travis/ilikerobots/polymer-app-layout.svg?maxAge=2592000?style=flat-square)](https://travis-ci.org/ilikerobots/polymer-app-layout)

Dart polymer wrappers for [PolymerLabs app-layout](https://github.com/PolymerLabs/app-layout) elements.

## Demos

[View demos at polyer-app-layout-demos](http://ilikerobots.github.io/polymer-app-layout-demos/)


## Rebuilding

Although not necessary for normal use, this package can be rebuilt from the original polymer source using the procedure
below.  The specific version used as a basis can be specified in bower.json.

1. Fetch the polymer element source
```sh
bower install
```

2. Build the Dart wrapper API

```sh
pub run custom_element_apigen:update app_layout_dart.yaml
```

For more information on using custom_element_apigen, see <https://pub.dartlang.org/packages/custom_element_apigen>
