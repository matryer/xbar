'use strict'
const path = require('path')
module.exports = function getMapfile(options) {
  if (options.map && typeof options.map.annotation === 'string') {
    return `${path.dirname(options.to)}/${options.map.annotation}`
  }
  return `${options.to}.map`
}
