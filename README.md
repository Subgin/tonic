# Tonic

:cocktail: Self meta-described collections framework

> **:construction: In progress ...**

## Usage

```
bin/setup
bin/start
bin/build
```

## Customization

Via `data/config.yaml`.

### Magic attributes

- name (required! should be unique!)
- description
- category
- tags (array)
- images (array)

### Filters

Types:

- `text`
- `select`
- `numeric_range`
- `tags`
- `boolean`

More options:

- `exclude` Exclude attributes from filters

### Sorting

- `default_order`
