unit z3_optimization;
{ This unit is automatically generated by Chet:
  https://github.com/neslib/Chet }

interface

uses z3;

(**
       \brief Create a new optimize context.

       \remark User must use #Z3_optimize_inc_ref and #Z3_optimize_dec_ref to manage optimize objects.
       Even if the context was created using #Z3_mk_context instead of #Z3_mk_context_rc.

       def_API('Z3_mk_optimize', OPTIMIZE, (_in(CONTEXT), ))
 *)
function Z3_mk_optimize(c: Z3_context): Z3_optimize; cdecl;
  external z3_dll name  'Z3_mk_optimize';

(**
       \brief Increment the reference counter of the given optimize context

       def_API('Z3_optimize_inc_ref', VOID, (_in(CONTEXT), _in(OPTIMIZE)))
 *)
procedure Z3_optimize_inc_ref(c: Z3_context; d: Z3_optimize); cdecl;
  external z3_dll name  'Z3_optimize_inc_ref';

(**
       \brief Decrement the reference counter of the given optimize context.

       def_API('Z3_optimize_dec_ref', VOID, (_in(CONTEXT), _in(OPTIMIZE)))
 *)
procedure Z3_optimize_dec_ref(c: Z3_context; d: Z3_optimize); cdecl;
  external z3_dll name  'Z3_optimize_dec_ref';

(**
       \brief Assert hard constraint to the optimization context.

       \sa Z3_optimize_assert_soft

       def_API('Z3_optimize_assert', VOID, (_in(CONTEXT), _in(OPTIMIZE), _in(AST)))
 *)
procedure Z3_optimize_assert(c: Z3_context; o: Z3_optimize; a: Z3_ast); cdecl;
  external z3_dll name  'Z3_optimize_assert';


(**
       \brief Assert soft constraint to the optimization context.
       \param c - context
       \param o - optimization context
       \param a - formula
       \param weight - a positive weight, penalty for violating soft constraint
       \param id - optional identifier to group soft constraints

       \sa Z3_optimize_assert

       def_API('Z3_optimize_assert_soft', UINT, (_in(CONTEXT), _in(OPTIMIZE), _in(AST), _in(STRING), _in(SYMBOL)))
 *)
function Z3_optimize_assert_soft(c: Z3_context; o: Z3_optimize; a: Z3_ast; weight: Z3_string; id: Z3_symbol): Cardinal; cdecl;
  external z3_dll name  'Z3_optimize_assert_soft';

(**
       \brief Add a maximization constraint.
       \param c - context
       \param o - optimization context
       \param t - arithmetical term

       \sa Z3_optimize_minimize

       def_API('Z3_optimize_maximize', UINT, (_in(CONTEXT), _in(OPTIMIZE), _in(AST)))
 *)
function Z3_optimize_maximize(c: Z3_context; o: Z3_optimize; t: Z3_ast): Cardinal; cdecl;
  external z3_dll name  'Z3_optimize_maximize';

(**
       \brief Add a minimization constraint.
       \param c - context
       \param o - optimization context
       \param t - arithmetical term

       \sa Z3_optimize_maximize

       def_API('Z3_optimize_minimize', UINT, (_in(CONTEXT), _in(OPTIMIZE), _in(AST)))
 *)
function Z3_optimize_minimize(c: Z3_context; o: Z3_optimize; t: Z3_ast): Cardinal; cdecl;
  external z3_dll name  'Z3_optimize_minimize';

(**
       \brief Create a backtracking point.

       The optimize solver contains a set of rules, added facts and assertions.
       The set of rules, facts and assertions are restored upon calling #Z3_optimize_pop.

       \sa Z3_optimize_pop

       def_API('Z3_optimize_push', VOID, (_in(CONTEXT), _in(OPTIMIZE)))
 *)
procedure Z3_optimize_push(c: Z3_context; d: Z3_optimize); cdecl;
  external z3_dll name  'Z3_optimize_push';

(**
       \brief Backtrack one level.

       \sa Z3_optimize_push

       \pre The number of calls to pop cannot exceed calls to push.

       def_API('Z3_optimize_pop', VOID, (_in(CONTEXT), _in(OPTIMIZE)))
 *)
procedure Z3_optimize_pop(c: Z3_context; d: Z3_optimize); cdecl;
  external z3_dll name  'Z3_optimize_pop';

(**
       \brief Check consistency and produce optimal values.
       \param c - context
       \param o - optimization context
       \param num_assumptions - number of additional assumptions
       \param assumptions - the additional assumptions

       \sa Z3_optimize_get_reason_unknown
       \sa Z3_optimize_get_model
       \sa Z3_optimize_get_statistics
       \sa Z3_optimize_get_unsat_core

       def_API('Z3_optimize_check', INT, (_in(CONTEXT), _in(OPTIMIZE), _in(UINT), _in_array(2, AST)))
 *)
function Z3_optimize_check(c: Z3_context; o: Z3_optimize; num_assumptions: Cardinal; assumptions: PZ3_ast): Z3_lbool; cdecl;
  external z3_dll name  'Z3_optimize_check';

(**
       \brief Retrieve a string that describes the last status returned by #Z3_optimize_check.

       Use this method when #Z3_optimize_check returns \c Z3_L_UNDEF.

       def_API('Z3_optimize_get_reason_unknown', STRING, (_in(CONTEXT), _in(OPTIMIZE) ))
 *)
function Z3_optimize_get_reason_unknown(c: Z3_context; d: Z3_optimize): Z3_string; cdecl;
  external z3_dll name  'Z3_optimize_get_reason_unknown';

(**
       \brief Retrieve the model for the last #Z3_optimize_check

       The error handler is invoked if a model is not available because
       the commands above were not invoked for the given optimization
       solver, or if the result was \c Z3_L_FALSE.

       def_API('Z3_optimize_get_model', MODEL, (_in(CONTEXT), _in(OPTIMIZE)))
 *)
function Z3_optimize_get_model(c: Z3_context; o: Z3_optimize): Z3_model; cdecl;
  external z3_dll name  'Z3_optimize_get_model';

(**
       \brief Retrieve the unsat core for the last #Z3_optimize_check
       The unsat core is a subset of the assumptions \c a.

       def_API('Z3_optimize_get_unsat_core', AST_VECTOR, (_in(CONTEXT), _in(OPTIMIZE)))       
 *)
function Z3_optimize_get_unsat_core(c: Z3_context; o: Z3_optimize): Z3_ast_vector; cdecl;
  external z3_dll name  'Z3_optimize_get_unsat_core';

(**
       \brief Set parameters on optimization context.

       \param c - context
       \param o - optimization context
       \param p - parameters

       \sa Z3_optimize_get_help
       \sa Z3_optimize_get_param_descrs

       def_API('Z3_optimize_set_params', VOID, (_in(CONTEXT), _in(OPTIMIZE), _in(PARAMS)))
 *)
procedure Z3_optimize_set_params(c: Z3_context; o: Z3_optimize; p: Z3_params); cdecl;
  external z3_dll name  'Z3_optimize_set_params';

(**
       \brief Return the parameter description set for the given optimize object.

       \param c - context
       \param o - optimization context

       \sa Z3_optimize_get_help
       \sa Z3_optimize_set_params

       def_API('Z3_optimize_get_param_descrs', PARAM_DESCRS, (_in(CONTEXT), _in(OPTIMIZE)))
 *)
function Z3_optimize_get_param_descrs(c: Z3_context; o: Z3_optimize): Z3_param_descrs; cdecl;
  external z3_dll name  'Z3_optimize_get_param_descrs';

(**
       \brief Retrieve lower bound value or approximation for the i'th optimization objective.

       \param c - context
       \param o - optimization context
       \param idx - index of optimization objective

       \sa Z3_optimize_get_upper
       \sa Z3_optimize_get_lower_as_vector
       \sa Z3_optimize_get_upper_as_vector

       def_API('Z3_optimize_get_lower', AST, (_in(CONTEXT), _in(OPTIMIZE), _in(UINT)))
 *)
function Z3_optimize_get_lower(c: Z3_context; o: Z3_optimize; idx: Cardinal): Z3_ast; cdecl;
  external z3_dll name  'Z3_optimize_get_lower';

(**
       \brief Retrieve upper bound value or approximation for the i'th optimization objective.

       \param c - context
       \param o - optimization context
       \param idx - index of optimization objective

       \sa Z3_optimize_get_lower
       \sa Z3_optimize_get_lower_as_vector
       \sa Z3_optimize_get_upper_as_vector

       def_API('Z3_optimize_get_upper', AST, (_in(CONTEXT), _in(OPTIMIZE), _in(UINT)))
 *)
function Z3_optimize_get_upper(c: Z3_context; o: Z3_optimize; idx: Cardinal): Z3_ast; cdecl;
  external z3_dll name  'Z3_optimize_get_upper';

(**
       \brief Retrieve lower bound value or approximation for the i'th optimization objective.
              The returned vector is of length 3. It always contains numerals.
              The three numerals are coefficients \c a, \c b, \c c and encode the result of
              #Z3_optimize_get_lower \ccode{a * infinity + b + c * epsilon}.
              
       \param c - context
       \param o - optimization context
       \param idx - index of optimization objective

       \sa Z3_optimize_get_lower
       \sa Z3_optimize_get_upper
       \sa Z3_optimize_get_upper_as_vector

       def_API('Z3_optimize_get_lower_as_vector', AST_VECTOR, (_in(CONTEXT), _in(OPTIMIZE), _in(UINT)))
 *)
function Z3_optimize_get_lower_as_vector(c: Z3_context; o: Z3_optimize; idx: Cardinal): Z3_ast_vector; cdecl;
  external z3_dll name  'Z3_optimize_get_lower_as_vector';

(**
       \brief Retrieve upper bound value or approximation for the i'th optimization objective.

       \param c - context
       \param o - optimization context
       \param idx - index of optimization objective

       \sa Z3_optimize_get_lower
       \sa Z3_optimize_get_upper
       \sa Z3_optimize_get_lower_as_vector

       def_API('Z3_optimize_get_upper_as_vector', AST_VECTOR, (_in(CONTEXT), _in(OPTIMIZE), _in(UINT)))
 *)
function Z3_optimize_get_upper_as_vector(c: Z3_context; o: Z3_optimize; idx: Cardinal): Z3_ast_vector; cdecl;
  external z3_dll name  'Z3_optimize_get_upper_as_vector';

(**
       \brief Print the current context as a string.
       \param c - context.
       \param o - optimization context.

       \sa Z3_optimize_from_file
       \sa Z3_optimize_from_string

       def_API('Z3_optimize_to_string', STRING, (_in(CONTEXT), _in(OPTIMIZE)))
 *)
function Z3_optimize_to_string(c: Z3_context; o: Z3_optimize): Z3_string; cdecl;
  external z3_dll name  'Z3_optimize_to_string';

(**
       \brief Parse an SMT-LIB2 string with assertions,
       soft constraints and optimization objectives.
       Add the parsed constraints and objectives to the optimization context.

       \param c - context.
       \param o - optimize context.
       \param s - string containing SMT2 specification.

       \sa Z3_optimize_from_file
       \sa Z3_optimize_to_string

       def_API('Z3_optimize_from_string', VOID, (_in(CONTEXT), _in(OPTIMIZE), _in(STRING)))
 *)
procedure Z3_optimize_from_string(c: Z3_context; o: Z3_optimize; s: Z3_string); cdecl;
  external z3_dll name  'Z3_optimize_from_string';

(**
       \brief Parse an SMT-LIB2 file with assertions,
       soft constraints and optimization objectives.
       Add the parsed constraints and objectives to the optimization context.

       \param c - context.
       \param o - optimize context.
       \param s - path to file containing SMT2 specification.

       \sa Z3_optimize_from_string
       \sa Z3_optimize_to_string

       def_API('Z3_optimize_from_file', VOID, (_in(CONTEXT), _in(OPTIMIZE), _in(STRING)))
 *)
procedure Z3_optimize_from_file(c: Z3_context; o: Z3_optimize; s: Z3_string); cdecl;
  external z3_dll name  'Z3_optimize_from_file';

(**
       \brief Return a string containing a description of parameters accepted by optimize.

       \sa Z3_optimize_get_param_descrs
       \sa Z3_optimize_set_params

       def_API('Z3_optimize_get_help', STRING, (_in(CONTEXT), _in(OPTIMIZE)))
 *)
function Z3_optimize_get_help(c: Z3_context; t: Z3_optimize): Z3_string; cdecl;
  external z3_dll name  'Z3_optimize_get_help';

(**
       \brief Retrieve statistics information from the last call to #Z3_optimize_check

       def_API('Z3_optimize_get_statistics', STATS, (_in(CONTEXT), _in(OPTIMIZE)))
 *)
function Z3_optimize_get_statistics(c: Z3_context; d: Z3_optimize): Z3_stats; cdecl;
  external z3_dll name  'Z3_optimize_get_statistics';

(**
       \brief Return the set of asserted formulas on the optimization context.

       def_API('Z3_optimize_get_assertions', AST_VECTOR, (_in(CONTEXT), _in(OPTIMIZE)))
 *)
function Z3_optimize_get_assertions(c: Z3_context; o: Z3_optimize): Z3_ast_vector; cdecl;
  external z3_dll name  'Z3_optimize_get_assertions';

(**
       \brief Return objectives on the optimization context.
       If the objective function is a max-sat objective it is returned
       as a Pseudo-Boolean (minimization) sum of the form \ccode{(+ (if f1 w1 0) (if f2 w2 0) ...)}
       If the objective function is entered as a maximization objective, then return
       the corresponding minimization objective. In this way the resulting objective
       function is always returned as a minimization objective.

       def_API('Z3_optimize_get_objectives', AST_VECTOR, (_in(CONTEXT), _in(OPTIMIZE)))
 *)
function Z3_optimize_get_objectives(c: Z3_context; o: Z3_optimize): Z3_ast_vector; cdecl;
  external z3_dll name  'Z3_optimize_get_objectives';

implementation

end.
