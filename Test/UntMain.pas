unit UntMain;

interface

uses
  Windows, {Messages,} SysUtils, Variants, Classes, Graphics,

  Controls, Forms, Dialogs, StdCtrls, Buttons,
  z3, ComCtrls, ExtCtrls,
  Z3.Context;


const  MAX_RETRACTABLE_ASSERTIONS = 1024 ;

(**
   \brief Very simple logical context wrapper with support for retractable constraints.
   A retractable constraint can be "removed" without using push/pop.
*)
  type
   Z3_ext_context_struct = record
      m_context : Z3_context;
      m_solver  : Z3_solver;
      // IMPORTANT: the fields m_answer_literals, m_retracted and m_num_answer_literals must be saved/restored
      // if push/pop operations are performed on m_context.
      m_answer_literals     : array[0..MAX_RETRACTABLE_ASSERTIONS-1] of Z3_ast;
      m_retracted           : array[0..MAX_RETRACTABLE_ASSERTIONS-1] of Boolean; // true if the assertion was retracted.
      m_num_answer_literals : Cardinal;
  end;
  Z3_ext_context = ^Z3_ext_context_struct;


  TMain = class(TForm)
    //pnl1: TPanel;
    //pnlBtn: TPanel;
    //btnTestApi: TBitBtn;
    //reLog: TRichEdit;
    //btnTestX86: TBitBtn;
    //btnTestClass: TBitBtn;
    //edtBinFile: TEdit;
    procedure btnTestApiClick(Sender: TObject);
    procedure reLogChange(Sender: TObject);
    procedure btnTestClassClick(Sender: TObject);
    procedure btnTestX86Click(Sender: TObject);
  private
    procedure prove(ctx: Z3_context; s: Z3_solver; f: Z3_ast; is_valid: Boolean);
    procedure TestApi;
    procedure simple_example;
    procedure demorgan;
    procedure find_model_example1;
    procedure check(ctx: Z3_context; s: Z3_solver; expected_result: Z3_lbool);
    procedure find_model_example2;
    procedure prove_example1;
    procedure prove_example2;
    procedure push_pop_example1;
    procedure quantifier_example1;
    procedure check2(ctx: Z3_context; s: Z3_solver; expected_result: Z3_lbool);

    function  display_model(c: Z3_context; m: Z3_model): AnsiString;
    function  display_symbol(c: Z3_context; s: Z3_symbol): AnsiString;
    function  display_ast(c: Z3_context; v: Z3_ast): AnsiString;
    function  display_sort(c: Z3_context; ty: Z3_sort): AnsiString;
    function display_function_interpretations(c: Z3_context;  m: Z3_model): AnsiString;
    procedure assert_inj_axiom(ctx: Z3_context; s: Z3_solver; f: Z3_func_decl;  i: Cardinal);
    procedure array_example1;
    procedure array_example2;
    procedure array_example3;
    procedure tuple_example1;
    procedure bitvector_example1;
    procedure bitvector_example2;
    procedure eval_example1;
    procedure two_contexts_example1;
    procedure error_code_example1;
    procedure error_code_example2;
    procedure parser_example2;
    procedure parser_example3;
    procedure assert_comm_axiom(ctx: Z3_context; s: Z3_solver; f: Z3_func_decl);
    procedure parser_example5;
    procedure numeral_example;
    procedure ite_example;
    procedure enum_example;
    procedure list_example;
    procedure tree_example;
    procedure forest_example;
    procedure binary_tree_example;
    procedure unsat_core_and_proof_example;
    function ext_check(ctx: Z3_ext_context): Z3_lbool;
    procedure incremental_example1;
    procedure reference_counter_example;
    procedure smt2parser_example;
    procedure substitute_example;
    procedure substitute_vars_example;
    procedure fpa_example;
    procedure mk_model_example;

    procedure demorgan_;
    procedure find_model_example1_;
    procedure prove_example1_;
    procedure prove_example2_;
    procedure nonlinear_example1_;
    procedure prove_(conjecture: TExpr);
    procedure bitvector_example1_;
    procedure bitvector_example2_;
    procedure capi_example;
    procedure eval_example1_;
    procedure two_contexts_example1_;
    procedure error_example_;
    procedure numeral_example_;
    procedure ite_example_;
    procedure ite_example2_;
    procedure quantifier_example;
    procedure unsat_core_example1;
    procedure unsat_core_example2;
    procedure unsat_core_example3;
    procedure TestClass;
    procedure tactic_example1;
    procedure tactic_example2;
    procedure tactic_example3;
    procedure tactic_example4;
    procedure tactic_example5;
    procedure tactic_example6;
    procedure tactic_example7;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation
       uses z3_ast_containers,z3_fpa,

       //doh: removed
       //testAsmx86,
       z3.Config,
       z3.model,
       z3.solver,
       z3.tactic,
       z3.func,
       z3.def;

{$R *.lfm}

procedure TMain.reLogChange(Sender: TObject);
begin
   //doh
   //todo
   //SendMessage(reLog.handle, WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure LOG_MSG(msg: PAnsiChar);
begin
    Z3_append_log(msg)
end;

(**
   \brief exit gracefully in case of error.
*)
function exitf(messag : AnsiString): AnsiString;
begin
   Result := Format('BUG: %s.',[messag]);
end;

(**
   \brief exit if unreachable code was reached.
*)
procedure unreachable;
begin
    exitf('unreachable code was reached');
end;

(**
   \brief Simpler error handler.
 *)
//doh
procedure error_handler(c : Z3_context; e: Z3_error_code) ; cdecl;
var s : AnsiString;// := Format('Error code: %d',[ Ord(e) ])+ sLineBreak;
begin
   //var s : AnsiString := Format('Error code: %d',[ Ord(e) ])+ sLineBreak;
   s  := Format('Error code: %d',[ Ord(e) ])+ sLineBreak;
    exitf(s + 'incorrect use of Z3');
end;


//doh
procedure throw_z3_error(c : Z3_context; e: Z3_error_code) ;cdecl;
var s : AnsiString;// := Format('Error code: %d',[ Ord(e) ])+ sLineBreak;

begin
   //var s : AnsiString := Format('Error code: %d',[ Ord(e) ])+ sLineBreak;
   s := Format('Error code: %d',[ Ord(e) ])+ sLineBreak;
   exitf(s + 'longjmp');
end;


procedure nothrow_z3_error(c : Z3_context; e: Z3_error_code) ; cdecl;
begin
    ShowMessage(Format('Z3 error: %s.', [Z3_get_error_msg(c, e)]));
end;


(**

   \brief Display Z3 version in the standard output.
*)
function display_version:AnsiString;
var major, minor, build, revision : Cardinal;
begin
   //var major, minor, build, revision : Cardinal;
   //var major, minor, build, revision : Cardinal;
    Z3_get_version(@major, @minor, @build, @revision);
    result := format('Z3 %d.%d.%d.%d',[ major, minor, build, revision]);
end;

(**
   \brief Create a logical context.

   Enable model construction. Other configuration parameters can be passed in the cfg variable.

   Also enable tracing to stderr and register custom error handler.
*)
function mk_context_custom(cfg :Z3_config ; err: Z3_error_handler ):Z3_context;
var
  ctx : Z3_context;
begin
    Z3_set_param_value(cfg, 'model', 'true');

    ctx := Z3_mk_context(cfg);
    Z3_set_error_handler(ctx, err);

    Result := ctx;
end;


(**
   \brief Create a logical context.

   Enable model construction only.

   Also enable tracing to stderr and register standard error handler.
*)
function mk_context:Z3_context;
var
  cfg : Z3_config;
  ctx : Z3_context;

begin
    cfg := Z3_mk_config;
    ctx := mk_context_custom(cfg, error_handler);
    Z3_del_config(cfg);

    Result := ctx;
end;

(**
   \brief Create a logical context.

   Enable fine-grained proof construction.
   Enable model construction.

   Also enable tracing to stderr and register standard error handler.
*)
function mk_proof_context: Z3_context;
var
  cfg : Z3_config;
  ctx : Z3_context;

begin
    cfg := Z3_mk_config();
    Z3_set_param_value(cfg, 'proof', 'true');
    ctx := mk_context_custom(cfg, throw_z3_error);
    Z3_del_config(cfg);
    Result := ctx;
end;

function mk_solver(ctx: Z3_context): Z3_solver;
var
  s : Z3_solver;
begin
    s := Z3_mk_solver(ctx);
    Z3_solver_inc_ref(ctx, s);
    Result := s;
end;

procedure del_solver(ctx: Z3_context; s: Z3_solver) ;
begin
    Z3_solver_dec_ref(ctx, s);
end;

(**
   \brief Create a variable using the given name and type.
*)
//doh
function mk_var(ctx: Z3_context; name: AnsiString; ty: Z3_sort): Z3_ast;
var s : Z3_symbol;// := Z3_mk_string_symbol(ctx, PAnsiChar(name));
begin
   //var s : Z3_symbol := Z3_mk_string_symbol(ctx, PAnsiChar(name));
   s := Z3_mk_string_symbol(ctx, PAnsiChar(name));
    Result := Z3_mk_const(ctx, s, ty);
end;

(**
   \brief Create a boolean variable using the given name.
*)
//doh
function mk_bool_var(ctx: Z3_context;name: AnsiString): Z3_ast;
var ty : Z3_sort;// := Z3_mk_bool_sort(ctx);
begin
   //var ty : Z3_sort := Z3_mk_bool_sort(ctx);
   ty  := Z3_mk_bool_sort(ctx);
   Result :=  mk_var(ctx, name, ty);
end;

(**
   \brief Create an integer variable using the given name.
*)
//doh
function mk_int_var(ctx: Z3_context;name: AnsiString) : Z3_ast;
var ty : Z3_sort;// := Z3_mk_int_sort(ctx);
begin
   //var ty : Z3_sort := Z3_mk_int_sort(ctx);
   ty  := Z3_mk_int_sort(ctx);
   Result :=  mk_var(ctx, name, ty);
end;

(**
   \brief Create a Z3 integer node using a C int.
*)
//doh
function mk_int(ctx : Z3_context; v: Integer) : Z3_ast;
var ty : Z3_sort;// := Z3_mk_int_sort(ctx);
begin
   //var ty : Z3_sort := Z3_mk_int_sort(ctx);
   ty := Z3_mk_int_sort(ctx);
   Result := Z3_mk_int(ctx, v, ty);
end;

(**
   \brief Create a real variable using the given name.
*)
//doh
function mk_real_var(ctx: Z3_context; name: AnsiString): Z3_ast;
var ty : Z3_sort;// := Z3_mk_real_sort(ctx);
begin
   //var ty : Z3_sort := Z3_mk_real_sort(ctx);
   ty  := Z3_mk_real_sort(ctx);
   Result := mk_var(ctx, name, ty);
end;


(**
   \brief Create the unary function application: <tt>(f x)</tt>.
*)
function mk_unary_app(ctx: Z3_context; f: Z3_func_decl; x: Z3_ast): Z3_ast;
var
  args : array[0..0] of Z3_ast;
begin
    args[0] := x;
    Result := Z3_mk_app(ctx, f, 1, @args[0]);
end;

(**
   \brief Create the binary function application: <tt>(f x y)</tt>.
*)
function mk_binary_app(ctx: Z3_context; f : Z3_func_decl; x: Z3_ast; y: Z3_ast): Z3_ast;
var
  args : array[0..1] of Z3_ast;
begin
    args[0] := x;
    args[1] := y;
    Result := Z3_mk_app(ctx, f, 2, @args[0]);
end;

(**
   \brief Check whether the logical context is satisfiable, and compare the result with the expected result.
   If the context is satisfiable, then display the model.
*)
//doh
procedure TMain.check(ctx: Z3_context; s: Z3_solver; expected_result: Z3_lbool);
var
 stmp : AnsiString ;
var m   : Z3_model;//  := 0;
var res : Z3_lbool;//  := Z3_solver_check(ctx, s);

begin
   //var m   : Z3_model  := 0;
   //var res : Z3_lbool  := Z3_solver_check(ctx, s);
   m    := 0;
   res  := Z3_solver_check(ctx, s);
    case res of
      Z3_L_FALSE: begin
          relog.Lines.Append('unsat.');

           end;
      Z3_L_UNDEF: begin
          relog.Lines.Append('unknown');
	        m := Z3_solver_get_model(ctx, s);
	        if (m) <> nil then
             Z3_model_inc_ref(ctx, m);
          relog.Lines.Append(Format('potential model:'+sLineBreak+'%s', [Z3_model_to_string(ctx, m)]));
      end;
      Z3_L_TRUE: begin
	        m := Z3_solver_get_model(ctx, s);
	        if (m) <> nil then
             Z3_model_inc_ref(ctx, m);
          stmp := Z3_model_to_string(ctx, m);
          relog.Lines.Append(Format('sat.'+ sLineBreak+'%s', [Z3_model_to_string(ctx, m)]));
      end;
    end;

    if (res <> expected_result) then
         relog.Lines.Append(exitf('unexpected result'));

    if (m) <> nil then
        Z3_model_dec_ref(ctx, m);
end;

(**
   \brief Display a symbol in the given output stream.
*)
function TMain.display_symbol(c : Z3_context;  s: Z3_symbol):AnsiString;
begin
    Result := '';
    case Z3_get_symbol_kind(c, s) of
     Z3_INT_SYMBOL   : Result := Format('#%d', [Z3_get_symbol_int   (c, s)]);
     Z3_STRING_SYMBOL: Result := Format('%s',  [Z3_get_symbol_string(c, s)]);
    else
        unreachable;
    end;
end;

(**
   \brief Display the given type.
*)
//doh
function TMain.display_sort(c: Z3_context;  ty:Z3_sort): AnsiString;
var num_fields : Cardinal;// := Z3_get_tuple_sort_num_fields(c, ty);
var i : Integer;
var field : Z3_func_decl;// := Z3_get_tuple_sort_field_decl(c, ty, i);


begin
    Result := '';

    case Z3_get_sort_kind(c, ty) of
      Z3_UNINTERPRETED_SORT: Result := Result + display_symbol(c, Z3_get_sort_name(c, ty));
      Z3_BOOL_SORT         : Result := Result + 'bool';
      Z3_INT_SORT          : Result := Result + 'int';
      Z3_REAL_SORT         : Result := Result + 'real';
      Z3_BV_SORT           : Result := Result + Format('bv%d', [Z3_get_bv_sort_size(c, ty)]);
      Z3_ARRAY_SORT: begin
          Result := Result + '[';
          Result := Result + display_sort(c, Z3_get_array_sort_domain(c, ty));
          Result := Result + '->';
          Result := Result + display_sort(c, Z3_get_array_sort_range(c, ty));
          Result := Result + ']';
      end;
      Z3_DATATYPE_SORT: begin
          if Z3_get_datatype_sort_num_constructors(c, ty) <> 1 then
          begin
              Result := Result + Format('%s', [Z3_sort_to_string(c,ty)]);
          end else
          begin
              //var num_fields : Cardinal := Z3_get_tuple_sort_num_fields(c, ty);
              //var i : Integer;
              num_fields := Z3_get_tuple_sort_num_fields(c, ty);
              //var i : Integer;
              Result := Result +  '(';
              for i := 0 to num_fields - 1 do
              begin
                  //var field : Z3_func_decl := Z3_get_tuple_sort_field_decl(c, ty, i);
                  field := Z3_get_tuple_sort_field_decl(c, ty, i);
                  if (i > 0) then
                      Result := Result +  ', ';

                  Result := Result + display_sort(c, Z3_get_range(c, field));
              end;
              Result := Result +  ')';
          end;
      end;
      else begin
          Result := Result + '"unknown[';
          Result := Result + display_symbol(c, Z3_get_sort_name(c, ty));
          Result := Result +']';
      end;
    end;

end;

(**
   \brief Custom ast pretty printer.

   This function demonstrates how to use the API to navigate terms.
*)
//doh
function TMain.display_ast(c: Z3_context; v: Z3_ast): AnsiString ;
var i         : Cardinal;
var app       : Z3_app;//       := Z3_to_app(c, v);
var num_fields: Cardinal;//     := Z3_get_app_num_args(c, app);
var d         : Z3_func_decl;// := Z3_get_app_decl(c, app);
var t : Z3_sort;
begin
    Result := '';

    case Z3_get_ast_kind(c, v) of
     Z3_NUMERAL_AST:begin
        //var t : Z3_sort;
        //var t : Z3_sort;
        Result := Result + Format('%s', [Z3_get_numeral_string(c, v)]);
        t := Z3_get_sort(c, v);
        Result := Result + ':';
        Result := Result + display_sort(c, t);
     end;
     Z3_APP_AST:begin
         //var i         : Cardinal;
         //var app       : Z3_app       := Z3_to_app(c, v);
         //var num_fields: Cardinal     := Z3_get_app_num_args(c, app);
         //var d         : Z3_func_decl := Z3_get_app_decl(c, app);
         //var i         : Cardinal;
         app             := Z3_to_app(c, v);
         num_fields      := Z3_get_app_num_args(c, app);
         d               := Z3_get_app_decl(c, app);

        Result := Result + Format('%s', [Z3_func_decl_to_string(c, d)]);

        if (num_fields > 0) then
        begin
            Result := Result + '[';
            for i := 0 to num_fields - 1 do
            begin
                if (i > 0) then
                    Result := Result +', ';

                Result := Result + display_ast(c, Z3_get_app_arg(c, app, i));
            end;
            Result := Result + ']';
        end;
     end;
     Z3_QUANTIFIER_AST: Result := Result +'quantifier#unknown' ;

    else
     Result := Result + '#unknown';
    end;
end;

(**
   \brief Custom function interpretations pretty printer.
*)
//doh
function TMain.display_function_interpretations(c: Z3_context; m: Z3_model): AnsiString;
var
  num_functions : Cardinal;
  i             : Integer;
var fdecl      : Z3_func_decl;
var name       : Z3_symbol;
var func_else  : Z3_ast;
var num_entries: Cardinal;// := 0;
var j          : Integer;//  := 0;
var finterp    : Z3_func_interp_opt;

var num_args    : Cardinal;
var k           : Integer;
var fentry      : Z3_func_entry;// := Z3_func_interp_get_entry(c, finterp, j);

begin
    Result := '';

    Result := 'function interpretations:' + sLineBreak;

    num_functions := Z3_model_get_num_funcs(c, m);

    for i := 0 to num_functions - 1 do
    begin
        //var fdecl      : Z3_func_decl;
        //var name       : Z3_symbol;
        //var func_else  : Z3_ast;
        //var num_entries: Cardinal := 0;
        //var j          : Integer  := 0;
        //var finterp    : Z3_func_interp_opt;
        //var fdecl      : Z3_func_decl;
        //var name       : Z3_symbol;
        //var func_else  : Z3_ast;
        num_entries := 0;
        j           := 0;
        //var finterp    : Z3_func_interp_opt;

        fdecl  := Z3_model_get_func_decl(c, m, i);
        finterp:= Z3_model_get_func_interp(c, m, fdecl);
        //  inc ref
	      Z3_func_interp_inc_ref(c, finterp);
        name   := Z3_get_decl_name(c, fdecl);
        Result := Result + display_symbol(c, name);
        Result := Result + ' = {';
        if finterp <> nil then
          num_entries := Z3_func_interp_get_num_entries(c, finterp);

        for j := 0 to num_entries - 1 do
        begin
            //var num_args    : Cardinal;
            //var k           : Integer;
            //var fentry      : Z3_func_entry := Z3_func_interp_get_entry(c, finterp, j);
            //var num_args    : Cardinal;
            //var k           : Integer;
            fentry       := Z3_func_interp_get_entry(c, finterp, j);
            // inc ref
	          Z3_func_entry_inc_ref(c, fentry);
            if (j > 0) then
                Result := Result + ', ';

            num_args := Z3_func_entry_get_num_args(c, fentry);
            Result := Result + '(';
            for k := 0 to num_args - 1 do
            begin
                if (k > 0) then
                     Result := Result +', ';

                Result := Result + display_ast(c, Z3_func_entry_get_arg(c, fentry, k));
            end;
            Result := Result + '|->';
            Result := Result + display_ast(c, Z3_func_entry_get_value(c, fentry));
            Result := Result +')';
            //  dec ref
	          Z3_func_entry_dec_ref(c, fentry);
        end;
        if (num_entries > 0) then
             Result := Result +', ';

        Result := Result + '(else|->';
        func_else := Z3_func_interp_get_else(c, finterp);
        Result := Result + display_ast(c, func_else);
        Result := Result  +')}'+ sLineBreak;
        // dec ref
	      Z3_func_interp_dec_ref(c, finterp);
    end;
end;


(**
   \brief Custom model pretty printer.
*)
//doh
function TMain.display_model(c: Z3_context; m: Z3_model): AnsiString;
var name : Z3_symbol;
var cnst : Z3_func_decl;// := Z3_model_get_const_decl(c, m, i);
var a, v : Z3_ast;
var ok   : Boolean;
var num_constants : Cardinal;
var i             : Integer ;
begin
   //var num_constants : Cardinal;
   //var i             : Integer ;
   //var num_constants : Cardinal;
   //var i             : Integer ;

    Result := '';

    if (m = nil) then Exit;

    num_constants := Z3_model_get_num_consts(c, m);
    for i := 0 to num_constants - 1 do
    begin
       //var name : Z3_symbol;
       //var cnst : Z3_func_decl := Z3_model_get_const_decl(c, m, i);
       //var a, v : Z3_ast;
       //var ok   : Boolean;
       //var name : Z3_symbol;
       cnst := Z3_model_get_const_decl(c, m, i);
       //var a, v : Z3_ast;
       //var ok   : Boolean;

        name   := Z3_get_decl_name(c, cnst);

        Result := Result + display_symbol(c, name);
        Result := Result + ' = ';

        a := Z3_mk_app(c, cnst, 0, 0);
        v := a;
        ok := Z3_model_eval(c, m, a, True, @v);

        Result := Result + display_ast(c, v);
        Result := Result + sLineBreak;;
    end;
    Result := Result + display_function_interpretations(c, m);
end;


(**
   \brief Similar to #check, but uses #display_model instead of #Z3_model_to_string.
*)
//doh
procedure TMain.check2(ctx : Z3_context; s: Z3_solver; expected_result: Z3_lbool);
var m   : Z3_model;//  := 0;
var res : Z3_lbool;//  := Z3_solver_check(ctx, s);
begin
   //var m   : Z3_model  := 0;
   //var res : Z3_lbool  := Z3_solver_check(ctx, s);
   m     := 0;
   res   := Z3_solver_check(ctx, s);
    case res of
     Z3_L_FALSE: begin
        relog.Lines.Append('unsat');
                 end;
     Z3_L_UNDEF:begin
        relog.Lines.Append('unknown');
        relog.Lines.Append('potential model:');
        m := Z3_solver_get_model(ctx, s);
	      if (m <> nil) then
          Z3_model_inc_ref(ctx, m);
         relog.Lines.Append(display_model(ctx, m));
     end;
     Z3_L_TRUE:begin
        relog.Lines.Append('sat');
        m := Z3_solver_get_model(ctx, s);
	      if (m <> nil) then
          Z3_model_inc_ref(ctx, m);
         relog.Lines.Append(display_model(ctx, m));
     end;
    end;
    if (res <> expected_result) then
        exitf('unexpected result');

    if (m <> nil)  then
       Z3_model_dec_ref(ctx, m);

end;

(**
   \brief Prove that the constraints already asserted into the logical
   context implies the given formula.  The result of the proof is
   displayed.

   Z3 is a satisfiability checker. So, one can prove \c f by showing
   that <tt>(not f)</tt> is unsatisfiable.

   The context \c ctx is not modified by this function.
*)
//doh
procedure TMain.prove(ctx: Z3_context; s: Z3_solver; f: Z3_ast; is_valid: Boolean);
var m     : Z3_model;//  := 0;
var not_f : Z3_ast;

begin
    //var m     : Z3_model  := 0;
    //var not_f : Z3_ast;
    m     := 0;
    //var not_f : Z3_ast;

    (* save the current state of the context *)
    Z3_solver_push(ctx, s);

    not_f := Z3_mk_not(ctx, f);
    Z3_solver_assert(ctx, s, not_f);

    case Z3_solver_check(ctx, s) of
     Z3_L_FALSE: begin
        (* proved *)
        relog.Lines.Append('valid');
        if  not is_valid then
            exitf('unexpected result');
     end;
     Z3_L_UNDEF:begin
        (* Z3 failed to prove/disprove f. *)
        relog.Lines.Append('unknown');
        m := Z3_solver_get_model(ctx, s);
        if (m <> nil) then
        begin
	          Z3_model_inc_ref(ctx, m);
            (* m should be viewed as a potential counterexample. *)
  	        relog.Lines.Append(Format('potential counter example:' +sLineBreak + '%s', [Z3_model_to_string(ctx, m)]));
        end;
        if is_valid  then
            exitf('unexpected result');
     end;
     Z3_L_TRUE:begin
        (* disproved *)
        relog.Lines.Append('invalid');
        m := Z3_solver_get_model(ctx, s);
        if (m <> nil) then
        begin
	          Z3_model_inc_ref(ctx, m);
            (* the model returned by Z3 is a counterexample *)
            relog.Lines.Append(Format('counter example:'+ sLineBreak+ '%s', [Z3_model_to_string(ctx, m)]))
        end;
        if (is_valid) then
            exitf('unexpected result');
     end;
    end;
    if (m <> nil) then
       Z3_model_dec_ref(ctx, m);

    (* restore scope *)
    Z3_solver_pop(ctx, s, 1);
