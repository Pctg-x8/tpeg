module com.cterm2.ml.syntaxTree;

import com.cterm2.ml.lexer;

abstract class NodeBase
{
    public abstract @property Location location();
}

abstract class DeclarationNode : NodeBase {}
abstract class StatementNode : NodeBase {}
abstract class ExpressionNode : StatementNode {}

final class NonvalueLiteralNode : ExpressionNode
{
    Location loc;
    public override @property Location location(){ return this.loc; }
    public this(Location l)
    {
        this.loc = l;
    }
}
final class SingleValueLiteralNode(ValueT) : ExpressionNode
{
    Location loc;
    ValueT val;

    public override @property Location location(){ return this.loc; }
    public @property value(){ return this.val; }

    public this(Location l, ValueT v)
    {
        this.loc = l;
        this.val = v;
    }
}

// Qualifiers //
enum Qualifiers : byte
{
    Public = 1 << 0,
    Private = 1 << 1,
    Protected = 1 << 2,
    Final = 1 << 3,
    Static = 1 << 4,
    Const = 1 << 5,
    Override = 1 << 6,

    AccessibleMask = Public | Private | Protected
}
struct Qualifier
{
    Location location;
    byte q_values;
    private auto isRaisedBit(Qualifiers q)(){ return (this.q_values & q) != 0; }

    public @property isPublic(){ return this.isRaisedBit!(Qualifiers.Public); }
    public @property isPrivate(){ return this.isRaisedBit!(Qualifiers.Private); }
    public @property isProtected(){ return this.isRaisedBit!(Qualifiers.Protected); }
    public @property isFinal(){ return this.isRaisedBit!(Qualifiers.Final); }
    public @property isStatic(){ return this.isRaisedBit!(Qualifiers.Static); }
    public @property isConst(){ return this.isRaisedBit!(Qualifiers.Const); }
    public @property isOverride(){ return this.isRaisedBit!(Qualifiers.Override); }
    public @property isAccessibleSpecified(){ return this.isRaisedBit!(Qualifiers.AccessibleMask); }
    public Qualifier combine(Qualifier q)
    {
        auto use_qloc = this.location.line > q.location.line && this.location.column > q.location.column;
        byte qval = q.q_values | this.q_values;
        if(q.isAccessibleSpecified() && this.isAccessibleSpecified())
        {
            // conflict(use new)
            qval &= ~Qualifiers.AccessibleMask;
            qval |= this.q_values & Qualifiers.AccessibleMask;
        }
        return Qualifier(use_qloc ? q.location : this.location, qval);
    }
    public this(Location l, byte v)
    {
        this.location = l;
        this.q_values = v;
    }
}

// Type Nodes //
abstract class TypeNode : NodeBase {}
final class TypeScopeResolverNode : TypeNode
{
    // A.B#C...
    TypeNode _parent, _child;

    invariant { assert(_parent !is null); }

    public override @property Location location(){ return this._parent.location; }
    public @property parent(){ return this._parent; }
    public @property child(){ return this._child; }
    public this(TypeNode typeParent, TypeNode typeChild)
    {
        this._parent = typeParent;
        this._child = typeChild;
    }
}
final class TemplateInstanceTypeNode : TypeNode
{
    Location loc;
    string template_name;
    TemplateParamNode[] _types;

    public override @property Location location(){ return this.loc; }
    public @property templateName(){ return this.template_name; }
    public @property types(){ return this._types; }
    public this(Location l, string tn, TemplateParamNode[] ts)
    {
        this.loc = l;
        this.template_name = tn;
        this._types = ts;
    }
}
final class RegisterTypeNode : TypeNode
{
    public enum Type
    {
        Void, Char, Uchar, Byte, Short, Ushort, Int, Uint, Long, Ulong
    }
    Location loc;
    Type _type;

    public override @property Location location(){ return this.loc; }
    public @property type(){ return this._type; }
    public this(Location l, Type t)
    {
        this.loc = l;
        this._type = t;
    }
}
final class TypeofNode : TypeNode
{
    Location loc;
    bool is_expr_inferencing;
    union
    {
        ExpressionNode _expr;
        TypeNode _type;
    }

    public override @property Location location(){ return this.loc; }
    public @property isExpressionInferencing(){ return this.is_expr_inferencing; }
    public @property expression(){ return this._expr; }
    public @property type(){ return this._type; }
    public this(Location l, ExpressionNode e)
    {
        this.loc = l;
        this._expr = e;
        this.is_expr_inferencing = true;
    }
    public this(Location l, TypeNode t)
    {
        this.loc = l;
        this._type = t;
        this.is_expr_inferencing = false;
    }
}
final class ArrayTypeNode : TypeNode
{
    TypeNode base_type;
    ExpressionNode dim;

