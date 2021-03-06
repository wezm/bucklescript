
module N = Bs_internalAVLset
module B = Bs_BagM
module A = Bs_Array
module S = Bs_Sort 

type ('k,'id) t0 = 'k  N.t0 

type ('elt,'id) t = (('elt,'id) Bs_Cmp.t , ('elt,'id) t0) B.bag  


let rec removeMutateAux nt x ~cmp = 
  let k = N.key nt in 
  let c = (Bs_Cmp.getCmp cmp) x k [@bs] in 
  if c = 0 then 
    let l,r = N.(left nt, right nt) in       
    match N.(toOpt l, toOpt r) with 
    | Some _,  Some nr ->  
      N.rightSet nt (N.removeMinAuxWithRootMutate nt nr);
      N.return (N.balMutate nt)
    | None, Some _ ->
      r  
    | (Some _ | None ), None ->  l 
  else 
    begin 
      if c < 0 then 
        match N.toOpt (N.left nt) with         
        | None -> N.return nt 
        | Some l ->
          N.leftSet nt (removeMutateAux ~cmp l x );
          N.return (N.balMutate nt)
      else 
        match N.toOpt (N.right nt) with 
        | None -> N.return nt 
        | Some r -> 
          N.rightSet nt (removeMutateAux ~cmp r x);
          N.return (N.balMutate nt)
    end

let removeDone (type elt) (type id) (d : (elt,id) t) v =  
  let dict, oldRoot = B.(dict d, data d) in 
  let module M = (val dict) in 
  match N.toOpt oldRoot with 
  | None -> ()
  | Some oldRoot2 ->
    let newRoot = removeMutateAux ~cmp:M.cmp oldRoot2 v in 
    if newRoot != oldRoot then 
      B.dataSet d newRoot    

let remove d v =     
  removeDone d v; 
  d     

let rec removeArrayMutateAux t xs i len ~cmp  =  
  if i < len then 
    let ele = A.unsafe_get xs i in 
    let u = removeMutateAux t ele ~cmp in 
    match N.toOpt u with 
    | None -> N.empty0
    | Some t -> removeArrayMutateAux t xs (i+1) len ~cmp 
  else N.return t    

let removeArrayDone (type elt) (type id) (d : (elt,id) t) xs =  
  let oldRoot = B.data d in 
  match N.toOpt oldRoot with 
  | None -> ()
  | Some nt -> 
    let len = A.length xs in 
    let dict = B.dict d in  
    let module M = (val dict) in 
    let newRoot = removeArrayMutateAux nt xs 0 len ~cmp:M.cmp in 
    if newRoot != oldRoot then 
      B.dataSet d newRoot

let removeArray d xs =      
  removeArrayDone d xs; 
  d

let rec removeMutateCheckAux  nt x removed ~cmp= 
  let k = N.key nt in 
  let c = (Bs_Cmp.getCmp cmp) x k [@bs] in 
  if c = 0 then 
    let () = removed := true in  
    let l,r = N.(left nt, right nt) in       
    match N.(toOpt l, toOpt r) with 
    | Some _,  Some nr ->  
      N.rightSet nt (N.removeMinAuxWithRootMutate nt nr);
      N.return (N.balMutate nt)
    | None, Some _ ->
      r  
    | (Some _ | None ), None ->  l 
  else 
    begin 
      if c < 0 then 
        match N.toOpt (N.left nt) with         
        | None -> N.return nt 
        | Some l ->
          N.leftSet nt (removeMutateCheckAux ~cmp l x removed);
          N.return (N.balMutate nt)
      else 
        match N.toOpt (N.right nt) with 
        | None -> N.return nt 
        | Some r -> 
          N.rightSet nt (removeMutateCheckAux ~cmp r x removed);
          N.return (N.balMutate nt)
    end



let removeCheck (type elt) (type id) (d : (elt,id) t) v =  
  let dict, oldRoot = B.(dict d, data d) in 
  let module M = (val dict) in 
  match N.toOpt oldRoot with 
  | None -> false 
  | Some oldRoot2 ->
    let removed = ref false in 
    let newRoot = removeMutateCheckAux ~cmp:M.cmp oldRoot2 v removed in 
    if newRoot != oldRoot then  
      B.dataSet d newRoot ;   
    !removed



let rec addMutateCheckAux  (t : _ t0) x added ~cmp  =   
  match N.toOpt t with 
  | None -> 
    added := true;
    N.singleton0 x 
  | Some nt -> 
    let k = N.key nt in 
    let  c = (Bs_Cmp.getCmp cmp) x k [@bs] in  
    if c = 0 then t 
    else
      let l, r = N.(left nt, right nt) in 
      (if c < 0 then                   
         let ll = addMutateCheckAux ~cmp l x added in
         N.leftSet nt ll
       else   
         N.rightSet nt (addMutateCheckAux ~cmp r x added );
      );
      N.return (N.balMutate nt)

