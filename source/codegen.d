module com.cterm2.tpeg.codegen;

import settings = com.cterm2.tpeg.settings;
import com.cterm2.tpeg.visitor;
import com.cterm2.tpeg.tree;
import std.stdio, std.path, std.file, std.algorithm, std.string;
import std.conv, std.regex, std.range;

void writeBeginDeclaration(File f, int indent, string[] qualifiers, string type, string name) in { assert(f.isOpen); } body
{
	f.writeln("\t".repeat(indent).join(""), qualifiers.join(" "), " ", type, " ", name, "\n{");
}
void writeReadonlyExport(File f, int indent, string name) in { assert(f.isOpen); } body
{
	auto vname = "_" ~ name;
	if(!name.match(regex(r"[A-Z]")).empty)
	{
		vname = name.replaceAll(regex(r"[A-Z]"), "_$&");
	}
	f.writeln("\t".repeat(indent).join(""), "public @property ", name, "(){ return this.", vname, "; }");
}

void writeTokenClassDeclaration(File f) in { assert(f.isOpen); } body
{
	f.writeBeginDeclaration(0, ["public"], "struct", "Location");
	f.writeln(q{	uint line = 1, col = 1;});
	f.writeln();
	f.writeln(q{	public string toString(){ return this.line.to!string ~ ":" ~ this.col.to!string; }});
	f.writeln( "}");
	f.writeBeginDeclaration(0, ["public"], "class", "Token");
	f.writeln(q{	Location _location;});
	f.writeln(q{	EnumTokenType _type;});
	f.writeln(q{	string _text;});
	f.writeln();
	f.writeReadonlyExport(1, "location");
	f.writeReadonlyExport(1, "type");
	f.writeReadonlyExport(1, "text");
	f.writeln();
	f.writeln(q{	public this(Location l, EnumTokenType t)});
	f.writeln( "	{");
	f.writeln(q{		this._location = l;});
	f.writeln(q{		this._type = t;});
	f.writeln( "	}");
	f.writeln(q{	public this(Location l, EnumTokenType t, string tx)});
	f.writeln( "	{");
	f.writeln(q{		this(l, t);});
	f.writeln(q{		this._text = tx;});
	f.writeln( "	}");
	f.writeln();
	f.writeln(q{	public @property dup(){ return new Token(this.location, this.type, this.text); }});
	f.writeln( "}");
	f.writeln("public class TokenizeError : Exception");
	f.writeln("{");
	f.writeln("	public this(string err, Location loc){ super(err ~ \" at \" ~ loc.toString); }");
	f.writeln("}");
	f.writeln();
	f.writeln("// utility //");
	f.writeBeginDeclaration(0, [], "struct", "MatchStruct");
	f.writeln(q{	bool isPerfectMatch;});
	f.writeln(q{	bool match;});
	f.writeln(q{	string matchStr;});
	f.writeln(q{	EnumTokenType itype;});
	f.writeln();
	f.writeln(q{	public @property length(){ return this.matchStr.length; }});
	f.writeln( "}");
	f.writeln(q{auto matchExactly(string s, EnumTokenType t)(string parsingRange)}, "\n", "{");
	f.writeln(q{	return MatchStruct(true, parsingRange.startsWith(s), s, t);});
	f.writeln( "}");
	f.writeln(q{auto matchRegex(alias rx, EnumTokenType t)(string parsingRange)});
	f.writeln( "{");
	f.writeln(q{	auto match = parsingRange.matchFirst(rx);});
	f.writeln(q{	if(match.empty) return MatchStruct(false, false, "", t);});
	f.writeln(q{	return MatchStruct(false, match.pre.empty, match.hit, t);});
	f.writeln( "}");
	f.writeln();
}
void writeTokenizerSourceHeader(File f, string[] patternSymbols, string[] moduleNamePath)
in { assert(f.isOpen); } body
{
	f.writeln("module ", moduleNamePath.join("."), ";");
	f.writeln();
	f.writeln(q{static import std.file;});
	f.writeln(q{import std.conv, std.algorithm, std.regex;});
	f.writeln(q{import std.array, std.range, std.exception;});
	f.writeln();
	f.writeBeginDeclaration(0, ["public"], "enum", "EnumTokenType");
	string line_temp = "__SKIP_PATTERN__, ";
	foreach(t; patternSymbols ~ "__INPUT_END__")
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
	f.writeln(q{public auto tokenize(string filePath){ return tokenizeStr(std.file.readText(filePath)); }});
	f.writeln();
}

enum EnumCurrentState
{
	None, GeneratePatternCtRegex, GeneratePatternMatchList,
	GenerateParserOrdinals, GenerateParserUsingCode, GenerateParserClassName,
	GenerateValueSaucer, GenerateReduceMethods, GenerateActionInferer
}

