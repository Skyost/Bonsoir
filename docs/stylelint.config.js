module.exports = {
  extends: [
    'stylelint-config-standard-scss',
    'stylelint-config-recommended-vue'
  ],
  rules: {
    'string-quotes': 'single',
    'at-rule-no-unknown': null,
    'scss/at-rule-no-unknown': true,
    'scss/no-global-function-names': null,
    'function-no-unknown': [
      true,
      {
        ignoreFunctions: ['lighten', 'darken']
      }
    ],
    'color-function-notation': null
  }
}
