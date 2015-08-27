module com.cterm2.ml.syntaxTree;

import com.cterm2.ml.lexer : Location;

abstract class NodeBase
{
    public abstract @property Location location();
}

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
    Override = 1 << 6
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
    public Qualifier combine(Qualifier q)
    {
        auto use_qloc = this.location.line > q.location.line && this.location.col > q.location.col;
        return Qualifier(use_qloc ? q.location : this.location, q.q_values | this.q_values);
    }
    public this(Location l, byte v)
    {
        this.location = l;
        this.q_values = v;
    }
}

// Type Nodes //
abstract class TypeNode : NodeBase {}
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
        this.default_value = dc;
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
    public @property name(){ return this.name; }
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

    invariant { assert(this._expressions !is null); }

    public override @property Location location(){ return this._expressions[0].location; }
    public @property keyExpression(){ return this._expressions[0]; }
    public @property valueExpression(){ return this._expressions[1]; }

    public this(ExpressionNode key, ExpressionNode val)
    {
        this._expressions = [key, val];
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
    StatementNode[] _stmt;
    ExpressionNode[] _expr;

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
