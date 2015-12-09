window.tags = {
  selected: '',
  filter: filter,
  refresh: refresh
};

function filter(tag){
  tags.selected = tag;
  var elements = document.querySelectorAll('nav button');
  for (var el in elements){
    el = elements[el];
    hasClass(el,tag) ? addClass(el,'active') : removeClass(el,'active');
  }
  refresh();
}

function refresh(){
  var elements = document.querySelectorAll('article');

  for (var el in elements){
    hasClass(elements[el],tags.selected) ? removeClass(elements[el],'hidden') : addClass(elements[el],'hidden');
  }
}