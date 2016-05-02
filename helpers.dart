library polyer_app_layout.lib.helpers;

class Helpers {

  static final Helpers _singleton = new Helpers._internal();

  factory Helpers() {
    return _singleton;
  }

  Helpers._internal();


  Map _scrollEffects = {};

  scrollTimingFunction(t, b, c, d) {
    t /= d;
    return -c * t * (t - 2) + b;
  }

  /**
   * Registers a scroll effect to be used in elements that implement the
   * `Polymer.AppScrollEffectsBehavior` behavior.
   *
   * @param {string} effectName The effect name.
   * @param {Object} effectDef The effect definition.
   */
  registerEffect(effectName, effectDef) {
    if (_scrollEffects.containsKey(effectName)) {
      throw new ArgumentError(
          'effect `' + effectName + '` is already registered.');
    }
    _scrollEffects[effectName] = effectDef;
  }

  //TODO implement scroll

}

