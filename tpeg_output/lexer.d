module com.cterm2.ml.lexer;

static import std.file;
import std.conv, std.algorithm, std.regex;
import std.array, std.range, std.exception;

public enum EnumTokenType
{
	__SKIP_PATTERN__, INUMBER, HNUMBER, FNUMBER, DNUMBER, NUMBER, STRING, CHARACTER, 
	IDENTIFIER, SEMICOLON, PERIOD, COMMA, COLON, RARROW, RARROW2, LARROW, SHARP, 
	EQUAL, PLUS_EQ, MINUS_EQ, ASTERISK_EQ, SLASH_EQ, PERCENT_EQ, AMPASAND_EQ, VL_EQ, 
	CA_EQ, LAB2_EQ, RAB2_EQ, AMPASAND2, VL2, CA2, PLUS, MINUS, ASTERISK, SLASH, 
	PERCENT, AMPASAND, VL, CA, LAB2, RAB2, LAB, RAB, LAB_EQ, RAB_EQ, EQ2, EX_EQ, 
	QUESTION, PLUS2, MINUS2, ASTERISK2, PERIOD2, PERIOD3, LP, RP, LB, RB, LBR, RBR, 
	PACKAGE, IMPORT, CLASS, TRAIT, ENUM, EXTENDS, WITH, TEMPLATE, ALIAS, PROPERTY, 
	FUNCTION, IF, ELSE, WHILE, DO, FOREACH, FOR, RETURN, BREAK, CONTINUE, SWITCH, 
	CASE, DEFAULT, TYPEOF, THIS, SUPER, TRUE, FALSE, NULL, PUBLIC, PRIVATE, PROTECTED, 
	FINAL, CONST, STATIC, OVERRIDE, AUTO, VOID, CHAR, UCHAR, BYTE, SHORT, USHORT, 
	INT, UINT, LONG, ULONG, __INPUT_END__
}
public struct Location
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

	public @property dup(){ return new Token(this.location, this.type, this.text); }
}
public class TokenizeError : Exception
{
	public this(string err, Location loc){ super(err ~ " at " ~ loc.toString); }
}

// utility //
 struct MatchStruct
{
	bool isPerfectMatch;
	bool match;
	string matchStr;
	EnumTokenType itype;

	public @property length(){ return this.matchStr.length; }
}
auto matchExactly(string s, EnumTokenType t)(string parsingRange)
{
	return MatchStruct(true, parsingRange.startsWith(s), s, t);
}
auto matchRegex(alias rx, EnumTokenType t)(string parsingRange)
{
	auto match = parsingRange.matchFirst(rx);
	if(match.empty) return MatchStruct(false, false, "", t);
	return MatchStruct(false, match.pre.empty, match.hit, t);
}

public auto tokenize(string filePath){ return tokenizeStr(std.file.readText(filePath)); }

