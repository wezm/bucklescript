'use strict';

var Bs_Sort = require("./bs_Sort.js");

function height(n) {
  if (n !== null) {
    return n.h;
  } else {
    return 0;
  }
}

function copy(n) {
  if (n !== null) {
    var l = n.left;
    var r = n.right;
    return {
            left: copy(l),
            key: n.key,
            right: copy(r),
            h: n.h
          };
  } else {
    return n;
  }
}

function create(l, v, r) {
  var hl = l !== null ? l.h : 0;
  var hr = r !== null ? r.h : 0;
  return {
          left: l,
          key: v,
          right: r,
          h: hl >= hr ? hl + 1 | 0 : hr + 1 | 0
        };
}

function singleton0(x) {
  return {
          left: null,
          key: x,
          right: null,
          h: 1
        };
}

function heightGe(l, r) {
  if (r !== null) {
    if (l !== null) {
      return +(l.h >= r.h);
    } else {
      return /* false */0;
    }
  } else {
    return /* true */1;
  }
}

function bal(l, v, r) {
  var hl = l !== null ? l.h : 0;
  var hr = r !== null ? r.h : 0;
  if (hl > (hr + 2 | 0)) {
    var ll = l.left;
    var lv = l.key;
    var lr = l.right;
    if (heightGe(ll, lr)) {
      return create(ll, lv, create(lr, v, r));
    } else {
      var lrl = lr.left;
      var lrv = lr.key;
      var lrr = lr.right;
      return create(create(ll, lv, lrl), lrv, create(lrr, v, r));
    }
  } else if (hr > (hl + 2 | 0)) {
    var rl = r.left;
    var rv = r.key;
    var rr = r.right;
    if (heightGe(rr, rl)) {
      return create(create(l, v, rl), rv, rr);
    } else {
      var rll = rl.left;
      var rlv = rl.key;
      var rlr = rl.right;
      return create(create(l, v, rll), rlv, create(rlr, rv, rr));
    }
  } else {
    return {
            left: l,
            key: v,
            right: r,
            h: hl >= hr ? hl + 1 | 0 : hr + 1 | 0
          };
  }
}

function min0Aux(_n) {
  while(true) {
    var n = _n;
    var match = n.left;
    if (match !== null) {
      _n = match;
      continue ;
      
    } else {
      return n.key;
    }
  };
}

function minOpt0(n) {
  if (n !== null) {
    return /* Some */[min0Aux(n)];
  } else {
    return /* None */0;
  }
}

function minNull0(n) {
  if (n !== null) {
    return min0Aux(n);
  } else {
    return null;
  }
}

function max0Aux(_n) {
  while(true) {
    var n = _n;
    var match = n.right;
    if (match !== null) {
      _n = match;
      continue ;
      
    } else {
      return n.key;
    }
  };
}

function maxOpt0(n) {
  if (n !== null) {
    return /* Some */[max0Aux(n)];
  } else {
    return /* None */0;
  }
}

function maxNull0(n) {
  if (n !== null) {
    return max0Aux(n);
  } else {
    return null;
  }
}

function removeMinAuxWithRef(n, v) {
  var ln = n.left;
  var rn = n.right;
  var kn = n.key;
  if (ln !== null) {
    return bal(removeMinAuxWithRef(ln, v), kn, rn);
  } else {
    v[0] = kn;
    return rn;
  }
}

var empty0 = null;

function isEmpty0(n) {
  if (n !== null) {
    return /* false */0;
  } else {
    return /* true */1;
  }
}

function stackAllLeft(_v, _s) {
  while(true) {
    var s = _s;
    var v = _v;
    if (v !== null) {
      _s = /* :: */[
        v,
        s
      ];
      _v = v.left;
      continue ;
      
    } else {
      return s;
    }
  };
}

function iter0(_n, f) {
  while(true) {
    var n = _n;
    if (n !== null) {
      iter0(n.left, f);
      f(n.key);
      _n = n.right;
      continue ;
      
    } else {
      return /* () */0;
    }
  };
}

function fold0(_s, _accu, f) {
  while(true) {
    var accu = _accu;
    var s = _s;
    if (s !== null) {
      var l = s.left;
      var k = s.key;
      var r = s.right;
      _accu = f(fold0(l, accu, f), k);
      _s = r;
      continue ;
      
    } else {
      return accu;
    }
  };
}

