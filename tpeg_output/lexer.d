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
	PACKAGE, IMPORT, CLASS, TRAIT, ENUM, EXTENDS, WITH, TEMPLATE, ALIAS, USING, 
	PROPERTY, FUNCTION, IF, ELSE, WHILE, DO, FOREACH, FOR, RETURN, BREAK, CONTINUE, 
	SWITCH, CASE, DEFAULT, TYPEOF, THIS, SUPER, TRUE, FALSE, NULL, PUBLIC, PRIVATE, 
	PROTECTED, FINAL, CONST, STATIC, OVERRIDE, AUTO, VOID, CHAR, UCHAR, BYTE, SHORT, 
	USHORT, INT, UINT, LONG, ULONG, __INPUT_END__
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

	Token[] tokenList;
	auto loc = Location();
	while(!parsingRange.empty)
	{
		auto matches = [