    public override @property Location location(){ return this.base_type.location; }
    public @property baseType(){ return this.base_type; }
    public @property dimension(){ return this.dim; }
    public this(TypeNode bt, ExpressionNode d)
    {
        this.base_type = bt;
        this.dim = d;
    }
}
final class InferenceTypeNode : TypeNode
{
    Location loc;

    public override @property Location location(){ return this.loc; }
    public this(Location l)
    {
        this.loc = l;
    }
}
final class FunctionTypeNode : TypeNode
{
    TypeNode base_type;
    VirtualParamNode[] vparam;

    public override @property Location location(){ return this.base_type.location; }
    public @property baseType(){ return this.base_type; }
    public @property virtualParams(){ return this.vparam; }
    public this(TypeNode bt, VirtualParamNode[] vps)
    {
        this.base_type = bt;
        this.vparam = vps;
    }
}
final class QualifiedTypeNode : TypeNode
{
    Qualifier qual;
    TypeNode base_type;

    public override @property Location location(){ return this.qual.location; }
    public @property qualifier(){ return this.qual; }
    public @property baseType(){ return this.base_type; }
    public this(Qualifier q, TypeNode bt)
    {
        this.qual = q;
        this.base_type = bt;
    }
}

// Element Nodes //
final class VirtualParamNode : NodeBase
{
    // virtual param
    TypeNode _type;
    string _name;
    ExpressionNode default_value;
    bool is_variadic;

    public override @property Location location(){ return this._type.location; }
    public @property type(){ return this._type; }
    public @property name(){ return this._name; }
    public @property defaultValue(){ return this.default_value; }
    public @property isVariadic(){ return this.is_variadic; }
    public this(TypeNode t, string n, ExpressionNode dv, bool iv)
    {
        this._type = t;
        this._name = n;
        this.default_value = dv;
        this.is_variadic = iv;
    }
}
final class TemplateVirtualParamNode : NodeBase
{
    public final enum ParamType
    {
        Any, Class, SymbolAlias, Type
    }

    Location loc;
    ParamType param_type;
    TypeNode spec_type;
    string _name;
    TypeNode default_value;

    public override @property Location location(){ return this.loc; }
    public @property paramType(){ return this.param_type; }
    public @property specType(){ return this.spec_type; }
    public @property name(){ return this._name; }
    public @property defaultValue(){ return this.default_value; }
    public this(Location l, ParamType pt, string n)
    {
        this.loc = l;
        this.param_type = pt;
        this.spec_type = null;
        this._name = n;
    }
    public this(Location l, ParamType pt, TypeNode t, string n)
    {
        this.loc = l;
        this.param_type = pt;
        this.spec_type = t;
        this._name = n;
    }
    public this(typeof(this) base, TypeNode dv)
    {
        this.loc = base.location;
        this.param_type = base.paramType;
        this.spec_type = base.specType;
        this._name = base.name;
        this.default_value = dv;
    }
}
final class TemplateParamNode : NodeBase
{
    Location loc;
    TypeNode type_name;
    string id;
    ExpressionNode _expression;

    public override @property Location location(){ return this.loc; }
    public @property typeName(){ return this.type_name; }
    public @property symbolName(){ return this.id; }
    public @property expression(){ return this._expression; }

    public this(Location l, TypeNode t)
    {
        this.loc = l;
        this.type_name = t;
    }
    public this(Location l, string i)
    {
        this.loc = l;
        this.id = i;
    }
    public this(Location l, ExpressionNode e)
    {
        this.loc = l;
        this._expression = e;
    }
}
final class DefinitionIdentifierParamNode : NodeBase
{
    Location loc;
    string _name;
    TypeNode default_value, extended_from, castable_to;

    public override @property Location location(){ return this.loc; }
    public @property name(){ return this._name; }
    public @property defaultValue(){ return this.default_value; }
    public @property extendedFrom(){ return this.extended_from; }
    public @property castableTo(){ return this.castable_to; }

    public this(Location l, string n)
    {
        // initial
        this.loc = l;
        this._name = n;
    }
    public auto clone()
    {
        auto dp = new DefinitionIdentifierParamNode(this.location, this.name);
        dp.default_value = this.defaultValue;
        dp.extended_from = this.extendedFrom;
        dp.castable_to = this.castableTo;
        return dp;
    }
    public auto withDefaultValue(TypeNode t)
    {
        auto obj = this.clone();
        obj.default_value = t;
        return obj;
    }
    public auto withExtendedFrom(TypeNode t)
    {
        auto obj = this.clone();
        obj.extended_from = t;
        return obj;
    }
    public auto withCastableTo(TypeNode t)
    {
        auto obj = this.clone();
        obj.castable_to = t;
        return obj;
    }
}
final class DefinitionIdentifierNode : NodeBase
{
    Location loc;
    string _name;
    DefinitionIdentifierParamNode[] _params;