end;

(**
   \brief Assert the axiom: function f is injective in the i-th argument.

   The following axiom is asserted into the logical context:
   \code
   forall (x_0, ..., x_n) finv(f(x_0, ..., x_i, ..., x_{n-1})) = x_i
   \endcode

   Where, \c finv is a fresh function declaration.
*)
procedure TMain.assert_inj_axiom(ctx: Z3_context; s: Z3_solver; f : Z3_func_decl; i: Cardinal);
var
  sz, j : Cardinal;
  finv_domain, finv_range : Z3_sort;
  finv                    : Z3_func_decl ;
  types                   : array of Z3_sort;   (* types of the quantified variables *)
  names                   : array of Z3_symbol; (* names of the quantified variables *)
  xs                      : array of Z3_ast;    (* arguments for the application f(x_0, ..., x_i, ..., x_{n-1}) *)
  x_i, fxs, finv_fxs, eq  : Z3_ast;
  p                       : Z3_pattern;
  q                       : Z3_ast;
begin
    sz := Z3_get_domain_size(ctx, f);

    if (i >= sz) then
        exitf('failed to create inj axiom');

    (* declare the i-th inverse of f: finv *)
    finv_domain := Z3_get_range(ctx, f);
    finv_range  := Z3_get_domain(ctx, f, i);
    finv        := Z3_mk_fresh_func_decl(ctx, 'inv', 1, @finv_domain, finv_range);

    (* allocate temporary arrays *)
    SetLength(types, sz);
    SetLength(names, sz);
    SetLength(xs,    sz);

    (* fill types, names and xs *)
    for j := 0 to sz - 1 do  types[j] := Z3_get_domain(ctx, f, j);
    for j := 0 to sz - 1 do  names[j] := Z3_mk_int_symbol(ctx, j);
    for j := 0 to sz - 1 do  xs[j]    := Z3_mk_bound(ctx, j, types[j]);

    x_i := xs[i];

    (* create f(x_0, ..., x_i, ..., x_{n-1}) *)
    fxs         := Z3_mk_app(ctx, f, sz, @xs[0]);

    (* create f_inv(f(x_0, ..., x_i, ..., x_{n-1})) *)
    finv_fxs    := mk_unary_app(ctx, finv, fxs);

    (* create finv(f(x_0, ..., x_i, ..., x_{n-1})) = x_i *)
    eq          := Z3_mk_eq(ctx, finv_fxs, x_i);

    (* use f(x_0, ..., x_i, ..., x_{n-1}) as the pattern for the quantifier *)
    p           := Z3_mk_pattern(ctx, 1, @fxs);
    relog.Lines.Append(Format('pattern: %s', [Z3_pattern_to_string(ctx, p)]));
    relog.Lines.Append('');

    (* create & assert quantifier *)
    q          := Z3_mk_forall(ctx,
                                 0,  (* using default weight *)
                                 1,  (* number of patterns *)
                                 @p, (* address of the "array" of patterns *)
                                 sz, (* number of quantified variables *)
                                 @types[0],
                                 @names[0],
                                 eq);
    relog.Lines.Append('assert axiom:');
    relog.Lines.Append(Format('%s', [Z3_ast_to_string(ctx, q)]));
    Z3_solver_assert(ctx, s, q);

    (* free temporary arrays *)
    SetLength(types, 0);
    SetLength(names, 0);
    SetLength(xs,    0);
end;

(**
   \brief Assert the axiom: function f is commutative.

   This example uses the SMT-LIB parser to simplify the axiom construction.
*)
procedure TMain.assert_comm_axiom(ctx: Z3_context; s: Z3_solver; f: Z3_func_decl);
var
  t             : Z3_sort;
  f_name, t_name: Z3_symbol ;
  q             : Z3_ast_vector ;
  i             : Cardinal;
Begin

    t := Z3_get_range(ctx, f);

    if (Z3_get_domain_size(ctx, f) <> 2) or
       (Z3_get_domain(ctx, f, 0) <> t) or
       (Z3_get_domain(ctx, f, 1) <> t) then
         exitf('function must be binary, and argument types must be equal to return type');


    (* Inside the parser, function f will be referenced using the symbol 'f'. *)
    f_name := Z3_mk_string_symbol(ctx, 'f');

    (* Inside the parser, type t will be referenced using the symbol 'T'. *)
    t_name := Z3_mk_string_symbol(ctx, 'T');

    q := Z3_parse_smtlib2_string(ctx,
                           '(assert (forall ((x T) (y T)) (= (f x y) (f y x))))',
                           1, @t_name, @t,
                           1, @f_name, @f);
    relog.Lines.Append(Format('assert axiom:'+ sLineBreak + '%s', [Z3_ast_vector_to_string(ctx, q)]));
    for i := 0 to Z3_ast_vector_size(ctx, q)  - 1 do
        Z3_solver_assert(ctx, s, Z3_ast_vector_get(ctx, q, i));

end;

(**
   \brief Z3 does not support explicitly tuple updates. They can be easily implemented
   as macros. The argument \c t must have tuple type.
   A tuple update is a new tuple where field \c i has value \c new_val, and all
   other fields have the value of the respective field of \c t.

   <tt>update(t, i, new_val)</tt> is equivalent to
   <tt>mk_tuple(proj_0(t), ..., new_val, ..., proj_n(t))</tt>
*)
//doh
function mk_tuple_update(c: Z3_context; t: Z3_ast; i: Cardinal; new_val: Z3_ast): Z3_ast;
var
  ty            : Z3_sort;
  mk_tuple_decl : Z3_func_decl;
  num_fields, j : Cardinal;
  new_fields    : array of Z3_ast;
  res           : Z3_ast;
var proj_decl : Z3_func_decl;// := Z3_get_tuple_sort_field_decl(c, ty, j);

begin
    ty := Z3_get_sort(c, t);

    if (Z3_get_sort_kind(c, ty) <> Z3_DATATYPE_SORT) then
        exitf('argument must be a tuple');

    num_fields := Z3_get_tuple_sort_num_fields(c, ty);

    if (i >= num_fields) then
        exitf('invalid tuple update, index is too big');

    SetLength(new_fields, num_fields);
    for j := 0 to num_fields - 1 do
    begin
        if i = j then
        begin
            (* use new_val at position i *)
            new_fields[j] := new_val;
        end else
        begin
            (* use field j of t *)
            //var proj_decl : Z3_func_decl := Z3_get_tuple_sort_field_decl(c, ty, j);
            proj_decl := Z3_get_tuple_sort_field_decl(c, ty, j);
            new_fields[j]                := mk_unary_app(c, proj_decl, t);
        end;
    end;
    mk_tuple_decl := Z3_get_tuple_sort_mk_decl(c, ty);
    res           := Z3_mk_app(c, mk_tuple_decl, num_fields, @new_fields[0]);

    SetLength(new_fields,0);
    result := res;
end;

(**********************Procedure start********)
(**
   \brief "Hello world" example: create a Z3 logical context, and delete it.
*)
procedure TMain.simple_example;
var
  ctx : Z3_context;
begin
    LOG_MSG('simple_example');

    relog.Lines.Append(sLineBreak + 'simple_example');

    ctx := mk_context;

    (* delete logical context *)
    Z3_del_context(ctx);
end;

(**
  Demonstration of how Z3 can be used to prove validity of
  De Morgan's Duality Law: {e not(x and y) <-> (not x) or ( not y) }
*)
procedure TMain.demorgan;
var
    cfg      : Z3_config;
    ctx      : Z3_context;
    s        : Z3_solver;
    bool_sort: Z3_sort;
    symbol_x,
    symbol_y : Z3_symbol;
    x, y,
    not_x,
    not_y,
    x_and_y,
    ls, rs,
    conjecture,
    negated_conjecture : Z3_ast;
    args               : array[0..1] of Z3_ast;
begin
    relog.Lines.Append(sLineBreak + 'DeMorgan');
    LOG_MSG('DeMorgan');

    cfg                := Z3_mk_config();
    ctx                := Z3_mk_context(cfg);
    Z3_del_config(cfg);
    bool_sort          := Z3_mk_bool_sort(ctx);
    symbol_x           := Z3_mk_int_symbol(ctx, 0);
    symbol_y           := Z3_mk_int_symbol(ctx, 1);
    x                  := Z3_mk_const(ctx, symbol_x, bool_sort);
    y                  := Z3_mk_const(ctx, symbol_y, bool_sort);

    (* De Morgan - with a negation around *)
    (* !(!(x && y) <-> (!x || !y)) *)
    not_x              := Z3_mk_not(ctx, x);
    not_y              := Z3_mk_not(ctx, y);
    args[0]            := x;
    args[1]            := y;
    x_and_y            := Z3_mk_and(ctx, 2, @args[0]);
    ls                 := Z3_mk_not(ctx, x_and_y);
    args[0]            := not_x;
    args[1]            := not_y;
    rs                 := Z3_mk_or(ctx, 2, @args[0]);
    conjecture         := Z3_mk_iff(ctx, ls, rs);
    negated_conjecture := Z3_mk_not(ctx, conjecture);

    s := mk_solver(ctx);
    Z3_solver_assert(ctx, s, negated_conjecture);
    case Z3_solver_check(ctx, s) of
      Z3_L_FALSE: begin
        (* The negated conjecture was unsatisfiable, hence the conjecture is valid *)
        relog.Lines.Append('DeMorgan is valid');
                 end;
      Z3_L_UNDEF: begin
        (* Check returned undef *)
        relog.Lines.Append('Undef');
         end;
      Z3_L_TRUE: begin
        (* The negated conjecture was satisfiable, hence the conjecture is not valid *)
        relog.Lines.Append('DeMorgan is not valid');
          end;

    end;
    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Find a model for <tt>x xor y</tt>.
*)
procedure TMain.find_model_example1;
var
  ctx           : Z3_context;
  x, y, x_xor_y : Z3_ast;
  s             : Z3_solver;
begin
    relog.Lines.Append(sLineBreak + 'find_model_example1');
    LOG_MSG('find_model_example1');

    ctx     := mk_context();
    s       := mk_solver(ctx);

    x       := mk_bool_var(ctx, 'x');
    y       := mk_bool_var(ctx, 'y');
    x_xor_y := Z3_mk_xor(ctx, x, y);

    Z3_solver_assert(ctx, s, x_xor_y);

    relog.Lines.Append('model for: x xor y');
    check(ctx, s, Z3_L_TRUE);

    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Find a model for <tt>x < y + 1, x > 2</tt>.
   Then, assert <tt>not(x = y)</tt>, and find another model.
*)
procedure TMain.find_model_example2;
var
  ctx            : Z3_context;
  x, y, one, two,
  y_plus_one     : Z3_ast;
  x_eq_y         : Z3_ast;
  args           : array[0..1] of Z3_ast;
  c1, c2, c3     : Z3_ast;
  s              : Z3_solver;
begin
    relog.Lines.Append(sLineBreak + 'find_model_example2');
    LOG_MSG('find_model_example2');

    ctx        := mk_context();
    s          := mk_solver(ctx);
    x          := mk_int_var(ctx, 'x');
    y          := mk_int_var(ctx, 'y');
    one        := mk_int(ctx, 1);
    two        := mk_int(ctx, 2);

    args[0]    := y;
    args[1]    := one;
    y_plus_one := Z3_mk_add(ctx, 2, @args[0]);

    c1         := Z3_mk_lt(ctx, x, y_plus_one);
    c2         := Z3_mk_gt(ctx, x, two);

    Z3_solver_assert(ctx, s, c1);
    Z3_solver_assert(ctx, s, c2);

    relog.Lines.Append('model for: x < y + 1, x > 2');
    check(ctx, s, Z3_L_TRUE);

    (* assert not(x = y) *)
    x_eq_y     := Z3_mk_eq(ctx, x, y);
    c3         := Z3_mk_not(ctx, x_eq_y);
    Z3_solver_assert(ctx, s,c3);

    relog.Lines.Append('model for: x < y + 1, x > 2, not(x = y)');
    check(ctx, s, Z3_L_TRUE);

    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Prove <tt>x = y implies g(x) = g(y)</tt>, and
   disprove <tt>x = y implies g(g(x)) = g(y)</tt>.

   This function demonstrates how to create uninterpreted types and
   functions.
*)
procedure TMain.prove_example1;
var
  ctx    : Z3_context;
  s      : Z3_solver;
  U_name,
  g_name,
  x_name,
  y_name : Z3_symbol;
  U      : Z3_sort;
  g_domain : array[0..0] of Z3_sort;
  g      : Z3_func_decl;
  x, y,
  gx, ggx,
  gy     : Z3_ast;
  eq, f  : Z3_ast;
begin
    relog.Lines.Append(sLineBreak + 'prove_example1');
    LOG_MSG('prove_example1');

    ctx        := mk_context();
    s          := mk_solver(ctx);

    (* create uninterpreted type. *)
    U_name     := Z3_mk_string_symbol(ctx, 'U');
    U          := Z3_mk_uninterpreted_sort(ctx, U_name);

    (* declare function g *)
    g_name      := Z3_mk_string_symbol(ctx, 'g');
    g_domain[0] := U;
    g           := Z3_mk_func_decl(ctx, g_name, 1, @g_domain[0], U);

    (* create x and y *)
    x_name      := Z3_mk_string_symbol(ctx, 'x');
    y_name      := Z3_mk_string_symbol(ctx, 'y');
    x           := Z3_mk_const(ctx, x_name, U);
    y           := Z3_mk_const(ctx, y_name, U);
    (* create g(x), g(y) *)
    gx          := mk_unary_app(ctx, g, x);
    gy          := mk_unary_app(ctx, g, y);

    (* assert x = y *)
    eq          := Z3_mk_eq(ctx, x, y);
    Z3_solver_assert(ctx, s, eq);

    (* prove g(x) = g(y) *)
    f           := Z3_mk_eq(ctx, gx, gy);
    relog.Lines.Append('prove: x = y implies g(x) = g(y)');
    prove(ctx, s, f, true);

    (* create g(g(x)) *)
    ggx         := mk_unary_app(ctx, g, gx);

    (* disprove g(g(x)) = g(y) *)
    f           := Z3_mk_eq(ctx, ggx, gy);
    relog.Lines.Append('disprove: x = y implies g(g(x)) = g(y)');
    prove(ctx, s, f, false);

    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Prove <tt>not(g(g(x) - g(y)) = g(z)), x + z <= y <= x implies z < 0 </tt>.
   Then, show that <tt>z < -1</tt> is not implied.

   This example demonstrates how to combine uninterpreted functions and arithmetic.
*)
procedure TMain.prove_example2;
var
  ctx      : Z3_context;
  s        : Z3_solver;
  int_sort : Z3_sort;
  g_name   : Z3_symbol;
  g_domain : array[0..0] of Z3_sort;
  g        : Z3_func_decl;
  args     : array[0..1] of Z3_ast;
  x, y, z,
  zero,
  minus_one,
  x_plus_z,
  gx, gy,
  gz, gx_gy,
  ggx_gy   : Z3_ast;
  eq, c1,
  c2, c3, f: Z3_ast;
begin

    relog.Lines.Append(sLineBreak + 'prove_example2');
    LOG_MSG('prove_example2');

    ctx        := mk_context();
    s          := mk_solver(ctx);

    (* declare function g *)
    int_sort    := Z3_mk_int_sort(ctx);
    g_name      := Z3_mk_string_symbol(ctx, 'g');
    g_domain[0] := int_sort;
    g           := Z3_mk_func_decl(ctx, g_name, 1, @g_domain[0], int_sort);

    (* create x, y, and z *)
    x           := mk_int_var(ctx, 'x');
    y           := mk_int_var(ctx, 'y');
    z           := mk_int_var(ctx, 'z');

    (* create gx, gy, gz *)
    gx          := mk_unary_app(ctx, g, x);
    gy          := mk_unary_app(ctx, g, y);
    gz          := mk_unary_app(ctx, g, z);

    (* create zero *)
    zero        := mk_int(ctx, 0);

    (* assert not(g(g(x) - g(y)) = g(z)) *)
    args[0]     := gx;
    args[1]     := gy;
    gx_gy       := Z3_mk_sub(ctx, 2, @args[0]);
    ggx_gy      := mk_unary_app(ctx, g, gx_gy);
    eq          := Z3_mk_eq(ctx, ggx_gy, gz);
    c1          := Z3_mk_not(ctx, eq);
    Z3_solver_assert(ctx, s, c1);

    (* assert x + z <= y *)
    args[0]     := x;
    args[1]     := z;
    x_plus_z    := Z3_mk_add(ctx, 2, @args[0]);
    c2          := Z3_mk_le(ctx, x_plus_z, y);
    Z3_solver_assert(ctx, s, c2);

    (* assert y <= x *)
    c3          := Z3_mk_le(ctx, y, x);
    Z3_solver_assert(ctx, s, c3);

    (* prove z < 0 *)
    f           := Z3_mk_lt(ctx, z, zero);
    relog.Lines.Append('prove: not(g(g(x) - g(y)) = g(z)), x + z <= y <= x implies z < 0');
    prove(ctx, s, f, true);

    (* disprove z < -1 *)
    minus_one   := mk_int(ctx, -1);
    f           := Z3_mk_lt(ctx, z, minus_one);
    relog.Lines.Append('disprove: not(g(g(x) - g(y)) = g(z)), x + z <= y <= x implies z < -1');
    prove(ctx, s, f, false);

    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Show how push & pop can be used to create "backtracking"
   points.

   This example also demonstrates how big numbers can be created in Z3.
*)
procedure TMain.push_pop_example1;
var
  ctx     : Z3_context ;
  s       : Z3_solver ;
  int_sort: Z3_sort;
  x_sym,
  y_sym   : Z3_symbol ;
  x, y,
  big_number,
  three   : Z3_ast ;
  c1, c2,
  c3      : Z3_ast;
begin
    relog.Lines.Append(sLineBreak + 'push_pop_example1');
    LOG_MSG('push_pop_example1');

    ctx        := mk_context();
    s          := mk_solver(ctx);

    (* create a big number *)
    int_sort   := Z3_mk_int_sort(ctx);
    big_number := Z3_mk_numeral(ctx, '1000000000000000000000000000000000000000000000000000000', int_sort);

    (* create number 3 *)
    three      := Z3_mk_numeral(ctx, '3', int_sort);

    (* create x *)
    x_sym      := Z3_mk_string_symbol(ctx, 'x');
    x          := Z3_mk_const(ctx, x_sym, int_sort);

    (* assert x >= "big number" *)
    c1         := Z3_mk_ge(ctx, x, big_number);
    relog.Lines.Append('assert: x >= "big number"');
    Z3_solver_assert(ctx, s, c1);

    (* create a backtracking point *)
    relog.Lines.Append('push');
    Z3_solver_push(ctx, s);

    relog.Lines.Append(Format('number of scopes: %d', [Z3_solver_get_num_scopes(ctx, s)]));

    (* assert x <= 3 *)
    c2         := Z3_mk_le(ctx, x, three);
    relog.Lines.Append('assert: x <= 3');
    Z3_solver_assert(ctx, s, c2);

    (* context is inconsistent at this point *)
    check2(ctx, s, Z3_L_FALSE);

    (* backtrack: the constraint x <= 3 will be removed, since it was
       asserted after the last Z3_solver_push. *)
    relog.Lines.Append('pop');
    Z3_solver_pop(ctx, s, 1);

    relog.Lines.Append(Format('number of scopes: %d', [Z3_solver_get_num_scopes(ctx, s)]));


    (* the context is consistent again. *)
    check2(ctx, s, Z3_L_TRUE);

    (* new constraints can be asserted... *)

    (* create y *)
    y_sym      := Z3_mk_string_symbol(ctx, 'y');
    y          := Z3_mk_const(ctx, y_sym, int_sort);

    (* assert y > x *)
    c3         := Z3_mk_gt(ctx, y, x);
    relog.Lines.Append('assert: y > x');
    Z3_solver_assert(ctx, s, c3);

    (* the context is still consistent. *)
    check2(ctx, s, Z3_L_TRUE);

    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Prove that <tt>f(x, y) = f(w, v) implies y = v</tt> when
   \c f is injective in the second argument.

   \sa assert_inj_axiom.
*)
procedure TMain.quantifier_example1;
var
  cfg                  : Z3_config;
  ctx                  : Z3_context;
  s                    : Z3_solver;
  int_sort             : Z3_sort;
  f_name               : Z3_symbol;
  f_domain             : array[0..1] of Z3_sort;
  f                    : Z3_func_decl;
  x, y, w, v, fxy, fwv : Z3_ast;
  p1, p2, p3, not_p3   : Z3_ast;
begin
    relog.Lines.Append('quantifier_example1');
    LOG_MSG('quantifier_example1');

    cfg := Z3_mk_config();
    (* If quantified formulas are asserted in a logical context, then
       Z3 may return L_UNDEF. In this case, the model produced by Z3 should be viewed as a potential/candidate model.
    *)

    (*
       The current model finder for quantified formulas cannot handle injectivity.
       So, we are limiting the number of iterations to avoid a long "wait".
    *)
    Z3_global_param_set('smt.mbqi.max_iterations', '10');
    ctx := mk_context_custom(cfg, error_handler);
    Z3_del_config(cfg);
    s := mk_solver(ctx);

    (* declare function f *)
    int_sort    := Z3_mk_int_sort(ctx);
    f_name      := Z3_mk_string_symbol(ctx, 'f');
    f_domain[0] := int_sort;
    f_domain[1] := int_sort;
    f           := Z3_mk_func_decl(ctx, f_name, 2, @f_domain[0], int_sort);

    (* assert that f is injective in the second argument. *)
    assert_inj_axiom(ctx, s, f, 1);

    (* create x, y, v, w, fxy, fwv *)
    x           := mk_int_var(ctx, 'x');
    y           := mk_int_var(ctx, 'y');
    v           := mk_int_var(ctx, 'v');
    w           := mk_int_var(ctx, 'w');
    fxy         := mk_binary_app(ctx, f, x, y);
    fwv         := mk_binary_app(ctx, f, w, v);

    (* assert f(x, y) = f(w, v) *)
    p1          := Z3_mk_eq(ctx, fxy, fwv);
    Z3_solver_assert(ctx, s, p1);

    (* prove f(x, y) = f(w, v) implies y = v *)
    p2          := Z3_mk_eq(ctx, y, v);
    relog.Lines.Append('prove: f(x, y) = f(w, v) implies y = v');
    prove(ctx, s, p2, true);

    (* disprove f(x, y) = f(w, v) implies x = w *)
    (* using check2 instead of prove *)
    p3          := Z3_mk_eq(ctx, x, w);
    not_p3      := Z3_mk_not(ctx, p3);
    Z3_solver_assert(ctx, s, not_p3);
    relog.Lines.Append('disprove: f(x, y) = f(w, v) implies x = w');
    relog.Lines.Append('that is: not(f(x, y) = f(w, v) implies x = w) is satisfiable');
    check2(ctx, s, Z3_L_UNDEF);
    relog.Lines.Append(Format('reason for last failure: %s',  [Z3_solver_get_reason_unknown(ctx, s)]));
    del_solver(ctx, s);
    Z3_del_context(ctx);
    (* reset global parameters set by this function *)
    Z3_global_param_reset_all;
end;

(**
   \brief Prove <tt>store(a1, i1, v1) = store(a2, i2, v2) implies (i1 = i3 or i2 = i3 or select(a1, i3) = select(a2, i3))</tt>.

   This example demonstrates how to use the array theory.
*)
procedure TMain.array_example1;
var
  ds                   : array[0..2] of  Z3_ast;
  int_sort, array_sort : Z3_sort;
  a1, a2, i1, v1, i2, v2, i3 : Z3_ast;
  st1, st2, sel1, sel2       : Z3_ast;
  antecedent, consequent     : Z3_ast;
  thm                        : Z3_ast;
var ctx                 : Z3_context;// := mk_context;
var s                   : Z3_solver;//  := mk_solver(ctx);
begin
    ctx                 := mk_context;
    s                   := mk_solver(ctx);
    ctx                 := mk_context;
    s                   := mk_solver(ctx);

    relog.Lines.Append(sLineBreak+ 'array_example1');
    LOG_MSG('array_example1');

    int_sort    := Z3_mk_int_sort(ctx);
    array_sort  := Z3_mk_array_sort(ctx, int_sort, int_sort);

    a1          := mk_var(ctx, 'a1', array_sort);
    a2          := mk_var(ctx, 'a2', array_sort);
    i1          := mk_var(ctx, 'i1', int_sort);
    i2          := mk_var(ctx, 'i2', int_sort);
    i3          := mk_var(ctx, 'i3', int_sort);
    v1          := mk_var(ctx, 'v1', int_sort);
    v2          := mk_var(ctx, 'v2', int_sort);

    st1         := Z3_mk_store(ctx, a1, i1, v1);
    st2         := Z3_mk_store(ctx, a2, i2, v2);

    sel1        := Z3_mk_select(ctx, a1, i3);
    sel2        := Z3_mk_select(ctx, a2, i3);

    (* create antecedent *)
    antecedent  := Z3_mk_eq(ctx, st1, st2);

    (* create consequent: i1 = i3 or  i2 = i3 or select(a1, i3) = select(a2, i3) *)
    ds[0]       := Z3_mk_eq(ctx, i1, i3);
    ds[1]       := Z3_mk_eq(ctx, i2, i3);
    ds[2]       := Z3_mk_eq(ctx, sel1, sel2);
    consequent  := Z3_mk_or(ctx, 3, @ds[0]);

    (* prove store(a1, i1, v1) = store(a2, i2, v2) implies (i1 = i3 or i2 = i3 or select(a1, i3) = select(a2, i3)) *)
    thm         := Z3_mk_implies(ctx, antecedent, consequent);
    relog.Lines.Append('prove: store(a1, i1, v1) = store(a2, i2, v2) implies (i1 = i3 or i2 = i3 or select(a1, i3) = select(a2, i3))');
    relog.Lines.Append(Format('%s', [Z3_ast_to_string(ctx, thm)]));
    prove(ctx, s, thm, true);

    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Show that <tt>distinct(a_0, ... , a_n)</tt> is
   unsatisfiable when \c a_i's are arrays from boolean to
   boolean and n > 4.

   This example also shows how to use the \c distinct construct.