function forAll0(_n, p) {
  while(true) {
    var n = _n;
    if (n !== null) {
      if (p(n.key)) {
        if (forAll0(n.left, p)) {
          _n = n.right;
          continue ;
          
        } else {
          return /* false */0;
        }
      } else {
        return /* false */0;
      }
    } else {
      return /* true */1;
    }
  };
}

function exists0(_n, p) {
  while(true) {
    var n = _n;
    if (n !== null) {
      if (p(n.key)) {
        return /* true */1;
      } else if (exists0(n.left, p)) {
        return /* true */1;
      } else {
        _n = n.right;
        continue ;
        
      }
    } else {
      return /* false */0;
    }
  };
}

function addMinElement(n, v) {
  if (n !== null) {
    return bal(addMinElement(n.left, v), n.key, n.right);
  } else {
    return singleton0(v);
  }
}

function addMaxElement(n, v) {
  if (n !== null) {
    return bal(n.left, n.key, addMaxElement(n.right, v));
  } else {
    return singleton0(v);
  }
}

function joinShared(ln, v, rn) {
  if (ln !== null) {
    if (rn !== null) {
      var lh = ln.h;
      var rh = rn.h;
      if (lh > (rh + 2 | 0)) {
        return bal(ln.left, ln.key, joinShared(ln.right, v, rn));
      } else if (rh > (lh + 2 | 0)) {
        return bal(joinShared(ln, v, rn.left), rn.key, rn.right);
      } else {
        return create(ln, v, rn);
      }
    } else {
      return addMaxElement(ln, v);
    }
  } else {
    return addMinElement(rn, v);
  }
}

function concatShared(t1, t2) {
  if (t1 !== null) {
    if (t2 !== null) {
      var v = [t2.key];
      var t2r = removeMinAuxWithRef(t2, v);
      return joinShared(t1, v[0], t2r);
    } else {
      return t1;
    }
  } else {
    return t2;
  }
}

function partitionShared0(n, p) {
  if (n !== null) {
    var key = n.key;
    var match = partitionShared0(n.left, p);
    var lf = match[1];
    var lt = match[0];
    var pv = p(key);
    var match$1 = partitionShared0(n.right, p);
    var rf = match$1[1];
    var rt = match$1[0];
    if (pv) {
      return /* tuple */[
              joinShared(lt, key, rt),
              concatShared(lf, rf)
            ];
    } else {
      return /* tuple */[
              concatShared(lt, rt),
              joinShared(lf, key, rf)
            ];
    }
  } else {
    return /* tuple */[
            null,
            null
          ];
  }
}

function lengthNode(n) {
  var l = n.left;
  var r = n.right;
  var sizeL = l !== null ? lengthNode(l) : 0;
  var sizeR = r !== null ? lengthNode(r) : 0;
  return (1 + sizeL | 0) + sizeR | 0;
}

function length0(n) {
  if (n !== null) {
    return lengthNode(n);
  } else {
    return 0;
  }
}

function toListAux(_accu, _n) {
  while(true) {
    var n = _n;
    var accu = _accu;
    if (n !== null) {
      _n = n.left;
      _accu = /* :: */[
        n.key,
        toListAux(accu, n.right)
      ];
      continue ;
      
    } else {
      return accu;
    }
  };
}

function toList0(s) {
  return toListAux(/* [] */0, s);
}

function checkInvariant(_v) {
  while(true) {
    var v = _v;
    if (v !== null) {
      var l = v.left;
      var r = v.right;
      var diff = height(l) - height(r) | 0;
      if (diff <= 2) {
        if (diff >= -2) {
          if (checkInvariant(l)) {
            _v = r;
            continue ;
            
          } else {
            return /* false */0;
          }
        } else {
          return /* false */0;
        }
      } else {
        return /* false */0;
      }
    } else {
      return /* true */1;
    }
  };
}

function fillArray(_n, _i, arr) {
  while(true) {
    var i = _i;
    var n = _n;
    var l = n.left;
    var v = n.key;
    var r = n.right;
    var next = l !== null ? fillArray(l, i, arr) : i;
    arr[next] = v;
    var rnext = next + 1 | 0;
    if (r !== null) {
      _i = rnext;
      _n = r;
      continue ;
      
    } else {
      return rnext;
    }
  };
}

function fillArrayWithPartition(_n, cursor, arr, p) {
  while(true) {
    var n = _n;
    var l = n.left;
    var v = n.key;
    var r = n.right;
    if (l !== null) {
      fillArrayWithPartition(l, cursor, arr, p);
    }
    if (p(v)) {
      var c = cursor.forward;
      arr[c] = v;
      cursor.forward = c + 1 | 0;
    } else {
      var c$1 = cursor.backward;
      arr[c$1] = v;
      cursor.backward = c$1 - 1 | 0;
    }
    if (r !== null) {
      _n = r;
      continue ;
      
    } else {
      return /* () */0;
    }
  };
}

