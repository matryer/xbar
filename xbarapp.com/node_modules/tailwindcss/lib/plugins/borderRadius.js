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
      [(0, _nameClass.default)('rounded', modifier)]: {
        borderRadius: `${value}`
      }
    }), (value, modifier) => ({
      [(0, _nameClass.default)('rounded-t', modifier)]: {
        borderTopLeftRadius: `${value}`,
        borderTopRightRadius: `${value}`
      },
      [(0, _nameClass.default)('rounded-r', modifier)]: {
        borderTopRightRadius: `${value}`,
        borderBottomRightRadius: `${value}`
      },
      [(0, _nameClass.default)('rounded-b', modifier)]: {
        borderBottomRightRadius: `${value}`,
        borderBottomLeftRadius: `${value}`
      },
      [(0, _nameClass.default)('rounded-l', modifier)]: {
        borderTopLeftRadius: `${value}`,
        borderBottomLeftRadius: `${value}`
      }
    }), (value, modifier) => ({
      [(0, _nameClass.default)('rounded-tl', modifier)]: {
        borderTopLeftRadius: `${value}`
      },
      [(0, _nameClass.default)('rounded-tr', modifier)]: {
        borderTopRightRadius: `${value}`
      },
      [(0, _nameClass.default)('rounded-br', modifier)]: {
        borderBottomRightRadius: `${value}`
      },
      [(0, _nameClass.default)('rounded-bl', modifier)]: {
        borderBottomLeftRadius: `${value}`
      }
    })];

    const utilities = _lodash.default.flatMap(generators, generator => {
      return _lodash.default.flatMap(theme('borderRadius'), (value, modifier) => {
        return generator(value, modifier);
      });
    });

    addUtilities(utilities, variants('borderRadius'));
  };
}