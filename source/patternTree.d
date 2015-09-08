module com.cterm2.tpeg.patternTree;

import std.string, std.conv;
import std.range, std.algorithm;

struct PatternTreeLocation
{
	size_t line, col;

	public auto toString()
	{
		return "Line " ~ this.line.to!string ~ ", Column " ~ this.col.to!string ~ " in pattern";
	}
}

class PatternTreeBase : IPatternTreeAcceptor
{
	// must be exported
	public abstract @property PatternTreeLocation location() pure;

	mixin PatternTreeAcceptorDefaultImpl;
}

class SoloContentNode(ContentT) : PatternTreeBase
{
	PatternTreeLocation loc;
	ContentT cont;

	public override @property PatternTreeLocation location() pure { return this.loc; }
	public @property content() pure { return this.cont; }

	public this(PatternTreeLocation l, ContentT c)
	{
		this.loc = l;
		this.cont = c;
	}

	mixin PatternTreeAcceptorDefaultImpl;
}
class PatternStringOperatorNode : PatternTreeBase
{
	public alias opEquals = Object.opEquals;
	public abstract bool opEquals(LiteralStringNode p);
	public abstract bool opEquals(RangedLiteralNode p);
	public abstract bool opEquals(PatternStringOperatorNode p);
	public abstract bool canMatch(LiteralStringNode p);
	public abstract bool canMatch(RangedLiteralNode p);
	public final bool canMatch(PatternStringOperatorNode p)
	{
		if(typeid(p) == typeid(LiteralStringNode)) return this.canMatch(cast(LiteralStringNode)p);
		else if(typeid(p) == typeid(RangedLiteralNode)) return this.canMatch(cast(RangedLiteralNode)p);
		assert(false);
	}
	public abstract PatternStringOperatorNode[] purge();
}
class LiteralStringNode : PatternStringOperatorNode
{
	PatternTreeLocation loc;
	string cont;

	public override @property PatternTreeLocation location() pure { return this.loc; }
	public @property content() pure { return this.cont; }

	public alias opEquals = Object.opEquals;
	public override bool opEquals(LiteralStringNode p)
	{
		return this.cont == p.cont;
	}
	public override bool opEquals(RangedLiteralNode p)
	{
		return p.left.opEquals(p.right) && this.opEquals(p.left);
	}
	public override bool opEquals(PatternStringOperatorNode p) { return p.opEquals(this); }
	public override bool canMatch(LiteralStringNode p) { return this.cont == p.cont; }		// matches "a".canMatch("a")
	public override bool canMatch(RangedLiteralNode p) { return false; }					// doesn't match "a".canMatch("0"~"9")
	public override PatternStringOperatorNode[] purge()
	{
		return this.cont.map!(a => cast(PatternStringOperatorNode)new LiteralStringNode(this.loc, (cast(dchar)a).to!string)).array;
	}

	public this(PatternTreeLocation l, string c)
	{
		this.loc = l;
		this.cont = c;
	}

	public override string toString() { return "LiteralString<" ~ this.cont ~ ">"; }

	mixin PatternTreeAcceptorDefaultImpl;
}
class RangedLiteralNode : PatternStringOperatorNode
{
	LiteralStringNode[2] nodes;

	public override @property PatternTreeLocation location() pure { return this.nodes[0].location; }
	public @property left() pure { return this.nodes[0]; }
	public @property right() pure { return this.nodes[1]; }

	public alias opEquals = Object.opEquals;
	public override bool opEquals(LiteralStringNode p)
	{
		return this.left.opEquals(this.right) && p.opEquals(this.left);
	}
	public override bool opEquals(RangedLiteralNode p)
	{
		return p.left.opEquals(this.left) && p.right.opEquals(this.right);
	}
	public override bool opEquals(PatternStringOperatorNode p) { return p.opEquals(this); }
	public override bool canMatch(LiteralStringNode p)
	{
		// matches ("0"~"9").canMatch("0")
		return p.cont.length == 1 && this.left.cont.front <= p.cont.front && p.cont.front <= this.right.cont.front;
	}
	public override bool canMatch(RangedLiteralNode p)
	{
		// matches ("0"~"9").canMatch("4"~"5")
		return this.left.cont.front <= p.left.cont.front && p.right.cont.front <= this.right.cont.front;
	}
	public override PatternStringOperatorNode[] purge()
	{
		return [new RangedLiteralNode(this.left, this.right)];
	}

	public this(LiteralStringNode l, LiteralStringNode r)
	{
		this.nodes[0] = l;
		this.nodes[1] = r;
	}

	public override string toString() { return "CharRange<" ~ this.left.cont ~ "-" ~ this.right.cont ~ ">"; }

	mixin PatternTreeAcceptorDefaultImpl;
}
class PatternGroupNode : SoloContentNode!PatternTreeBase
{
	public this(PatternTreeLocation l, PatternTreeBase c)
	{
		super(l, c);
	}

	public override string toString()
	{
		return this.content.toString;
	}

	mixin PatternTreeAcceptorDefaultImpl;
}
class ExcludingPatternNode : SoloContentNode!PatternTreeBase
{
	public this(PatternTreeLocation l, PatternTreeBase c)
	{
		super(l, c);
	}

	public override string toString()
	{
		return "" ~ this.content.toString ~ "<Exc>";
	}

