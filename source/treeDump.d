module com.cterm2.tpeg.treeDump;

import com.cterm2.tpeg.tree;
import com.cterm2.tpeg.visitor;
import std.string, std.array, std.range, std.algorithm, std.conv, std.stdio;

class TreeDump : IVisitor
{
	uint indent = 0;
	bool requireIndent = true;

	private void print(T...)(T elm)
	{
		foreach(e; elm)
		{
			if(this.requireIndent)
			{
				this.printIndent();
				this.requireIndent = false;
			}
			static if(is(typeof(e) == string))
			{
				if(e.back == '\n') this.requireIndent = true;
			}
			write(e);
		}
	}
	private void println(T...)(T elm){ this.print(elm, "\n"); }
	private void printIndent()
	{
		for(uint i = 0; i < this.indent; i++) write("  ");
	}
	private void printAttribute(AttrT)(string attrName, AttrT attr)
	{
		static if(is(AttrT == string))
		{
			if(attr !is null)
			{
				this.println(attrName, ": ", attr);
			}
		}
		else static if(is(AttrT T : T[]))
		{
			foreach(i, att; attr)
			{
				this.printAttribute(attrName ~ " #" ~ i.to!string, att);
			}
		}
		else static if(is(AttrT : IAcceptor))
		{
			if(attr !is null)
			{
				this.print(attrName, ": ");
				attr.accept(this);
			}
		}
		else
		{
			this.println(attrName, ": ", attr);
		}
	}

	public void dump(ScriptNode node)
	{
		node.accept(this);
	}

	public override void visit(ScriptNode node)
	{
		this.println("ScriptNode");

		with(node)
		{
			this.indent++;
			scope(exit) this.indent--;

			this.printAttribute("packageName", packageName.join("."));
			this.printAttribute("tokenizer", tokenizer);
			this.printAttribute("parser", parser);
		}
	}
	public override void visit(TokenizerNode node)
	{
		this.println("TokenizerNode");

		with(node)
		{
			this.indent++;
			scope(exit) this.indent--;

			this.printAttribute("moduleName", moduleName);
			this.printAttribute("skipPatterns", skipPatterns);
			this.printAttribute("patterns", patterns);
			foreach(s, p; specializes)
			{
				this.printAttribute("Specialize Pattern for " ~ s, p);
			}
		}
	}
	public override void visit(ParserNode node)
	{
		this.println("ParserNode");

		with(node)
		{
			this.indent++;
			scope(exit) this.indent--;

			this.printAttribute("moduleName", moduleName);
			this.printAttribute("headerPart", headerPart);
			this.printAttribute("startRuleName", startRuleName);
			this.printAttribute("rules", rules);
		}
	}
	public override void visit(PatternNode node)
	{
		this.println("PatternNode");

		with(node)
		{
			this.indent++;
			scope(exit) this.indent--;

			this.printAttribute("tokenName", tokenName);
			this.printAttribute("patternString", patternString);
		}
	}
	public override void visit(RuleNode node)
	{
		this.println("RuleNode");

		with(node)
		{
			this.indent++;
			scope(exit) this.indent--;

			this.printAttribute("ruleName", ruleName);
			this.printAttribute("typeName", typeName);
			this.printAttribute("ruleBody", ruleBody);
		}
	}
	public override void visit(PEGSwitchingNode node)
	{
		this.println("PEGSwitchingNode");

		with(node)
		{
			this.indent++;
			scope(exit) this.indent--;

			this.printAttribute("nodes", nodes);
		}
	}
	public override void visit(PEGSequentialNode node)
	{
		this.println("PEGSequentialNode");

		with(node)
		{
			this.indent++;
			scope(exit) this.indent--;

			this.printAttribute("nodes", nodes);
		}
	}
	public override void visit(PEGLoopQualifiedNode node)
	{
		this.println("PEGLoopQualifiedNode");

		with(node)
		{
			this.indent++;
			scope(exit) this.indent--;

			this.printAttribute("inner", inner);
			this.printAttribute("isRequiredLeastOne", isRequiredLeastOne);
		}
	}
	public override void visit(PEGSkippableNode node)
	{
		this.println("PEGSkippableNode");

		with(node)
		{
			this.indent++;
			scope(exit) this.indent--;

			this.printAttribute("inner", inner);
		}
	}
	public override void visit(PEGActionNode node)
	{
		this.println("PEGActionNode");

		with(node)
		{
			this.indent++;
			scope(exit) this.indent--;

			this.printAttribute("action_string", action_string);
		}
	}
	public override void visit(PEGElementNode node)
	{
		this.println("PEGElementNode");

		with(node)
		{
			this.indent++;
			scope(exit) this.indent--;

			this.printAttribute("elementName", elementName);
			this.printAttribute("binderName", binderName);
			this.printAttribute("isBinded", isBinded);
			this.printAttribute("isRule", isRule);
		}
	}
}
