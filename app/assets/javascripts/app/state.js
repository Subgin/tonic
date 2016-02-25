window.state = {
  refresh: refresh,
  reset: reset,
  boolean: {},
  numeric: {},
  slider: {},
  range: {},
  tagged: {},
  search: ''
};

var HIDDEN = 'hidden';

function refresh () {
  Object.keys(map).forEach(function(id){
    var el = document.getElementById(id);
    if (!el) return;
    hasFilters(id) ?
      removeClass(el,HIDDEN) :
      (!hasClass(el,HIDDEN) && addClass(el,HIDDEN));
  });
}

function reset () {
  collection.forEach(function(c){
    var id = c.name.toLowerCase().replace('/\s/g','-');
    map[id] = c;
  });
}

function hasFilters (id) {
  var item = map[id];
  return filter.has.tags(item, Object.keys(state.tagged)) && filter.has.search(item, state.search) && filter.has.custom(item, state.custom);
}
