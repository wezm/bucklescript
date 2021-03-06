let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y = Mt.eq_suites ~test_id ~suites loc x y 
let b loc x =  Mt.bool_suites ~test_id ~suites loc x  
let t loc x = Mt.throw_suites ~test_id ~suites loc x 
module N = Bs.Set
module I = Array_data_util
module A = Bs.Array
module IntCmp = 
  (val Bs.Cmp.make (fun[@bs] (x:int) y -> compare x y))
module L = Bs.List

let () = 
  let u0 = N.ofArray (module IntCmp) (I.range 0 30) in 
  let u1 = N.remove u0 0 in 
  let u2 = N.remove u1 0 in 
  let u3 = N.remove u2 30 in 
  let u4 = N.remove u3 20 in   
  let r = I.randomRange 0 30 in 
  
  let u5  = N.add u4 3 in 
  let u6 = N.removeArray u5 r in   
  let u7 = N.mergeArray u6 [|0;1;2;0|] in 
  let u8 = N.removeArray u7 [|0;1;2;3|] in 
  let u9 = N.mergeArray u8 (I.randomRange 0 20000)  in 
  let u10 = N.mergeArray u9 (I.randomRange 0 200) in 
  let u11 = N.removeArray u10 (I.randomRange 0 200) in 
  let u12 = N.removeArray u11 (I.randomRange 0 1000) in 
  let u13 = N.removeArray u12 (I.randomRange 0 1000) in 
  let u14 = N.removeArray u13 (I.randomRange 1000 10000) in 
  let u15 = N.removeArray u14 (I.randomRange 10000 (20000 - 1)) in 
  let u16 = N.removeArray u15 (I.randomRange 20000 21000) in
  b __LOC__ (u0 != u1);  
  b __LOC__ (u2 == u1);
  eq __LOC__ (N.size u4) 28; 
  b __LOC__ (Js.eqNull 29 (N.maxNull u4));
  b __LOC__ (Js.eqNull 1 (N.minNull u4));
  b __LOC__ (u4 == u5);  
  b __LOC__ (N.isEmpty u6);  
  eq  __LOC__ (N.size u7) 3 ;
  b __LOC__ (not (N.isEmpty u7));  
  b __LOC__ (N.isEmpty u8);
  (* b __LOC__ (u9 == u10); *)
  (* addArray does not get reference equality guarantee *)
  b __LOC__ (N.has u10 20);
  b __LOC__ (N.has u10 21);
  eq __LOC__ (N.size u10) 20001;
  eq __LOC__ (N.size u11) 19800;  
  eq __LOC__ (N.size u12) 19000;
  b __LOC__ (u12 == u13);  
  eq __LOC__ (N.size u14) 10000;
  eq __LOC__ (N.size u15) 1 ;
  b __LOC__ (N.has u15 20000);
  b __LOC__ (not @@ N.has u15 2000);
  b __LOC__ (N.isEmpty u16);
  let u17  = N.ofArray (module IntCmp) (I.randomRange 0 100) in 
  let u18 = N.ofArray (module IntCmp) (I.randomRange 59 200) in 
  let u19 = N.union u17 u18 in 
  let u20 = N.ofArray (module IntCmp) (I.randomRange 0 200) in 
  b __LOC__ (N.eq u19 u20);
  let u21 =  N.inter u17 u18 in 
  eq __LOC__ (N.toArray u21) (I.range 59 100);
  let u22 = N.diff u17 u18 in 
  eq __LOC__ (N.toArray u22) (I.range 0 58);
  let u23 = N.diff u18 u17 in 
  let u24 = N.union u18 u17 in 
  b __LOC__ (N.eq u24 u19);
  eq __LOC__ (N.toArray u23) (I.range 101 200);
  b __LOC__ (N.subset u23 u18);
  b __LOC__ (not (N.subset u18 u23));
  b __LOC__ (N.subset u22 u17);
  b __LOC__ (N.subset u21 u17 && N.subset u21 u18);
  b __LOC__ (Js.eqNull 47 (N.getNull u22 47));
  b __LOC__ ( Some 47 = (N.get u22 47));
  b __LOC__ (Js.Null.test (N.getNull u22 59));
  b __LOC__ (None = (N.get u22 59));
  let u25 = N.add u22 59 in 
  eq __LOC__ (N.size u25) 60;
  b __LOC__ (N.minimum (N.empty (module IntCmp)) = None);
  b __LOC__ (N.maximum (N.empty (module IntCmp)) = None);
  b __LOC__ (N.minNull (N.empty (module IntCmp)) = Js.null);
  b __LOC__ (N.maxNull (N.empty (module IntCmp)) = Js.null)

