"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.tailwindExtractor = tailwindExtractor;
exports.default = purgeUnusedUtilities;

var _lodash = _interopRequireDefault(require("lodash"));

var _postcss = _interopRequireDefault(require("postcss"));

var _postcssPurgecss = _interopRequireDefault(require("@fullhuman/postcss-purgecss"));

var _log = _interopRequireDefault(require("../util/log"));

var _htmlTags = _interopRequireDefault(require("html-tags"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function removeTailwindMarkers(css) {
  css.walkAtRules('tailwind', rule => rule.remove());
  css.walkComments(comment => {
    switch (comment.text.trim()) {
      case 'tailwind start base':
      case 'tailwind end base':
      case 'tailwind start components':
      case 'tailwind start utilities':
      case 'tailwind end components':
      case 'tailwind end utilities':
        comment.remove();
        break;

      default:
        break;
    }
  });
}

function tailwindExtractor(content) {
  // Capture as liberally as possible, including things like `h-(screen-1.5)`
  const broadMatches = content.match(/[^<>"'`\s]*[^<>"'`\s:]/g) || [];
  const broadMatchesWithoutTrailingSlash = broadMatches.map(match => _lodash.default.trimEnd(match, '\\')); // Capture classes within other delimiters like .block(class="w-1/2") in Pug

  const innerMatches = content.match(/[^<>"'`\s.(){}[\]#=%]*[^<>"'`\s.(){}[\]#=%:]/g) || [];
  return broadMatches.concat(broadMatchesWithoutTrailingSlash).concat(innerMatches);
}

function purgeUnusedUtilities(config, configChanged) {
  const purgeEnabled = _lodash.default.get(config, 'purge.enabled', config.purge !== false && config.purge !== undefined && process.env.NODE_ENV === 'production');

  if (!purgeEnabled) {
    return removeTailwindMarkers;
  } // Skip if `purge: []` since that's part of the default config


  if (Array.isArray(config.purge) && config.purge.length === 0) {
    if (configChanged) {
      _log.default.warn(['Tailwind is not purging unused styles because no template paths have been provided.', 'If you have manually configured PurgeCSS outside of Tailwind or are deliberately not removing unused styles, set `purge: false` in your Tailwind config file to silence this warning.', 'https://tailwindcss.com/docs/controlling-file-size/#removing-unused-css']);
    }

    return removeTailwindMarkers;
  }

  const {
    defaultExtractor,
    ...purgeOptions
  } = config.purge.options || {};
  return (0, _postcss.default)([function (css) {
    const mode = _lodash.default.get(config, 'purge.mode', 'layers');

    if (!['all', 'layers'].includes(mode)) {
      throw new Error('Purge `mode` must be one of `layers` or `all`.');
    }

    if (mode === 'all') {
      return;
    }

    const layers = _lodash.default.get(config, 'purge.layers', ['base', 'components', 'utilities']);

    css.walkComments(comment => {
      switch (comment.text.trim()) {
        case `purgecss start ignore`:
          comment.before(_postcss.default.comment({
            text: 'purgecss end ignore'
          }));
          break;

        case `purgecss end ignore`:
          comment.before(_postcss.default.comment({
            text: 'purgecss end ignore'
          }));
          comment.text = 'purgecss start ignore';
          break;

        default:
          break;
      }

      layers.forEach(layer => {
        switch (comment.text.trim()) {
          case `tailwind start ${layer}`:
            comment.text = 'purgecss end ignore';
            break;

          case `tailwind end ${layer}`:
            comment.text = 'purgecss start ignore';
            break;

          default:
            break;
        }
      });
    });
    css.prepend(_postcss.default.comment({
      text: 'purgecss start ignore'
    }));
    css.append(_postcss.default.comment({
      text: 'purgecss end ignore'
    }));
  }, removeTailwindMarkers, (0, _postcssPurgecss.default)({
    content: Array.isArray(config.purge) ? config.purge : config.purge.content,
    defaultExtractor: content => {
      const extractor = defaultExtractor || tailwindExtractor;
      const preserved = [...extractor(content)];

      if (_lodash.default.get(config, 'purge.preserveHtmlElements', true)) {
        preserved.push(..._htmlTags.default);
      }

      return preserved;
    },
    ...purgeOptions
  })]);
}