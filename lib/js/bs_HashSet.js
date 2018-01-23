'use strict';

var Bs_internalSetBuckets = require("./bs_internalSetBuckets.js");
var Bs_internalBucketsType = require("./bs_internalBucketsType.js");

function copyBucket(hash, h_buckets, ndata_tail, _, _old_bucket) {
  while(true) {
    var old_bucket = _old_bucket;
    if (old_bucket !== undefined) {
      var nidx = hash(old_bucket.key) & (h_buckets.length - 1 | 0);
      var match = ndata_tail[nidx];
      if (match !== undefined) {
        match.next = old_bucket;
      } else {
        h_buckets[nidx] = old_bucket;
      }
      ndata_tail[nidx] = old_bucket;
      _old_bucket = old_bucket.next;
      continue ;
      
    } else {
      return /* () */0;
    }
  };
}

function remove0(hash, eq, h, key) {
  var h_buckets = h.buckets;
  var i = hash(key) & (h_buckets.length - 1 | 0);
  var l = h_buckets[i];
  if (l !== undefined) {
    var next_cell = l.next;
    if (eq(l.key, key)) {
      h.size = h.size - 1 | 0;
      h_buckets[i] = next_cell;
      return /* () */0;
    } else if (next_cell !== undefined) {
      var eq$1 = eq;
      var h$1 = h;
      var key$1 = key;
      var _prec = l;
      var _cell = next_cell;
      while(true) {
        var cell = _cell;
        var prec = _prec;
        var cell_next = cell.next;
        if (eq$1(cell.key, key$1)) {
          prec.next = cell_next;
          h$1.size = h$1.size - 1 | 0;
          return /* () */0;
        } else if (cell_next !== undefined) {
          _cell = cell_next;
          _prec = cell;
          continue ;
          
        } else {
          return /* () */0;
        }
      };
    } else {
      return /* () */0;
    }
  } else {
    return /* () */0;
  }
}

function addBucket(eq, h, key, _cell) {
  while(true) {
    var cell = _cell;
    if (eq(cell.key, key)) {
      cell.key = key;
      return /* () */0;
    } else {
      var n = cell.next;
      if (n !== undefined) {
        _cell = n;
        continue ;
        
      } else {
        h.size = h.size + 1 | 0;
        cell.next = {
          key: key,
          next: n
        };
        return /* () */0;
      }
    }
  };
}

function addDone0(h, key, hash, eq) {
  var h_buckets = h.buckets;
  var i = hash(key) & (h_buckets.length - 1 | 0);
  var l = h_buckets[i];
  if (l !== undefined) {
    addBucket(eq, h, key, l);
  } else {
    h.size = h.size + 1 | 0;
    h_buckets[i] = {
      key: key,
      next: Bs_internalBucketsType.emptyOpt
    };
  }
  if (h.size > (h.buckets.length << 1)) {
    var hash$1 = hash;
    var h$1 = h;
    var odata = h$1.buckets;
    var osize = odata.length;
    var nsize = (osize << 1);
    if (nsize >= osize) {
      var h_buckets$1 = new Array(nsize);
      var ndata_tail = new Array(nsize);
      h$1.buckets = h_buckets$1;
      for(var i$1 = 0 ,i_finish = osize - 1 | 0; i$1 <= i_finish; ++i$1){
        copyBucket(hash$1, h_buckets$1, ndata_tail, h$1, odata[i$1]);
      }
      for(var i$2 = 0 ,i_finish$1 = nsize - 1 | 0; i$2 <= i_finish$1; ++i$2){
        var match = ndata_tail[i$2];
        if (match !== undefined) {
          match.next = Bs_internalBucketsType.emptyOpt;
        }
        
      }
      return /* () */0;
    } else {
      return 0;
    }
  } else {
    return 0;
  }
}

function add0(h, key, hash, eq) {
  addDone0(h, key, hash, eq);
  return h;
}

function has0(h, key, hash, eq) {
  var h_buckets = h.buckets;
  var nid = hash(key) & (h_buckets.length - 1 | 0);
  var bucket = h_buckets[nid];
  if (bucket !== undefined) {
    var eq$1 = eq;
    var key$1 = key;
    var _cell = bucket;
    while(true) {
      var cell = _cell;
      if (eq$1(cell.key, key$1)) {
        return /* true */1;
      } else {
        var match = cell.next;
        if (match !== undefined) {
          _cell = match;
          continue ;
          
        } else {
          return /* false */0;
        }
      }
    };
  } else {
    return /* false */0;
  }
}

