"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = _default;

var _lodash = _interopRequireDefault(require("lodash"));

var _flattenColorPalette = _interopRequireDefault(require("../util/flattenColorPalette"));

var _withAlphaVariable = _interopRequireDefault(require("../util/withAlphaVariable"));

var _toColorValue = _interopRequireDefault(require("../util/toColorValue"));

var _nameClass = _interopRequireDefault(require("../util/nameClass"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _default() {
  return function ({
    addUtilities,
    theme,
    variants,
    corePlugins
  }) {
    const colors = (0, _flattenColorPalette.default)(theme('backgroundColor'));

    const getProperties = value => {
      if (corePlugins('backgroundOpacity')) {
        return (0, _withAlphaVariable.default)({
          color: value,
          property: 'background-color',
          variable: '--tw-bg-opacity'
        });
      }

      return {
        'background-color': (0, _toColorValue.default)(value)
      };
    };

    const utilities = _lodash.default.fromPairs(_lodash.default.map(colors, (value, modifier) => {
      return [(0, _nameClass.default)('bg', modifier), getProperties(value)];
    }));

    addUtilities(utilities, variants('backgroundColor'));
  };
}