module com.cterm2.tpeg.visitor;

import com.cterm2.tpeg.tree;

interface IVisitor
{
	// Visitor Interface

	public void visit(ScriptNode);
	public void visit(TokenizerNode);
	public void visit(ParserNode);
	public void visit(PatternNode);
	public void visit(RuleNode);
	public void visit(PEGSwitchingNode);
	public void visit(PEGSequentialNode);
	public void visit(PEGLoopQualifiedNode);
	public void visit(PEGSkippableNode);
	public void visit(PEGActionNode);
	public void visit(PEGElementNode);

	public final void visit(NodeBase){ assert(false); }
	public final void visit(PEGNodeBase){ assert(false); }
}

interface IAcceptor
{
	public void accept(IVisitor visitor);
}

mixin template DefaultAcceptorImpl()
{
	public override void accept(IVisitor visitor){ visitor.visit(this); }
}
