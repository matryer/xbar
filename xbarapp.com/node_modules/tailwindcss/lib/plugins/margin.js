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
      [(0, _nameClass.default)('m', modifier)]: {
        margin: `${size}`
      }
    }), (size, modifier) => ({
      [(0, _nameClass.default)('my', modifier)]: {
        'margin-top': `${size}`,
        'margin-bottom': `${size}`
      },
      [(0, _nameClass.default)('mx', modifier)]: {
        'margin-left': `${size}`,
        'margin-right': `${size}`
      }
    }), (size, modifier) => ({
      [(0, _nameClass.default)('mt', modifier)]: {
        'margin-top': `${size}`
      },
      [(0, _nameClass.default)('mr', modifier)]: {
        'margin-right': `${size}`
      },
      [(0, _nameClass.default)('mb', modifier)]: {
        'margin-bottom': `${size}`
      },
      [(0, _nameClass.default)('ml', modifier)]: {
        'margin-left': `${size}`
      }
    })];

    const utilities = _lodash.default.flatMap(generators, generator => {
      return _lodash.default.flatMap(theme('margin'), generator);
    });

    addUtilities(utilities, variants('margin'));
  };
}