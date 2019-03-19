module DimensionChecker

  export @dimensionCheck

  function init_traverse(ex::Expr)
    (exp_stack,symbol_size) = traverse(ex);
    return (pop!(exp_stack),symbol_size)
  end
  
  function traverse(ex::Expr)
    exp_stack = [];
    symbol_size = Dict();
    traverse(ex,exp_stack,symbol_size)
  end
  
  function traverse(ex::Symbol,exp_stack,symbol_size)
    try symbol_size[string(ex)] = size(eval(ex))
        catch e  #not the nicest code  
    end
  end
  
  function traverse(ex::Expr,exp_stack,symbol_size) 
    if ex.head == :call  # function call 
        arg = ex.args[1];
        if (string(arg) != ":")
            test!(arg,exp_stack,symbol_size)
        end
        # Here all the operators are skipped because they are the first argument
        for arg in ex.args[2:end]
            if (string(arg) != ":")
                test!(arg,exp_stack,symbol_size)
            end
            traverse(arg,exp_stack,symbol_size);  # recursive
        end
      
        elseif ex.head == :ref # now where at the indexing level and stop here
        symbol_size[string(ex)] = size(eval(ex));
        a = size(eval(ex));
        
    else
        for arg in ex.args
            test!(arg,exp_stack,symbol_size)
            traverse(arg,exp_stack,symbol_size);  # recursive
        end
    end
  
    
    return (exp_stack,symbol_size)
  end
  
function traverse(ex,exp_stack,symbol_size)
  end
  
  function test!(ex::Expr,exp_stack,symbol_size)
    try 
        eval(ex);
    catch e
        push!(exp_stack,ex);
    end
  end
  
  function test!(ex,exp_stack,symbol_size)
    # If not an expression just ignore
  end
  
  function expr_to_size_string(ex::Expr,symbol_size::Dict)
    str = string(ex);
    size_str = str
    for (key, value) in symbol_size
        size_str = replace(size_str, string(key) => string(value))
    end
    return "Error in expression '" * str * "' with dimensions '" * size_str *"'"
  end
  
  macro dimensionCheck(expression)
    (exp_stack,symbol_size) = init_traverse(esc(expression))
    return expr_to_size_string(exp_stack,symbol_size)
  end
end