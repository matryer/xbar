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
      [(0, _nameClass.default)('p', modifier)]: {
        padding: `${size}`
      }
    }), (size, modifier) => ({
      [(0, _nameClass.default)('py', modifier)]: {
        'padding-top': `${size}`,
        'padding-bottom': `${size}`
      },
      [(0, _nameClass.default)('px', modifier)]: {
        'padding-left': `${size}`,
        'padding-right': `${size}`
      }
    }), (size, modifier) => ({
      [(0, _nameClass.default)('pt', modifier)]: {
        'padding-top': `${size}`
      },
      [(0, _nameClass.default)('pr', modifier)]: {
        'padding-right': `${size}`
      },
      [(0, _nameClass.default)('pb', modifier)]: {
        'padding-bottom': `${size}`
      },
      [(0, _nameClass.default)('pl', modifier)]: {
        'padding-left': `${size}`
      }
    })];

    const utilities = _lodash.default.flatMap(generators, generator => {
      return _lodash.default.flatMap(theme('padding'), generator);
    });

    addUtilities(utilities, variants('padding'));
  };
}