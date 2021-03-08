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
    const generators = [(value, modifier) => ({
      [(0, _nameClass.default)('border', modifier)]: {
        borderWidth: `${value}`
      }
    }), (value, modifier) => ({
      [(0, _nameClass.default)('border-t', modifier)]: {
        borderTopWidth: `${value}`
      },
      [(0, _nameClass.default)('border-r', modifier)]: {
        borderRightWidth: `${value}`
      },
      [(0, _nameClass.default)('border-b', modifier)]: {
        borderBottomWidth: `${value}`
      },
      [(0, _nameClass.default)('border-l', modifier)]: {
        borderLeftWidth: `${value}`
      }
    })];

    const utilities = _lodash.default.flatMap(generators, generator => {
      return _lodash.default.flatMap(theme('borderWidth'), (value, modifier) => {
        return generator(value, modifier);
      });
    });

    addUtilities(utilities, variants('borderWidth'));
  };
}