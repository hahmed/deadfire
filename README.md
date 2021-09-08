# Deadfire

A miminal CSS preprocessor.

Use plain ol' boring CSS with a little bit of @import, @apply and nestings.

CSS is a staple technology when building web applications. With the introduction of LESS, SASS, SCSS it made CSS easier to maintain. However, most of these tools are no longer supported, maintained or have far too many features.

With the rise of the utility first approach. There is not a great amount of custom CSS to write.

Deadfire sprinkles a few extra features which helps you write CSS, easier!

Deadfire can be used with or without a CSS frameworks.

## Features

- [x] @import
- [x] [@apply](https://tabatkins.github.io/specs/css-apply-rule/)
- [ ] [nesting](https://drafts.csswg.org/css-nesting-1)

## Examples

### @import

Imports allow you to easily include a file from the file system in your current css document. All @import statements must be at the top of the document (but after a @charset).

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

The output is;

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

@apply inlines your classes into your custom css.

The CSS apply rule was [proposed to be included into CSS](https://tabatkins.github.io/specs/css-apply-rule/) however it was abandoned. Let's see an example of how to declare your mixins and use the @apply directive.

NOTE: All mixins must be declared on the `:root` element or preloaded via the `Deadfire.mixins` method. Root should be declared after the import statements and any comments.

```CSS
:root {
  --font-bold: {
    font-weight: bold;
  }

  --text-company-blue: color: blue;

  --btn: {
    padding-bottom: 10px;
    text-align: center;
  }
}
```

How can we use the mixins? Using @apply...

```CSS
.btn-blue {
  @apply btn font-bold text-company-blue;
}

.homepage-hero {
  @apply font-bold text-company-blue;
}
```

### nesting

Nesting adds the ability to nest one style rule inside another.

NOTE: This feature is still a work in progress.

```CSS
/* & can be used on its own */
.btn {
  color: blue;
  & > .homepage { color: red; }
}
```

This is expanded to:

```CSS
.btn { color: blue; }
.btn > .homepage { color: red; }
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'deadfire'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install deadfire

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hahmed/deadfire. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/hahmed/deadfire/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Autoprefixer::Rb project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hahmed/deadfire/blob/master/CODE_OF_CONDUCT.md).