    public override @property Location location(){ return this.loc; }
    public @property name(){ return this._name; }
    public @property params(){ return this._params; }
    public @property hasParameter(){ return this._params !is null; }

    public this(Location l, string n, DefinitionIdentifierParamNode[] ps)
    {
        this.loc = l;
        this._name = n;
        this._params = ps;
    }
}
final class AssocArrayElementNode : ExpressionNode
{
    ExpressionNode[2] _expressions;

    public override @property Location location(){ return this._expressions[0].location; }
    public @property keyExpression(){ return this._expressions[0]; }
    public @property valueExpression(){ return this._expressions[1]; }

    public this(ExpressionNode key, ExpressionNode val)
    {
        this._expressions = [key, val];
    }
}
final class NameValuePair
{
    Location loc;
    string _name;
    ExpressionNode _value;

    public @property location(){ return this.loc; }
    public @property name(){ return this._name; }
    public @property value(){ return this._value; }

    public this(Location l, string n, ExpressionNode v)
    {
        this.loc = l;
        this._name = n;
        this._value = v;
    }
}
final class TypeNamePair
{
    Location l;
    TypeNode _type;
    string _name;

    public @property location(){ return this.l; }
    public @property type(){ return this._type; }
    public @property name(){ return this._name; }

    public this(Location l, TypeNode t, string n)
    {
        this.l = l;
        this._type = t;
        this._name = n;
    }
}

// Super Literals //
alias ThisReferenceNode = NonvalueLiteralNode;
alias SuperReferenceNode = NonvalueLiteralNode;
alias BooleanLiteralNode = SingleValueLiteralNode!bool;
alias NullLiteralNode = NonvalueLiteralNode;

// Literals //
alias IntLiteralNode = SingleValueLiteralNode!int;
alias FloatLiteralNode = SingleValueLiteralNode!float;
alias DoubleLiteralNode = SingleValueLiteralNode!double;
alias NumericLiteralNode = SingleValueLiteralNode!real;
alias StringLiteralNode = SingleValueLiteralNode!string;
alias CharacterLiteralNode = SingleValueLiteralNode!char;
final class FunctionLiteralNode : ExpressionNode
{
    Location loc;
    VirtualParamNode[] _vparams;
    StatementNode _stmt;
    ExpressionNode _expr;

    invariant { assert((this._stmt !is null) != (this._expr !is null)); }

    public override @property Location location(){ return this.loc; }
    public @property vparams(){ return this._vparams; }
    public @property statement(){ return this._stmt; }
    public @property expression(){ return this._expr; }
    public @property isPure(){ return this._stmt is null; }

    public this(Location l, VirtualParamNode[] vps, StatementNode st)
    {
        this.loc = l;
        this._vparams = vps;
        this._stmt = st;
    }
    public this(Location l, VirtualParamNode[] vps, ExpressionNode ex)
    {
        this.loc = l;
        this._vparams = vps;
        this._expr = ex;
    }
    public this(VirtualParamNode vp, ExpressionNode ex)
    {
        this.loc = vp.location;
        this._vparams = [vp];
        this._expr = ex;
    }
}
final class ArrayLiteralNode : ExpressionNode
{
    Location loc;
    ExpressionNode[] elist;

    public override @property Location location(){ return this.loc; }
    public @property expressions(){ return this.elist; }

    public this(Location l, ExpressionNode[] el)
    {
        this.loc = l;
        this.elist = el;
    }
}
final class AssocArrayLiteralNode : ExpressionNode
{
    Location loc;
    AssocArrayElementNode[] elist;

    public override @property Location location(){ return this.loc; }
    public @property elements(){ return this.elist; }

    public this(Location l, AssocArrayElementNode[] el)
    {
        this.loc = l;
        this.elist = el;
    }
}

// Expressions //
final class NewInstanceNode : ExpressionNode
{
    Location loc;
    TypeNode _type;
    ExpressionNode[] _params;

    public override @property Location location(){ return this.loc; }
    public @property type(){ return this._type; }
    public @property params(){ return this._params; }

    public this(Location l, TypeNode tn)
    {
        this.loc = l;
        this._type = tn;
    }
    public this(Location l, TypeNode tn, ExpressionNode[] ps)
    {
        this(l, tn);
        this._params = ps;
    }
}
final class TemplateInstantiateNode : ExpressionNode
{
    Location loc;
    string template_name;
    TemplateParamNode[] _params;

