window.state = {
  init: init,
  reset: reset,
  refresh: refresh,
  _strings: [],
  _customs: [],
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
  setTimeout(router.changed);
}

var excluded = ['tags','image'];
function init () {
  Object.keys(collection[0]).forEach(function(a){
    if (excluded.indexOf(a) > -1) return;
    typeof collection[0][a] === 'string' && !document.getElementsByName(a) ?
      state._strings.push(a) :
      state._customs.push(a) && router.filters.push(a);
  });
  collection.forEach(function(c){
    map[c.name.toLowerCase().replace('/\s/g','-')] = c;
  });
  setTimeout(router.use);
}

function reset () {
  location.hash = '';
  filter.reset();
  state.refresh();
}
