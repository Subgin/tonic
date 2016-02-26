function textFilter (text) {
  state.search = text;
  state.refresh();
}

function hasSearch (item) {
  if (!state.search) return true;
  var regexp = new RegExp(state.search, 'i');
  return item.name.match(regexp) || item.description.match(regexp) || hasAnySearch(item, regexp, state._strings, 0);
}

function hasAnySearch (item, regexp, attrs, a) {
  if (!attrs[a] || !item[attrs[a]]) return false;
  return item[attrs[a]].match(regexp) || hasAnySearch(item, regexp, ++a);
}

function useSearch (text) {
  state.search = text;
  document.getElementsByTagName('input')[0].value = text;
}

function resetSearch () {
  state.search = '';
  document.getElementsByTagName('input')[0].value = '';
}
