module com.cterm2.tpeg.sample.calc.parser;

import com.cterm2.tpeg.sample.calc.lexer;
import std.array, std.algorithm;

// Header part from user tpeg file //
import std.stdio, std.conv;

public struct TokenIterator
{
	size_t pos;
	Token[] token;

	 @property current(){ return pos >= token.length ? token[$ - 1] : token[pos]; }

	size_t toHash() const @safe pure nothrow { return pos; }
	bool opEquals(ref const TokenIterator iter) const @safe pure nothrow
	{
		return pos == iter.pos && token.ptr == iter.token.ptr;
	}
}
public struct Result(ValueType : ISyntaxTree)
{
	bool succeeded;
	TokenIterator iterNext;
	TokenIterator iterError;
	ValueType value;

	 @property failed(){ return !succeeded; }

	auto opAssign(T : ISyntaxTree)(Result!T val)
	{
		this.succeeded = val.succeeded;
		this.iterNext = val.iterNext;
		this.iterError = val.iterError;
		this.value = val.value;
		return this;
	}
}

public interface ISyntaxTree
{
	public @property Location location();
	public @property ISyntaxTree[] child();
}
public class RuleTree(string RuleName) : ISyntaxTree
{
	ISyntaxTree _content;

	public override @property Location location(){ return this._content.location; }
	public override @property ISyntaxTree[] child(){ return [this._content]; }
	public @property content(){ return _content; }
	public @property ruleName(){ return RuleName; }

	public this(ISyntaxTree c)
	{
		this._content = c;
	}
}
public class PartialTree(uint PartialOrdinal) : ISyntaxTree
{
	ISyntaxTree[] _children;

	public override @property Location location(){ return this._children.front.location; }
	public override @property ISyntaxTree[] child(){ return this._children; }
	public @property partialOrdinal(){ return PartialOrdinal; }

	public this(ISyntaxTree[] trees)
	{
		this._children = trees;
	}
}
public class TokenTree : ISyntaxTree
{
	Token _token;

	public override @property Location location(){ return this.token.location; }
	public override @property ISyntaxTree[] child(){ return [null]; }
	public @property token(){ return _token; }

	public this(Token t)
	{
		this._token = t.dup;
	}
}

