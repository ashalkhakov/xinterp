(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Xanadu - Unleashing the Potential of Types!
** Copyright (C) 2018 Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of  the GNU GENERAL PUBLIC LICENSE (GPL) as published by the
** Free Software Foundation; either version 3, or (at  your  option)  any
** later version.
** 
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
** 
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*)

(* ****** ****** *)
//
// Author: Hongwei Xi
// Start Time: November, 2019
// Authoremail: gmhwxiATgmailDOTcom
//
(* ****** ****** *)
//
// HX-2019-11-02:
// level-1 interpreter for syncheck!
//
(* ****** ****** *)
//
#include
"share\
/atspre_staload.hats"
#include
"share\
/atspre_staload_libats_ML.hats"
#staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
#define
XANADU_targetloc
"./../../xanadu/srcgen/xats"
//
(* ****** ****** *)
//
#staload
LAB = "{$XANADU}/SATS/label0.sats"
#staload
STM = "{$XANADU}/SATS/stamp0.sats"
#staload
SYM = "{$XANADU}/SATS/symbol.sats"
//
#staload
D2E = "{$XANADU}/SATS/dynexp2.sats"
#staload
T12 = "{$XANADU}/SATS/trans12.sats"
//
(* ****** ****** *)

overload =
with $D2E.eq_d2cst_d2cst
overload =
with $D2E.eq_d2var_d2var

overload
print with $D2E.print_d2cst

overload
.stamp with $D2E.d2cst_get_stamp
overload
.stamp with $D2E.d2var_get_stamp

(* ****** ****** *)
//
#staload "./../SATS/intrep0.sats"
#staload "./../SATS/interp0.sats"
//
(* ****** ****** *)

#staload
_(*TMP*) =
"{$XANADU}/DATS/dynexp2_print.dats"

(* ****** ****** *)
//
implement
fprint_val<ir0val> = fprint_ir0val
//
(* ****** ****** *)
//
extern
fun
the_d2cstdef_search
(k0: d2cst): Option_vt(ir0val)
extern
fun
the_d2cstdef_insert
(d2c: d2cst, def: ir0val): void
//
extern
fun
the_d2vardef_search
(k0: d2var): Option_vt(ir0val)
extern
fun
the_d2vardef_insert
(d2v: d2var, def: ir0val): void
//
(* ****** ****** *)
//
datatype
d2key =
| D2Kcst of d2cst // let-fun
| D2Kvar of d2var // arg and let-var
//
(* ****** ****** *)

local
//
absimpl
ir0env_tbox =
List0(@(d2key, ir0val))
//
datavtype
intpenv =
| INTPENV of
  (int(*level*), intplst)
//
and
intplst =
| intplst_nil of ()
| intplst_fun of ()
//
| intplst_let1 of intplst
| intplst_try1 of intplst
(*
| intplst_loc1 of intplst
| intplst_loc2 of intplst
*)
//
| intplst_cons of
  (d2key, ir0val, intplst)
//
absimpl
intpenv_vtbox = intpenv
//
in(*in-of-local*)

implement
ir0env_make_nil
((*void*)) = list_nil()
implement
intpenv_make_nil
((*void*)) =
INTPENV(0, intplst_nil())

(* ****** ****** *)

fun
intplst_make_fenv
(kxs: ir0env): intplst =
(
auxlst
(kxs, intplst_fun())
) where
{
//
fun
auxlst
( kxs: ir0env
, env: intplst): intplst =
(
case+ kxs of
| list_nil() => env
| list_cons(kx0, kxs) =>
  (
  auxlst(kxs, env)
  ) where
  {
  val env =
  intplst_cons(kx0.0, kx0.1, env)
  }
) (* end of [auxlst] *)
//
} (* end of [intplst_make_fenv] *)

fun
intplst_take_fenv
(env: !intplst): ir0env =
(
list_vt2t
(
auxenv(env, list_vt_nil())
)
) where
{
vtypedef
res =
List0_vt(@(d2key, ir0val))
fun
auxenv
(env: !intplst, res: res): res =
(
case+ env of
//
| intplst_nil() => res
| intplst_fun() => res
//
| intplst_let1
    (env) => auxenv(env, res)
| intplst_try1
    (env) => auxenv(env, res)
//
(*
| intplst_loc1
    (env) => auxenv(env, res)
| intplst_loc2
    (env) => auxenv(env, res)
*)
//
| intplst_cons(k0, x0, env) =>
  (
    auxenv
    (env, list_vt_cons((k0, x0), res))
  )
)
} (* end of [intplst_take_env] *)

(* ****** ****** *)

implement
intpenv_make_fenv
  (kxs) =
INTPENV
(
1(*level*)
,
intplst_make_fenv(kxs)
)
//
implement
intpenv_take_fenv(env) =
(
  intplst_take_fenv(xs)
) where
{
  val+INTPENV(l0, xs) = env
}
//
(* ****** ****** *)