	mixin PatternTreeAcceptorDefaultImpl;
}
class ZeroLoopQualifiedPatternNode : PatternTreeBase
{
	PatternTreeBase cont;

	public override @property PatternTreeLocation location() pure { return this.cont.location; }
	public @property content() pure { return this.cont; }

	public this(PatternTreeBase c)
	{
		this.cont = c;
	}

	public override string toString()
	{
		return "" ~ this.content.toString ~ "<More>";
	}

	mixin PatternTreeAcceptorDefaultImpl;
}
class LoopQualifiedPatternNode : PatternTreeBase
{
	PatternTreeBase cont;

	public override @property PatternTreeLocation location() pure { return this.cont.location; }
	public @property content() pure { return this.cont; }

	public this(PatternTreeBase c)
	{
		this.cont = c;
	}

	public override string toString()
	{
		return "" ~ this.content.toString ~ "<Onemore>";
	}

	mixin PatternTreeAcceptorDefaultImpl;
}
class PatternSequenceNode : PatternTreeBase
{
	PatternTreeBase[] _trees;

	invariant { assert(this._trees !is null); }

	public override @property PatternTreeLocation location() pure { return this.trees[0].location; }
	public @property trees() pure { return this._trees; }

	public this(PatternTreeBase[] ts)
	{
		this._trees = ts;
	}

	public override string toString()
	{
		return "(" ~ this.trees.map!(a => a.toString).join("->") ~ ")";
	}

	mixin PatternTreeAcceptorDefaultImpl;
}
class PatternSwitchNode : PatternTreeBase
{
	PatternTreeBase[] _trees;

	invariant { assert(this._trees !is null); }

	public override @property PatternTreeLocation location() pure { return this.trees[0].location; }
	public @property trees() pure { return this._trees; }

	public this(PatternTreeBase[] ts)
	{
		this._trees = ts;
	}

	public override string toString()
	{
		return "(" ~ this.trees.map!(a => a.toString).join("|") ~ ")";
	}

	mixin PatternTreeAcceptorDefaultImpl;
}

interface IPatternTreeVisitor
{
	public void visit(PatternSwitchNode);
	public void visit(PatternSequenceNode);
	public void visit(RangedLiteralNode);
	public void visit(LoopQualifiedPatternNode);
	public void visit(ZeroLoopQualifiedPatternNode);
	public void visit(ExcludingPatternNode);
	public void visit(PatternGroupNode);
	public void visit(LiteralStringNode);

	public final void visit(PatternTreeBase n) { assert(false); }
}
interface IPatternTreeAcceptor
{
	public void accept(IPatternTreeVisitor);
}
mixin template PatternTreeAcceptorDefaultImpl()
{
	public override void accept(IPatternTreeVisitor vis)
	{
		vis.visit(this);
	}
}

class PatternTreeDumper : IPatternTreeVisitor
{
	import std.stdio, std.range;

	private bool requireIndent = true;
	private size_t indents;
	private @property auto tabs() { return this.requireIndent ? "  ".repeat(this.indents).join : ""; }
	private void enterNodeBlock(string nodeName)
	{
		writeln(this.tabs, nodeName); this.requireIndent = true;
		this.indents++;
	}
	private void leaveNodeBlock()
	{
		this.indents--;
	}

	public void entry(IPatternTreeAcceptor node)
	{
		this.indents = 0;
		node.accept(this);
	}

	public override void visit(PatternSwitchNode node)
	{
		this.enterNodeBlock("PatternSwitchNode");
		foreach(n; node.trees) n.accept(this);
		this.leaveNodeBlock();
	}
	public override void visit(PatternSequenceNode node)
	{
		this.enterNodeBlock("PatternSequenceNode");
		foreach(n; node.trees) n.accept(this);
		this.leaveNodeBlock();
	}
	public override void visit(RangedLiteralNode node)
	{
		this.enterNodeBlock("RangedLiteralNode");
		write(this.tabs, "left: "); this.requireIndent = false;
		node.left.accept(this);
		write(this.tabs, "right: "); this.requireIndent = false;
		node.right.accept(this);
		this.leaveNodeBlock();
	}
	public override void visit(LoopQualifiedPatternNode node)
	{
		this.enterNodeBlock("LoopQualifiedPatternNode");
		write(this.tabs, "content: "); this.requireIndent = false;
		node.content.accept(this);
		this.leaveNodeBlock();
	}
	public override void visit(ZeroLoopQualifiedPatternNode node)
	{
		this.enterNodeBlock("ZeroLoopQualifiedPatternNode");
		write(this.tabs, "content: "); this.requireIndent = false;
		node.content.accept(this);
		this.leaveNodeBlock();
	}
	public override void visit(ExcludingPatternNode node)
	{
		this.enterNodeBlock("ExcludingPatternNode");
		write(this.tabs, "content: "); this.requireIndent = false;
		node.content.accept(this);
		this.leaveNodeBlock();
	}
	public override void visit(PatternGroupNode node)
	{
		this.enterNodeBlock("PatternGroupNode");
		write(this.tabs, "content: "); this.requireIndent = false;
		node.content.accept(this);
		this.leaveNodeBlock();
	}
	public override void visit(LiteralStringNode node)
	{
		this.enterNodeBlock("LiteralStringNode");
		writeln(this.tabs, "content: ", node.content);
		this.leaveNodeBlock();
	}
}