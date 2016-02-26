
var tags = document.getElementsByClassName('tag'),
    tagAll = document.getElementById('tag_all'),
    ACTIVE = 'active',
    TAG = 'tag_';

function hasTags (item) {
  var tags = Object.keys(state.tagged);
  return !tags.length || !(item.tags && item.tags.length) || hasAllTags(item, tags, 0);
}

function hasAllTags (item, tags, i){
  if (!tags[i]) return true;
  return item.tags.indexOf(tags[i])>-1 && hasAllTags(item, tags, ++i);
}

function tagFilter (tag) {
  if (treatAllTag(tag)) return;
  removeClass(tagAll,ACTIVE);
  if (state.tagged[tag]) {
    removeClass(document.getElementById(TAG+tag),ACTIVE);
    delete state.tagged[tag];
  } else {
    addClass(document.getElementById(TAG+tag),ACTIVE);
    state.tagged[tag] = true;
  }
  if (!Object.keys(state.tagged).length && !hasClass(tagAll,ACTIVE)) addClass(tagAll,ACTIVE);
  state.refresh();
}

function treatAllTag (tag) {
  if (tag === 'all'){
    resetTags();
    state.reset();
    return true;
  }
  return false;
}

function useTags (tagged) {
  if (!tagged) return;
  tagged = tagged.split(',');
  resetTags();
  if (!tagged.length) return;
  removeClass(tagAll,ACTIVE);
  tagged.forEach(function (tag) {
    state.tagged[tag] = true;
    tag = document.getElementById(TAG+tag);
    if (tag) addClass(tag,ACTIVE);
  });
}

function resetTags () {
  state.tagged = {};
  var elems = document.getElementsByClassName(ACTIVE);
  for (var e in elems) removeClass(elems[e],ACTIVE);
  if (!hasClass(tagAll,ACTIVE)) addClass(tagAll,ACTIVE);
}
