'use strict';


var emptyOpt = undefined;

function power_2_above(_x, n) {
  while(true) {
    var x = _x;
    if (x >= n) {
      return x;
    } else if ((x << 1) < x) {
      return x;
    } else {
      _x = (x << 1);
      continue ;
      
    }
  };
}

function create0(initialSize) {
  var s = power_2_above(16, initialSize);
  return {
          size: 0,
          buckets: new Array(s)
        };
}

function clear0(h) {
  h.size = 0;
  var h_buckets = h.buckets;
  var len = h_buckets.length;
  for(var i = 0 ,i_finish = len - 1 | 0; i <= i_finish; ++i){
    h_buckets[i] = emptyOpt;
  }
  return /* () */0;
}

exports.emptyOpt = emptyOpt;
exports.create0 = create0;
exports.clear0 = clear0;
/* No side effect */