implement
intpenv_bind_fix
  (env0, irv0) =
let
val-
IR0Vfix
(fenv, d2v0, _, _) = irv0
in
(
  fold@(env0)
) where
{
val+
@INTPENV(l0, xs) = env0
val () =
(
  xs :=
  intplst_cons
  (D2Kvar(d2v0), irv0, xs)
)
} (* end of [where] *)
end // end of [intpenv_bind_fix]

implement
intpenv_bind_fixs
  (env0, irv0) =
(
  auxirdfs(env0, irdfs)
) where
{
//
val-
IR0Vfixs
( fenv
, d2v0, iras
, body, irdfs) = irv0
//
fun
auxirdfs
( env0
: !intpenv
, ires
: ir0explst): void =
(
case+ ires of
| list_nil
  ((*void*)) => ()
| list_cons
  (ire1, ires) =>
  (
    fold@(env0);
    auxirdfs(env0, ires)
  ) where
  {
  val+
  @INTPENV(l0, xs) = env0
  val () =
  (
    xs :=
    intplst_cons
    (D2Kvar(d2v1), irv1, xs)
  )
  } where
  {
  val-
  IR0Efix
  ( knd1, d2v1
  , iras, body) = ire1.node()
  val irv1 =
  IR0Vfixs
  (fenv, d2v1, iras, body, irdfs)
  }
) (* end of [auxirdfs] *)
//
} (* end of [intpenv_bind_fixs] *)

(* ****** ****** *)

implement
intpenv_pop0_let1
  (env0) =
(
  fold@(env0)
) where
{
//
fun
auxlst
( xs
: intplst): intplst =
(
case- xs of
| ~intplst_let1
   (xs) => xs
| ~intplst_cons
   (_, _, xs) => auxlst(xs)
)
//
val-
@INTPENV(l0, xs) = env0
val () = (xs := auxlst(xs))
} // end of [intpenv_push_let1] *)

implement
intpenv_push_let1
  (env0) =
(
  fold@(env0)
) where
{
val-
@INTPENV(l0, xs) = env0
val () =
(xs := intplst_let1(xs))
} // end of [intpenv_push_let1] *)

(* ****** ****** *)

implement
intpenv_pop0_try1
  (env0) =
(
  fold@(env0)
) where
{
//
fun
auxlst
( xs
: intplst): intplst =
(
case- xs of
| ~intplst_try1
   (xs) => xs
| ~intplst_let1
   (xs) => auxlst(xs)
| ~intplst_cons
   (_, _, xs) => auxlst(xs)
)
//
val-
@INTPENV(l0, xs) = env0
val () = (xs := auxlst(xs))
} // end of [intpenv_push_try1] *)

implement
intpenv_push_try1
  (env0) =
(
  fold@(env0)
) where
{
val-
@INTPENV(l0, xs) = env0
val () =
(xs := intplst_try1(xs))
} // end of [intpenv_push_try1] *)

(* ****** ****** *)

implement
intpenv_free_nil
  (env0) =
{
val-~intplst_nil() = xs
} where
{
val+~INTPENV(l0, xs) = env0
} (* intpenv_free_nil *)

(* ****** ****** *)
//
implement
intpenv_free_fenv
  (env) =
( auxlst(xs) ) where
{
//
fun
auxlst
(xs: intplst): void =
(
case- xs of
|
~intplst_fun() => ()
|
~intplst_let1(xs) => auxlst(xs)
|
~intplst_cons(_, _, xs) => auxlst(xs)
)
//
val+~INTPENV(l0, xs) = env
//
} (* end of [intpenv_free_fenv] *)
//
(* ****** ****** *)

implement
interp0_search_d2cst
  (env0, d2c0) =
  (auxlst(xs)) where
{
//
  vtypedef
  res = Option_vt(ir0val)
  val+INTPENV(l0, xs) = env0
//
  fun
  auxlst
  (xs: !intplst): res =
  (
  case+ xs of
  | intplst_nil() =>
    the_d2cstdef_search(d2c0)
  | intplst_fun() =>
    the_d2cstdef_search(d2c0)
//
  | intplst_let1(xs) => auxlst(xs)
  | intplst_try1(xs) => auxlst(xs)
//
(*
  | intplst_loc1(xs) => auxlst(xs)
  | intplst_loc2(xs) => auxlst(xs)
*)
  | intplst_cons
    (d2k1, irv1, xs) =>
    (
    case+ d2k1 of
    | D2Kcst(d2c1) =>
      if
      (d2c0 = d2c1)
      then Some_vt(irv1) else auxlst(xs)
    | D2Kvar(d2v1) => auxlst(xs)
    )
  ) (* end of [auxlst] *)
//
} (* end of [interp0_search_d2cst] *)

(* ****** ****** *)

