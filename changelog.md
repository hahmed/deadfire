## Changelog
### 0.7.0 (current)

### 0.6.0 (15 Jan 2025)
- Drop config.deadfire.* instead the Deadfire.configuration is preferred for configuring deadfire.

### 0.5.0 (12 Dec 2024)
- Drop ruby 2.7
- Add a railties to make it real simple to pre-process every file for a simple setup
- Added the asset registry to make it easier to control how or which file is used as a mixin
- Excluded files are no longer pro-processed
- Make rails + propshaft dependencies

### 0.4.0 (18 May 2024)
- Fix parsing comments that have 2 stars e.g. /**
- Adds a logger and a default setting that suppresses the logs which can be configured to report errors.
- Fixes issue with import's not parsing correctly when there is no ending semicolon.
- Added ci for ruby 3.3
- Add support for importing .scss files, making it easier to migrate from other libraries.
```
@import "nav"
@import "sidebar.scss"
.image { padding: 2px; }
```
Deadfire will look for the file nav.css, then nav.scss in the `config.root_path` in the case when a file extension is not included.

- Simplify the configuration by having one option called compressed instead of keep_newlines and keep_comments.
- Add the ability to exclude files from being pre-processed via the `config.deadfire.excluded_files` option.

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
