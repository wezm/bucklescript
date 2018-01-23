(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the GNU Library General Public License, with    *)
(*  the special exception on linking described in file ../LICENSE.     *)
(*                                                                     *)
(***********************************************************************)
(**  Adapted by Authors of BuckleScript 2017                           *)

(* For JS backends, we use [undefined] as default value, so that buckets
   could be allocated lazily
*)

(* We do dynamic hashing, and resize the table and rehash the elements
   when buckets become too long. *)
module C = Bs_internalBucketsType
(* TODO:
   the current implementation relies on the fact that bucket 
   empty value is [undefined] in both places,
   in theory, it can be different 

*)
type ('a,'b) bucket = {
  mutable key : 'a;
  mutable value : 'b;
  mutable next : ('a,'b) bucket C.opt
}  
and ('a, 'b) t0 = ('a,'b) bucket C.container  
[@@bs.deriving abstract]

module A = Bs_Array

type statistics = {
  num_bindings: int;
  num_buckets: int;
  max_bucket_length: int;
  bucket_histogram: int array
}

let rec copy ( x : _ t0) : _ t0= 
  C.container
    ~size:(C.size x)
    ~buckets:(copyBuckets (C.buckets x))
and copyBuckets ( buckets : _ bucket C.opt array) =  
  let len = A.length buckets in 
  let newBuckets = A.makeUninitializedUnsafe len in 
  for i = 0 to len - 1 do 
    A.unsafe_set newBuckets i 
    (copyBucket (A.unsafe_get buckets i))
  done ;
  newBuckets
and copyBucket c =   
  match C.toOpt c with 
  | None -> c 
  | Some c -> 
    let head = (bucket ~key:(key c) ~value:(value c)
                  ~next:(C.emptyOpt)) in 
    copyAuxCont (next c) head;
    C.return head
and copyAuxCont c prec =       
  match C.toOpt c with 
  | None -> ()
  | Some nc -> 
    let ncopy = 
        bucket ~key:(key nc) ~value:(value nc) ~next:C.emptyOpt in 
    nextSet prec (C.return ncopy) ;
    copyAuxCont (next nc) ncopy




let rec bucketLength accu buckets = 
  match C.toOpt buckets with 
  | None -> accu
  | Some cell -> bucketLength (accu + 1) (next cell)



let rec do_bucket_iter ~f buckets = 
  match C.toOpt buckets with 
  | None ->
    ()
  | Some cell ->
    f (key cell)  (value cell) [@bs]; do_bucket_iter ~f (next cell)

let forEach0 h f =
  let d = C.buckets h in
  for i = 0 to A.length d - 1 do
    do_bucket_iter f (A.unsafe_get d i)
  done


let rec do_bucket_fold ~f b accu =
  match C.toOpt b with
  | None ->
    accu
  | Some cell ->
    do_bucket_fold ~f (next cell) (f accu (key cell) (value cell)  [@bs]) 

let reduce0  h init f =
  let d = C.buckets h in
  let accu = ref init in
  for i = 0 to A.length d - 1 do
    accu := do_bucket_fold ~f (A.unsafe_get d i) !accu
  done;
  !accu



let getMaxBucketLength h =
  A.reduce (C.buckets h) 0
    (fun[@bs] m b -> 
       let len = bucketLength 0 b in
       Pervasives.max m len)

let getBucketHistogram h =
  let mbl = getMaxBucketLength h in 
  let histo = A.initExn (mbl + 1) (fun[@bs] _ -> 0) in
  A.forEach (C.buckets h)
    (fun[@bs] b ->
       let l = bucketLength 0 b in
       A.unsafe_set histo l (A.unsafe_get histo l + 1)
    );
  histo

let logStats0 h =
  let histogram = getBucketHistogram h in 
  Js.log [%obj{ bindings = C.size h;
                buckets = A.length (C.buckets h);
                histogram}]


(** iterate the Buckets, in place remove the elements *)                
let rec filterMapInplaceBucket f h i prec cell =
  let n = next cell in
  begin match f (key cell) (value cell) [@bs] with
    | None ->
      C.sizeSet h (C.size h - 1); (* delete *)
      begin match C.toOpt n with 
        | Some nextCell -> 
          filterMapInplaceBucket f h i prec nextCell
        | None -> 
          match C.toOpt prec with 
          | None -> A.unsafe_set (C.buckets h) i prec
          | Some cell -> nextSet cell n
      end
    | Some data -> (* replace *)
      let bucket = C.return cell in 
      begin match C.toOpt prec with
        | None -> A.unsafe_set (C.buckets h) i  bucket 
        | Some c -> nextSet cell bucket
      end;
      valueSet cell data;
      match C.toOpt n with 
      | None -> nextSet cell n 
      | Some nextCell -> 
        filterMapInplaceBucket f h i bucket nextCell
  end

let filterMapInplace0 h f =
  let h_buckets = C.buckets h in
  for i = 0 to A.length h_buckets - 1 do
    let v = A.unsafe_get h_buckets i in 
    match C.toOpt v with 
    | None -> ()
    | Some v -> filterMapInplaceBucket f h i C.emptyOpt v
  done

let rec fillArray i arr cell =  
  A.unsafe_set arr i (key cell, value cell);
  match C.toOpt (next cell) with 
  | None -> i + 1
  | Some v -> fillArray (i + 1) arr v 

let toArray0 h = 
  let d = C.buckets h in 
  let current = ref 0 in 
  let arr = A.makeUninitializedUnsafe (C.size h) in 
  for i = 0 to A.length d - 1 do  
    let cell = A.unsafe_get d i in 
    match C.toOpt cell with 
    | None -> ()
    | Some cell -> 
      current := fillArray !current arr cell
  done;
  arr 

let rec fillArrayMap i arr cell f =  
  A.unsafe_set arr i (f cell [@bs]);
  match C.toOpt (next cell) with 
  | None -> i + 1
  | Some v -> fillArrayMap (i + 1) arr v f

let linear h f = 
  let d = C.buckets h in 
  let current = ref 0 in 
  let arr = A.makeUninitializedUnsafe (C.size h) in 
  for i = 0 to A.length d - 1 do  
    let cell = A.unsafe_get d i in 
    match C.toOpt cell with 
    | None -> ()
    | Some cell -> 
      current := fillArrayMap !current arr cell f
  done;
  arr 

let keys0 h = linear h (fun [@bs] x -> key x)  
let values0 h = linear h (fun [@bs] x -> value x)  
let toArray0 h = linear h (fun [@bs]x -> key x, value x)
