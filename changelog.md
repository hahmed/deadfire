## Changelog
### 0.4.0 (current)

- Add support for importing .scss files, making it easier to migrate from other libraries.
```
@import "nav"
@import "sidebar.scss"
.image { padding: 2px; }
```
Deadfire will look for the file nav.css, then nav.scss in the `config.root_path` in the case when a file extension is not included.

- Simplify the configuration by having one option called compressed instead of keep_newlines and keep_comments.

### 0.3.0 (15 November 2023)

- Redo the parser by splitting up the tokenizer, parser, interpreter and generator phases which makes each step simpler. It's still faster than sassc but much slower than it was previously which is something I hope to address soon.
- Key thing to note is that Deadfire now only handles @imports and mixins. Nesting is now a feature of CSS, which means Deadfire is much simpler as a result.
- In the next version I will drop the old parser and it's tests.
- Add support for Ruby 3.2
- Updated docs and added an example on how to get Deadfire working with Propshaft.

### 0.2.0 (25 October 2022)

- Added build for ruby 3.0
- StringIO is now hidden and only visible on the buffer class.
- Fixed a bug with a css ruleset after a nested block was being ignored, example;
```
.title {
  color: blue;
  & .text { padding: 3px; }
}
.image { padding: 2px; }
```

### 0.1.0 (17 October 2022)

Initial release
