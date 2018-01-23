#ifdef TYPE_STRING
type key = string
type seed = int
external caml_hash_mix_string : seed -> string -> seed  = "caml_hash_mix_string"
external final_mix : seed -> seed = "caml_hash_final_mix"
let hash (s : key) =   
  final_mix  (caml_hash_mix_string 0 s )
             #elif defined TYPE_INT
type key = int
type seed = int
external caml_hash_mix_int : seed -> int -> seed  = "caml_hash_mix_int"
external final_mix : seed -> seed = "caml_hash_final_mix"
let hash (s : key) = 
  final_mix (caml_hash_mix_int 0 s)
            #else 
  [%error "unknown type"]
  #endif

module N = Bs_internalSetBuckets
module C = Bs_internalBucketsType
module A = Bs_Array
type t = key N.t0 

let rec copyBucket  ~h_buckets ~ndata_tail h old_bucket = 
  match C.toOpt old_bucket with 
  | None -> ()
  | Some cell ->
    let nidx = hash (N.key cell)  land (Array.length h_buckets - 1) in 
    let v = C.return cell in 
    begin match C.toOpt (A.unsafe_get ndata_tail nidx) with
      | None -> 
        A.unsafe_set h_buckets nidx  v
      | Some tail ->
        N.nextSet tail v  (* cell put at the end *)            
    end;          
    A.unsafe_set ndata_tail nidx  v;
    copyBucket  ~h_buckets ~ndata_tail h (N.next cell)


let resize  h =
  let odata = C.buckets h in
  let osize = Array.length odata in
  let nsize = osize * 2 in
  if nsize >= osize then begin (* no overflow *)
    let h_buckets = A.makeUninitialized nsize  in
    let ndata_tail = A.makeUninitialized nsize  in (* keep track of tail *)
    C.bucketsSet h  h_buckets;          (* so that indexfun sees the new bucket count *)
    for i = 0 to osize - 1 do
      copyBucket  ~h_buckets ~ndata_tail h (A.unsafe_get odata i)
    done;
    for i = 0 to nsize - 1 do
      match C.toOpt (A.unsafe_get ndata_tail i) with
      | None -> ()
      | Some tail -> N.nextSet tail C.emptyOpt
    done
  end



let rec removeBucket  h h_buckets  i (key : key) prec cell =
  let cell_next = N.next cell in 
  if  (N.key cell) = key 
  then 
    begin
      N.nextSet prec cell_next;
      C.sizeSet h (C.size h - 1);        
    end
  else 
    match C.toOpt cell_next with 
    | None -> 
      ()
    | Some cell_next ->
      removeBucket h h_buckets i key cell cell_next

let removeDone h (key : key)=  
  let h_buckets = C.buckets h in 
  let i = hash key  land (Array.length h_buckets - 1) in  
  let l = (A.unsafe_get h_buckets i) in 
  match C.toOpt l with 
  | None -> ()
  | Some cell -> 
    let next_cell = (N.next cell) in 
    if  (N.key cell) = key then 
      begin 
        C.sizeSet h (C.size h - 1) ;
        A.unsafe_set h_buckets i next_cell
      end
    else       
      match C.toOpt next_cell with 
      | None -> ()
      | Some next_cell -> 
        removeBucket h h_buckets i key cell next_cell

let remove h key = removeDone h key; h


let rec addBucket  h buckets_len (key : key)  cell = 
  if N.key cell <> key then
    let  n = N.next cell in 
    match C.toOpt n with 
    | None ->  
      C.sizeSet h (C.size h + 1);
      N.nextSet cell (C.return @@ N.bucket ~key ~next:n);
      if C.size h > buckets_len lsl 1 then resize  h
    | Some n -> addBucket  h buckets_len key  n

let addDone h (key : key)  =
  let h_buckets = C.buckets h in 
  let buckets_len = Array.length h_buckets in 
  let i = hash key land (buckets_len - 1) in 
  let l = Array.unsafe_get h_buckets i in  
  match C.toOpt l with                                    
  | None -> 
    A.unsafe_set h_buckets i 
      (C.return @@ N.bucket ~key ~next:C.emptyOpt);
    C.sizeSet h (C.size  h + 1);
    if C.size h > buckets_len lsl 1 then resize  h
  | Some cell -> 
    addBucket  h buckets_len key cell

let add h key = addDone h key; h


let rec memInBucket (key : key) cell = 

  (N.key cell) = key  || 
  (match C.toOpt (N.next cell) with 
   | None -> false 
   | Some nextCell -> 
     memInBucket key nextCell)

let has h key =
  let h_buckets = C.buckets h in 
  let nid = hash key  land (Array.length h_buckets - 1) in 
  let bucket = (A.unsafe_get h_buckets nid) in 
  match C.toOpt bucket with 
  | None -> false 
  | Some bucket -> 
    memInBucket key bucket


let create = C.create0
let clear = C.clear0

let size = C.size
let forEach = N.iter0
let reduce = N.fold0
let logStats = N.logStats0
let toArray = N.toArray0

let ofArray arr  = 
  let len = Bs.Array.length arr in 
  let v = create len in 
  for i = 0 to len - 1 do 
    addDone v (Bs.Array.unsafe_get arr i)
  done ;
  v

(* TOOD: optimize heuristics for resizing *)  
let mergeArrayDone h arr =   
  let len = Bs.Array.length arr in 
  for i = 0 to len - 1 do 
    addDone h (A.unsafe_get arr i)
  done


let mergeArray h arr =   
  mergeArrayDone h arr; h

let copy = N.copy
