
function numericFilter(value, attribute) {
  state.numeric[attribute] = value;
  state.refresh();
}

function hasNumeric (item, attribute, value) {
  return !value || item[attribute] === value;
}
