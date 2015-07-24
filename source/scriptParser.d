module com.cterm2.tpeg.scriptParser;

import std.string, std.file, std.stdio, std.array, std.range, std.algorithm, std.conv;
import std.regex;

import com.cterm2.tpeg.tree;

struct Location
{
	int line = 1;

	public string toString(){ return this.line.to!string; }
}

public class ParseError : Exception
{
	public this(string msg, Location l)
	{
		super(msg ~ " at line " ~ l.toString);
	}
}

public class ScriptParser
{
	string fileData;
	string parsingRange;
	Location loc;
	static rIdentifier = ctRegex!r"[A-Za-z_][A-Za-z0-9_]*";
	string[string] idstock;

	public this(string path)
	{
		this.fileData = readText(path);
	}
	public ScriptNode run()
	{
		this.parsingRange = fileData[];
		this.loc.line = 1;

		auto enterLocation = this.loc;
		string[] packname;
		TokenizerNode tokenizer;
		ParserNode parser;

		this.skipIgnores;
		if(this.getIdentifier == "package") packname = this.parsePackage;
		while(true)
		{
			if(this.getIdentifier == "tokenizer")
			{
				if(tokenizer !is null)
				{
					writeln("Warning: double tokenizer found. used last one.");
				}
				tokenizer = this.enterTokenizerBlock;
				this.skipIgnores;
			}
			else if(this.getIdentifier == "parser")
			{
				if(parser !is null)
				{
					writeln("Warning: double parser found. used last one.");
				}
				parser = this.enterParserBlock;
				this.skipIgnores;
			}
			else break;
		}
		if(!this.parsingRange.empty) throw new ParseError("unterm script", this.loc);

		return new ScriptNode(enterLocation, packname, tokenizer, parser);
	}

	private string[] parsePackage()
	{
		if(this.getIdentifier != "package") throw new ParseError("Required \"package\"", this.loc);
		this.dropIdentifier("package");
		this.skipIgnores;

		string[] packlist;
		auto first_pack = this.getIdentifier;
		if(first_pack.empty) throw new ParseError("Required package name", this.loc);
		this.dropIdentifier(first_pack);
		packlist ~= first_pack;
		this.skipIgnores;
		while(!this.parsingRange.empty && this.parsingRange.front == '.')
		{
			this.parsingRange = this.parsingRange.drop(1);
			this.skipIgnores;
			auto second_pack = this.getIdentifier;
			if(second_pack.empty) throw new ParseError("Required package name", this.loc);
			this.dropIdentifier(second_pack);
			packlist ~= second_pack;
			this.skipIgnores;
		}

		return packlist;
	}
	private TokenizerNode enterTokenizerBlock()
	{
		auto enterLocation = this.loc;

		if(this.getIdentifier != "tokenizer") throw new ParseError("Required \"tokenizer\"", this.loc);
		this.dropIdentifier("tokenizer");
		this.skipIgnores;
		this.checkCharacter!'{';
		this.skipIgnores;

		string module_name = "tokenizer";
		PatternNode[] skip_patterns;
		PatternNode[] patterns;

		// body
		while(true)
		{
			if(this.getIdentifier == "module")
			{
				module_name = this.parseModuleName;
				this.skipIgnores;
			}
			else if(this.getIdentifier == "skip_pattern")
			{
				auto patLocation = this.loc;
				auto skip_pattern = this.parseSkipPattern;
				writeln("skip_pattern = r\"", skip_pattern, "\"");
				if(skip_pattern.front == '"' && skip_pattern.back == '"')
				{
					skip_patterns ~= new PatternNode(patLocation, skip_pattern[1 .. $ - 1], false);
				}
				else
				{
					skip_patterns ~= new PatternNode(patLocation, skip_pattern, true);
				}
				this.skipIgnores;
			}
			else if(this.getIdentifier == "patterns")
			{
				patterns = this.enterPatternsBlock();
				this.skipIgnores;
			}
			else break;
		}

		this.checkCharacter!'}';
		return new TokenizerNode(enterLocation, module_name, skip_patterns, patterns);
	}
	private ParserNode enterParserBlock()
	{
		auto enterLocation = this.loc;

		if(this.getIdentifier != "parser") throw new ParseError("Required \"parser\"", this.loc);
		this.dropIdentifier("parser");
		this.skipIgnores;
		this.checkCharacter!'{';
		this.skipIgnores;

		string module_name = "parser";
		string[] header_parts;
		string start_rule_name = "";
		RuleNode[] rules;

		// body
		while(true)
		{
			if(this.getIdentifier == "module")
			{
				module_name = this.parseModuleName;
				this.skipIgnores;
			}
			else if(this.getIdentifier == "header")
			{
				auto header_mixins = this.parseHeader;
				writeln("header mixins: \n", header_mixins);
				header_parts ~= header_mixins;
				this.skipIgnores;
			}
			else if(this.getIdentifier == "start_rule")
			{
				start_rule_name = this.parseStartRule;
				writeln("parser: start_rule: ", start_rule_name);
				this.skipIgnores;
			}
			else if(this.getIdentifier == "rules")
			{
				rules = this.parseRules;
				this.skipIgnores;
			}
			else break;
		}

		this.checkCharacter!'}';
		if(start_rule_name.empty && !rules.empty) start_rule_name = rules.front.ruleName;
		return new ParserNode(enterLocation, module_name, header_parts.join("\n"), start_rule_name, rules);
	}