implement
interp0_search_d2var
  (env0, d2v0) =
  (auxlst(xs)) where
{
//
  vtypedef
  res = Option_vt(ir0val)
  val+INTPENV(l0, xs) = env0
//
  fun
  auxlst
  (xs: !intplst): res =
  (
  case+ xs of
  | intplst_nil() =>
    the_d2vardef_search(d2v0)
  | intplst_fun() =>
    the_d2vardef_search(d2v0)
//
  | intplst_let1(xs) => auxlst(xs)
  | intplst_try1(xs) => auxlst(xs)
//
(*
  | intplst_loc1(xs) => auxlst(xs)
  | intplst_loc2(xs) => auxlst(xs)
*)
  | intplst_cons
    (d2k1, irv1, xs) =>
    (
    case+ d2k1 of
    | D2Kcst(d2c1) => auxlst(xs)
    | D2Kvar(d2v1) =>
      if
      (d2v0 = d2v1)
      then Some_vt(irv1) else auxlst(xs)
    )
  ) (* end of [auxlst] *)
//
} (* end of [interp0_search_d2var] *)

(* ****** ****** *)

implement
interp0_insert_d2cst
  (env0, d2c0, irv0) =
let
//
val+
@INTPENV(l0, xs) = env0
//
in
//
case xs of
|
intplst_nil() =>
(
fold@(env0);
the_d2cstdef_insert(d2c0, irv0)
)
|
_(*non-intplst_nil*) =>
(
fold@(env0)
) where
{
  val () =
  (
  xs :=
  intplst_cons(D2Kcst(d2c0), irv0, xs)
  )
} (* non-intplst_nil *)
//
end // end of [interp0_insert_d2cst]

(* ****** ****** *)

implement
interp0_insert_d2var
  (env0, d2v0, irv0) =
let
//
val+
@INTPENV(l0, xs) = env0
//
in
//
case xs of
|
intplst_nil() =>
(
fold@(env0);
the_d2vardef_insert(d2v0, irv0)
)
|
_(*non-intplst_nil*) =>
(
fold@(env0)
) where
{
  val () =
  (
  xs :=
  intplst_cons(D2Kvar(d2v0), irv0, xs)
  )
} (* non-intplst_nil *)
//
end // end of [interp0_insert_d2var]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)
//
// For
// some functions declared
// in prelude/SATS/bool.sats
//
(* ****** ****** *)

fun
bool_neg
(x: ir0val): ir0val =
let
val-
IR0Vbtf(x)=x in IR0Vbtf(not(x))
end // end of [bool_neg]

fun
bool_add
( x: ir0val
, y: ir0val): ir0val =
let
val-
IR0Vbtf(x) = x
val-
IR0Vbtf(y) = y in IR0Vbtf(x + y)
end // end of [bool_add]
fun
bool_mul
( x: ir0val
, y: ir0val): ir0val =
let
val-
IR0Vbtf(x) = x
val-
IR0Vbtf(y) = y in IR0Vbtf(x * y)
end // end of [bool_mul]

fun
bool_print
(x: ir0val): ir0val =
let
val-IR0Vbtf(x) = x in
let
val () = print(x) in IR0Vnil() end
end // end of [bool_print]

(* ****** ****** *)
//
// For
// some functions declared
// in prelude/SATS/char.sats
//
(* ****** ****** *)
//
fun
char_make_sint
(x: ir0val): ir0val =
let
val-IR0Vint(c) = x
in
  IR0Vchr(int2char0(c))
end // end of [char_make_sint]
//
fun
sint_make_char
(x: ir0val): ir0val =
let
val-IR0Vchr(c) = x
in
  IR0Vint(char2int0(c))
end // end of [sint_make_char]
//
(* ****** ****** *)

fun
char_eqzq
(x: ir0val): ir0val =
let
val-IR0Vchr(c) = x
in
  IR0Vbtf(char0_iseqz(c))
end // end of [char_eqzq]
fun
char_neqzq
(x: ir0val): ir0val =
let
val-IR0Vchr(c) = x
in
  IR0Vbtf(char0_isneqz(c))
end // end of [char_neqzq]
fun
char_print
(x: ir0val): ir0val =
let
val-IR0Vchr(x) = x in
let
val () = print(x) in IR0Vnil() end
end // end of [char_print]

fun
char_cmp
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vchr(x) = x
val-IR0Vchr(y) = y in IR0Vint(x - y) end
fun
char_equal
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vchr(x) = x
val-IR0Vchr(y) = y in IR0Vbtf(x = y) end
fun
char_noteq
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vchr(x) = x
val-IR0Vchr(y) = y in IR0Vbtf(x != y) end

(* ****** ****** *)
//
// For
// some functions declared
// in prelude/SATS/gint.sats
//
(* ****** ****** *)

fun
gint_print_sint
(x: ir0val): ir0val =
let
val-IR0Vint(x) = x in
let
val () = print(x) in IR0Vnil() end
end // end of [gint_print_sint]

