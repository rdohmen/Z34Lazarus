unit z3_fpa;
{ This unit is automatically generated by Chet:
  https://github.com/neslib/Chet }

interface

uses z3;

(**
        \brief Create the RoundingMode sort.

        \param c logical context

        def_API('Z3_mk_fpa_rounding_mode_sort', SORT, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_rounding_mode_sort(c: Z3_context): Z3_sort; cdecl;
  external z3_dll name  'Z3_mk_fpa_rounding_mode_sort';

(**
        \brief Create a numeral of RoundingMode sort which represents the NearestTiesToEven rounding mode.

        \param c logical context

        def_API('Z3_mk_fpa_round_nearest_ties_to_even', AST, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_round_nearest_ties_to_even(c: Z3_context): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_round_nearest_ties_to_even';

(**
        \brief Create a numeral of RoundingMode sort which represents the NearestTiesToEven rounding mode.

        \param c logical context

        def_API('Z3_mk_fpa_rne', AST, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_rne(c: Z3_context): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_rne';

(**
        \brief Create a numeral of RoundingMode sort which represents the NearestTiesToAway rounding mode.

        \param c logical context

        def_API('Z3_mk_fpa_round_nearest_ties_to_away', AST, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_round_nearest_ties_to_away(c: Z3_context): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_round_nearest_ties_to_away';

(**
        \brief Create a numeral of RoundingMode sort which represents the NearestTiesToAway rounding mode.

        \param c logical context

        def_API('Z3_mk_fpa_rna', AST, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_rna(c: Z3_context): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_rna';

(**
        \brief Create a numeral of RoundingMode sort which represents the TowardPositive rounding mode.

        \param c logical context

        def_API('Z3_mk_fpa_round_toward_positive', AST, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_round_toward_positive(c: Z3_context): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_round_toward_positive';

(**
        \brief Create a numeral of RoundingMode sort which represents the TowardPositive rounding mode.

        \param c logical context

        def_API('Z3_mk_fpa_rtp', AST, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_rtp(c: Z3_context): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_rtp';

(**
        \brief Create a numeral of RoundingMode sort which represents the TowardNegative rounding mode.

        \param c logical context

        def_API('Z3_mk_fpa_round_toward_negative', AST, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_round_toward_negative(c: Z3_context): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_round_toward_negative';

(**
        \brief Create a numeral of RoundingMode sort which represents the TowardNegative rounding mode.

        \param c logical context

        def_API('Z3_mk_fpa_rtn', AST, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_rtn(c: Z3_context): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_rtn';

(**
        \brief Create a numeral of RoundingMode sort which represents the TowardZero rounding mode.

        \param c logical context

        def_API('Z3_mk_fpa_round_toward_zero', AST, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_round_toward_zero(c: Z3_context): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_round_toward_zero';

(**
        \brief Create a numeral of RoundingMode sort which represents the TowardZero rounding mode.

        \param c logical context

        def_API('Z3_mk_fpa_rtz', AST, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_rtz(c: Z3_context): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_rtz';

(**
        \brief Create a FloatingPoint sort.

        \param c logical context
        \param ebits number of exponent bits
        \param sbits number of significand bits

        \remark \c ebits must be larger than 1 and \c sbits must be larger than 2.

        def_API('Z3_mk_fpa_sort', SORT, (_in(CONTEXT), _in(UINT), _in(UINT)))
 *)
function Z3_mk_fpa_sort(c: Z3_context; ebits: Cardinal; sbits: Cardinal): Z3_sort; cdecl;
  external z3_dll name  'Z3_mk_fpa_sort';

(**
        \brief Create the half-precision (16-bit) FloatingPoint sort.

        \param c logical context

        def_API('Z3_mk_fpa_sort_half', SORT, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_sort_half(c: Z3_context): Z3_sort; cdecl;
  external z3_dll name  'Z3_mk_fpa_sort_half';

(**
        \brief Create the half-precision (16-bit) FloatingPoint sort.

        \param c logical context

        def_API('Z3_mk_fpa_sort_16', SORT, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_sort_16(c: Z3_context): Z3_sort; cdecl;
  external z3_dll name  'Z3_mk_fpa_sort_16';

(**
        \brief Create the single-precision (32-bit) FloatingPoint sort.

        \param c logical context.

        def_API('Z3_mk_fpa_sort_single', SORT, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_sort_single(c: Z3_context): Z3_sort; cdecl;
  external z3_dll name  'Z3_mk_fpa_sort_single';

(**
        \brief Create the single-precision (32-bit) FloatingPoint sort.

        \param c logical context

        def_API('Z3_mk_fpa_sort_32', SORT, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_sort_32(c: Z3_context): Z3_sort; cdecl;
  external z3_dll name  'Z3_mk_fpa_sort_32';

(**
        \brief Create the double-precision (64-bit) FloatingPoint sort.

        \param c logical context

        def_API('Z3_mk_fpa_sort_double', SORT, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_sort_double(c: Z3_context): Z3_sort; cdecl;
  external z3_dll name  'Z3_mk_fpa_sort_double';

(**
        \brief Create the double-precision (64-bit) FloatingPoint sort.

        \param c logical context

        def_API('Z3_mk_fpa_sort_64', SORT, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_sort_64(c: Z3_context): Z3_sort; cdecl;
  external z3_dll name  'Z3_mk_fpa_sort_64';

(**
        \brief Create the quadruple-precision (128-bit) FloatingPoint sort.

        \param c logical context

        def_API('Z3_mk_fpa_sort_quadruple', SORT, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_sort_quadruple(c: Z3_context): Z3_sort; cdecl;
  external z3_dll name  'Z3_mk_fpa_sort_quadruple';

(**
        \brief Create the quadruple-precision (128-bit) FloatingPoint sort.

        \param c logical context

        def_API('Z3_mk_fpa_sort_128', SORT, (_in(CONTEXT),))
 *)
function Z3_mk_fpa_sort_128(c: Z3_context): Z3_sort; cdecl;
  external z3_dll name  'Z3_mk_fpa_sort_128';

(**
        \brief Create a floating-point NaN of sort \c s.

        \param c logical context
        \param s target sort

        def_API('Z3_mk_fpa_nan', AST, (_in(CONTEXT),_in(SORT)))
 *)
function Z3_mk_fpa_nan(c: Z3_context; s: Z3_sort): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_nan';

(**
        \brief Create a floating-point infinity of sort \c s.

        \param c logical context
        \param s target sort
        \param negative indicates whether the result should be negative

        When \c negative is \c true, -oo will be generated instead of +oo.

        def_API('Z3_mk_fpa_inf', AST, (_in(CONTEXT),_in(SORT),_in(BOOL)))
 *)
function Z3_mk_fpa_inf(c: Z3_context; s: Z3_sort; negative: Boolean): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_inf';

(**
        \brief Create a floating-point zero of sort \c s.

        \param c logical context
        \param s target sort
        \param negative indicates whether the result should be negative

        When \c negative is \c true, -zero will be generated instead of +zero.

        def_API('Z3_mk_fpa_zero', AST, (_in(CONTEXT),_in(SORT),_in(BOOL)))
 *)
function Z3_mk_fpa_zero(c: Z3_context; s: Z3_sort; negative: Boolean): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_zero';

(**
        \brief Create an expression of FloatingPoint sort from three bit-vector expressions.

        This is the operator named `fp' in the SMT FP theory definition.
        Note that \c sgn is required to be a bit-vector of size 1. Significand and exponent
        are required to be longer than 1 and 2 respectively. The FloatingPoint sort
        of the resulting expression is automatically determined from the bit-vector sizes
        of the arguments. The exponent is assumed to be in IEEE-754 biased representation.

        \param c logical context
        \param sgn sign
        \param exp exponent
        \param sig significand

        def_API('Z3_mk_fpa_fp', AST, (_in(CONTEXT), _in(AST), _in(AST), _in(AST)))
 *)
function Z3_mk_fpa_fp(c: Z3_context; sgn: Z3_ast; exp: Z3_ast; sig: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_fp';

(**
        \brief Create a numeral of FloatingPoint sort from a float.

        This function is used to create numerals that fit in a float value.
        It is slightly faster than #Z3_mk_numeral since it is not necessary to parse a string.

        \param c logical context
        \param v value
        \param ty sort

        \c ty must be a FloatingPoint sort

        \sa Z3_mk_numeral

        def_API('Z3_mk_fpa_numeral_float', AST, (_in(CONTEXT), _in(FLOAT), _in(SORT)))
 *)
function Z3_mk_fpa_numeral_float(c: Z3_context; v: Single; ty: Z3_sort): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_numeral_float';

(**
        \brief Create a numeral of FloatingPoint sort from a double.

        This function is used to create numerals that fit in a double value.
        It is slightly faster than #Z3_mk_numeral since it is not necessary to parse a string.

        \param c logical context
        \param v value
        \param ty sort

        \c ty must be a FloatingPoint sort

        \sa Z3_mk_numeral

        def_API('Z3_mk_fpa_numeral_double', AST, (_in(CONTEXT), _in(DOUBLE), _in(SORT)))
 *)
function Z3_mk_fpa_numeral_double(c: Z3_context; v: Double; ty: Z3_sort): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_numeral_double';

(**
        \brief Create a numeral of FloatingPoint sort from a signed integer.

        \param c logical context
        \param v value
        \param ty result sort

        \c ty must be a FloatingPoint sort

        \sa Z3_mk_numeral

        def_API('Z3_mk_fpa_numeral_int', AST, (_in(CONTEXT), _in(INT), _in(SORT)))
 *)
function Z3_mk_fpa_numeral_int(c: Z3_context; v: Integer; ty: Z3_sort): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_numeral_int';

(**
        \brief Create a numeral of FloatingPoint sort from a sign bit and two integers.

        \param c logical context
        \param sgn sign bit (true == negative)
        \param sig significand
        \param exp exponent
        \param ty result sort

        \c ty must be a FloatingPoint sort

        \sa Z3_mk_numeral

        def_API('Z3_mk_fpa_numeral_int_uint', AST, (_in(CONTEXT), _in(BOOL), _in(INT), _in(UINT), _in(SORT)))
 *)
function Z3_mk_fpa_numeral_int_uint(c: Z3_context; sgn: Boolean; exp: Integer; sig: Cardinal; ty: Z3_sort): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_numeral_int_uint';

(**
        \brief Create a numeral of FloatingPoint sort from a sign bit and two 64-bit integers.

        \param c logical context
        \param sgn sign bit (true == negative)
        \param sig significand
        \param exp exponent
        \param ty result sort

        \c ty must be a FloatingPoint sort

        \sa Z3_mk_numeral

        def_API('Z3_mk_fpa_numeral_int64_uint64', AST, (_in(CONTEXT), _in(BOOL), _in(INT64), _in(UINT64), _in(SORT)))
 *)
function Z3_mk_fpa_numeral_int64_uint64(c: Z3_context; sgn: Boolean; exp: Int64; sig: UInt64; ty: Z3_sort): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_numeral_int64_uint64';

(**
        \brief Floating-point absolute value

        \param c logical context
        \param t term of FloatingPoint sort

        def_API('Z3_mk_fpa_abs', AST, (_in(CONTEXT),_in(AST)))
 *)
function Z3_mk_fpa_abs(c: Z3_context; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_abs';

(**
        \brief Floating-point negation

        \param c logical context
        \param t term of FloatingPoint sort

        def_API('Z3_mk_fpa_neg', AST, (_in(CONTEXT),_in(AST)))
 *)
function Z3_mk_fpa_neg(c: Z3_context; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_neg';

(**
        \brief Floating-point addition

        \param c logical context
        \param rm term of RoundingMode sort
        \param t1 term of FloatingPoint sort
        \param t2 term of FloatingPoint sort

        \c rm must be of RoundingMode sort, \c t1 and \c t2 must have the same FloatingPoint sort.

        def_API('Z3_mk_fpa_add', AST, (_in(CONTEXT),_in(AST),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_add(c: Z3_context; rm: Z3_ast; t1: Z3_ast; t2: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_add';

(**
        \brief Floating-point subtraction

        \param c logical context
        \param rm term of RoundingMode sort
        \param t1 term of FloatingPoint sort
        \param t2 term of FloatingPoint sort

        \c rm must be of RoundingMode sort, \c t1 and \c t2 must have the same FloatingPoint sort.

        def_API('Z3_mk_fpa_sub', AST, (_in(CONTEXT),_in(AST),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_sub(c: Z3_context; rm: Z3_ast; t1: Z3_ast; t2: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_sub';

(**
        \brief Floating-point multiplication

        \param c logical context
        \param rm term of RoundingMode sort
        \param t1 term of FloatingPoint sort
        \param t2 term of FloatingPoint sort

        \c rm must be of RoundingMode sort, \c t1 and \c t2 must have the same FloatingPoint sort.

        def_API('Z3_mk_fpa_mul', AST, (_in(CONTEXT),_in(AST),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_mul(c: Z3_context; rm: Z3_ast; t1: Z3_ast; t2: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_mul';

(**
        \brief Floating-point division

        \param c logical context
        \param rm term of RoundingMode sort
        \param t1 term of FloatingPoint sort.
        \param t2 term of FloatingPoint sort

        The nodes \c rm must be of RoundingMode sort, \c t1 and \c t2 must have the same FloatingPoint sort.

        def_API('Z3_mk_fpa_div', AST, (_in(CONTEXT),_in(AST),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_div(c: Z3_context; rm: Z3_ast; t1: Z3_ast; t2: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_div';

(**
        \brief Floating-point fused multiply-add.

        \param c logical context
        \param rm term of RoundingMode sort
        \param t1 term of FloatingPoint sort
        \param t2 term of FloatingPoint sort
        \param t3 term of FloatingPoint sort

        The result is \ccode{round((t1 * t2) + t3)}.

        \c rm must be of RoundingMode sort, \c t1, \c t2, and \c t3 must have the same FloatingPoint sort.

        def_API('Z3_mk_fpa_fma', AST, (_in(CONTEXT),_in(AST),_in(AST),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_fma(c: Z3_context; rm: Z3_ast; t1: Z3_ast; t2: Z3_ast; t3: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_fma';

(**
        \brief Floating-point square root

        \param c logical context
        \param rm term of RoundingMode sort
        \param t term of FloatingPoint sort

        \c rm must be of RoundingMode sort, \c t must have FloatingPoint sort.

        def_API('Z3_mk_fpa_sqrt', AST, (_in(CONTEXT),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_sqrt(c: Z3_context; rm: Z3_ast; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_sqrt';

(**
        \brief Floating-point remainder

        \param c logical context
        \param t1 term of FloatingPoint sort
        \param t2 term of FloatingPoint sort

        \c t1 and \c t2 must have the same FloatingPoint sort.

        def_API('Z3_mk_fpa_rem', AST, (_in(CONTEXT),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_rem(c: Z3_context; t1: Z3_ast; t2: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_rem';

(**
        \brief Floating-point roundToIntegral. Rounds a floating-point number to
        the closest integer, again represented as a floating-point number.

        \param c logical context
        \param rm term of RoundingMode sort
        \param t term of FloatingPoint sort

        \c t must be of FloatingPoint sort.

        def_API('Z3_mk_fpa_round_to_integral', AST, (_in(CONTEXT),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_round_to_integral(c: Z3_context; rm: Z3_ast; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_round_to_integral';

(**
        \brief Minimum of floating-point numbers.

        \param c logical context
        \param t1 term of FloatingPoint sort
        \param t2 term of FloatingPoint sort

        \c t1, \c t2 must have the same FloatingPoint sort.

        def_API('Z3_mk_fpa_min', AST, (_in(CONTEXT),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_min(c: Z3_context; t1: Z3_ast; t2: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_min';

(**
        \brief Maximum of floating-point numbers.

        \param c logical context
        \param t1 term of FloatingPoint sort
        \param t2 term of FloatingPoint sort

        \c t1, \c t2 must have the same FloatingPoint sort.

        def_API('Z3_mk_fpa_max', AST, (_in(CONTEXT),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_max(c: Z3_context; t1: Z3_ast; t2: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_max';

(**
        \brief Floating-point less than or equal.

        \param c logical context
        \param t1 term of FloatingPoint sort
        \param t2 term of FloatingPoint sort

        \c t1 and \c t2 must have the same FloatingPoint sort.

        def_API('Z3_mk_fpa_leq', AST, (_in(CONTEXT),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_leq(c: Z3_context; t1: Z3_ast; t2: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_leq';

(**
        \brief Floating-point less than.

        \param c logical context
        \param t1 term of FloatingPoint sort
        \param t2 term of FloatingPoint sort

        \c t1 and \c t2 must have the same FloatingPoint sort.

        def_API('Z3_mk_fpa_lt', AST, (_in(CONTEXT),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_lt(c: Z3_context; t1: Z3_ast; t2: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_lt';

(**
        \brief Floating-point greater than or equal.

        \param c logical context
        \param t1 term of FloatingPoint sort
        \param t2 term of FloatingPoint sort

        \c t1 and \c t2 must have the same FloatingPoint sort.

        def_API('Z3_mk_fpa_geq', AST, (_in(CONTEXT),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_geq(c: Z3_context; t1: Z3_ast; t2: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_geq';

(**
        \brief Floating-point greater than.

        \param c logical context
        \param t1 term of FloatingPoint sort
        \param t2 term of FloatingPoint sort

        \c t1 and \c t2 must have the same FloatingPoint sort.

        def_API('Z3_mk_fpa_gt', AST, (_in(CONTEXT),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_gt(c: Z3_context; t1: Z3_ast; t2: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_gt';

(**
        \brief Floating-point equality.

        \param c logical context
        \param t1 term of FloatingPoint sort
        \param t2 term of FloatingPoint sort

        Note that this is IEEE 754 equality (as opposed to SMT-LIB \ccode{=}).

        \c t1 and \c t2 must have the same FloatingPoint sort.

        def_API('Z3_mk_fpa_eq', AST, (_in(CONTEXT),_in(AST),_in(AST)))
 *)
function Z3_mk_fpa_eq(c: Z3_context; t1: Z3_ast; t2: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_eq';

(**
        \brief Predicate indicating whether \c t is a normal floating-point number.

        \param c logical context
        \param t term of FloatingPoint sort

        \c t must have FloatingPoint sort.

        def_API('Z3_mk_fpa_is_normal', AST, (_in(CONTEXT),_in(AST)))
 *)
function Z3_mk_fpa_is_normal(c: Z3_context; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_is_normal';

(**
        \brief Predicate indicating whether \c t is a subnormal floating-point number.

        \param c logical context
        \param t term of FloatingPoint sort

        \c t must have FloatingPoint sort.

        def_API('Z3_mk_fpa_is_subnormal', AST, (_in(CONTEXT),_in(AST)))
 *)
function Z3_mk_fpa_is_subnormal(c: Z3_context; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_is_subnormal';

(**
        \brief Predicate indicating whether \c t is a floating-point number with zero value, i.e., +zero or -zero.

        \param c logical context
        \param t term of FloatingPoint sort

        \c t must have FloatingPoint sort.

        def_API('Z3_mk_fpa_is_zero', AST, (_in(CONTEXT),_in(AST)))
 *)
function Z3_mk_fpa_is_zero(c: Z3_context; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_is_zero';

(**
        \brief Predicate indicating whether \c t is a floating-point number representing +oo or -oo.

        \param c logical context
        \param t term of FloatingPoint sort

        \c t must have FloatingPoint sort.

        def_API('Z3_mk_fpa_is_infinite', AST, (_in(CONTEXT),_in(AST)))
 *)
function Z3_mk_fpa_is_infinite(c: Z3_context; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_is_infinite';

(**
        \brief Predicate indicating whether \c t is a NaN.

        \param c logical context
        \param t term of FloatingPoint sort

        \c t must have FloatingPoint sort.

        def_API('Z3_mk_fpa_is_nan', AST, (_in(CONTEXT),_in(AST)))
 *)
function Z3_mk_fpa_is_nan(c: Z3_context; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_is_nan';

(**
        \brief Predicate indicating whether \c t is a negative floating-point number.

        \param c logical context
        \param t term of FloatingPoint sort

        \c t must have FloatingPoint sort.

        def_API('Z3_mk_fpa_is_negative', AST, (_in(CONTEXT),_in(AST)))
 *)
function Z3_mk_fpa_is_negative(c: Z3_context; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_is_negative';

(**
        \brief Predicate indicating whether \c t is a positive floating-point number.

        \param c logical context
        \param t term of FloatingPoint sort

        \c t must have FloatingPoint sort.

        def_API('Z3_mk_fpa_is_positive', AST, (_in(CONTEXT),_in(AST)))
 *)
function Z3_mk_fpa_is_positive(c: Z3_context; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_is_positive';

(**
        \brief Conversion of a single IEEE 754-2008 bit-vector into a floating-point number.

        Produces a term that represents the conversion of a bit-vector term \c bv to a
        floating-point term of sort \c s.

        \param c logical context
        \param bv a bit-vector term
        \param s floating-point sort

        \c s must be a FloatingPoint sort, \c t must be of bit-vector sort, and the bit-vector
        size of \c bv must be equal to \ccode{ebits+sbits} of \c s. The format of the bit-vector is
        as defined by the IEEE 754-2008 interchange format.

        def_API('Z3_mk_fpa_to_fp_bv', AST, (_in(CONTEXT),_in(AST),_in(SORT)))
 *)
function Z3_mk_fpa_to_fp_bv(c: Z3_context; bv: Z3_ast; s: Z3_sort): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_to_fp_bv';

(**
        \brief Conversion of a FloatingPoint term into another term of different FloatingPoint sort.

        Produces a term that represents the conversion of a floating-point term \c t to a
        floating-point term of sort \c s. If necessary, the result will be rounded according
        to rounding mode \c rm.

        \param c logical context
        \param rm term of RoundingMode sort
        \param t term of FloatingPoint sort
        \param s floating-point sort

        \c s must be a FloatingPoint sort, \c rm must be of RoundingMode sort, \c t must be of floating-point sort.

        def_API('Z3_mk_fpa_to_fp_float', AST, (_in(CONTEXT),_in(AST),_in(AST),_in(SORT)))
 *)
function Z3_mk_fpa_to_fp_float(c: Z3_context; rm: Z3_ast; t: Z3_ast; s: Z3_sort): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_to_fp_float';

(**
        \brief Conversion of a term of real sort into a term of FloatingPoint sort.

        Produces a term that represents the conversion of term \c t of real sort into a
        floating-point term of sort \c s. If necessary, the result will be rounded according
        to rounding mode \c rm.

        \param c logical context
        \param rm term of RoundingMode sort
        \param t term of Real sort
        \param s floating-point sort

        \c s must be a FloatingPoint sort, \c rm must be of RoundingMode sort, \c t must be of real sort.

        def_API('Z3_mk_fpa_to_fp_real', AST, (_in(CONTEXT),_in(AST),_in(AST),_in(SORT)))
 *)
function Z3_mk_fpa_to_fp_real(c: Z3_context; rm: Z3_ast; t: Z3_ast; s: Z3_sort): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_to_fp_real';

(**
        \brief Conversion of a 2's complement signed bit-vector term into a term of FloatingPoint sort.

        Produces a term that represents the conversion of the bit-vector term \c t into a
        floating-point term of sort \c s. The bit-vector \c t is taken to be in signed
        2's complement format. If necessary, the result will be rounded according
        to rounding mode \c rm.

        \param c logical context
        \param rm term of RoundingMode sort
        \param t term of bit-vector sort
        \param s floating-point sort

        \c s must be a FloatingPoint sort, \c rm must be of RoundingMode sort, \c t must be of bit-vector sort.

        def_API('Z3_mk_fpa_to_fp_signed', AST, (_in(CONTEXT),_in(AST),_in(AST),_in(SORT)))
 *)
function Z3_mk_fpa_to_fp_signed(c: Z3_context; rm: Z3_ast; t: Z3_ast; s: Z3_sort): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_to_fp_signed';

(**
        \brief Conversion of a 2's complement unsigned bit-vector term into a term of FloatingPoint sort.

        Produces a term that represents the conversion of the bit-vector term \c t into a
        floating-point term of sort \c s. The bit-vector \c t is taken to be in unsigned
        2's complement format. If necessary, the result will be rounded according
        to rounding mode \c rm.

        \param c logical context
        \param rm term of RoundingMode sort
        \param t term of bit-vector sort
        \param s floating-point sort

        \c s must be a FloatingPoint sort, \c rm must be of RoundingMode sort, \c t must be of bit-vector sort.

        def_API('Z3_mk_fpa_to_fp_unsigned', AST, (_in(CONTEXT),_in(AST),_in(AST),_in(SORT)))
 *)
function Z3_mk_fpa_to_fp_unsigned(c: Z3_context; rm: Z3_ast; t: Z3_ast; s: Z3_sort): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_to_fp_unsigned';

(**
        \brief Conversion of a floating-point term into an unsigned bit-vector.

        Produces a term that represents the conversion of the floating-point term \c t into a
        bit-vector term of size \c sz in unsigned 2's complement format. If necessary, the result
        will be rounded according to rounding mode \c rm.

        \param c logical context
        \param rm term of RoundingMode sort
        \param t term of FloatingPoint sort
        \param sz size of the resulting bit-vector

        def_API('Z3_mk_fpa_to_ubv', AST, (_in(CONTEXT),_in(AST),_in(AST),_in(UINT)))
 *)
function Z3_mk_fpa_to_ubv(c: Z3_context; rm: Z3_ast; t: Z3_ast; sz: Cardinal): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_to_ubv';

(**
        \brief Conversion of a floating-point term into a signed bit-vector.

        Produces a term that represents the conversion of the floating-point term \c t into a
        bit-vector term of size \c sz in signed 2's complement format. If necessary, the result
        will be rounded according to rounding mode \c rm.

        \param c logical context
        \param rm term of RoundingMode sort
        \param t term of FloatingPoint sort
        \param sz size of the resulting bit-vector

        def_API('Z3_mk_fpa_to_sbv', AST, (_in(CONTEXT),_in(AST),_in(AST),_in(UINT)))
 *)
function Z3_mk_fpa_to_sbv(c: Z3_context; rm: Z3_ast; t: Z3_ast; sz: Cardinal): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_to_sbv';

(**
        \brief Conversion of a floating-point term into a real-numbered term.

        Produces a term that represents the conversion of the floating-point term \c t into a
        real number. Note that this type of conversion will often result in non-linear
        constraints over real terms.

        \param c logical context
        \param t term of FloatingPoint sort

        def_API('Z3_mk_fpa_to_real', AST, (_in(CONTEXT),_in(AST)))
 *)
function Z3_mk_fpa_to_real(c: Z3_context; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_to_real';

(**
        \brief Retrieves the number of bits reserved for the exponent in a FloatingPoint sort.

        \param c logical context
        \param s FloatingPoint sort

        def_API('Z3_fpa_get_ebits', UINT, (_in(CONTEXT),_in(SORT)))
 *)
function Z3_fpa_get_ebits(c: Z3_context; s: Z3_sort): Cardinal; cdecl;
  external z3_dll name  'Z3_fpa_get_ebits';

(**
        \brief Retrieves the number of bits reserved for the significand in a FloatingPoint sort.

        \param c logical context
        \param s FloatingPoint sort

        def_API('Z3_fpa_get_sbits', UINT, (_in(CONTEXT),_in(SORT)))
 *)
function Z3_fpa_get_sbits(c: Z3_context; s: Z3_sort): Cardinal; cdecl;
  external z3_dll name  'Z3_fpa_get_sbits';

(**
        \brief Checks whether a given floating-point numeral is a NaN.

        \param c logical context
        \param t a floating-point numeral

        def_API('Z3_fpa_is_numeral_nan', BOOL, (_in(CONTEXT), _in(AST)))
 *)
function Z3_fpa_is_numeral_nan(c: Z3_context; t: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_fpa_is_numeral_nan';

(**
        \brief Checks whether a given floating-point numeral is a +oo or -oo.

        \param c logical context
        \param t a floating-point numeral

        def_API('Z3_fpa_is_numeral_inf', BOOL, (_in(CONTEXT), _in(AST)))
 *)
function Z3_fpa_is_numeral_inf(c: Z3_context; t: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_fpa_is_numeral_inf';

(**
        \brief Checks whether a given floating-point numeral is +zero or -zero.

        \param c logical context
        \param t a floating-point numeral

        def_API('Z3_fpa_is_numeral_zero', BOOL, (_in(CONTEXT), _in(AST)))
 *)
function Z3_fpa_is_numeral_zero(c: Z3_context; t: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_fpa_is_numeral_zero';

(**
        \brief Checks whether a given floating-point numeral is normal.

        \param c logical context
        \param t a floating-point numeral

        def_API('Z3_fpa_is_numeral_normal', BOOL, (_in(CONTEXT), _in(AST)))
 *)
function Z3_fpa_is_numeral_normal(c: Z3_context; t: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_fpa_is_numeral_normal';

(**
        \brief Checks whether a given floating-point numeral is subnormal.

        \param c logical context
        \param t a floating-point numeral

        def_API('Z3_fpa_is_numeral_subnormal', BOOL, (_in(CONTEXT), _in(AST)))
 *)
function Z3_fpa_is_numeral_subnormal(c: Z3_context; t: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_fpa_is_numeral_subnormal';

(**
        \brief Checks whether a given floating-point numeral is positive.

        \param c logical context
        \param t a floating-point numeral

        def_API('Z3_fpa_is_numeral_positive', BOOL, (_in(CONTEXT), _in(AST)))
 *)
function Z3_fpa_is_numeral_positive(c: Z3_context; t: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_fpa_is_numeral_positive';

(**
        \brief Checks whether a given floating-point numeral is negative.

        \param c logical context
        \param t a floating-point numeral

        def_API('Z3_fpa_is_numeral_negative', BOOL, (_in(CONTEXT), _in(AST)))
 *)
function Z3_fpa_is_numeral_negative(c: Z3_context; t: Z3_ast): Boolean; cdecl;
  external z3_dll name  'Z3_fpa_is_numeral_negative';

(**
        \brief Retrieves the sign of a floating-point literal as a bit-vector expression.

        \param c logical context
        \param t a floating-point numeral

        Remarks: NaN is an invalid argument.

        def_API('Z3_fpa_get_numeral_sign_bv', AST, (_in(CONTEXT), _in(AST)))
 *)
function Z3_fpa_get_numeral_sign_bv(c: Z3_context; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_fpa_get_numeral_sign_bv';

(**
        \brief Retrieves the significand of a floating-point literal as a bit-vector expression.

        \param c logical context
        \param t a floating-point numeral

        Remarks: NaN is an invalid argument.

        def_API('Z3_fpa_get_numeral_significand_bv', AST, (_in(CONTEXT), _in(AST)))
 *)
function Z3_fpa_get_numeral_significand_bv(c: Z3_context; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_fpa_get_numeral_significand_bv';

(**
        \brief Retrieves the sign of a floating-point literal.

        \param c logical context
        \param t a floating-point numeral
        \param sgn sign

        Remarks: sets \c sgn to 0 if `t' is positive and to 1 otherwise, except for
        NaN, which is an invalid argument.

        def_API('Z3_fpa_get_numeral_sign', BOOL, (_in(CONTEXT), _in(AST), _out(INT)))
 *)
function Z3_fpa_get_numeral_sign(c: Z3_context; t: Z3_ast; sgn: PInteger): Boolean; cdecl;
  external z3_dll name  'Z3_fpa_get_numeral_sign';

(**
        \brief Return the significand value of a floating-point numeral as a string.

        \param c logical context
        \param t a floating-point numeral

        Remarks: The significand \c s is always \ccode{0.0 <= s < 2.0}; the resulting string is long
        enough to represent the real significand precisely.

        def_API('Z3_fpa_get_numeral_significand_string', STRING, (_in(CONTEXT), _in(AST)))
 *)
function Z3_fpa_get_numeral_significand_string(c: Z3_context; t: Z3_ast): Z3_string; cdecl;
  external z3_dll name  'Z3_fpa_get_numeral_significand_string';

(**
        \brief Return the significand value of a floating-point numeral as a uint64.

        \param c logical context
        \param t a floating-point numeral
        \param n pointer to output uint64

        Remarks: This function extracts the significand bits in `t`, without the
        hidden bit or normalization. Sets the \c Z3_INVALID_ARG error code if the
        significand does not fit into a \c uint64. NaN is an invalid argument.

        def_API('Z3_fpa_get_numeral_significand_uint64', BOOL, (_in(CONTEXT), _in(AST), _out(UINT64)))
 *)
function Z3_fpa_get_numeral_significand_uint64(c: Z3_context; t: Z3_ast; n: PUInt64): Boolean; cdecl;
  external z3_dll name  'Z3_fpa_get_numeral_significand_uint64';

(**
        \brief Return the exponent value of a floating-point numeral as a string.

        \param c logical context
        \param t a floating-point numeral
        \param biased flag to indicate whether the result is in biased representation

        Remarks: This function extracts the exponent in `t`, without normalization.
        NaN is an invalid argument.

    def_API('Z3_fpa_get_numeral_exponent_string', STRING, (_in(CONTEXT), _in(AST), _in(BOOL)))
 *)
function Z3_fpa_get_numeral_exponent_string(c: Z3_context; t: Z3_ast; biased: Boolean): Z3_string; cdecl;
  external z3_dll name  'Z3_fpa_get_numeral_exponent_string';

(**
        \brief Return the exponent value of a floating-point numeral as a signed 64-bit integer

        \param c logical context
        \param t a floating-point numeral
        \param n exponent
        \param biased flag to indicate whether the result is in biased representation

        Remarks: This function extracts the exponent in `t`, without normalization.
        NaN is an invalid argument.

        def_API('Z3_fpa_get_numeral_exponent_int64', BOOL, (_in(CONTEXT), _in(AST), _out(INT64), _in(BOOL)))
 *)
function Z3_fpa_get_numeral_exponent_int64(c: Z3_context; t: Z3_ast; n: PInt64; biased: Boolean): Boolean; cdecl;
  external z3_dll name  'Z3_fpa_get_numeral_exponent_int64';

(**
        \brief Retrieves the exponent of a floating-point literal as a bit-vector expression.

        \param c logical context
        \param t a floating-point numeral
        \param biased flag to indicate whether the result is in biased representation

        Remarks: This function extracts the exponent in `t`, without normalization.
        NaN is an invalid arguments.

        def_API('Z3_fpa_get_numeral_exponent_bv', AST, (_in(CONTEXT), _in(AST), _in(BOOL)))
 *)
function Z3_fpa_get_numeral_exponent_bv(c: Z3_context; t: Z3_ast; biased: Boolean): Z3_ast; cdecl;
  external z3_dll name  'Z3_fpa_get_numeral_exponent_bv';

(**
        \brief Conversion of a floating-point term into a bit-vector term in IEEE 754-2008 format.

        \param c logical context
        \param t term of FloatingPoint sort

        \c t must have FloatingPoint sort. The size of the resulting bit-vector is automatically
        determined.

        Note that IEEE 754-2008 allows multiple different representations of NaN. This conversion
        knows only one NaN and it will always produce the same bit-vector representation of
        that NaN.

        def_API('Z3_mk_fpa_to_ieee_bv', AST, (_in(CONTEXT),_in(AST)))
 *)
function Z3_mk_fpa_to_ieee_bv(c: Z3_context; t: Z3_ast): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_to_ieee_bv';

(**
        \brief Conversion of a real-sorted significand and an integer-sorted exponent into a term of FloatingPoint sort.

        Produces a term that represents the conversion of \ccode{sig * 2^exp} into a
        floating-point term of sort \c s. If necessary, the result will be rounded
        according to rounding mode \c rm.

        \param c logical context
        \param rm term of RoundingMode sort
        \param exp exponent term of Int sort
        \param sig significand term of Real sort
        \param s FloatingPoint sort

        \c s must be a FloatingPoint sort, \c rm must be of RoundingMode sort, \c exp must be of int sort, \c sig must be of real sort.

        def_API('Z3_mk_fpa_to_fp_int_real', AST, (_in(CONTEXT),_in(AST),_in(AST),_in(AST),_in(SORT)))
 *)
function Z3_mk_fpa_to_fp_int_real(c: Z3_context; rm: Z3_ast; exp: Z3_ast; sig: Z3_ast; s: Z3_sort): Z3_ast; cdecl;
  external z3_dll name  'Z3_mk_fpa_to_fp_int_real';

implementation

end.
