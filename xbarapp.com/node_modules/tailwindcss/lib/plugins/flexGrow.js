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
    addUtilities(_lodash.default.fromPairs(_lodash.default.map(theme('flexGrow'), (value, modifier) => {
      return [(0, _nameClass.default)('flex-grow', modifier), {
        'flex-grow': value
      }];
    })), variants('flexGrow'));
  };
}