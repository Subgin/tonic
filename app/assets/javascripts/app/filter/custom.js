
function hasCustom (item) {
  return hasAttribute(item, 'booleans', Object.keys(state.booleans), 0) &&
    hasEquals(item, 'numerics', Object.keys(state.numerics), 0) &&
    hasEquals(item, 'types', Object.keys(state.types), 0) &&
    hasRanges(item, 'sliders', Object.keys(state.sliders), 0) &&
    hasRanges(item, 'ranges', Object.keys(state.ranges), 0);
}

function hasAttribute (item, type, attrs, i){
  if (!attrs[i]) return true;
  return !!item[attrs[i]]=== state[type][attrs[i]] && hasAttribute(item, type, attrs, ++i);
}

function hasEquals (item, type, attrs, i) {
  if (!attrs[i] || state[type][attrs[i]]==='all') return true;
  return item[attrs[i]] === state[type][attrs[i]] && hasEquals(item, type, attrs, ++i);
}

function hasRanges (item, type, attrs, i) {
  if (!attrs[i]) return true;
  return item[attrs[i]] >= state[type][attrs].a &&
    item[attrs[i]] < state[type][attrs].b &&
    hasRanges(item, attrs, ++i);
}

function booleanFilter (value, attribute) {
  state.booleans[attribute] = Boolean(value);
  state.refresh();
}

function numericFilter (value, attribute) {
  state.numerics[attribute] = Number(value);
  state.refresh();
}

function typeFilter (value, attribute) {
  state.types[attribute] = value;
  state.refresh();
}

function numericRangeFilter (value, attribute, direction) {
  if (!state.sliders[attribute]) state.sliders[attribute] = {};
  state.sliders[attribute][direction] = Number(value);
  state.refresh();
}
