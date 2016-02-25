
function textFilter (text) {
  state.search = text;
  state.refresh();
}

function hasSearch (item) {
  if (!state.search) return true;
  var regexp = new RegExp(state.search, 'i');
  return item.name.match(regexp) || item.description.match(regexp) || hasAnySearch(item, regexp, item._strings, 0);
}

function hasAnySearch (item, regexp, attrs, a) {
  if (!attrs[a]) return false;
  //!_strings if (typeof item[attrs[a]] !== 'string') return hasAnySearch(item, regexp, ++a);
  return item[attrs[a]].match(regexp) || hasAnySearch(item, regexp, ++a);
}