public auto tokenizeStr(string fileData)
{
	auto parsingRange = fileData[];

	// precompiled regex patterns //
	auto rxSkipPattern1 = ctRegex!r"[ \t\r\n]";
	auto rxSkipPattern2 = ctRegex!r"//[^\n]*\n";
	auto rxSkipPattern3 = ctRegex!r"/*[^\*]*\*/";
	auto rxINUMBER = ctRegex!r"[0-9]+";
	auto rxHNUMBER = ctRegex!r"0x[0-9A-Fa-f]+";
	auto rxFNUMBER = ctRegex!r"[0-9]*\.[0-9]+(f|F)";
	auto rxDNUMBER = ctRegex!r"[0-9]*\.[0-9]+(d|D)";
	auto rxNUMBER = ctRegex!r"[0-9]*\.[0-9]+";
	auto rxSTRING = ctRegex!`"[^"]*"`;
	auto rxCHARACTER = ctRegex!r"'[^']*'";
	auto rxIDENTIFIER = ctRegex!r"[A-Za-z_][A-Za-z0-9_]*";

	Token[] tokenList;
	auto loc = Location();
	while(!parsingRange.empty)
	{
		auto matches = [
			parsingRange.matchRegex!(rxSkipPattern1, EnumTokenType.__SKIP_PATTERN__), 
			parsingRange.matchRegex!(rxSkipPattern2, EnumTokenType.__SKIP_PATTERN__), 
			parsingRange.matchRegex!(rxSkipPattern3, EnumTokenType.__SKIP_PATTERN__), 
			parsingRange.matchRegex!(rxINUMBER, EnumTokenType.INUMBER), 
			parsingRange.matchRegex!(rxHNUMBER, EnumTokenType.HNUMBER), 
			parsingRange.matchRegex!(rxFNUMBER, EnumTokenType.FNUMBER), 
			parsingRange.matchRegex!(rxDNUMBER, EnumTokenType.DNUMBER), 
			parsingRange.matchRegex!(rxNUMBER, EnumTokenType.NUMBER), 
			parsingRange.matchRegex!(rxSTRING, EnumTokenType.STRING), 
			parsingRange.matchRegex!(rxCHARACTER, EnumTokenType.CHARACTER), 
			parsingRange.matchRegex!(rxIDENTIFIER, EnumTokenType.IDENTIFIER), 
			parsingRange.matchExactly!(";", EnumTokenType.SEMICOLON), 
			parsingRange.matchExactly!(".", EnumTokenType.PERIOD), 
			parsingRange.matchExactly!(",", EnumTokenType.COMMA), 
			parsingRange.matchExactly!(":", EnumTokenType.COLON), 
			parsingRange.matchExactly!("->", EnumTokenType.RARROW), 
			parsingRange.matchExactly!("=>", EnumTokenType.RARROW2), 
			parsingRange.matchExactly!("<-", EnumTokenType.LARROW), 
			parsingRange.matchExactly!("#", EnumTokenType.SHARP), 
			parsingRange.matchExactly!("=", EnumTokenType.EQUAL), 
			parsingRange.matchExactly!("+=", EnumTokenType.PLUS_EQ), 
			parsingRange.matchExactly!("-=", EnumTokenType.MINUS_EQ), 
			parsingRange.matchExactly!("*=", EnumTokenType.ASTERISK_EQ), 
			parsingRange.matchExactly!("/=", EnumTokenType.SLASH_EQ), 
			parsingRange.matchExactly!("%=", EnumTokenType.PERCENT_EQ), 
			parsingRange.matchExactly!("&=", EnumTokenType.AMPASAND_EQ), 
			parsingRange.matchExactly!("|=", EnumTokenType.VL_EQ), 
			parsingRange.matchExactly!("^=", EnumTokenType.CA_EQ), 
			parsingRange.matchExactly!("<<=", EnumTokenType.LAB2_EQ), 
			parsingRange.matchExactly!(">>=", EnumTokenType.RAB2_EQ), 
			parsingRange.matchExactly!("&&", EnumTokenType.AMPASAND2), 
			parsingRange.matchExactly!("||", EnumTokenType.VL2), 
			parsingRange.matchExactly!("^^", EnumTokenType.CA2), 
			parsingRange.matchExactly!("+", EnumTokenType.PLUS), 
			parsingRange.matchExactly!("-", EnumTokenType.MINUS), 
			parsingRange.matchExactly!("*", EnumTokenType.ASTERISK), 
			parsingRange.matchExactly!("/", EnumTokenType.SLASH), 
			parsingRange.matchExactly!("%", EnumTokenType.PERCENT), 
			parsingRange.matchExactly!("&", EnumTokenType.AMPASAND), 
			parsingRange.matchExactly!("|", EnumTokenType.VL), 
			parsingRange.matchExactly!("^", EnumTokenType.CA), 
			parsingRange.matchExactly!("<<", EnumTokenType.LAB2), 
			parsingRange.matchExactly!(">>", EnumTokenType.RAB2), 
			parsingRange.matchExactly!("<", EnumTokenType.LAB), 
			parsingRange.matchExactly!(">", EnumTokenType.RAB), 
			parsingRange.matchExactly!("<=", EnumTokenType.LAB_EQ), 
			parsingRange.matchExactly!(">=", EnumTokenType.RAB_EQ), 
			parsingRange.matchExactly!("==", EnumTokenType.EQ2), 
			parsingRange.matchExactly!("!=", EnumTokenType.EX_EQ), 
			parsingRange.matchExactly!("?", EnumTokenType.QUESTION), 
			parsingRange.matchExactly!("++", EnumTokenType.PLUS2), 
			parsingRange.matchExactly!("--", EnumTokenType.MINUS2), 
			parsingRange.matchExactly!("**", EnumTokenType.ASTERISK2), 
			parsingRange.matchExactly!("..", EnumTokenType.PERIOD2), 
			parsingRange.matchExactly!("...", EnumTokenType.PERIOD3), 
			parsingRange.matchExactly!("(", EnumTokenType.LP), 
			parsingRange.matchExactly!(")", EnumTokenType.RP), 
			parsingRange.matchExactly!("{", EnumTokenType.LB), 
			parsingRange.matchExactly!("}", EnumTokenType.RB), 
			parsingRange.matchExactly!("[", EnumTokenType.LBR), 
			parsingRange.matchExactly!("]", EnumTokenType.RBR), 
			parsingRange.matchExactly!("package", EnumTokenType.PACKAGE), 
			parsingRange.matchExactly!("import", EnumTokenType.IMPORT), 
			parsingRange.matchExactly!("class", EnumTokenType.CLASS), 
			parsingRange.matchExactly!("trait", EnumTokenType.TRAIT), 
			parsingRange.matchExactly!("enum", EnumTokenType.ENUM), 
			parsingRange.matchExactly!("extends", EnumTokenType.EXTENDS), 
			parsingRange.matchExactly!("with", EnumTokenType.WITH), 
			parsingRange.matchExactly!("template", EnumTokenType.TEMPLATE), 
			parsingRange.matchExactly!("alias", EnumTokenType.ALIAS), 
			parsingRange.matchExactly!("property", EnumTokenType.PROPERTY), 
			parsingRange.matchExactly!("funcion", EnumTokenType.FUNCTION), 
			parsingRange.matchExactly!("if", EnumTokenType.IF), 
			parsingRange.matchExactly!("else", EnumTokenType.ELSE), 
			parsingRange.matchExactly!("while", EnumTokenType.WHILE), 
			parsingRange.matchExactly!("do", EnumTokenType.DO), 
			parsingRange.matchExactly!("foreach", EnumTokenType.FOREACH), 
			parsingRange.matchExactly!("for", EnumTokenType.FOR), 
			parsingRange.matchExactly!("return", EnumTokenType.RETURN), 
			parsingRange.matchExactly!("break", EnumTokenType.BREAK), 
			parsingRange.matchExactly!("continue", EnumTokenType.CONTINUE), 
			parsingRange.matchExactly!("switch", EnumTokenType.SWITCH), 
			parsingRange.matchExactly!("case", EnumTokenType.CASE), 
			parsingRange.matchExactly!("default", EnumTokenType.DEFAULT), 
			parsingRange.matchExactly!("typeof", EnumTokenType.TYPEOF), 
			parsingRange.matchExactly!("this", EnumTokenType.THIS), 
			parsingRange.matchExactly!("super", EnumTokenType.SUPER), 
			parsingRange.matchExactly!("true", EnumTokenType.TRUE), 
			parsingRange.matchExactly!("false", EnumTokenType.FALSE), 
			parsingRange.matchExactly!("null", EnumTokenType.NULL), 
			parsingRange.matchExactly!("public", EnumTokenType.PUBLIC), 
			parsingRange.matchExactly!("private", EnumTokenType.PRIVATE), 
			parsingRange.matchExactly!("protected", EnumTokenType.PROTECTED), 
			parsingRange.matchExactly!("final", EnumTokenType.FINAL), 
			parsingRange.matchExactly!("const", EnumTokenType.CONST), 
			parsingRange.matchExactly!("static", EnumTokenType.STATIC), 
			parsingRange.matchExactly!("override", EnumTokenType.OVERRIDE), 
			parsingRange.matchExactly!("auto", EnumTokenType.AUTO), 
			parsingRange.matchExactly!("void", EnumTokenType.VOID), 
			parsingRange.matchExactly!("char", EnumTokenType.CHAR), 
			parsingRange.matchExactly!("uchar", EnumTokenType.UCHAR), 
			parsingRange.matchExactly!("byte", EnumTokenType.BYTE), 
			parsingRange.matchExactly!("short", EnumTokenType.SHORT), 
			parsingRange.matchExactly!("ushort", EnumTokenType.USHORT), 
			parsingRange.matchExactly!("int", EnumTokenType.INT), 
			parsingRange.matchExactly!("uint", EnumTokenType.UINT), 
			parsingRange.matchExactly!("long", EnumTokenType.LONG), 
			parsingRange.matchExactly!("ulong", EnumTokenType.ULONG)
		].filter!(a => a.match);
		if(matches.empty) throw new TokenizeError("No match patterns", loc);
		auto longest_match = matches.reduce!((a, b)
		{
			if(a.length == b.length)
			{
				if(a.isPerfectMatch && !b.isPerfectMatch) return a;
				else if(!a.isPerfectMatch && b.isPerfectMatch) return b;
				else throw new TokenizeError("Conflicting patterns", loc);
			}
			return a.length > b.length ? a : b;
		});

		if(longest_match.itype != EnumTokenType.__SKIP_PATTERN__)
		{
			tokenList ~= new Token(loc, longest_match.itype, longest_match.matchStr);
		}
		auto lines = longest_match.matchStr.split(ctRegex!r"
");
		foreach(a; lines[0 .. $ - 1])
		{
			loc.col = 1;
			loc.line++;
		}
		loc.col += lines[$ - 1].length;
		parsingRange = parsingRange.drop(longest_match.length);
	}

	tokenList ~= new Token(loc, EnumTokenType.__INPUT_END__, "[EOI]");
	return tokenList.dup;
}
