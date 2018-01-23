#ifdef TYPE_STRING
type key = string
#elif defined TYPE_INT
type key = int
#else
[%error "unknown type"]
#endif  


type 'b t 


val create:  int -> 'b t 

val clear: 'b t -> unit

val setDone: 'a t -> key -> 'a -> unit
(** [setDone tbl k v] if [k] does not exist,
    add the binding [k,v], otherwise, update the old value with the new
    [v]
*)
  
val set: 'a t -> key -> 'a -> 'a t   
val copy: 'a t -> 'a t 
val get:  'a t -> key -> 'a option

val has:  'b  t -> key -> bool

val removeDone: 'a t -> key -> unit
val remove: 'a t -> key -> 'a t 

val forEach: 'b t -> (key -> 'b -> unit [@bs]) -> unit

val reduce: 'b t -> 'c -> ('c -> key -> 'b ->  'c [@bs]) -> 'c

val filterMapDone: 'a t ->  (key -> 'a -> 'a option [@bs]) -> unit
val filterMap: 'a t ->  (key -> 'a -> 'a option [@bs]) -> 'a t
  
val size: _ t -> int  
val logStats: _ t -> unit

val toArray: 'a t -> (key * 'a) array
val keysToArray: 'a t -> key array
val valuesToArray: 'a t -> 'a array
val ofArray: (key * 'a) array -> 'a t
val mergeArrayDone: 'a t -> (key * 'a) array -> unit
val mergeArray: 'a t -> (key * 'a) array -> 'a t

val getBucketHistogram: _ t -> int array

