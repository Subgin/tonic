window.tags = {
  selected: '',
  filter: filter,
  refresh: refresh
};

function filter(tag){
  tags.selected = tag;
  var elements = document.querySelectorAll('button');
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

function textFilter(text, attribute) {
  var regexp = new RegExp(text, "i");

  $("article").each(function(){
    var elem_text = $(this).data(attribute);

    if (elem_text.match(regexp) != null) {
      $(this).show();
    } else {
      $(this).hide();
    }
  });
}

function numericFilter(value, attribute) {
  $("article").each(function(){
    var attribute_value = $(this).data(attribute);

    if ((attribute_value == value) || value == "") {
      $(this).show();
    } else {
      $(this).hide();
    }
  });
}

function numericSliderFilter(value, attribute, direction) {
  $("article").each(function(){
    var attribute_value = $(this).data(attribute);

    if (attribute_value >= value && direction == "from") {
      $(this).show();
    } else if (attribute_value < value && direction == "to") {
      $(this).show();
    } else {
      $(this).hide();
    }
  });
}

function rangeSliderFilter(value, attribute, direction) {
  $("article").each(function(){
    var attribute_value = $(this).data(attribute);

    if (attribute_value >= value && direction == "min") {
      $(this).show();
    } else if (attribute_value < value && direction == "max") {
      $(this).show();
    } else {
      $(this).hide();
    }
  });
}

function booleanFilter(yes, attribute) {
  $("article").each(function(){
    var attribute_value = $(this).data(attribute);

    if (yes) {
      if (attribute_value)
        $(this).show();
      else
        $(this).hide();
    } else {
      if (attribute_value)
        $(this).hide();
      else
        $(this).show();
    }
  });
}