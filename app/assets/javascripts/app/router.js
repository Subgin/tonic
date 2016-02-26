window.router = {
  use: useRouter,
  changed: changedRouter,
  filters: ['search','tags'],
  applied: {}
};

function useRouter () {
  var url = String(location.hash);
  if (url.length>1) {
    router.applied = {};
    router.filters.forEach(function (f) {
      if (!appliedRouter(url.slice(1), router.filters, 0)) state.reset();
    });
  } else state.reset();
  state.refresh();
}

function appliedRouter (url, filters, i) {
  if (!filters[i]) return !!Object.keys(router.applied).length;
  var param = url.indexOf(filters[i]);
  if (param > -1){
    param = url.substring(1 + param + filters[i].length).split('/')[0];
    if (param) {
      router.applied[filters[i]] = param;
      filter.use(filters[i], param);
    }
  }
  return appliedRouter(url, filters, ++i);
}

var SEARCH = '/search/', TAGS = '/tags/', s = '/';
function changedRouter () {
  var url = '', tags = Object.keys(state.tagged);
  if (state.search) url = SEARCH + state.search;
  if (tags.length) url += TAGS + tags.join(',');
  state._customs.forEach(function (c) {
    if (router.applied[c]) url += s + c + s + router.applied[c];
  });
  if (url) location.hash = url;
}
