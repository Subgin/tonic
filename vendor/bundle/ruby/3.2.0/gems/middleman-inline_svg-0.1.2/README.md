# Middleman Inline SVG

[![CircleCI](https://circleci.com/gh/thoughtbot/middleman-inline_svg.svg?style=svg)](https://circleci.com/gh/thoughtbot/middleman-inline_svg)

A [Middleman] extension that enables the inlining of SVG's. This gives us the
ability to style those SVG's using standard CSS.

## Installation

1. Add middleman-inline_svg to your `Gemfile`:

    ```ruby
    gem "middleman-inline_svg"
    ```

1. Install the gem:

    ```bash
    bundle install
    ```

1. Activate the extension in `config.rb`:

    ```ruby
    activate :inline_svg
    ```

## Usage

`middleman-inline_svg` provides an `inline_svg` helper that you can use in your
templates. Using it will inline your SVG markup directly into the HTML enabling
you to style it with CSS.

Given the following SVG file named `ruby.svg`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg width="32px" height="32px" viewBox="0 0 32 32" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <g id="ruby" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
    <!-- ... -->
  </g>
</svg>
```

And the following code in a Middleman template:

```erb
<a>
  <%= inline_svg "ruby.svg" %> Ruby
</a>
```

Middleman will output the following:

```html
<a>
  <svg width="32px" height="32px" viewBox="0 0 32 32" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="ruby" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
      <!-- ... -->
    </g>
  </svg>
  Ruby
</a>
```

It's possible to specify a title for the SVG. And any other options passed will
be rendered as attributes on the `<svg/>` element. Adding a title to your SVG
will improve accessibility.

```erb
<a>
  <%= inline_svg "ruby.svg",
      title: "Ruby logo",
      class: "ruby-logo",
      role: "img" %>
  Ruby
</a>
```

```html
<a>
  <svg width="32px" height="32px" viewBox="0 0 32 32" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class="ruby-logo" role="img">
    <title>Ruby logo</title>
    <g id="ruby" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
      <!-- ... -->
    </g>
  </svg>
  Ruby
</a>
```

Underscores are translated into hyphens in the output.

```erb
<a>
  <%= inline_svg "ruby.svg",
      title: "Ruby logo",
      class: "ruby-logo",
      aria_hidden: true %>
  Ruby
</a>
```

```html
<a>
  <svg width="32px" height="32px" viewBox="0 0 32 32" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true">
    <g id="ruby" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
      <!-- ... -->
    </g>
  </svg>
  Ruby
</a>
```

## Configuration

You can configure the default attributes/title in the Middleman `config.rb` file
when the extension is activated:

```ruby
activate :inline_svg do |config|
  config.defaults = {
    role: img
  }
end
```
