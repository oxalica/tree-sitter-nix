[
  ({ builtins.unknown = builtins.unknown; })
  #  ^ field
  #           ^ field
  #                     ^ variable.builtin
  #                             ^ punctuation.delimiter
  #                              ^ variable.builtin

  (builtins.unknown 42)
  #^ variable.builtin
  #        ^ punctuation.delimiter
  #         ^ function.builtin

  builtins null true false map throw
  # ^ variable.builtin
  #        ^ constant.builtin
  #             ^ boolean
  #                  ^ boolean
  #                        ^ function.builtin
  #                            ^ exception
]
