; This file is local queries for nvim-treesitter.
; Locals may not work when definition is below usage, but nvim-treesitter seems to work well.
; See: https://github.com/tree-sitter/tree-sitter/issues/918

(function) @scope
(function
  universal: _ @definition.parameter)
(formal
  name: _ @definition.parameter)

(rec_attrset
  bind: [
    (bind
      attrpath: (attrpath
        . (identifier) @definition.field))
    (inherit
      attr: (identifier) @definition.field)
    (inherit_from
      attr: (identifier) @definition.field)]) @scope

(let_attrset
  bind: [
    (bind
      attrpath: (attrpath
        . (identifier) @definition.var))
    (inherit
      attr: (identifier) @definition.var)
    (inherit_from
      attr: (identifier) @definition.var)]) @scope

(let
  bind: [
    (bind
      attrpath: (attrpath
        . (identifier) @definition.var))
    (inherit
      attr: (identifier) @definition.var)
    (inherit_from
      attr: (identifier) @definition.var)]) @scope

(variable) @reference
(inherit
  attr: (identifier) @reference)