    public override @property Location location(){ return this.loc; }
    public @property templateName(){ return this.template_name; }
    public @property params(){ return this._params; }

    public this(Location l, string tn, TemplateParamNode[] ps)
    {
        this.loc = l;
        this.template_name = tn;
        this._params = ps;
    }
}
final class IdentifierReferenceNode : ExpressionNode
{
    Location loc;
    string ref_name;

    public override @property Location location(){ return this.loc; }
    public @property refName(){ return this.ref_name; }

    public this(Location l, string rn)
    {
        this.loc = l;
        this.ref_name = rn;
    }
}
final enum UnaryOperatorType
{
    Increase, Decrease, Square, Funcall, ArrayRef, ObjectRef, Casting, Negate
}
class PostOperatorNode : ExpressionNode
{
    ExpressionNode _target;
    UnaryOperatorType _op;

    public override @property Location location(){ return this.target.location; }
    public @property target(){ return this._target; }
    public @property operator(){ return this._op; }

    public this(ExpressionNode t, UnaryOperatorType o)
    {
        this._target = t;
        this._op = o;
    }
}
final class FuncallNode : PostOperatorNode
{
    ExpressionNode[] _params;

    public @property params(){ return this._params; }

    public this(ExpressionNode e, ExpressionNode[] ps)
    {
        super(e, UnaryOperatorType.Funcall);
        this._params = ps;
    }
}
final class ArrayRefNode : PostOperatorNode
{
    ExpressionNode[] _dims;

    public @property dimensions(){ return this._dims; }

    public this(ExpressionNode e, ExpressionNode[] ds)
    {
        super(e, UnaryOperatorType.ArrayRef);
        this._dims = ds;
    }
}
final class ObjectRefNode : PostOperatorNode
{
    ExpressionNode _name;

    public @property name(){ return this._name; }

    public this(ExpressionNode e, ExpressionNode r)
    {
        super(e, UnaryOperatorType.ObjectRef);
        this._name = r;
    }
}
final class CastingNode : PostOperatorNode
{
    TypeNode _type;

    public @property type(){ return this._type; }

    public this(ExpressionNode e, TypeNode t)
    {
        super(e, UnaryOperatorType.Casting);
        this._type = t;
    }
}
final class PreOperatorNode : ExpressionNode
{
    Location loc;
    ExpressionNode _target;
    UnaryOperatorType _op;

    public override @property Location location(){ return this.loc; }
    public @property target(){ return this._target; }
    public @property operator(){ return this._op; }

    public this(Location l, ExpressionNode t, UnaryOperatorType o)
    {
        this.loc = l;
        this._target = t;
        this._op = o;
    }
}
final enum BinaryOperatorType
{
    Ranged, Mod, Div, Mul, Sub, Add, Xor, Or, And, LeftShift, RightShift,
    Equiv, Inequiv, Less, Greater, LessEq, GreaterEq, LogAnd, LogOr, LogXor
}
final class BinaryOperatorNode : ExpressionNode
{
    ExpressionNode _left, _right;
    BinaryOperatorType _op;

    public override @property Location location(){ return this._left.location; }
    public @property left(){ return this._left; }
    public @property right(){ return this._right; }
    public @property operator(){ return this._op; }

    public this(ExpressionNode l, BinaryOperatorType o, ExpressionNode r)
    {
        this._left = l;
        this._op = o;
        this._right = r;
    }
}
final class AlternateValueNode : ExpressionNode
{
    ExpressionNode cond, _then, _not;

    public override @property Location location(){ return this.cond.location; }
    public @property condition(){ return this.cond; }
    public @property then(){ return this._then; }
    public @property not(){ return this._not; }

    public this(ExpressionNode c, ExpressionNode t, ExpressionNode n)
    {
        this.cond = c;
        this._then = t;
        this._not = n;
    }
}
final class AssignOperatorNode : ExpressionNode
{
    ExpressionNode _left, _right;

    public override @property Location location(){ return this._left.location; }
    public @property left(){ return this._left; }
    public @property right(){ return this._right; }

    public this(ExpressionNode l, ExpressionNode r)
    {
        this._left = l;
        this._right = r;
    }
}
final class OperatedAssignNode : ExpressionNode
{
    ExpressionNode _left, _right;
    BinaryOperatorType _op;

    public override @property Location location(){ return this._left.location; }
    public @property left(){ return this._left; }
    public @property right(){ return this._right; }
    public @property operator(){ return this._op; }