*)
procedure TMain.array_example2;
var
  ctx        : Z3_context ;
  s          : Z3_solver;
  bool_sort,
  array_sort : Z3_sort;
  a          : array[0..4] of Z3_ast;
  d          : Z3_ast;
  i, n       : Integer;
var ss : Z3_symbol;// := Z3_mk_int_symbol(ctx, i);

begin
    relog.Lines.Append(sLineBreak+ 'array_example2');
    LOG_MSG('array_example2');

    for n := 2 to 5 do
    begin
        relog.Lines.Append(Format('n = %d', [n]));
        ctx := mk_context();
        s   := mk_solver(ctx);

        bool_sort   := Z3_mk_bool_sort(ctx);
        array_sort  := Z3_mk_array_sort(ctx, bool_sort, bool_sort);

        (* create arrays *)
        for i := 0 to n - 1 do
        begin
            //var ss : Z3_symbol := Z3_mk_int_symbol(ctx, i);
            ss   := Z3_mk_int_symbol(ctx, i);
            a[i] := Z3_mk_const(ctx, ss, array_sort);
        end;

        (* assert distinct(a[0], ..., a[n]) *)
        d := Z3_mk_distinct(ctx, n, @a[0]);
        relog.Lines.Append(Format('%s', [Z3_ast_to_string(ctx, d)]));
        Z3_solver_assert(ctx, s, d);

        (* context is satisfiable if n < 5 *)
        if    (n) < 5 then check2(ctx, s, Z3_L_TRUE )
        else               check2(ctx, s, Z3_L_FALSE );

	      del_solver(ctx, s);
        Z3_del_context(ctx);
    end;
end;

(**
   \brief Simple array type construction/deconstruction example.
*)
//doh
procedure TMain.array_example3;
var
   bool_sort, int_sort, array_sort : Z3_sort;
   domain, range                   : Z3_sort;
var ctx : Z3_context;// := mk_context;
var s   : Z3_solver;//  := mk_solver(ctx);

begin
    relog.Lines.Append(sLineBreak+ 'array_example3');
    LOG_MSG('array_example3');

    //var ctx : Z3_context := mk_context;
    //var s   : Z3_solver  := mk_solver(ctx);
    ctx  := mk_context;
    s    := mk_solver(ctx);

    bool_sort  := Z3_mk_bool_sort(ctx);
    int_sort   := Z3_mk_int_sort(ctx);
    array_sort := Z3_mk_array_sort(ctx, int_sort, bool_sort);

    if Z3_get_sort_kind(ctx, array_sort) <> Z3_ARRAY_SORT then
        exitf('type must be an array type');

    domain := Z3_get_array_sort_domain(ctx, array_sort);
    range  := Z3_get_array_sort_range(ctx, array_sort);

    relog.Lines.Append('domain: '+ display_sort(ctx, domain));

    relog.Lines.Append('range:  '+ display_sort(ctx, range));
    relog.Lines.Append('');

	if (int_sort <> domain) or (bool_sort <> range) then
       exitf('invalid array type');


    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Simple tuple type example. It creates a tuple that is a pair of real numbers.
*)
//doh
procedure TMain.tuple_example1;
var
    real_sort, pair_sort  : Z3_sort;
    mk_tuple_name         : Z3_symbol;
    mk_tuple_decl         : Z3_func_decl  ;
    proj_names            : array[0..1] of Z3_symbol;
    proj_sorts            : array[0..1] of Z3_sort;
    proj_decls            : array[0..1] of Z3_func_decl;
    antecedents           : array[0..1] of Z3_ast;
    get_x_decl, get_y_decl: Z3_func_decl;
var ctx : Z3_context;// := mk_context();
var s   : Z3_solver;//  := mk_solver(ctx);
var app1, app2, x, y, one : Z3_ast;
var eq1, eq2, eq3, thm    : Z3_ast;

var p1, p2, x1, x2, y1, y2      : Z3_ast;
var antecedent, consequent {, thm} : Z3_ast;

var {p1, p2, one,} ten, updt{, x, y} : Z3_ast;
//var antecedent, consequent, thm  : Z3_ast;


Begin
    relog.Lines.Append(sLineBreak+ 'tuple_example1');
    LOG_MSG('tuple_example1');

    //var ctx : Z3_context := mk_context();
    //var s   : Z3_solver  := mk_solver(ctx);
    ctx  := mk_context();
    s    := mk_solver(ctx);


    real_sort := Z3_mk_real_sort(ctx);

    (* Create pair (tuple) type *)
    mk_tuple_name := Z3_mk_string_symbol(ctx, 'mk_pair');
    proj_names[0] := Z3_mk_string_symbol(ctx, 'get_x');
    proj_names[1] := Z3_mk_string_symbol(ctx, 'get_y');
    proj_sorts[0] := real_sort;
    proj_sorts[1] := real_sort;
    (* Z3_mk_tuple_sort will set mk_tuple_decl and proj_decls *)
    pair_sort     := Z3_mk_tuple_sort(ctx, mk_tuple_name, 2, @proj_names[0], @proj_sorts[0], @mk_tuple_decl, @proj_decls[0]);
    get_x_decl    := proj_decls[0]; (* function that extracts the first element of a tuple. *)
    get_y_decl    := proj_decls[1]; (* function that extracts the second element of a tuple. *)

    relog.Lines.Append('tuple_sort: '+ display_sort(ctx, pair_sort));
    relog.Lines.Append('');

     begin
        (* prove that get_x(mk_pair(x,y)) == 1 implies x = 1*)
         //var app1, app2, x, y, one : Z3_ast;
         //var eq1, eq2, eq3, thm    : Z3_ast;
         //var app1, app2, x, y, one : Z3_ast;
         //var eq1, eq2, eq3, thm    : Z3_ast;

        x    := mk_real_var(ctx, 'x');
        y    := mk_real_var(ctx, 'y');
        app1 := mk_binary_app(ctx, mk_tuple_decl, x, y);
        app2 := mk_unary_app(ctx, get_x_decl, app1);
        one  := Z3_mk_numeral(ctx, '1', real_sort);
        eq1  := Z3_mk_eq(ctx, app2, one);
        eq2  := Z3_mk_eq(ctx, x, one);
        thm  := Z3_mk_implies(ctx, eq1, eq2);
        relog.Lines.Append('prove: get_x(mk_pair(x, y)) = 1 implies x = 1');
        prove(ctx, s, thm, true);

        (* disprove that get_x(mk_pair(x,y)) == 1 implies y = 1*)
        eq3  := Z3_mk_eq(ctx, y, one);
        thm  := Z3_mk_implies(ctx, eq1, eq3);
        relog.Lines.Append('disprove: get_x(mk_pair(x, y)) = 1 implies y = 1');
        prove(ctx, s, thm, false);
     end;

     begin
        (* prove that get_x(p1) = get_x(p2) and get_y(p1) = get_y(p2) implies p1 = p2 *)
         //var p1, p2, x1, x2, y1, y2      : Z3_ast;
         //var antecedent, consequent, thm : Z3_ast;
         //var p1, p2, x1, x2, y1, y2      : Z3_ast;
         //var antecedent, consequent, thm : Z3_ast;

        p1             := mk_var(ctx, 'p1', pair_sort);
        p2             := mk_var(ctx, 'p2', pair_sort);
        x1             := mk_unary_app(ctx, get_x_decl, p1);
        y1             := mk_unary_app(ctx, get_y_decl, p1);
        x2             := mk_unary_app(ctx, get_x_decl, p2);
        y2             := mk_unary_app(ctx, get_y_decl, p2);
        antecedents[0] := Z3_mk_eq(ctx, x1, x2);
        antecedents[1] := Z3_mk_eq(ctx, y1, y2);
        antecedent     := Z3_mk_and(ctx, 2, @antecedents[0]);
        consequent     := Z3_mk_eq(ctx, p1, p2);
        thm            := Z3_mk_implies(ctx, antecedent, consequent);
        relog.Lines.Append('prove: get_x(p1) = get_x(p2) and get_y(p1) = get_y(p2) implies p1 = p2');
        prove(ctx, s, thm, true);

        (* disprove that get_x(p1) = get_x(p2) implies p1 = p2 *)
        thm            := Z3_mk_implies(ctx, antecedents[0], consequent);
        relog.Lines.Append('disprove: get_x(p1) = get_x(p2) implies p1 = p2');
        prove(ctx, s, thm, false);
     end;

     begin
        (* demonstrate how to use the mk_tuple_update function *)
        (* prove that p2 = update(p1, 0, 10) implies get_x(p2) = 10 *)
         //var p1, p2, one, ten, updt, x, y : Z3_ast;
         //var antecedent, consequent, thm  : Z3_ast;
         //var p1, p2, one, ten, updt, x, y : Z3_ast;
         //var antecedent, consequent, thm  : Z3_ast;

        p1             := mk_var(ctx, 'p1', pair_sort);
        p2             := mk_var(ctx, 'p2', pair_sort);
        one            := Z3_mk_numeral(ctx, '1', real_sort);
        ten            := Z3_mk_numeral(ctx, '10', real_sort);
        updt           := mk_tuple_update(ctx, p1, 0, ten);
        antecedent     := Z3_mk_eq(ctx, p2, updt);
        x              := mk_unary_app(ctx, get_x_decl, p2);
        consequent     := Z3_mk_eq(ctx, x, ten);
        thm            := Z3_mk_implies(ctx, antecedent, consequent);
        relog.Lines.Append('prove: p2 = update(p1, 0, 10) implies get_x(p2) = 10');
        prove(ctx, s, thm, true);

        (* disprove that p2 = update(p1, 0, 10) implies get_y(p2) = 10 *)
        y              := mk_unary_app(ctx, get_y_decl, p2);
        consequent     := Z3_mk_eq(ctx, y, ten);
        thm            := Z3_mk_implies(ctx, antecedent, consequent);
        relog.Lines.Append('disprove: p2 = update(p1, 0, 10) implies get_y(p2) = 10');
        prove(ctx, s, thm, false);
     end;


    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Simple bit-vector example. This example disproves that x - 10 <= 0 IFF x <= 10 for (32-bit) machine integers
*)
//doh
procedure TMain.bitvector_example1;
var
  bv_sort : Z3_sort;
  x, zero, ten, x_minus_ten, c1, c2, thm : Z3_ast;
var ctx : Z3_context;// := mk_context;
var s   : Z3_solver;//  := mk_solver(ctx);
begin
   //var ctx : Z3_context := mk_context;
   //var s   : Z3_solver  := mk_solver(ctx);
   ctx  := mk_context;
   s    := mk_solver(ctx);

    relog.Lines.Append(sLineBreak+ 'bitvector_example1');
    LOG_MSG('bitvector_example1');

    bv_sort   := Z3_mk_bv_sort(ctx, 32);

    x           := mk_var(ctx, 'x', bv_sort);
    zero        := Z3_mk_numeral(ctx, '0', bv_sort);
    ten         := Z3_mk_numeral(ctx, '10', bv_sort);
    x_minus_ten := Z3_mk_bvsub(ctx, x, ten);
    (* bvsle is signed less than or equal to *)
    c1          := Z3_mk_bvsle(ctx, x, ten);
    c2          := Z3_mk_bvsle(ctx, x_minus_ten, zero);
    thm         := Z3_mk_iff(ctx, c1, c2);
    relog.Lines.Append('disprove: x - 10 <= 0 IFF x <= 10 for (32-bit) machine integers');
    prove(ctx, s, thm, false);

    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Find x and y such that: x ^ y - 103 == x * y
*)
//doh
procedure TMain.bitvector_example2;
var bv_sort : Z3_sort;// := Z3_mk_bv_sort(ctx, 32);
var x       : Z3_ast;//  := mk_var(ctx, 'x', bv_sort);
var y       : Z3_ast;//  := mk_var(ctx, 'y', bv_sort);
var x_xor_y : Z3_ast;//  := Z3_mk_bvxor(ctx, x, y);
var c103    : Z3_ast;//  := Z3_mk_numeral(ctx, '103', bv_sort);
var lhs     : Z3_ast;//  := Z3_mk_bvsub(ctx, x_xor_y, c103);
var rhs     : Z3_ast;//  := Z3_mk_bvmul(ctx, x, y);
var ctr     : Z3_ast;//  := Z3_mk_eq(ctx, lhs, rhs);
var ctx : Z3_context;// := mk_context;
var s   : Z3_solver;//  := mk_solver(ctx);

begin
    //var ctx : Z3_context := mk_context;
    //var s   : Z3_solver  := mk_solver(ctx);
    ctx  := mk_context;
    s     := mk_solver(ctx);

    relog.Lines.Append(sLineBreak+ 'bitvector_example2');
    LOG_MSG('bitvector_example2');
    relog.Lines.Append('find values of x and y, such that x ^ y - 103 == x * y');

    (* construct x ^ y - 103 == x * y *)
    //var bv_sort : Z3_sort := Z3_mk_bv_sort(ctx, 32);
    //var x       : Z3_ast  := mk_var(ctx, 'x', bv_sort);
    //var y       : Z3_ast  := mk_var(ctx, 'y', bv_sort);
    //var x_xor_y : Z3_ast  := Z3_mk_bvxor(ctx, x, y);
    //var c103    : Z3_ast  := Z3_mk_numeral(ctx, '103', bv_sort);
    //var lhs     : Z3_ast  := Z3_mk_bvsub(ctx, x_xor_y, c103);
    //var rhs     : Z3_ast  := Z3_mk_bvmul(ctx, x, y);
    //var ctr     : Z3_ast  := Z3_mk_eq(ctx, lhs, rhs);
    bv_sort  := Z3_mk_bv_sort(ctx, 32);
    x         := mk_var(ctx, 'x', bv_sort);
    y         := mk_var(ctx, 'y', bv_sort);
    x_xor_y   := Z3_mk_bvxor(ctx, x, y);
    c103      := Z3_mk_numeral(ctx, '103', bv_sort);
    lhs       := Z3_mk_bvsub(ctx, x_xor_y, c103);
    rhs       := Z3_mk_bvmul(ctx, x, y);
    ctr       := Z3_mk_eq(ctx, lhs, rhs);

    (* add the constraint <tt>x ^ y - 103 == x * y<\tt> to the logical context *)
    Z3_solver_assert(ctx, s, ctr);

    (* find a model (i.e., values for x an y that satisfy the constraint *)
    check(ctx, s, Z3_L_TRUE);

    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Demonstrate how to use #Z3_eval.
*)
procedure TMain.eval_example1;
var
  x, y, two : Z3_ast;
  c1, c2    : Z3_ast;
  args      : array[0..1] of Z3_ast;
var ctx : Z3_context;// := mk_context;
var s   : Z3_solver;//  := mk_solver(ctx);
var m   : Z3_model;//   := 0;
var x_plus_y : Z3_ast;
var v        : Z3_ast ;

begin
    //var ctx : Z3_context := mk_context;
    //var s   : Z3_solver  := mk_solver(ctx);
    //var m   : Z3_model   := 0;
    ctx := mk_context;
    s   := mk_solver(ctx);
    m   := 0;

    relog.Lines.Append('');
    relog.Lines.Append('eval_example1');
    LOG_MSG('eval_example1');

    x          := mk_int_var(ctx, 'x');
    y          := mk_int_var(ctx, 'y');
    two        := mk_int(ctx, 2);

    (* assert x < y *)
    c1         := Z3_mk_lt(ctx, x, y);
    Z3_solver_assert(ctx, s, c1);

    (* assert x > 2 *)
    c2         := Z3_mk_gt(ctx, x, two);
    Z3_solver_assert(ctx, s, c2);

    (* find model for the constraints above *)
    if Z3_solver_check(ctx, s) = Z3_L_TRUE then
    begin
        //var x_plus_y : Z3_ast;
        //var v        : Z3_ast ;
        //var x_plus_y : Z3_ast;
        //var v        : Z3_ast ;
        args[0] := x;
        args[1] := y;
        m := Z3_solver_get_model(ctx, s);
        // inc ref
	      if m <> nil then
          Z3_model_inc_ref(ctx, m);
        relog.Lines.Append(Format('MODEL:' + sLineBreak+ '%s', [Z3_model_to_string(ctx, m)]));
        x_plus_y := Z3_mk_add(ctx, 2, @args[0]);
        relog.Lines.Append(sLineBreak + 'evaluating x+y');
        if Z3_model_eval(ctx, m, x_plus_y, True, @v) then
        begin
            relog.Lines.Append('result = ' +  display_ast(ctx, v));
        end else
        begin
            exitf('failed to evaluate: x+y');
        end;
    end else
    begin
        exitf('the constraints are satisfiable');
    end;
    // dec ref
    if m <> nil then
      Z3_model_dec_ref(ctx, m);
    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Several logical context can be used simultaneously.
*)
procedure TMain.two_contexts_example1;
var
  ctx1, ctx2 : Z3_context;
  x1, x2     : Z3_ast ;
begin
    relog.Lines.Append(sLineBreak+ 'two_contexts_example1');
    LOG_MSG('two_contexts_example1');

    (* using the same (default) configuration to initialized both logical contexts. *)
    ctx1 := mk_context();
    ctx2 := mk_context();

    x1 := Z3_mk_const(ctx1, Z3_mk_int_symbol(ctx1,0), Z3_mk_bool_sort(ctx1));
    x2 := Z3_mk_const(ctx2, Z3_mk_int_symbol(ctx2,0), Z3_mk_bool_sort(ctx2));

    Z3_del_context(ctx1);

    (* ctx2 can still be used. *)
    relog.Lines.Append(Format('%s', [Z3_ast_to_string(ctx2, x2)]));

    Z3_del_context(ctx2);
end;

(**
   \brief Demonstrates how error codes can be read instead of registering an error handler.
 *)
procedure TMain.error_code_example1;
var
  cfg : Z3_config;
  ctx : Z3_context;
  s   : Z3_solver;
  x   : Z3_ast;
  m   : Z3_model;
  v   : Z3_ast;
  x_decl : Z3_func_decl;
  str  : AnsiString;
begin

    relog.Lines.Append(sLineBreak+ 'error_code_example1');
    LOG_MSG('error_code_example1');

    (* Do not register an error handler, as we want to use Z3_get_error_code manually *)
    cfg := Z3_mk_config;
    ctx := mk_context_custom(cfg, nil);
    Z3_del_config(cfg);
    s := mk_solver(ctx);

    x          := mk_bool_var(ctx, 'x');
    x_decl     := Z3_get_app_decl(ctx, Z3_to_app(ctx, x));
    Z3_solver_assert(ctx, s, x);

    if (Z3_solver_check(ctx, s) <> Z3_L_TRUE) then
        exitf('unexpected result');

    m := Z3_solver_get_model(ctx, s);
    // inc ref
    if m <> nil  then
      Z3_model_inc_ref(ctx, m);
    if not Z3_model_eval(ctx, m, x, True, @v)  then
        exitf('did not obtain value for declaration.');

    if (Z3_get_error_code(ctx) = Z3_OK) then
        relog.Lines.Append('last call succeeded.');

    (* The following call will fail since the value of x is a boolean *)
    str := Z3_get_numeral_string(ctx, v);
    if (Z3_get_error_code(ctx) <> Z3_OK) then
        relog.Lines.Append('last call failed.');

    // dec ref
    if m <> nil then
      Z3_model_dec_ref(ctx, m);
    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Demonstrates how error handlers can be used.
*)
//doh
procedure TMain.error_code_example2;
var
  cfg : Z3_config;
  ctx : Z3_context;
  e   : Z3_error_code;
  l   : Boolean;
var x, y, app : Z3_ast;

label
    err  ;
begin
    relog.Lines.Append(sLineBreak+ 'error_code_example2');
    LOG_MSG('error_code_example2');

    ctx := nil;

    l := True;

    if l then
    begin
        //var x, y, app : Z3_ast;

        cfg := Z3_mk_config();
        ctx := mk_context_custom(cfg, nothrow_z3_error);
        Z3_del_config(cfg);

        x   := mk_int_var(ctx, 'x');
        y   := mk_bool_var(ctx, 'y');
        relog.Lines.Append('before Z3_mk_iff');
        (* the next call will produce an error *)
        app := Z3_mk_iff(ctx, x, y);
        e   := Z3_get_error_code(ctx);

        if e <> Z3_OK  then goto err;

        unreachable;
        Z3_del_context(ctx);
    end else
    begin
    err:
        relog.Lines.Append(Format('Z3 error: %s.', [Z3_get_error_msg(ctx, e)]));
        if ctx <> nil then
            Z3_del_context(ctx);
    end;
end;

(**
   \brief Demonstrates how to initialize the parser symbol table.
 *)
procedure TMain.parser_example2;
var
  x, y : Z3_ast;
  names: array[0..1] of Z3_symbol ;
  decls: array[0..2] of Z3_func_decl;
  f    : Z3_ast_vector;
  i    : Cardinal;
var ctx : Z3_context;// := mk_context;
var s   : Z3_solver;//  := mk_solver(ctx);
begin
    //var ctx : Z3_context := mk_context;
    //var s   : Z3_solver  := mk_solver(ctx);
    ctx  := mk_context;
    s    := mk_solver(ctx);

    relog.Lines.Append(sLineBreak+ 'parser_example2');
    LOG_MSG('parser_example2');

    (* Z3_enable_arithmetic doesn't need to be invoked in this example
       because it will be implicitly invoked by mk_int_var.
    *)

    x        := mk_int_var(ctx, 'x');
    decls[0] := Z3_get_app_decl(ctx, Z3_to_app(ctx, x));
    y        := mk_int_var(ctx, 'y');
    decls[1] := Z3_get_app_decl(ctx, Z3_to_app(ctx, y));

    names[0] := Z3_mk_string_symbol(ctx, 'a');
    names[1] := Z3_mk_string_symbol(ctx, 'b');

    f := Z3_parse_smtlib2_string(ctx,
                           '(assert (> a b))',
                           0, 0, 0,
                           (* 'x' and 'y' declarations are inserted as 'a' and 'b' into the parser symbol table. *)
                           2, @names[0], @decls[0]);
    relog.Lines.Append(Format('formula: %s', [Z3_ast_vector_to_string(ctx, f)]));
    relog.Lines.Append(Format('assert axiom:'+ sLineBreak +'%s', [Z3_ast_vector_to_string(ctx, f)]));
    for i := 0 to Z3_ast_vector_size(ctx, f) -1 do
        Z3_solver_assert(ctx, s, Z3_ast_vector_get(ctx, f, i));

    check(ctx, s, Z3_L_TRUE);

    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Demonstrates how to initialize the parser symbol table.
 *)
procedure TMain.parser_example3;
var
  cfg     : Z3_config;
  ctx     : Z3_context;
  s       : Z3_solver;
  int_sort: Z3_sort;
  g_name  : Z3_symbol;
  g_domain: array[0..1] of Z3_sort;
  g       : Z3_func_decl;
  thm     : Z3_ast_vector;
begin
    relog.Lines.Append(sLineBreak+ 'parser_example3');
    LOG_MSG('parser_example3');

    cfg := Z3_mk_config();
    (* See quantifier_example1 *)
    Z3_set_param_value(cfg, 'model', 'true');
    ctx := mk_context_custom(cfg, error_handler);
    Z3_del_config(cfg);
    s := mk_solver(ctx);

    (* declare function g *)
    int_sort    := Z3_mk_int_sort(ctx);
    g_name      := Z3_mk_string_symbol(ctx, 'g');
    g_domain[0] := int_sort;
    g_domain[1] := int_sort;
    g           := Z3_mk_func_decl(ctx, g_name, 2, @g_domain[0], int_sort);

    assert_comm_axiom(ctx, s, g);

    thm := Z3_parse_smtlib2_string(ctx,
                           '(assert (forall ((x Int) (y Int)) (=> (= x y) (= (g x 0) (g 0 y)))))',
                           0, 0, 0,
                           1, @g_name, @g);
    relog.Lines.Append(Format('formula: %s', [Z3_ast_vector_to_string(ctx, thm)]));
    prove(ctx, s, Z3_ast_vector_get(ctx, thm, 0), true);

    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Demonstrates how to handle parser errors using Z3 error handling support.
*)
procedure TMain.parser_example5;
var
  cfg     : Z3_config;
  ctx     : Z3_context;
  s       : Z3_solver;
  e       : Z3_error_code;
  l   : Boolean;
label
    err  ;
