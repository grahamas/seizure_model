function kw_example(fn_expr)
  fn_dct = MacroTools.splitdef(fn_expr)
  # postwalk processes leaves first, so they can be used to set defaults in larger kwargs
  fn_dct[:body] = MacroTools.postwalk(fn_dct[:body]) do x
    if isa(x, Expr) && (x.head == :kw)
      push!(fn_dct[:kwargs], Expr(:kw, x.args[1], x.args[2]))
      Expr(:kw, x.args[1], x.args[1]) # INTENTIONALLY set default to same symbol
    else
      x
    end
  end
  MacroTools.combinedef(fn_dct)
end