(* ****** ****** *)
//
fun
gint_neg_sint
(x: ir0val): ir0val =
let
val-IR0Vint(x) = x in IR0Vint(~x) end
//
fun
gint_abs_sint
(x: ir0val): ir0val =
let
val-IR0Vint(x) = x in IR0Vint(abs(x))
end
//
(* ****** ****** *)
//
fun
gint_succ_sint
(x: ir0val): ir0val =
let
val-IR0Vint(x) = x in IR0Vint(x + 1) end
fun
gint_pred_sint
(x: ir0val): ir0val =
let
val-IR0Vint(x) = x in IR0Vint(x - 1) end
//
(* ****** ****** *)
//
fun
gint_lt_sint_sint
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vint(x) = x
val-IR0Vint(y) = y in IR0Vbtf(x < y) end
fun
gint_gt_sint_sint
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vint(x) = x
val-IR0Vint(y) = y in IR0Vbtf(x > y) end
//
fun
gint_eq_sint_sint
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vint(x) = x
val-IR0Vint(y) = y in IR0Vbtf(x = y) end
//
fun
gint_lte_sint_sint
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vint(x) = x
val-IR0Vint(y) = y in IR0Vbtf(x <= y) end
fun
gint_gte_sint_sint
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vint(x) = x
val-IR0Vint(y) = y in IR0Vbtf(x >= y) end
//
fun
gint_neq_sint_sint
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vint(x) = x
val-IR0Vint(y) = y in IR0Vbtf(x != y) end
//
(* ****** ****** *)
//
fun
gint_cmp_sint_sint
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vint(x) = x
val-IR0Vint(y) = y in IR0Vint(compare(x, y)) end
//
(* ****** ****** *)

fun
gint_add_sint_sint
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vint(x) = x
val-IR0Vint(y) = y in IR0Vint(x + y) end

fun
gint_sub_sint_sint
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vint(x) = x
val-IR0Vint(y) = y in IR0Vint(x - y) end

(* ****** ****** *)

fun
gint_mul_sint_sint
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vint(x) = x
val-IR0Vint(y) = y in IR0Vint(x * y) end

fun
gint_div_sint_sint
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vint(x) = x
val-IR0Vint(y) = y in IR0Vint(x / y) end

fun
gint_mod_sint_sint
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vint(x) = x
val-IR0Vint(y) = y in IR0Vint(x % y) end

(* ****** ****** *)
//
// For
// some functions declared
// in prelude/SATS/gflt.sats
//
(* ****** ****** *)
//
fun
gflt_i_dflt
(x: ir0val): ir0val =
let
val-IR0Vint(x) = x
in
IR0Vflt(g0int2float_int_double(x))
end
//
(* ****** ****** *)
//
fun
gflt_neg_dflt
(x: ir0val): ir0val =
let
val-IR0Vflt(x) = x in IR0Vflt(~x) end
//
fun
gflt_abs_dflt
(x: ir0val): ir0val =
let
val-IR0Vflt(x) = x in IR0Vflt(abs(x))
end
//
(* ****** ****** *)
//
fun
gflt_succ_dflt
(x: ir0val): ir0val =
let
val-IR0Vflt(x) = x in IR0Vflt(x + 1) end
fun
gflt_pred_dflt
(x: ir0val): ir0val =
let
val-IR0Vflt(x) = x in IR0Vflt(x - 1) end
//
(* ****** ****** *)
//
fun
gflt_lt_dflt_dflt
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vflt(x) = x
val-IR0Vflt(y) = y in IR0Vbtf(x < y) end
fun
gflt_gt_dflt_dflt
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vflt(x) = x
val-IR0Vflt(y) = y in IR0Vbtf(x > y) end
//
fun
gflt_eq_dflt_dflt
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vflt(x) = x
val-IR0Vflt(y) = y in IR0Vbtf(x = y) end
//
fun
gflt_lte_dflt_dflt
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vflt(x) = x
val-IR0Vflt(y) = y in IR0Vbtf(x <= y) end
fun
gflt_gte_dflt_dflt
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vflt(x) = x
val-IR0Vflt(y) = y in IR0Vbtf(x >= y) end
//
fun
gflt_neq_dflt_dflt
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vflt(x) = x
val-IR0Vflt(y) = y in IR0Vbtf(x != y) end
//
(* ****** ****** *)
//
fun
gflt_cmp_dflt_dflt
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vflt(x) = x
val-IR0Vflt(y) = y in IR0Vint(compare(x, y)) end
//
(* ****** ****** *)

fun
gflt_add_dflt_dflt
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vflt(x) = x
val-IR0Vflt(y) = y in IR0Vflt(x + y) end

fun
gflt_sub_dflt_dflt
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vflt(x) = x
val-IR0Vflt(y) = y in IR0Vflt(x - y) end

(* ****** ****** *)

fun
gflt_mul_dflt_dflt
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vflt(x) = x
val-IR0Vflt(y) = y in IR0Vflt(x * y) end