    public this(ExpressionNode l, BinaryOperatorType t, ExpressionNode r)
    {
        this._left = l;
        this._op = t;
        this._right = r;
    }
}

// Statement //
final class LocalVariableDeclarationNode : StatementNode
{
    Location iloc;
    Qualifier _qual;
    TypeNode _type;
    NameValuePair[] decls;

    public override @property Location location(){ return this.iloc; }
    public @property qualifier(){ return this._qual; }
    public @property type(){ return this._type; }
    public @property declarators(){ return this.decls; }

    public this(Location il, Qualifier q, TypeNode t, NameValuePair[] nvp)
    {
        this.iloc = il;
        this._qual = q;
        this._type = t;
        this.decls = nvp;
    }
}
final class BlockStatementNode : StatementNode
{
    Location loc;
    StatementNode[] inner;

    public override @property Location location(){ return this.loc; }
    public @property innerElements(){ return this.inner; }

    public this(Location l, StatementNode[] st)
    {
        this.loc = l;
        this.inner = st;
    }
}
class SwitchSectionNode : NodeBase
{
    Location loc;
    StatementNode following_stmt;

    public final override @property Location location(){ return this.loc; }
    public final @property followingStmt(){ return this.following_stmt; }

    public this(Location l, StatementNode fs)
    {
        this.loc = l;
        this.following_stmt = fs;
    }
}
final class DefaultSectionNode : SwitchSectionNode
{
    public this(Location l, StatementNode fs)
    {
        super(l, fs);
    }
}
final class ValueCaseSectionNode : SwitchSectionNode
{
    ExpressionNode[] _values;

    public @property values(){ return this._values; }

    public this(Location l, ExpressionNode[] vs, StatementNode fs)
    {
        super(l, fs);
        this._values = vs;
    }
}
final class TypeCaseSectionNode : SwitchSectionNode
{
    bool is_const_restraint;
    DefinitionIdentifierNode _name;
    TypeNode _type;
    ExpressionNode cond;

    public @property isConstRestraint(){ return this.is_const_restraint; }
    public @property name(){ return this._name; }
    public @property type(){ return this._type; }
    public @property condition(){ return this.cond; }

    public this(Location l, bool icr, DefinitionIdentifierNode n, TypeNode t, ExpressionNode c, StatementNode fs)
    {
        super(l, fs);
        this.is_const_restraint = icr;
        this._name = n;
        this._type = t;
        this.cond = c;
    }
}
final class SwitchStatementNode : StatementNode
{
    Location loc;
    ExpressionNode _target;
    SwitchSectionNode[] sects;

    public override @property Location location(){ return this.loc; }
    public @property target(){ return this._target; }
    public @property sections(){ return this.sects; }

    public this(Location l, ExpressionNode t, SwitchSectionNode[] ss)
    {
        this.loc = l;
        this._target = t;
        this.sects = ss;
    }
}
final class ContinueLoopNode : StatementNode
{
    Location loc;
    string _name;

    public override @property Location location(){ return this.loc; }
    public @property name(){ return this._name; }

    public this(Location l, string n)
    {
        this.loc = l;
        this._name = n;
    }
}
final class BreakLoopNode : StatementNode
{
    Location loc;
    string _name;

    public override @property Location location(){ return this.loc; }
    public @property name(){ return this._name; }

    public this(Location l, string n)
    {
        this.loc = l;
        this._name = n;
    }
}
final class ReturnNode : StatementNode
{
    Location loc;
    ExpressionNode _value;

    public override @property Location location(){ return this.loc; }
    public @property value(){ return this._value; }

    public this(Location l, ExpressionNode v)
    {
        this.loc = l;
        this._value = v;
    }
}
abstract class NamedStatementNode : StatementNode
{
    Location loc;
    string _name;

    public override @property Location location(){ return this.loc; }
    public @property name(){ return this._name; }

    public abstract typeof(this) clone();
    public auto withName(string n)
    {
        auto obj = this.clone();
        obj._name = n;
        return obj;
    }

    public this(Location l, string n)
    {
        this.loc = l;
        this._name = n;
    }
}
final class ForStatementNode : NamedStatementNode
{
    ExpressionNode[3] expr;
    StatementNode stmt;

    public @property init(){ return this.expr[0]; }
    public @property cond(){ return this.expr[1]; }
    public @property step(){ return this.expr[2]; }
    public @property statement(){ return this.stmt; }

    public override typeof(this) clone()
    {
        return new ForStatementNode(this.location, this.name, this.init, this.cond, this.step, this.statement);
    }

