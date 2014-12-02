function (key, values) {
  var result = {};

  values.forEach(function(value) {
    for(event in value) {
      if(!result[event])
        result[event] = [];

      result[event] = result[event].concat(value[event]);
    }
  });
  return result;
}
