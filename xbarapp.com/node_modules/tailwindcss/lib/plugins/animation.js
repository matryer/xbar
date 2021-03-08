"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = _default;

var _lodash = _interopRequireDefault(require("lodash"));

var _nameClass = _interopRequireDefault(require("../util/nameClass"));

var _parseAnimationValue = _interopRequireDefault(require("../util/parseAnimationValue"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _default() {
  return function ({
    addUtilities,
    theme,
    variants,
    prefix
  }) {
    const prefixName = name => prefix(`.${name}`).slice(1);

    const keyframesConfig = theme('keyframes');

    const keyframesStyles = _lodash.default.mapKeys(keyframesConfig, (_keyframes, name) => `@keyframes ${prefixName(name)}`);

    addUtilities(keyframesStyles, {
      respectImportant: false
    });
    const animationConfig = theme('animation');

    const utilities = _lodash.default.mapValues(_lodash.default.mapKeys(animationConfig, (_animation, suffix) => (0, _nameClass.default)('animate', suffix)), animation => {
      const {
        name
      } = (0, _parseAnimationValue.default)(animation);
      if (name === undefined || keyframesConfig[name] === undefined) return {
        animation
      };
      return {
        animation: animation.replace(name, prefixName(name))
      };
    });

    addUtilities(utilities, variants('animation'));
  };
}