    public this(Location l, string n, ExpressionNode i, ExpressionNode c, ExpressionNode s, StatementNode st)
    {
        super(l, n);
        this.expr = [i, c, s];
        this.stmt = st;
    }
    public this(Location l, ExpressionNode i, ExpressionNode c, ExpressionNode s, StatementNode st)
    {
        this(l, null, i, c, s, st);
    }
}
final class ForeachStatementNode : NamedStatementNode
{
    TypeNamePair[] tnps;
    ExpressionNode _target;
    StatementNode stmt;

    public @property typeNamePairs(){ return this.tnps; }
    public @property target(){ return this._target; }
    public @property statement(){ return this.stmt; }

    public override typeof(this) clone()
    {
        return new ForeachStatementNode(this.location, this.name, this.typeNamePairs, this.target, this.statement);
    }

    public this(Location l, string n, TypeNamePair[] t, ExpressionNode tg, StatementNode s)
    {
        super(l, n);
        this.tnps = t;
        this._target = tg;
        this.stmt = s;
    }
    public this(Location l, TypeNamePair[] t, ExpressionNode tg, StatementNode s)
    {
        this(l, null, t, tg, s);
    }
}
final class PostConditionLoopNode : NamedStatementNode
{
    ExpressionNode cond;
    StatementNode stmt;

    public @property condition(){ return this.cond; }
    public @property statement(){ return this.stmt; }

    public override typeof(this) clone()
    {
        return new PostConditionLoopNode(this.location, this.name, this.condition, this.statement);
    }

    public this(Location l, string n, ExpressionNode c, StatementNode s)
    {
        super(l, n);
        this.cond = c;
        this.stmt = s;
    }
    public this(Location l, ExpressionNode c, StatementNode s)
    {
        this(l, null, c, s);
    }
}
final class PreConditionLoopNode : NamedStatementNode
{
    ExpressionNode cond;
    StatementNode stmt;

    public @property condition(){ return this.cond; }
    public @property statement(){ return this.stmt; }

    public override typeof(this) clone()
    {
        return new PreConditionLoopNode(this.location, this.name, this.condition, this.statement);
    }

    public this(Location l, string n, ExpressionNode c, StatementNode s)
    {
        super(l, n);
        this.cond = c;
        this.stmt = s;
    }
    public this(Location l, ExpressionNode c, StatementNode s)
    {
        this(l, null, c, s);
    }
}
final class ConditionalNode : StatementNode
{
    Location loc;
    ExpressionNode cond;
    StatementNode _then, _not;

    public override @property Location location(){ return this.loc; }
    public @property condition(){ return this.cond; }
    public @property then(){ return this._then; }
    public @property not(){ return this._not; }

    public this(Location l, ExpressionNode c, StatementNode t, StatementNode n)
    {
        this.loc = l;
        this.cond = c;
        this._then = t;
        this._not = n;
    }
}

// Declarations //
final class ConstructorDeclarationNode : DeclarationNode
{
    Location loc;
    Qualifier qual;
    VirtualParamNode[] _params;
    StatementNode stmt;

    public override @property Location location(){ return this.loc; }
    public @property qualifier(){ return this.qual; }
    public @property params(){ return this._params; }
    public @property statement(){ return this.stmt; }

    public this(Location l, Qualifier q, VirtualParamNode[] vps, StatementNode st)
    {
        this.loc = l;
        this.qual = q;
        this._params = vps;
        this.stmt = st;
    }
}
final class GetterDeclarationNode : DeclarationNode
{
    Location loc;
    Qualifier qual;
    TypeNode _type;
    DefinitionIdentifierNode _name;
    StatementNode stmt;
    ExpressionNode expr;

    public override @property Location location(){ return this.loc; }
    public @property qualifier(){ return this.qual; }
    public @property type(){ return this._type; }
    public @property name(){ return this._name; }
    public @property statement(){ return this.stmt; }
    public @property expression(){ return this.expr; }
    public @property isPure(){ return this.expr !is null; }
    public @property isAbstract(){ return this.expr is null && this.stmt is null; }

    public this(Location l, Qualifier q, TypeNode t, DefinitionIdentifierNode n)
    {
        this.loc = l;
        this.qual = q;
        this._type = t;
        this._name = n;
    }
    public this(Location l, Qualifier q, TypeNode t, DefinitionIdentifierNode n, StatementNode s)
    {
        this.loc = l;
        this.qual = q;
        this._type = t;
        this._name = n;
        this.stmt = s;
    }
    public this(Location l, Qualifier q, TypeNode t, DefinitionIdentifierNode n, ExpressionNode e)
    {
        this.loc = l;
        this.qual = q;
        this._type = t;
        this._name = n;
        this.expr = e;
    }
}
final class SetterDeclarationNode : DeclarationNode
{
    Location loc;
    Qualifier qual;
    TypeNode _type;
    DefinitionIdentifierNode _name;
    TypeNamePair _param;
    StatementNode stmt;

