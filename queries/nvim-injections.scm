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

; Manually marked with an indicator comment
; FIXME: Cannot dynamic inject before `#offset!` issue being resolved.
; See: https://github.com/neovim/neovim/issues/16032

; Using `#set!` inside `[]` doesn't work, so we need to split these queries.
(
  ((comment) @_language (#any-of? @_language "# bash" "/* bash */") (#set! "language" "bash")) .
  [
    ((indented_string) @content)
    (bind
      expression: [
        (indented_string) @content
        (binary (indented_string) @content)
        (app argument: (indented_string) @content)])]
  (#offset! @content 0 2 0 -2))
(
  ((comment) @_language (#any-of? @_language "# fish" "/* fish */") (#set! "language" "fish")) .
  [
    ((indented_string) @content)
    (bind
      expression: [
        (indented_string) @content
        (binary (indented_string) @content)
        (app argument: (indented_string) @content)])]
  (#offset! @content 0 2 0 -2))
(
  ((comment) @_language (#any-of? @_language "# vim" "/* vim */") (#set! "language" "vim")) .
  [
    ((indented_string) @content)
    (bind
      expression: [
        (indented_string) @content
        (binary (indented_string) @content)
        (app argument: (indented_string) @content)])]
  (#offset! @content 0 2 0 -2))
(
  ((comment) @_language (#any-of? @_language "# tmux" "/* tmux */") (#set! "language" "tmux")) .
  [
    ((indented_string) @content)
    (bind
      expression: [
        (indented_string) @content
        (binary (indented_string) @content)
        (app argument: (indented_string) @content)])]
  (#offset! @content 0 2 0 -2))
(
  ((comment) @_language (#any-of? @_language "# toml" "/* toml */") (#set! "language" "toml")) .
  [
    ((indented_string) @content)
    (bind
      expression: [
        (indented_string) @content
        (binary (indented_string) @content)
        (app argument: (indented_string) @content)])]
  (#offset! @content 0 2 0 -2))
(
  ((comment) @_language (#any-of? @_language "# yaml" "/* yaml */") (#set! "language" "yaml")) .
  [
    ((indented_string) @content)
    (bind
      expression: [
        (indented_string) @content
        (binary (indented_string) @content)
        (app argument: (indented_string) @content)])]
  (#offset! @content 0 2 0 -2))

; Reverse inject interpolation to override other injected languages.
; I cannot find other way to correctly highlight interpolations inside injected string.
; Related: https://github.com/nvim-treesitter/nvim-treesitter/issues/1688
(interpolation
  expression: (_) @nix)

(comment) @comment
