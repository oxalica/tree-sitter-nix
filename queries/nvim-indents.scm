[
  ; Bracket like
  (let)
  (attrset)
  (rec_attrset)
  (let_attrset)
  (parenthesized)
  (list)

  ; Binding
  (bind)
  (inherit)
  (inherit_from)
  (formal)

  ; Binary operations
  (binary)
  (has_attr)
  (select)
  (app)
] @indent

; Conditional
(if) @indent

[
  "in"
  "}"
  "]"
  ")"
  "then"
  "else"
] @branch

[
  (comment)
  (string)
  (indented_string)
] @ignore