fun
gflt_div_dflt_dflt
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vflt(x) = x
val-IR0Vflt(y) = y in IR0Vflt(x / y) end

(*
fun
gflt_mod_dflt_dflt
( x: ir0val
, y: ir0val): ir0val =
let
val-IR0Vflt(x) = x
val-IR0Vflt(y) = y in IR0Vflt(x % y) end
*)

(* ****** ****** *)
//
// For
// some functions declared
// in prelude/SATS/string.sats
//
(* ****** ****** *)
//
fun
string_head_opt
(x: ir0val): ir0val =
let
val-IR0Vstr(x) = x
val p = string2ptr(x)
in
  IR0Vchr
  ($UN.ptr0_get<char>(p))
end // end of [string_head_opt]
fun
string_head_raw
(x: ir0val): ir0val =
let
val-IR0Vstr(x) = x
val p = string2ptr(x)
in
  IR0Vchr
  ($UN.ptr0_get<char>(p))
end // end of [string_head_raw]
fun
string_tail_raw
(x: ir0val): ir0val =
let
val-IR0Vstr(x) = x
val p = string2ptr(x)
in
IR0Vstr
($UN.cast(ptr0_succ<char>(p)))
end // end of [string_tail_raw]
//
fun
string_print
(x: ir0val): ir0val =
let
val-IR0Vstr(x) = x in
let
val () = print(x) in IR0Vnil() end
end // end of [ string_print ]
//
(* ****** ****** *)
//
fun
string_get_at
(x: ir0val
,i: ir0val): ir0val =
let
val-IR0Vstr(x) = x
val-IR0Vint(i) = i in
let
val p = string2ptr(x)
in
IR0Vchr($UN.ptr0_get_at<char>(p, i))
end
end // end of [ string_get_at ]
//
(* ****** ****** *)

fun
strptr_alloc
(x: ir0val): ir0val =
let
val-IR0Vint(x) = x in
let
val x0 =
g1ofg0(x)
val () =
assertloc(x0 >= 0)
val p0 =
$UN.castvwtp0{ptr}
(malloc_gc(i2sz(x0+1)))
val c0 = '\000'
val s0 = $UN.cast{string}(p0)
val () =
$UN.ptr0_set_at<char>(p0, x0, c0) in IR0Vstr(s0)
end
end // end of [strptr_alloc]
fun
strptr_set_at
( x: ir0val
, i: ir0val
, c: ir0val): ir0val =
let
val-IR0Vstr(x) = x
val-IR0Vint(i) = i
val-IR0Vchr(c) = c in
let
val p0 = $UN.cast{ptr}(x)
val () = $UN.ptr0_set_at<char>(p0, i, c) in IR0Vnil()
end
end // end of [strptr_set_at]

(* ****** ****** *)
//
fun
a0ptr_alloc
((*void*)): ir0val =
IR0Vptr
(
$UN.castvwtp0
(array_ptr_alloc<ir0val>(i2sz(1)))
)
//
fun
a0ref_get
(A: ir0val): ir0val =
let
val-
IR0Vptr(A) = A
in
  $UN.ptr0_get<ir0val>(A)
end
fun
a0ref_set
( A: ir0val
, x: ir0val): ir0val =
let
val-IR0Vptr(A) = A
in
IR0Vnil() where
{
val () = $UN.ptr0_set<ir0val>(A, x)
}
end
//
(* ****** ****** *)
//
fun
a1ptr_alloc
(n: ir0val): ir0val =
let
val-
IR0Vint(n) = n
val n = g1ofg0(n)
val () = assert(n >= 0)
in
IR0Vptr
(
$UN.castvwtp0
(
arrayptr_make_uninitized<ir0val>(i2sz(n))
)
)
end // end of [a1ptr_alloc]
//
fun
a1ref_head_raw
(A: ir0val): ir0val =
let
  val-IR0Vptr(A) = A
in
  $UN.ptr0_get<ir0val>(A)
end // end of [a1ref_head_raw]
fun
a1ref_tail_raw
(A: ir0val): ir0val =
let
  val-IR0Vptr(A) = A
in
  IR0Vptr(ptr_succ<ir0val>(A))
end // end of [a1ref_tail_raw]
//
fun
a1ref_get_at_raw
( A: ir0val
, i: ir0val): ir0val =
(
  a1ptr_get_at_raw(A, i)
)
and
a1ptr_get_at_raw
( A: ir0val
, i: ir0val): ir0val =
let
  val-IR0Vptr(A) = A
  val-IR0Vint(i) = i
in
  $UN.ptr0_get_at<ir0val>(A, i)
end // end of [a1ref_get_at_raw]
//
fun
a1ref_set_at_raw
( A: ir0val
, i: ir0val
, x: ir0val): ir0val =
(
  a1ptr_set_at_raw(A, i, x)
)
and
a1ptr_set_at_raw
( A: ir0val
, i: ir0val
, x: ir0val): ir0val =
let
  val-IR0Vptr(A) = A
  val-IR0Vint(i) = i
