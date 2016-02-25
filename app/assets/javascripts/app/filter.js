window.filter = {
  tag: tagFilter,
  text: textFilter,
  numeric: numericFilter,
  slider: numericSliderFilter,
  range: rangeSliderFilter,
  boolean: booleanFilter,
  has: {
    tags: hasTags,
    search: hasSearch,
    custom: hasCustom
  }
};

function numericFilter(value, attribute) {
  state.numeric[attribute] = value;
  state.refresh();

  // TODO REMOVE
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

function hasCustom () {
  // TODO custom attributes filtering
  return true;
}
