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

	public @property dup()
	{
		return new Token(this.location, this.type, this.text);
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
	f.writeln(q{
public auto tokenize(string filePath){ return tokenizeStr(std.file.readText(filePath)); }
});
}

void generateElementParser(File f) in { assert(f.isOpen); } body
{
	// generate template class in Grammar class

	f.writeln(q{	private static class ElementParser(EnumTokenType ParseE)});
	f.writeln( "	{");
	f.writeln(q{		protected alias ResultType = Result!TokenTree;});
	f.writeln(q{		private static ResultType[TokenIterator] _memo;});
	f.writeln();
	f.writeln(q{		public static auto parse(TokenIterator r)});
	f.writeln( "		{");
	f.writeln(q{			if((r in _memo) is null)});
	f.writeln( "			{");
	f.writeln( "				// register new result");
	f.writeln(q{				_memo[r] = innerParse(r);});
	f.writeln( "			}");
	f.writeln();
	f.writeln(q{			return _memo[r];});
	f.writeln( "		}");
	f.writeln();
	f.writeln(q{		private static auto innerParse(TokenIterator r)});
	f.writeln( "		{");
	f.writeln(q{			if(r.current.type == ParseE)});
	f.writeln( "			{");
	f.writeln(q{				return ResultType(true, TokenIterator(r.pos + 1, r.token), TokenIterator(r.pos + 1, r.token), new TokenTree(r.current));});
	f.writeln( "			}");
	f.writeln(q{			else});
	f.writeln( "			{");
	f.writeln(q{				return ResultType(false, r, TokenIterator(r.pos + 1, r.token));});
	f.writeln( "			}");
	f.writeln( "		}");
	f.writeln( "	}");
}
void generateRuleParser(File f) in { assert(f.isOpen); } body
{
	f.writeln(q{	private static class RuleParser(string Name, alias PrimaryParser)});
	f.writeln( "	{");
	f.writeln(q{		private alias ResultType = Result!(RuleTree!Name);});
	f.writeln(q{		private static ResultType[TokenIterator] _memo;});
	f.writeln();
	f.writeln(q{		public static ResultType parse(TokenIterator r)});
	f.writeln( "		{");
	f.writeln(q{			if((r in _memo) is null)});
	f.writeln( "			{");
	f.writeln( "				// register new result");
	f.writeln(q{				auto res = PrimaryParser.parse(r);});
	f.writeln(q{				if(res.succeeded) _memo[r] = ResultType(true, res.iterNext, res.iterError, new RuleTree!Name(res.value));});
	f.writeln(q{				else _memo[r] = ResultType(false, r, res.iterError);});
	f.writeln( "			}");
	f.writeln();
	f.writeln(q{			return _memo[r];});
	f.writeln( "		}");
	f.writeln( "	}");
}
void generatePartialParserHeader(File f) in { assert(f.isOpen); } body
{
	f.writeln(q{	private template PartialParserHeader(alias InternalParserMethod)});
	f.writeln( "	{");
	f.writeln(q{		private static ResultType[TokenIterator] _memo;});
	f.writeln();
	f.writeln(q{		public static ResultType parse(TokenIterator r)});
	f.writeln( "		{");
	f.writeln(q{			if((r in _memo) is null) _memo[r] = InternalParserMethod(r);});
	f.writeln(q{			return _memo[r];});
	f.writeln( "		}");
	f.writeln( "	}");
}

