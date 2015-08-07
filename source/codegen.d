module com.cterm2.tpeg.codegen;

import com.cterm2.tpeg.visitor;
import com.cterm2.tpeg.tree;
import std.stdio, std.path, std.file, std.algorithm, std.string;
import std.conv;

void writeProtection(File f, string name) in { assert(f.isOpen); } body
{
	import std.ascii, std.regex;
	if(!name.any!(a => a.isUpper)) f.writeln("\t", "public @property ", name, "(){ return this._", name, "; }");
	else
	{
		auto name_p = name.replaceAll!(s => "_" ~ std.string.toLower(s.hit))(regex(r"[A-Z]"));
		f.writeln("\t", "public @property ", name, "(){ return this.", name_p, "; }");
	}
}
void writeCtor(File f, string[string] args) in { assert(f.isOpen); } body
{
	string[] args_texts;
	foreach(t, a; args)
	{
		if(a is null) args_texts ~= t; else args_texts ~= t ~ " " ~ a;
	}
	auto args_text = args_texts.join(", ");
	f.writeln("\t", "public this(", args_text, ")");
}

void writeTokenClassDeclaration(File f) in { assert(f.isOpen); } body
{
	f.write(q{public struct Location
{
	uint line = 1, col = 1;

	public string toString(){ return this.line.to!string ~ ":" ~ this.col.to!string; }
}
public class Token
{
	Location _location;
	EnumTokenType _type;
	string _text;

	public @property location(){ return this._location; }
	public @property type(){ return this._type; }
	public @property text(){ return this._text; }

	public this(Location l, EnumTokenType t)
	{
		this._location = l;
		this._type = t;
	}
	public this(Location l, EnumTokenType t, string tx)
	{
		this(l, t);
		this._text = tx;
	}
}
public class TokenizeError : Exception
{
	public this(string err, Location loc){ super(err ~ " at " ~ loc.toString); }
}

// utility //
struct MatchStruct
{
	bool match;
	string matchStr;
	EnumTokenType itype;

	public @property length(){ return this.matchStr.length; }
}
auto matchExactly(string s, EnumTokenType t)(string parsingRange)
{
	return MatchStruct(parsingRange.startsWith(s), s, t);
}
auto matchRegex(alias rx, EnumTokenType t)(string parsingRange)
{
	auto match = parsingRange.matchFirst(rx);
	if(match.empty) return MatchStruct(false, "", t);
	return MatchStruct(match.pre.empty, match.hit, t);
}
});
}
void writeTokenizerSourceHeader(File f, string[] patternSymbols, string[] moduleNamePath)
in { assert(f.isOpen); } body
{
	f.writeln("module ", moduleNamePath.join("."), ";");
	f.writeln(q{
static import std.file;
import std.conv, std.algorithm, std.regex;
import std.array, std.range, std.exception;
});
	f.writeln(q{public enum EnumTokenType});
	f.writeln("{");
	string line_temp = "__SKIP_PATTERN__, ";
	foreach(t; patternSymbols)
	{
		if(line_temp.length >= 80-4)
		{
			f.writeln("\t", line_temp);
			line_temp = null;
		}
		line_temp ~= t ~ ", ";
	}
	f.writeln("\t", line_temp[0 .. $ - 2]);
	f.writeln("}");
	f.writeTokenClassDeclaration();
	f.writeln(q{
public auto tokenize(string filePath){ return tokenizeStr(std.file.readText(filePath)); }
});
}

void generateElementParser(File f) in { assert(f.isOpen); } body
{
	// generate template class in Grammar class

	f.writeln(q{	private class ElementParser(EnumTokenType ParseE)});
	f.writeln( "	{");
	f.writeln(q{		protected alias ResultType = Result!string;});
	f.writeln(q{		private static ResultType[TokenIterator] _memo;});
	f.writeln();
	f.writeln(q{		public static auto parse(TokenIterator r)});
	f.writeln( "		{");
	f.writeln(q{			if((r in this._memo) is null)});
	f.writeln( "			{");
	f.writeln( "				// register new result");
	f.writeln(q{				this._memo[r] = this.innerParse(r);});
	f.writeln( "			}");
	f.writeln();
	f.writeln(q{			return this._memo[r];});
	f.writeln( "		}");
	f.writeln();
	f.writeln(q{		private static auto innerParse(TokenIterator r)});
	f.writeln( "		{");
	f.writeln(q{			if(r.current.type == ParseE)});
	f.writeln( "			{");
	f.writeln(q{				return ResultType(true, TokenIterator(r.pos + 1, r.token), r.current.text);});
	f.writeln( "			}");
	f.writeln(q{			else});
	f.writeln( "			{");
	f.writeln(q{				return ResultType(false, r);});
	f.writeln( "			}");
	f.writeln( "		}");
	f.writeln( "	}");
}

