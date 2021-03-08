var { bold, underline, yellow } = require('colorette');
var path = require('path');
var sortBy = require('lodash.sortby');
var util = require('./util');

var supportsLargeCharset = process.platform !== 'win32' || process.env.CI || process.env.TERM === 'xterm-256color';
var warningSymbol = supportsLargeCharset ? '⚠' : '!!';

module.exports = function(opts) {
  var options = opts || {};
  var sortByPosition = (typeof options.sortByPosition !== 'undefined') ? options.sortByPosition : true;
  var positionless = options.positionless || 'first';

  return function(input) {
    var messages = input.messages.filter(function(message) {
      return typeof message.text === 'string';
    });
    var source = input.source;

    if (!messages.length) return '';

    var orderedMessages = sortBy(
      messages,
      function(m) {
        if (!m.line) return 1;
        if (positionless === 'any') return 1;
        if (positionless === 'first') return 2;
        if (positionless === 'last') return 0;
      },
      function(m) {
        if (!sortByPosition) return 1;
        return m.line;
      },
      function(m) {
        if (!sortByPosition) return 1;
        return m.column;
      }
    );

    var output = '\n';

    if (source) {
      output += bold(underline(logFrom(source))) + '\n';
    }

    orderedMessages.forEach(function(w) {
      output += messageToString(w) + '\n';
    });

    return output;

    function messageToString(message) {
      var location = util.getLocation(message);
      var str = '';

      if (location.line) {
        str += bold(location.line);
      }

      if (location.column) {
        str += bold(':' + location.column);
      }

      if (location.line || location.column) {
        str += '\t';
      }

      if (!options.noIcon && message.type === 'warning') {
        str += yellow(warningSymbol + '  ');
      }

      str += message.text;
      if (!options.noPlugin) {
        str += yellow(' [' + message.plugin + ']');
      }
      return str;
    }

    function logFrom(fromValue) {
      if (fromValue.charAt(0) === '<') return fromValue;
      return path.relative(process.cwd(), fromValue).split(path.sep).join('/');
    }
  };
};