class CodeGenerator : IVisitor
{
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
		settings.acquireOutputDirectory();

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
		this.packageName = node.packageName;
		if(node.tokenizer !is null) this.lexerModuleName = node.tokenizer.moduleName;
		if(node.tokenizer !is null) node.tokenizer.accept(this);
		if(node.parser !is null) node.parser.accept(this);
	}
	public void visit(TokenizerNode node)
	{
		assert(!this.currentFile.isOpen);
		this.currentFile.open(buildPath(settings.OutputDirectory, node.moduleName ~ ".d"), "w");
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
		this.currentFile.writeln("\t\t", "auto longest_match = matches.reduce!((a, b)");
		this.currentFile.writeln("\t\t", "{");
		this.currentFile.writeln("\t\t\t", "if(a.length == b.length)");
		this.currentFile.writeln("\t\t\t", "{");
		this.currentFile.writeln("\t\t\t\t", "if(a.isPerfectMatch && !b.isPerfectMatch) return a;");
		this.currentFile.writeln("\t\t\t\t", "else if(!a.isPerfectMatch && b.isPerfectMatch) return b;");
		this.currentFile.writeln("\t\t\t\t", "else throw new TokenizeError(\"Conflicting patterns\", loc);");
		this.currentFile.writeln("\t\t\t", "}");
		this.currentFile.writeln("\t\t\t", "return a.length > b.length ? a : b;");
		this.currentFile.writeln("\t\t", "});");
		this.currentFile.writeln();
		this.currentFile.writeln("\t\t", "if(longest_match.itype != EnumTokenType.__SKIP_PATTERN__)");
		this.currentFile.writeln("\t\t", "{");
		this.currentFile.writeln("\t\t\t", "tokenList ~= new Token(loc, longest_match.itype, longest_match.matchStr);");
		this.currentFile.writeln("\t\t", "}");
		this.currentFile.writeln("\t\t", "auto lines = longest_match.matchStr.split(ctRegex!r\"\n\");");
		this.currentFile.writeln("\t\t", "foreach(a; lines[0 .. $ - 1])");
		this.currentFile.writeln("\t\t", "{");
		this.currentFile.writeln("\t\t\t", "loc.col = 1;");
		this.currentFile.writeln("\t\t\t", "loc.line++;");
		this.currentFile.writeln("\t\t", "}");
		this.currentFile.writeln("\t\t", "loc.col += lines[$ - 1].length;");
		this.currentFile.writeln("\t\t", "parsingRange = parsingRange.drop(longest_match.length);");
		this.currentFile.writeln("\t", "}");
		this.currentFile.writeln();
		this.currentFile.writeln("\t", q{tokenList ~= new Token(loc, EnumTokenType.__INPUT_END__, "[EOI]");});
		this.currentFile.writeln("\t", q{return tokenList.dup;});
		this.currentFile.writeln("}");
		this.currentFile.close();
	}
	public void visit(ParserNode node)
	{
		this.currentState = EnumCurrentState.GenerateParserOrdinals;
		foreach(n; node.rules) n.accept(this);
		this.currentState = EnumCurrentState.None;
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
				if(node.patternString.any!(a => a == '"'))
				{
					this.currentFile.writeln(" = ctRegex!`", node.patternString, "`;");
				}
				else
				{
					this.currentFile.writeln(" = ctRegex!r\"", node.patternString, "\";");
				}
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
		switch(this.currentState)
		{
		case EnumCurrentState.GenerateParserOrdinals:
			node.ruleBody.accept(this);
			break;
		default: break;
		}
	}
	public void visit(PEGSwitchingNode node)
	{
		switch(this.currentState)
		{
		case EnumCurrentState.GenerateParserOrdinals:
			foreach(n; node.nodes) n.accept(this);
			this.acquireRuleOrdinal(node);
			break;
		default: break;
		}
	}
	public void visit(PEGSequentialNode node)
	{
		switch(this.currentState)
		{
		case EnumCurrentState.GenerateParserOrdinals:
			foreach(n; node.nodes) n.accept(this);
			this.acquireRuleOrdinal(node);
			break;
		default: break;
		}
	}
	public void visit(PEGLoopQualifiedNode node)
	{
		switch(this.currentState)
		{
		case EnumCurrentState.GenerateParserOrdinals:
			node.inner.accept(this);
			this.acquireRuleOrdinal(node);
			break;
		default: break;
		}
	}
	public void visit(PEGSkippableNode node)
	{
		switch(this.currentState)
		{
		case EnumCurrentState.GenerateParserOrdinals:
			node.inner.accept(this);
			this.acquireRuleOrdinal(node);
			break;
		default: break;
		}
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
