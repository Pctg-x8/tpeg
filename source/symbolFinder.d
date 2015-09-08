module com.cterm2.tpeg.symbolFinder;

import com.cterm2.tpeg.visitor;
import com.cterm2.tpeg.tree;
import std.algorithm, std.array, std.stdio;
import com.cterm2.tpeg.scriptParser;

enum EnumFinderPhase
{
	Prepare, Resolve
}

struct LocationalString
{
	Location loc;
	string str;
}

class SymbolFinder : IVisitor
{
	EnumFinderPhase phase;
	LocationalString[] patternNames, ruleNames;
	public bool hasError = false;

	public void prepare(ScriptNode node)
	{
		this.phase = EnumFinderPhase.Prepare;
		this.patternNames = null;
		this.ruleNames = null;
		this.hasError = false;
		node.accept(this);
		foreach(a; this.patternNames)
		{
			foreach(b; this.ruleNames) if(a.str == b.str)
			{
				writeln("Error: Symbol " ~ a.str ~ " is in another section(line ", a.loc, " and line ", b.loc, ")");
				hasError = true;
				break;
			}
		}
	}
	public void resolve(ScriptNode node)
	{
		this.phase = EnumFinderPhase.Resolve;
		this.hasError = false;
		node.accept(this);
	}

	public override void visit(ScriptNode node)
	{
		node.tokenizer && node.tokenizer.accept(this);
		node.parser && node.parser.accept(this);
	}
	public override void visit(TokenizerNode node)
	{
		foreach(n; node.skipPatterns) n.accept(this);
		foreach(n; node.patterns) n.accept(this);
		foreach(s, n; node.specializes)
		{
			if(this.phase == EnumFinderPhase.Resolve)
			{
				if(!this.patternNames.any!(a => a.str == s))
				{
					writeln("Error: Token " ~ s ~ " is not found. at line ", node.location);
					this.hasError = true;
				}
			}
			else
			{
				foreach(nds; n) nds.accept(this);
			}
		}
		if(this.phase == EnumFinderPhase.Prepare) node.patternSymbols = this.patternNames.map!(a => a.str).array;
	}
	public override void visit(ParserNode node)
	{
		foreach(n; node.rules) n.accept(this);
	}
	public override void visit(PatternNode node)
	{
		final switch(this.phase)
		{
		case EnumFinderPhase.Prepare:
			if(node.tokenName !is null)
			{
				if(this.patternNames.any!(a => a.str == node.tokenName))
				{
					writeln("Error: Pattern Symbol " ~ node.tokenName ~ " is declared again. at line ", node.location);
					this.hasError = true;
				}
				else
				{
					this.patternNames ~= LocationalString(node.location, node.tokenName);
				}
			}
			break;
		case EnumFinderPhase.Resolve: break;
		}
	}
	public override void visit(RuleNode node)
	{
		final switch(this.phase)
		{
		case EnumFinderPhase.Prepare:
			if(node.ruleName !is null)
			{
				if(this.ruleNames.any!(a => a.str == node.ruleName))
				{
					writeln("Error: Rule Symbol " ~ node.ruleName ~ " is declared again. at line ", node.location);
					this.hasError = true;
				}
				else
				{
					this.ruleNames ~= LocationalString(node.location, node.ruleName);
				}
			}
			break;
		case EnumFinderPhase.Resolve:
			node.ruleBody && node.ruleBody.accept(this);
		}
	}
	public override void visit(PEGSwitchingNode node)
	{
		foreach(n; node.nodes) n.accept(this);
	}
	public override void visit(PEGSequentialNode node)
	{
		foreach(n; node.nodes) n.accept(this);
	}
	public override void visit(PEGLoopQualifiedNode node)
	{
		node.inner && node.inner.accept(this);
	}
	public override void visit(PEGSkippableNode node)
	{
		node.inner && node.inner.accept(this);
	}
	public override void visit(PEGActionNode node)
	{

	}
	public override void visit(PEGElementNode node)
	{
		final switch(this.phase)
		{
		case EnumFinderPhase.Prepare: return;
		case EnumFinderPhase.Resolve:
			if(this.ruleNames.any!(a => a.str == node.elementName))
			{
				node.toRuleElement;
			}
			else if(this.patternNames.any!(a => a.str == node.elementName))
			{
				node.toPatternElement;
			}
			else
			{
				writeln("Error: Symbol " ~ node.elementName ~ " is not found. at line ", node.location);
				this.hasError = true;
			}
			break;
		}
	}
}