public class Grammar
{
	private template PartialParserHeader(alias InternalParserMethod)
	{
		private static ResultType[TokenIterator] _memo;

		public static ResultType parse(TokenIterator r)
		{
			if((r in _memo) is null) _memo[r] = InternalParserMethod(r);
			return _memo[r];
		}
	}
	private static class ComplexParser_Sequential0
	{
		// id=<Sequential:<true:true:expr:e>,<Action: std.stdio.writeln("  = ", e); >>
		private alias PartialTreeType = PartialTree!0;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified1
	{
		// id=<LoopQualified:false:<Sequential:<true:true:expr:e>,<Action: std.stdio.writeln("  = ", e); >>>
		private alias PartialTreeType = PartialTree!1;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential0.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential2
	{
		// id=<Sequential:<LoopQualified:false:<Sequential:<true:true:expr:e>,<Action: std.stdio.writeln("  = ", e); >>>,<Action: return; >>
		private alias PartialTreeType = PartialTree!2;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified1.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ElementParser(EnumTokenType ParseE)
	{
		private alias ResultType = Result!TokenTree;
		private static ResultType[TokenIterator] _memo;

		public static ResultType parse(TokenIterator r)
		{
			if((r in _memo) is null)
			{
				// register new result
				if(r.current.type == ParseE)
				{
					_memo[r] = ResultType(true, TokenIterator(r.pos + 1, r.token), TokenIterator(r.pos + 1, r.token), new TokenTree(r.current));
				}
				else
				{
					_memo[r] = ResultType(false, r, TokenIterator(r.pos + 1, r.token));
				}
			}

			return _memo[r];
		}
	}
	private alias ElementParser_PLUS = ElementParser!(EnumTokenType.PLUS);
	private static class ComplexParser_Sequential3
	{
		// id=<Sequential:<false:false:PLUS:>,<true:true:term:rhs>,<Action: lhs = lhs + rhs; >>
		private alias PartialTreeType = PartialTree!3;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PLUS.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = term.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_MINUS = ElementParser!(EnumTokenType.MINUS);
	private static class ComplexParser_Sequential4
	{
		// id=<Sequential:<false:false:MINUS:>,<true:true:term:rhs>,<Action: lhs = lhs - rhs; >>
		private alias PartialTreeType = PartialTree!4;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_MINUS.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = term.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching5
	{
		// id=<Switch:<Sequential:<false:false:PLUS:>,<true:true:term:rhs>,<Action: lhs = lhs + rhs; >>,<Sequential:<false:false:MINUS:>,<true:true:term:rhs>,<Action: lhs = lhs - rhs; >>>
		private alias PartialTreeType = PartialTree!5;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential3.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential4.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified6
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:PLUS:>,<true:true:term:rhs>,<Action: lhs = lhs + rhs; >>,<Sequential:<false:false:MINUS:>,<true:true:term:rhs>,<Action: lhs = lhs - rhs; >>>>
		private alias PartialTreeType = PartialTree!6;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching5.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential7
	{
		// id=<Sequential:<true:true:term:lhs>,<LoopQualified:false:<Switch:<Sequential:<false:false:PLUS:>,<true:true:term:rhs>,<Action: lhs = lhs + rhs; >>,<Sequential:<false:false:MINUS:>,<true:true:term:rhs>,<Action: lhs = lhs - rhs; >>>>,<Action: return lhs; >>
		private alias PartialTreeType = PartialTree!7;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = term.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified6.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_ASTERISK = ElementParser!(EnumTokenType.ASTERISK);
	private static class ComplexParser_Sequential8
	{
		// id=<Sequential:<false:false:ASTERISK:>,<true:true:factor:rhs>,<Action: lhs = lhs * rhs; >>
		private alias PartialTreeType = PartialTree!8;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_ASTERISK.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = factor.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_SLASH = ElementParser!(EnumTokenType.SLASH);
	private static class ComplexParser_Sequential9
	{
		// id=<Sequential:<false:false:SLASH:>,<true:true:factor:rhs>,<Action: lhs = lhs / rhs; >>
		private alias PartialTreeType = PartialTree!9;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_SLASH.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = factor.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PERCENT = ElementParser!(EnumTokenType.PERCENT);
	private static class ComplexParser_Sequential10
	{
		// id=<Sequential:<false:false:PERCENT:>,<true:true:factor:rhs>,<Action: lhs = lhs % rhs; >>
		private alias PartialTreeType = PartialTree!10;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PERCENT.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = factor.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching11
	{
		// id=<Switch:<Sequential:<false:false:ASTERISK:>,<true:true:factor:rhs>,<Action: lhs = lhs * rhs; >>,<Sequential:<false:false:SLASH:>,<true:true:factor:rhs>,<Action: lhs = lhs / rhs; >>,<Sequential:<false:false:PERCENT:>,<true:true:factor:rhs>,<Action: lhs = lhs % rhs; >>>
		private alias PartialTreeType = PartialTree!11;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential8.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential9.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential10.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified12
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:ASTERISK:>,<true:true:factor:rhs>,<Action: lhs = lhs * rhs; >>,<Sequential:<false:false:SLASH:>,<true:true:factor:rhs>,<Action: lhs = lhs / rhs; >>,<Sequential:<false:false:PERCENT:>,<true:true:factor:rhs>,<Action: lhs = lhs % rhs; >>>>
		private alias PartialTreeType = PartialTree!12;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching11.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential13
	{
		// id=<Sequential:<true:true:factor:lhs>,<LoopQualified:false:<Switch:<Sequential:<false:false:ASTERISK:>,<true:true:factor:rhs>,<Action: lhs = lhs * rhs; >>,<Sequential:<false:false:SLASH:>,<true:true:factor:rhs>,<Action: lhs = lhs / rhs; >>,<Sequential:<false:false:PERCENT:>,<true:true:factor:rhs>,<Action: lhs = lhs % rhs; >>>>,<Action: return lhs; >>
		private alias PartialTreeType = PartialTree!13;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = factor.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified12.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential14
	{
		// id=<Sequential:<false:false:PLUS:>,<true:true:factor:t>,<Action: return t; >>
		private alias PartialTreeType = PartialTree!14;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PLUS.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = factor.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential15
	{
		// id=<Sequential:<false:false:MINUS:>,<true:true:factor:t>,<Action: return -t; >>
		private alias PartialTreeType = PartialTree!15;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_MINUS.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = factor.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential16
	{
		// id=<Sequential:<true:true:primary:t>,<Action: return t; >>
		private alias PartialTreeType = PartialTree!16;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = primary.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching17
	{
		// id=<Switch:<Sequential:<false:false:PLUS:>,<true:true:factor:t>,<Action: return t; >>,<Sequential:<false:false:MINUS:>,<true:true:factor:t>,<Action: return -t; >>,<Sequential:<true:true:primary:t>,<Action: return t; >>>
		private alias PartialTreeType = PartialTree!17;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential14.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential15.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential16.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_INUMBER = ElementParser!(EnumTokenType.INUMBER);
	private static class ComplexParser_Sequential18
	{
		// id=<Sequential:<true:false:INUMBER:t>,<Action: return t.to!real; >>
		private alias PartialTreeType = PartialTree!18;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_INUMBER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_FNUMBER = ElementParser!(EnumTokenType.FNUMBER);
	private static class ComplexParser_Sequential19
	{
		// id=<Sequential:<true:false:FNUMBER:t>,<Action: return t.to!real; >>
		private alias PartialTreeType = PartialTree!19;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_FNUMBER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LP = ElementParser!(EnumTokenType.LP);
	private alias ElementParser_RP = ElementParser!(EnumTokenType.RP);
	private static class ComplexParser_Sequential20
	{
		// id=<Sequential:<false:false:LP:>,<true:true:expr:e>,<false:false:RP:>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!20;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching21
	{
		// id=<Switch:<Sequential:<true:false:INUMBER:t>,<Action: return t.to!real; >>,<Sequential:<true:false:FNUMBER:t>,<Action: return t.to!real; >>,<Sequential:<false:false:LP:>,<true:true:expr:e>,<false:false:RP:>,<Action: return e; >>>
		private alias PartialTreeType = PartialTree!21;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential18.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential19.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential20.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class RuleParser(string Name, alias PrimaryParser)
	{
		private alias ResultType = Result!(RuleTree!Name);
		private static ResultType[TokenIterator] _memo;

		public static ResultType parse(TokenIterator r)
		{
			if((r in _memo) is null)
			{
				// register new result
				auto res = PrimaryParser.parse(r);
				if(res.succeeded) _memo[r] = ResultType(true, res.iterNext, res.iterError, new RuleTree!Name(res.value));
				else _memo[r] = ResultType(false, r, res.iterError);
			}

			return _memo[r];
		}
	}
	public alias calc = RuleParser!("calc", ComplexParser_Sequential2);
	public alias expr = RuleParser!("expr", ComplexParser_Sequential7);
	public alias term = RuleParser!("term", ComplexParser_Sequential13);
	public alias factor = RuleParser!("factor", ComplexParser_Switching17);
	public alias primary = RuleParser!("primary", ComplexParser_Switching21);
}
public auto parse(Token[] tokenList)
{
	auto res = Grammar.calc.parse(TokenIterator(0, tokenList));
	if(res.failed) return res;
	if(res.iterNext.current.type != EnumTokenType.__INPUT_END__)
	{
		return Grammar.calc.ResultType(false, res.iterNext, res.iterError);
	}

	TreeReduce.reduce_calc(cast(RuleTree!"calc")(res.value));
	return res;
}

public class TreeReduce
{
	private static auto reduce_calc(RuleTree!"calc" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[0].child)
		{
			auto e = reduce_expr(cast(RuleTree!"expr")(n0.child[0]));
			{  std.stdio.writeln("  = ", e);  }
		}
		{  return;  }
		assert(false);
	}
	private static real reduce_expr(RuleTree!"expr" node) in { assert(node !is null); } body
	{
		auto lhs = reduce_term(cast(RuleTree!"term")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			if((cast(PartialTree!3)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!3)(n0.child[0]);
				auto rhs = reduce_term(cast(RuleTree!"term")(__tree_ref__.child[1]));
				{  lhs = lhs + rhs;  }
			}
			else if((cast(PartialTree!4)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!4)(n0.child[0]);
				auto rhs = reduce_term(cast(RuleTree!"term")(__tree_ref__.child[1]));
				{  lhs = lhs - rhs;  }
			}
		}
		{  return lhs;  }
		assert(false);
	}
	private static real reduce_term(RuleTree!"term" node) in { assert(node !is null); } body
	{
		auto lhs = reduce_factor(cast(RuleTree!"factor")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			if((cast(PartialTree!8)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!8)(n0.child[0]);
				auto rhs = reduce_factor(cast(RuleTree!"factor")(__tree_ref__.child[1]));
				{  lhs = lhs * rhs;  }
			}
			else if((cast(PartialTree!9)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!9)(n0.child[0]);
				auto rhs = reduce_factor(cast(RuleTree!"factor")(__tree_ref__.child[1]));
				{  lhs = lhs / rhs;  }
			}
			else if((cast(PartialTree!10)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!10)(n0.child[0]);
				auto rhs = reduce_factor(cast(RuleTree!"factor")(__tree_ref__.child[1]));
				{  lhs = lhs % rhs;  }
			}
		}
		{  return lhs;  }
		assert(false);
	}
	private static real reduce_factor(RuleTree!"factor" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!14)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!14)(node.content.child[0]);
			auto t = reduce_factor(cast(RuleTree!"factor")(__tree_ref__.child[1]));
			{  return t;  }
		}
		else if((cast(PartialTree!15)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!15)(node.content.child[0]);
			auto t = reduce_factor(cast(RuleTree!"factor")(__tree_ref__.child[1]));
			{  return -t;  }
		}
		else if((cast(PartialTree!16)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!16)(node.content.child[0]);
			auto t = reduce_primary(cast(RuleTree!"primary")(__tree_ref__.child[0]));
			{  return t;  }
		}
		assert(false);
	}
	private static real reduce_primary(RuleTree!"primary" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!18)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!18)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token.text;
			{  return t.to!real;  }
		}
		else if((cast(PartialTree!19)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!19)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token.text;
			{  return t.to!real;  }
		}
		else if((cast(PartialTree!20)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!20)(node.content.child[0]);
			auto e = reduce_expr(cast(RuleTree!"expr")(__tree_ref__.child[1]));
			{  return e;  }
		}
		assert(false);
	}
}
