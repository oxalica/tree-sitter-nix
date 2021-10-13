[
  foo foo.bar
  # ^ variable
  #   ^ variable
  #      ^ punctuation.delimiter
  #       ^ property

  ./foo ./foo/ <nixpkgs>
  # ^ string.special
  #     ^ string.special
  #            ^ string.special

  ./foo${foo}/bar/
  # <- string.special
  #    ^ punctuation.special
  #     ^ punctuation.special
  #      ^ variable
  #         ^ punctuation.special
  #          ^ string.special
  #              ^ error

  /${foo}
  # <- string.special
  #  ^ variable
  #     ^ punctuation.special
  # FIXME
  # x punctuation.special

  https://example.com
  # <- string.special

  123 (-1)
  # ^ number
  #    ^ number

  123.456 1.e-2 (-1.e-2)
  # ^ float
  #       ^ float
  #              ^ float

  (-1 1)
  #^ operator

  (if true then true else false)
  #^ conditional
  #        ^ conditional
  #                  ^ conditional

  ({ or = 1; }.or or 42)
  #  ^ field
  #            ^ property
  #               ^ keyword.operator

  (x: x)
  #^ variable.parameter
  # ^ punctuation.delimiter
  #   ^ variable

  (x@{ a, b ? a }: x)
  #^ variable.parameter
  # ^ punctuation.special
  #  ^ punctuation.bracket
  #    ^ variable.parameter
  #     ^ punctuation.delimiter
  #       ^ variable.parameter
  #         ^ punctuation.delimiter
  #           ^ variable

  ({ a, b ? a }@x: x)
  #  ^ variable.parameter
  #            ^ punctuation.special
  #             ^ variable.parameter

  (1 + !{}.a.b or 42 ? a.b)
  #  ^ operator
  #    ^ operator
  #       ^ punctuation.delimiter
  #        ^ property
  #         ^ punctuation.delimiter
  #          ^ property
  #            ^ keyword.operator
  #                  ^ operator
  #                    ^ property
  #                      ^ property
]
