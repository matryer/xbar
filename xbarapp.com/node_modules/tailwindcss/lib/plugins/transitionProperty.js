"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = _default;

var _lodash = _interopRequireDefault(require("lodash"));

var _nameClass = _interopRequireDefault(require("../util/nameClass"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _default() {
  return function ({
    addUtilities,
    theme,
    variants
  }) {
    const defaultTimingFunction = theme('transitionTimingFunction.DEFAULT');
    const defaultDuration = theme('transitionDuration.DEFAULT');

    const utilities = _lodash.default.fromPairs(_lodash.default.map(theme('transitionProperty'), (value, modifier) => {
      return [(0, _nameClass.default)('transition', modifier), {
        'transition-property': value,
        ...(value === 'none' ? {} : {
          'transition-timing-function': defaultTimingFunction,
          'transition-duration': defaultDuration
        })
      }];
    }));

    addUtilities(utilities, variants('transitionProperty'));
  };
}