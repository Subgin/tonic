
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
  router.applied[attribute] = String(value);
  state.booleans[attribute] = Boolean(value);
  state.refresh();
}

function numericFilter (value, attribute) {
  router.applied[attribute] = String(value);
  state.numerics[attribute] = Number(value);
  state.refresh();
}

function typeFilter (value, attribute) {
  router.applied[attribute] = String(value);
  state.types[attribute] = value;
  state.refresh();
}

var MIN = 'min', AND = ',';
function numericRangeFilter (value, attribute, direction) {
  if (direction === MIN) {
    if (router.applied[attribute] && router.applied[attribute].indexOf(AND) > -1) {
      router.applied[attribute] = value + AND + router.applied[attribute].split(AND)[1];
    } else {
      router.applied[attribute] = value;
    }
  } else {
    if (router.applied[attribute] && router.applied[attribute].indexOf(AND) === -1) {
      router.applied[attribute] = router.applied[attribute].split(AND)[0] + AND + value;
    } else {
      router.applied[attribute] = AND + value;
    }
  }
  if (!state.sliders[attribute]) state.sliders[attribute] = {};
  state.sliders[attribute][direction] = Number(value);
  state.refresh();
}

function useCustom (name, value){
  if (document.filters[name]) {
    switch (document.filters[name].type) {
      case 'select-one':
        if (selectorHas(name,value)) {
          state.types[name] = value;
          document.filters[name].value = value;
        }
        break;
      case 'number':
        if (numericHas(name,value)) {
          state.numerics[name] = value;
          document.filters[name].value = value;
        }
        break;
      default:
    }
  }
}

function numericHas (name, value) {
  value = Number(value);
  var range = document.filters[name];
  if (!range.length || range.length < 2) {
    if (range.max) {
      return value < Number(range.max) && value > Number(range.min);
    } else return value > Number(range.min);
  }
}

function selectorHas (name, value) {
  var options = document.filters[name].options;
  for (var o in options) if (options[o].value === value) return true;
  return false;
}

function resetCustom () {
  Object.keys(state.booleans).forEach(resetCustomFilter);
  Object.keys(state.numerics).forEach(resetCustomFilter);
  Object.keys(state.sliders).forEach(resetCustomFilter);
  Object.keys(state.ranges).forEach(resetCustomFilter);
  Object.keys(state.types).forEach(resetCustomFilter);
}

function resetCustomFilter (custom) {
  document.filters[custom].value = null;
  delete router.applied[custom];
}