let testIterToList  xs = 
  let v = ref [] in 
  N.forEach xs (fun[@bs] x -> v := x :: !v ) ; 
  L.reverse !v

let () =   
  let u0 = N.ofArray ~dict:(module IntCmp) (I.randomRange 0 20) in 
  let u1 = N.remove u0 17 in  
  let u2 = N.add u1 33 in 
  b __LOC__ (L.forAll2 (testIterToList u0) (L.init 21 (fun[@bs] i -> i)) (fun [@bs] x y -> x = y));
  b __LOC__ (L.forAll2 (testIterToList u0) (N.toList u0) (fun [@bs] x y -> x = y));
  b __LOC__ (N.exists u0 (fun [@bs] x -> x = 17));
  b __LOC__ (not (N.exists u1 (fun [@bs] x -> x = 17)));
  b __LOC__ (N.forAll u0 (fun [@bs] x -> x < 24));
  b __LOC__ (not (N.forAll u2 (fun [@bs] x -> x < 24)));
  b __LOC__ (N.cmp u1 u0 < 0);
  b __LOC__ (N.cmp u0 u1 > 0)

let () =   
  let a0 = N.ofArray ~dict:(module IntCmp) (I.randomRange 0 1000) in 
  let a1,a2 = 
    (
      N.filter a0 (fun [@bs] x -> x mod 2  = 0),
      N.filter a0 (fun [@bs] x -> x mod 2 <> 0)
    ) in 
  let a3, a4 = N.partition a0 (fun [@bs] x -> x mod 2 = 0) in   
  b __LOC__ (N.eq a1 a3);
  b __LOC__ (N.eq a2 a4);
  eq __LOC__ (N.getExn a0 3) 3 ;
  eq __LOC__ (N.getExn a0 4) 4;   
  t __LOC__ (fun _ -> ignore @@ N.getExn a0 1002 );
  t __LOC__ (fun _ -> ignore @@ N.getExn a0 (-1) );  
  eq __LOC__ (N.size a0 ) 1001;
  b __LOC__ (not @@ N.isEmpty a0);
  let (a5,a6), pres  = N.split a0 200 in 
  b __LOC__ pres ;
  eq __LOC__ (N.toArray a5) (A.initExn 200 (fun[@bs] i -> i));
  eq __LOC__ (N.toList a6) (L.init 800 (fun[@bs] i -> i + 201));
  let a7 = N.remove a0 200 in 
  let (a8,a9), pres  = N.split a7 200 in 
  b __LOC__ (not pres) ;
  eq __LOC__ (N.toArray a8) (A.initExn 200 (fun[@bs] i -> i));
  eq __LOC__ (N.toList a9) (L.init 800 (fun[@bs] i -> i + 201));
  eq __LOC__ (N.minimum a8) (Some 0);
  eq __LOC__ (N.minimum a9) (Some 201);
  b __LOC__ (L.forAll [a0;a1;a2;a3;a4] (fun [@bs] x -> N.checkInvariant x))


let () =   
  let a = N.ofArray (module IntCmp) [||] in 
  b __LOC__ (N.isEmpty (N.filter a (fun[@bs] x -> x mod 2 = 0)))


;; Mt.from_pair_suites __FILE__ !suites  