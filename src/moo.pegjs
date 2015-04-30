{
  function node(type, value, line, column) {
    //console.log(type, value);
    //return { type: type, val: value, l: line, c: column }
    return { type: type, val: value }
  }
}

start
  = Expressions+

Digit "Digit"
  = [0-9]

Digits "Digits"
  = digits:Digit+                                                                                      { return digits.join('') }

Alphabet "Alphabet"
  = [a-zA-Z]

Alphabets "Alphabets"
  = alphabets:Alphabet+                                                                                { return alphabets.join('') }

Symbol "Symbol"
  = [!@#$%\^&*()\-_=\+\[\]\{\}\|;:'.,<>/?\\]

Whitespace "Whitespace"
  = [ \t]

LineTerminator "LineTerminator"
  = [\n\r]

NullLiteral "NullLiteral"
  = "null"

TrueLiteral "TrueLiteral"
  = "true"

FalseLiteral "FalseLiteral"
  = "false"

BooleanLiteral "BooleanLiteral"
  = TrueLiteral
  / FalseLiteral

Keyword "Keyword"
  = "let"

WhitespaceOrLineTerminator "WhitespaceOrLineTerminator"
  = Whitespace
  / LineTerminator

Char "Char"
  = Alphabet / Digit / Symbol / Whitespace / LineTerminator

ArithmeticOperator "ArithmeticOperator"
  = "/"                                                                                                { return node('DivisionOperator', '/') }
  / "*"                                                                                                { return node('MultiplicationOperator', '*') }
  / "+"                                                                                                { return node('AdditionOperator', '+') }
  / "-"                                                                                                { return node('SubtractionOperator', '-') }

LogicalOperator "LogicalOperator"
  = "&&"                                                                                               { return node('AndOperator', '&&') }
  / "||"                                                                                               { return node('OrOperator', '||') }
  / "=="                                                                                               { return node('EqualityOperator', '==') }
  / "!="                                                                                               { return node('NotEqualOperator', '!=') }
  / "<="                                                                                               { return node('LTEOperator', '<=') }
  / ">="                                                                                               { return node('GTEOperator', '>=') }
  / "<"                                                                                                { return node('LTOperator', '<') }
  / ">"                                                                                                { return node('GTOperator', '>') }

UnaryLogicalOperator "UnaryLogicalOperator"
  = "!"                                                                                                { return node('NegationOperator', '!') }

UnaryOperator "UnaryOperator"
  = "+"
  / "-"

BinaryOperator "BinaryOperator"
  = ArithmeticOperator
  / LogicalOperator

Operator "Operator"
  = BinaryOperator
  / UnaryOperator

ReservedWord "ReservedWord"
  = Keyword
  / NullLiteral
  / BooleanLiteral

Integer "Integer"
  = integer:(UnaryOperator?Digits)                                                                     { return parseInt(integer.join(''), 10) }

Float "Float"
  = float:(UnaryOperator?Digits"."Digits)                                                              { return parseFloat(float.join(''), 10) }

String "String"
  = "\"" string:Char* "\""                                                                             { return node("String", string.join('')) }

Boolean "Boolean"
  = TrueLiteral                                                                                        { return node("Boolean", true) }
  / FalseLiteral                                                                                       { return node("Boolean", false) }

Number "Number"
  = float:Float                                                                                        { return node("Number", float) }
  / int:Integer                                                                                        { return node("Number", int) }

Identifier "Identifier"
  = !ReservedWord first:("_" / Alphabet)rest:("_" / Alphabet / Digit)*                                 { return node("Identifier", first+rest.join('')) }

Identifiers "Identifiers"
  = id:Identifier Whitespace+                                                                          { return id }

Atom "Atom"
  = Number
  / Boolean
  / String
  / Identifier

Block "Block"
  = "{" WhitespaceOrLineTerminator* exprs:Expressions* WhitespaceOrLineTerminator* "}"                 { return node("Block", exprs) }

AtomAssignment "AtomAssignment"
  = Whitespace* "let" Whitespace+ id:Identifier Whitespace+ "=" Whitespace* atom:Atom                  { return node("AtomAssignment", [id, atom]) }

BlockAssignment "BlockAssignment"
  = Whitespace* "let" Whitespace+ ids:Identifiers* Whitespace* "=" Whitespace* block:Block             { return node("BlockAssignment", [ids, block]) }

LambdaAssignment "LambdaAssignment"
  = Whitespace* "let" Whitespace+ ids:Identifiers* Whitespace* "=" Whitespace* lambda:LambdaExpression { return node("LambdaAssignment", [ids, lambda]) }

AssignmentExpression "AssignmentExpression"
  = atomAssignment:AtomAssignment                                                                      { return node("AssignmentExpression", atomAssignment) }
  / blockAssignment:BlockAssignment                                                                    { return node("AssignmentExpression", blockAssignment) }
  / lambdaAssignment:LambdaAssignment                                                                  { return node("AssignmentExpression", lambdaAssignment) }

InvocationExpression "InvocationExpression"
  = Whitespace* functionId:Identifier args:Arguments*                                                  { return node("InvocationExpression", [functionId, node("Arguments", args)]); }
  / Whitespace* lambda:LambdaExpression args:Arguments*                                                { return node("InvocationExpression", [lambda, node("Arguments", args)]) }

Argument "Argument"
  = Atom
  / LambdaExpression
  / Expression
  / Block

Arguments
  = Whitespace+ arg:Argument                                                                           { return arg }

LambdaExpression "LambdaExpression"
  = "(" Whitespace* block:Block Whitespace* ")"                                                        { return node("LambdaExpression", [block]) }
  / "(" Whitespace* ids:Identifiers* Whitespace* block:Block Whitespace* ")"                           { return node("LambdaExpression", [ids, block]) }

OperatorExpression "OperatorExpression"
  = Whitespace* arg1:OpArgument Whitespace* rest:FromOpExpression+                                     { return node("OperatorExpression", [arg1].concat(rest[0])) }
  / Whitespace* unaryOp:UnaryLogicalOperator expr:OpArgument Whitespace* rest:FromOpExpression*        { return node("OperatorExpression", [unaryOp, expr].concat(rest)) }

OpArgument "OpArgument"
  = InvocationExpression
  / Atom
  / "(" Whitespace* expr:Expression Whitespace* ")"                                                    { return expr }

FromOpExpression "FromOpExpression"
  = Whitespace* binaryOp:BinaryOperator Whitespace* expr:Expression Whitespace*                        { return [binaryOp, expr] }

Expression "Expression"
  = AssignmentExpression
  / opExpr:OperatorExpression                                                                          { return opExpr }
  / invExpr:InvocationExpression                                                                       { return invExpr }
  / lambdaExpr:LambdaExpression                                                                        { return lambdaExpr }
  / atom:Atom                                                                                          { return atom }
  / "(" Whitespace* expr:Expression Whitespace* ")"                                                    { return expr }

ExpressionTerminator "ExpressionTerminator"
  = [;\n]

Expressions
  = expr:Expression? Whitespace* ExpressionTerminator Whitespace*                                      { return expr }

// start = Expressions+
