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
    const generators = [(size, modifier) => ({
      [(0, _nameClass.default)('inset', modifier)]: {
        top: `${size}`,
        right: `${size}`,
        bottom: `${size}`,
        left: `${size}`
      }
    }), (size, modifier) => ({
      [(0, _nameClass.default)('inset-y', modifier)]: {
        top: `${size}`,
        bottom: `${size}`
      },
      [(0, _nameClass.default)('inset-x', modifier)]: {
        right: `${size}`,
        left: `${size}`
      }
    }), (size, modifier) => ({
      [(0, _nameClass.default)('top', modifier)]: {
        top: `${size}`
      },
      [(0, _nameClass.default)('right', modifier)]: {
        right: `${size}`
      },
      [(0, _nameClass.default)('bottom', modifier)]: {
        bottom: `${size}`
      },
      [(0, _nameClass.default)('left', modifier)]: {
        left: `${size}`
      }
    })];

    const utilities = _lodash.default.flatMap(generators, generator => {
      return _lodash.default.flatMap(theme('inset'), generator);
    });

    addUtilities(utilities, variants('inset'));
  };
}