    public override @property Location location(){ return this.loc; }
    public @property qualifier(){ return this.qual; }
    public @property type(){ return this._type; }
    public @property name(){ return this._name; }
    public @property param(){ return this._param; }
    public @property statement(){ return this.stmt; }
    public @property isAbstract(){ return this.stmt is null; }

    public this(Location l, Qualifier q, TypeNode t, DefinitionIdentifierNode n, TypeNamePair p, StatementNode s)
    {
        this.loc = l;
        this.qual = q;
        this._type = t;
        this._name = n;
        this._param = p;
        this.stmt = s;
    }
    public this(Location l, Qualifier q, TypeNode t, DefinitionIdentifierNode n, TypeNamePair p)
    {
        this(l, q, t, n, p, null);
    }
}
final class MethodDeclarationNode : DeclarationNode
{
    Location loc;
    Qualifier qual;
    TypeNode _type;
    DefinitionIdentifierNode _name;
    VirtualParamNode[] _vparams;
    StatementNode stmt;
    ExpressionNode expr;

    public override @property Location location(){ return this.loc; }
    public @property qualifier(){ return this.qual; }
    public @property type(){ return this._type; }
    public @property name(){ return this._name; }
    public @property vparams(){ return this._vparams; }
    public @property statement(){ return this.stmt; }
    public @property expression(){ return this.expr; }
    public @property isPure(){ return this.expr !is null; }
    public @property isAbstract(){ return this.expr is null && this.stmt is null; }

    public this(Location l, Qualifier q, TypeNode t, DefinitionIdentifierNode n, VirtualParamNode[] vps)
    {
        this.loc = l;
        this.qual = q;
        this._type = t;
        this._name = n;
        this._vparams = vps;
    }
    public this(Location l, Qualifier q, TypeNode t, DefinitionIdentifierNode n, VirtualParamNode[] vps, StatementNode st)
    {
        this.loc = l;
        this.qual = q;
        this._type = t;
        this._name = n;
        this._vparams = vps;
        this.stmt = st;
    }
    public this(Location l, Qualifier q, TypeNode t, DefinitionIdentifierNode n, VirtualParamNode[] vps, ExpressionNode ex)
    {
        this.loc = l;
        this.qual = q;
        this._type = t;
        this._name = n;
        this._vparams = vps;
        this.expr = ex;
    }
}
final class FieldDeclarationNode : DeclarationNode
{
    Location loc;
    Qualifier qual;
    TypeNode _type;
    NameValuePair[] nvps;

    public override @property Location location(){ return this.loc; }
    public @property qualifier(){ return this.qual; }
    public @property type(){ return this._type; }
    public @property declarators(){ return this.nvps; }

    public this(Location l, Qualifier q, TypeNode t, NameValuePair[] nvps)
    {
        this.loc = l;
        this.qual = q;
        this._type = t;
        this.nvps = nvps;
    }
}

// Structure/Toplevel Declaration //
final class AliasDeclarationNode : DeclarationNode
{
    Location loc;
    Qualifier qual;
    TypeNode _type;
    DefinitionIdentifierNode _name;

    public override @property Location location(){ return this.loc; }
    public @property qualifier(){ return qual; }
    public @property type(){ return this._type; }
    public @property name(){ return this._name; }

    public this(Location l, Qualifier q, TypeNode t, DefinitionIdentifierNode n)
    {
        this.loc = l;
        this.qual = q;
        this._type = t;
        this._name = n;
    }
}
final class TemplateDeclarationNode : DeclarationNode
{
    Location loc;
    Qualifier qual;
    string _name;
    TemplateVirtualParamNode[] tvps;
    DeclarationNode[] decls;

    public override @property Location location(){ return this.loc; }
    public @property qualifier(){ return this.qual; }
    public @property name(){ return this._name; }
    public @property params(){ return this.tvps; }
    public @property declarators(){ return this.decls; }

    public this(Location l, Qualifier q, string n, TemplateVirtualParamNode[] tvps, DeclarationNode[] ds)
    {
        this.loc = l;
        this.qual = q;
        this._name = n;
        this.tvps = tvps;
        this.decls = ds;
    }
}
final class EnumElementNode : NodeBase
{
    Location loc;
    string _name;
    ExpressionNode[] ctor_params;

    public override @property Location location(){ return this.loc; }
    public @property name(){ return this._name; }
    public @property ctorParams(){ return this.ctor_params; }

