"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = _default;

var _lodash = _interopRequireDefault(require("lodash"));

var _flattenColorPalette = _interopRequireDefault(require("../util/flattenColorPalette"));

var _nameClass = _interopRequireDefault(require("../util/nameClass"));

var _toColorValue = _interopRequireDefault(require("../util/toColorValue"));

var _withAlphaVariable = require("../util/withAlphaVariable");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _default() {
  return function ({
    addUtilities,
    theme,
    variants
  }) {
    const colors = (0, _flattenColorPalette.default)(theme('gradientColorStops'));
    const utilities = (0, _lodash.default)(colors).map((value, modifier) => {
      const transparentTo = (() => {
        if (_lodash.default.isFunction(value)) {
          return value({
            opacityValue: 0
          });
        }

        try {
          const [r, g, b] = (0, _withAlphaVariable.toRgba)(value);
          return `rgba(${r}, ${g}, ${b}, 0)`;
        } catch (_error) {
          return `rgba(255, 255, 255, 0)`;
        }
      })();

      return [[(0, _nameClass.default)('from', modifier), {
        '--tw-gradient-from': (0, _toColorValue.default)(value, 'from'),
        '--tw-gradient-stops': `var(--tw-gradient-from), var(--tw-gradient-to, ${transparentTo})`
      }], [(0, _nameClass.default)('via', modifier), {
        '--tw-gradient-stops': `var(--tw-gradient-from), ${(0, _toColorValue.default)(value, 'via')}, var(--tw-gradient-to, ${transparentTo})`
      }], [(0, _nameClass.default)('to', modifier), {
        '--tw-gradient-to': (0, _toColorValue.default)(value, 'to')
      }]];
    }).unzip().flatten().fromPairs().value();
    addUtilities(utilities, variants('gradientColorStops'));
  };
}