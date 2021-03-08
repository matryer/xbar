"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = _default;

var _lodash = _interopRequireDefault(require("lodash"));

var _flattenColorPalette = _interopRequireDefault(require("../util/flattenColorPalette"));

var _nameClass = _interopRequireDefault(require("../util/nameClass"));

var _toColorValue = _interopRequireDefault(require("../util/toColorValue"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _default() {
  return function ({
    addUtilities,
    theme,
    variants
  }) {
    const colors = (0, _flattenColorPalette.default)(theme('fill'));

    const utilities = _lodash.default.fromPairs(_lodash.default.map(colors, (value, modifier) => {
      return [(0, _nameClass.default)('fill', modifier), {
        fill: (0, _toColorValue.default)(value)
      }];
    }));

    addUtilities(utilities, variants('fill'));
  };
}