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
	public @property escapedContent() pure
	{
		if(this.content.front != '\\') return this.content;
		else
		{
			switch(this.content[1])
			{
			case 'n': return "\n";
			case 't': return "\t";
			case 'r': return "\r";
			default: return this.content[1].to!string;
			}
		}
	}

	public override PatternStringOperatorNode[] purge()
	{
		PatternTreeLocation loc = this.loc;
		PatternStringOperatorNode[] nodes;
		bool inEscape = false;
		foreach(a; this.cont)
		{
			if(inEscape)
			{
				nodes ~= new LiteralStringNode(loc, "\\" ~ a);
				loc.col += 2;
				inEscape = false;
			}
			else
			{
				if(a == '\\') inEscape = true;
				else
				{
					nodes ~= new LiteralStringNode(loc, a.to!string);
					loc.col++;
				}
			}
		}
		assert(!inEscape);
		return nodes;
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
class AnyCharacterNode : PatternStringOperatorNode
{
	PatternTreeLocation loc;

	public override @property PatternTreeLocation location() pure { return this.loc; }

	public override PatternStringOperatorNode[] purge()
	{
		return [new AnyCharacterNode(this.loc)];
	}

	public this(PatternTreeLocation l)
	{
		this.loc = l;
	}

	public override string toString() { return "AnyCharacter"; }
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
	public void visit(LiteralStringNode);
	public void visit(AnyCharacterNode);

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
	public override void visit(LiteralStringNode node)
	{
		this.enterNodeBlock("LiteralStringNode");
		writeln(this.tabs, "content: ", node.content);
		this.leaveNodeBlock();
	}
	public override void visit(AnyCharacterNode node)
	{
		this.enterNodeBlock("AnyCharacterNode");
		this.leaveNodeBlock();
	}
}