function fillArrayWithFilter(_n, _i, arr, p) {
  while(true) {
    var i = _i;
    var n = _n;
    var l = n.left;
    var v = n.key;
    var r = n.right;
    var next = l !== null ? fillArrayWithFilter(l, i, arr, p) : i;
    var rnext = p(v) ? (arr[next] = v, next + 1 | 0) : next;
    if (r !== null) {
      _i = rnext;
      _n = r;
      continue ;
      
    } else {
      return rnext;
    }
  };
}

function toArray0(n) {
  if (n !== null) {
    var size = lengthNode(n);
    var v = new Array(size);
    fillArray(n, 0, v);
    return v;
  } else {
    return /* array */[];
  }
}

function ofSortedArrayRevAux(arr, off, len) {
  if (len > 3 || len < 0) {
    var nl = len / 2 | 0;
    var left = ofSortedArrayRevAux(arr, off, nl);
    var mid = arr[off - nl | 0];
    var right = ofSortedArrayRevAux(arr, (off - nl | 0) - 1 | 0, (len - nl | 0) - 1 | 0);
    return create(left, mid, right);
  } else {
    switch (len) {
      case 0 : 
          return empty0;
      case 1 : 
          return singleton0(arr[off]);
      case 2 : 
          var x0 = arr[off];
          var x1 = arr[off - 1 | 0];
          return {
                  left: singleton0(x0),
                  key: x1,
                  right: empty0,
                  h: 2
                };
      case 3 : 
          var x0$1 = arr[off];
          var x1$1 = arr[off - 1 | 0];
          var x2 = arr[off - 2 | 0];
          return {
                  left: singleton0(x0$1),
                  key: x1$1,
                  right: singleton0(x2),
                  h: 2
                };
      
    }
  }
}

function ofSortedArrayAux(arr, off, len) {
  if (len > 3 || len < 0) {
    var nl = len / 2 | 0;
    var left = ofSortedArrayAux(arr, off, nl);
    var mid = arr[off + nl | 0];
    var right = ofSortedArrayAux(arr, (off + nl | 0) + 1 | 0, (len - nl | 0) - 1 | 0);
    return create(left, mid, right);
  } else {
    switch (len) {
      case 0 : 
          return empty0;
      case 1 : 
          return singleton0(arr[off]);
      case 2 : 
          var x0 = arr[off];
          var x1 = arr[off + 1 | 0];
          return {
                  left: singleton0(x0),
                  key: x1,
                  right: empty0,
                  h: 2
                };
      case 3 : 
          var x0$1 = arr[off];
          var x1$1 = arr[off + 1 | 0];
          var x2 = arr[off + 2 | 0];
          return {
                  left: singleton0(x0$1),
                  key: x1$1,
                  right: singleton0(x2),
                  h: 2
                };
      
    }
  }
}

function ofSortedArrayUnsafe0(arr) {
  return ofSortedArrayAux(arr, 0, arr.length);
}

function filterShared0(n, p) {
  if (n !== null) {
    var l = n.left;
    var v = n.key;
    var r = n.right;
    var newL = filterShared0(l, p);
    var pv = p(v);
    var newR = filterShared0(r, p);
    if (pv) {
      if (l === newL && r === newR) {
        return n;
      } else {
        return joinShared(newL, v, newR);
      }
    } else {
      return concatShared(newL, newR);
    }
  } else {
    return null;
  }
}

function filterCopy(n, p) {
  if (n !== null) {
    var size = lengthNode(n);
    var v = new Array(size);
    var last = fillArrayWithFilter(n, 0, v, p);
    return ofSortedArrayAux(v, 0, last);
  } else {
    return null;
  }
}

function partitionCopy(n, p) {
  if (n !== null) {
    var size = lengthNode(n);
    var v = new Array(size);
    var backward = size - 1 | 0;
    var cursor = {
      forward: 0,
      backward: backward
    };
    fillArrayWithPartition(n, cursor, v, p);
    var forwardLen = cursor.forward;
    return /* tuple */[
            ofSortedArrayAux(v, 0, forwardLen),
            ofSortedArrayRevAux(v, backward, size - forwardLen | 0)
          ];
  } else {
    return /* tuple */[
            null,
            null
          ];
  }
}

