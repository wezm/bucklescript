(* Copyright (C) 2017 Authors of BuckleScript
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)


type 'a t


val create : unit -> 'a t

val clear : 'a t -> unit

val copy : 'a t -> 'a t
(** [copy x] O(1) *)

val push : 'a t -> 'a -> unit

val popNull : 'a t -> 'a Js.null

val popOpt : 'a t -> 'a option 

val topNull : 'a t -> 'a Js.null

val topOpt : 'a t -> 'a option 

val isEmpty : 'a t -> bool

val length : 'a t -> int

val iter : 'a t -> ('a -> unit [@bs]) -> unit

val dynamicPopIter : 'a t -> ('a ->  unit [@bs]) -> unit 
(** [dynamicPopIter s f ]
  apply [f] to each element of [s]. The item is poped 
  before applying [f], [s] will be empty  after this opeartion
*)

