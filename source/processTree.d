module com.cterm2.tpeg.processTree;

// Process Trees

import com.cterm2.tpeg.visitor;
import com.cterm2.tpeg.tree;
import std.string, std.conv, std.algorithm, std.range;

abstract class ProcessTreeBase : IProcessTreeAcceptor
{
    mixin DefaultProcessTreeAcceptorImpl;
}
class ReferenceRange : ProcessTreeBase
{
    string current_reference;
    ProcessTreeBase[] inner_trees;

    public @property currentReference(){ return this.current_reference; }
    public @property innerTrees(){ return this.inner_trees; }

    public this(string cr, ProcessTreeBase[] its)
    {
        this.current_reference = cr;
        this.inner_trees = its;
    }

    mixin DefaultProcessTreeAcceptorImpl;
}
class Loop : ProcessTreeBase
{
    string restraint_name;
    ProcessTreeBase[] inner_trees;

    public @property restraintName(){ return this.restraint_name; }
    public @property innerTrees(){ return this.inner_trees; }

    public this(string rn, ProcessTreeBase[] its)
    {
        this.restraint_name = rn;
        this.inner_trees = its;
    }

    mixin DefaultProcessTreeAcceptorImpl;
}
class HasValueReferenceRange : ProcessTreeBase
{
    string current_reference;
    uint reference_at;
    ProcessTreeBase[] inner_trees;

    public @property currentReference(){ return this.current_reference; }
    public @property referenceAt(){ return this.reference_at; }
    public @property innerTrees(){ return this.inner_trees; }

    public this(string cr, uint ra, ProcessTreeBase[] its)
    {
        this.current_reference = cr;
        this.reference_at = ra;
        this.inner_trees = its;
    }

    mixin DefaultProcessTreeAcceptorImpl;
}
class TokenConditionalReferenceRange : ProcessTreeBase
{
    string token_type;
    string current_reference;
    ProcessTreeBase[] inner_trees;

    public @property tokenType(){ return this.token_type; }
    public @property currentReference(){ return this.current_reference; }
    public @property innerTrees(){ return this.inner_trees; }

    public this(string tt, string cr, ProcessTreeBase[] its)
    {
        this.token_type = tt;
        this.current_reference = cr;
        this.inner_trees = its;
    }

    mixin DefaultProcessTreeAcceptorImpl;
}
class RuleConditionalReferenceRange : ProcessTreeBase
{
    string rule_name;
    string current_reference;
    ProcessTreeBase[] inner_trees;

    public @property ruleName(){ return this.rule_name; }
    public @property currentReference(){ return this.current_reference; }
    public @property innerTrees(){ return this.inner_trees; }

    public this(string rn, string cr, ProcessTreeBase[] its)
    {
        this.rule_name = rn;
        this.current_reference = cr;
        this.inner_trees = its;
    }

    mixin DefaultProcessTreeAcceptorImpl;
}
class PartialConditionalReferenceRange : ProcessTreeBase
{
    uint partial_ordinal;
    string current_reference;
    ProcessTreeBase[] inner_trees;

    public @property partialOrdinal(){ return this.partial_ordinal; }
    public @property currentReference(){ return this.current_reference; }
    public @property innerTrees(){ return this.inner_trees; }

    public this(uint po, string cr, ProcessTreeBase[] its)
    {
        this.partial_ordinal = po;
        this.current_reference = cr;
        this.inner_trees = its;
    }

    mixin DefaultProcessTreeAcceptorImpl;
}
class SwitchingGroup : ProcessTreeBase
{
    ProcessTreeBase[] inner_trees;

    public @property innerTrees(){ return this.inner_trees; }

    public this(ProcessTreeBase[] its)
    {
        this.inner_trees = its;
    }

    mixin DefaultProcessTreeAcceptorImpl;
}
class Binder : ProcessTreeBase
{
    string binder_name;
    PEGElementNode _target;

    public @property binderName(){ return this.binder_name; }
    public @property target(){ return this._target; }

    public this(string bn, PEGElementNode t)
    {
        this.binder_name = bn;
        this._target = t;
    }

    mixin DefaultProcessTreeAcceptorImpl;
}
class Action : ProcessTreeBase
{
    string action_string;

    public @property actionString(){ return this.action_string; }

    public this(string as)
    {
        this.action_string = as;
    }

    mixin DefaultProcessTreeAcceptorImpl;
}

enum EnumCurrentState
{
    None, GenerateSwitchingConditionalReferenceRange
}

