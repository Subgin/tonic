window.filter = {
  tag: tagFilter,
  text: textFilter,
  type: typeFilter,
  numeric: numericFilter,
  range: numericRangeFilter,
  boolean: booleanFilter,
  has: function (item) {
    return
      hasSearch(item) &&
      hasTags(item) &&
      hasCustom(item);
  }
};
