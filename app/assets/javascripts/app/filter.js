window.filter = {
  reset: resetFilters,
  use: useFilters,
  tag: tagFilter,
  text: textFilter,
  type: typeFilter,
  numeric: numericFilter,
  range: numericRangeFilter,
  boolean: booleanFilter,
  has: function (item) {
    return hasSearch(item) && hasTags(item) && hasCustom(item);
  }
};

function resetFilters () {
  resetSearch();
  resetTags();
  resetCustom();
  location.hash = '';
}

function useFilters (key, value) {
  if (!key || !value) return;
  switch (key) {
    case 'search':
      useSearch(value);
      break;
    case 'tags':
      useTags(value);
      break;
    default:
      useCustom(key, value);
  }
}
