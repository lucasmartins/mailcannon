function(key, values) {

  function returnUnique(array) { // fastest shit on earth
    if(!array) return [];
    var o = {}, i, l = array.length, r = [];
    for(i=0; i<l;i+=1) o[array[i]] = array[i];
    for(i in o) r.push(o[i]);
    return r;
  };

  for(event in values){
    values[event] = returnUnique(values[event]).length
  }

  return values;
}