	private string parseModuleName()
	{
		if(this.getIdentifier != "module") throw new ParseError("Required \"module\"", this.loc);
		this.dropIdentifier("module");
		this.skipIgnores;
		auto str = this.getIdentifier;
		if(str.empty) throw new ParseError("Required module name", this.loc);
		this.dropIdentifier(str);
		return str;
	}
	private string parseSkipPattern()
	{
		if(this.getIdentifier != "skip_pattern") throw new ParseError("Required \"skip_pattern\"", this.loc);
		this.dropIdentifier("skip_pattern");
		this.skipSpaces;

		auto str = this.getStringToLF;
		return str;
	}
	private PatternNode[] enterPatternsBlock()
	{
		if(this.getIdentifier != "patterns") throw new ParseError("Required \"Patterns\"", this.loc);
		this.dropIdentifier("patterns");
		this.skipIgnores;
		this.checkCharacter!'{';
		this.skipIgnores;

		// body
		PatternNode[] nodes;
		while(!this.parsingRange.empty && this.parsingRange.front != '}')
		{
			auto enterLocation = this.loc;

			auto token_name = this.getIdentifier;
			if(token_name.empty) throw new ParseError("Required token name", this.loc);
			this.dropIdentifier(token_name);
			this.skipSpaces;
			auto pattern = this.getStringToLF;
			if(pattern.front == '"' && pattern.back == '"')
			{
				writeln("pattern registered: ", token_name, " = ", pattern, " (exactly match)");
				nodes ~= new PatternNode(enterLocation, token_name, pattern[1 .. $ - 1], false);
			}
			else
			{
				writeln("pattern registered: ", token_name, " = r\"", pattern, "\"");
				nodes ~= new PatternNode(enterLocation, token_name, pattern, true);
			}
			this.skipIgnores;
		}

		this.checkCharacter!'}';
		return nodes;
	}
	private string parseHeader()
	{
		if(this.getIdentifier != "header") throw new ParseError("Required \"header\"", this.loc);
		this.dropIdentifier("header");
		this.skipIgnores;
		this.checkCharacter!'{';
		if(!this.parsingRange.empty && this.parsingRange.front == '\n')
		{
			this.parsingRange = this.parsingRange.drop(1);
			this.loc.line++;
		}

		string mixins;
		while(!this.parsingRange.empty && this.parsingRange.front != '}')
		{
			if(this.parsingRange.front == '\n')
			{
				this.loc.line++;
			}
			mixins ~= this.parsingRange.front;
			this.parsingRange = this.parsingRange.drop(1);
		}
		while(!mixins.empty && [' ', '\t', '\r', '\n'].any!(a => a == mixins.back)) mixins.popBack;

		this.checkCharacter!'}';
		return mixins;
	}
	private string parseStartRule()
	{
		if(this.getIdentifier != "start_rule") throw new ParseError("Required \"start_rule\"", this.loc);
		this.dropIdentifier("start_rule");
		this.skipIgnores;
		auto rule_name = this.getIdentifier;
		if(rule_name.empty) throw new ParseError("Required rule name", this.loc);
		this.dropIdentifier(rule_name);
		return rule_name;
	}
	private RuleNode[] parseRules()
	{
		if(this.getIdentifier != "rules") throw new ParseError("Required \"rules\"", this.loc);
		this.dropIdentifier("rules");
		this.skipIgnores;
		this.checkCharacter!'{';
		this.skipIgnores;

		// body
		RuleNode[] rules;
		while(true)
		{
			string type_name = "auto";
			auto enterLocation = this.loc;

			auto rule_name = this.getIdentifier;
			if(rule_name.empty) break;
			this.dropIdentifier(rule_name);
			this.skipIgnores;
			if(this.parsingRange.front == '<')
			{
				// return type
				this.parsingRange = this.parsingRange.drop(1);
				type_name = "";
				while(!this.parsingRange.empty && this.parsingRange.front != '>')
				{
					if(this.parsingRange.front == '\n')
					{
						this.loc.line++;
					}
					type_name ~= this.parsingRange.front;
					this.parsingRange = this.parsingRange.drop(1);
				}
				this.checkCharacter!'>';
				this.skipIgnores;
			}
			this.checkCharacter!'=';
			this.skipIgnores;
			auto peg_node = this.parsePEG;
			this.skipIgnores;
			this.checkCharacter!';';
			this.skipIgnores;

			rules ~= new RuleNode(enterLocation, rule_name, type_name, peg_node);
			writeln("parser: rule found: ", rule_name, type_name != "auto" ? " with value type " ~ type_name : "");
		}

		this.checkCharacter!'}';
		return rules;
	}
	private PEGNodeBase parsePEG()
	{
		// core procedure of parsing PEG(Parsing Expression Grammar)
		if(this.parsingRange.front == '(')
		{
			return this.parsePEGSingle;
		}
		else
		{
			return this.parsePEGSwitch;
		}
	}
	private PEGNodeBase parsePEGSwitch()
	{
		// switching grammar
		auto nodes = [this.parsePEGSequential];
		this.skipIgnores;
		while(!this.parsingRange.empty && this.parsingRange.front == '/')
		{
			this.parsingRange = this.parsingRange.drop(1);
			this.skipIgnores;
			nodes ~= this.parsePEGSequential;
			this.skipIgnores;
		}

		if(nodes.length == 1) return nodes[0];
		else return new PEGSwitchingNode(nodes);
	}
	private PEGNodeBase parsePEGSequential()
	{
		// sequential grammar
		auto nodes = [this.parsePEGSingle];
		this.skipIgnores;
		while(!this.parsingRange.empty &&
			(this.parsingRange.front == '(' || this.parsingRange.front == '[' || this.parsingRange.front == '{' || !this.getIdentifier.empty))
		{
			nodes ~= this.parsePEGSingle;
			this.skipIgnores;
		}

		if(nodes.length == 1) return nodes[0];
		else return new PEGSequentialNode(nodes);
	}
	private PEGNodeBase parsePEGSingle()
	{
		// single/grouped object
		PEGNodeBase baseNode;

		if(this.parsingRange.front == '(')
		{
			// prevail
			this.parsingRange = this.parsingRange.drop(1);
			this.skipIgnores;
			baseNode = this.parsePEG;
			this.skipIgnores;
			this.checkCharacter!')';
		}
		else if(this.parsingRange.front == '[')
		{
			// omit
			auto enterLocation = this.loc;

			this.parsingRange = this.parsingRange.drop(1);
			this.skipIgnores;
			auto node = this.parsePEG;
			this.skipIgnores;
			this.checkCharacter!']';

			return new PEGSkippableNode(enterLocation, node);
		}
		else if(this.parsingRange.front == '{')
		{
			// action
			auto enterLocation = this.loc;

			this.parsingRange = this.parsingRange.drop(1);
			string action_str;
			while(!this.parsingRange.empty && this.parsingRange.front != '}')
			{
				if(this.parsingRange.front == '\n')
				{
					this.loc.line++;
				}
				action_str ~= this.parsingRange.front;
				this.parsingRange = this.parsingRange.drop(1);
			}
			this.checkCharacter!'}';

			return new PEGActionNode(enterLocation, action_str);
		}
		else
		{
			baseNode = this.parsePEGElement;
		}

		this.skipIgnores;
		switch(this.parsingRange.front)
		{
		case '+':
			this.parsingRange = this.parsingRange.drop(1);
			return new PEGLoopQualifiedNode(baseNode, true);
		case '*':
			this.parsingRange = this.parsingRange.drop(1);
			return new PEGLoopQualifiedNode(baseNode, false);
		default: return baseNode;
		}
	}
	private auto parsePEGElement()
	{
		// element of peg
		auto enterLocation = this.loc;
		string bind_name;

		auto ref_name = this.getIdentifier;
		if(ref_name.empty) throw new ParseError("Required Rule or Token name", this.loc);
		this.dropIdentifier(ref_name);
		this.skipIgnores;
		if(this.parsingRange.front == ':')
		{
			// binding to local variable
			this.parsingRange = this.parsingRange.drop(1);
			this.skipIgnores;
			bind_name = this.getIdentifier;
			if(bind_name.empty) throw new ParseError("Required binder name", this.loc);
			this.dropIdentifier(bind_name);
			this.skipIgnores;
		}

		return new PEGElementNode(enterLocation, ref_name, bind_name);
	}

