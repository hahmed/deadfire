# Deadfire

A miminal CSS preprocessor.

Use plain ol' boring CSS with a little bit of @import, @apply and nestings.

CSS is a staple technology when building web applications. With the introduction of LESS, SASS, SCSS it made CSS easier to maintain. However, most of these tools are no longer supported, maintained or have far too many features (wait... that's a bad thing?).

With the rise of the utility first approach. There is not a great amount of custom CSS to write.

Deadfire sprinkles a few extra features which helps you write CSS, easier!

Deadfire can be used with or without a CSS framework.

## Features

- [x] @import
- [x] [@apply](https://tabatkins.github.io/specs/css-apply-rule/)
- [ ] [nesting](https://drafts.csswg.org/css-nesting-1)

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

@apply inlines your classes into your custom css.

The CSS apply rule was [proposed to be included into CSS](https://tabatkins.github.io/specs/css-apply-rule/) however it was abandoned. Mixins simplify applying existing css to a new class.

All mixins must be declared on the `:root` element or preloaded via the `Deadfire.mixins` method. Using a mixin before it's declared will raise an `EarlyApplyException`. Ideally the `:root` element should appear near the top of the document.

Let's see an example of how to declare mixins and use the @apply directive.

```CSS
:root {
  --font-bold: {
    font-weight: bold;
  }

  --btn: {
    padding-bottom: 10px;
    text-align: center;
  }
}
```

How can we use mixins? Using @apply...

```CSS
.btn-blue {
  @apply --btn --font-bold;
}

.homepage-hero {
  @apply --font-bold;
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

## Deadfire + Ruby on Rails

After adding Deadfire gem to your rails application, open the file `config/initializers/assets.rb` to setup your Sprocket and the asset pipeline to use the new preprocessor.

```ruby
# config/initializers/assets.rb
class DeadfireProcessor
  def call(input)
    return { data: Deadfire.parse(input[:data]) }
  end
end

Deadfire.configuration.root_path = Rails.root.join('app', 'assets', 'stylesheets')
Sprockets.register_preprocessor('text/css', DeadfireProcessor.new)
```

Your css file should now be run through Deadfire.

NOTE: The deadfire-rails gem has not been developed, mostly because it will include some simple to use conventions when writing css for your rails application and that needs a little more thought.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hahmed/deadfire. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/hahmed/deadfire/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Deadfire project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hahmed/deadfire/blob/master/CODE_OF_CONDUCT.md).