function size0(prim) {
  return prim.size;
}

function toArray(h) {
  return Bs_internalSetBuckets.toArray0(h.data);
}

function create(dict, initialize_size) {
  return {
          dict: dict,
          data: Bs_internalBucketsType.create0(initialize_size)
        };
}

function clear(h) {
  return Bs_internalBucketsType.clear0(h.data);
}

function size(h) {
  return h.data.size;
}

function forEach(h, f) {
  return Bs_internalSetBuckets.forEach0(h.data, f);
}

function reduce(h, init, f) {
  return Bs_internalSetBuckets.reduce0(h.data, init, f);
}

function logStats(h) {
  return Bs_internalSetBuckets.logStats0(h.data);
}

function addDone(h, key) {
  var dict = h.dict;
  var data = h.data;
  return addDone0(data, key, dict[/* hash */0], dict[/* eq */1]);
}

function add(h, key) {
  addDone(h, key);
  return h;
}

function removeDone(h, key) {
  var M = h.dict;
  return remove0(M[/* hash */0], M[/* eq */1], h.data, key);
}

function remove(h, key) {
  removeDone(h, key);
  return h;
}

function has(h, key) {
  var M = h.dict;
  return has0(h.data, key, M[/* hash */0], M[/* eq */1]);
}

function ofArray0(hash, eq, arr) {
  var len = arr.length;
  var v = Bs_internalBucketsType.create0(len);
  for(var i = 0 ,i_finish = len - 1 | 0; i <= i_finish; ++i){
    addDone0(v, arr[i], hash, eq);
  }
  return v;
}

function addArray0(hash, eq, h, arr) {
  var len = arr.length;
  for(var i = 0 ,i_finish = len - 1 | 0; i <= i_finish; ++i){
    addDone0(h, arr[i], hash, eq);
  }
  return /* () */0;
}

function ofArray(arr, dict) {
  return {
          dict: dict,
          data: ofArray0(dict[/* hash */0], dict[/* eq */1], arr)
        };
}

function mergeArrayDone(h, arr) {
  var data = h.data;
  var M = h.dict;
  return addArray0(M[/* hash */0], M[/* eq */1], data, arr);
}

function mergeArray(h, arr) {
  mergeArrayDone(h, arr);
  return h;
}

function getData(prim) {
  return prim.data;
}

function getDict(prim) {
  return prim.dict;
}

function packDictData(prim, prim$1) {
  return {
          dict: prim,
          data: prim$1
        };
}

function getBucketHistogram(h) {
  return Bs_internalSetBuckets.getBucketHistogram(h.data);
}

var clear0 = Bs_internalBucketsType.clear0;

var create0 = Bs_internalBucketsType.create0;

var forEach0 = Bs_internalSetBuckets.forEach0;

var reduce0 = Bs_internalSetBuckets.reduce0;

var logStats0 = Bs_internalSetBuckets.logStats0;

var toArray0 = Bs_internalSetBuckets.toArray0;

exports.create = create;
exports.clear = clear;
exports.addDone = addDone;
exports.add = add;
exports.has = has;
exports.removeDone = removeDone;
exports.remove = remove;
exports.forEach = forEach;
exports.reduce = reduce;
exports.size = size;
exports.logStats = logStats;
exports.toArray = toArray;
exports.ofArray = ofArray;
exports.mergeArrayDone = mergeArrayDone;
exports.mergeArray = mergeArray;
exports.getBucketHistogram = getBucketHistogram;
exports.getData = getData;
exports.getDict = getDict;
exports.packDictData = packDictData;
exports.clear0 = clear0;
exports.create0 = create0;
exports.add0 = add0;
exports.addDone0 = addDone0;
exports.has0 = has0;
exports.remove0 = remove0;
exports.forEach0 = forEach0;
exports.reduce0 = reduce0;
exports.size0 = size0;
exports.logStats0 = logStats0;
exports.toArray0 = toArray0;
exports.ofArray0 = ofArray0;
exports.addArray0 = addArray0;
/* No side effect */
