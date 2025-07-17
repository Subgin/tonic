# Tonic

> 🍸 Digital Collections Framework

Transform your collection into a beautiful and responsive website ✨

Tonic parses your collection, defined in a `YAML`, `JSON`, or `CSV` file, and automatically generates a customizable static website to explore your collection in a smart way, with a lot of filtering and sorting options.

*Built with: [Middleman](https://middlemanapp.com), [Ralix](https://github.com/ralixjs/ralix), [Tailwind](https://tailwindcss.com)*

🌐 [**Live demo**](https://tonic-demo.netlify.app)

<p align="center">
  <img src="https://github.com/user-attachments/assets/e1acccf2-e086-4eb8-88f1-b4b5c30bb509">
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
> bin/dev
```

Or compile the site (into the `build/` folder) by:

```
> bin/build
```

### Collection

Define your collection in the `data/collection.yaml` file (or `data/collection.json` or `data/collection.csv`). Example:

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

Or a `CSV` file (`data/collection.csv`), as the following example:

```csv
name,description,category,tags,price,downloads,published_at
Item 1,Ad aut libero. Adipisci asperiores repudiandae.,Transportation,"tag1,tag2",99.9,400,2021-06-10
Item 2,Incidunt cupiditate rerum. Enim quo pariatur.,Accounting,tag2,149.9,100,2022-09-01
```

**NOTE:** For CSV files, array fields like `tags` and `images` should be comma-separated within the cell (e.g., `"tag1,tag2"`). Numeric fields are automatically detected and converted to appropriate types.

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

More ✨ rules:

- Automatic 🎬 video embeds from urls (YouTube, Vimeo and more).
- Audio ⏯️ player for audio files.
- If the attribute name ends with `_at` (`published_at`, `updated_at`, ...), it's automatically parsed as 📅 date.
- The `detail_page_link` attribute makes the detail page to 🏃 jump to an external page, [see more](#detail-pages).

### Customization

Configure your site via the `data/config.yaml` file. All options:

```yaml
# Main settings
title: My Collection
description: |
  Welcome to my <u>awesome</u> collection!<br>
  More information in the <a href="#">following section</a>.
remote_collection: https://example.com/collection.json
detail_pages: true

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
footer_content: Follow us on <a href="#">X</a> and <a href="#">Instagram</a>
hide_filters: false
hide_sorting: false
hide_sharing: false
sharing_platforms:
  - facebook
  - x
  - whatsapp
  - email
item_card_image: true

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

#### Detail pages

If disabled, detail pages won't be generated. Remember you can link to an external page by defining the `detail_page_link` attribute in any of the items of your collection.

```yaml
- name: Awesome Product
  description: This product is fantastic!
  price: 99.9
  detail_page_link: https://my-shop.com/product/awesome-product
```

If you only want to customize how they look, you can do it by editing the HTML template, check the [Advanced customization](#advanced-customization) section.

#### Font family

You can use remote fonts from [Google Fonts](https://fonts.google.com) by adding the family name in the `font_family` option:

```yaml
font_family: "Fira Sans" # other examples: Lato, Roboto, Oswald, Montserrat, ...
```

#### Sharing

If you want to customize the available sharing options, you should use the `sharing_platforms` option passing an array.

By default, the supported platforms are: Facebook, X, Linkedin, Pinterest, Whatsapp, Telegram and Email.

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
  - `numeric_select_range`
  - `date_range`
  - `tags`
  - `boolean`
- `exclude` Exclude attributes from filters.

### Advanced customization

If you want to fully customize your Tonic instance, you can do it by editing the files under the `source/*` folder.

For example, if you want to customize the auto-generated HTML for your items, you can do it by editing these files:

- Item card partial: [`source/templates/collection/_item_card.html.erb`](source/templates/collection/_item_card.html.erb)
- Item detail page: [`source/templates/collection/detail_page.html.erb`](source/templates/collection/detail_page.html.erb)

**NOTE** In both templates you can use the `item` object to access any attribute: `item.name`, `item.description`, etc.

You can also add more pages to your Tonic site by just adding HTML templates (`*.html.erb`) under the `source/*` directory. After all, Tonic uses [Middleman](https://middlemanapp.com) under the hood, so you can even use Markdown and/or many other template engines.

## License

Copyright (c) Subgin. Tonic is released under the [MIT](LICENSE) License.