begin
    relog.Lines.Append(sLineBreak+ 'parser_example5');
    LOG_MSG('parser_example5');

    ctx := nil;
    s   := nil;

    l := True;

    if l then
    begin
        cfg := Z3_mk_config();
        ctx := mk_context_custom(cfg, nothrow_z3_error);
        s   := mk_solver(ctx);
        Z3_del_config(cfg);

        Z3_parse_smtlib2_string(ctx,
                               (* the following string has a parsing error: missing parenthesis *)
                               '(declare-const x Int) declare-const y Int) (assert (and (> x y) (> x 0)))',
                               0, 0, 0,
                               0, 0, 0);
        e := Z3_get_error_code(ctx);
        if e <> Z3_OK then
           goto err;
        unreachable;
	      del_solver(ctx, s);
        Z3_del_context(ctx);
    end else
    begin
    err:
        relog.Lines.Append(Format('Z3 error: %s.', [Z3_get_error_msg(ctx, e)]));
        if ctx <> nil then
        begin
	          del_solver(ctx, s);
            Z3_del_context(ctx);
        end;
    end;
end;

(**
    \brief Demonstrate different ways of creating rational numbers: decimal and fractional representations.
*)
procedure TMain.numeral_example;
var
  ctx     : Z3_context;
  s       : Z3_solver;
  n1, n2  : Z3_ast;
  real_ty : Z3_sort;
begin
    relog.Lines.Append(sLineBreak+ 'numeral_example');
    LOG_MSG('numeral_example');

    ctx        := mk_context();
    s          := mk_solver(ctx);

    real_ty    := Z3_mk_real_sort(ctx);

    n1 := Z3_mk_numeral(ctx, '1/2', real_ty);
    n2 := Z3_mk_numeral(ctx, '0.5', real_ty);
    relog.Lines.Append(Format('Numerals n1:%s n2:%s', [Z3_ast_to_string(ctx, n1), Z3_ast_to_string(ctx, n2)]));
    prove(ctx, s, Z3_mk_eq(ctx, n1, n2), true);

    n1 := Z3_mk_numeral(ctx, '-1/3', real_ty);
    n2 := Z3_mk_numeral(ctx, '-0.33333333333333333333333333333333333333333333333333', real_ty);
    relog.Lines.Append(Format('Numerals n1:%s n2:%s', [string(Z3_ast_to_string(ctx, n1)), Z3_ast_to_string(ctx, n2)]));
    prove(ctx, s, Z3_mk_not(ctx, Z3_mk_eq(ctx, n1, n2)), true);

    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Test ite-term (if-then-else terms).
*)
procedure TMain.ite_example;
var
  ctx               : Z3_context;
  f, one, zero, ite : Z3_ast;
begin
    relog.Lines.Append(sLineBreak+ 'ite_example');
    LOG_MSG('ite_example');

    ctx := mk_context();

    f    := Z3_mk_false(ctx);
    one  := mk_int(ctx, 1);
    zero := mk_int(ctx, 0);
    ite  := Z3_mk_ite(ctx, f, one, zero);

    relog.Lines.Append(Format('term: %s', [Z3_ast_to_string(ctx, ite)]));

    (* delete logical context *)
    Z3_del_context(ctx);
end;

(**
   \brief Create a list datatype.
*)
procedure TMain.list_example;
var
  int_ty, int_list   : Z3_sort;
  nil_decl,
  is_nil_decl,
  cons_decl,
  is_cons_decl,
  head_decl,
  tail_decl          : Z3_func_decl;
  &nil, l1, l2, x,
  y, u, v, fml, fml1 : Z3_ast;
  ors                : array[0..1] of Z3_ast;
var  ctx : Z3_context;// := mk_context();
var  s   : Z3_solver;//  := mk_solver(ctx);

begin
    relog.Lines.Append(sLineBreak+ 'list_example');
    LOG_MSG('list_example');

    //var  ctx : Z3_context := mk_context();
    //var  s   : Z3_solver  := mk_solver(ctx);
    ctx := mk_context();
    s   := mk_solver(ctx);

    int_ty := Z3_mk_int_sort(ctx);

    int_list := Z3_mk_list_sort(ctx,
                                Z3_mk_string_symbol(ctx, 'int_list'),
                                int_ty,
                                @nil_decl,
                                @is_nil_decl,
                                @cons_decl,
                                @is_cons_decl,
                                @head_decl,
                                @tail_decl);

    &nil := Z3_mk_app(ctx, nil_decl, 0, 0);
    l1   := mk_binary_app(ctx, cons_decl, mk_int(ctx, 1), &nil);
    l2   := mk_binary_app(ctx, cons_decl, mk_int(ctx, 2), &nil);

    (* nil != cons(1, nil) *)
    prove(ctx, s, Z3_mk_not(ctx, Z3_mk_eq(ctx, &nil, l1)), true);

    (* cons(2,nil) != cons(1, nil) *)
    prove(ctx, s, Z3_mk_not(ctx, Z3_mk_eq(ctx, l1, l2)), true);

    (* cons(x,nil) = cons(y, nil) => x = y *)
    x := mk_var(ctx, 'x', int_ty);
    y := mk_var(ctx, 'y', int_ty);
    l1 := mk_binary_app(ctx, cons_decl, x, &nil);
	  l2 := mk_binary_app(ctx, cons_decl, y, &nil);
    prove(ctx, s, Z3_mk_implies(ctx, Z3_mk_eq(ctx,l1,l2), Z3_mk_eq(ctx, x, y)), true);

    (* cons(x,u) = cons(x, v) => u = v *)
    u := mk_var(ctx, 'u', int_list);
    v := mk_var(ctx, 'v', int_list);
    l1:= mk_binary_app(ctx, cons_decl, x, u);
	  l2:= mk_binary_app(ctx, cons_decl, y, v);
    prove(ctx, s, Z3_mk_implies(ctx, Z3_mk_eq(ctx,l1,l2), Z3_mk_eq(ctx, u, v)), true);
    prove(ctx, s, Z3_mk_implies(ctx, Z3_mk_eq(ctx,l1,l2), Z3_mk_eq(ctx, x, y)), true);

    (* is_nil(u) or is_cons(u) *)
    ors[0] := Z3_mk_app(ctx, is_nil_decl, 1, @u);
    ors[1] := Z3_mk_app(ctx, is_cons_decl, 1, @u);
    prove(ctx, s, Z3_mk_or(ctx, 2, @ors[0]), true);

    (* occurs check u != cons(x,u) *)
    prove(ctx, s, Z3_mk_not(ctx, Z3_mk_eq(ctx, u, l1)), true);

    (* destructors: is_cons(u) => u = cons(head(u),tail(u)) *)
    fml1 := Z3_mk_eq(ctx, u, mk_binary_app(ctx, cons_decl, mk_unary_app(ctx, head_decl, u), mk_unary_app(ctx, tail_decl, u)));
    fml  := Z3_mk_implies(ctx, Z3_mk_app(ctx, is_cons_decl, 1, @u), fml1);
    relog.Lines.Append(Format('Formula %s', [Z3_ast_to_string(ctx, fml)]));
    prove(ctx, s, fml, true);

    prove(ctx, s, fml1, false);

    (* delete logical context *)
    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Create a binary tree datatype.
*)
procedure TMain.tree_example;
var
  cell                     : Z3_sort;
  nil_decl, is_nil_decl,
  cons_decl, is_cons_decl,
  car_decl, cdr_decl       : Z3_func_decl;
  &nil, l1, l2, x, y,
  u, v, fml, fml1          : Z3_ast;
  head_tail                : array of Z3_symbol  ;
  sorts                    : array of Z3_sort;
  sort_refs                : array of Cardinal;
  nil_con, cons_con        : Z3_constructor;
  constructors             : array[0..1] of Z3_constructor;
  cons_accessors           : array[0..1] of Z3_func_decl;
  ors                      : array[0..1] of Z3_ast;
var ctx : Z3_context;// := mk_context();
var s   : Z3_solver;//  := mk_solver(ctx);

begin
    relog.Lines.Append(sLineBreak+ 'tree_example');
    LOG_MSG('tree_example');

    //var ctx : Z3_context := mk_context();
    //var s   : Z3_solver  := mk_solver(ctx);
    ctx  := mk_context();
    s    := mk_solver(ctx);

    //doh
    //head_tail := [ Z3_mk_string_symbol(ctx, 'car'), Z3_mk_string_symbol(ctx, 'cdr') ];

    head_tail.create;
    TAppender<Z3_symbol>.Append(head_tail, Z3_mk_string_symbol(ctx, 'car'));
    TAppender<Z3_symbol>.Append(head_tail, Z3_mk_string_symbol(ctx, 'cdr'));



    //doh
    //sorts     := [ 0, 0 ];
    sorts.create;
    TAppender<Z3_sort>.Append(sorts, 0);
    TAppender<Z3_sort>.Append(sorts, 0);


    //doh
    //sort_refs := [ 0, 0 ];
    sort_refs.create;
    TAppender<Cardinal>.Append(sort_refs, 0);
    TAppender<Cardinal>.Append(sort_refs, 0);

    nil_con  := Z3_mk_constructor(ctx, Z3_mk_string_symbol(ctx, 'nil'), Z3_mk_string_symbol(ctx, 'is_nil'), 0, 0, 0, 0);
    cons_con := Z3_mk_constructor(ctx, Z3_mk_string_symbol(ctx, 'cons'), Z3_mk_string_symbol(ctx, 'is_cons'), 2, @head_tail[0], @sorts[0], @sort_refs[0]);
    constructors[0] := nil_con;
    constructors[1] := cons_con;

    cell := Z3_mk_datatype(ctx, Z3_mk_string_symbol(ctx, 'cell'), 2, @constructors[0]);

    Z3_query_constructor(ctx, nil_con, 0, @nil_decl, @is_nil_decl, 0);
    Z3_query_constructor(ctx, cons_con, 2, @cons_decl, @is_cons_decl, @cons_accessors[0]);
    car_decl := cons_accessors[0];
    cdr_decl := cons_accessors[1];

    Z3_del_constructor(ctx,nil_con);
    Z3_del_constructor(ctx,cons_con);


    &nil := Z3_mk_app(ctx, nil_decl, 0, 0);
    l1   := mk_binary_app(ctx, cons_decl, &nil, &nil);
    l2   := mk_binary_app(ctx, cons_decl, l1, &nil);

    (* nil != cons(nil, nil) *)
    prove(ctx, s, Z3_mk_not(ctx, Z3_mk_eq(ctx, &nil, l1)), true);

    (* cons(x,u) = cons(x, v) => u = v *)
    u  := mk_var(ctx, 'u', cell);
    v  := mk_var(ctx, 'v', cell);
    x  := mk_var(ctx, 'x', cell);
    y  := mk_var(ctx, 'y', cell);
    l1 := mk_binary_app(ctx, cons_decl, x, u);
    l2 := mk_binary_app(ctx, cons_decl, y, v);
    prove(ctx, s, Z3_mk_implies(ctx, Z3_mk_eq(ctx,l1,l2), Z3_mk_eq(ctx, u, v)), true);
    prove(ctx, s, Z3_mk_implies(ctx, Z3_mk_eq(ctx,l1,l2), Z3_mk_eq(ctx, x, y)), true);

    (* is_nil(u) or is_cons(u) *)
    ors[0] := Z3_mk_app(ctx, is_nil_decl,  1, @u);
    ors[1] := Z3_mk_app(ctx, is_cons_decl, 1, @u);
    prove(ctx, s, Z3_mk_or(ctx, 2, @ors[0]), true);

    (* occurs check u != cons(x,u) *)
    prove(ctx, s, Z3_mk_not(ctx, Z3_mk_eq(ctx, u, l1)), true);

    (* destructors: is_cons(u) => u = cons(car(u),cdr(u)) *)
    fml1 := Z3_mk_eq(ctx, u, mk_binary_app(ctx, cons_decl, mk_unary_app(ctx, car_decl, u), mk_unary_app(ctx, cdr_decl, u)));
    fml  := Z3_mk_implies(ctx, Z3_mk_app(ctx, is_cons_decl, 1, @u), fml1);
    relog.Lines.Append(Format('Formula %s', [Z3_ast_to_string(ctx, fml)]));
    prove(ctx, s, fml, true);

    prove(ctx, s, fml1, false);

    (* delete logical context *)
    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Create a forest of trees.

   forest ::= nil | cons(tree, forest)
   tree   ::= nil | cons(forest, forest)
*)

procedure TMain.forest_example;
var
  tree, forest               : Z3_sort;
  nil1_decl, is_nil1_decl,
  cons1_decl, is_cons1_decl,
  car1_decl, cdr1_decl       : Z3_func_decl;
  nil2_decl, is_nil2_decl,
  cons2_decl, is_cons2_decl,
  car2_decl, cdr2_decl       : Z3_func_decl;
  nil1, nil2, t1, t2, t3,
  t4, f1, f2, f3, l1, l2,
  x, y, u, v                 : Z3_ast;
  head_tail                  : array of Z3_symbol;
  sorts                      : array of Z3_sort;
  sort_refs                  : array of Cardinal;
  sort_names                 : array of Z3_symbol;
  nil1_con, cons1_con,
  nil2_con, cons2_con        : Z3_constructor;
  constructors1,
  constructors2              : array[0..1] of Z3_constructor;
  cons_accessors             : array[0..1] of Z3_func_decl;
  ors                        : array[0..1] of Z3_ast;
  clists                     : array[0..1] of Z3_constructor_list;
  clist1, clist2             : Z3_constructor_list;
var ctx : Z3_context;// := mk_context();
var s   : Z3_solver;//  := mk_solver(ctx);

begin
    relog.Lines.Append(sLineBreak+ 'forest_example');
    LOG_MSG('forest_example');

    //var ctx : Z3_context := mk_context();
    //var s   : Z3_solver  := mk_solver(ctx);
    ctx  := mk_context();
    s    := mk_solver(ctx);

    //head_tail  := [ Z3_mk_string_symbol(ctx, 'car'), Z3_mk_string_symbol(ctx, 'cdr') ];
    //sorts      := [ 0, 0 ];
    //sort_refs  := [ 0, 0 ];
    //sort_names := [ Z3_mk_string_symbol(ctx, 'forest'), Z3_mk_string_symbol(ctx, 'tree') ];

    //doh
    //head_tail := [ Z3_mk_string_symbol(ctx, 'car'), Z3_mk_string_symbol(ctx, 'cdr') ];

    head_tail.create;
    TAppender<Z3_symbol>.Append(head_tail, Z3_mk_string_symbol(ctx, 'car'));
    TAppender<Z3_symbol>.Append(head_tail, Z3_mk_string_symbol(ctx, 'cdr'));

    //doh
    //sorts     := [ 0, 0 ];
    sorts.create;
    TAppender<Z3_sort>.Append(sorts, 0);
    TAppender<Z3_sort>.Append(sorts, 0);


    //doh
    //sort_refs := [ 0, 0 ];
    sort_refs.create;
    TAppender<Cardinal>.Append(sort_refs, 0);
    TAppender<Cardinal>.Append(sort_refs, 0);

    //doh
    //head_tail := [ Z3_mk_string_symbol(ctx, 'car'), Z3_mk_string_symbol(ctx, 'cdr') ];

    sort_names.create;
    TAppender<Z3_symbol>.Append(sort_names, Z3_mk_string_symbol(ctx, 'forest'));
    TAppender<Z3_symbol>.Append(sort_names, Z3_mk_string_symbol(ctx, 'tree'));


    (* build a forest *)
    nil1_con         := Z3_mk_constructor(ctx, Z3_mk_string_symbol(ctx, 'nil1'), Z3_mk_string_symbol(ctx, 'is_nil1'), 0, 0, 0, 0);
    sort_refs[0]     := 1; (* the car of a forest is a tree *)
    sort_refs[1]     := 0;
    cons1_con        := Z3_mk_constructor(ctx, Z3_mk_string_symbol(ctx, 'cons1'), Z3_mk_string_symbol(ctx, 'is_cons1'), 2, @head_tail[0], @sorts[0], @sort_refs[0]);
    constructors1[0] := nil1_con;
    constructors1[1] := cons1_con;

    (* build a tree *)
    nil2_con         := Z3_mk_constructor(ctx, Z3_mk_string_symbol(ctx, 'nil2'), Z3_mk_string_symbol(ctx, 'is_nil2'),0, 0, 0, 0);
    sort_refs[0]     := 0; (* both branches of a tree are forests *)
    sort_refs[1]     := 0;
    cons2_con        := Z3_mk_constructor(ctx, Z3_mk_string_symbol(ctx, 'cons2'), Z3_mk_string_symbol(ctx, 'is_cons2'),2, @head_tail[0], @sorts[0], @sort_refs[0]);
    constructors2[0] := nil2_con;
    constructors2[1] := cons2_con;

    clist1 := Z3_mk_constructor_list(ctx, 2, @constructors1[0]);
    clist2 := Z3_mk_constructor_list(ctx, 2, @constructors2[0]);

    clists[0] := clist1;
    clists[1] := clist2;

    Z3_mk_datatypes(ctx, 2, @sort_names[0], @sorts[0], @clists[0]);
    forest := sorts[0];
    tree   := sorts[1];

    Z3_query_constructor(ctx, nil1_con, 0, @nil1_decl, @is_nil1_decl, 0);
    Z3_query_constructor(ctx, cons1_con, 2, @cons1_decl, @is_cons1_decl, @cons_accessors[0]);
    car1_decl := cons_accessors[0];
    cdr1_decl := cons_accessors[1];

    Z3_query_constructor(ctx, nil2_con, 0, @nil2_decl, @is_nil2_decl, 0);
    Z3_query_constructor(ctx, cons2_con, 2, @cons2_decl, @is_cons2_decl, @cons_accessors[0]);
    car2_decl := cons_accessors[0];
    cdr2_decl := cons_accessors[1];

    Z3_del_constructor_list(ctx, clist1);
    Z3_del_constructor_list(ctx, clist2);
    Z3_del_constructor(ctx,nil1_con);
    Z3_del_constructor(ctx,cons1_con);
    Z3_del_constructor(ctx,nil2_con);
    Z3_del_constructor(ctx,cons2_con);

    nil1 := Z3_mk_app(ctx, nil1_decl, 0, 0);
    nil2 := Z3_mk_app(ctx, nil2_decl, 0, 0);
    f1 := mk_binary_app(ctx, cons1_decl, nil2, nil1);
    t1 := mk_binary_app(ctx, cons2_decl, nil1, nil1);
    t2 := mk_binary_app(ctx, cons2_decl, f1, nil1);
    t3 := mk_binary_app(ctx, cons2_decl, f1, f1);
    t4 := mk_binary_app(ctx, cons2_decl, nil1, f1);
    f2 := mk_binary_app(ctx, cons1_decl, t1, nil1);
    f3 := mk_binary_app(ctx, cons1_decl, t1, f1);


    (* nil != cons(nil,nil) *)
    prove(ctx, s, Z3_mk_not(ctx, Z3_mk_eq(ctx, nil1, f1)), true);
    prove(ctx, s, Z3_mk_not(ctx, Z3_mk_eq(ctx, nil2, t1)), true);


    (* cons(x,u) = cons(x, v) => u = v *)
    u  := mk_var(ctx, 'u', forest);
    v  := mk_var(ctx, 'v', forest);
    x  := mk_var(ctx, 'x', tree);
    y  := mk_var(ctx, 'y', tree);
    l1 := mk_binary_app(ctx, cons1_decl, x, u);
    l2 := mk_binary_app(ctx, cons1_decl, y, v);
    prove(ctx, s, Z3_mk_implies(ctx, Z3_mk_eq(ctx,l1,l2), Z3_mk_eq(ctx, u, v)), true);
    prove(ctx, s, Z3_mk_implies(ctx, Z3_mk_eq(ctx,l1,l2), Z3_mk_eq(ctx, x, y)), true);

    (* is_nil(u) or is_cons(u) *)
    ors[0] := Z3_mk_app(ctx, is_nil1_decl, 1, @u);
    ors[1] := Z3_mk_app(ctx, is_cons1_decl, 1, @u);
    prove(ctx, s, Z3_mk_or(ctx, 2, @ors[0]), true);

    (* occurs check u != cons(x,u) *)
    prove(ctx, s, Z3_mk_not(ctx, Z3_mk_eq(ctx, u, l1)), true);

    (* delete logical context *)
    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Create a binary tree datatype of the form
        BinTree ::=   nil
                    | node(value : Int, left : BinTree, right : BinTree)
*)
//doh
procedure TMain.binary_tree_example;
var
  cell             : Z3_sort;
  nil_con, node_con: Z3_constructor;
  nil_decl,                    (* nil : BinTree   (constructor) *)
  is_nil_decl,                 (* is_nil : BinTree -> Bool (tester, return true if the given BinTree is a nil) *)
  node_decl,                   (* node : Int, BinTree, BinTree -> BinTree  (constructor) *)
  is_node_decl,                (* is_node : BinTree -> Bool (tester, return true if the given BinTree is a node) *)
  value_decl,                  (* value : BinTree -> Int  (accessor for nodes) *)
  left_decl,                   (* left : BinTree -> BinTree (accessor for nodes, retrieves the left child of a node) *)
  right_decl   : Z3_func_decl; (* right : BinTree -> BinTree (accessor for nodes, retrieves the right child of a node) *)
  node_accessor_names     : array of Z3_symbol;
  node_accessor_sorts     : array of Z3_sort;
  node_accessor_sort_refs : array of Cardinal ;
  args1,args2,args3       : array of Z3_ast;
  constructors            : array[0..1]of Z3_constructor;
  node_accessors          : array[0..2]of Z3_func_decl;
var ctx : Z3_context;// := mk_context();
var s   : Z3_solver;//  := mk_solver(ctx);
var &nil : Z3_ast;// := Z3_mk_app(ctx, nil_decl, 0, 0);
var node1: Z3_ast;// := Z3_mk_app(ctx, node_decl, 3, @args1[0]);
var node2: Z3_ast;// := Z3_mk_app(ctx, node_decl, 3, @args2[0]);
var node3: Z3_ast;// := Z3_mk_app(ctx, node_decl, 3, @args3[0]);