class ProcessTreeGenerator : IVisitor
{
    ProcessTreeBase[] generatedTree;
    uint loopOrdinal = 0;
    EnumCurrentState currentState;
    bool err;

    public @property hasError(){ return this.err; }

    public void entry(ScriptNode n)
    {
        this.generatedTree = null;
        this.loopOrdinal = 0;
        this.currentState = EnumCurrentState.None;
        this.err = false;
        n.accept(this);
    }

    // IVisitor //
	public void visit(ScriptNode node)
    {
        if(node.parser) node.parser.accept(this);
    }
	public void visit(TokenizerNode node)
    {
        assert(false);
    }
	public void visit(ParserNode node)
    {
        foreach(n; node.rules) n.accept(this);
    }
	public void visit(PatternNode node)
    {
        assert(false);
    }
	public void visit(RuleNode node)
    {
        node.ruleBody.accept(this);
        node.process = new ReferenceRange("content", this.generatedTree);
        //scope auto pd = new ProcessTreeDumper();
        //node.process.accept(pd);
    }
	public void visit(PEGSwitchingNode node)
    {
        switch(this.currentState)
        {
        case EnumCurrentState.GenerateSwitchingConditionalReferenceRange:
            this.generatedTree = [new PartialConditionalReferenceRange(node.complexRuleOrdinal, "child[0]", this.generatedTree)];
            break;
        case EnumCurrentState.None:
            {
                ProcessTreeBase[] trees;
                foreach(n; node.nodes)
                {
                    n.accept(this);

                    if(this.generatedTree != null)
                    {
                        this.currentState = EnumCurrentState.GenerateSwitchingConditionalReferenceRange;
                        n.accept(this);
                        if(this.generatedTree != null) trees ~= this.generatedTree;
                        this.currentState = EnumCurrentState.None;
                    }
                }
                this.generatedTree = [new SwitchingGroup(trees)];
            }
            break;
        default: break;
        }
    }
	public void visit(PEGSequentialNode node)
    {
        switch(this.currentState)
        {
        case EnumCurrentState.GenerateSwitchingConditionalReferenceRange:
            this.generatedTree = [new PartialConditionalReferenceRange(node.complexRuleOrdinal, "child[0]", this.generatedTree)];
            break;
        case EnumCurrentState.None:
            {
                ProcessTreeBase[] trees;

                foreach(i, n; node.nodes)
                {
                    n.accept(this);
                    if(this.generatedTree != null) trees ~= new ReferenceRange("child[" ~ i.to!string ~ "]", this.generatedTree);
                }
                this.generatedTree = trees;
            }
            break;
        default: break;
        }
    }
	public void visit(PEGLoopQualifiedNode node)
    {
        switch(this.currentState)
        {
        case EnumCurrentState.GenerateSwitchingConditionalReferenceRange:
            this.generatedTree = [new PartialConditionalReferenceRange(node.complexRuleOrdinal, "child[0]", this.generatedTree)];
            break;
        case EnumCurrentState.None:
            node.inner.accept(this);
            this.generatedTree = [new Loop("n" ~ this.loopOrdinal.to!string, this.generatedTree)];
            break;
        default: break;
        }
    }
	public void visit(PEGSkippableNode node)
    {
        switch(this.currentState)
        {
        case EnumCurrentState.GenerateSwitchingConditionalReferenceRange:
            this.generatedTree = [new PartialConditionalReferenceRange(node.complexRuleOrdinal, "child[0]", this.generatedTree)];
            break;
        case EnumCurrentState.None:
            node.inner.accept(this);
            this.generatedTree = [new ReferenceRange("child[0]", [new HasValueReferenceRange("child", 0, this.generatedTree)])];
            break;
        default: break;
        }
    }
	public void visit(PEGActionNode node)
    {
        switch(this.currentState)
        {
        case EnumCurrentState.GenerateSwitchingConditionalReferenceRange:
            std.stdio.writeln("Error: Action-only switching is not allowed.");
            this.err = true;
            this.generatedTree = null;
            break;
        case EnumCurrentState.None:
            this.generatedTree = [new Action(node.actionString)];
            break;
        default: break;
        }
    }
	public void visit(PEGElementNode node)
    {
        switch(this.currentState)
        {
        case EnumCurrentState.GenerateSwitchingConditionalReferenceRange:
            if(node.isRule)
            {
                this.generatedTree = [new RuleConditionalReferenceRange(node.elementName, "child[0]", this.generatedTree)];
            }
            else
            {
                this.generatedTree = [new TokenConditionalReferenceRange(node.elementName, "child[0]", this.generatedTree)];
            }
            break;
        case EnumCurrentState.None:
            if(node.isBinded)
            {
                this.generatedTree = [new Binder(node.binderName, node)];
            }
            else this.generatedTree = null;
            break;
        default: break;
        }
    }
}