function mem0(_t, x, cmp) {
  while(true) {
    var t = _t;
    if (t !== null) {
      var v = t.key;
      var c = cmp(x, v);
      if (c) {
        _t = c < 0 ? t.left : t.right;
        continue ;
        
      } else {
        return /* true */1;
      }
    } else {
      return /* false */0;
    }
  };
}

function cmp0(s1, s2, cmp) {
  var len1 = length0(s1);
  var len2 = length0(s2);
  if (len1 === len2) {
    var _e1 = stackAllLeft(s1, /* [] */0);
    var _e2 = stackAllLeft(s2, /* [] */0);
    var cmp$1 = cmp;
    while(true) {
      var e2 = _e2;
      var e1 = _e1;
      if (e1) {
        if (e2) {
          var h2 = e2[0];
          var h1 = e1[0];
          var c = cmp$1(h1.key, h2.key);
          if (c) {
            return c;
          } else {
            _e2 = stackAllLeft(h2.right, e2[1]);
            _e1 = stackAllLeft(h1.right, e1[1]);
            continue ;
            
          }
        } else {
          return 0;
        }
      } else {
        return 0;
      }
    };
  } else if (len1 < len2) {
    return -1;
  } else {
    return 1;
  }
}

function eq0(s1, s2, cmp) {
  return +(cmp0(s1, s2, cmp) === 0);
}

function subset0(_s1, _s2, cmp) {
  while(true) {
    var s2 = _s2;
    var s1 = _s1;
    if (s1 !== null) {
      if (s2 !== null) {
        var l1 = s1.left;
        var v1 = s1.key;
        var r1 = s1.right;
        var l2 = s2.left;
        var v2 = s2.key;
        var r2 = s2.right;
        var c = cmp(v1, v2);
        if (c) {
          if (c < 0) {
            if (subset0(create(l1, v1, null), l2, cmp)) {
              _s1 = r1;
              continue ;
              
            } else {
              return /* false */0;
            }
          } else if (subset0(create(null, v1, r1), r2, cmp)) {
            _s1 = l1;
            continue ;
            
          } else {
            return /* false */0;
          }
        } else if (subset0(l1, l2, cmp)) {
          _s2 = r2;
          _s1 = r1;
          continue ;
          
        } else {
          return /* false */0;
        }
      } else {
        return /* false */0;
      }
    } else {
      return /* true */1;
    }
  };
}

function findOpt0(_n, x, cmp) {
  while(true) {
    var n = _n;
    if (n !== null) {
      var v = n.key;
      var c = cmp(x, v);
      if (c) {
        _n = c < 0 ? n.left : n.right;
        continue ;
        
      } else {
        return /* Some */[v];
      }
    } else {
      return /* None */0;
    }
  };
}

function findNull0(_n, x, cmp) {
  while(true) {
    var n = _n;
    if (n !== null) {
      var v = n.key;
      var c = cmp(x, v);
      if (c) {
        _n = c < 0 ? n.left : n.right;
        continue ;
        
      } else {
        return v;
      }
    } else {
      return null;
    }
  };
}

function findExn0(_n, x, cmp) {
  while(true) {
    var n = _n;
    if (n !== null) {
      var v = n.key;
      var c = cmp(x, v);
      if (c) {
        _n = c < 0 ? n.left : n.right;
        continue ;
        
      } else {
        return v;
      }
    } else {
      throw new Error("findExn0");
    }
  };
}

function rotateWithLeftChild(k2) {
  var k1 = k2.left;
  k2.left = k1.right;
  k1.right = k2;
  var hlk2 = height(k2.left);
  var hrk2 = height(k2.right);
  k2.h = (
    hlk2 > hrk2 ? hlk2 : hrk2
  ) + 1 | 0;
  var hlk1 = height(k1.left);
  var hk2 = k2.h;
  k1.h = (
    hlk1 > hk2 ? hlk1 : hk2
  ) + 1 | 0;
  return k1;
}

function rotateWithRightChild(k1) {
  var k2 = k1.right;
  k1.right = k2.left;
  k2.left = k1;
  var hlk1 = height(k1.left);
  var hrk1 = height(k1.right);
  k1.h = (
    hlk1 > hrk1 ? hlk1 : hrk1
  ) + 1 | 0;
  var hrk2 = height(k2.right);
  var hk1 = k1.h;
  k2.h = (
    hrk2 > hk1 ? hrk2 : hk1
  ) + 1 | 0;
  return k2;
}

