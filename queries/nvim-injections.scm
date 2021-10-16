; Common field names containg bash script.

(bind
  attrpath: ((attrpath) @_path
    (#match? @_path "^([a-z][A-Za-z]*Phase|(pre|post)[A-Z][A-Za-z]*|(.*\\.)?script)$"))
  expression: [
    (indented_string) @bash
    (if (indented_string) @bash)
    (let body: (indented_string) @bash)

    ; Rough match over `lib.optionalString ''bar''`
    (app function: (app) argument: (indented_string) @bash)

    ; Rough match inner expressions concated with `+`
    (binary [
      (indented_string) @bash
      (parenthesized [ (if (indented_string) @bash) (let body: (indented_string) @bash)])
      (app function: (app) argument: (indented_string) @bash)
      (binary [
        (indented_string) @bash
        (parenthesized [ (if (indented_string) @bash) (let body: (indented_string) @bash)])
        (app function: (app) argument: (indented_string) @bash)
        (binary [
          (indented_string) @bash
          (parenthesized [ (if (indented_string) @bash) (let body: (indented_string) @bash)])
          (app function: (app) argument: (indented_string) @bash)
          (binary [
            (indented_string) @bash
            (parenthesized [ (if (indented_string) @bash) (let body: (indented_string) @bash)])
            (app function: (app) argument: (indented_string) @bash)])])])])])

; Trivial builders

; FIXME: Write them together with `[]` will cause lua error.
(app
  function: (app
    function: ((_) @_func
      (#match? @_func "(^|\\.)writeShellScript(Bin)?$")))
  argument: (indented_string) @bash)
(app
  (app
    function: (app
      function: ((_) @_func
        (#match? @_func "(^|\\.)runCommand(CC|NoCC|Local|NoCCLocal)?$"))))
  argument: (indented_string) @bash)

; Reverse inject interpolation to override other injected languages.
; I cannot find other way to correctly highlight interpolations inside injected string.
; Related: https://github.com/nvim-treesitter/nvim-treesitter/issues/1688
(interpolation
  expression: (_) @nix)

(comment) @comment