begin
    relog.Lines.Append(sLineBreak+ 'binary_tree_example');
    LOG_MSG('binary_tree_example');

    //var ctx : Z3_context := mk_context();
    //var s   : Z3_solver  := mk_solver(ctx);
    ctx := mk_context();
    s   := mk_solver(ctx);

    //doh
    //node_accessor_names    := [ Z3_mk_string_symbol(ctx, 'value'), Z3_mk_string_symbol(ctx, 'left'), Z3_mk_string_symbol(ctx, 'right') ];
    //node_accessor_sorts    := [ Z3_mk_int_sort(ctx), 0, 0 ];
    //node_accessor_sort_refs:= [ 0, 0, 0 ];

    node_accessor_names .create;
    TAppender<Z3_symbol>.Append(node_accessor_names , Z3_mk_string_symbol(ctx, 'value'));
    TAppender<Z3_symbol>.Append(node_accessor_names , Z3_mk_string_symbol(ctx, 'left'));
    TAppender<Z3_symbol>.Append(node_accessor_names , Z3_mk_string_symbol(ctx, 'right'));

    node_accessor_sorts.create;
    TAppender<Z3_sort>.Append(node_accessor_sorts, Z3_mk_int_sort(ctx));
    TAppender<Z3_sort>.Append(node_accessor_sorts, 0);
    TAppender<Z3_sort>.Append(node_accessor_sorts, 0);

    node_accessor_sort_refs.create;
    TAppender<Cardinal>.Append(node_accessor_sort_refs, 0);
    TAppender<Cardinal>.Append(node_accessor_sort_refs, 0);
    TAppender<Cardinal>.Append(node_accessor_sort_refs, 0);


    (* nil_con and node_con are auxiliary datastructures used to create the new recursive datatype BinTree *)
    nil_con  := Z3_mk_constructor(ctx, Z3_mk_string_symbol(ctx, 'nil'), Z3_mk_string_symbol(ctx, 'is-nil'), 0, 0, 0, 0);
    node_con := Z3_mk_constructor(ctx, Z3_mk_string_symbol(ctx, 'node'), Z3_mk_string_symbol(ctx, 'is-cons'),
                                 3, @node_accessor_names[0], @node_accessor_sorts[0], @node_accessor_sort_refs[0]);
    constructors[0] := nil_con;
    constructors[1] := node_con;

    (* create the new recursive datatype *)
    cell := Z3_mk_datatype(ctx, Z3_mk_string_symbol(ctx, 'BinTree'), 2, @constructors[0]);

    (* retrieve the new declarations: constructors (nil_decl, node_decl), testers (is_nil_decl, is_cons_del), and
       accessors (value_decl, left_decl, right_decl *)
    Z3_query_constructor(ctx, nil_con, 0, @nil_decl, @is_nil_decl, 0);
    Z3_query_constructor(ctx, node_con, 3, @node_decl, @is_node_decl,@ node_accessors[0]);
    value_decl := node_accessors[0];
    left_decl  := node_accessors[1];
    right_decl := node_accessors[2];

    (* delete auxiliary/helper structures *)
    Z3_del_constructor(ctx, nil_con);
    Z3_del_constructor(ctx, node_con);



    (* small example using the recursive datatype BinTree *)
    begin
        (* create nil *)
        //var &nil : Z3_ast := Z3_mk_app(ctx, nil_decl, 0, 0);
        &nil := Z3_mk_app(ctx, nil_decl, 0, 0);
        (* create node1 ::= node(10, nil, nil) *)

        ///doh
        //args1             := [ mk_int(ctx, 10), &nil, &nil ];

        args1.create;
        TAppender<Z3_ast>.Append(args1, mk_int(ctx, 10));
        TAppender<Z3_ast>.Append(args1, &nil);
        TAppender<Z3_ast>.Append(args1, &nil);


        //var node1: Z3_ast := Z3_mk_app(ctx, node_decl, 3, @args1[0]);

        node1:= Z3_mk_app(ctx, node_decl, 3, @args1[0]);

        (* create node2 ::= node(30, node1, nil) *)

        //doh
        //args2             := [ mk_int(ctx, 30), node1, &nil ];

        args2.create;
        TAppender<Z3_ast>.Append(args2, mk_int(ctx, 30));
        TAppender<Z3_ast>.Append(args2, &nil);
        TAppender<Z3_ast>.Append(args2, &nil);

        //var node2: Z3_ast := Z3_mk_app(ctx, node_decl, 3, @args2[0]);
        node2 := Z3_mk_app(ctx, node_decl, 3, @args2[0]);
        (* create node3 ::= node(20, node2, node1); *)

        //doh
        //args3             := [ mk_int(ctx, 20), node2, node1 ];

        args3.create;
        TAppender<Z3_ast>.Append(args3, mk_int(ctx, 20));
        TAppender<Z3_ast>.Append(args3, node2);
        TAppender<Z3_ast>.Append(args3, node1);

        //var node3: Z3_ast := Z3_mk_app(ctx, node_decl, 3, @args3[0]);
        node3 := Z3_mk_app(ctx, node_decl, 3, @args3[0]);

        (* prove that nil != node1 *)
        prove(ctx, s, Z3_mk_not(ctx, Z3_mk_eq(ctx, &nil, node1)), true);

        (* prove that nil = left(node1) *)
        prove(ctx, s, Z3_mk_eq(ctx, &nil, mk_unary_app(ctx, left_decl, node1)), true);

        (* prove that node1 = right(node3) *)
        prove(ctx, s, Z3_mk_eq(ctx, node1, mk_unary_app(ctx, right_decl, node3)), true);

        (* prove that !is-nil(node2) *)
        prove(ctx, s, Z3_mk_not(ctx, mk_unary_app(ctx, is_nil_decl, node2)), true);

        (* prove that value(node2) >= 0 *)
        prove(ctx, s, Z3_mk_ge(ctx, mk_unary_app(ctx, value_decl, node2), mk_int(ctx, 0)), true);
    end;

    (* delete logical context *)
    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

//doh
procedure TMain.btnTestX86Click(Sender: TObject);
begin
    Z3_open_log('z3.log');
    relog.Clear;

    (**test asm x86*)
    if not FileExists('asmx86/test1.bin') then
      ShowMessage('file inesistente')
    else
      ShowMessage('Test is disabled in this version');
      //doh: disabled test
      //relog.lines.AddStrings( Testx86(edtBinFile.Text));
    (****)

    Z3_close_log;
end;

(**
   \brief Create an enumeration data type.
*)
//doh
procedure TMain.enum_example;
var
  fruit          : Z3_sort;
  enum_names     : array[0..2] of Z3_symbol;
  enum_consts    : array[0..2] of Z3_func_decl;
  enum_testers   : array[0..2] of Z3_func_decl;
  apple, orange,
  banana, fruity : Z3_ast;
  ors            : array[0..2] of Z3_ast;
var ctx  : Z3_context;// := mk_context();
var s    : Z3_solver;//  := mk_solver(ctx);
var name : Z3_symbol;//  := Z3_mk_string_symbol(ctx, 'fruit');

begin
    relog.Lines.Append(sLineBreak+ 'enum_example');
    LOG_MSG('enum_example');

    //var ctx  : Z3_context := mk_context();
    //var s    : Z3_solver  := mk_solver(ctx);
    //var name : Z3_symbol  := Z3_mk_string_symbol(ctx, 'fruit');
    ctx   := mk_context();
    s     := mk_solver(ctx);
    name  := Z3_mk_string_symbol(ctx, 'fruit');

    enum_names[0] := Z3_mk_string_symbol(ctx,'apple');
    enum_names[1] := Z3_mk_string_symbol(ctx,'banana');
    enum_names[2] := Z3_mk_string_symbol(ctx,'orange');

    fruit := Z3_mk_enumeration_sort(ctx, name, 3, @enum_names[0], @enum_consts[0], @enum_testers[0]);

    relog.Lines.Append(Format('%s', [Z3_func_decl_to_string(ctx, enum_consts[0])]));
    relog.Lines.Append(Format('%s', [Z3_func_decl_to_string(ctx, enum_consts[1])]));
    relog.Lines.Append(Format('%s', [Z3_func_decl_to_string(ctx, enum_consts[2])]));

    relog.Lines.Append(Format('%s', [Z3_func_decl_to_string(ctx, enum_testers[0])]));
    relog.Lines.Append(Format('%s', [Z3_func_decl_to_string(ctx, enum_testers[1])]));
    relog.Lines.Append(Format('%s', [Z3_func_decl_to_string(ctx, enum_testers[2])]));

    apple  := Z3_mk_app(ctx, enum_consts[0], 0, 0);
    banana := Z3_mk_app(ctx, enum_consts[1], 0, 0);
    orange := Z3_mk_app(ctx, enum_consts[2], 0, 0);

    (* Apples are different from oranges *)
    prove(ctx, s, Z3_mk_not(ctx, Z3_mk_eq(ctx, apple, orange)), true);

    (* Apples pass the apple test *)
    prove(ctx, s, Z3_mk_app(ctx, enum_testers[0], 1, @apple), true);

    (* Oranges fail the apple test *)
    prove(ctx, s, Z3_mk_app(ctx, enum_testers[0], 1, @orange), false);
    prove(ctx, s, Z3_mk_not(ctx, Z3_mk_app(ctx, enum_testers[0], 1, @orange)), true);

    fruity := mk_var(ctx, 'fruity', fruit);

    (* If something is fruity, then it is an apple, banana, or orange *)
    ors[0] := Z3_mk_eq(ctx, fruity, apple);
    ors[1] := Z3_mk_eq(ctx, fruity, banana);
    ors[2] := Z3_mk_eq(ctx, fruity, orange);

    prove(ctx, s, Z3_mk_or(ctx, 3, @ors[0]), true);

    (* delete logical context *)
    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Prove a theorem and extract, and print the proof.

   This example illustrates the use of #Z3_check_assumptions.
*)
//doh
procedure TMain.unsat_core_and_proof_example;
var
  ctx : Z3_context;
  s   : Z3_solver;
  assumptions : array of Z3_ast;
  args1,args2,
  args3       : array of Z3_ast;
  g1,g2,g3,g4 : array of Z3_ast;
  res         : Z3_lbool;
  proof       : Z3_ast;
  m           : Z3_model;
  i           : Cardinal ;
  core        : Z3_ast_vector ;
var pa : Z3_ast;// := mk_bool_var(ctx, 'PredA');
 var pb : Z3_ast;// := mk_bool_var(ctx, 'PredB');
 var pc : Z3_ast;// := mk_bool_var(ctx, 'PredC');
 var pd : Z3_ast;// := mk_bool_var(ctx, 'PredD');
 var p1 : Z3_ast;// := mk_bool_var(ctx, 'P1');
 var p2 : Z3_ast;// := mk_bool_var(ctx, 'P2');
 var p3 : Z3_ast;// := mk_bool_var(ctx, 'P3');
 var p4 : Z3_ast;// := mk_bool_var(ctx, 'P4');

 var f1 : Z3_ast;// := Z3_mk_and(ctx, 3, @args1[0]);
 var f2 : Z3_ast;// := Z3_mk_and(ctx, 3, @args2[0]);
 var f3 : Z3_ast;// := Z3_mk_or(ctx, 2, @args3[0]);
 var f4 : Z3_ast;// := pd;


begin
    relog.Lines.Append(sLineBreak+ 'unsat_core_and_proof_example');
    LOG_MSG('unsat_core_and_proof_example');

    ctx := mk_proof_context();
    s   := mk_solver(ctx);
    //var pa : Z3_ast := mk_bool_var(ctx, 'PredA');
    //var pb : Z3_ast := mk_bool_var(ctx, 'PredB');
    //var pc : Z3_ast := mk_bool_var(ctx, 'PredC');
    //var pd : Z3_ast := mk_bool_var(ctx, 'PredD');
    //var p1 : Z3_ast := mk_bool_var(ctx, 'P1');
    //var p2 : Z3_ast := mk_bool_var(ctx, 'P2');
    //var p3 : Z3_ast := mk_bool_var(ctx, 'P3');
    //var p4 : Z3_ast := mk_bool_var(ctx, 'P4');
    pa  := mk_bool_var(ctx, 'PredA');
    pb  := mk_bool_var(ctx, 'PredB');
    pc  := mk_bool_var(ctx, 'PredC');
    pd  := mk_bool_var(ctx, 'PredD');
    p1  := mk_bool_var(ctx, 'P1');
    p2  := mk_bool_var(ctx, 'P2');
    p3  := mk_bool_var(ctx, 'P3');
    p4  := mk_bool_var(ctx, 'P4');

    //doh
    //assumptions := [ Z3_mk_not(ctx, p1), Z3_mk_not(ctx, p2), Z3_mk_not(ctx, p3), Z3_mk_not(ctx, p4) ];
    assumptions.create;
    TAppender<Z3_ast>.Append(assumptions, Z3_mk_not(ctx, p1));
    TAppender<Z3_ast>.Append(assumptions, Z3_mk_not(ctx, p2));
    TAppender<Z3_ast>.Append(assumptions, Z3_mk_not(ctx, p3));
    TAppender<Z3_ast>.Append(assumptions, Z3_mk_not(ctx, p4));

    //doh
    //args1           := [ pa, pb, pc ];
    args1.create;
    TAppender<Z3_ast>.Append(args1, pa);
    TAppender<Z3_ast>.Append(args1, pb);
    TAppender<Z3_ast>.Append(args1, pc);




    //var f1 : Z3_ast := Z3_mk_and(ctx, 3, @args1[0]);
    f1  := Z3_mk_and(ctx, 3, @args1[0]);

    //doh
    //args2           := [ pa, Z3_mk_not(ctx, pb), pc ];

    args2.create;
    TAppender<Z3_ast>.Append(args2, pa);
    TAppender<Z3_ast>.Append(args2, Z3_mk_not(ctx, pb));
    TAppender<Z3_ast>.Append(args2, pc);

    //var f2 : Z3_ast := Z3_mk_and(ctx, 3, @args2[0]);
    f2  := Z3_mk_and(ctx, 3, @args2[0]);

    //doh
    //args3           := [ Z3_mk_not(ctx, pa), Z3_mk_not(ctx, pc) ];

    args3.create;
    TAppender<Z3_ast>.Append(args3, Z3_mk_not(ctx, pa));
    TAppender<Z3_ast>.Append(args3, Z3_mk_not(ctx, pc));

    //var f3 : Z3_ast := Z3_mk_or(ctx, 2, @args3[0]);
    //var f4 : Z3_ast := pd;
    f3  := Z3_mk_or(ctx, 2, @args3[0]);
    f4  := pd;

    //doh
    //g1 := [ f1, p1 ];
    //g2 := [ f2, p2 ];
    //g3 := [ f3, p3 ];
    //g4 := [ f4, p4 ];

    g1.create;
    TAppender<Z3_ast>.Append(g1, f1);
    TAppender<Z3_ast>.Append(g1, p1);

    g2.create;
    TAppender<Z3_ast>.Append(g1, f2);
    TAppender<Z3_ast>.Append(g1, p2);

    g3.create;
    TAppender<Z3_ast>.Append(g1, f3);
    TAppender<Z3_ast>.Append(g1, p3);

    g4.create;
    TAppender<Z3_ast>.Append(g1, f4);
    TAppender<Z3_ast>.Append(g1, p4);


    m  := nil;

    Z3_solver_assert(ctx, s, Z3_mk_or(ctx, 2, @g1[0]));
    Z3_solver_assert(ctx, s, Z3_mk_or(ctx, 2, @g2[0]));
    Z3_solver_assert(ctx, s, Z3_mk_or(ctx, 2, @g3[0]));
    Z3_solver_assert(ctx, s, Z3_mk_or(ctx, 2, @g4[0]));

    res := Z3_solver_check_assumptions(ctx, s, 4, @assumptions[0]);

    case res of
        Z3_L_FALSE: begin
          core  := Z3_solver_get_unsat_core(ctx, s);
          proof := Z3_solver_get_proof(ctx, s);
          relog.Lines.Append('unsat');
          relog.Lines.Append(Format('proof: %s', [string(Z3_ast_to_string(ctx, proof))]));

          relog.Lines.Append('core:');
          for i := 0 to Z3_ast_vector_size(ctx, core) - 1do
            relog.Lines.Append(Format('%s', [Z3_ast_to_string(ctx, Z3_ast_vector_get(ctx, core, i))]));

          relog.Lines.Append('');
        end;
        Z3_L_UNDEF: begin
          relog.Lines.Append('unknown');
          relog.Lines.Append('potential model:');
          m := Z3_solver_get_model(ctx, s);
          if m <> nil then
             Z3_model_inc_ref(ctx, m);
          display_model(ctx,  m);
        end;
        Z3_L_TRUE: begin
          relog.Lines.Append('sat');
          m := Z3_solver_get_model(ctx, s);
          if m <> nil then
            Z3_model_inc_ref(ctx, m);
          display_model(ctx, m);
       end;
    end;

    (* delete logical context *)
    if m <> nil then
       Z3_model_dec_ref(ctx, m);
    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(* -start- Z3_ext_context definition and implementation*************)

(**
   \brief Create a logical context wrapper with support for retractable constraints.
 *)
function mk_ext_context: Z3_ext_context ;
var
 ctx : Z3_ext_context;
begin
    ctx := AllocMem(SizeOf(Z3_ext_context_struct));
    ctx^.m_context := mk_context();
    ctx^.m_solver  := mk_solver(ctx.m_context);
    ctx^.m_num_answer_literals := 0;

    Result := ctx;
end;

(**
   \brief Delete the given logical context wrapper.
*)
procedure del_ext_context(ctx: Z3_ext_context);
begin
     del_solver(ctx^.m_context, ctx^.m_solver);
     Z3_del_context(ctx^.m_context);
     FreeMem(ctx);
end;

(**
   \brief Create a retractable constraint.

   \return An id that can be used to retract/reassert the constraint.
*)
function assert_retractable_cnstr(ctx: Z3_ext_context; c:Z3_ast): Cardinal ;
var
  ty      : Z3_sort;
  ans_lit : Z3_ast;
  args    : array[0..1] of Z3_ast;
begin
    Result :=  MAX_RETRACTABLE_ASSERTIONS;

    if (ctx.m_num_answer_literals = MAX_RETRACTABLE_ASSERTIONS) then
        exitf('maximum number of retractable constraints was exceeded.');

    ty      := Z3_mk_bool_sort(ctx.m_context);
    ans_lit := Z3_mk_fresh_const(ctx.m_context, 'k', ty);
    result  := ctx.m_num_answer_literals;
    ctx^.m_answer_literals[result] := ans_lit;
    ctx^.m_retracted[result]       := false;
    Inc(ctx^.m_num_answer_literals);
    // assert: c OR (not ans_lit)
    args[0] := c;
    args[1] := Z3_mk_not(ctx^.m_context, ans_lit);
    Z3_solver_assert(ctx^.m_context, ctx^.m_solver, Z3_mk_or(ctx^.m_context, 2, @args[0]));

end;

(**
   \brief Retract an constraint asserted using #assert_retractable_cnstr.
*)
procedure retract_cnstr(ctx: Z3_ext_context; id: Cardinal);
begin
    if (id >= ctx.m_num_answer_literals) then
        exitf('invalid constraint id.');

    ctx^.m_retracted[id] := true;
end;

(**
   \brief Reassert a constraint retracted using #retract_cnstr.
*)
procedure reassert_cnstr(ctx: Z3_ext_context; id: Cardinal);
begin
    if (id >= ctx.m_num_answer_literals) then
        exitf('invalid constraint id.');

    ctx^.m_retracted[id] := false;
end;

(**
   \brief Check whether the logical context wrapper with support for retractable assertions is feasible or not.
*)
//doh
function TMain.ext_check(ctx:Z3_ext_context): Z3_lbool;
var
  res             : Z3_lbool;
  num_assumptions : Cardinal;
  assumptions     : array[0..MAX_RETRACTABLE_ASSERTIONS-1] of Z3_ast;
  core            : Z3_ast_vector ;
  core_size, i    : Cardinal;
  Ss              : AnsiString;
var j : Cardinal;

begin
    num_assumptions := 0;
    Ss              := '';
    for i := 0 to ctx.m_num_answer_literals- 1 do
    begin
        if (ctx.m_retracted[i] = false) then
        begin
            // Since the answer literal was not retracted, we added it as an assumption.
            // Recall that we assert (C \/ (not ans_lit)). Therefore, adding ans_lit as an assumption has the effect of "asserting" C.
            // If the constraint was "retracted" (ctx->m_retracted[i] == Z3_true), then we don't really need to add (not ans_lit) as an assumption.
            assumptions[num_assumptions] := ctx.m_answer_literals[i];
            Inc(num_assumptions);
        end;
    end;
    res := Z3_solver_check_assumptions(ctx.m_context, ctx.m_solver, num_assumptions, @assumptions[0]);
    if (res = Z3_L_FALSE) then
    begin
        // Display the UNSAT core
        Ss :='unsat core: ';
        core      := Z3_solver_get_unsat_core(ctx.m_context, ctx.m_solver);
        core_size := Z3_ast_vector_size(ctx.m_context, core);
        for i := 0 to  core_size - 1 do
        begin
            // In this example, we display the core based on the assertion ids.

            ///doh
            //var j : Cardinal;
            //var j : Cardinal;
            for j := 0 to ctx.m_num_answer_literals - 1 do
            begin
 	              if (Z3_ast_vector_get(ctx.m_context, core, i) = ctx.m_answer_literals[j]) then
                begin
                    Ss := Ss + (Format('%d ', [j]));
                    break;
                end;
            end;
            if (j = ctx.m_num_answer_literals) then
                exitf('bug in Z3, the core contains something that is not an assumption.');

        end;
        relog.Lines.Append(Ss);
    end;
    Result := res;
end;
(* -end- Z3_ext_context definition and implementation*************)

(**
   \brief Simple example using the functions: #mk_ext_context, #assert_retractable_cnstr, #retract_cnstr, #reassert_cnstr and #del_ext_context.
*)
procedure TMain.incremental_example1;
var
  x, y, z, two, one : Z3_ast;
  c1, c2, c3, c4    : Cardinal ;
  res               : Z3_lbool;
var ext_ctx  : Z3_ext_context;// := mk_ext_context;
var ctx      : Z3_context;//     := ext_ctx.m_context;

begin
    relog.Lines.Append(sLineBreak+ 'incremental_example1');
    LOG_MSG('incremental_example1');

    //var ext_ctx  : Z3_ext_context := mk_ext_context;
    //var ctx      : Z3_context     := ext_ctx.m_context;
    ext_ctx  := mk_ext_context;
    ctx      := ext_ctx.m_context;

    x          := mk_int_var(ctx, 'x');
    y          := mk_int_var(ctx, 'y');
    z          := mk_int_var(ctx, 'z');
    two        := mk_int(ctx, 2);
    one        := mk_int(ctx, 1);

    (* assert x < y *)
    c1 := assert_retractable_cnstr(ext_ctx, Z3_mk_lt(ctx, x, y));
    (* assert x = z *)
    c2 := assert_retractable_cnstr(ext_ctx, Z3_mk_eq(ctx, x, z));
    (* assert x > 2 *)
    c3 := assert_retractable_cnstr(ext_ctx, Z3_mk_gt(ctx, x, two));
    (* assert y < 1 *)
    c4 := assert_retractable_cnstr(ext_ctx, Z3_mk_lt(ctx, y, one));

    res := ext_check(ext_ctx);
    if (res <> Z3_L_FALSE) then  exitf('bug in Z3');
    relog.Lines.Append('unsat');

    retract_cnstr(ext_ctx, c4);
    res := ext_check(ext_ctx);
    if (res <> Z3_L_TRUE) then  exitf('bug in Z3');
    relog.Lines.Append('sat');

    reassert_cnstr(ext_ctx, c4);
    res := ext_check(ext_ctx);
    if (res <> Z3_L_FALSE) then exitf('bug in Z3');
    relog.Lines.Append('unsat');

    retract_cnstr(ext_ctx, c2);
    res := ext_check(ext_ctx);
    if (res <> Z3_L_FALSE) then exitf('bug in Z3');
    relog.Lines.Append('unsat');

    retract_cnstr(ext_ctx, c3);
    res := ext_check(ext_ctx);
    if (res <> Z3_L_TRUE) then  exitf('bug in Z3');
    relog.Lines.Append('sat');

    del_ext_context(ext_ctx);
end;

(**
   \brief Simple example showing how to use reference counters in Z3
   to manage memory efficiently.
*)
procedure TMain.reference_counter_example;
var
  cfg     : Z3_config;
  ctx     : Z3_context;
  s       : Z3_solver;
  ty      : Z3_sort;
  x, y,
  x_xor_y : Z3_ast;
  sx, sy  : Z3_symbol;
begin
    relog.Lines.Append(sLineBreak+ 'reference_counter_example');
    LOG_MSG('reference_counter_example');

    cfg                := Z3_mk_config();
    Z3_set_param_value(cfg, 'model', 'true');
    // Create a Z3 context where the user is responsible for managing
    // Z3_ast reference counters.
    ctx                := Z3_mk_context_rc(cfg);
    Z3_del_config(cfg);
    s                  := mk_solver(ctx);
    Z3_solver_inc_ref(ctx, s);

    ty      := Z3_mk_bool_sort(ctx);
    Z3_inc_ref(ctx, Z3_sort_to_ast(ctx, ty)); // Z3_sort_to_ast(ty) is just syntax sugar for ((Z3_ast) ty)
    sx      := Z3_mk_string_symbol(ctx, 'x');
    // Z3_symbol is not a Z3_ast. No reference counting is needed.
    x       := Z3_mk_const(ctx, sx, ty);
    Z3_inc_ref(ctx, x);
    sy      := Z3_mk_string_symbol(ctx, 'y');
    y       := Z3_mk_const(ctx, sy, ty);
    Z3_inc_ref(ctx, y);
    // ty is not needed anymore.
    Z3_dec_ref(ctx, Z3_sort_to_ast(ctx, ty));
    x_xor_y := Z3_mk_xor(ctx, x, y);
    Z3_inc_ref(ctx, x_xor_y);
    // x and y are not needed anymore.
    Z3_dec_ref(ctx, x);
    Z3_dec_ref(ctx, y);
    Z3_solver_assert(ctx, s, x_xor_y);
    // x_or_y is not needed anymore.
    Z3_dec_ref(ctx, x_xor_y);

    relog.Lines.Append('model for: x xor y');
    check(ctx, s, Z3_L_TRUE);

    // Test push & pop
    Z3_solver_push(ctx, s);
    Z3_solver_pop(ctx, s, 1);
    Z3_solver_dec_ref(ctx, s);

    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Demonstrates how to use SMT2 parser.
*)
procedure TMain.smt2parser_example;
var
  ctx : Z3_context;
  fs  : Z3_ast_vector;
Begin
    relog.Lines.Append(sLineBreak+ 'smt2parser_example');
    LOG_MSG('smt2parser_example');

    ctx := mk_context();
    fs  := Z3_parse_smtlib2_string(ctx, '(declare-fun a () (_ BitVec 8)) (assert (bvuge a #x10)) (assert (bvule a #xf0))', 0, 0, 0, 0, 0, 0);
    Z3_ast_vector_inc_ref(ctx, fs);
    relog.Lines.Append(Format('formulas: %s', [Z3_ast_vector_to_string(ctx, fs)]));
    Z3_ast_vector_dec_ref(ctx, fs);

    Z3_del_context(ctx);
end;

(**
   \brief Demonstrates how to use the function \c Z3_substitute to replace subexpressions in a Z3 AST.
*)
procedure TMain.substitute_example;
var
  ctx   : Z3_context;
  int_ty: Z3_sort;
  a, b  : Z3_ast;
  f     : Z3_func_decl;
  g     : Z3_func_decl;
  fab, ga, ffabga, r : Z3_ast;
  f_domain : array of Z3_sort;
  args     : array of Z3_ast;
  from,&to : array of Z3_ast;
var zero : Z3_ast;// := Z3_mk_numeral(ctx, '0', int_ty);
var one  : Z3_ast;// := Z3_mk_numeral(ctx, '1', int_ty);