let addCheck (type elt) (type id) (m : (elt,id) t) e = 
  let dict, oldRoot = B.(dict m, data m) in 
  let module M = (val dict) in 
  let added = ref false in 
  let newRoot = addMutateCheckAux ~cmp:M.cmp oldRoot e added in 
  if newRoot != oldRoot then 
    B.dataSet m newRoot;
  !added    


let split (type elt) (type id) (d : (elt,id) t)  key  =     
  let dict, s = B.dict d, B.data d  in 
  let module M = (val dict ) in 
  let arr = N.toArray0 s in 
  let i = S.binSearch arr key (Bs_Cmp.getCmp M.cmp)  in   
  let len = A.length arr in 
  if i < 0 then 
    let next = - i -1 in 
    (B.bag 
       ~data:(N.ofSortedArrayAux arr 0 next)
       ~dict
     , 
     B.bag 
       ~data:(N.ofSortedArrayAux arr next (len - next))
       ~dict
    ), false
  else 
    (B.bag 
       ~data:(N.ofSortedArrayAux arr 0 i)
       ~dict,
     B.bag 
       ~data:(N.ofSortedArrayAux arr (i+1) (len - i - 1))
       ~dict
    ), true       

let filter d p = 
  let data, dict = B.(data d, dict d) in  
  B.bag ~data:(N.filterCopy data p ) ~dict 
let partition d p = 
  let data, dict = B.(data d, dict d) in 
  let a , b = N.partitionCopy data p in 
  B.bag ~data:a ~dict, B.bag ~data:b ~dict      

let empty ~dict = 
  B.bag ~dict ~data:N.empty0
let isEmpty d = 
  N.isEmpty0 (B.data d)
let singleton x ~dict = 
  B.bag ~data:(N.singleton0 x) ~dict 
let minimum d = 
  N.minOpt0 (B.data d)
let minNull d =
  N.minNull0 (B.data d)
let maximum d = 
  N.maxOpt0 (B.data d)
let maxNull d =
  N.maxNull0 (B.data d)
let forEach d f =
  N.iter0 (B.data d) f     
let reduce d acc cb = 
  N.fold0 (B.data d) acc cb 
let forAll d p = 
  N.forAll0 (B.data d) p 
let exists d  p = 
  N.exists0 (B.data d) p   
let size d = 
  N.length0 (B.data d)
let toList d =
  N.toList0 (B.data d)
let toArray d = 
  N.toArray0 (B.data d)
let ofSortedArrayUnsafe xs ~dict : _ t =
  B.bag ~data:(N.ofSortedArrayUnsafe0 xs) ~dict   
let checkInvariant d = 
  N.checkInvariant (B.data d)
let cmp (type elt) (type id) (d0 : (elt,id) t) d1 = 
  let module M = (val B.dict d0) in 
  N.cmp0 ~cmp:M.cmp (B.data d0) (B.data d1)
let eq (type elt) (type id) (d0 : (elt,id) t)  d1 = 
  let module M = (val B.dict d0) in 
  N.eq0 ~cmp:M.cmp (B.data d0) (B.data d1)
let get (type elt) (type id) (d : (elt,id) t) x = 
  let module M = (val B.dict d) in 
  N.findOpt0 ~cmp:M.cmp (B.data d) x 
let getNull (type elt) (type id) (d : (elt,id) t) x = 
  let module M = (val B.dict d) in 
  N.findNull0 ~cmp:M.cmp (B.data d) x
let getExn (type elt) (type id) (d : (elt,id) t) x = 
  let dict = B.dict d in 
  let module M = (val dict) in 
  N.findExn0 ~cmp:M.cmp (B.data d) x     
let has (type elt) (type id) (d : (elt,id) t) x =
  let dict = B.dict d in 
  let module M = (val dict) in 
  N.mem0 ~cmp:M.cmp (B.data d) x   
let ofArray (type elt) (type id) data ~(dict : (elt,id) Bs_Cmp.t) =  
  let module M = (val dict) in 
  B.bag ~dict ~data:(N.ofArray0 ~cmp:M.cmp data)
let addDone (type elt) (type id) (m : (elt,id) t) e = 
  let dict, oldRoot = B.(dict m, data m) in 
  let module M = (val dict) in 
  let newRoot = N.addMutate ~cmp:M.cmp oldRoot e  in 
  if newRoot != oldRoot then 
    B.dataSet m newRoot
let add m e = 
  addDone m e;
  m
let addArrayMutate (t : _ t0) xs ~cmp =     
  let v = ref t in 
  for i = 0 to A.length xs - 1 do 
    v := N.addMutate !v (A.unsafe_get xs i)  ~cmp
  done; 
  !v 
