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
    addUtilities({
      '*': {
        '--tw-shadow': '0 0 #0000'
      }
    }, {
      respectImportant: false
    });

    const utilities = _lodash.default.fromPairs(_lodash.default.map(theme('boxShadow'), (value, modifier) => {
      return [(0, _nameClass.default)('shadow', modifier), {
        '--tw-shadow': value === 'none' ? '0 0 #0000' : value,
        'box-shadow': [`var(--tw-ring-offset-shadow, 0 0 #0000)`, `var(--tw-ring-shadow, 0 0 #0000)`, `var(--tw-shadow)`].join(', ')
      }];
    }));

    addUtilities(utilities, variants('boxShadow'));
  };
}