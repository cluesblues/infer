(*
 * Copyright (c) 2009-2013, Monoidics ltd.
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

(** Program variables. *)

open! IStd
module F = Format

type translation_unit = SourceFile.t option [@@deriving compare]

(** Type for program variables. There are 4 kinds of variables:
        1) local variables, used for local variables and formal parameters
        2) callee program variables, used to handle recursion ([x | callee] is distinguished from [x])
        3) global variables
        4) seed variables, used to store the initial value of formal parameters
*)
type t [@@deriving compare]

val compare_modulo_this : t -> t -> int
(** Comparison considering all pvars named 'this'/'self' to be equal *)

val equal : t -> t -> bool
(** Equality for pvar's *)

val get_declaring_function : t -> Typ.Procname.t option
(** if not a global, return function declaring var *)

val d : t -> unit
(** Dump a program variable. *)

val get_name : t -> Mangled.t
(** Get the name component of a program variable. *)

val get_ret_pvar : Typ.Procname.t -> t
(** [get_ret_pvar proc_name] retuns the return pvar associated with the procedure name *)

val get_ret_param_pvar : Typ.Procname.t -> t
(** [get_ret_param_pvar proc_name] retuns the return_param pvar associated with the procedure name *)

val get_simplified_name : t -> string
(** Get a simplified version of the name component of a program variable. *)

val is_abduced : t -> bool
(** Check if the pvar is an abduced return var or param passed by ref *)

val is_callee : t -> bool
(** Check if the pvar is a callee var *)

val is_global : t -> bool
(** Check if the pvar is a global var or a static local var *)

val is_static_local : t -> bool
(** Check if the pvar is a static variable declared inside a function *)

val is_local : t -> bool
(** Check if the pvar is a (non-static) local var *)

val is_seed : t -> bool
(** Check if the pvar is a seed var *)

val is_return : t -> bool
(** Check if the pvar is a return var *)

val is_this : t -> bool
(** Check if a pvar is the special "this" var *)

val is_self : t -> bool
(** Check if a pvar is the special "self" var *)

val is_frontend_tmp : t -> bool
(** return true if [pvar] is a temporary variable generated by the frontend *)

val is_clang_tmp : t -> bool
(** return true if [pvar] is a temporary variable generated by clang *)

val is_ssa_frontend_tmp : t -> bool
(** return true if [pvar] is a temporary variable generated by the frontend and is only assigned
    once on a non-looping control-flow path *)

val is_cpp_temporary : t -> bool
(** return true if this pvar represents a C++ temporary object (see http://en.cppreference.com/w/cpp/language/lifetime) *)

val mk : Mangled.t -> Typ.Procname.t -> t
(** [mk name proc_name suffix] creates a program var with the given function name and suffix *)

val mk_abduced_ref_param : Typ.Procname.t -> int -> Location.t -> t
(** create an abduced variable for a parameter passed by reference *)

val mk_abduced_ret : Typ.Procname.t -> Location.t -> t
(** create an abduced return variable for a call to [proc_name] at [loc] *)

val mk_callee : Mangled.t -> Typ.Procname.t -> t
(** [mk_callee name proc_name] creates a program var
    for a callee function with the given function name *)

val mk_global :
     ?is_constexpr:bool
  -> ?is_ice:bool
  -> ?is_pod:bool
  -> ?is_static_local:bool
  -> ?is_static_global:bool
  -> ?translation_unit:SourceFile.t
  -> Mangled.t
  -> t
(** create a global variable with the given name *)

val mk_tmp : string -> Typ.Procname.t -> t
(** create a fresh temporary variable local to procedure [pname]. for use in the frontends only! *)

val pp : Pp.env -> F.formatter -> t -> unit
(** Pretty print a program variable. *)

val pp_value : F.formatter -> t -> unit
(** Pretty print a pvar which denotes a value, not an address *)

val pp_translation_unit : F.formatter -> translation_unit -> unit

val to_callee : Typ.Procname.t -> t -> t
(** Turn an ordinary program variable into a callee program variable *)

val to_seed : t -> t
(** Turn a pvar into a seed pvar (which stores the initial value of a stack var) *)

val to_string : t -> string
(** Convert a pvar to string. *)

val get_translation_unit : t -> translation_unit
(** Get the translation unit corresponding to a global. Raises Invalid_arg if not a global. *)

val is_compile_constant : t -> bool
(** Is the variable's value a compile-time constant? Always (potentially incorrectly) returns
    [false] for non-globals. *)

val is_ice : t -> bool
(** Is the variable's type an integral constant expression? Always (potentially incorrectly) returns
    [false] for non-globals. *)

val is_pod : t -> bool
(** Is the variable's type a "Plain Old Data" type (C++)? Always (potentially incorrectly) returns
    [true] for non-globals. *)

val get_initializer_pname : t -> Typ.Procname.t option
(** Get the procname of the initializer function for the given global variable *)

val get_name_of_local_with_procname : t -> Mangled.t
(** [get_name_of_local_with_procname var] Return a name that is composed of the name of
var and the name of the procname in case of locals *)

val materialized_cpp_temporary : string