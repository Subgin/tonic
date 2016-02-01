function hasClass(el,className){
  if (!el || !className) return;
  if (el.classList)
    return el.classList.contains(className);
  else
    return new RegExp('(^| )' + className + '( |$)', 'gi').test(el.className);
}

function removeClass(el,className){
  if (!el || !className) return;
  if (el.classList)
    el.classList.remove(className);
  else if (el.className)
    el.className = el.className.replace(new RegExp('(^|\\b)' + className.split(' ').join('|') + '(\\b|$)', 'gi'), ' ');
}

function addClass(el,className){
  if (!el || !className) return;
  if (el.classList)
    el.classList.add(className);
  else
    el.className += ' ' + className;
}