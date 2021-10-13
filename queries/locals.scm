; Locals may not work when definition is below usage, but nvim-treesitter seems to work well.
; See: https://github.com/tree-sitter/tree-sitter/issues/918

(function) @local.scope
(function
  universal: _ @local.definition)
(formal
  name: _ @local.definition)

(rec_attrset
  bind: (bind
    attrpath: (attrpath
      . (identifier) @local.definition))
) @local.scope

(let_attrset
  bind: (bind
    attrpath: (attrpath
      . (identifier) @local.definition))
) @local.scope

(let
  bind: (bind
    attrpath: (attrpath
      . (identifier) @local.definition))) @local.scope

(variable) @local.reference
(inherit
  attr: (identifier) @local.reference)
