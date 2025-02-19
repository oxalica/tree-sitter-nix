module.exports = grammar({
  name: 'nix',

  extras: $ => [
    /\s/,
    $.comment,
  ],

  supertypes: $ => [
    $._expression
  ],

  inline: $ => [
  ],

  externals: $ => [
    $._string_fragment,
    $._indented_string_fragment,
    $._path_start,
    $._path_fragment,
    $.path_invalid_slash,
    $._path_end,
  ],

  word: $ => $.keyword,

  precedences: $ => [
    [
      $.app,
      'unary_negate',
      'binary_has_attr',
      'binary_concat',
      'binary_times',
      'binary_plus',
      'unary_not',
      'binary_update',
      'binary_compare',
      'binary_equal',
      'binary_and',
      'binary_or',
      'binary_imply',
    ]
  ],

  conflicts: $ => [
  ],

  rules: {
    source_expression: $ => field('expression', $._expression),

    // Keywords go before identifiers to let them take precedence when both are expected.
    // Test `let missing value (last)` would fail without this.
    // Workaround before https://github.com/tree-sitter/tree-sitter/pull/246
    keyword: $ => /if|then|else|let|inherit|in|rec|with|assert/,

    identifier: $ => /[a-zA-Z_][a-zA-Z0-9_\'\-]*/,
    integer: $ => /[0-9]+/,
    float: $ => /(([1-9][0-9]*\.[0-9]*)|(0?\.[0-9]+))([Ee][+-]?[0-9]+)?/,
    uri: $ => /[a-zA-Z][a-zA-Z0-9\+\-\.]*:[a-zA-Z0-9%\/\?:@\&=\+\$,\-_\.\!\~\*\']+/,

    _nix_path: $ => /<[a-zA-Z0-9\._\-\+]+(\/[a-zA-Z0-9\._\-\+]+)*>/,

    _path: $ => seq(
      $._path_start,
      repeat(choice(
        alias($.interpolation_immediate, $.interpolation),
        $._path_fragment,
        $.path_invalid_slash,
      )),
      $._path_end,
    ),

    path: $ => choice(
      $._nix_path,
      $._path,
    ),

    _expression: $ => choice(
      $.function,
      $.assert,
      $.with,
      $.let,
      $.if,
      $._operator_expression,
    ),

    function: $ => choice(
      seq(field('universal', $.identifier), ':', field('body', $._expression)),
      seq(field('formals', $.formals), ":", field('body', $._expression)),
      seq(field('formals', $.formals), '@', field('universal', $.identifier), ':', field('body', $._expression)),
      seq(field('universal', $.identifier), '@', field('formals', $.formals), ':', field('body', $._expression)),
    ),

    formals: $ => choice(
      seq('{', '}'),
      seq('{', sep1(field('formal', $.formal), ','), '}'),
      seq('{', sep1(field('formal', $.formal), ','), ',', field('ellipses', $.ellipses), '}'),
      seq('{', field('ellipses', $.ellipses), '}'),
    ),
    formal: $ => seq(field("name", $.identifier), optional(seq('?', field('default', $._expression)))),
    ellipses: $ => '...',

    assert: $ => seq('assert', field('condition', $._expression), ';', field('body', $._expression)),
    with: $ => seq('with', field('environment', $._expression), ';', field('body', $._expression)),
    let: $ => seq('let', repeat($._bind_or_inherit), 'in', field('body', $._expression)),

    if: $ => seq('if', field('condition', $._expression), 'then', field('consequence', $._expression), 'else', field('alternative', $._expression)),

    _operator_expression: $ => choice(
      $.unary,
      $.binary,
      $.has_attr,
      $.app,
      $._select_expression
    ),

    unary: $ => choice(
      ...[
        ['!', 'unary_not'],
        ['-', 'unary_negate'],
      ].map(([operator, precedence]) =>
        prec(precedence, seq(
          field('operator', operator),
          field('argument', $._operator_expression)
        ))
      )
    ),

    binary: $ => choice(
      // left assoc.
      ...[
        ['==', 'binary_equal'],
        ['!=', 'binary_equal'],
        ['<',  'binary_compare'],
        ['<=', 'binary_compare'],
        ['>',  'binary_compare'],
        ['>=', 'binary_compare'],
        ['&&', 'binary_and'],
        ['||', 'binary_or'],
        ['+',  'binary_plus'],
        ['-',  'binary_plus'],
        ['*',  'binary_times'],
        ['/',  'binary_times'],
      ].map(([operator, precedence]) =>
      prec.left(precedence, seq(
        field('left', $._operator_expression),
        field('operator', operator),
        field('right', $._operator_expression)
      ))),
      // right assoc.
      ...[
        ['->', 'binary_imply'],
        ['//', 'binary_update'],
        ['++', 'binary_concat'],
      ].map(([operator, precedence]) =>
      prec.right(precedence, seq(
        field('left', $._operator_expression),
        field('operator', operator),
        field('right', $._operator_expression)
      )))
    ),

    has_attr: $ => prec.left('binary_has_attr', seq(
      field('expression', $._operator_expression),
      '?',
      field('attrpath', $.attrpath)
    )),

    app: $ => seq(field('function', $._operator_expression), field('argument', $._select_expression)),

    _select_expression: $ => choice(
      $.select,
      $._primary_expression
    ),
    select: $ => seq(
      field('expression', $._primary_expression),
      '.',
      field('attrpath', $.attrpath),
      optional(seq('or', field('default', $._primary_expression)))
    ),

    _primary_expression: $ => choice(
      alias($.identifier, $.variable),
      $.integer,
      $.float,
      $.string,
      $.indented_string,
      $.path,
      $.uri,
      $.parenthesized,
      $.attrset,
      $.let_attrset,
      $.rec_attrset,
      $.list
    ),

    parenthesized: $ => seq('(', field('expression', $._expression), ')'),

    attrset: $ => seq('{', repeat($._bind_or_inherit), '}'),
    let_attrset: $ => seq('let', '{', repeat($._bind_or_inherit), '}'),
    rec_attrset: $ => seq('rec', '{', repeat($._bind_or_inherit), '}'),

    string: $ => seq(
      '"',
      repeat(choice(
        $._string_fragment,
        alias($.interpolation_immediate, $.interpolation),
        $.escape_sequence
      )),
      '"'
    ),
    escape_sequence: $ => token.immediate(/\\(.|\s)/), // Can also escape newline.

    indented_string: $ => seq(
      "''",
      repeat(choice(
        $._indented_string_fragment,
        alias($.interpolation_immediate, $.interpolation),
        alias($.indented_escape_sequence, $.escape_sequence),
      )),
      "''"
    ),
    indented_escape_sequence: $ => token.immediate(/'''|''\$|''\\(.|\s)/), // Can also escape newline.

    _bind_or_inherit: $ => field('bind', choice($.bind, $.inherit, $.inherit_from)),
    bind: $ => seq(field('attrpath', $.attrpath), '=', field('expression', $._expression), ';'),
    inherit: $ => seq('inherit', repeat(field('attr', $._attr)), ';'),
    inherit_from: $ => seq(
      'inherit',
      field('from', $.parenthesized),
      repeat(field('attr', $._attr)),
      ';'
    ),

    attrpath: $ => sep1(field('attr', $._attr), "."),
    _attr: $ => choice(
      $.identifier,
      $.string,
      $.interpolation
    ),

    interpolation: $ => seq('${', field('expression', $._expression), '}'),
    interpolation_immediate: $ => seq(token.immediate('${'), field('expression', $._expression), '}'),

    list: $ => seq('[', repeat(field('element', $._select_expression)), ']'),

    comment: $ => token(choice(
      seq('#', /.*/),
      seq(
        "/*",
        repeat(choice(
          /[^*]/,
          /\*[^/]/,
        )),
        "*/"
      )
    )),
  },
});

function sep1(rule, separator) {
  return seq(rule, repeat(seq(separator, rule)));
}
