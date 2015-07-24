module com.cterm2.tpeg.tree;

import std.string, std.range, std.array;
import com.cterm2.tpeg.scriptParser;
import com.cterm2.tpeg.visitor;

public abstract class NodeBase : IAcceptor
{
	Location loc;
	public @property location(){ return this.loc; }
	public this(Location l){ this.loc = l; }

	mixin DefaultAcceptorImpl;
}

public class ScriptNode : NodeBase
{
	string[] package_name;
	TokenizerNode _tokenizer;
	ParserNode _parser;

	public @property packageName(){ return this.package_name; }
	public @property tokenizer(){ return this._tokenizer; }
	public @property parser(){ return this._parser; }

	public this(Location l, string[] pn, TokenizerNode tk, ParserNode ps)
	{
		super(l);
		this.package_name = pn;
		this._tokenizer = tk;
		this._parser = ps;
	}

	mixin DefaultAcceptorImpl;
}
public class TokenizerNode : NodeBase
{
	string module_name;
	PatternNode[] skip_patterns;
	PatternNode[] _patterns;

	public @property moduleName(){ return this.module_name; }
	public @property skipPatterns(){ return this.skip_patterns; }
	public @property patterns(){ return this._patterns; }

	public this(Location l, string mn, PatternNode[] sp, PatternNode[] pts)
	{
		super(l);
		this.module_name = mn;
		this.skip_patterns = sp;
		this._patterns = pts;
	}

	mixin DefaultAcceptorImpl;
}
public class PatternNode : NodeBase
{
	string token_name;
	string pattern_string;
	bool is_regex;

	public @property tokenName(){ return this.token_name; }
	public @property patternString(){ return this.pattern_string; }
	public @property isRegex(){ return this.is_regex; }

	public this(Location l, string tn, string ps, bool rx)
	{
		super(l);
		this.token_name = tn;
		this.pattern_string = ps;
		this.is_regex = rx;
	}
	public this(Location l, string ps, bool rx)
	{
		super(l);
		this.token_name = null;
		this.pattern_string = ps;
		this.is_regex = rx;
	}

	mixin DefaultAcceptorImpl;
}

public class ParserNode : NodeBase
{
	string module_name;
	string header_part;
	string start_rule_name;
	RuleNode[] _rules;

	public @property moduleName(){ return this.module_name; }
	public @property headerPart(){ return this.header_part; }
	public @property startRuleName(){ return this.start_rule_name; }
	public @property rules(){ return this._rules; }

	public this(Location l, string mn, string hp, string srn, RuleNode[] rls)
	{
		super(l);
		this.module_name = mn;
		this.header_part = hp;
		this.start_rule_name = srn;
		this._rules = rls;
	}

	mixin DefaultAcceptorImpl;
}
public class RuleNode : NodeBase
{
	string rule_name;
	string type_name;
	PEGNodeBase rule_body;

	public @property ruleName(){ return this.rule_name; }
	public @property typeName(){ return this.type_name; }
	public @property ruleBody(){ return this.rule_body; }

	public this(Location l, string rn, string tn, PEGNodeBase rb)
	{
		super(l);
		this.rule_name = rn;
		this.type_name = tn;
		this.rule_body = rb;
	}

	mixin DefaultAcceptorImpl;
}

public abstract class PEGNodeBase : NodeBase
{
	public this(Location l){ super(l); }

	mixin DefaultAcceptorImpl;
}
public class PEGSwitchingNode : PEGNodeBase
{
	PEGNodeBase[] _nodes;

	public @property nodes(){ return this._nodes; }

	public this(PEGNodeBase[] nds)
	{
		super(nds[0].location);
		this._nodes = nds;
	}

	mixin DefaultAcceptorImpl;
}
public class PEGSequentialNode : PEGNodeBase
{
	PEGNodeBase[] _nodes;

	public @property nodes(){ return this._nodes; }

	public this(PEGNodeBase[] nds)
	{
		super(nds[0].location);
		this._nodes = nds;
	}

	mixin DefaultAcceptorImpl;
}
public class PEGLoopQualifiedNode : PEGNodeBase
{
	PEGNodeBase _inner;
	bool is_required_least_one;

	public @property inner(){ return this._inner; }
	public @property isRequiredLeastOne(){ return this.is_required_least_one; }

	public this(PEGNodeBase node, bool irlo)
	{
		super(node.location);
		this._inner = node;
		this.is_required_least_one = irlo;
	}

	mixin DefaultAcceptorImpl;
}
public class PEGSkippableNode : PEGNodeBase
{
	PEGNodeBase _inner;

	public @property inner(){ return this._inner; }

	public this(Location l, PEGNodeBase node)
	{
		super(l);
		this._inner = node;
	}

	mixin DefaultAcceptorImpl;
}
public class PEGActionNode : PEGNodeBase
{
	string action_string;

	public @property actionString(){ return this.action_string; }

	public this(Location l, string as)
	{
		super(l);
		this.action_string = as;
	}

	mixin DefaultAcceptorImpl;
}
public class PEGElementNode : PEGNodeBase
{
	string element_name;
	string binder_name;
	bool is_rule;

	public @property elementName(){ return this.element_name; }
	public @property binderName(){ return this.binder_name; }
	public @property isBinded(){ return !this.binder_name.empty; }
	public @property isRule(){ return this.is_rule; }

	public void toRuleElement(){ this.is_rule = true; }
	public void toPatternElement(){ this.is_rule = false; }

	public this(Location l, string en, string bn)
	{
		super(l);
		this.element_name = en;
		this.binder_name = bn;
		this.is_rule = false;
	}

	mixin DefaultAcceptorImpl;
}