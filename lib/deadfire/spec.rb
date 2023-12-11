module Deadfire
  class Spec # :nodoc:
    # EBNF
    # stylesheet         = [ CDO | CDC | S | statement ]*;
    # statement          = ruleset | at-rule;
    # at-rule            = ATKEYWORD S* any-value* [ block | ';' S* ];
    # block              = '{' S* [ S* (declaration | at-rule) ]* '}' S*;
    # ruleset            = selector [ ',' S* selector ]* S* '{' S* declaration [ ';' S* declaration ]* '}' S*;
    # selector           = simple-selector [ combinator selector | S+ [ combinator? selector ]? ];
    # simple-selector    = element-name? [ '#' id-selector ]? [ '.' class-selector ]* [ '[' attrib-selector ']' ]*;
    # id-selector        = NAME;
    # class-selector     = '.' NAME;
    # attrib-selector    = NAME [ [ '=' | INCLUDES | DASHMATCH ] any-value ]?;
    # combinator         = '+' | '>' | '~' | S+;
    # declaration        = property ':' S* value;
    # property           = NAME;
    # value              = any-value [ ',' S* any-value ]*;
    # any-value          = IDENT | STRING | NUMBER | PERCENTAGE | DIMENSION | COLOR | URI | FUNCTION any-value* ')' | '(' any-value* ')' | '[' any-value* ']' | '{' any-value* '}' | ';';

    CHARSET = "@charset"
    IMPORT = "@import"
    MEDIA = "@media"
    PAGE = "@page"
    FONT_FACE = "@font-face"
    KEYFRAMES = "@keyframes"
    SUPPORTS = "@supports"
    NAMESPACE = "@namespace"
    COUNTER_STYLE = "@counter-style"
    VIEWPORT = "@viewport"
    DOCUMENT = "@document"
    APPLY = "@apply"
    LAYER = "@layer"

    CSS_AT_RULES = [
      CHARSET,
      IMPORT,
      MEDIA,
      PAGE,
      FONT_FACE,
      KEYFRAMES,
      SUPPORTS,
      NAMESPACE,
      COUNTER_STYLE,
      VIEWPORT,
      DOCUMENT,
      APPLY,
      LAYER
    ]

    CSS_SELECTORS = [
      ":root",
      "::before",
      "::after",
      ":hover",
      ":active",
      ":focus",
      ":first-child",
      ":last-child",
      ":nth-child(n)",
      ":nth-last-child(n)",
      ":only-child",
      ":only-of-type",
      ":first-of-type",
      ":last-of-type",
      ":nth-of-type(n)",
      ":nth-last-of-type(n)",
      ":checked",
      ":disabled",
      ":enabled",
      ":empty",
      "::first-line",
      "::first-letter",
      "::selection",
      "~",
      "+",
      ">",
      " ",
      ".class",
      "#id",
      "[attribute]",
      "[attribute=value]",
      "[attribute~=value]",
      "[attribute|=value]",
      "[attribute^=value]",
      "[attribute$=value]",
      "[attribute*=value]",
      ":not(selector)",
      ":matches(selector)",
      ":any(selector)",
      ":has(selector)",
      "::placeholder"
    ]

    CSS_POTENTIAL_VALUES_TYPES = [
      :length_and_size, # e.g. 5px or 5em
      :color, # e.g. hex codes, RGB and RGBA values, HSL and HSLA values, and named colors - #fff
      :textual, # strings, keywords, and URLs - bold, url, etc.
      :enumerated, # e.g. inline, block, list-item, etc.
      :functional, # e.g.  calc(), attr(), and var() - calc(100% - 10px)
      :other # everything else like inherit, initial, unset
    ]

    COMMON_CSS_PROPERTIES = [
      "color",
      "background-color",
      "background-image",
      "border",
      "border-radius",
      "box-shadow",
      "font-family",
      "font-size",
      "font-weight",
      "letter-spacing",
      "line-height",
      "margin",
      "padding",
      "text-align",
      "text-decoration",
      "text-transform",
      "width",
      "height",
      "display",
      "flex",
      "flex-direction",
      "justify-content",
      "align-items",
      "position",
      "top",
      "right",
      "bottom",
      "left",
      "z-index"
    ]
  end
end
