#include <tree_sitter/parser.h>
#include <inttypes.h>
#include <wctype.h>

enum TokenType {
  STRING_FRAGMENT,
  INDENTED_STRING_FRAGMENT,
  PATH_START,
  PATH_FRAGMENT,
  PATH_INVALID_SLASH,
  PATH_END,
};

static void advance(TSLexer *lexer) {
  lexer->advance(lexer, false);
}

static void skip(TSLexer *lexer) {
  lexer->advance(lexer, true);
}

// Here we only parse literal fragment inside a string.
// Delimiter, interpolation and escape sequence are handled by the parser and we simply stop at them.
//
// The implementation is inspired by tree-sitter-javascript:
// https://github.com/tree-sitter/tree-sitter-javascript/blob/fdeb68ac8d2bd5a78b943528bb68ceda3aade2eb/src/scanner.c#L19
static bool scan_string_fragment(TSLexer *lexer) {
  lexer->result_symbol = STRING_FRAGMENT;
  for (bool has_content = false;; has_content = true) {
    lexer->mark_end(lexer);
    switch (lexer->lookahead) {
      case '"':
      case '\\':
        return has_content;
      case '$':
        advance(lexer);
        if (lexer->lookahead == '{') {
          return has_content;
        } else if (lexer->lookahead != '"' && lexer->lookahead != '\\') {
          // Any char following '$' other than '"', '\\' and '{' (which was handled above)
          // should be consumed as additional string content.
          // This means `$${` doesn't start an interpolation, but `$$${` does.
          advance(lexer);
        }
        break;
      // Simply give up on EOF or '\0'.
      case '\0':
        return false;
      default:
        advance(lexer);
    }
  }
}

// See comments of scan_string_fragment.
static bool scan_indented_string_fragment(TSLexer *lexer) {
  lexer->result_symbol = INDENTED_STRING_FRAGMENT;
  for (bool has_content = false;; has_content = true) {
    lexer->mark_end(lexer);
    switch (lexer->lookahead) {
      case '$':
        advance(lexer);
        if (lexer->lookahead == '{') {
          return has_content;
        } else if (lexer->lookahead != '\'') {
          // Any char following '$' other than '\'' and '{' (which was handled above)
          // should be consumed as additional string content.
          // This means `$${` doesn't start an interpolation, but `$$${` does.
          advance(lexer);
        }
        break;
      case '\'':
        advance(lexer);
        if (lexer->lookahead == '\'') {
          // Two single quotes always stop current string fragment.
          // It can be either an end delimiter '', or escape sequences ''', ''$, ''\<any>
          return has_content;
        }
        break;
      // Simply give up on EOF or '\0'.
      case '\0':
        return false;
      default:
        advance(lexer);
    }
  }
}

static bool is_valid_path_char(int32_t c) {
  return iswalnum(c) || c == '.' || c == '_' || c == '+' || c == '-';
}

// Indicate starting of a path, spanning the first segment including `/`.
//
// `~/f`, `/f`, `foo/f`, `~/${`, `/${`, `foo/${`
//  ^^     ^     ^^^^     ^^      ^      ^^^^
static bool scan_path_start(TSLexer *lexer) {
  lexer->result_symbol = PATH_START;

  while (iswspace(lexer->lookahead)) {
    skip(lexer);
  }

  // The first segment must be `~/`, `/`, or any number of path chars followed by `/`.
  if (lexer->lookahead == '~') {
    advance(lexer);
  } else {
    while (is_valid_path_char(lexer->lookahead)) {
      advance(lexer);
    }
  }
  if (lexer->lookahead != '/') {
    return false;
  }
  advance(lexer);
  lexer->mark_end(lexer);

  // The second segment must starts with `${` or any valid path chars.
  if (lexer->lookahead == '$') {
    advance(lexer);
    if (lexer->lookahead == '{') {
      return true;
    }
  } else if (is_valid_path_char(lexer->lookahead)) {
    return true;
  }
  return false;
}

// A valid path fragment, end of path, or a parsable but invalid slash.
//
// Valid path fragment: `/` following `${`, or simply `/any_valid_chars` or `any_valid_chars`
// Invalid slash: `/` follows any invalid character other than `${`, which only appears as
//                trailing slash or redundant slash.
// End of path: Zero sized token if any invalid character other than `${` follows.
// Otherwise, it returns false (including an immediate `${`).
static bool scan_path_fragment(TSLexer *lexer) {
  lexer->result_symbol = PATH_FRAGMENT;

  // Process '/' only at the start.
  // If '/' follows '${' or any valid path character, itself is a valid path fragment.
  // Otherwise, it is the last character of a path, which is a trailing slash.
  if (lexer->lookahead == '/') {
    advance(lexer);
    lexer->mark_end(lexer);
    if (!is_valid_path_char(lexer->lookahead)) {
      if (lexer->lookahead == '$') {
        advance(lexer);
        if (lexer->lookahead == '{') {
          return true;
        }
      }
      lexer->result_symbol = PATH_INVALID_SLASH;
      return true;
    }
  } else if (!is_valid_path_char(lexer->lookahead)) {
    // If a `${` follows, leave it for the internal lexer to start an interpolation.
    if (lexer->lookahead == '$') {
      lexer->mark_end(lexer);
      advance(lexer);
      if (lexer->lookahead == '{') {
        return false;
      }
    }
    // Otherwise, it's the end of a path. Exit the path state.
    // This would not cause dead-loop since we won't scan path fragment outside the path.
    lexer->result_symbol = PATH_END;
    return true;
  }

  // Here must be at least one valid path character follows.
  while (is_valid_path_char(lexer->lookahead)) {
    advance(lexer);
  }
  return true;
}

void *tree_sitter_nix_external_scanner_create() {
  return NULL;
}

bool tree_sitter_nix_external_scanner_scan(void *payload, TSLexer *lexer,
                                            const bool *valid_symbols) {
  // Path is a basic token which can be parsed even during error recovery. It should goes first.
  // Note that during error recovery, everything becomes valid.
  // See: https://github.com/tree-sitter/tree-sitter/issues/1259
  if (valid_symbols[PATH_START]) {
    return scan_path_start(lexer);
  } else if (valid_symbols[PATH_FRAGMENT] || valid_symbols[PATH_END] || valid_symbols[PATH_INVALID_SLASH]) {
    return scan_path_fragment(lexer);
  } else if (valid_symbols[STRING_FRAGMENT]) {
    return scan_string_fragment(lexer);
  } else if (valid_symbols[INDENTED_STRING_FRAGMENT]) {
    return scan_indented_string_fragment(lexer);
  }

  return false;
}

unsigned tree_sitter_nix_external_scanner_serialize(void *payload, char *buffer) {
  return 0;
}

void tree_sitter_nix_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) { }

void tree_sitter_nix_external_scanner_destroy(void *payload) { }
