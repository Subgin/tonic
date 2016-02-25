
var ACTIVE = 'active',
    TAG = 'tag_';

function tagFilter (tag) {
  if (isAllTag(tag)) return state.refresh();
  removeClass(document.getElementById(TAG+'all'), ACTIVE);
  if (state.tagged[tag]) {
    removeClass(document.getElementById(TAG+tag), ACTIVE);
    delete state.tagged[tag];
  } else {
    addClass(document.getElementById(TAG+tag), ACTIVE);
    state.tagged[tag] = true;
  }
  state.refresh();
}

function isAllTag (tag) {
  if (tag === 'all'){
    state.tagged = {};
    var el = document.getElementById(TAG+'all');
    if (!hasClass(el,ACTIVE)) addClass(el,ACTIVE);
    removeTags();
    state.reset();
    return true;
  }
  return false;
}

function removeTags () {
  var tags = document.getElementsByClassName('tag');
  for (var t in tags){
    removeClass(tags[t], ACTIVE);
  }
}

function hasTags (item, tags) {
  return !tags.length || !(item.tags && item.tags.length) || hasAllTags(item, tags, 0);
}

function hasAllTags (item, tags, i){
  if (!tags[i]) return true;
  return item.tags.indexOf(tags[i])>-1 && hasAllTags(item, tags, ++i);
}