begin
    relog.Lines.Append(sLineBreak+ 'substitute_example');
    LOG_MSG('substitute_example');

    ctx    := mk_context();
    int_ty := Z3_mk_int_sort(ctx);
    a      := mk_int_var(ctx,'a');
    b      := mk_int_var(ctx,'b');
    begin
        //doh
        //f_domain := [ int_ty, int_ty ];

        f_domain.create;
        TAppender<Z3_sort>.Append(f_domain, int_ty);
        TAppender<Z3_sort>.Append(f_domain, int_ty);

        f        := Z3_mk_func_decl(ctx, Z3_mk_string_symbol(ctx, 'f'), 2, @f_domain[0], int_ty);
    end;
    g := Z3_mk_func_decl(ctx, Z3_mk_string_symbol(ctx, 'g'), 1, @int_ty, int_ty);
    begin
        //doh
        //args  := [ a, b ];

        args.create;
        TAppender<Z3_ast>.Append(args, a);
        TAppender<Z3_ast>.Append(args, b);

        fab   := Z3_mk_app(ctx, f, 2, @args[0]);
    end;
    ga := Z3_mk_app(ctx, g, 1, @a);
    begin
        //doh
        //args   := [ fab, ga ];

        args.create;
        TAppender<Z3_ast>.Append(args, fab);
        TAppender<Z3_ast>.Append(args, ga);

        ffabga := Z3_mk_app(ctx, f, 2, @args[0]);
    end;
    // Replace b -> 0, g(a) -> 1 in f(f(a, b), g(a))
    begin
        ///doh
        //var zero : Z3_ast := Z3_mk_numeral(ctx, '0', int_ty);
        //var one  : Z3_ast := Z3_mk_numeral(ctx, '1', int_ty);
        zero  := Z3_mk_numeral(ctx, '0', int_ty);
        one   := Z3_mk_numeral(ctx, '1', int_ty);


        //doh
        //from     := [ b, ga ];

        from.create;
        TAppender<Z3_ast>.Append(from, b);
        TAppender<Z3_ast>.Append(from, ga);

        //doh
        //&to      := [ zero, one ];

        &to.create;
        TAppender<Z3_ast>.Append(&to, zero);
        TAppender<Z3_ast>.Append(&to, one);

        r := Z3_substitute(ctx, ffabga, 2, @from[0], @&to[0]);
    end;
    // Display r
    relog.Lines.Append(Format('substitution result: %s', [Z3_ast_to_string(ctx, r)]));
    Z3_del_context(ctx);
end;

(**
   \brief Demonstrates how to use the function \c Z3_substitute_vars to replace (free) variables with expressions in a Z3 AST.
*)
procedure TMain.substitute_vars_example;
var
  ctx           : Z3_context;
  int_ty        : Z3_sort;
  x0, x1        : Z3_ast;
  a, b, gb      : Z3_ast;
  f             : Z3_func_decl;
  g             : Z3_func_decl ;
  f01, ff010, r : Z3_ast;

  f_domain : array of Z3_sort;
  args,&to : array of Z3_ast;
begin
    relog.Lines.Append(sLineBreak+ 'substitute_vars_example');
    LOG_MSG('substitute_vars_example');

    ctx    := mk_context();
    int_ty := Z3_mk_int_sort(ctx);
    x0     := Z3_mk_bound(ctx, 0, int_ty);
    x1     := Z3_mk_bound(ctx, 1, int_ty);
    begin
        //doh
        //f_domain := [ int_ty, int_ty ];


        f_domain.create;
        TAppender<Z3_ast>.Append(f_domain, int_ty);
        TAppender<Z3_ast>.Append(f_domain, int_ty);

        f        := Z3_mk_func_decl(ctx, Z3_mk_string_symbol(ctx, 'f'), 2, @f_domain[0], int_ty);
    end;
    g := Z3_mk_func_decl(ctx, Z3_mk_string_symbol(ctx, 'g'), 1, @int_ty, int_ty);
    begin
        //doh
        //args  := [ x0, x1 ];

        args.create;
        TAppender<Z3_ast>.Append(args, x0);
        TAppender<Z3_ast>.Append(args, x1);


        f01   := Z3_mk_app(ctx, f, 2, @args[0]);
    end;
    begin
        //doh
        //args  := [ f01, x0 ];

        args.create;
        TAppender<Z3_ast>.Append(args, f01);
        TAppender<Z3_ast>.Append(args, x0);



        ff010 := Z3_mk_app(ctx, f, 2, @args[0]);
    end;
    a  := mk_int_var(ctx, 'a');
    b  := mk_int_var(ctx, 'b');
    gb := Z3_mk_app(ctx, g, 1, @b);
    // Replace x0 -> a, x1 -> g(b) in f(f(x0,x1),x0)
    begin
        //doh
        //&to := [ a, gb ];


        &to.create;
        TAppender<Z3_ast>.Append(&to, a);
        TAppender<Z3_ast>.Append(&to, gb);

        r   := Z3_substitute_vars(ctx, ff010, 2, @&to[0]);
    end;
    // Display r
    relog.Lines.Append(Format('substitution result: %s', [Z3_ast_to_string(ctx, r)]));
    Z3_del_context(ctx);
end;

(**
   \brief Demonstrates some basic features of the FloatingPoint theory.
*)

procedure TMain.fpa_example;
var
  cfg              : Z3_config;
  ctx              : Z3_context;
  s                : Z3_solver;
  double_sort,
  rm_sort          : Z3_sort;
  s_rm, s_x,
  s_y, s_x_plus_y  : Z3_symbol;
  rm, x, y, n,
  x_plus_y, c1, c2,
  c3, c4, c5       : Z3_ast;
	args, args2      : array[0..1] of Z3_ast ;
  and_args, args3  : array[0..2] of Z3_ast;

Begin
    relog.Lines.Append(sLineBreak+ 'FPA-example');
    LOG_MSG('FPA-example');

    cfg := Z3_mk_config();
    ctx := Z3_mk_context(cfg);
    s   := mk_solver(ctx);
    Z3_del_config(cfg);

    double_sort := Z3_mk_fpa_sort(ctx, 11, 53);
    rm_sort     := Z3_mk_fpa_rounding_mode_sort(ctx);

    // Show that there are x, y s.t. (x + y) = 42.0 (with rounding mode).
    s_rm := Z3_mk_string_symbol(ctx, 'rm');
    rm   := Z3_mk_const(ctx, s_rm, rm_sort);
    s_x  := Z3_mk_string_symbol(ctx, 'x');
    s_y  := Z3_mk_string_symbol(ctx, 'y');
    x    := Z3_mk_const(ctx, s_x, double_sort);
    y    := Z3_mk_const(ctx, s_y, double_sort);
    n    := Z3_mk_fpa_numeral_double(ctx, 42.0, double_sort);

    s_x_plus_y := Z3_mk_string_symbol(ctx, 'x_plus_y');
    x_plus_y   := Z3_mk_const(ctx, s_x_plus_y, double_sort);
    c1         := Z3_mk_eq(ctx, x_plus_y, Z3_mk_fpa_add(ctx, rm, x, y));

    args[0] := c1;
    args[1] := Z3_mk_eq(ctx, x_plus_y, n);
    c2      := Z3_mk_and(ctx, 2, @args[0]);

    args2[0] := c2;
    args2[1] := Z3_mk_not(ctx, Z3_mk_eq(ctx, rm, Z3_mk_fpa_rtz(ctx)));
    c3       := Z3_mk_and(ctx, 2, @args2[0]);

    and_args[0] := Z3_mk_not(ctx, Z3_mk_fpa_is_zero(ctx, y));
    and_args[1] := Z3_mk_not(ctx, Z3_mk_fpa_is_nan(ctx, y));
    and_args[2] := Z3_mk_not(ctx, Z3_mk_fpa_is_infinite(ctx, y));
    args3[0]    := c3;
    args3[1]    := Z3_mk_and(ctx, 3, @and_args[0]);
    c4          := Z3_mk_and(ctx, 2, @args3[0]);

    relog.Lines.Append(Format('c4: %s', [Z3_ast_to_string(ctx, c4)]));
    Z3_solver_push(ctx, s);
    Z3_solver_assert(ctx, s, c4);
    check(ctx, s, Z3_L_TRUE);
    Z3_solver_pop(ctx, s, 1);

    // Show that the following are equal:
    //   (fp #b0 #b10000000001 #xc000000000000)
    //   ((_ to_fp 11 53) #x401c000000000000))
    //   ((_ to_fp 11 53) RTZ 1.75 2)))
    //   ((_ to_fp 11 53) RTZ 7.0)))

    Z3_solver_push(ctx, s);
    c1 := Z3_mk_fpa_fp(ctx,
                       Z3_mk_numeral(ctx, '0', Z3_mk_bv_sort(ctx, 1)),
                       Z3_mk_numeral(ctx, '1025', Z3_mk_bv_sort(ctx, 11)),
                       Z3_mk_numeral(ctx, '3377699720527872', Z3_mk_bv_sort(ctx, 52)));
    c2 := Z3_mk_fpa_to_fp_bv(ctx,
                             Z3_mk_numeral(ctx, '4619567317775286272', Z3_mk_bv_sort(ctx, 64)),
                             Z3_mk_fpa_sort(ctx, 11, 53));
    c3 := Z3_mk_fpa_to_fp_int_real(ctx,
                                   Z3_mk_fpa_rtz(ctx),
                                   Z3_mk_numeral(ctx, '2', Z3_mk_int_sort(ctx)),     (* exponent *)
                                   Z3_mk_numeral(ctx, '1.75', Z3_mk_real_sort(ctx)), (* significand *)
                                   Z3_mk_fpa_sort(ctx, 11, 53));
    c4 := Z3_mk_fpa_to_fp_real(ctx,
                               Z3_mk_fpa_rtz(ctx),
                               Z3_mk_numeral(ctx, '7.0', Z3_mk_real_sort(ctx)),
                               Z3_mk_fpa_sort(ctx, 11, 53));
    args3[0] := Z3_mk_eq(ctx, c1, c2);
    args3[1] := Z3_mk_eq(ctx, c1, c3);
    args3[2] := Z3_mk_eq(ctx, c1, c4);
    c5       := Z3_mk_and(ctx, 3, @args3[0]);

    relog.Lines.Append(Format('c5: %s', [Z3_ast_to_string(ctx, c5)]));
    Z3_solver_assert(ctx, s, c5);
    check(ctx, s, Z3_L_TRUE);
    Z3_solver_pop(ctx, s, 1);

    del_solver(ctx, s);
    Z3_del_context(ctx);
end;

(**
   \brief Demonstrates some basic features of model construction
*)

procedure TMain.mk_model_example;
var
  ctx              : Z3_context;
  m                : Z3_model;
  intSort          : Z3_sort ;
  aSymbol,
  bSymbol,
  cSymbol          : Z3_symbol;
  aFuncDecl,
  bFuncDecl,
  cFuncDecl        : Z3_func_decl;
  aApp, bApp,
  cApp             : Z3_ast;
  int2intArraySort : Z3_sort;
  zeroNumeral,
  oneNumeral,
  twoNumeral,
  threeNumeral,
  fourNumeral     : Z3_ast;
  addArgs,
  arrayAddArgs    : array of Z3_ast;
  arrayDomain     : array[0..0] of Z3_sort;
  expectedInterpretations : array of Z3_func_decl;
  cAsFuncDecl     : Z3_func_decl;
  cAsFuncInterp   : Z3_func_interp;
  zeroArgs        : Z3_ast_vector;
  oneArgs         : Z3_ast_vector;
  cFuncDeclAsArray: Z3_ast;
  modelAsString   : Z3_string;
var d  : Z3_func_decl;// := expectedInterpretations[index];
var index : Integer;
var aPlusB : Z3_ast;// := Z3_mk_add(ctx, (*num_args=*)2, (*args=*)    @addArgs[0]);
var aPlusBEval : Z3_ast;// := Nil;
var aPlusBEvalSuccess : Boolean;// := Z3_model_eval(ctx, m, aPlusB, (*model_completion=*)false,@aPlusBEval);
var aPlusBValue           : Integer;// := 0;
var getAPlusBValueSuccess : Boolean;// := Z3_get_numeral_int(ctx, aPlusBEval, @aPlusBValue);

var c0 : Z3_ast;// := Z3_mk_select(ctx, cApp, zeroNumeral);
var c1 : Z3_ast;// := Z3_mk_select(ctx, cApp, oneNumeral);
var c2 : Z3_ast;// := Z3_mk_select(ctx, cApp, twoNumeral);

var arrayAdd : Z3_ast;// := Z3_mk_add(ctx, (*num_args=*)3, (*args=*)    @arrayAddArgs[0]);
var arrayAddEval : Z3_ast;// := nil;
var arrayAddEvalSuccess  : Boolean;// :=  Z3_model_eval(ctx, m, arrayAdd, (*model_completion=*)false, @arrayAddEval);

var arrayAddValue : Integer ;
var getArrayAddValueSuccess : Boolean ;



begin
    relog.Lines.Append(sLineBreak+ 'mk_model_example');
    LOG_MSG('mk_model_example');

    ctx := mk_context();
    // Construct empty model
    m := Z3_mk_model(ctx);
    Z3_model_inc_ref(ctx, m);

    // Create constants "a" and "b"
    intSort   := Z3_mk_int_sort(ctx);
    aSymbol   := Z3_mk_string_symbol(ctx, 'a');
    aFuncDecl := Z3_mk_func_decl(ctx, aSymbol,
                                (*domain_size=*)0,
                                (*domain=*)     nil,
                                (*range=*)      intSort);
    aApp := Z3_mk_app(ctx, aFuncDecl,
                     (*num_args=*)0,
                     (*args=*)nil);
    bSymbol   := Z3_mk_string_symbol(ctx, 'b');
    bFuncDecl := Z3_mk_func_decl(ctx, bSymbol,
                                (*domain_size=*)0,
                                (*domain=*)     nil,
                                (*range=*)      intSort);
    bApp := Z3_mk_app(ctx, bFuncDecl,
                     (*num_args=*)0,
                     (*args=*)    nil);

    // Create array "c" that maps int to int.
    cSymbol          := Z3_mk_string_symbol(ctx, 'c');
    int2intArraySort := Z3_mk_array_sort(ctx,
                                        (*domain=*)intSort,
                                        (*range=*) intSort);
    cFuncDecl := Z3_mk_func_decl(ctx, cSymbol,
                                (*domain_size=*)0,
                                (*domain=*)     nil,
                                (*range=*)      int2intArraySort);
    cApp := Z3_mk_app(ctx, cFuncDecl,
                     (*num_args=*)0,
                     (*args=*)    nil);

    // Create numerals to be used in model
    zeroNumeral := Z3_mk_int(ctx, 0, intSort);
    oneNumeral  := Z3_mk_int(ctx, 1, intSort);
    twoNumeral  := Z3_mk_int(ctx, 2, intSort);
    threeNumeral:= Z3_mk_int(ctx, 3, intSort);
    fourNumeral := Z3_mk_int(ctx, 4, intSort);

    // Add assignments to model
    // a == 1
    Z3_add_const_interp(ctx, m, aFuncDecl, oneNumeral);
    // b == 2
    Z3_add_const_interp(ctx, m, bFuncDecl, twoNumeral);

    // Create a fresh function that represents
    // reading from array.
    arrayDomain[0] := intSort;
    cAsFuncDecl    := Z3_mk_fresh_func_decl(ctx,
                                        (*prefix=*)     '',
                                        (*domain_size*) 1,
                                        (*domain=*)     @arrayDomain[0],
                                        (*sort=*)       intSort);
    // Create function interpretation with default
    // value of "0".
    cAsFuncInterp := Z3_add_func_interp(ctx, m, cAsFuncDecl,
                                       (*default_value=*)zeroNumeral);
    Z3_func_interp_inc_ref(ctx, cAsFuncInterp);
    // Add [0] = 3
    zeroArgs := Z3_mk_ast_vector(ctx);
    Z3_ast_vector_inc_ref(ctx, zeroArgs);
    Z3_ast_vector_push(ctx, zeroArgs, zeroNumeral);
    Z3_func_interp_add_entry(ctx, cAsFuncInterp, zeroArgs, threeNumeral);
    // Add [1] = 4
    oneArgs := Z3_mk_ast_vector(ctx);
    Z3_ast_vector_inc_ref(ctx, oneArgs);
    Z3_ast_vector_push(ctx, oneArgs, oneNumeral);
    Z3_func_interp_add_entry(ctx, cAsFuncInterp, oneArgs, fourNumeral);

    // Now use the `(_ as_array)` to associate
    // the `cAsFuncInterp` with the `cFuncDecl`
    // in the model
    cFuncDeclAsArray := Z3_mk_as_array(ctx, cAsFuncDecl);
    Z3_add_const_interp(ctx, m, cFuncDecl, cFuncDeclAsArray);

    // Print the model
    modelAsString := Z3_model_to_string(ctx, m);
    relog.Lines.Append(Format('Model:'+ sLineBreak +'%s', [modelAsString]));

    // Check the interpretations we expect to be present
    // are.
    begin
        //doh
        //expectedInterpretations := [aFuncDecl, bFuncDecl, cFuncDecl];

        expectedInterpretations.create;
        TAppender<Z3_func_decl>.Append(expectedInterpretations, aFuncDecl);
        TAppender<Z3_func_decl>.Append(expectedInterpretations, bFuncDecl);
        TAppender<Z3_func_decl>.Append(expectedInterpretations, cFuncDecl);

        //var index : Integer;

        for index := 0 to Length(expectedInterpretations) - 1 do
        begin
            //var d  : Z3_func_decl := expectedInterpretations[index];
            d  := expectedInterpretations[index];
            if (Z3_model_has_interp(ctx, m, d)) then
            begin
                relog.Lines.Append(Format('Found interpretation for "%s"', [Z3_ast_to_string(ctx, Z3_func_decl_to_ast(ctx, d))]));
            end else
            begin
                relog.Lines.Append('Missing interpretation');
                exit;
            end;
        end;
    end;

    begin
        // Evaluate a + b under model
        //doh
        //addArgs             := [aApp, bApp];

        addArgs.create;
        TAppender<Z3_ast>.Append(addArgs, aApp);
        TAppender<Z3_ast>.Append(addArgs, bApp);

        //doh
        //var aPlusB : Z3_ast := Z3_mk_add(ctx,
        //                          (*num_args=*)2,
        //                          (*args=*)    @addArgs[0]);
        //var aPlusBEval : Z3_ast := Nil;
        //var aPlusBEvalSuccess : Boolean := Z3_model_eval(ctx, m, aPlusB,
        //                                 (*model_completion=*)false,
        //                                                @aPlusBEval);

        aPlusB  := Z3_mk_add(ctx,(*num_args=*)2, (*args=*)    @addArgs[0]);
        aPlusBEval  := Nil;
        aPlusBEvalSuccess  := Z3_model_eval(ctx, m, aPlusB, (*model_completion=*)false, @aPlusBEval);


        if (aPlusBEvalSuccess <> true) then
        begin
            relog.Lines.Append('Failed to evaluate model');
            exit;
        end;

        begin
            //doh
            //var aPlusBValue           : Integer := 0;
            //var getAPlusBValueSuccess : Boolean := Z3_get_numeral_int(ctx, aPlusBEval, @aPlusBValue);
            aPlusBValue           := 0;
            getAPlusBValueSuccess  := Z3_get_numeral_int(ctx, aPlusBEval, @aPlusBValue);
            if (getAPlusBValueSuccess <> true) then
            begin
                relog.Lines.Append('Failed to get integer value for a+b');
                exit;
            end;
            relog.Lines.Append(Format('Evaluated a + b = %d', [aPlusBValue]));
            if (aPlusBValue <> 3) then
            begin
                relog.Lines.Append('a+b did not evaluate to expected value');
                exit;
            end;
        end;
    end;

    begin
        //doh
        // Evaluate c[0] + c[1] + c[2] under model
        //var c0 : Z3_ast := Z3_mk_select(ctx, cApp, zeroNumeral);
        //var c1 : Z3_ast := Z3_mk_select(ctx, cApp, oneNumeral);
        //var c2 : Z3_ast := Z3_mk_select(ctx, cApp, twoNumeral);
        c0  := Z3_mk_select(ctx, cApp, zeroNumeral);
        c1  := Z3_mk_select(ctx, cApp, oneNumeral);
        c2  := Z3_mk_select(ctx, cApp, twoNumeral);

        //doh
        //arrayAddArgs    := [c0, c1, c2];

        arrayAddArgs.create;
        TAppender<Z3_ast>.Append(arrayAddArgs, c0);
        TAppender<Z3_ast>.Append(arrayAddArgs, c1);
        TAppender<Z3_ast>.Append(arrayAddArgs, c2);


        //doh
        //var arrayAdd : Z3_ast := Z3_mk_add(ctx,
        //                            (*num_args=*)3,
        //                            (*args=*)    @arrayAddArgs[0]);
        //var arrayAddEval : Z3_ast := nil;
        //var arrayAddEvalSuccess  : Boolean :=  Z3_model_eval(ctx, m, arrayAdd,
        arrayAdd  := Z3_mk_add(ctx, (*num_args=*)3, (*args=*)    @arrayAddArgs[0]);
        arrayAddEval  := nil;
        arrayAddEvalSuccess  :=  Z3_model_eval(ctx, m, arrayAdd, (*model_completion=*)false, @arrayAddEval);
        if (arrayAddEvalSuccess <> true) then
        begin
            relog.Lines.Append('Failed to evaluate model');
            exit;
        end;
        begin
            //doh
            //var arrayAddValue : Integer := 0;
            //var getArrayAddValueSuccess : Boolean := Z3_get_numeral_int(ctx, arrayAddEval, @arrayAddValue);
            arrayAddValue  := 0;
            getArrayAddValueSuccess  := Z3_get_numeral_int(ctx, arrayAddEval, @arrayAddValue);
            if (getArrayAddValueSuccess <> true) then
            begin
                relog.Lines.Append('Failed to get integer value for c[0] + c[1] + c[2]');
                exit;
            end;
            relog.Lines.Append(Format('Evaluated c[0] + c[1] + c[2] = %d', [arrayAddValue]));
            if (arrayAddValue <> 7) then
            begin
                relog.Lines.Append('c[0] + c[1] + c[2] did not evaluate to expected value');
                exit;
            end;
        end;
    end;

    Z3_ast_vector_dec_ref(ctx, oneArgs);
    Z3_ast_vector_dec_ref(ctx, zeroArgs);
    Z3_func_interp_dec_ref(ctx, cAsFuncInterp);
    Z3_model_dec_ref(ctx, m);
    Z3_del_context(ctx);
end;

(**
   \brief Simple function that tries to prove the given conjecture using the following steps:
   1- create a solver
   2- assert the negation of the conjecture
   3- checks if the result is unsat.
*)
procedure TMain.prove_(conjecture: TExpr);
var c : TContext ;

var s : TSolver ;

begin
   //doh
   //var c : TContext := conjecture.ctx;
   //
   //var s : TSolver := TSolver.Create(c);
   c  := conjecture.ctx;

   s  := TSolver.Create(c);

    s.add( OpNot(conjecture));

    relog.Lines.Append('conjecture:' +sLineBreak + conjecture.ToStr);
    if (s.check = unsat) then
    begin
        relog.Lines.Append('proved')
    end else
    begin
        relog.Lines.Append('failed to prove');
        relog.Lines.Append('counterexample:'+sLineBreak + s.get_model.ToStr);
    end;
end;
(**********************************************************************)
(*                      End Test Api                                  *)
(**********************************************************************)


(**********************************************************************)
(*                      Start Test Class                              *)
(**********************************************************************)

procedure TMain.tactic_example7;
(*
  Tactics can be combined with solvers.
  For example, we can apply a tactic to a goal, produced a set of subgoals,
  then select one of the subgoals and solve it using a solver.
  This example demonstrates how to do that, and
  how to use model converters to convert a model for a subgoal into a model for the original goal.
*)
var c : TContext ;
var t : TTactic ;
var x : TExpr ;
var y : TExpr ;
var z : TExpr ;
var g : TGoal ;
var r : TApply_result ;
var s : TSolver;// := TSolver.Create(c);
var i : Integer;
var subgoal : TGoal;// := r.Items[0];
var m : TModel;// := s.get_model;


begin
    relog.Lines.Append(sLineBreak+ 'tactic example 7');
    //doh
    //var c : TContext := TContext.Create;
    //
    //var t: TTactic := TTactic.Create(c, 'simplify') ;
    //    t := T_OpAnd(t, TTactic.Create(c, 'normalize-bounds') );
    //    t := T_OpAnd(t, TTactic.Create(c, 'solve-eqs') );
    //
    //var x  : TExpr := c.int_const('x');
    //var y  : TExpr := c.int_const('y');
    //var z  : TExpr := c.int_const('z');
    //
    //var g : TGoal := TGoal.Create(c);
    c := TContext.Create;

    t := TTactic.Create(c, 'simplify') ;
    t := T_OpAnd(t, TTactic.Create(c, 'normalize-bounds') );
    t := T_OpAnd(t, TTactic.Create(c, 'solve-eqs') );

    x := c.int_const('x');
    y := c.int_const('y');
    z := c.int_const('z');

    g := TGoal.Create(c);
    g.add(OpMajor(x,10));
    g.add( OpEq(y,OpAdd(x,3)) );
    g.add( OpMajor(z,y) );
    //doh
    //var r : TApply_result := t.ToApplyRes(g);
    r := t.ToApplyRes(g);
    //doh
    // r contains only one subgoal
    relog.Lines.Append(r.ToStr);

    //doh
    //var s: TSolver := TSolver.Create(c);
    //var i : Integer;
    //var subgoal : TGoal := r.Items[0];
    s := TSolver.Create(c);
    //i : Integer;
    subgoal  := r.Items[0];
    for i := 0 to subgoal.size - 1 do
        s.add( subgoal.Items[i] );

    relog.Lines.Append( check_resultToStr(s.check) );

    //doh
    //var m : TModel := s.get_model;
    m  := s.get_model;
    relog.Lines.Append('model for subgoal:' +sLineBreak + m.ToStr ) ;
    relog.Lines.Append('model for original goal:' +sLineBreak + subgoal.convert_model(m).ToStr )
    
