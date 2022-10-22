# Tonic

> :cocktail: Self meta-described collections framework

Transform your collection into a beautiful website!

Tonic parses your collection, defined in a `YAML` file, and automatically generates a static website to explore your collection in a smart way, with a lot of filtering and sorting options.

*Built with: [Middleman](https://github.com/middleman/middleman), [Ralix](https://github.com/ralixjs/ralix), [Tailwind](https://tailwindcss.com)*

## Usage

**Requirements**

- Ruby
- Yarn

Clone/fork this repository (or use the GitHub *template* button), then `cd` into the folder and run:

```
> bin/setup
```

Start the development server by:

```
> bin/start
```

Or compile the site by:

```
> bin/build
```

Add your collection in `data/collection.yaml`. Example:

```yaml
- name: Item 1
  description: Ad aut libero. Adipisci asperiores repudiandae. Sunt expedita sunt.
  category: Marketing
  tags:
    - tag1
    - tag2
  likes: 200
  downloads: 400
- name: Item 2
  description: Incidunt cupiditate rerum. Enim quo pariatur. Commodi provident dolores.
  category: Accounting
  tags:
    - tag2
  likes: 60
  downloads: 100
```

### Magic attributes

- name (required! should be unique!)
- description
- category
- tags (array)
- images (array)

### Customization

Via `data/config.yaml`:

```yaml
# Main info
title: My Collection
description: This is an example of a Tonic collection.
links:
  - text: About Us
    url: '/about'

# Style
main_color: "#4338ca"
font_family: "Fira Sans"
logo: "/images/logo.png"

# Sorting
sorting:
  default_order: price_desc

# Filters
filters:
  type:
    category: "select"
  exclude:
    - summary
    - long_description
```

#### Sorting

- `default_order` By default: "name_asc".

More options:

- `exclude` Exclude attributes from sorting options.

#### Filters

Types:

- `text`
- `select`
- `numeric_range`
- `tags`
- `boolean`

More options:

- `exclude` Exclude attributes from filters.

## License

Copyright (c) Subgin. Tonic is released under the [MIT](LICENSE) License.
