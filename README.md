# Tonic

:cocktail: Self meta-described collections framework

> **:construction: In progress ...**

## Usage

```
bin/setup
bin/start
bin/build
```

Add your collection in `data/collection.yaml`

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

# Sorting
sorting:
  default_order: price_desc

# Filters
filters:
  type:
    category: "select"
```

#### Sorting

- `default_order`

#### Filters

Types:

- `text`
- `select`
- `numeric_range`
- `tags`
- `boolean`

More options:

- `exclude` Exclude attributes from filters
