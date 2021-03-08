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
    const utilities = _lodash.default.fromPairs(_lodash.default.map(theme('placeholderOpacity'), (value, modifier) => {
      return [`${(0, _nameClass.default)('placeholder-opacity', modifier)}::placeholder`, {
        '--tw-placeholder-opacity': value
      }];
    }));

    addUtilities(utilities, variants('placeholderOpacity'));
  };
}