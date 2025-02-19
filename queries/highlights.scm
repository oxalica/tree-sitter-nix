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

(escape_sequence) @string.escape

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
        . (identifier) @variable)
      (attrpath
        (identifier) @field)]))

(let_attrset
  bind: (bind
    attrpath: [
      (attrpath
        . (identifier) @variable.builtin
        (#eq? @variable.builtin "body"))
      (attrpath
        . (identifier) @variable)
      (attrpath
        (identifier) @field)]))

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

; Special variables

((variable) @include (#eq? @include "import") (#is-not? local))
((variable) @constant.builtin (#eq? @constant.builtin "null") (#is-not? local))
((variable) @exception (#eq? @exception "throw") (#is-not? local))
((variable) @boolean (#match? @boolean "^(true|false)$") (#is-not? local))

; Builtins

; Render the last component of builtin paths as builtin function if is applied arguments.
(app
  function: (select
    expression: ((variable) @variable.builtin
      (#eq? @variable.builtin "builtins")
      (#is-not? local))
    attrpath: (attrpath
      (identifier) @function.builtin .)))

; Display entire builtins path as builtin variable (ex. `builtins.filter` is highlighted as one long builtin)
(select
  expression: ((variable) @variable.builtin @_i
    (#eq? @_i "builtins")
    (#is-not? local))
  attrpath: (attrpath
    (identifier) @variable.builtin))

; Known builtins.
((variable) @variable.builtin
  (#match? @variable.builtin "^(__currentSystem|__currentTime|__nixPath|__nixVersion|__storeDir|builtins)$")
  (#is-not? local))
((variable) @function.builtin
  (#match? @function.builtin "^(__add|__addErrorContext|__all|__any|__appendContext|__attrNames|__attrValues|__bitAnd|__bitOr|__bitXor|__catAttrs|__compareVersions|__concatLists|__concatMap|__concatStringsSep|__deepSeq|__div|__elem|__elemAt|__fetchurl|__filter|__filterSource|__findFile|__foldl'|__fromJSON|__functionArgs|__genList|__genericClosure|__getAttr|__getContext|__getEnv|__hasAttr|__hasContext|__hashFile|__hashString|__head|__intersectAttrs|__isAttrs|__isBool|__isFloat|__isFunction|__isInt|__isList|__isPath|__isString|__langVersion|__length|__lessThan|__listToAttrs|__mapAttrs|__match|__mul|__parseDrvName|__partition|__path|__pathExists|__readDir|__readFile|__replaceStrings|__seq|__sort|__split|__splitVersion|__storePath|__stringLength|__sub|__substring|__tail|__toFile|__toJSON|__toPath|__toXML|__trace|__tryEval|__typeOf|__unsafeDiscardOutputDependency|__unsafeDiscardStringContext|__unsafeGetAttrPos|__valueSize|abort|baseNameOf|derivation|derivationStrict|dirOf|fetchGit|fetchMercurial|fetchTarball|fromTOML|import|isNull|map|placeholder|removeAttrs|scopedImport|throw|toString)$")
  (#is-not? local))

; Field access

(select
  attrpath: (attrpath
    (identifier) @property))
(has_attr
  attrpath: (attrpath
    (identifier) @property))

; Variable reference

(variable) @variable

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

; Operators

(unary
  operator: _ @operator)

(binary
  operator: _ @operator)

(has_attr
  "?" @operator)

; Punctuations

(interpolation
  [ "${" "}" ] @punctuation.special)

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
