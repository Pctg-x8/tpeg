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

enum EnumCurrentState
{
	None, GeneratePatternCtRegex, GeneratePatternMatchList
}

class CodeGenerator : IVisitor
{
	string outdir = "tpeg_output";
	string[] packageName;
	File currentFile;
	uint skipPatternOrdinal;
	EnumCurrentState currentState;
	string matchListTemp;

	string lexerModuleName;

	public void entry(ScriptNode node)
	{
		this.currentState = EnumCurrentState.None;
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
		this.currentFile.writeln("import ", (this.packageName ~ this.lexerModuleName).join("."), " : EnumTokenType;");
		this.currentFile.writeln();
		if(node.headerPart !is null)
		{
			this.currentFile.writeln("// header part from tpeg file //");
			this.currentFile.writeln(node.headerPart);
			this.currentFile.writeln();
		}
		this.currentFile.writeln(q{public class Grammar}, "\n{");
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

		this.currentFile.writeln(`	public static class `, node.ruleName, `
	{
		private alias ResultType = Result;
		private ResultType[TokenRange] _memo;

		public auto parse(TokenRange r)
		{
			if(r in this._memo) return this._memo[r];
			else
			{
				// parsing rule code here`);
		node.ruleBody.accept(this);
		this.currentFile.writeln(`

				return ResultType();
			}
		}
	}`);
	}
	public void visit(PEGSwitchingNode node)
	{
		this.currentFile.writeln("				// PEGSwitchingNode: ", node.nodes.length, " childs.");
	}
	public void visit(PEGSequentialNode node)
	{
		this.currentFile.writeln("				// PEGSequentialNode: ", node.nodes.length, " childs.");
	}
	public void visit(PEGLoopQualifiedNode node)
	{

	}
	public void visit(PEGSkippableNode node)
	{

	}
	public void visit(PEGActionNode node)
	{

	}
	public void visit(PEGElementNode node)
	{

	}
}
