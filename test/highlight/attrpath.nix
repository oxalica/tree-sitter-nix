let
  foo.bar.baz = 42;
  # <- variable
  #  ^ punctuation.delimiter
  #   ^ field
  #      ^ punctuation.delimiter
  #       ^ field
  #           ^ punctuation.delimiter
  #               ^ punctuation.delimiter

  bar = foo.bar.baz;
  # <- variable
  #     ^ variable
  #        ^ punctuation.delimiter
  #         ^ property
  #            ^ punctuation.delimiter
  #             ^ property

  foo.${bar.baz} = 42;
  # <- variable
  #   ^ punctuation.special
  #    ^ punctuation.special
  #     ^ variable
  #        ^ punctuation.delimiter
  #         ^ property
  #            ^ punctuation.special

  attr = rec {
    # <- variable
    #    ^ keyword
    #        ^ punctuation.bracket

    foo."bar".${bar.baz}.bux = 42;
    # <- field
    #  ^ punctuation.delimiter
    #   ^ string
    #         ^ punctuation.special
    #           ^ variable
    #               ^ property
    #                  ^ punctuation.special
    #                    ^ field

    inherit bar;
    #       ^ variable

    inherit (foo) baz;
    #        ^ variable
    #             ^ property
  };
  # <- punctuation.bracket

  let_attrset = let {
    a = 42;
    # <- variable

    b.c = 42;
    # <- variable
    # ^ field

    body.foo = body.foo;
    # <- variable.builtin
    #    ^ field
    #          ^ variable
    #               ^ property
  };

in
  attrs.foo.bar ? foo.bar
  # <- variable
  #     ^ property
  #         ^ property
  #               ^ property
  #                   ^ property
