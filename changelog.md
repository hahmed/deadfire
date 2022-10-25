## Changelog
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