module com.cterm2.tpeg.sample.calc.lexer;

static import std.file;
import std.conv, std.algorithm, std.regex;
import std.array, std.range, std.exception;

public enum EnumTokenType
{
	__SKIP_PATTERN__, INUMBER, FNUMBER, PLUS, MINUS, ASTERISK, SLASH, PERCENT, LP, 
	RP, __INPUT_END__
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

public auto tokenize(string filePath){ return tokenizeStr(std.file.readText(filePath)); }

public auto tokenizeStr(string fileData)
{
	auto parsingRange = fileData[];

	// precompiled regex patterns //
	auto rxSkipPattern1 = ctRegex!r"[ \n\t\r]";
	auto rxSkipPattern2 = ctRegex!r"#[^\n]*\n";
	auto rxINUMBER = ctRegex!r"[0-9]+";
	auto rxFNUMBER = ctRegex!r"[0-9]*\.[0-9]+";

	Token[] tokenList;
	auto loc = Location();
	while(!parsingRange.empty)
	{
		auto matches = [
			parsingRange.matchRegex!(rxSkipPattern1, EnumTokenType.__SKIP_PATTERN__), 
			parsingRange.matchRegex!(rxSkipPattern2, EnumTokenType.__SKIP_PATTERN__), 
			parsingRange.matchRegex!(rxINUMBER, EnumTokenType.INUMBER), 
			parsingRange.matchRegex!(rxFNUMBER, EnumTokenType.FNUMBER), 
			parsingRange.matchExactly!("+", EnumTokenType.PLUS), 
			parsingRange.matchExactly!("-", EnumTokenType.MINUS), 
			parsingRange.matchExactly!("*", EnumTokenType.ASTERISK), 
			parsingRange.matchExactly!("/", EnumTokenType.SLASH), 
			parsingRange.matchExactly!("%", EnumTokenType.PERCENT), 
			parsingRange.matchExactly!("(", EnumTokenType.LP), 
			parsingRange.matchExactly!(")", EnumTokenType.RP)
		].filter!(a => a.match);
		if(matches.empty) throw new TokenizeError("No match patterns", loc);
		auto longest_match = matches.reduce!((a, b)
		{
			if(a.length == b.length) throw new TokenizeError("Conflicting patterns", loc);
			return a.length > b.length ? a : b;
		});

		if(longest_match.itype != EnumTokenType.__SKIP_PATTERN__)
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
		parsingRange = parsingRange.drop(longest_match.length);
	}

	tokenList ~= new Token(loc, EnumTokenType.__INPUT_END__, "[EOI]");
	return tokenList.dup;
}
