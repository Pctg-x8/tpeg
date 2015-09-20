module com.cterm2.tpeg.parserIndexAlloc;

import settings = com.cterm2.tpeg.settings;
import com.cterm2.tpeg.visitor;
import com.cterm2.tpeg.tree;
import std.stdio, std.path, std.file, std.algorithm, std.string;
import std.conv, std.regex, std.range;

class ParserIndexAllocator : IVisitor
{
	int complexRuleCount = 0;
	int[string] complexRuleIdentifierTable;

	public void entry(ScriptNode node)
	{
		this.complexRuleIdentifierTable = null;
		this.complexRuleCount = 0;

		node.accept(this);
	}

	private void acquireRuleOrdinal(NodeT : PEGNodeBase)(NodeT node) if(__traits(hasMember, NodeT, "complexRuleOrdinal"))
	{
		if(node.complexRuleOrdinal < 0)
		{
			auto ruleIdentifier = node.ruleIdentifier;
			if(ruleIdentifier in this.complexRuleIdentifierTable)
			{
				node.complexRuleOrdinal = this.complexRuleIdentifierTable[ruleIdentifier];
			}
			else
			{
				this.complexRuleIdentifierTable[ruleIdentifier] = this.complexRuleCount;
				node.complexRuleOrdinal = this.complexRuleCount;
				this.complexRuleCount++;
			}
		}
	}

	// IVisitor //
	public void visit(ScriptNode node)
	{
		if(node.parser !is null) node.parser.accept(this);
	}
	public void visit(TokenizerNode node){}
	public void visit(ParserNode node)
	{
		foreach(n; node.rules) n.accept(this);
	}
	public void visit(PatternNode node){}
	public void visit(RuleNode node)
	{
		node.ruleBody.accept(this);
	}
	public void visit(PEGSwitchingNode node)
	{
		foreach(n; node.nodes) n.accept(this);
		this.acquireRuleOrdinal(node);
	}
	public void visit(PEGSequentialNode node)
	{
		foreach(n; node.nodes) n.accept(this);
		this.acquireRuleOrdinal(node);
	}
	public void visit(PEGLoopQualifiedNode node)
	{
		node.inner.accept(this);
		this.acquireRuleOrdinal(node);
	}
	public void visit(PEGSkippableNode node)
	{
		node.inner.accept(this);
		this.acquireRuleOrdinal(node);
	}
	public void visit(PEGActionNode node)
	{
		// nothing to do
	}
	public void visit(PEGElementNode node)
	{
		// nothing to do
	}
}