let mergeArrayDone (type elt) (type id) (d : (elt,id) t ) xs =   
  let dict = B.dict d in 
  let oldRoot = B.data d in 
  let module M = (val dict) in 
  let newRoot = addArrayMutate oldRoot xs ~cmp:M.cmp in 
  if newRoot != oldRoot then 
    B.dataSet d newRoot 
let mergeArray d xs = 
  mergeArrayDone d xs ; 
  d 







let subset (type elt) (type id) (a : (elt,id) t) b = 
  let dict = B.dict a in 
  let module M = (val dict) in 
  N.subset0  ~cmp:M.cmp (B.data a) (B.data b)

let inter (type elt) (type id) (a : (elt,id) t) b  : _ t = 
  let dict, dataa, datab = B.dict a, B.data a, B.data b in 
  let module M = (val dict) in 
  match N.toOpt dataa, N.toOpt datab with 
  | None, _ -> empty dict
  | _, None -> empty dict
  | Some dataa0, Some datab0 ->  
    let sizea, sizeb = 
      N.lengthNode dataa0, N.lengthNode datab0 in          
    let totalSize = sizea + sizeb in 
    let tmp = A.makeUninitializedUnsafe totalSize in 
    ignore @@ N.fillArray dataa0 0 tmp ; 
    ignore @@ N.fillArray datab0 sizea tmp;
    let p = Bs_Cmp.getCmp M.cmp in 
    if (p (A.unsafe_get tmp (sizea - 1))
          (A.unsafe_get tmp sizea) [@bs] < 0)
       || 
       (p 
          (A.unsafe_get tmp (totalSize - 1))
          (A.unsafe_get tmp 0) [@bs] < 0 
       )
    then empty dict
    else 
      let tmp2 = A.makeUninitializedUnsafe (min sizea sizeb) in 
      let k = S.inter tmp 0 sizea tmp sizea sizeb tmp2 0 p in 
      B.bag ~data:(N.ofSortedArrayAux tmp2 0 k)
        ~dict
let diff (type elt) (type id) (a : (elt,id) t) b : _ t = 
  let dict, dataa, datab = B.dict a, B.data a, B.data b in 
  let module M = (val dict) in
  match N.toOpt dataa, N.toOpt datab with 
  | None, _ -> empty dict 
  | _, None -> 
    B.bag ~data:(N.copy dataa) ~dict 
  | Some dataa0, Some datab0
    -> 
    let sizea, sizeb = N.lengthNode dataa0, N.lengthNode datab0 in  
    let totalSize = sizea + sizeb in 
    let tmp = A.makeUninitializedUnsafe totalSize in 
    ignore @@ N.fillArray dataa0 0 tmp ; 
    ignore @@ N.fillArray datab0 sizea tmp;
    let p = Bs_Cmp.getCmp M.cmp in 
    if (p (A.unsafe_get tmp (sizea - 1))
          (A.unsafe_get tmp sizea) [@bs] < 0)
       || 
       (p 
          (A.unsafe_get tmp (totalSize - 1))
          (A.unsafe_get tmp 0) [@bs] < 0 
       )
    then B.bag ~data:(N.copy dataa) ~dict 
    else 
      let tmp2 = A.makeUninitializedUnsafe sizea in 
      let k = S.diff tmp 0 sizea tmp sizea sizeb tmp2 0 p in 
      B.bag ~data:(N.ofSortedArrayAux tmp2 0 k) ~dict 

let union (type elt) (type id) (a : (elt,id) t) b = 
  let dict, dataa, datab = B.dict a, B.data a, B.data b  in 
  let module M = (val dict) in 
  match N.toOpt dataa, N.toOpt datab with 
  | None, _ -> B.bag ~data:(N.copy datab) ~dict 
  | _, None -> B.bag ~data:(N.copy dataa) ~dict 
  | Some dataa0, Some datab0 
    -> 
    let sizea, sizeb = N.lengthNode dataa0, N.lengthNode datab0 in 
    let totalSize = sizea + sizeb in 
    let tmp = A.makeUninitializedUnsafe totalSize in 
    ignore @@ N.fillArray dataa0 0 tmp ;
    ignore @@ N.fillArray datab0 sizea tmp ;
    let p = (Bs_Cmp.getCmp M.cmp)  in 
    if p
        (A.unsafe_get tmp (sizea - 1))
        (A.unsafe_get tmp sizea) [@bs] < 0 then 
      B.bag ~data:(N.ofSortedArrayAux tmp 0 totalSize) ~dict 
    else   
      let tmp2 = A.makeUninitializedUnsafe totalSize in 
      let k = S.union tmp 0 sizea tmp sizea sizeb tmp2 0 p in 
      B.bag ~data:(N.ofSortedArrayAux tmp2 0 k) ~dict 

let copy d = B.bag ~data:(N.copy (B.data d)) ~dict:(B.dict d)
