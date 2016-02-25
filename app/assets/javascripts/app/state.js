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

function init () {
  if (location.hash){
    // TODO check url
  } else {
    Object.keys(state).forEach(function(o){ if (typeof state[o]==='object') state[o]={}; });
    state.search = '';
  }
  refresh();
}

var HIDDEN = 'hidden';
function refresh () {
  Object.keys(map).forEach(function(id){
    var el = document.getElementById(id);
    if (!el) return;
    filter.has(map[id]) ?
      removeClass(el,HIDDEN) :
      ( !hasClass(el,HIDDEN) && addClass(el,HIDDEN) );
  });
}

var excluded = ['tags','image','_strings','_customs'];
function reset (clicked) {
  if (clicked) {
    location.hash = '';
    filter.reset();
  }
  collection.forEach(function(c){
    var id = c.name.toLowerCase().replace('/\s/g','-');
    c._strings = []; c._customs = [];
    Object.keys(c).forEach(function(a){
      if (excluded.indexOf(a)>-1) return;
      typeof c[a]==='string' ?
        c._strings.push(a) :
        c._customs.push(a);
    });
    map[id] = c;
    if (Object.keys(map).length===collection.length) init();
  });
}