in
  IR0Vnil where
  {
  val () =
  $UN.ptr0_set_at<ir0val>(A, i, x)
  }
end // end of [a1ref_set_at_raw]
//
(* ****** ****** *)

local
//
#staload
STDIO =
"libats/libc/SATS/stdio.sats"
#staload
STDLIB =
"libats/libc/SATS/stdlib.sats"
//
in(*in-of-local*)
//
fun
g_stdin() =
IR0Vptr($UN.cast(stdin_ref))
fun
g_stdout() =
IR0Vptr($UN.cast(stdout_ref))
fun
g_stderr() =
IR0Vptr($UN.cast(stderr_ref))
//
fun
fgetc_ref
(fr: ir0val): ir0val =
let
val-IR0Vptr(fr) = fr
in
IR0Vint($STDIO.fgetc0($UN.cast(fr)))
end
//
fun
fputc_ref
( c0: ir0val
, fr: ir0val): ir0val =
let
val-IR0Vint(c0) = c0
val-IR0Vptr(fr) = fr
in
IR0Vint
($STDIO.fputc0_int(c0, $UN.cast(fr)))
end
//
(* ****** ****** *)
//
fun
rand_nint_limit
( x0 : ir0val ): ir0val  =
let
//
val-IR0Vint(x0) = x0
//
val x0 = g1ofg0(x0)
val () = assert(x0 > 0)
val r0 = $STDLIB.random()
//
val x0 = $UN.cast{uint}(x0)
val r0 = $UN.cast{uint}(r0)
//
in
IR0Vint
($UN.cast{int}(g0uint_mod_uint(r0, x0)))
end
//
end // end of [local]

(* ****** ****** *)

local
//
typedef key = d2cst
typedef itm = ir0val
//
#define D2CSTMAPSZ 1024
//
implement
hash_key<key>(k0) =
let
fun
fhash
( k0
: uint): ulint = hash_key<uint>(k0)
in
$effmask_all
(fhash($STM.stamp2uint(k0.stamp())))
end
implement
equal_key_key<key>(k1, k2) =
$effmask_all
(
$STM.eq_stamp_stamp(k1.stamp(), k2.stamp())
)
//
val
the_d2cstdef_map =
hashtbl_make_nil<key,itm>(i2sz(D2CSTMAPSZ))
//
in (*in-of-local*)

implement
interp0_fprint_d2cstmap
  (out) =
(
  fprint_hashtbl(out, the_d2cstdef_map)
)

(* ****** ****** *)

implement
the_d2cstdef_search
  (k0) =
hashtbl_search<key,itm>(the_d2cstdef_map, k0)

implement
the_d2cstdef_insert
  (k0, x0) =
{
//
(*
val () =
println!
("the_d2cstdef_insert: k0 = ", k0)
val () =
println!
("the_d2cstdef_insert: x0 = ", x0)
*)
//
val-
~None_vt() =
hashtbl_insert<key,itm>(the_d2cstdef_map, k0, x0)
} (* end of [the_d2cstdef_insert] *)

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

local
//
typedef key = d2var
typedef itm = ir0val
//
#define D2VARMAPSZ 1024
//
implement
hash_key<key>(k0) =
let
fun
fhash
( k0
: uint): ulint = hash_key<uint>(k0)
in
$effmask_all
(fhash($STM.stamp2uint(k0.stamp())))
end
implement
equal_key_key<key>(k1, k2) =
$effmask_all
(
$STM.eq_stamp_stamp(k1.stamp(), k2.stamp())
)
//
val
the_d2vardef_map =
hashtbl_make_nil<key,itm>(i2sz(D2VARMAPSZ))
//
in (*in-of-local*)

implement
interp0_fprint_d2varmap
  (out) =
(
  fprint_hashtbl(out, the_d2vardef_map)
)

(* ****** ****** *)

implement
the_d2vardef_search
  (k0) =
hashtbl_search<key,itm>(the_d2vardef_map, k0)

implement
the_d2vardef_insert
  (k0, x0) =
{
val-
~None_vt() =
hashtbl_insert<key,itm>(the_d2vardef_map, k0, x0)
} (* end of [the_d2vardef_insert] *)

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

local

val
the_flag = ref<int>(0)

in

implement
interp0_initize() =
let
val n0 = the_flag[]
val () = the_flag[] := n0+1
in
if
(n0 = 0)
then
{
val () = interp0_initize_gint()
}
end // end of [interp0_initize]

end // end of [local]

(* ****** ****** *)

local

fun
firfun0
(
f0: () -> ir0val
)
: ir0valist -<cloref1> ir0val =
lam(vs) =>
let
val-list_nil() = vs in f0((*void*))
end

fun
firfun1
(
f1:
(ir0val) -> ir0val
)
: ir0valist -<cloref1> ir0val =
lam(vs) =>
let
val-list_cons(v1, vs) = vs in f1(v1)
end

