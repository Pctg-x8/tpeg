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
    TypeNode[] _types;

    public override @property Location location(){ return this.loc; }
    public @property templateName(){ return this.template_name; }
    public @property types(){ return this._types; }
    public this(Location l, string tn, TypeNode[] ts)
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
        RestrictedTypeNode _type;
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
    public this(Location l, RestrictedTypeNode t)
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
    public this(Qualifier q, TYpeNode bt)
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

}
