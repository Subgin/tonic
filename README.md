# Tonic

> 🍸 Self meta-described collections framework

Transform your collection into a beautiful website!

Tonic parses your collection, defined in a `YAML` file, and automatically generates a customizable static website to explore your collection in a smart way, with a lot of filtering and sorting options.

*Built with: [Middleman](https://middlemanapp.com), [Ralix](https://github.com/ralixjs/ralix), [Tailwind](https://tailwindcss.com)*

🌐 [**Live demo**](https://tonic-demo.netlify.app)

## Install

**Requirements**

- Ruby
- Yarn

Clone/fork this repository (or use the GitHub *template* button), then `cd` into the folder and run:

```
> bin/setup
```

## Usage

Start the development server by:

```
> bin/start
```

Or compile the site (into the `build/` folder) by:

```
> bin/build
```

### Collection

Define your collection in the `data/collection.yaml` file. Example:

```yaml
- name: Item 1
  description: Ad aut libero. Adipisci asperiores repudiandae. Sunt expedita sunt.
  category: Marketing
  tags:
    - tag1
    - tag2
  likes: 200
  downloads: 400
  published_at: "2021-06-10"
- name: Item 2
  description: Incidunt cupiditate rerum. Enim quo pariatur. Commodi provident dolores.
  category: Accounting
  tags:
    - tag2
  likes: 60
  downloads: 100
  published_at: "2022-10-10"
```

The string attributes can contain HTML:

```yaml
description: |
  <p>This thing is fantastic!</p>
  <p>Check out <b>more information</b> in the <a href="/about">following section</a></p>
```

### Magic attributes

Some names help Tonic to automatically render your items (and its related filters) as beautiful as possible by default:

- name (required! should be unique!)
- description (required!)
- category
- tags (shoud be an array)
- images (shoud be an array)

### Customization

Via `data/config.yaml`:

```yaml
# Main info
title: My Collection
description: This is an example of a Tonic collection.

# Style/UI
main_color: "#4338ca"
font_family: "Fira Sans"
logo: "/images/logo.png"
links:
  - text: About Us
    url: '/about'
  - text: Contact
    url: '/contact'
hide_filters: true
hide_sorting: true

# Sorting
sorting:
  default_order: "price desc"
  exclude:
    - clicks

# Filters
filters:
  type:
    category: text
    status: radio_buttons
  exclude:
    - summary
    - long_description
```

#### Sorting

By default, the `name` attribute and all integer attributes are used to build the sorting options.

Options:

- `default_order` By default: "name asc".
- `exclude` Exclude attributes from sorting options.

#### Filters

Options:

- `type` Force an attribute to render a specific filter type. Available types:
  - `text`
  - `select`
  - `radio_buttons`
  - `numeric_range`
  - `date_range`
  - `tags`
  - `boolean`
- `exclude` Exclude attributes from filters.

### Advanced customization

If you want to fully customize your Tonic instance, you can do it by editing the files under the `source/*` folder.

For example, if you want to customize the auto-generated HTML for your items, you can do it by editing these files:

- Item card partial: [`source/templates/collection/_item_card.html.erb`](source/templates/collection/_item_card.html.erb)
- Item detail page: [`source/templates/collection/item_page.html.erb`](source/templates/collection/item_page.html.erb)

You can also add more pages to your Tonic site by just adding HTML templates (`*.html.erb`) under the `source/*` directory. After all, Tonic uses [Middleman](https://middlemanapp.com) under the hood.

## License

Copyright (c) Subgin. Tonic is released under the [MIT](LICENSE) License.
