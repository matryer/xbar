"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = _default;

var _lodash = _interopRequireDefault(require("lodash"));

var _postcssFunctions = _interopRequireDefault(require("postcss-functions"));

var _didyoumean = _interopRequireDefault(require("didyoumean"));

var _transformThemeValue = _interopRequireDefault(require("../util/transformThemeValue"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function findClosestExistingPath(theme, path) {
  const parts = _lodash.default.toPath(path);

  do {
    parts.pop();
    if (_lodash.default.hasIn(theme, parts)) break;
  } while (parts.length);

  return parts.length ? parts : undefined;
}

function pathToString(path) {
  if (typeof path === 'string') return path;
  return path.reduce((acc, cur, i) => {
    if (cur.includes('.')) return `${acc}[${cur}]`;
    return i === 0 ? cur : `${acc}.${cur}`;
  }, '');
}

function list(items) {
  return items.map(key => `'${key}'`).join(', ');
}

function listKeys(obj) {
  return list(Object.keys(obj));
}

function validatePath(config, path, defaultValue) {
  const pathString = Array.isArray(path) ? pathToString(path) : _lodash.default.trim(path, `'"`);
  const pathSegments = Array.isArray(path) ? path : _lodash.default.toPath(pathString);

  const value = _lodash.default.get(config.theme, pathString, defaultValue);

  if (typeof value === 'undefined') {
    let error = `'${pathString}' does not exist in your theme config.`;
    const parentSegments = pathSegments.slice(0, -1);

    const parentValue = _lodash.default.get(config.theme, parentSegments);

    if (_lodash.default.isObject(parentValue)) {
      const validKeys = Object.keys(parentValue).filter(key => validatePath(config, [...parentSegments, key]).isValid);
      const suggestion = (0, _didyoumean.default)(_lodash.default.last(pathSegments), validKeys);

      if (suggestion) {
        error += ` Did you mean '${pathToString([...parentSegments, suggestion])}'?`;
      } else if (validKeys.length > 0) {
        error += ` '${pathToString(parentSegments)}' has the following valid keys: ${list(validKeys)}`;
      }
    } else {
      const closestPath = findClosestExistingPath(config.theme, pathString);

      if (closestPath) {
        const closestValue = _lodash.default.get(config.theme, closestPath);

        if (_lodash.default.isObject(closestValue)) {
          error += ` '${pathToString(closestPath)}' has the following keys: ${listKeys(closestValue)}`;
        } else {
          error += ` '${pathToString(closestPath)}' is not an object.`;
        }
      } else {
        error += ` Your theme has the following top-level keys: ${listKeys(config.theme)}`;
      }
    }

    return {
      isValid: false,
      error
    };
  }

  if (!(typeof value === 'string' || typeof value === 'number' || typeof value === 'function' || value instanceof String || value instanceof Number || Array.isArray(value))) {
    let error = `'${pathString}' was found but does not resolve to a string.`;

    if (_lodash.default.isObject(value)) {
      let validKeys = Object.keys(value).filter(key => validatePath(config, [...pathSegments, key]).isValid);

      if (validKeys.length) {
        error += ` Did you mean something like '${pathToString([...pathSegments, validKeys[0]])}'?`;
      }
    }

    return {
      isValid: false,
      error
    };
  }

  const [themeSection] = pathSegments;
  return {
    isValid: true,
    value: (0, _transformThemeValue.default)(themeSection)(value)
  };
}

function _default(config) {
  return root => (0, _postcssFunctions.default)({
    functions: {
      theme: (path, ...defaultValue) => {
        const {
          isValid,
          value,
          error
        } = validatePath(config, path, defaultValue.length ? defaultValue : undefined);

        if (!isValid) {
          throw root.error(error);
        }

        return value;
      }
    }
  })(root);
}