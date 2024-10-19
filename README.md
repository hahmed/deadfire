# Deadfire

A lightweight CSS preprocessor.

Use plain ol' CSS with a little bit of @import and @apply.

CSS is a staple technology when building web applications. With the introduction of LESS, SASS, SCSS it made CSS easier to maintain. However, most of these tools are no longer supported, maintained or have far too many features (wait... that's a bad thing?).

Deadfire sprinkles a few extra features which helps you write CSS, easier.

Deadfire can be used with or without a CSS framework.

## Features

- [x] @import
- [x] [@apply](https://tabatkins.github.io/specs/css-apply-rule/)

### @import

Imports allow you to easily include a file from the file system into your current css document.

```CSS
/* shared/buttons.css */
.button {
  color: red;
  text-align: center;
}

/* application.css */
@import "shared/buttons.css";

.page-title {
  font-size: 20px;
}
```

Output;

```CSS
/* application.css */
.button {
  color: red;
  text-align: center;
}

.page-title {
  font-size: 20px;
}
```

### @apply

The `@apply` directive inlines your classes into your custom CSS, simplifying the process of applying existing styles to a new class.

The CSS apply rule was [proposed to be included into CSS](https://tabatkins.github.io/specs/css-apply-rule/) however it was abandoned. Mixins simplify applying existing css to a new class.

Let's take a look at an example of how to use the @apply directive. Note that all utility classes are automatically cached.

```CSS
.font-bold: {
  font-weight: bold;
}

.btn: {
  padding-bottom: 10px;
  text-align: center;
}
```

Re-use the styles using @apply:

```CSS
.btn-blue {
  @apply .btn .font-bold;
}

.homepage-hero {
  @apply .font-bold;
}
```

### Fault tolerant

When Deadfire encounters an error, such as a missing mixin or other issues, it does not immediately raise an error that would halt the execution. Instead, it continues processing the CSS code and collects the encountered errors. These errors are then reported through the ErrorReporter class, allowing you to handle or display them as needed.

By adopting this fault-tolerant approach, Deadfire aims to provide more flexibility and resilience when dealing with CSS code that may contain errors or inconsistencies. It allows you to gather information about the encountered issues and take appropriate actions based on the reported errors.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'deadfire'
```

And then execute:

  `> bundle install`

Or install it yourself as:

  `> gem install deadfire`

## Deadfire + Ruby on Rails

Propshaft is the new asset pipeline for Rails, to use Deadfire as a preprocessor add the deadfire gem to your Gemfile.

```ruby
gem "deadfire"
```

That's all, your css file should now be run through Deadfire.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To run the tests, run `bin/test`.
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hahmed/deadfire. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/hahmed/deadfire/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Deadfire project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hahmed/deadfire/blob/master/CODE_OF_CONDUCT.md).
