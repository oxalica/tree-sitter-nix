; This file is highlight queries for nvim-treesitter.
;
; 1. In nvim-treesitter's queries, later occurred captures have higher precedence over previous ones,
;    which is opposite to tree-sitter's first-prior order.
;    https://github.com/tree-sitter/tree-sitter/issues/632
; 2. nvim-treesitter needs @none to clear string color inside interpolation.
; 3. nvim-treesitter doesn't support `(#is-not? local)` yet.
; 4. Interpolation and escapes need to set priority to override injected languages.

; Keywords

[
  "assert"
  "with"
  "let"
  "in"
  "rec"
  "inherit"
] @keyword

[
  "if"
  "then"
  "else"
] @conditional

(select
  "or" @keyword.operator)

; Comments

(comment) @comment

; String like

[ (string) (indented_string) ] @string

(path) @string.special
(path_invalid_slash) @error
(uri) @string.special ; Or @text.uri?

; Override injected languages.
(escape_sequence (#set! "priority" 105)) @string.escape

; Variable reference

(variable) @variable

; Field access

(select
  attrpath: (attrpath
    (identifier) @property))
(has_attr
  attrpath: (attrpath
    (identifier) @property))

; Builtins

; Known builtins.
((variable) @variable.builtin
 (#match? @variable.builtin "^(__currentSystem|__currentTime|__nixPath|__nixVersion|__storeDir|builtins)$"))
((variable) @function.builtin
 (#match? @function.builtin "^(__add|__addErrorContext|__all|__any|__appendContext|__attrNames|__attrValues|__bitAnd|__bitOr|__bitXor|__catAttrs|__compareVersions|__concatLists|__concatMap|__concatStringsSep|__deepSeq|__div|__elem|__elemAt|__fetchurl|__filter|__filterSource|__findFile|__foldl'|__fromJSON|__functionArgs|__genList|__genericClosure|__getAttr|__getContext|__getEnv|__hasAttr|__hasContext|__hashFile|__hashString|__head|__intersectAttrs|__isAttrs|__isBool|__isFloat|__isFunction|__isInt|__isList|__isPath|__isString|__langVersion|__length|__lessThan|__listToAttrs|__mapAttrs|__match|__mul|__parseDrvName|__partition|__path|__pathExists|__readDir|__readFile|__replaceStrings|__seq|__sort|__split|__splitVersion|__storePath|__stringLength|__sub|__substring|__tail|__toFile|__toJSON|__toPath|__toXML|__trace|__tryEval|__typeOf|__unsafeDiscardOutputDependency|__unsafeDiscardStringContext|__unsafeGetAttrPos|__valueSize|abort|baseNameOf|derivation|derivationStrict|dirOf|fetchGit|fetchMercurial|fetchTarball|fromTOML|import|isNull|map|placeholder|removeAttrs|scopedImport|throw|toString)$"))

; Display entire builtins path as builtin variable (ex. `builtins.filter` is highlighted as one long builtin)
(select
  expression: (variable) @variable.builtin @_i
  attrpath: (attrpath
    (identifier) @variable.builtin)
  (#eq? @_i "builtins"))

; Render the last component of builtin paths as builtin function if is applied arguments.
(app
  function: (select
    expression: (variable) @variable.builtin
    attrpath: (attrpath
      (identifier) @function.builtin .)
    (#eq? @variable.builtin "builtins")))

; Special variables

((variable) @include (#eq? @include "import"))
((variable) @constant.builtin (#eq? @constant.builtin "null"))
((variable) @exception (#eq? @exception "throw"))
((variable) @boolean (#match? @boolean "^(true|false)$"))

; Function

(function
  universal: (identifier) @variable.parameter)
(function
  "@"? @punctuation.special
  ":" @punctuation.delimiter)
(formal
  name: _ @variable.parameter
  "?"? @punctuation.delimiter)
(ellipses) @punctuation.special

; Field definition

(let
  bind: (bind
    attrpath: [
      (attrpath
        (identifier) @field)
      (attrpath
        . (identifier) @variable)]))

(let_attrset
  bind: (bind
    attrpath: [
      (attrpath
        (identifier) @field)
      (attrpath
        . (identifier) @variable)
      (attrpath
        . (identifier) @variable.builtin
        (#eq? @variable.builtin "body"))]))

(attrset
  bind: (bind
    attrpath: (attrpath
      (identifier) @field)))
(rec_attrset
  bind: (bind
    attrpath: (attrpath
      (identifier) @field)))

(inherit
  attr: (identifier) @variable)
(inherit_from
  attr: (identifier) @property)

; Operators

(unary
  operator: _ @operator)

(binary
  operator: _ @operator)

(has_attr
  "?" @operator)

; Integers, also highlight a unary -

(unary
  operator: "-" @number
  argument: (integer))
(integer) @number

; Floats, also highlight a unary -

(unary
  operator: "-" @float
  argument: (float))
(float) @float

; Punctuations

[
  "."
  ";"
  ","
  "="
] @punctuation.delimiter

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

(interpolation) @none
; Override injected languages.
((interpolation ["${" "}"] @punctuation.special)
  (#set! "priority" 105))