interface IProcessTreeVisitor
{
    public void visit(ReferenceRange);
    public void visit(Loop);
    public void visit(HasValueReferenceRange);
    public void visit(TokenConditionalReferenceRange);
    public void visit(RuleConditionalReferenceRange);
    public void visit(PartialConditionalReferenceRange);
    public void visit(SwitchingGroup);
    public void visit(Binder);
    public void visit(Action);

    public final void visit(ProcessTreeBase){ assert(false); }
    public final void visit(IProcessTreeAcceptor){ assert(false); }
}
interface IProcessTreeAcceptor
{
    public void accept(IProcessTreeVisitor);
}

template DefaultProcessTreeAcceptorImpl()
{
    public override void accept(IProcessTreeVisitor v){ v.visit(this); }
}

class ProcessTreeDumper : IProcessTreeVisitor
{
    int indentLevel = 0;
    @property indentStr(){ return " ".repeat(indentLevel).join(); }

    private void printClass(T)(T d)
    {
        std.stdio.writeln(indentStr, typeid(T));
    }
    private void printValue(T)(string name, lazy T value)
    {
        std.stdio.writeln(indentStr, name, ": ", value());
    }

    public void visit(ReferenceRange node)
    {
        printClass(node);
        indentLevel++;
        printValue("currentReference", node.currentReference);
        std.stdio.writeln(indentStr, "innerNodes: ");
        indentLevel++;
        foreach(n; node.innerTrees) n.accept(this);
        indentLevel--;
        indentLevel--;
    }
    public void visit(Loop node)
    {
        printClass(node);
        indentLevel++;
        printValue("restraintName", node.restraintName);
        std.stdio.writeln(indentStr, "innerNodes: ");
        indentLevel++;
        foreach(n; node.innerTrees) n.accept(this);
        indentLevel--;
        indentLevel--;
    }
    public void visit(HasValueReferenceRange node)
    {
        printClass(node);
        indentLevel++;
        printValue("referenceIndex", node.referenceAt);
        printValue("currentReference", node.currentReference);
        std.stdio.writeln(indentStr, "innerNodes: ");
        indentLevel++;
        foreach(n; node.innerTrees) n.accept(this);
        indentLevel--;
        indentLevel--;
    }
    public void visit(TokenConditionalReferenceRange node)
    {
        printClass(node);
        indentLevel++;
        printValue("tokenType", node.tokenType);
        printValue("currentReference", node.currentReference);
        std.stdio.writeln(indentStr, "innerNodes: ");
        indentLevel++;
        foreach(n; node.innerTrees) n.accept(this);
        indentLevel--;
        indentLevel--;
    }
    public void visit(RuleConditionalReferenceRange node)
    {
        printClass(node);
        indentLevel++;
        printValue("ruleName", node.ruleName);
        printValue("currentReference", node.currentReference);
        std.stdio.writeln(indentStr, "innerNodes: ");
        indentLevel++;
        foreach(n; node.innerTrees) n.accept(this);
        indentLevel--;
        indentLevel--;
    }
    public void visit(PartialConditionalReferenceRange node)
    {
        printClass(node);
        indentLevel++;
        printValue("ordinal", node.partialOrdinal);
        printValue("currentReference", node.currentReference);
        std.stdio.writeln(indentStr, "innerNodes: ");
        indentLevel++;
        foreach(n; node.innerTrees) n.accept(this);
        indentLevel--;
        indentLevel--;
    }
    public void visit(SwitchingGroup node)
    {
        printClass(node);
        indentLevel++;
        std.stdio.writeln(indentStr, "innerNodes: ");
        indentLevel++;
        foreach(n; node.innerTrees) n.accept(this);
        indentLevel--;
        indentLevel--;
    }
    public void visit(Binder node)
    {
        printClass(node);
        indentLevel++;
        printValue("binderName", node.binderName);
        printValue("target.elementName", node.target.elementName ~ "(" ~ (node.target.isRule ? "rule" : "token") ~ ")");
        indentLevel--;
    }
    public void visit(Action node)
    {
        printClass(node);
        indentLevel++;
        printValue("actionString", node.actionString);
        indentLevel--;
    }
}
