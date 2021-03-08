var defaultFormatter = require('./formatter');
var { red, bold } = require('colorette');
var util = require('./util');
var groupBy = require('lodash.groupby');
var forOwn = require('lodash.forown');
var difference = require('lodash.difference');

module.exports = function(opts = {}) {
  var formatter = opts.formatter || defaultFormatter({
    noIcon: opts.noIcon,
    noPlugin: opts.noPlugin,
  });

  var pluginFilter;
  if (!opts.plugins) {
    // Every plugin
    pluginFilter = function() { return true; };
  } else if (opts.plugins.every(function(plugin) { return plugin[0] === '!'; })) {
    // Deny list
    pluginFilter = function(message) {
      return opts.plugins.indexOf('!' + message.plugin) === -1;
    };
  } else {
    // Allow list
    pluginFilter = function(message) {
      return opts.plugins.indexOf(message.plugin) !== -1;
    };
  }

  var messageFilter = opts.filter || (message => message.type === 'warning');

  return {
    postcssPlugin: 'postcss-reporter',
    OnceExit (css, { result }) {
      var messagesToLog = result.messages
        .filter(pluginFilter)
        .filter(messageFilter);

      var resultSource = (!result.root.source) ? ''
        : result.root.source.input.file || result.root.source.input.id;

      var sourceGroupedMessages = groupBy(messagesToLog, message => {
        return util.getLocation(message).file || resultSource;
      });

      var report = '';
      forOwn(sourceGroupedMessages, function(messages, source) {
        report += formatter({
          messages: messages,
          source: source,
        });
      });

      if (opts.clearReportedMessages) {
        result.messages = difference(result.messages, messagesToLog);
      }

      if (opts.clearAllMessages) {
        var messagesToClear = result.messages.filter(pluginFilter);
        result.messages = difference(result.messages, messagesToClear);
      }


      if (!report) return;

      console.log(report);

      if (opts.throwError && shouldThrowError()) {
        throw new Error(red(bold('\n** postcss-reporter: warnings or errors were found **')));
      }

      function shouldThrowError() {
        return (
          messagesToLog.length
          && messagesToLog.some(message => {
            return message.type === 'warning' || message.type === 'error';
          })
        );
      }
    },
  };
};
