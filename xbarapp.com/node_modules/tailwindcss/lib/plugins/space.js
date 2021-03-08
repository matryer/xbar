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
    const generators = [(_size, modifier) => {
      const size = _size === '0' ? '0px' : _size;
      return {
        [`${(0, _nameClass.default)('space-y', modifier)} > :not([hidden]) ~ :not([hidden])`]: {
          '--tw-space-y-reverse': '0',
          'margin-top': `calc(${size} * calc(1 - var(--tw-space-y-reverse)))`,
          'margin-bottom': `calc(${size} * var(--tw-space-y-reverse))`
        },
        [`${(0, _nameClass.default)('space-x', modifier)} > :not([hidden]) ~ :not([hidden])`]: {
          '--tw-space-x-reverse': '0',
          'margin-right': `calc(${size} * var(--tw-space-x-reverse))`,
          'margin-left': `calc(${size} * calc(1 - var(--tw-space-x-reverse)))`
        }
      };
    }];

    const utilities = _lodash.default.flatMap(generators, generator => {
      return [..._lodash.default.flatMap(theme('space'), generator), {
        '.space-y-reverse > :not([hidden]) ~ :not([hidden])': {
          '--tw-space-y-reverse': '1'
        },
        '.space-x-reverse > :not([hidden]) ~ :not([hidden])': {
          '--tw-space-x-reverse': '1'
        }
      }];
    });

    addUtilities(utilities, variants('space'));
  };
}