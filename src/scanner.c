#include <tree_sitter/parser.h>
#include <inttypes.h>

enum TokenType {
  STRING_FRAGMENT,
  INDENTED_STRING_FRAGMENT,
  PATH_FRAGMENT,
  PATH_TRAILING_SLASH,
};

static void advance(TSLexer *lexer) {
  lexer->advance(lexer, false);
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
  return 'a' <= c && c <= 'z' ||
    'A' <= c && c <= 'Z' ||
    '0' <= c && c <= '9' ||
    c == '.' || c == '_' || c == '+' || c == '-';
}

static bool scan_path_fragment(TSLexer *lexer) {
  bool has_content = false;
  lexer->result_symbol = PATH_FRAGMENT;

  // Process '/' only at the start.
  // If '/' follows '${' or any valid path character, itself is a valid path fragment.
  // Otherwise, it is the last character of a path, which is a trailing slash.
  if (lexer->lookahead == '/') {
    advance(lexer);
    lexer->mark_end(lexer);
    if (lexer->lookahead == '$') {
      advance(lexer);
      if (lexer->lookahead == '{') {
        return true;
      }
      lexer->result_symbol = PATH_TRAILING_SLASH;
      return true;
    } else if (!is_valid_path_char(lexer->lookahead)) {
      lexer->result_symbol = PATH_TRAILING_SLASH;
      return true;
    }

    // A valid path character follows. Continue processing.
    has_content = true;
  }

  for (;; has_content = true) {
    lexer->mark_end(lexer);
    if (is_valid_path_char(lexer->lookahead)) {
      advance(lexer);
    } else {
      // Here we stop on '${' and '/', which can be handled in parse or next call to `scan_path_fragment`.
      return has_content;
    }
  }
}

void *tree_sitter_nix_external_scanner_create() {
  return NULL;
}

bool tree_sitter_nix_external_scanner_scan(void *payload, TSLexer *lexer,
                                            const bool *valid_symbols) {
  // This never happens in valid grammar. Only during error recovery, everything becomes valid.
  // See: https://github.com/tree-sitter/tree-sitter/issues/1259
  //
  // We should not consume any content as string fragment during error recovery, or we'll break
  // more valid grammar below.
  // The test 'attrset typing field following string' covers this.
  if (valid_symbols[STRING_FRAGMENT] && valid_symbols[INDENTED_STRING_FRAGMENT]) {
    return false;
  } else if (valid_symbols[STRING_FRAGMENT]) {
    return scan_string_fragment(lexer);
  } else if (valid_symbols[INDENTED_STRING_FRAGMENT]) {
    return scan_indented_string_fragment(lexer);
  } else if (valid_symbols[PATH_FRAGMENT] || valid_symbols[PATH_TRAILING_SLASH]) {
    return scan_path_fragment(lexer);
  }

  return false;
}

unsigned tree_sitter_nix_external_scanner_serialize(void *payload, char *buffer) {
  return 0;
}

void tree_sitter_nix_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) { }

void tree_sitter_nix_external_scanner_destroy(void *payload) { }