enum EnumCurrentState
{
	None, GeneratePatternCtRegex, GeneratePatternMatchList,
	GenerateElementParsingStructures, GenerateActionInferer
}

class CodeGenerator : IVisitor
{
	string outdir = "tpeg_output";
	string[] packageName;
	File currentFile;
	uint skipPatternOrdinal;
	EnumCurrentState currentState;
	string matchListTemp;
	string[] parseClassDefinedList;
	int complexRuleCount = 0;
	int[string] complexRuleIdentifierTable;

	string lexerModuleName;

	public void entry(ScriptNode node)
	{
		this.currentState = EnumCurrentState.None;
		this.parseClassDefinedList = null;
		this.complexRuleIdentifierTable = null;
		this.complexRuleCount = 0;
		if(!exists(this.outdir) || !isDir(this.outdir))
		{
			mkdir(this.outdir);
		}

		node.accept(this);
	}

	// IVisitor //
	public void visit(ScriptNode node)
	{
		this.packageName = node.packageName;
		if(node.tokenizer !is null) this.lexerModuleName = node.tokenizer.moduleName;
		if(node.tokenizer !is null) node.tokenizer.accept(this);
		if(node.parser !is null) node.parser.accept(this);
	}
	public void visit(TokenizerNode node)
	{
		assert(!this.currentFile.isOpen);
		this.currentFile.open(buildPath(this.outdir, node.moduleName ~ ".d"), "w");
		this.currentFile.writeTokenizerSourceHeader(node.patternSymbols, this.packageName ~ node.moduleName);
		this.currentFile.writeln(q{public auto tokenizeStr(string fileData)});
		this.currentFile.writeln("{");
		this.currentFile.writeln(q{	auto parsingRange = fileData[];}, "\n");
		this.currentFile.writeln("\t", "// precompiled regex patterns //");
		this.currentState = EnumCurrentState.GeneratePatternCtRegex;
		foreach(i, n; node.skip_patterns)
		{
			this.skipPatternOrdinal = i + 1;
			n.accept(this);
		}
		foreach(n; node.patterns) n.accept(this);
		this.currentState = EnumCurrentState.None;
		this.currentFile.writeln();
		this.currentFile.writeln("\t", q{Token[] tokenList;});
		this.currentFile.writeln("\t", q{auto loc = Location();});
		this.currentFile.writeln("\t", q{while(!parsingRange.empty)});
		this.currentFile.writeln("\t{");
		this.currentFile.writeln("\t\t", q{auto matches = }, "[");
		this.currentState = EnumCurrentState.GeneratePatternMatchList;
		this.matchListTemp = "";
		foreach(i, n; node.skip_patterns)
		{
			this.skipPatternOrdinal = i + 1;
			n.accept(this);
		}
		foreach(n; node.patterns) n.accept(this);
		this.currentState = EnumCurrentState.None;
		this.currentFile.writeln(this.matchListTemp[0 .. $ - 3]);
		this.currentFile.writeln("\t\t", "].", q{filter!(a => a.match)}, ";");
		this.currentFile.writeln("\t\t", q{if(matches.empty) throw new TokenizeError("No match patterns", loc);});
		this.currentFile.writeln("\t\t", q{auto longest_match = matches.reduce!((a, b)
		{
			if(a.length == b.length) throw new TokenizeError("Conflicting patterns", loc);
			return a.length > b.length ? a : b;
		});});
		this.currentFile.writeln("\n", "\t\t", q{if(longest_match.itype != EnumTokenType.__SKIP_PATTERN__)
		{
			tokenList ~= new Token(loc, longest_match.itype, longest_match.matchStr);
		}
		auto lines = longest_match.matchStr.split(ctRegex!r"\n");
		foreach(a; lines[0 .. $ - 1])
		{
			loc.col = 1;
			loc.line++;
		}
		loc.col += lines[$ - 1].length;
		parsingRange = parsingRange.drop(longest_match.length);});
		this.currentFile.writeln("\t", "}");
		this.currentFile.writeln("\n", "\t", q{return tokenList.dup;});
		this.currentFile.writeln("}");
		this.currentFile.close();
	}
	public void visit(ParserNode node)
	{
		assert(!this.currentFile.isOpen);
		this.currentFile.open(buildPath(this.outdir, node.moduleName ~ ".d"), "w");
		this.currentFile.writeln("module ", (this.packageName ~ node.moduleName).join("."), ";");
		this.currentFile.writeln();
		this.currentFile.writeln("import ", (this.packageName ~ this.lexerModuleName).join("."), ";");
		this.currentFile.writeln("import std.traits;");
		this.currentFile.writeln();
		if(node.headerPart !is null)
		{
			this.currentFile.writeln("// header part from tpeg file //");
			this.currentFile.writeln(node.headerPart);
			this.currentFile.writeln();
		}
		with(this.currentFile)
		{
			writeln(q{struct TokenIterator});
			writeln("{");
			writeln(q{	size_t pos;});
			writeln(q{	Token[] token;});
			writeln();
			writeln(q{	size_t toHash() const @safe pure nothrow { return pos; }});
			writeln(q{	bool opEquals(ref const TokenIterator iter) const @safe pure nothrow});
			writeln("	{");
			writeln(q{		return pos == iter.pos && token.ptr == iter.token.ptr;});
			writeln("	}");
			writeln("}");
			writeln();
			writeln(q{struct Result(ValueType)});
			writeln("{");
			writeln(q{	bool succeeded;});
			writeln(q{	TokeIterator iterNext;});
			writeln(q{	static if(!is(ValueType == void)) ValueType value;});
			writeln();
			writeln(q{	@property bool failed(){ return !succeeded; }});
			writeln("}");
			writeln();
		}
		this.currentFile.writeln(q{public class Grammar}, "\n{");
		this.currentState = EnumCurrentState.GenerateElementParsingStructures;
		foreach(n; node.rules) n.accept(this);
		this.currentState = EnumCurrentState.None;
		foreach(n; node.rules) n.accept(this);
		this.currentFile.writeln("}");
		this.currentFile.close();
	}
	public void visit(PatternNode node)
	{
		switch(this.currentState)
		{
		case EnumCurrentState.GeneratePatternCtRegex:
			if(node.isRegex)
			{
				assert(this.currentFile.isOpen);

				this.currentFile.write("\t", "auto rx");
				if(node.tokenName is null)
				{
					this.currentFile.write("SkipPattern", this.skipPatternOrdinal);
				}
				else this.currentFile.write(node.tokenName);
				this.currentFile.writeln(" = ctRegex!r\"", node.patternString, "\";");
			}
			break;
		case EnumCurrentState.GeneratePatternMatchList:
			assert(this.currentFile.isOpen);

			if(node.isRegex)
			{
				matchListTemp ~= "\t\t\t" ~ q{parsingRange.matchRegex} ~ "!(rx";
				if(node.tokenName is null)
				{
					matchListTemp ~= "SkipPattern" ~ this.skipPatternOrdinal.to!string;
					matchListTemp ~= ", " ~ q{EnumTokenType.__SKIP_PATTERN__};
				}
				else
				{
					matchListTemp ~= node.tokenName ~ ", EnumTokenType." ~ node.tokenName;
				}
				matchListTemp ~= "), \n";
			}
			else
			{
				matchListTemp ~= "\t\t\t" ~ q{parsingRange.matchExactly} ~ "!(";
				matchListTemp ~= "\"" ~ node.pattern_string ~ "\", ";
				if(node.tokenName is null)
				{
					matchListTemp ~= q{EnumTokenType.__SKIP_PATTERN__};
				}
				else
				{
					matchListTemp ~= "EnumTokenType." ~ node.tokenName;
				}
				matchListTemp ~= "), \n";
			}
			break;
		default: break;
		}
	}
	public void visit(RuleNode node)
	{
		assert(this.currentFile.isOpen);

		switch(this.currentState)
		{
		case EnumCurrentState.GenerateElementParsingStructures:
			node.ruleBody.accept(this);
			break;
		case EnumCurrentState.None:
			this.currentFile.writeln(q{	public static class }, node.ruleName);
			this.currentFile.writeln("	{");

			if(node.typeName == "auto")
			{
				// inferencing required
				with(this.currentFile)
				{
					writeln(q{		private alias ValueType = ReturnType!__vtype_inferer__;});
					writeln(q{		private auto __vtype_inferer__()});
					writeln("		{");
					writeln("			// actions...");
					this.currentState = EnumCurrentState.GenerateActionInferer;
					node.ruleBody.accept(this);
					this.currentState = EnumCurrentState.None;
					writeln("		}");
					writeln();
					writeln(q{		private alias ResultType = Result!ValueType;});
					writeln(q{		private ResultType[TokenIterator] _memo;});
					writeln();
					writeln(q{		public auto parse(TokenIterator r)});
					writeln("		{");
					writeln(q{			if((r in this._memo) is null)});
					writeln("			{");
					writeln("				// register new result");
					writeln();
					writeln(q{				bool succeeded = false;});
					writeln(q{				static if(is(ValueType == void))});
					writeln("				{");
					writeln(q{					this.innerParse(r, succeeded);});
					writeln(q{					this._memo[r] = ResultType(succeeded);});
					writeln("				}");
					writeln(q{				else});
					writeln("				{");
					writeln(q{					auto result = this.innerParse(r, succeeded);});
					writeln(q{					this._memo[r] = ResultType(succeeded, result);});
					writeln("				}");
					writeln("			}");
					writeln();
					writeln(q{			return this._memo[r];});
					writeln("		}");
					writeln();
					writeln(q{		private auto innerParse(TokenIterator r, out bool succeeded)});
					writeln("		{");
					writeln(q{			succeeded = true;});
					writeln();
					writeln("			// parsing rule code here");
					node.ruleBody.accept(this);
					writeln(q{			static if(!is(ValueType == void)) return ValueType();});
					writeln("		}");
				}
			}
			else
			{
				// restricted type
				with(this.currentFile)
				{
					auto tname = node.typeName.any!(a => a == ' ') ? "(" ~ node.typeName ~ ")" : node.typeName;
					writeln(q{		private alias ResultType = Result!}, tname, q{;});
					writeln(q{		private ResultType[TokenIterator] _memo;});
					writeln();
					writeln(q{		public auto parse(TokenIterator r)});
					writeln("		{");
					writeln(q{			if((r in this._memo) is null)});
					writeln("			{");
					writeln("				// register new result");
					writeln();
					writeln(q{				bool succeeded = false;});
					if(node.typeName == "void")
					{
						writeln(q{				this.innerParse(r, succeeded)});
						writeln(q{				this._memo[r] = ResultType(succeeded);});
					}
					else
					{
						writeln(q{				auto result = this.innerParse(r, succeeded);});
						writeln(q{				this._memo[r] = ResultType(succeeded, result);});
					}
					writeln("			}");
					writeln();
					writeln(q{			return this._memo[r];});
					writeln("		}");
					writeln();
					writeln(q{		private auto innerParse(TokenIterator r, out bool succeeded)});
					writeln("		{");
					writeln(q{			succeeded = true;});
					writeln();
					writeln("			// parsing rule code here");
					node.ruleBody.accept(this);
					writeln(q{			return }, node.typeName, q{();});
					writeln("		}");
				}
			}

			this.currentFile.writeln("	}");
			break;
		default: break;
		}
	}
	public void visit(PEGSwitchingNode node)
	{
		this.currentFile.writeln("			// PEGSwitchingNode id=", node.ruleIdentifier);
		foreach(n; node.nodes)
		{
			n.accept(this);
		}
	}
	public void visit(PEGSequentialNode node)
	{
		this.currentFile.writeln("			// PEGSequentialNode id=", node.ruleIdentifier);
		foreach(n; node.nodes)
		{
			n.accept(this);
		}
	}
	public void visit(PEGLoopQualifiedNode node)
	{
		this.currentFile.writeln("			// PEGLoopQualifiedNode: id=", node.ruleIdentifier);
		node.inner.accept(this);
	}
	public void visit(PEGSkippableNode node)
	{
		switch(this.currentState)
		{
		case EnumCurrentState.GenerateElementParsingStructures:
			node.inner.accept(this);

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
					auto className = "ComplexParser_Skippable" ~ this.complexRuleCount.to!string;
					this.complexRuleCount++;
					if(typeid(node.inner) == typeid(PEGElementNode))
					{
						if(!(cast(PEGElementNode)node.inner).isRule)
						{
							// use element parser
						}
					}
				}
			}
			break;
		default: break;
		}
	}
	public void visit(PEGActionNode node)
	{
		switch(this.currentState)
		{
		case EnumCurrentState.GenerateActionInferer:
			this.currentFile.writeln("			{", node.actionString, "}");
			break;
		default: break;
		}
	}
	public void visit(PEGElementNode node)
	{
		switch(this.currentState)
		{
		case EnumCurrentState.GenerateElementParsingStructures:
			if(!node.isRule)
			{
				if(!this.parseClassDefinedList.any!(a => a == "ElementParser"))
				{
					// generate template class at once.
					this.parseClassDefinedList ~= "ElementParser";
					this.currentFile.generateElementParser();
				}

				// generated only pattern parsing
				auto className = "ElementParser_" ~ node.elementName;
				if(!this.parseClassDefinedList.any!(a => a == className))
				{
					this.parseClassDefinedList ~= className;
					this.currentFile.writeln(q{	private alias }, className, q{ = ElementParser!(EnumTokenType.}, node.elementName, q{);});
				}
			}
			break;
		default: break;
		}
	}
}
