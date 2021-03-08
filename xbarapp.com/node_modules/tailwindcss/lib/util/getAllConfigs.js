"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = getAllConfigs;

var _defaultConfigStub = _interopRequireDefault(require("../../stubs/defaultConfig.stub.js"));

var _featureFlags = require("../featureFlags");

var _lodash = require("lodash");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function getAllConfigs(config) {
  const configs = (0, _lodash.flatMap)([...(0, _lodash.get)(config, 'presets', [_defaultConfigStub.default])].reverse(), preset => {
    return getAllConfigs((0, _lodash.isFunction)(preset) ? preset() : preset);
  });
  const features = {// Add experimental configs here...
  };
  Object.keys(features).forEach(feature => {
    if ((0, _featureFlags.flagEnabled)(config, feature)) {
      configs.unshift(features[feature]);
    }
  });
  return [config, ...configs];
}