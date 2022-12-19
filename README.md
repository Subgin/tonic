# Tonic

> 🍸 Self meta-described collections framework

Transform your collection into a beautiful website!

Tonic parses your collection, defined in a `YAML` or `JSON` file, and automatically generates a customizable static website to explore your collection in a smart way, with a lot of filtering and sorting options.

*Built with: [Middleman](https://middlemanapp.com), [Ralix](https://github.com/ralixjs/ralix), [Tailwind](https://tailwindcss.com)*

🌐 [**Live demo**](https://tonic-demo.netlify.app)

<p align="center">
  <img src="https://user-images.githubusercontent.com/576701/200078092-344ec8b1-ea09-4a89-9973-01cf53ec2eb7.png">
</p>

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
  price: 99.9
  downloads: 400
  published_at: "2021-06-10"
- name: Item 2
  description: Incidunt cupiditate rerum. Enim quo pariatur. Commodi provident dolores.
  category: Accounting
  tags:
    - tag2
  price: 149.9
  downloads: 100
  published_at: "2022-09-01"
```

The string attributes can contain HTML:

```yaml
description: |
  <p>This thing is fantastic!</p>
  <p>Check out <b>more information</b> in the <a href="/about">following section</a></p>
```

You can also use a `JSON` file (`data/collection.json`), as the following example:

```json
[
  {
    "name": "Item 1",
    "description": "Ad aut libero. Adipisci asperiores repudiandae. Sunt expedita sunt.",
    "tags": ["tag1", "tag2"],
    "price": 99.9
  },
  {
    "name": "Item 2",
    "description": "Incidunt cupiditate rerum. Enim quo pariatur. Commodi provident dolores.",
    "tags": ["tag2"],
    "price": 149.9
  }
]
```

#### Remote Collection

You can also fetch your collection from a remote resource. To do so, you should define the `remote_collection` setting in the [configuration file](#customization):

```yaml
remote_collection: https://example.com/collection.json
```

#### Nested attributes

Your items can have nested attributes too:

```yaml
- name: Leanne Graham
  email: leanne_graham@example.com
  address:
    street: Kulas Light
    city: Gwenborough
    zipcode: 92998-3874
    geo:
      lat: -37.3159
      lng: 81.1496
```

### Magic attributes

Some names help Tonic to automatically render your items (and its related filters) as beautiful as possible by default:

- name (required! should be unique!)
- description
- category
- tags (shoud be an array)
- images (shoud be an array)

### Customization

Configure your site via the `data/config.yaml` file. All options:

```yaml
# Main info
title: My Collection
description: |
  Welcome to my <u>awesome</u> collection!<br>
  More information in the <a href="#">following section</a>.
remote_collection: https://example.com/collection.json

# Style/UI
main_color: "#0891b2"
background_color: "#e0f2fe"
font_family: "Fira Sans"
logo: "/images/logo.png"
links:
  - text: About Us
    url: '/about'
  - text: Contact
    url: '/contact'
footer_content: Follow us on <a href="#">Twitter</a> and <a href="#">Instagram</a>
hide_filters: true
hide_sorting: true
item_card:
  image: false

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

#### Font family

You can use remote fonts from [Google Fonts](https://fonts.google.com) by adding the family name in the `font_family` option:

```yaml
font_family: "Fira Sans" # other examples: Lato, Roboto, Oswald, Montserrat, ...
```

#### Sorting

By default, the `name` attribute and all integer attributes are used to build the sorting options.

Available options:

- `default_order` By default: "name asc".
- `exclude` Exclude attributes from sorting options.

#### Filters

Tonic analyzes your collection (especially the *1st item*) to infer the best option given the attribute type and other parameters (like number of unique values). It can be overridden in case you want a different filter type for X reasons.

Available options:

- `type` Forces an attribute to render a specific filter type. Available types:
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

You can also add more pages to your Tonic site by just adding HTML templates (`*.html.erb`) under the `source/*` directory. After all, Tonic uses [Middleman](https://middlemanapp.com) under the hood, so you can also use Markdown and many other template engines.

## License

Copyright (c) Subgin. Tonic is released under the [MIT](LICENSE) License.
