""" Rewriting for GAT expressions.

The current content of this module is just a stopgap until I can implement
a generic term rewriting system.
"""
module Rewrite
export associate, associate_unit, distribute_unary, anti_involute

using ..Syntax
import ..Syntax: head

""" Simplify associative binary operation.

Maintains the normal form `op(e1,e2,...)` where `e1`,`e2`,... are expressions
that are *not* applications of `op()`
"""
function associate{E<:GATExpr}(expr::E)::E
  op, e1, e2 = head(expr), first(expr), last(expr)
  args1 = head(e1) == op ? args(e1) : [e1]
  args2 = head(e2) == op ? args(e2) : [e2]
  E([args1; args2], type_args(expr))
end

""" Simplify associative binary operation with unit.

Reduces a freely generated (typed) monoid to normal form.
"""
function associate_unit(expr::GATExpr, unit::Function)::GATExpr
  e1, e2 = first(expr), last(expr)
  if (head(e1) == head(unit)) e2
  elseif (head(e2) == head(unit)) e1
  else associate(expr) end
end

""" Distribute unary operation over a binary operation.
"""
function distribute_unary(raw_expr::GATExpr, un_op::Function,
                          bin_op::Function)::GATExpr
  if head(raw_expr) != head(un_op)
    return raw_expr
  end
  expr = first(raw_expr)
  if head(expr) == head(bin_op)
    bin_op([un_op(A) for A in args(expr)]...)
  else
    raw_expr
  end
end

""" Simplify unary operation that is an anti-involution on a (typed) monoid.
""" 
function anti_involute(raw_expr::GATExpr, inv::Function, op::Function,
                       unit::Function)::GATExpr
  if head(raw_expr) != head(inv)
    return raw_expr
  end
  expr = first(raw_expr)
  if head(expr) == head(inv)
    first(expr)
  elseif head(expr) == head(op)
    op([inv(A) for A in reverse(args(expr))]...)
  elseif head(expr) == head(unit)
    expr
  else raw_expr end
end

# FIXME: This doesn't seem like a good idea.
head(f::Function)::Symbol = Symbol(string(typeof(f).name.name)[2:end])

end
