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
    filter.has(map[id]) ?
      removeClass(el,HIDDEN) :
      ( !hasClass(el,HIDDEN) && addClass(el,HIDDEN) );
  });
}

function reset () {
  collection.forEach(function(c){
    var id = c.name.toLowerCase().replace('/\s/g','-');
    c._strings = []; c._customs = [];
    Object.keys(c).forEach(function(a){
      if (['tags','image','_strings','_customs'].indexOf(a)>-1) return;
      typeof c[a]==='string' ?
        c._strings.push(a) :
        c._customs.push(a);
    });
    map[id] = c;
  });
}
