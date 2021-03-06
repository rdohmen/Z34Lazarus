unit z3_algebraic;
{ This unit is automatically generated by Chet:
  https://github.com/neslib/Chet }



interface

uses z3;

(**
       \brief Return \c true if \c a can be used as value in the Z3 real algebraic
       number package.

       def_API('Z3_algebraic_is_value', BOOL, (_in(CONTEXT), _in(AST)))
 *)
function Z3_algebraic_is_value(c: Z3_context; a: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_algebraic_is_value';

(**
       \brief Return \c true if \c a is positive, and \c false otherwise.

       \pre Z3_algebraic_is_value(c, a)

       def_API('Z3_algebraic_is_pos', BOOL, (_in(CONTEXT), _in(AST)))
 *)
function Z3_algebraic_is_pos(c: Z3_context; a: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_algebraic_is_pos';


(**
       \brief Return \c true if \c a is negative, and \c false otherwise.

       \pre Z3_algebraic_is_value(c, a)

       def_API('Z3_algebraic_is_neg', BOOL, (_in(CONTEXT), _in(AST)))
 *)
function Z3_algebraic_is_neg(c: Z3_context; a: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_algebraic_is_neg';

(**
       \brief Return \c true if \c a is zero, and \c false otherwise.

       \pre Z3_algebraic_is_value(c, a)

       def_API('Z3_algebraic_is_zero', BOOL, (_in(CONTEXT), _in(AST)))
 *)
function Z3_algebraic_is_zero(c: Z3_context; a: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_algebraic_is_zero';

(**
       \brief Return 1 if \c a is positive, 0 if \c a is zero, and -1 if \c a is negative.

       \pre Z3_algebraic_is_value(c, a)

       def_API('Z3_algebraic_sign', INT, (_in(CONTEXT), _in(AST)))
 *)
function Z3_algebraic_sign(c: Z3_context; a: Z3_ast): Integer; cdecl;
  external z3_dll name  'Z3_algebraic_sign';

(**
       \brief Return the value a + b.

       \pre Z3_algebraic_is_value(c, a)
       \pre Z3_algebraic_is_value(c, b)
       \post Z3_algebraic_is_value(c, result)

       def_API('Z3_algebraic_add', AST, (_in(CONTEXT), _in(AST), _in(AST)))
 *)
function Z3_algebraic_add(c: Z3_context; a: Z3_ast; b: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_algebraic_add';

(**
       \brief Return the value a - b.

       \pre Z3_algebraic_is_value(c, a)
       \pre Z3_algebraic_is_value(c, b)
       \post Z3_algebraic_is_value(c, result)

       def_API('Z3_algebraic_sub', AST, (_in(CONTEXT), _in(AST), _in(AST)))
 *)
function Z3_algebraic_sub(c: Z3_context; a: Z3_ast; b: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_algebraic_sub';

(**
       \brief Return the value a * b.

       \pre Z3_algebraic_is_value(c, a)
       \pre Z3_algebraic_is_value(c, b)
       \post Z3_algebraic_is_value(c, result)

       def_API('Z3_algebraic_mul', AST, (_in(CONTEXT), _in(AST), _in(AST)))
 *)
function Z3_algebraic_mul(c: Z3_context; a: Z3_ast; b: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_algebraic_mul';

(**
       \brief Return the value a / b.

       \pre Z3_algebraic_is_value(c, a)
       \pre Z3_algebraic_is_value(c, b)
       \pre !Z3_algebraic_is_zero(c, b)
       \post Z3_algebraic_is_value(c, result)

       def_API('Z3_algebraic_div', AST, (_in(CONTEXT), _in(AST), _in(AST)))
 *)
function Z3_algebraic_div(c: Z3_context; a: Z3_ast; b: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_algebraic_div';

(**
       \brief Return the a^(1/k)

       \pre Z3_algebraic_is_value(c, a)
       \pre k is even => !Z3_algebraic_is_neg(c, a)
       \post Z3_algebraic_is_value(c, result)

       def_API('Z3_algebraic_root', AST, (_in(CONTEXT), _in(AST), _in(UINT)))
 *)
function Z3_algebraic_root(c: Z3_context; a: Z3_ast; k: Cardinal): Z3_ast; cdecl;
  external z3_dll name  'Z3_algebraic_root';

(**
       \brief Return the a^k

       \pre Z3_algebraic_is_value(c, a)
       \post Z3_algebraic_is_value(c, result)

       def_API('Z3_algebraic_power', AST, (_in(CONTEXT), _in(AST), _in(UINT)))
 *)
function Z3_algebraic_power(c: Z3_context; a: Z3_ast; k: Cardinal): Z3_ast; cdecl;
  external z3_dll name  'Z3_algebraic_power';

(**
       \brief Return \c true if a < b, and \c false otherwise.

       \pre Z3_algebraic_is_value(c, a)
       \pre Z3_algebraic_is_value(c, b)

       def_API('Z3_algebraic_lt', BOOL, (_in(CONTEXT), _in(AST), _in(AST)))
 *)
function Z3_algebraic_lt(c: Z3_context; a: Z3_ast; b: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_algebraic_lt';

(**
       \brief Return \c true if a > b, and \c false otherwise.

       \pre Z3_algebraic_is_value(c, a)
       \pre Z3_algebraic_is_value(c, b)

       def_API('Z3_algebraic_gt', BOOL, (_in(CONTEXT), _in(AST), _in(AST)))
 *)
function Z3_algebraic_gt(c: Z3_context; a: Z3_ast; b: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_algebraic_gt';

(**
       \brief Return \c true if a <= b, and \c false otherwise.

       \pre Z3_algebraic_is_value(c, a)
       \pre Z3_algebraic_is_value(c, b)

       def_API('Z3_algebraic_le', BOOL, (_in(CONTEXT), _in(AST), _in(AST)))
 *)
function Z3_algebraic_le(c: Z3_context; a: Z3_ast; b: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_algebraic_le';

(**
       \brief Return \c true if a >= b, and \c false otherwise.

       \pre Z3_algebraic_is_value(c, a)
       \pre Z3_algebraic_is_value(c, b)

       def_API('Z3_algebraic_ge', BOOL, (_in(CONTEXT), _in(AST), _in(AST)))
 *)
function Z3_algebraic_ge(c: Z3_context; a: Z3_ast; b: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_algebraic_ge';

(**
       \brief Return \c true if a == b, and \c false otherwise.

       \pre Z3_algebraic_is_value(c, a)
       \pre Z3_algebraic_is_value(c, b)

       def_API('Z3_algebraic_eq', BOOL, (_in(CONTEXT), _in(AST), _in(AST)))
 *)
function Z3_algebraic_eq(c: Z3_context; a: Z3_ast; b: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_algebraic_eq';

(**
       \brief Return \c true if a != b, and \c false otherwise.

       \pre Z3_algebraic_is_value(c, a)
       \pre Z3_algebraic_is_value(c, b)

       def_API('Z3_algebraic_neq', BOOL, (_in(CONTEXT), _in(AST), _in(AST)))
 *)
function Z3_algebraic_neq(c: Z3_context; a: Z3_ast; b: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_algebraic_neq';

(**
       \brief Given a multivariate polynomial p(x_0, ..., x_{n-1}, x_n), returns the
       roots of the univariate polynomial p(a[0], ..., a[n-1], x_n).

       \pre p is a Z3 expression that contains only arithmetic terms and free variables.
       \pre forall i in [0, n) Z3_algebraic_is_value(c, a[i])
       \post forall r in result Z3_algebraic_is_value(c, result)

       def_API('Z3_algebraic_roots', AST_VECTOR, (_in(CONTEXT), _in(AST), _in(UINT), _in_array(2, AST)))
 *)
function Z3_algebraic_roots(c: Z3_context; p: Z3_ast; n: Cardinal; a: PZ3_ast): Z3_ast_vector; cdecl;
  external z3_dll name  'Z3_algebraic_roots';

(**
       \brief Given a multivariate polynomial p(x_0, ..., x_{n-1}), return the
       sign of p(a[0], ..., a[n-1]).

       \pre p is a Z3 expression that contains only arithmetic terms and free variables.
       \pre forall i in [0, n) Z3_algebraic_is_value(c, a[i])

       def_API('Z3_algebraic_eval', INT, (_in(CONTEXT), _in(AST), _in(UINT), _in_array(2, AST)))
 *)
function Z3_algebraic_eval(c: Z3_context; p: Z3_ast; n: Cardinal; a: PZ3_ast): Integer; cdecl;
  external z3_dll name  'Z3_algebraic_eval';

implementation

end.
