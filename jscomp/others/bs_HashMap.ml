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

module N = Bs_internalBuckets 
module C = Bs_internalBucketsType
module B = Bs_Bag 
module A = Bs_Array

type ('a, 'b,'id) t0 = ('a,'b) N.t0

type ('a,'b,'id) t = 
  (('a, 'id) Bs_Hash.t,
   ('a,'b,'id) t0) B.bag 



let rec copyBucketReHash ~hash ~h_buckets ~ndata_tail h old_bucket = 
  match C.toOpt old_bucket with 
  | None -> ()
  | Some cell ->
    let nidx = (Bs_Hash.getHash hash) (N.key cell) [@bs] land (A.length h_buckets - 1) in 
    let v = C.return cell in 
    begin match C.toOpt (A.unsafe_get ndata_tail nidx) with
      | None -> 
        A.unsafe_set h_buckets nidx  v
      | Some tail ->
        N.nextSet tail v  (* cell put at the end *)            
    end;          
    A.unsafe_set ndata_tail nidx  v;
    copyBucketReHash ~hash ~h_buckets ~ndata_tail h (N.next cell)


let resize ~hash h =
  let odata = C.buckets h in
  let osize = Array.length odata in
  let nsize = osize * 2 in
  if nsize >= osize then begin (* no overflow *)
    let h_buckets = A.makeUninitialized nsize  in
    let ndata_tail = A.makeUninitialized nsize  in (* keep track of tail *)
    C.bucketsSet h  h_buckets;          (* so that indexfun sees the new bucket count *)
    for i = 0 to osize - 1 do
      copyBucketReHash ~hash ~h_buckets ~ndata_tail h (A.unsafe_get odata i)
    done;
    for i = 0 to nsize - 1 do
      match C.toOpt (A.unsafe_get ndata_tail i) with
      | None -> ()
      | Some tail -> N.nextSet tail C.emptyOpt
    done
  end

let rec replaceInBucket ~eq  key info cell = 
  if (Bs_Hash.getEq eq) (N.key cell) key [@bs]
  then
    begin
      N.valueSet cell info;
      false
    end
  else
    match C.toOpt (N.next cell) with 
    | None -> true 
    | Some cell -> 
      replaceInBucket ~eq key info cell

(* if [key] already exists, replace it, otherwise add it 
   Here we add it to the head, it could be tail
*)      
let setDone0 ~hash ~eq  h key value =
  let h_buckets = C.buckets h in 
  let i = (Bs_Hash.getHash hash) key [@bs] land (Array.length h_buckets - 1) in 
  let l = Array.unsafe_get h_buckets i in  
  match C.toOpt l with  
  | None -> 
    A.unsafe_set h_buckets i (C.return (N.bucket ~key ~value ~next:l));
    C.sizeSet h (C.size  h + 1);
    if C.size h > Array.length (C.buckets h) lsl 1 then resize ~hash h
    (* do we really need resize here ? *)
  | Some bucket -> 
    begin 
      if replaceInBucket ~eq key value bucket then begin
        A.unsafe_set h_buckets i (C.return (N.bucket ~key ~value ~next:l));
        C.sizeSet h (C.size  h + 1);
        if C.size h > Array.length (C.buckets h) lsl 1 then resize ~hash h
        (* TODO: duplicate bucklets ? *)
      end 
    end

let rec removeInBucket  h h_buckets  i key prec bucket ~eq =
  match C.toOpt bucket with
  | None -> ()
  | Some cell ->
    let cell_next = N.next cell in 
    if (Bs_Hash.getEq eq) (N.key cell) key [@bs]
    then 
      begin        
        N.nextSet prec cell_next ; 
        C.sizeSet h (C.size h - 1);        
      end
    else removeInBucket ~eq h h_buckets i key cell cell_next

let remove0 ~hash ~eq h key =  
  let h_buckets = C.buckets h in 
  let i = (Bs_Hash.getHash hash) key [@bs] land (Array.length h_buckets - 1) in  
  let bucket = A.unsafe_get h_buckets i in 
  match C.toOpt bucket with 
  | None -> ()
  | Some cell -> 
    if (Bs_Hash.getEq eq) (N.key cell ) key [@bs] then 
    begin 
      A.unsafe_set h_buckets i (N.next cell);
      C.sizeSet h (C.size h - 1)
    end 
    else  
      removeInBucket ~eq h h_buckets i key  cell (N.next cell)


let rec findAux ~eq key buckets = 
  match C.toOpt buckets with 
  | None ->
    None
  | Some cell ->
    if (Bs_Hash.getEq eq) key (N.key cell) [@bs] then Some (N.value cell)
    else findAux ~eq key  (N.next cell)

let get0 ~hash ~eq h key =
  let h_buckets = C.buckets h in 
  let nid = (Bs_Hash.getHash hash) key [@bs] land (Array.length h_buckets - 1) in 
  match C.toOpt @@ A.unsafe_get h_buckets nid with
  | None -> None
  | Some cell1  ->
    if (Bs_Hash.getEq eq) key (N.key cell1) [@bs] then 
      Some  (N.value cell1)
    else
      match C.toOpt (N.next  cell1) with
      | None -> None
      | Some cell2 ->
        if (Bs_Hash.getEq eq) key 
            (N.key cell2) [@bs] then 
          Some (N.value cell2) else
          match C.toOpt (N.next cell2) with
          | None -> None
          | Some cell3 ->
            if (Bs_Hash.getEq eq) key 
                (N.key cell3) [@bs] then 
              Some (N.value cell3)
            else 
              findAux ~eq key (N.next cell3)


let rec memInBucket ~eq key cell = 
  (Bs_Hash.getEq eq) (N.key cell) key [@bs] || 
  (match C.toOpt (N.next cell) with 
   | None -> false 
   | Some nextCell -> 
     memInBucket ~eq key nextCell)

let has0 ~hash ~eq h key =
  let h_buckets = C.buckets h in 
  let nid = (Bs_Hash.getHash hash) key [@bs] land (Array.length h_buckets - 1) in 
  let bucket = A.unsafe_get h_buckets nid in 
  match C.toOpt bucket with 
  | None -> false 
  | Some bucket -> 
    memInBucket ~eq key bucket


let create0 = C.create0
let clear0 = C.clear0
let size0 = C.size
let forEach0 = N.forEach0
let reduce0 = N.reduce0
let logStats0 = N.logStats0
let filterMapDone0 = N.filterMapInplace0
let toArray0 = N.toArray0


let create initialize_size ~dict = 
  B.bag ~data:(create0 initialize_size) ~dict 
let clear h = clear0 (B.data h)
let size h = C.size (B.data h)                 
let forEach h f = N.forEach0 (B.data h) f
let reduce h init f = N.reduce0 (B.data h) init f
let logStats h = logStats0 (B.data h)

let setDone (type a)  (type id) (h : (a,_,id) t) (key:a) info = 
  let module M = (val B.dict h) in 
  setDone0 ~hash:M.hash ~eq:M.eq (B.data h) key info 

let set h key info = setDone h key info; h

let removeDone (type a) (type id) (h : (a,_,id) t) (key : a) = 
  let module M = (val B.dict h) in   
  remove0 ~hash:M.hash ~eq:M.eq (B.data h) key 

let remove h key = removeDone h key; h
  
let get (type a) (type id) (h : (a, _, id) t) (key : a) =           
  let module M = (val B.dict h) in   
  get0 ~hash:M.hash ~eq:M.eq (B.data h) key 

let has (type a) (type id) (h : (a,_,id) t) (key : a) =           
  let module M = (val B.dict h) in   
  has0 ~hash:M.hash ~eq:M.eq (B.data h) key   

let filterMapDone h f = filterMapDone0 (B.data h) f

let filterMap h f = filterMapDone h f; h
  
let toArray h = toArray0 (B.data h)

let ofArray0 arr ~hash ~eq = 
  let len = A.length arr in 
  let v = create0 len in 
  for i = 0 to len - 1 do 
    let key,value = (Bs.Array.unsafe_get arr i) in 
    setDone0 ~eq ~hash v key value
  done ;
  v

(* TOOD: optimize heuristics for resizing *)  
let mergeArrayDone0  h arr ~hash ~eq =   
  let len = A.length arr in 
  for i = 0 to len - 1 do 
    let key,value = (A.unsafe_get arr i) in 
    setDone0 h  ~eq ~hash key value
  done
  
let mergeArray0 h arr  ~hash ~eq = mergeArrayDone0 h arr ~hash ~eq; h
  
let ofArray (type a) (type id) arr ~dict:(dict:(a,id) Bs_Hash.t) =     
  let module M = (val dict) in 
  B.bag ~dict  ~data:M.(ofArray0 ~eq ~hash arr)

let mergeArrayDone (type a) (type id) (h : (a,_,id) t) arr = 
  let module M = (val B.dict h) in
  mergeArrayDone0 ~hash:M.hash ~eq:M.eq (B.data h) arr

let mergeArray h arr = 
  mergeArrayDone h arr;
  h

let copy h = B.bag ~dict:(B.dict h) ~data:(N.copy (B.data h))

let keysToArray0 = N.keys0  
let keysToArray h = N.keys0 (B.data h)
let valuesToArray0 = N.values0  
let valuesToArray h = N.values0 (B.data h)

let getData = B.data
let getDict = B.dict
let packDictData = B.bag 