    public this(Location l, string n, ExpressionNode[] cp)
    {
        this.loc = l;
        this._name = n;
        this.ctor_params = cp;
    }
}
final class EnumDeclarationNode : DeclarationNode
{
    Location loc;
    Qualifier qual;
    string _name;
    EnumElementNode[] _elements;
    DeclarationNode[] class_body;

    public override @property Location location(){ return this.loc; }
    public @property qualifier(){ return this.qual; }
    public @property name(){ return this._name; }
    public @property elements(){ return this._elements; }
    public @property classBody(){ return this.class_body; }

    public this(Location l, Qualifier q, string n, EnumElementNode[] es, DeclarationNode[] cb)
    {
        this.loc = l;
        this.qual = q;
        this._name = n;
        this._elements = es;
        this.class_body = cb;
    }
}
final class TraitDeclarationNode : DeclarationNode
{
    Location loc;
    Qualifier qual;
    DefinitionIdentifierNode _name;
    TypeNode[] with_traits;
    DeclarationNode[] trait_body;

    public override @property Location location(){ return this.loc; }
    public @property qualifier(){ return this.qual; }
    public @property name(){ return this._name; }
    public @property withTraits(){ return this.with_traits; }
    public @property traitBody(){ return this.trait_body; }

    public this(Location l, Qualifier q, DefinitionIdentifierNode n, TypeNode[] wt, DeclarationNode[] tb)
    {
        this.loc = l;
        this.qual = q;
        this._name = n;
        this.with_traits = wt;
        this.trait_body = tb;
    }
}
final class ClassDeclarationNode : DeclarationNode
{
    Location loc;
    Qualifier qual;
    DefinitionIdentifierNode _name;
    TypeNode extended_from;
    TypeNode[] with_traits;
    DeclarationNode[] class_body;

    public override @property Location location(){ return this.loc; }
    public @property qualifier(){ return this.qual; }
    public @property name(){ return this._name; }
    public @property extendedFrom(){ return this.extended_from; }
    public @property withTraits(){ return this.with_traits; }
    public @property classBody(){ return this.class_body; }

    public this(Location l, Qualifier q, DefinitionIdentifierNode n, TypeNode ef, TypeNode[] wt, DeclarationNode[] cb)
    {
        this.loc = l;
        this.qual = q;
        this._name = n;
        this.extended_from = ef;
        this.with_traits = wt;
        this.class_body = cb;
    }
}
final class PartialPackageDeclarationNode : DeclarationNode
{
    Location loc;
    Token[] _name;
    DeclarationNode[] nodes;

    public override @property Location location(){ return this.loc; }
    public @property name(){ return this._name; }
    public @property elements(){ return this.nodes; }

    public this(Location l, Token[] n, DeclarationNode[] ns)
    {
        this.loc = l;
        this._name = n;
        this.nodes = ns;
    }
}
final class ImportUnitNode : DeclarationNode
{
    Location loc;
    string[] base_path;
    bool is_wildcard;
    ImportUnitNode[] sub_paths;

    public override @property Location location(){ return this.loc; }
    public @property basePath(){ return this.base_path; }
    public @property isWildcard(){ return this.is_wildcard; }
    public @property subPaths(){ return this.sub_paths; }

    public this(Location l, string[] bp, bool iw)
    {
        this.loc = l;
        this.base_path = bp;
        this.is_wildcard = iw;
    }
    public this(Location l, string[] bp, ImportUnitNode[] sp)
    {
        this.loc = l;
        this.base_path = bp;
        this.is_wildcard = false;
        this.sub_paths = sp;
    }
}
final class ImportDeclarationNode : DeclarationNode
{
    Location loc;
    ImportUnitNode[] units;

    public override @property Location location(){ return this.loc; }
    public @property items(){ return this.units; }

    public this(Location l, ImportUnitNode[] us)
    {
        this.loc = l;
        this.units = us;
    }
}
final class StaticInitializerNode : DeclarationNode
{
    // Wrapper for StatementNode to DeclarationNode conversion
    StatementNode st;

    public override @property Location location(){ return this.st.location; }
    public @property statement(){ return this.st; }

    public this(StatementNode st)
    {
        this.st = st;
    }
}

// Script //
final class ScriptNode : NodeBase
{
    Token[] package_name;
    DeclarationNode[] decls;

    public override @property Location location(){ return Location(1, 1); }
    public @property packageName(){ return this.package_name; }
    public @property declarators(){ return this.decls; }

    public this(Token[] pn, DeclarationNode[] ds)
    {
        this.package_name = pn;
        this.decls = ds;
    }
}