	private void skipIgnores()
	{
		while(this.skipSpaces || this.skipComment){}
	}
	private bool skipSpaces()
	{
		bool parsed = false;
		while(!this.parsingRange.empty &&
			[' ', '\r', '\n', '\t'].any!(a => a == this.parsingRange.front))
		{
			if(this.parsingRange.front == '\n')
			{
				this.loc.line++;
			}
			this.parsingRange = this.parsingRange.drop(1);
			parsed = true;
		}
		return parsed;
	}
	private bool skipComment()
	{
		if(!this.parsingRange.empty && this.parsingRange.front == '#')
		{
			while(!this.parsingRange.empty && this.parsingRange.front != '\n') this.parsingRange = this.parsingRange.drop(1);
			return true;
		}
		return false;
	}
	private string getIdentifier()
	{
		if(this.parsingRange in this.idstock) return this.idstock[this.parsingRange];

		if(this.parsingRange.empty)
		{
			this.idstock[this.parsingRange] = null;
			return null;
		}

		auto match = this.parsingRange.matchFirst(rIdentifier);
		if(match.empty || !match.pre.empty)
		{
			this.idstock[this.parsingRange] = null;
			return null;
		}
		this.idstock[this.parsingRange] = match.hit;
		return match.hit;
	}
	private void dropIdentifier(string p)
	{
		this.parsingRange = this.parsingRange.drop(p.length);
	}
	private string getStringToLF()
	{
		string st;
		while(!this.parsingRange.empty && this.parsingRange.front != '\n')
		{
			st ~= this.parsingRange.front;
			this.parsingRange = this.parsingRange.drop(1);
		}
		return st;
	}
	private void checkCharacter(char c)()
	{
		if(this.parsingRange.empty || this.parsingRange.front != c) throw new ParseError("Required " ~ c, this.loc);
		this.parsingRange = this.parsingRange.drop(1);
	}
}
