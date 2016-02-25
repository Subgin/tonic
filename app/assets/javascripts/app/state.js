window.state = {
  refresh: refresh,
  reset: reset,
  booleans: {},
  numerics: {},
  sliders: {},
  ranges: {},
  tagged: {},
  types: {},
  search: ''
};

var HIDDEN = 'hidden';

function refresh () {
  Object.keys(map).forEach(function(id){
    var el = document.getElementById(id);
    if (!el) return;
    hasFilters(id) ?
      removeClass(el,HIDDEN) :
      ( !hasClass(el,HIDDEN) && addClass(el,HIDDEN) );
  });
}

function hasFilters (id) {
  var item = map[id];
  return filter.has(item);
}

function reset () {
  collection.forEach(function(c){
    var id = c.name.toLowerCase().replace('/\s/g','-');
    c._strings = []; c._customs = [];
    Object.keys(c).forEach(function(a){
      if (a==='tags' || a==='image' || a==='_strings' || a==='_customs') return;
      typeof c[a]==='string' ?
        c._strings.push(a) :
        c._customs.push(a);
    });
    map[id] = c;
  });
}