fun
firfun2
(
f2:
( ir0val
, ir0val) -> ir0val
)
: ir0valist -<cloref1> ir0val =
lam(vs) =>
let
val-list_cons(v1, vs) = vs
val-list_cons(v2, vs) = vs in f2(v1, v2)
end

fun
firfun3
(
f3:
( ir0val
, ir0val
, ir0val) -> ir0val
)
: ir0valist -<cloref1> ir0val =
lam(vs) =>
let
val-list_cons(v1, vs) = vs
val-list_cons(v2, vs) = vs
val-list_cons(v3, vs) = vs in f3(v1, v2, v3)
end

fun
d2cst
(nam: string): d2cst =
(
let
//
// (*
val () =
println!
("d2cst: nam = ", nam)
// *)
//
val
sym = $SYM.symbol_make(nam)
val
opt = $T12.the_dexpenv_find(sym)
//
in
//
case- opt of
|
~Some_vt(d2i) =>
(
case- d2i of
| $D2E.D2ITMcst(d2cs) =>
  let
  val-list_cons(d2c0, _) = d2cs in d2c0
  end (* end of [D2ITMcst] *)
)
//
end // end of [let]
) (* end of [d2cst] *)

in(*in-of-local*)

(* ****** ****** *)

local

val
the_flag = ref<int>(0)

in(*in-of-local*)