enum EnumCurrentState
{
	None, GeneratePatternCtRegex, GeneratePatternMatchList,
	GenerateElementParsingStructures, GenerateParserUsingCode, GenerateParserClassName
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
		this.currentFile.writeln();
		this.currentFile.writeln("\t", q{tokenList ~= new Token(loc, EnumTokenType.__INPUT_END__, "[EOI]");});
		this.currentFile.writeln("\t", q{return tokenList.dup;});
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
		this.currentFile.writeln("import std.traits, std.algorithm, std.range, std.array;");
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
			writeln(q{	@property current(){ return pos >= token.length ? token[$ - 1] : token[pos]; }});
			writeln(q{	size_t toHash() const @safe pure nothrow { return pos; }});
			writeln(q{	bool opEquals(ref const TokenIterator iter) const @safe pure nothrow});
			writeln("	{");
			writeln(q{		return pos == iter.pos && token.ptr == iter.token.ptr;});
			writeln("	}");
			writeln("}");
			writeln();
			writeln(q{struct Result(ValueType : ISyntaxTree)});
			writeln("{");
			writeln(q{	bool succeeded;});
			writeln(q{	TokenIterator iterNext;});
			writeln(q{	TokenIterator iterError;});
			writeln(q{	ValueType value;});
			writeln();
			writeln(q{	@property bool failed(){ return !succeeded; }});
			writeln(q{	auto opAssign(T : ISyntaxTree)(Result!T val)});
			writeln("	{");
			writeln(q{		this.succeeded = val.succeeded;});
			writeln(q{		this.iterNext = val.iterNext;});
			writeln(q{		this.iterError = val.iterError;});
			writeln(q{		this.value = val.value;});
			writeln(q{		return this;});
			writeln("	}");
			writeln("}");
			writeln();
			writeln(q{public interface ISyntaxTree});
			writeln("{");
			writeln(q{	public @property Location location();});
			writeln("}");
			writeln(q{public class RuleTree(string RuleName) : ISyntaxTree});
			writeln("{");
			writeln(q{	ISyntaxTree _child;});
			writeln();
			writeln(q{	public override @property Location location(){ return this._child.location; }});
			writeln(q{	public @property child(){ return this._child; }});
			writeln();
			writeln(q{	public this(ISyntaxTree c)});
			writeln("	{");
			writeln(q{		this._child = c;});
			writeln("	}");
			writeln("}");
			writeln(q{public class PartialTree : ISyntaxTree});
			writeln("{");
			writeln(q{	ISyntaxTree[] children;});
			writeln();
			writeln(q{	public override @property Location location(){ return this.children.front.location; }});
			writeln();
			writeln(q{	public this(ISyntaxTree[] trees)});
			writeln("	{");
			writeln(q{		this.children = trees;});
			writeln("	}");
			writeln("}");
			writeln(q{public class TokenTree : ISyntaxTree});
			writeln("{");
			writeln(q{	Token _token;});
			writeln();
			writeln(q{	public override @property Location location(){ return this.token.location; }});
			writeln(q{	public @property token(){ return this._token; }});
			writeln();
			writeln(q{	public this(Token t)});
			writeln("	{");
			writeln(q{		this._token = t.dup;});
			writeln("	}");
			writeln("}");
			writeln();
		}
		this.currentFile.writeln(q{public class Grammar}, "\n{");
		this.currentState = EnumCurrentState.GenerateElementParsingStructures;
		foreach(n; node.rules) n.accept(this);
		this.currentState = EnumCurrentState.None;
		foreach(n; node.rules) n.accept(this);
		this.currentFile.writeln("}");
		this.currentFile.writeln();
		this.currentFile.writeln(q{public auto parse(Token[] tokenList)});
		this.currentFile.writeln("{");
		this.currentFile.writeln(q{	auto res = Grammar.}, node.startRuleName, q{.parse(TokenIterator(0, tokenList));});
		this.currentFile.writeln(q{	if(res.iterNext.current.type != EnumTokenType.__INPUT_END__)});
		this.currentFile.writeln("	{");
		this.currentFile.writeln(q{		return Grammar.}, node.startRuleName, q{.ResultType(false, res.iterNext, res.iterError);});
		this.currentFile.writeln("	}");
		this.currentFile.writeln(q{	return res;});
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
			if(!this.parseClassDefinedList.any!(a => a == "RuleParser"))
			{
				this.parseClassDefinedList ~= "RuleParser";
				this.currentFile.generateRuleParser();
			}
			this.currentFile.write(q{	public alias }, node.ruleName, q{ = RuleParser!(}, `"`, node.ruleName, `"`, q{, });
			this.currentState = EnumCurrentState.GenerateParserClassName;
			node.ruleBody.accept(this);
			this.currentState = EnumCurrentState.None;
			this.currentFile.writeln(q{);});
			break;
		default: break;
		}
	}
	public void visit(PEGSwitchingNode node)
	{
		switch(this.currentState)
		{
		case EnumCurrentState.GenerateElementParsingStructures:
			foreach(n; node.nodes)
			{
				n.accept(this);
			}

			this.acquireRuleOrdinal(node);
			if(!this.parseClassDefinedList.any!(a => a == "PartialParserHeader"))
			{
				this.parseClassDefinedList ~= "PartialParserHeader";
				this.currentFile.generatePartialParserHeader();
			}
			auto className = "ComplexParser_Switching" ~ node.complexRuleOrdinal.to!string;
			if(!this.parseClassDefinedList.any!(a => a == className))
			{
				this.parseClassDefinedList ~= className;
				with(this.currentFile)
				{
					writeln(q{	private static class }, className);
					writeln("	{");
					writeln("		// id=", node.ruleIdentifier);
					writeln(q{		private alias ResultType = Result!PartialTree;});
					writeln(q{		mixin PartialParserHeader!innerParse;});
					writeln();
					writeln(q{		private static ResultType innerParse(TokenIterator r)});
					writeln("		{");
					writeln(q{			Result!ISyntaxTree resTemp;});
					writeln(q{			TokenIterator[] errors;});
					this.currentState = EnumCurrentState.GenerateParserUsingCode;
					foreach(n; node.nodes)
					{
						if(typeid(n) == typeid(PEGActionNode)) continue;
						writeln();
						  write(q{			resTemp = }); n.accept(this); writeln(q{;});
						writeln(q{			if(resTemp.succeeded)});
						writeln("			{");
						writeln(q{				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree([resTemp.value]));});
						writeln("			}");
						writeln(q{			errors ~= resTemp.iterError;});
					}
					writeln(q{			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));});
					this.currentState = EnumCurrentState.GenerateElementParsingStructures;
					writeln("		}");
					writeln("	}");
				}
			}
			break;
		case EnumCurrentState.GenerateParserUsingCode:
			this.acquireRuleOrdinal(node);
			this.currentFile.write("ComplexParser_Switching", node.complexRuleOrdinal, q{.parse(r)});
			break;
		case EnumCurrentState.GenerateParserClassName:
			this.acquireRuleOrdinal(node);
			this.currentFile.write("ComplexParser_Switching", node.complexRuleOrdinal);
			break;
		default: break;
		}
	}
	public void visit(PEGSequentialNode node)
	{
		switch(this.currentState)
		{
		case EnumCurrentState.GenerateElementParsingStructures:
			foreach(n; node.nodes)
			{
				n.accept(this);
			}

			this.acquireRuleOrdinal(node);
			if(!this.parseClassDefinedList.any!(a => a == "PartialParserHeader"))
			{
				this.parseClassDefinedList ~= "PartialParserHeader";
				this.currentFile.generatePartialParserHeader();
			}
			auto className = "ComplexParser_Sequential" ~ node.complexRuleOrdinal.to!string;
			if(!this.parseClassDefinedList.any!(a => a == className))
			{
				this.parseClassDefinedList ~= className;
				with(this.currentFile)
				{
					writeln(q{	private static class }, className);
					writeln("	{");
					writeln("		// id=", node.ruleIdentifier);
					writeln(q{		private alias ResultType = Result!PartialTree;});
					writeln(q{		mixin PartialParserHeader!innerParse;});
					writeln();
					writeln(q{		private static ResultType innerParse(TokenIterator r)});
					writeln("		{");
					writeln(q{			Result!ISyntaxTree resTemp;});
					writeln(q{			ISyntaxTree[] treeList;});
					this.currentState = EnumCurrentState.GenerateParserUsingCode;
					foreach(n; node.nodes)
					{
						if(typeid(n) == typeid(PEGActionNode)) continue;
						writeln();
						  write(q{			resTemp = }); n.accept(this); writeln(q{;});
						writeln(q{			if(resTemp.failed)});
						writeln("			{");
						writeln(q{				return ResultType(false, r, resTemp.iterError);});
						writeln("			}");
						writeln(q{			treeList ~= resTemp.value;});
						writeln(q{			r = resTemp.iterNext;});
					}
					writeln(q{			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree(treeList));});
					this.currentState = EnumCurrentState.GenerateElementParsingStructures;
					writeln("		}");
					writeln("	}");
				}
			}
			break;
		case EnumCurrentState.GenerateParserUsingCode:
			this.acquireRuleOrdinal(node);
			this.currentFile.write("ComplexParser_Sequential", node.complexRuleOrdinal, q{.parse(r)});
			break;
		case EnumCurrentState.GenerateParserClassName:
			this.acquireRuleOrdinal(node);
			this.currentFile.write("ComplexParser_Sequential", node.complexRuleOrdinal);
			break;
		default: break;
		}
	}
	public void visit(PEGLoopQualifiedNode node)
	{
		switch(this.currentState)
		{
		case EnumCurrentState.GenerateElementParsingStructures:
			node.inner.accept(this);

			this.acquireRuleOrdinal(node);
			if(!this.parseClassDefinedList.any!(a => a == "PartialParserHeader"))
			{
				this.parseClassDefinedList ~= "PartialParserHeader";
				this.currentFile.generatePartialParserHeader();
			}
			auto className = "ComplexParser_LoopQualified" ~ node.complexRuleOrdinal.to!string;
			if(!this.parseClassDefinedList.any!(a => a == className))
			{
				this.parseClassDefinedList ~= className;
				with(this.currentFile)
				{
					writeln(q{	private static class }, className);
					writeln("	{");
					writeln("		// id=", node.ruleIdentifier);
					writeln(q{		private alias ResultType = Result!PartialTree;});
					writeln(q{		mixin PartialParserHeader!innerParse;});
					writeln();
					writeln(q{		private static ResultType innerParse(TokenIterator r)});
					writeln("		{");
					this.currentState = EnumCurrentState.GenerateParserUsingCode;
					writeln(q{			ISyntaxTree[] treeList;});
					writeln(q{			TokenIterator lastError;});
					writeln(q{			while(true)});
					writeln("			{");
					  write(q{				auto result = }); node.inner.accept(this); writeln(q{;});
					writeln(q{				lastError = result.iterError;});
					writeln(q{				if(result.failed) break;});
					writeln(q{				treeList ~= result.value;});
					writeln(q{				r = result.iterNext;});
					writeln("			}");
					if(!node.isRequiredLeastOne)
					{
						writeln(q{			return ResultType(true, r, lastError, new PartialTree(treeList));});
					}
					else
					{
						writeln(q{			return ResultType(!treeList.empty, r, lastError, new PartialTree(treeList));});
					}
					this.currentState = EnumCurrentState.GenerateElementParsingStructures;
					writeln("		}");
					writeln("	}");
				}
			}
			break;
		case EnumCurrentState.GenerateParserUsingCode:
			this.acquireRuleOrdinal(node);
			this.currentFile.write("ComplexParser_LoopQualified", node.complexRuleOrdinal, q{.parse(r)});
			break;
		case EnumCurrentState.GenerateParserClassName:
			this.acquireRuleOrdinal(node);
			this.currentFile.write("ComplexParser_LoopQualified", node.complexRuleOrdinal);
			break;
		default: break;
		}
	}
	public void visit(PEGSkippableNode node)
	{
		switch(this.currentState)
		{
		case EnumCurrentState.GenerateElementParsingStructures:
			node.inner.accept(this);

			this.acquireRuleOrdinal(node);
			if(!this.parseClassDefinedList.any!(a => a == "PartialParserHeader"))
			{
				this.parseClassDefinedList ~= "PartialParserHeader";
				this.currentFile.generatePartialParserHeader();
			}
			auto className = "ComplexParser_Skippable" ~ node.complexRuleOrdinal.to!string;
			if(!this.parseClassDefinedList.any!(a => a == className))
			{
				this.parseClassDefinedList ~= className;
				with(this.currentFile)
				{
					writeln(q{	private static class }, className);
					writeln("	{");
					writeln("		// id=", node.ruleIdentifier);
					writeln(q{		private alias ResultType = Result!PartialTree;});
					writeln(q{		mixin PartialParserHeader!innerParse;});
					writeln();
					writeln(q{		public static ResultType innerParse(TokenIterator r)});
					writeln("		{");
					this.currentState = EnumCurrentState.GenerateParserUsingCode;
					  write(q{			auto result = });node.inner.accept(this);writeln(q{;});
					writeln(q{			if(result.failed)});
					writeln("			{");
					writeln(q{				return ResultType(true, r, r, new PartialTree())});
					writeln("			}");
					writeln(q{			else});
					writeln("			{");
					writeln(q{				return result;});
					writeln("			}");
					this.currentState = EnumCurrentState.GenerateElementParsingStructures;
					writeln("		}");
					writeln("	}");
				}
			}
			break;
		case EnumCurrentState.GenerateParserUsingCode:
			this.acquireRuleOrdinal(node);
			this.currentFile.write("ComplexParser_Skippable", node.complexRuleOrdinal, q{.parse(r)});
			break;
		case EnumCurrentState.GenerateParserClassName:
			this.acquireRuleOrdinal(node);
			this.currentFile.write("ComplexParser_Skippable", node.complexRuleOrdinal);
			break;
		default: break;
		}
	}
	public void visit(PEGActionNode node)
	{
		switch(this.currentState)
		{
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
		case EnumCurrentState.GenerateParserUsingCode:
			if(node.isRule) this.currentFile.write(node.elementName, ".parse(r)");
			else this.currentFile.write(q{ElementParser_}, node.elementName, q{.parse(r)});
			break;
		case EnumCurrentState.GenerateParserClassName:
			if(node.isRule) this.currentFile.write(node.elementName);
			else this.currentFile.write(q{ElementParser_}, node.elementName);
			break;
		default: break;
		}
	}
}
