"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = _default;

var _lodash = _interopRequireDefault(require("lodash"));

var _flattenColorPalette = _interopRequireDefault(require("../util/flattenColorPalette"));

var _nameClass = _interopRequireDefault(require("../util/nameClass"));

var _toColorValue = _interopRequireDefault(require("../util/toColorValue"));

var _withAlphaVariable = _interopRequireDefault(require("../util/withAlphaVariable"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _default() {
  return function ({
    addUtilities,
    theme,
    variants,
    corePlugins
  }) {
    const colors = (0, _flattenColorPalette.default)(theme('textColor'));

    const getProperties = value => {
      if (corePlugins('textOpacity')) {
        return (0, _withAlphaVariable.default)({
          color: value,
          property: 'color',
          variable: '--tw-text-opacity'
        });
      }

      return {
        color: (0, _toColorValue.default)(value)
      };
    };

    const utilities = _lodash.default.fromPairs(_lodash.default.map(colors, (value, modifier) => {
      return [(0, _nameClass.default)('text', modifier), getProperties(value)];
    }));

    addUtilities(utilities, variants('textColor'));
  };
}