end;

procedure TMain.tactic_example6;
(*
In this example, we show how to implement a solver for integer arithmetic using SAT.
The solver is complete only for problems where every variable has a lower and upper bound.
*)
var c : TContext;// := TContext.Create;
var p: TParams;// := TParams.Create(c);
var t: TTactic;// := &with(TTactic.Create(c, 'simplify'), p) ;
var s : TSolver;//  := t.mk_solver;

var x  : TExpr;// := c.int_const('x');
var y  : TExpr;// := c.int_const('y');
var z  : TExpr;// := c.int_const('z');

begin
    relog.Lines.Append(sLineBreak+ 'tactic example 6');
    //var c : TContext := TContext.Create;
    //var p: TParams := TParams.Create(c);
    c := TContext.Create;
    p := TParams.Create(c);

    p.&set('arith_lhs', true);
    p.&set('som', true); // sum-of-monomials normal form

    //var t: TTactic := &with(TTactic.Create(c, 'simplify'), p) ;
    t  := &with(TTactic.Create(c, 'simplify'), p) ;
    t := T_OpAnd(t, TTactic.Create(c, 'normalize-bounds') );
    t := T_OpAnd(t, TTactic.Create(c, 'lia2pb') );
    t := T_OpAnd(t, TTactic.Create(c, 'pb2bv') );
    t := T_OpAnd(t, TTactic.Create(c, 'bit-blast') );
    t := T_OpAnd(t, TTactic.Create(c, 'sat') );

    //var s : TSolver  := t.mk_solver;
    //
    //var x  : TExpr := c.int_const('x');
    //var y  : TExpr := c.int_const('y');
    //var z  : TExpr := c.int_const('z');
    s  := t.mk_solver;

    x  := c.int_const('x');
    y  := c.int_const('y');
    z  := c.int_const('z');

    s.add( OpAnd(OpMajor(x,0), OpMinor(x,10)));
    s.add( OpAnd(OpMajor(y,0), OpMinor(y,10)));
    s.add( OpAnd(OpMajor(z,0), OpMinor(z,10)));

    //s.add(3*y + 2*x == z)
    s.add( OpEq(OpAdd(OpMul(3,y), OpMul(2,x)),z) );
    relog.Lines.Append( check_resultToStr(s.check));
    relog.Lines.Append( s.get_model.ToStr);

    s.reset;
    //s.add(3*y + 2*x == z);
    s.add( OpEq(OpAdd(OpMul(3,y), OpMul(2,x)),z) );
    relog.Lines.Append( check_resultToStr(s.check));
end;

procedure TMain.tactic_example5;
(*
 The tactic smt wraps the main solver in Z3 as a tactic.
*)
var c : TContext;// := TContext.Create;
var x  : TExpr;// := c.int_const('x');
var y  : TExpr;// := c.int_const('y');

var s : TSolver;// := TTactic.Create(c, 'smt').mk_solver;

begin
    relog.Lines.Append(sLineBreak+ 'tactic example 5');
    //var c : TContext := TContext.Create;
    //var x  : TExpr := c.int_const('x');
    //var y  : TExpr := c.int_const('y');
    //
    //var s : TSolver := TTactic.Create(c, 'smt').mk_solver;
    c  := TContext.Create;
    x  := c.int_const('x');
    y  := c.int_const('y');
    s  := TTactic.Create(c, 'smt').mk_solver;
    s.add(OpMajor(x, OpAdd(y,1)) );

    relog.Lines.Append(check_resultToStr(s.check));
    relog.Lines.Append(s.get_model.ToStr);

end;

procedure TMain.tactic_example4;
(*
  A tactic can be converted into a solver object using the method mk_solver().
  If the tactic produces the empty goal, then the associated solver returns sat.
  If the tactic produces a single goal containing False, then the solver returns unsat.
  Otherwise, it returns unknown.

  In this example, the tactic t implements a basic bit-vector solver using equation solving,
  bit-blasting, and a propositional SAT solver.
  We use the combinator `with` to configure our little solver.
  We also include the tactic `aig` which tries to compress Boolean formulas using And-Inverted Graphs.
*)
var c : TContext;// := TContext.Create;

var p : TParams;// := TParams.Create(c);
var t : TTactic;// := &with( TTactic.Create(c, 'simplify'), p);
var s : TSolver;// := t.mk_solver;

var x  : TExpr;// := c.bv_const('x',16);
var y  : TExpr;// := c.bv_const('y',16);
var m : TModel;// := s.get_model;

begin
    relog.Lines.Append(sLineBreak+ 'tactic example 4');
    //var c : TContext := TContext.Create;
    //
    //var p : TParams := TParams.Create(c);
    c := TContext.Create;

    p := TParams.Create(c);
    p.&set('mul2concat', true);
    //var t : TTactic := &with( TTactic.Create(c, 'simplify'), p);
    t := &with( TTactic.Create(c, 'simplify'), p);
    t := T_OpAnd( t, TTactic.Create(c, 'solve-eqs'));
    t := T_OpAnd( t, TTactic.Create(c, 'bit-blast'));
    t := T_OpAnd( t, TTactic.Create(c, 'aig'));
    t := T_OpAnd( t, TTactic.Create(c, 'sat'));

    //var s : TSolver := t.mk_solver;
    //
    //var x  : TExpr := c.bv_const('x',16);
    //var y  : TExpr := c.bv_const('y',16);
    s := t.mk_solver;

    x := c.bv_const('x',16);
    y := c.bv_const('y',16);

    s.add( OpEq(OpAdd(OpMul(x,32),y),13));
    // In C++, the operator < has higher precedence than &.
    s.add( OpMinor(OpAndbv(x,y),10) );
    s.add(OpMajor(y,-100));

    relog.Lines.Append(check_resultToStr(s.check));
    m  := s.get_model;
    relog.Lines.Append(m.ToStr);
    relog.Lines.Append('x*32 + y = ' + (m.eval(OpAdd(OpMul(x,32),y)).ToStr )) ;
    relog.Lines.Append('x & y    = ' + (m.eval(OpAndbv(x,y)).ToStr));
    
end;

procedure TMain.tactic_example3;
var c : TContext;// := TContext.Create;

var x  : TExpr;// := c.real_const('x');
var y  : TExpr;// := c.real_const('y');
var z  : TExpr;// := c.real_const('z');

var g  : TGoal;// := TGoal.Create(c);
var t1 : TTactic;// := TTactic.Create(c,'split-clause');
var t2 : TTactic;// := TTactic.Create(c,'skip');
var split_all : TTactic;// := &repeat( T_OpOr(t1,t2) );
var split_at_most_2 : TTactic;// := &repeat(T_OpOr(t1,t2), 1);
var split_solve : TTactic;// := T_OpAnd(split_all, TTactic.Create(c, 'solve-eqs'));

begin
    relog.Lines.Append(sLineBreak+ 'tactic example 3');
    //var c : TContext := TContext.Create;
    //
    //var x  : TExpr := c.real_const('x');
    //var y  : TExpr := c.real_const('y');
    //var z  : TExpr := c.real_const('z');
    //
    //var g : TGoal := TGoal.Create(c);
    c := TContext.Create;

    x := c.real_const('x');
    y := c.real_const('y');
    z := c.real_const('z');

    g := TGoal.Create(c);

    g.add( OpOr( OpEq(x, 0), Opeq(x,1) ) );
    g.add( OpOr( OpEq(y, 0), Opeq(y,1) ) );
    g.add( OpOr( OpEq(z, 0), Opeq(z,1) ) );

    g.add( OpMajor(OpAdd(OpAdd(x,y),z),2) );
    // split all clauses

    //var t1        : TTactic := TTactic.Create(c,'split-clause');
    //var t2        : TTactic := TTactic.Create(c,'skip');
    //var split_all : TTactic := &repeat( T_OpOr(t1,t2) );
    t1 := TTactic.Create(c,'split-clause');
    t2 := TTactic.Create(c,'skip');
    split_all := &repeat( T_OpOr(t1,t2) );
    relog.Lines.Append(split_all.ToApplyRes(g).ToStr );

    t1 := TTactic.Create(c,'split-clause');
    t2 := TTactic.Create(c,'skip');
    //var split_at_most_2 : TTactic := &repeat(T_OpOr(t1,t2), 1);
    split_at_most_2 := &repeat(T_OpOr(t1,t2), 1);
    relog.Lines.Append(split_at_most_2.ToApplyRes(g).ToStr);

    // In the tactic split_solver, the tactic solve-eqs discharges all but one goal.
    // Note that, this tactic generates one goal: the empty goal which is trivially satisfiable (i.e., feasible)
    //var split_solve : TTactic := T_OpAnd(split_all, TTactic.Create(c, 'solve-eqs'));
    split_solve := T_OpAnd(split_all, TTactic.Create(c, 'solve-eqs'));
    relog.Lines.Append(split_solve.ToApplyRes(g).ToStr);

end;

procedure TMain.tactic_example2;
(*
  In Z3, we say a clause is any constraint of the form (f_1 || ... || f_n).
  The tactic split-clause will select a clause in the input goal, and split it n subgoals.
  One for each subformula f_i.
*)
var c : TContext;// := TContext.Create;

var x  : TExpr;// := c.real_const('x');
var y  : TExpr;// := c.real_const('y');

var g : TGoal;// := TGoal.Create(c);
var t : TTactic;//       := TTactic.Create(c, 'split-clause');
var r : TApply_result;// := t.ToApplyRes(g);
var i : Integer;

begin
    relog.Lines.Append(sLineBreak+ 'tactic example 2');
    //var c : TContext := TContext.Create;
    //
    //var x  : TExpr := c.real_const('x');
    //var y  : TExpr := c.real_const('y');
    //
    //var g : TGoal := TGoal.Create(c);
    c := TContext.Create;
    x := c.real_const('x');
    y := c.real_const('y');
    g := TGoal.Create(c);
    g.add( OpOr( OpMinor(x, 0), OpMajor(x,0) ) );
    g.add( OpEq(x,OpAdd(y, 1)) );
    g.add( OpMinor(y, 0) );

    //var t : TTactic       := TTactic.Create(c, 'split-clause');
    //var r : TApply_result := t.ToApplyRes(g);
    //var i : Integer;
    t := TTactic.Create(c, 'split-clause');
    r := t.ToApplyRes(g);
    //var i : Integer;
    for i := 0 to r.size - 1 do
      relog.Lines.Append( 'subgoal '+ IntToStr(i) + sLineBreak + r.Items[i].ToStr );

end;

procedure TMain.tactic_example1;
(*
  Z3 implements a methodology for orchestrating reasoning engines where "big" symbolic
  reasoning steps are represented as functions known as tactics, and tactics are composed
  using combinators known as tacticals. Tactics process sets of formulas called Goals.

  When a tactic is applied to some goal G, four different outcomes are possible. The tactic succeeds
  in showing G to be satisfiable (i.e., feasible); succeeds in showing G to be unsatisfiable (i.e., infeasible);
  produces a sequence of subgoals; or fails. When reducing a goal G to a sequence of subgoals G1, ..., Gn,
  we face the problem of model conversion. A model converter construct a model for G using a model for some subgoal Gi.

  In this example, we create a goal g consisting of three formulas, and a tactic t composed of two built-in tactics:
  simplify and solve-eqs. The tactic simplify apply transformations equivalent to the ones found in the command simplify.
  The tactic solver-eqs eliminate variables using Gaussian elimination. Actually, solve-eqs is not restricted
  only to linear arithmetic. It can also eliminate arbitrary variables.
  Then, sequential composition combinator & applies simplify to the input goal and solve-eqs to each subgoal produced by simplify.
  In this example, only one subgoal is produced.
*)
var c : TContext;// := TContext.Create;

var x  : TExpr;// := c.real_const('x');
var y  : TExpr;// := c.real_const('y');

var g : TGoal;// := TGoal.Create(c);
var t1 : TTactic;// := TTactic.Create(c, 'simplify');
var t2 : TTactic;// := TTactic.Create(c, 'solve-eqs');
var t  : TTactic;// := T_OpAnd(t1,t2);

var r : TApply_result;// := t.ToApplyRes(g);

begin
    relog.Lines.Append(sLineBreak+ 'tactic example 1');
    //var c : TContext := TContext.Create;
    //
    //var x  : TExpr := c.real_const('x');
    //var y  : TExpr := c.real_const('y');
    //
    //var g : TGoal := TGoal.Create(c);
    c  := TContext.Create;
    x  := c.real_const('x');
    y  := c.real_const('y');
    g  := TGoal.Create(c);
    g.add( OpMajor(x,0) );
    g.add( OpMajor(y,0) );
    g.add( OpEq(x, OpAdd(y,2)) );
    relog.Lines.Append(g.ToStr);

    //var t1 : TTactic := TTactic.Create(c, 'simplify');
    //var t2 : TTactic := TTactic.Create(c, 'solve-eqs');
    //var t  : TTactic := T_OpAnd(t1,t2);
    //
    //var r : TApply_result := t.ToApplyRes(g);
    t1 := TTactic.Create(c, 'simplify');
    t2 := TTactic.Create(c, 'solve-eqs');
    t  := T_OpAnd(t1,t2);

    r  := t.ToApplyRes(g);
    relog.Lines.Append(r.ToStr);

end;

(**
   \brief Unsat core example 3
*)
procedure TMain.unsat_core_example3;
var c : TContext;// := TContext.Create;

var x  : TExpr;// := c.int_const('x');
var y  : TExpr;// := c.int_const('y');

var s : TSolver;// := TSolver.Create(c);

// enabling unsat core tracking
var p : TParams;// := TParams.Create(c);

begin
    // Extract unsat core using tracked assertions
    relog.Lines.Append(sLineBreak+ 'unsat core example3');
    //var c : TContext := TContext.Create;
    //
    //var x  : TExpr := c.int_const('x');
    //var y  : TExpr := c.int_const('y');
    //
    //var s : TSolver := TSolver.Create(c);
    //
    //// enabling unsat core tracking
    //var p : TParams := TParams.Create(c);
    c := TContext.Create;

    x := c.int_const('x');
    y := c.int_const('y');

    s := TSolver.Create(c);

    // enabling unsat core tracking
    p  := TParams.Create(c);
    p.&set('unsat_core', true);
    s.&set(p);

    // The following assertion will not be tracked.
    s.add(OpMajor(x,0));

    // The following assertion will be tracked using Boolean variable p1.
    // The C++ wrapper will automatically create the Boolean variable.
    s.add(OpMajor(y,0), 'p1');

    // Asserting other tracked assertions.
    s.add( OpMinor(x,10), 'p2');
    s.add( OpMinor(y,0),  'p3');

    relog.Lines.Append(  check_resultToStr(s.check) );
    relog.Lines.Append(  s.unsat_core.ToStr );

end;

(**
   \brief Unsat core example 2
*)
procedure  TMain.unsat_core_example2;
var
  assumptions : TArray<TExpr>;
  qs          : TArray<TExpr>; // auxiliary vector used to store new answer literals.
  qi          : TExpr;
  i           : Integer;
  qname       : AnsiString;
  p           : PAnsiChar;

var c : TContext;// := TContext.Create;
// The answer literal mechanism, described in the previous example,
// tracks assertions. An assertion can be a complicated
// formula containing containing the conjunction of many subformulas.
var p1 : TExpr;// := c.bool_const('p1');
var x  : TExpr;// := c.int_const('x');
var y  : TExpr;// := c.int_const('y');

var s : TSolver;// := TSolver.Create(c);

var F : TExpr;//  := OpAnd(OpAnd(OpAnd(OpMajor(x,10),OpMajor(y,x)),OpMinor(y, 5)), OpMajor(y, 0));
var core : Texpr_vector;// := s.unsat_core;
var core2 : Texpr_vector;// := s.unsat_core;


begin
    relog.Lines.Append(sLineBreak+ 'unsat core example2');
    //var c : TContext := TContext.Create;
    //// The answer literal mechanism, described in the previous example,
    //// tracks assertions. An assertion can be a complicated
    //// formula containing containing the conjunction of many subformulas.
    //var p1 : TExpr := c.bool_const('p1');
    //var x  : TExpr := c.int_const('x');
    //var y  : TExpr := c.int_const('y');
    //
    //var s : TSolver := TSolver.Create(c);
    //
    //var F : TExpr  := OpAnd(OpAnd(OpAnd(OpMajor(x,10),OpMajor(y,x)),OpMinor(y, 5)), OpMajor(y, 0));
    c  := TContext.Create;
    // The answer literal mechanism, described in the previous example,
    // tracks assertions. An assertion can be a complicated
    // formula containing containing the conjunction of many subformulas.
    p1 := c.bool_const('p1');
    x  := c.int_const('x');
    y  := c.int_const('y');

    s := TSolver.Create(c);

    F   := OpAnd(OpAnd(OpAnd(OpMajor(x,10),OpMajor(y,x)),OpMinor(y, 5)), OpMajor(y, 0));
    s.add(implies(p1, F));

    //assumptions := [ p1 ];

    assumptions.create;
    TAppender<TExpr>.Append(assumptions, p1);


    relog.Lines.Append(  check_resultToStr(s.check( 1, assumptions)) );

    //var core : Texpr_vector := s.unsat_core;
    core  := s.unsat_core;
    relog.Lines.Append(core.ToStr);
    relog.Lines.Append('size: ' + IntToStr(core.size) );

    for i := 0 to core.size - 1 do
        relog.Lines.Append(core.Items[i].ToStr);

    // The core is not very informative, since p1 is tracking the formula F
    // that is a conjunction of subformulas.
    // Now, we use the following piece of code to break this conjunction
    // into individual subformulas. First, we flat the conjunctions by
    // using the method simplify.
    assert(F.is_app ); // I'm assuming F is an application.
    if (F.decl.decl_kind = Z3_OP_AND) then
    begin
        // F is a conjunction
        relog.Lines.Append('F num. args (before simplify): ' + IntToStr(F.num_args) );
        F := F.simplify;
        relog.Lines.Append('F num. args (after simplify): ' + IntToStr(F.num_args) );
        for i := 0 to F.num_args -1 do
        begin
            relog.Lines.Append( format('Creating answer literal q%d for %s',[i,F.arg(i).toStr]));
            //

            //qname := 'q'+ ansistring(UIntToStr(i));
            // TODO Should be UIntToStr in stead of IntToStr...
            qname := 'q'+ ansistring(IntToStr(i));
            GetMem(p,Length(qname));
            CopyMemory(p,@qname[1],Length(qname));

            qi := c.bool_const( p ); // create a new answer literal
            s.add(implies(qi, F.arg(i)));
            //doh
            //qs := qs + [qi] ;

            TAppender<TExpr>.Append(qs, qi);

        end;
    end;

    // The solver s already contains p1 => F
    // To disable F, we add (not p1) as an additional assumption

    //doh
    //qs := qs + [ OpNot(p1) ];
    TAppender<TExpr>.Append(qs, OpNot(p1));

    relog.Lines.Append(  check_resultToStr(s.check( Length(qs), qs)) );

    //var core2 : Texpr_vector := s.unsat_core;
    core2 := s.unsat_core;
    relog.Lines.Append(core2.ToStr);
    relog.Lines.Append('size: ' + IntToStr(core2.size) );

    for i := 0 to core2.size - 1 do
        relog.Lines.Append(core2.Items[i].ToStr);

end;

(**
   \brief Unsat core example
*)
procedure TMain.unsat_core_example1;
var
  i : Integer;
var c : TContext;// := TContext.Create;
// We use answer literals to track assertions.
// An answer literal is essentially a fresh Boolean marker
// that is used to track an assertion.
// For example, if we want to track assertion F, we
// create a fresh Boolean variable p and assert (p => F)
// Then we provide p as an argument for the check method.
var p1 : TExpr;// := c.bool_const('p1');
var p2 : TExpr;// := c.bool_const('p2');
var p3 : TExpr;// := c.bool_const('p3');
var x  : TExpr;// := c.int_const('x');
var y  : TExpr;// := c.int_const('y');

var s : TSolver;// := TSolver.Create(c);
var assumptions : TArray<TExpr>;// := [ p1, p2, p3 ];
var core : TExpr_vector;// := s.unsat_core;
var assumptions2 : TArray<TExpr>;// := [ p1, p3 ];


begin
    relog.Lines.Append(sLineBreak+ 'unsat core example1');
    //var c : TContext := TContext.Create;
    //// We use answer literals to track assertions.
    //// An answer literal is essentially a fresh Boolean marker
    //// that is used to track an assertion.
    //// For example, if we want to track assertion F, we
    //// create a fresh Boolean variable p and assert (p => F)
    //// Then we provide p as an argument for the check method.
    //var p1 : TExpr := c.bool_const('p1');
    //var p2 : TExpr := c.bool_const('p2');
    //var p3 : TExpr := c.bool_const('p3');
    //var x  : TExpr := c.int_const('x');
    //var y  : TExpr := c.int_const('y');
    //
    //var s : TSolver := TSolver.Create(c);
    c  := TContext.Create;
    p1 := c.bool_const('p1');
    p2 := c.bool_const('p2');
    p3 := c.bool_const('p3');
    x  := c.int_const('x');
    y  := c.int_const('y');

    s  := TSolver.Create(c);

    s.add(implies( p1,  OpMajor(x,10)) );
    s.add(implies( p1,  OpMajor(y,x )) );
    s.add(implies( p2,  OpMinor(y,5 )) ) ;
    s.add(implies( p3,  OpMajor(y,0 )) );

    //var assumptions : TArray<TExpr> := [ p1, p2, p3 ];
    //doh

    //assumptions  := [ p1, p2, p3 ];

    assumptions.create;
    TAppender<TExpr>.Append(assumptions, p1);
    TAppender<TExpr>.Append(assumptions, p2);
    TAppender<TExpr>.Append(assumptions, p3);

    relog.Lines.Append( check_resultToStr(s.check(3, assumptions)));

    //var core : TExpr_vector := s.unsat_core;
    core  := s.unsat_core;

    relog.Lines.Append( core.ToStr );
    relog.Lines.Append( 'size: ' + IntToStr(core.size));

    for i := 0 to core.size - 1 do
        relog.Lines.Append( core.Items[i].ToStr);

    // Trying again without p2
    //var assumptions2 : TArray<TExpr> := [ p1, p3 ];

    //doh
    //assumptions2 := [ p1, p3 ];

    assumptions.create;
    TAppender<TExpr>.Append(assumptions, p1);
    TAppender<TExpr>.Append(assumptions, p3);


    relog.Lines.Append( check_resultToStr(s.check(2, assumptions2)));

end;

(**
   \brief Small example using quantifiers.
*)
procedure TMain.quantifier_example;
    var c : TContext;// := TContext.Create;

    var x : TExpr;// := c.int_const('x');
    var y : TExpr;// := c.int_const('y');
    var I : TSort;// := c.int_sort;
    var f : TFunc_decl;// := &function('f', I, I, I);

    var s : TSolver;// := TSolver.Create(c);

    // making sure model based quantifier instantiation is enabled.
    var p : TParams;// := TParams.Create(c);
    var rr : TExpr;// := OpMajOrEq(f.FunOf(x, y),0);
    var a : TExpr;// := c.int_const('a');


begin
    relog.Lines.Append(sLineBreak+ 'quantifier example');
    //var c : TContext := TContext.Create;
    //
    //var x : TExpr := c.int_const('x');
    //var y : TExpr := c.int_const('y');
    //var I : TSort := c.int_sort;
    //var f : TFunc_decl := &function('f', I, I, I);
    //
    //var s : TSolver := TSolver.Create(c);
    //
    //// making sure model based quantifier instantiation is enabled.
    //var p : TParams := TParams.Create(c);
    c := TContext.Create;

    x := c.int_const('x');
    y := c.int_const('y');
    I := c.int_sort;
    f := &function('f', I, I, I);

    s := TSolver.Create(c);

    // making sure model based quantifier instantiation is enabled.
    p := TParams.Create(c);
    p.&set('MBQI', true);
    s.&set(p);

    //var rr : TExpr := OpMajOrEq(f.FunOf(x, y),0);
    rr := OpMajOrEq(f.FunOf(x, y),0);
    rr := forall(x, y, rr );
    s.add( rr);
    //var a : TExpr := c.int_const('a');
    a := c.int_const('a');
    s.add( OpMinor(f.FunOf(a, a), a) );
    relog.Lines.Append(s.ToStr);
    relog.Lines.Append(check_resultToStr(s.check));
    relog.Lines.Append( s.get_model.ToStr);

    s.add( OpMinor(a, 0));
    relog.Lines.Append(check_resultToStr(s.check));
end;

procedure TMain.ite_example2_;
    var c : TContext;// := TContext.Create;

    var b : TExpr;// := c.bool_const('b');
    var x : TExpr;// := c.int_const('x');
    var y : TExpr;// := c.int_const('y');
    var it: TExpr;// := OpMajor(ite(b,x,y),0) ;