function doubleWithLeftChild(k3) {
  var v = rotateWithRightChild(k3.left);
  k3.left = v;
  return rotateWithLeftChild(k3);
}

function doubleWithRightChild(k2) {
  var v = rotateWithLeftChild(k2.right);
  k2.right = v;
  return rotateWithRightChild(k2);
}

function heightUpdateMutate(t) {
  var hlt = height(t.left);
  var hrt = height(t.right);
  t.h = (
    hlt > hrt ? hlt : hrt
  ) + 1 | 0;
  return t;
}

function balMutate(nt) {
  var l = nt.left;
  var r = nt.right;
  var hl = height(l);
  var hr = height(r);
  if (hl > (2 + hr | 0)) {
    var ll = l.left;
    var lr = l.right;
    if (heightGe(ll, lr)) {
      return heightUpdateMutate(rotateWithLeftChild(nt));
    } else {
      return heightUpdateMutate(doubleWithLeftChild(nt));
    }
  } else if (hr > (2 + hl | 0)) {
    var rl = r.left;
    var rr = r.right;
    if (heightGe(rr, rl)) {
      return heightUpdateMutate(rotateWithRightChild(nt));
    } else {
      return heightUpdateMutate(doubleWithRightChild(nt));
    }
  } else {
    nt.h = (
      hl > hr ? hl : hr
    ) + 1 | 0;
    return nt;
  }
}

function addMutate(cmp, t, x) {
  if (t !== null) {
    var k = t.key;
    var c = cmp(x, k);
    if (c) {
      var l = t.left;
      var r = t.right;
      if (c < 0) {
        var ll = addMutate(cmp, l, x);
        t.left = ll;
      } else {
        t.right = addMutate(cmp, r, x);
      }
      return balMutate(t);
    } else {
      return t;
    }
  } else {
    return singleton0(x);
  }
}

function ofArray0(xs, cmp) {
  var len = xs.length;
  if (len) {
    var next = Bs_Sort.strictlySortedLength(xs, (function (x, y) {
            return +(cmp(x, y) < 0);
          }));
    var result;
    if (next >= 0) {
      result = ofSortedArrayAux(xs, 0, next);
    } else {
      next = -next | 0;
      result = ofSortedArrayRevAux(xs, next - 1 | 0, next);
    }
    for(var i = next ,i_finish = len - 1 | 0; i <= i_finish; ++i){
      result = addMutate(cmp, result, xs[i]);
    }
    return result;
  } else {
    return empty0;
  }
}

function removeMinAuxWithRootMutate(nt, n) {
  var rn = n.right;
  var ln = n.left;
  if (ln !== null) {
    n.left = removeMinAuxWithRootMutate(nt, ln);
    return balMutate(n);
  } else {
    nt.key = n.key;
    return rn;
  }
}

exports.copy = copy;
exports.create = create;
exports.bal = bal;
exports.singleton0 = singleton0;
exports.minOpt0 = minOpt0;
exports.minNull0 = minNull0;
exports.maxOpt0 = maxOpt0;
exports.maxNull0 = maxNull0;
exports.removeMinAuxWithRef = removeMinAuxWithRef;
exports.empty0 = empty0;
exports.isEmpty0 = isEmpty0;
exports.stackAllLeft = stackAllLeft;
exports.iter0 = iter0;
exports.fold0 = fold0;
exports.forAll0 = forAll0;
exports.exists0 = exists0;
exports.joinShared = joinShared;
exports.concatShared = concatShared;
exports.filterShared0 = filterShared0;
exports.filterCopy = filterCopy;
exports.partitionShared0 = partitionShared0;
exports.partitionCopy = partitionCopy;
exports.lengthNode = lengthNode;
exports.length0 = length0;
exports.toList0 = toList0;
exports.checkInvariant = checkInvariant;
exports.fillArray = fillArray;
exports.toArray0 = toArray0;
exports.ofSortedArrayAux = ofSortedArrayAux;
exports.ofSortedArrayRevAux = ofSortedArrayRevAux;
exports.ofSortedArrayUnsafe0 = ofSortedArrayUnsafe0;
exports.mem0 = mem0;
exports.cmp0 = cmp0;
exports.eq0 = eq0;
exports.subset0 = subset0;
exports.findOpt0 = findOpt0;
exports.findNull0 = findNull0;
exports.findExn0 = findExn0;
exports.ofArray0 = ofArray0;
exports.addMutate = addMutate;
exports.balMutate = balMutate;
exports.removeMinAuxWithRootMutate = removeMinAuxWithRootMutate;
/* No side effect */