implement
interp0_initize_gint() =
let
val n0 = the_flag[]
val () = the_flag[] := n0+1
in
//
if
(n0 = 0)
then
{
//
(* ****** ****** *)
//
// For
// some functions declared
// in prelude/SATS/bool.sats
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst("xint_bool_neg")
,
IR0Vfun(firfun1(bool_neg)))
val () =
the_d2cstdef_insert
(
d2cst("xint_bool_add")
,
IR0Vfun(firfun2(bool_add)))
val () =
the_d2cstdef_insert
(
d2cst("xint_bool_mul")
,
IR0Vfun(firfun2(bool_mul)))
val () =
the_d2cstdef_insert
(
d2cst("xint_bool_print")
,
IR0Vfun(firfun1(bool_print)))
//
(* ****** ****** *)
//
// For
// some functions declared
// in prelude/SATS/char.sats
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_char_make_sint"),
IR0Vfun
(firfun1(char_make_sint)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_sint_make_char"),
IR0Vfun
(firfun1(sint_make_char)))
//
val () =
the_d2cstdef_insert
(
d2cst("xint_char_eqzq"),
IR0Vfun(firfun1(char_eqzq)))
val () =
the_d2cstdef_insert
(
d2cst("xint_char_neqzq"),
IR0Vfun(firfun1(char_neqzq)))
//
val () =
the_d2cstdef_insert
(
d2cst("xint_char_cmp")
,
IR0Vfun(firfun2(char_cmp)))
val () =
the_d2cstdef_insert
(
d2cst("xint_char_equal")
,
IR0Vfun(firfun2(char_equal)))
val () =
the_d2cstdef_insert
(
d2cst("xint_char_noteq")
,
IR0Vfun(firfun2(char_noteq)))
//
val () =
the_d2cstdef_insert
(
d2cst("xint_char_print")
,
IR0Vfun(firfun1(char_print)))
//
(* ****** ****** *)
//
// For
// some functions declared
// in prelude/SATS/gint.sats
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_print_sint")
,
IR0Vfun
(firfun1(gint_print_sint)))
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_neg_sint")
,
IR0Vfun
(firfun1(gint_neg_sint)))
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_abs_sint")
,
IR0Vfun
(firfun1(gint_abs_sint)))
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_succ_sint")
,
IR0Vfun
(firfun1(gint_succ_sint)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_pred_sint")
,
IR0Vfun
(firfun1(gint_pred_sint)))
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_lt_sint_sint")
,
IR0Vfun
(firfun2(gint_lt_sint_sint)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_gt_sint_sint")
,
IR0Vfun
(firfun2(gint_gt_sint_sint)))
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_eq_sint_sint")
,
IR0Vfun
(firfun2(gint_eq_sint_sint)))
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_lte_sint_sint")
,
IR0Vfun
(firfun2(gint_lte_sint_sint)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_gte_sint_sint")
,
IR0Vfun
(firfun2(gint_gte_sint_sint)))
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_neq_sint_sint")
,
IR0Vfun
(firfun2(gint_neq_sint_sint)))
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_cmp_sint_sint")
,
IR0Vfun
(firfun2(gint_cmp_sint_sint)))
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_add_sint_sint")
,
IR0Vfun
(firfun2(gint_add_sint_sint)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_sub_sint_sint")
,
IR0Vfun
(firfun2(gint_sub_sint_sint)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_mul_sint_sint")
,
IR0Vfun
(firfun2(gint_mul_sint_sint)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_div_sint_sint")
,
IR0Vfun
(firfun2(gint_div_sint_sint)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_gint_mod_sint_sint")
,
IR0Vfun
(firfun2(gint_mod_sint_sint)))
//
(* ****** ****** *)
//
// For
// some functions declared
// in prelude/SATS/gflt.sats
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_i_dflt")
,
IR0Vfun
(firfun1(gflt_i_dflt)))
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_neg_dflt")
,
IR0Vfun
(firfun1(gflt_neg_dflt)))
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_abs_dflt")
,
IR0Vfun
(firfun1(gflt_abs_dflt)))
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_succ_dflt")
,
IR0Vfun
(firfun1(gflt_succ_dflt)))
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_pred_dflt")
,
IR0Vfun
(firfun1(gflt_pred_dflt)))
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_lt_dflt_dflt")
,
IR0Vfun
(firfun2(gflt_lt_dflt_dflt)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_gt_dflt_dflt")
,
IR0Vfun
(firfun2(gflt_gt_dflt_dflt)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_eq_dflt_dflt")
,
IR0Vfun
(firfun2(gflt_eq_dflt_dflt)))
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_lte_dflt_dflt")
,
IR0Vfun
(firfun2(gflt_lte_dflt_dflt)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_gte_dflt_dflt")
,
IR0Vfun
(firfun2(gflt_gte_dflt_dflt)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_neq_dflt_dflt")
,
IR0Vfun
(firfun2(gflt_neq_dflt_dflt)))
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_cmp_dflt_dflt")
,
IR0Vfun
(firfun2(gflt_cmp_dflt_dflt)))
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_add_dflt_dflt")
,
IR0Vfun
(firfun2(gflt_add_dflt_dflt)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_sub_dflt_dflt")
,
IR0Vfun
(firfun2(gflt_sub_dflt_dflt)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_mul_dflt_dflt")
,
IR0Vfun
(firfun2(gflt_mul_dflt_dflt)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_div_dflt_dflt")
,
IR0Vfun
(firfun2(gflt_div_dflt_dflt)))
(*
val () =
the_d2cstdef_insert
(
d2cst
("xint_gflt_mod_dflt_dflt")
,
IR0Vfun
(firfun2(gflt_mod_dflt_dflt)))
*)
//
(* ****** ****** *)
//
// For
// some functions declared
// in prelude/SATS/string.sats
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_string_head_opt"),
IR0Vfun
(firfun1(string_head_opt)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_string_head_raw"),
IR0Vfun
(firfun1(string_head_raw)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_string_tail_raw"),
IR0Vfun
(firfun1(string_tail_raw)))
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_string_print"),
IR0Vfun(firfun1(string_print)))
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_string_get_at"),
IR0Vfun(firfun2(string_get_at)))
//
(* ****** ****** *)

val () =
the_d2cstdef_insert
(
d2cst
("xint_strptr_alloc"),
IR0Vfun
(firfun1(strptr_alloc)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_strptr_set_at"),
IR0Vfun
(firfun3(strptr_set_at)))

(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_a0ptr_alloc")
,
IR0Vfun
(firfun0(a0ptr_alloc)))
//
val () =
the_d2cstdef_insert
(
d2cst("xint_a0ref_get")
,
IR0Vfun
( firfun1(a0ref_get)) )
val () =
the_d2cstdef_insert
(
d2cst("xint_a0ref_set")
,
IR0Vfun
( firfun2(a0ref_set)) )
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_a1ptr_alloc")
,
IR0Vfun
(firfun1(a1ptr_alloc)))
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_a1ref_head_raw")
,
IR0Vfun
(firfun1(a1ref_head_raw)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_a1ref_tail_raw")
,
IR0Vfun
(firfun1(a1ref_tail_raw)))
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_a1ref_get_at_raw")
,
IR0Vfun
(firfun2(a1ref_get_at_raw)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_a1ptr_get_at_raw")
,
IR0Vfun
(firfun2(a1ptr_get_at_raw)))
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_a1ref_set_at_raw")
,
IR0Vfun
(firfun3(a1ref_set_at_raw)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_a1ptr_set_at_raw")
,
IR0Vfun
(firfun3(a1ptr_set_at_raw)))
//
(* ****** ****** *)
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_g_stdin")
,
IR0Vfun(firfun0(g_stdin)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_g_stdout")
,
IR0Vfun(firfun0(g_stdout)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_g_stderr")
,
IR0Vfun(firfun0(g_stderr)))
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_fgetc_ref")
,
IR0Vfun(firfun1(fgetc_ref)))
val () =
the_d2cstdef_insert
(
d2cst
("xint_fputc_ref")
,
IR0Vfun(firfun2(fputc_ref)))
//
val () =
the_d2cstdef_insert
(
d2cst
("xint_rand_nint_limit")
,
IR0Vfun(firfun1(rand_nint_limit)))
//
} (* end of [then] *) 
//
end (* end of [interp0_initize_gint] *)

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

(* end of [xint_interp0_envmap.dats] *)
