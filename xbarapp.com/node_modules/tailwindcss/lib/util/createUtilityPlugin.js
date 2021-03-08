"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = createUtilityPlugin;

var _fromPairs = _interopRequireDefault(require("lodash/fromPairs"));

var _toPairs = _interopRequireDefault(require("lodash/toPairs"));

var _castArray = _interopRequireDefault(require("lodash/castArray"));

var _nameClass = _interopRequireDefault(require("./nameClass"));

var _transformThemeValue = _interopRequireDefault(require("./transformThemeValue"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function createUtilityPlugin(themeKey, utilityVariations, {
  filterDefault = false
} = {}) {
  const transformValue = (0, _transformThemeValue.default)(themeKey);
  return function ({
    addUtilities,
    variants,
    theme
  }) {
    const pairs = (0, _toPairs.default)(theme(themeKey));
    const utilities = utilityVariations.map(([classPrefix, properties]) => {
      return (0, _fromPairs.default)(pairs.filter(([key]) => {
        return filterDefault ? key !== 'DEFAULT' : true;
      }).map(([key, value]) => {
        return [(0, _nameClass.default)(classPrefix, key), (0, _fromPairs.default)((0, _castArray.default)(properties).map(property => [property, transformValue(value)]))];
      }));
    });
    return addUtilities(utilities, variants(themeKey));
  };
}