begin
    relog.Lines.Append(sLineBreak+ 'if-then-else example2');
    //var c : TContext := TContext.Create;
    //
    //var b : TExpr := c.bool_const('b');
    //var x : TExpr := c.int_const('x');
    //var y : TExpr := c.int_const('y');
    //var it: TExpr := OpMajor(ite(b,x,y),0) ;
    c  := TContext.Create;

    b  := c.bool_const('b');
    x  := c.int_const('x');
    y  := c.int_const('y');
    it := OpMajor(ite(b,x,y),0) ;

    relog.Lines.Append(it.ToStr);
end;

(**
   \brief Test ite-term (if-then-else terms).
*)
procedure TMain.ite_example_;
    var c : TContext;// := TContext.Create;

    var f   : TExpr;// := c.bool_val(false);
    var one : TExpr;// := c.int_val(1);
    var zero: TExpr;// := c.int_val(0);
    var ite : TExpr;// := to_expr(c, Z3_mk_ite(c.ToZ3_Context, f.ToZ3_ast, one.ToZ3_ast, zero.ToZ3_ast));

begin
    relog.Lines.Append(sLineBreak+ 'if-then-else example');
    //var c : TContext := TContext.Create;
    //
    //var f   : TExpr := c.bool_val(false);
    //var one : TExpr := c.int_val(1);
    //var zero: TExpr := c.int_val(0);
    //var ite : TExpr := to_expr(c, Z3_mk_ite(c.ToZ3_Context, f.ToZ3_ast, one.ToZ3_ast, zero.ToZ3_ast));
    c    := TContext.Create;

    f    := c.bool_val(false);
    one  := c.int_val(1);
    zero := c.int_val(0);
    ite  := to_expr(c, Z3_mk_ite(c.ToZ3_Context, f.ToZ3_ast, one.ToZ3_ast, zero.ToZ3_ast));

    relog.Lines.Append('term: '+ ite.ToStr);
end;

(**
    \brief Demonstrate different ways of creating rational numbers: decimal and fractional representations.
*)
procedure TMain.numeral_example_;
    var c : TContext;// := TContext.Create;

     var n1 : TExpr;// := c.real_val('1/2');
     var n2 : TExpr;// := c.real_val('0.5');
     var n3 : TExpr;// := c.real_val(1, 2);

begin
    relog.Lines.Append(sLineBreak+ 'numeral example');
    //var c : TContext := TContext.Create;
    //
    //var n1 : TExpr := c.real_val('1/2');
    //var n2 : TExpr := c.real_val('0.5');
    //var n3 : TExpr := c.real_val(1, 2);
    c  := TContext.Create;
    n1  := c.real_val('1/2');
    n2  := c.real_val('0.5');
    n3  := c.real_val(1, 2);
    relog.Lines.Append(n1.ToStr + ''+ n2.ToStr + ''+ n3.ToStr);

    prove_( OpAnd( OpEq(n1,n2), OpEq(n1,n3) ) );

    n1 := c.real_val('-1/3');
    n2 := c.real_val('-0.3333333333333333333333333333333333');
    relog.Lines.Append(n1.ToStr + ''+ n2.ToStr ) ;
    prove_(OpNotEq(n1,n2));
end;

(**
   \brief Demonstrates how to catch API usage errors.
*)
procedure TMain.error_example_;
var c : TContext;// := TContext.Create;
var x : TExpr;// := c.bool_const('x');
var n : TExpr;// := OpAdd(x,1);
var arg : TExpr;// := to_expr(c, Z3_get_app_arg(c.ToZ3_Context, x.ToZ3_app, 0));


begin
    relog.Lines.Append(sLineBreak+ 'error example');

    //var c : TContext := TContext.Create;
    //
    //var x : TExpr := c.bool_const('x');
    c := TContext.Create;
    x := c.bool_const('x');

    // Error using the C API can be detected using Z3_get_error_code.
    // The next call fails because x is a constant.
    //Z3_ast arg = Z3_get_app_arg(c, x, 0);
    if Z3_get_error_code(c.ToZ3_Context) <> Z3_OK then
    begin
       relog.Lines.Append('last call failed.');
    end ;

    // The C++ layer converts API usage errors into exceptions.
    try
       // The next call fails because x is a Boolean.
    //var n : TExpr := OpAdd(x,1);
      n := OpAdd(x,1);
    except
       on Ex : TZ3Exception do
       begin
          relog.Lines.Append('failed: ' + ex.message );
       end;
    end;

    // The functions to_expr, to_sort and to_func_decl also convert C API errors into exceptions.
    try
       //var arg : TExpr := to_expr(c, Z3_get_app_arg(c.ToZ3_Context, x.ToZ3_app, 0));
       arg := to_expr(c, Z3_get_app_arg(c.ToZ3_Context, x.ToZ3_app, 0));
    except
       on Ex : TZ3Exception do
       begin
          relog.Lines.Append('failed: ' + ex.message );
       end;
    end;
end;

(**
   \brief Several contexts can be used simultaneously.
*)
procedure TMain.two_contexts_example1_;
var c1 : TContext;// := TContext.Create;
var c2 : TContext;// := TContext.Create;
var x : TExpr;// := c1.int_const('x');
var n : TExpr;// := OpAdd(x, 1);
var n1 : TExpr;// := to_expr(c2, Z3_translate(c1.ToZ3_Context, n.ToZ3_ast, c2.ToZ3_Context));
begin
    relog.Lines.Append(sLineBreak+ 'two contexts example 1');
    LOG_MSG('two contexts example 1');

    //var c1 : TContext := TContext.Create;
    //var c2 : TContext := TContext.Create;
    //
    //var x : TExpr := c1.int_const('x');
    //var n : TExpr := OpAdd(x, 1);
    //// We cannot mix expressions from different contexts, but we can copy
    //// an expression from one context to another.
    //// The following statement copies the expression n from c1 to c2.
    //var n1 : TExpr := to_expr(c2, Z3_translate(c1.ToZ3_Context, n.ToZ3_ast, c2.ToZ3_Context));
    c1:= TContext.Create;
    c2:= TContext.Create;
    x := c1.int_const('x');
    n := OpAdd(x, 1);
    // We cannot mix expressions from different contexts, but we can copy
    // an expression from one context to another.
    // The following statement copies the expression n from c1 to c2.
    n1:= to_expr(c2, Z3_translate(c1.ToZ3_Context, n.ToZ3_ast, c2.ToZ3_Context));
    relog.Lines.Append( n1.ToStr);
end;

(**
   \brief Demonstrate how to evaluate expressions in a model.
*)
procedure TMain.eval_example1_;
var c : TContext;// := TContext.Create;
var x : TExpr;// := c.int_const('x');
var y : TExpr;// := c.int_const('y');
var s : TSolver;// := TSolver.Create(c);
var m : TModel;// := s.get_model;
begin
    relog.Lines.Append(sLineBreak+ 'eval example 1');
    LOG_MSG('eval example 1');

    //var c : TContext := TContext.Create;
    //
    //var x : TExpr := c.int_const('x');
    //var y : TExpr := c.int_const('y');
    //
    //var s : TSolver := TSolver.Create(c);
    c := TContext.Create;
    x := c.int_const('x');
    y := c.int_const('y');
    s := TSolver.Create(c);

    (* assert x < y *)
    s.add( OpMinor(x, y));
    (* assert x > 2 *)
    s.add( OpMajor(x, 2));

    relog.Lines.Append( check_resultToStr(s.check));

    //var m : TModel := s.get_model;
    m := s.get_model;
    relog.Lines.Append('Model:'+sLineBreak + m.ToStr);
    relog.Lines.Append('x+y = ' + m.eval( OpAdd(x,y) ).ToStr);
end;

(**
   \brief Mixing C and C++ APIs.
*)
procedure TMain.capi_example;
var c : TContext;// := TContext.Create;
var x : TExpr;// := c.bv_const('x',32);
var y : TExpr;// := c.bv_const('y',32);
var  r : TExpr;// := to_expr(c, Z3_mk_bvsrem(c.ToZ3_Context, x.ToZ3_ast, y.ToZ3_ast));

begin
    relog.Lines.Append(sLineBreak+ 'capi example');
    LOG_MSG('capi example');

    //var c : TContext := TContext.Create;
    //
    //var x : TExpr := c.bv_const('x',32);
    //var y : TExpr := c.bv_const('y',32);
    //// Invoking a C API function, and wrapping the result using an expr object.
    //var  r : TExpr := to_expr(c, Z3_mk_bvsrem(c.ToZ3_Context, x.ToZ3_ast, y.ToZ3_ast));
    c := TContext.Create;
    x := c.bv_const('x',32);
    y := c.bv_const('y',32);
    // Invoking a C API function, and wrapping the result using an expr object.
    r := to_expr(c, Z3_mk_bvsrem(c.ToZ3_Context, x.ToZ3_ast, y.ToZ3_ast));
    relog.Lines.Append('r: ' + r.ToStr);
end;

(**
   \brief Find x and y such that: x ^ y - 103 == x * y
*)
procedure  TMain.bitvector_example2_;
var c : TContext;// := TContext.Create;
var x : TExpr;// := c.bv_const('x',32);
var y : TExpr;// := c.bv_const('y',32);
var s : TSolver;// := TSolver.Create(c);

begin
    relog.Lines.Append(sLineBreak+ 'bitvector example 2');
    LOG_MSG('bitvector example 2');

    //var c : TContext := TContext.Create;
    //
    //var x : TExpr := c.bv_const('x',32);
    //var y : TExpr := c.bv_const('y',32);
    //
    //var s : TSolver := TSolver.Create(c);
    c := TContext.Create;
    x := c.bv_const('x',32);
    y := c.bv_const('y',32);
    s := TSolver.Create(c);

    // In C++, the operator == has higher precedence than ^.
    s.add(OpEq(OpMinus(OpXorbv(x, y),103), OpMul(x,y)) );
    relog.Lines.Append(s.ToStr);
    relog.Lines.Append(check_resultToStr(s.check));
    relog.Lines.Append( s.get_model.ToStr);
end;

(**
   \brief Simple bit-vector example. This example disproves that x - 10 <= 0 IFF x <= 10 for (32-bit) machine integers
*)
procedure  TMain.bitvector_example1_;
var c : TContext;// := TContext.Create;
var x : TExpr;// := c.bv_const('x',32);
var y : TExpr;// := c.bv_const('y',32);
begin
    relog.Lines.Append(sLineBreak+ 'bitvector example 1');
    LOG_MSG('bitvector example 1');

    //var c : TContext := TContext.Create;
    //
    //var x : TExpr := c.bv_const('x',32);
    c := TContext.Create;
    x := c.bv_const('x',32);

    // using signed <=
    prove_(OpEq(OpMinOrEq(OpMinus(x, 10),0), OpMinOrEq(x,10)));

    // using unsigned <=
    prove_(OpEq( ule(OpAdd(x, 10), 0), ule(x, 10)));

    //var y : TExpr := c.bv_const('y',32);
    y := c.bv_const('y',32);
    prove_(implies(OpEq(concat(x, y),concat(y, x)), OpEq(x, y)));
end;

(**
   \brief Nonlinear arithmetic example 1
*)
procedure  TMain.nonlinear_example1_;
var cfg : TConfig;//:= TConfig.Create;
var c : TContext;// := TContext.Create(cfg);
var x : TExpr;// := c.real_const('x');
var y : TExpr;// := c.real_const('y');
var z : TExpr;// := c.real_const('z');
var s : TSolver;// := TSolver.Create(c);
var m : TModel;// := s.get_model;
begin
    relog.Lines.Append(sLineBreak+ 'nonlinear example 1');
    LOG_MSG('nonlinear example 1');

    //var cfg : TConfig := TConfig.Create;
    cfg := TConfig.Create;
    cfg.&set('auto_config', true);

    //var c : TContext := TContext.Create(cfg);
    //
    //var x : TExpr := c.real_const('x');
    //var y : TExpr := c.real_const('y');
    //var z : TExpr := c.real_const('z');
    //
    //var s : TSolver := TSolver.Create(c);
    c := TContext.Create(cfg);
    x := c.real_const('x');
    y := c.real_const('y');
    z := c.real_const('z');
    s := TSolver.Create(c);

    s.add( OpEq(OpAdd(OpMul(x,x),OpMul(y,y) ),1 ));      // x^2 + y^2 == 1
    s.add( OpMinor( OpAdd(OpMul(OpMul(x,x),x),OpMul(OpMul(z,z),z)), c.real_val('1/2')) );          // x^3 + z^3 < 1/2
    s.add(OpNotEq(z, 0));
    relog.Lines.Append(check_resultToStr(s.check));

    //var m : TModel := s.get_model;
    m := s.get_model;
    relog.Lines.Append(m.ToStr);
    set_param('pp.decimal', true); // set decimal notation
    relog.Lines.Append('model in decimal notation');
    relog.Lines.Append(m.ToStr);
    set_param('pp.decimal-precision', 50); // increase number of decimal places to 50.
    relog.Lines.Append('model using 50 decimal places');
    relog.Lines.Append(m.ToStr);
    set_param('pp.decimal', false); // disable decimal notation
end;

(**
   \brief Prove <tt>not(g(g(x) - g(y)) = g(z)), x + z <= y <= x implies z < 0 </tt>.
   Then, show that <tt>z < -1</tt> is not implied.

   This example demonstrates how to combine uninterpreted functions and arithmetic.
*)
procedure TMain.prove_example2_ ;
var c : TContext;// := TContext.Create;
var x : TExpr;// := c.int_const('x');
var y : TExpr;// := c.int_const('y');
var z : TExpr;// := c.int_const('z');
var I : TSort;// := c.int_sort;
var g : TFunc_decl;// := &function('g', I, I);
var e1 : TExpr;// := OpNotEq (g.FunOf( OpMinus(g.FunOf(x),g.FunOf(y))),g.FunOf(z));
var e2 : TExpr;// := OpAdd(x,z);
var conjecture1 : TExpr;// := implies ( e1, OpMinor(z,0) ) ;
var s : TSolver;// := TSolver.Create(c);
var conjecture2 : TExpr;// := implies ( e1, OpMinor(z,-1) ) ;
begin
    relog.Lines.Append(sLineBreak+ 'prove_example2');
    LOG_MSG('prove_example2');

    //var c : TContext := TContext.Create;
    //
    //var x : TExpr := c.int_const('x');
    //var y : TExpr := c.int_const('y');
    //var z : TExpr := c.int_const('z');
    //
    //var I : TSort := c.int_sort;
    //var g : TFunc_decl := &function('g', I, I);
    //
    //var e1 : TExpr := OpNotEq (g.FunOf( OpMinus(g.FunOf(x),g.FunOf(y))),g.FunOf(z));
    //var e2 : TExpr := OpAdd(x,z);
    c := TContext.Create;
    x := c.int_const('x');
    y := c.int_const('y');
    z := c.int_const('z');
    I := c.int_sort;
    g := &function('g', I, I);
    e1 := OpNotEq (g.FunOf( OpMinus(g.FunOf(x),g.FunOf(y))),g.FunOf(z));
    e2 := OpAdd(x,z);
    e2 := OpMinOrEq(e2,y);
    e2 := OpAnd(e2,OpMinOrEq(y,x));
    e1 := Opand(e1,e2);
    // expr conjecture1 = implies(g(g(x) - g(y)) != g(z) && x + z <= y && y <= x, z < 0);
    //var conjecture1 : TExpr := implies ( e1, OpMinor(z,0) ) ;
    //
    //var s : TSolver := TSolver.Create(c);
    conjecture1 := implies ( e1, OpMinor(z,0) ) ;

    s := TSolver.Create(c);
    s.add( OpNot(conjecture1));

    relog.Lines.Append('conjecture 1' +sLineBreak + conjecture1.ToStr);

    if (s.check = unsat) then  relog.Lines.Append('proved')
    else                       relog.Lines.Append('failed to prove');

    e1 := OpNotEq (g.FunOf( OpMinus(g.FunOf(x),g.FunOf(y))),g.FunOf(z));
    e2 := OpAdd(x,z);
    e2 := OpMinOrEq(e2,y);
    e2 := OpAnd(e2,OpMinOrEq(y,x));
    e1 := OpAnd(e1,e2);
    //expr conjecture2 = implies(g(g(x) - g(y)) != g(z) && x + z <= y && y <= x, z < -1);
    //var conjecture2 : TExpr := implies ( e1, OpMinor(z,-1) ) ;
    conjecture2 := implies ( e1, OpMinor(z,-1) ) ;

    s.reset();
    s.add(OpNot(conjecture2));
    relog.Lines.Append('conjecture 2' +sLineBreak + conjecture2.ToStr);

    if (s.check = unsat) then  relog.Lines.Append('proved')
    else begin
             relog.Lines.Append('failed to prove');
             relog.Lines.Append('counterexample:'+sLineBreak + s.get_model.ToStr);
    end;

end;

(**
   \brief Prove <tt>x = y implies g(x) = g(y)</tt>, and
   disprove <tt>x = y implies g(g(x)) = g(y)</tt>.

   This function demonstrates how to create uninterpreted types and
   functions.
*)
procedure TMain.prove_example1_;
var c : TContext;// := TContext.Create;
var x : TExpr;// := c.int_const('x');
var y : TExpr;// := c.int_const('y');
var I : TSort;// := c.int_sort;
var g : TFunc_decl;// := &function('g', I, I);
var s : TSolver;// := TSolver.Create(c);
var conjecture1 : TExpr;// := implies ( OpEq(x,y) , OpEq( g.FunOf(x), g.FunOf(y) ) );
var conjecture2 : TExpr;// := implies ( OpEq(x,y) , OpEq( g.FunOf(g.FunOf(x)), g.FunOf(y) ) );
var m : TModel;// := s.get_model;

begin
    relog.Lines.Append(sLineBreak+ 'prove_example1');
    LOG_MSG('prove_example1');

    //var c : TContext := TContext.Create;
    //
    //var x : TExpr := c.int_const('x');
    //var y : TExpr := c.int_const('y');
    //
    //var I : TSort := c.int_sort;
    //var g : TFunc_decl := &function('g', I, I);
    //
    //var s : TSolver := TSolver.Create(c);
    //
    //var conjecture1 : TExpr := implies ( OpEq(x,y) , OpEq( g.FunOf(x), g.FunOf(y) ) );
    c := TContext.Create;
    x := c.int_const('x');
    y := c.int_const('y');
    I := c.int_sort;
    g := &function('g', I, I);
    s := TSolver.Create(c);
    conjecture1 := implies ( OpEq(x,y) , OpEq( g.FunOf(x), g.FunOf(y) ) );
    relog.Lines.Append('conjecture 1' +sLineBreak + conjecture1.ToStr);
    s.add( OpNot(conjecture1) );

    if (s.check = unsat) then  relog.Lines.Append('proved')
    else                       relog.Lines.Append('failed to prove');


    s.reset; // remove all assertions from solver s

    //var conjecture2 : TExpr := implies ( OpEq(x,y) , OpEq( g.FunOf(g.FunOf(x)), g.FunOf(y) ) );
    conjecture2 := implies ( OpEq(x,y) , OpEq( g.FunOf(g.FunOf(x)), g.FunOf(y) ) );
    relog.Lines.Append('conjecture 2' +sLineBreak + conjecture2.ToStr);
    s.add( OpNot(conjecture2) );

    if (s.check = unsat) then  relog.Lines.Append('proved')
    else begin
        relog.Lines.Append('failed to prove');
        //var m : TModel := s.get_model;
        m := s.get_model;
        relog.Lines.Append('counterexample:'+sLineBreak + m.ToStr);
        relog.Lines.Append('g(g(x)) = ' + m.eval(g.FunOf(g.FunOf(x))).ToStr );
        relog.Lines.Append('g(y)    = ' + m.eval(g.FunOf(y)).ToStr );
    end;
end;

(**
   \brief Find a model for <tt>x >= 1 and y < x + 3</tt>.
*)
procedure  TMain.find_model_example1_;
var
 i: Integer;
var c : TContext;// := TContext.Create;

var x : TExpr;// := c.int_const('x');
var y : TExpr;// := c.int_const('y');

var s : TSolver;// := TSolver.Create(c);
var m : TModel;// := s.get_model;
var v : TFunc_decl;// := m.Item[i];

begin
    relog.Lines.Append(sLineBreak+'find_model_example1');
    LOG_MSG('find_model_example1');

    //var c : TContext := TContext.Create;
    //
    //var x : TExpr := c.int_const('x');
    //var y : TExpr := c.int_const('y');
    //
    //var s : TSolver := TSolver.Create(c);
    c := TContext.Create;
    x := c.int_const('x');
    y := c.int_const('y');
    s := TSolver.Create(c);

    s.add( OpMajOrEq(x,1) );
    s.add( OpMinor(y, (OpAdd(x,3)) ) );

    relog.Lines.Append(check_resultToStr(s.check));

    //var m : TModel := s.get_model;
    m := s.get_model;
    relog.Lines.Append(string(m.ToStr));

    // traversing the model
    for i := 0 to m.size - 1 do
    begin
       //var v : TFunc_decl := m.Item[i];
       v := m.Item[i];
        // this problem contains only constants
        assert(v.arity = 0);
        relog.Lines.Append( v.name.ToStr+ ' = '+ (m.get_const_interp(v).ToStr ));

    end;
    // we can evaluate expressions in the model.
    relog.Lines.Append( 'x + y + 1 = ' +(m.eval( OpAdd( Opadd(x,y), 1))).ToStr );

end;

procedure TMain.demorgan_ ;
var str : AnsiString;
var c : TContext;// := TContext.Create;
var x : TExpr;// := c.bool_const('x');
var y : TExpr;// := c.bool_const('y');
var conjecture : TExpr;// := OpEq((OpNot( OpAnd(x,y) )),  (OpOr( OpNot(x), OpNot(y) )) );
var s : TSolver;// := TSolver.Create(c);

begin
    relog.Lines.Append('de-Morgan example');
    LOG_MSG('de-Morgan example');

    //var c : TContext := TContext.Create;
    //
    //var x : TExpr := c.bool_const('x');
    //var y : TExpr := c.bool_const('y');
    //
    //// (!(x && y) ) == ( !x || !y );
    //var conjecture : TExpr := OpEq((OpNot( OpAnd(x,y) )),  (OpOr( OpNot(x), OpNot(y) )) );
    //
    //
    //var s : TSolver := TSolver.Create(c);
    c := TContext.Create;
    x := c.bool_const('x');
    y := c.bool_const('y');

     // (!(x && y) ) == ( !x || !y );
    conjecture := OpEq((OpNot( OpAnd(x,y) )),  (OpOr( OpNot(x), OpNot(y) )) );


    s := TSolver.Create(c);
    // adding the negation of the conjecture as a constraint.
    s.add(OpNot( conjecture) );
    str := '';//s.to_smt2('unknown');

    relog.Lines.Append(s.ToStr);
    relog.Lines.Append(str);

    case s.check of
      unsat:   begin
          relog.Lines.Append('de-Morgan is valid');
          end;
      sat:     begin
          relog.Lines.Append('de-Morgan is not valid');
          end;
      unknown: begin
          relog.Lines.Append('unknown');
          end;

    end;
end;

procedure TMain.TestClass;
begin
   Z3_open_log('z3_Class.log');
   relog.Clear;

   demorgan_ ;
   find_model_example1_ ;

   prove_example1_;
   prove_example2_ ;
   nonlinear_example1_ ;
   bitvector_example1_ ;
   bitvector_example2_ ;
   capi_example;
   eval_example1_;
   two_contexts_example1_;
   error_example_;
   numeral_example_;
   ite_example_;
   ite_example2_;
   quantifier_example;
   unsat_core_example1;
   unsat_core_example2;
   unsat_core_example3;
   tactic_example1;
   tactic_example2;
   tactic_example3;
   tactic_example4;
   tactic_example5;
   tactic_example6;
   tactic_example7;

  {  tactic_example8;
    tactic_example9;
    tactic_qe;
    tst_visit;
    tst_numeral;
    incremental_example1;
    incremental_example2;
    incremental_example3;
    enum_sort_example;
    tuple_example;
    expr_vector_example;
    exists_expr_vector_example;
    substitute_example;
    opt_example;
    extract_example;
    param_descrs_example;
    sudoku_example;
    consequence_example;
    parse_example;
    mk_model_example;
    recfun_example;  }

   relog.Lines.Add('End Test z3_Class');
   Z3_close_log;
end;

procedure TMain.btnTestClassClick(Sender: TObject);
begin
   TestClass
end;

procedure TMain.TestApi;
begin
    Z3_open_log('z3_Api.log');
    relog.Clear;

    relog.Lines.Append(display_version);
    simple_example();
    demorgan();
    find_model_example1();
    find_model_example2();
    prove_example1();
    prove_example2();
    push_pop_example1();
    quantifier_example1();
    array_example1();
    array_example2();
    array_example3();
    tuple_example1();
    bitvector_example1();
    bitvector_example2();
    eval_example1();
    two_contexts_example1();
    error_code_example1();
    error_code_example2();
    parser_example2();
    parser_example3();
    parser_example5();
    numeral_example();
    ite_example();
    list_example();
    tree_example();
    forest_example();
    binary_tree_example();
    enum_example();
    unsat_core_and_proof_example();
    incremental_example1();
    reference_counter_example();
    smt2parser_example();
    substitute_example();
    substitute_vars_example();
    fpa_example();
    mk_model_example();

    relog.Lines.Add('End Test z3_Api');
    Z3_close_log;
end;

procedure TMain.btnTestApiClick(Sender: TObject);
begin
   TestApi;
end;

end.
