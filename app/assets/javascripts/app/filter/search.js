
function textFilter (text) {
  state.search = text;
  state.refresh();
}

function hasSearch (item, text) {
  if (!text) return true;
  var regexp = new RegExp(text, "i");
  return item.name.match(regexp) || item.description.match(regexp) || hasAnySearch(item, regexp, Object.keys(item), 0);
}

function hasAnySearch (item, regexp, attrs, a) {
  if (!attrs[a]) return false;
  if (typeof item[attrs[a]] !== 'string') return hasAnySearch(item, regexp, ++a);
  return item[attrs[a]].match(regexp) || hasAnySearch(item, regexp, ++a);
}
