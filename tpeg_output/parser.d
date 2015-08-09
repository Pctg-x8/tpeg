module com.cterm2.tpeg.sample.calc.parser;

import com.cterm2.tpeg.sample.calc.lexer;
import std.traits, std.algorithm, std.range, std.array;

// header part from tpeg file //
import std.stdio, std.conv;

struct TokenIterator
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

struct Result(ValueType : ISyntaxTree)
{
	bool succeeded;
	TokenIterator iterNext;
	TokenIterator iterError;
	ValueType value;

	@property bool failed(){ return !succeeded; }
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
	public void startReducing();
}
public class RuleTree(string RuleName) : ISyntaxTree
{
	ISyntaxTree _child;

	public override @property Location location(){ return this._child.location; }
	public @property child(){ return this._child; }

	public override void startReducing(){ TreeReduce.reduce(this); }

	public this(ISyntaxTree c)
	{
		this._child = c;
	}
}
public class PartialTree(uint PartialOrdinal) : ISyntaxTree
{
	ISyntaxTree[] children;

	public override @property Location location(){ return this.children.front.location; }

	public override void startReducing(){ TreeReduce.reduce(this); }

	public this(ISyntaxTree[] trees)
	{
		this.children = trees;
	}
}
public class TokenTree : ISyntaxTree
{
	Token _token;

	public override @property Location location(){ return this.token.location; }
	public @property token(){ return this._token; }

	public override void startReducing(){ TreeReduce.reduce(this); }

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
		private alias ResultType = Result!(PartialTree!0);
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree(treeList));
		}
	}
	private static class ComplexParser_LoopQualified1
	{
		// id=<LoopQualified:true:<Sequential:<true:true:expr:e>,<Action: std.stdio.writeln("  = ", e); >>>
		private alias ResultType = Result!(PartialTree!1);
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
			return ResultType(!treeList.empty, r, lastError, new PartialTree(treeList));
		}
	}
	private static class ElementParser(EnumTokenType ParseE)
	{
		protected alias ResultType = Result!TokenTree;
		private static ResultType[TokenIterator] _memo;

		public static auto parse(TokenIterator r)
		{
			if((r in _memo) is null)
			{
				// register new result
				_memo[r] = innerParse(r);
			}

			return _memo[r];
		}

		private static auto innerParse(TokenIterator r)
		{
			if(r.current.type == ParseE)
			{
				return ResultType(true, TokenIterator(r.pos + 1, r.token), TokenIterator(r.pos + 1, r.token), new TokenTree(r.current));
			}
			else
			{
				return ResultType(false, r, TokenIterator(r.pos + 1, r.token));
			}
		}
	}
	private alias ElementParser_PLUS = ElementParser!(EnumTokenType.PLUS);
	private static class ComplexParser_Sequential2
	{
		// id=<Sequential:<false:false:PLUS:>,<true:true:term:rhs>,<Action: lhs = lhs + rhs; >>
		private alias ResultType = Result!(PartialTree!2);
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree(treeList));
		}
	}
	private alias ElementParser_MINUS = ElementParser!(EnumTokenType.MINUS);
	private static class ComplexParser_Sequential3
	{
		// id=<Sequential:<false:false:MINUS:>,<true:true:term:rhs>,<Action: lhs = lhs - rhs; >>
		private alias ResultType = Result!(PartialTree!3);
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree(treeList));
		}
	}
	private static class ComplexParser_Switching4
	{
		// id=<Switch:<Sequential:<false:false:PLUS:>,<true:true:term:rhs>,<Action: lhs = lhs + rhs; >>,<Sequential:<false:false:MINUS:>,<true:true:term:rhs>,<Action: lhs = lhs - rhs; >>>
		private alias ResultType = Result!(PartialTree!4);
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential2.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential3.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified5
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:PLUS:>,<true:true:term:rhs>,<Action: lhs = lhs + rhs; >>,<Sequential:<false:false:MINUS:>,<true:true:term:rhs>,<Action: lhs = lhs - rhs; >>>>
		private alias ResultType = Result!(PartialTree!5);
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching4.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTree(treeList));
		}
	}
	private static class ComplexParser_Sequential6
	{
		// id=<Sequential:<true:true:term:lhs>,<LoopQualified:false:<Switch:<Sequential:<false:false:PLUS:>,<true:true:term:rhs>,<Action: lhs = lhs + rhs; >>,<Sequential:<false:false:MINUS:>,<true:true:term:rhs>,<Action: lhs = lhs - rhs; >>>>,<Action: return lhs; >>
		private alias ResultType = Result!(PartialTree!6);
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

			resTemp = ComplexParser_LoopQualified5.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree(treeList));
		}
	}
	private alias ElementParser_ASTERISK = ElementParser!(EnumTokenType.ASTERISK);
	private static class ComplexParser_Sequential7
	{
		// id=<Sequential:<false:false:ASTERISK:>,<true:true:factor:rhs>,<Action: lhs = lhs * rhs; >>
		private alias ResultType = Result!(PartialTree!7);
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree(treeList));
		}
	}
	private alias ElementParser_SLASH = ElementParser!(EnumTokenType.SLASH);
	private static class ComplexParser_Sequential8
	{
		// id=<Sequential:<false:false:SLASH:>,<true:true:factor:rhs>,<Action: lhs = lhs / rhs; >>
		private alias ResultType = Result!(PartialTree!8);
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree(treeList));
		}
	}
	private alias ElementParser_PERCENT = ElementParser!(EnumTokenType.PERCENT);
	private static class ComplexParser_Sequential9
	{
		// id=<Sequential:<false:false:PERCENT:>,<true:true:factor:rhs>,<Action: lhs = lhs % rhs; >>
		private alias ResultType = Result!(PartialTree!9);
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree(treeList));
		}
	}
	private static class ComplexParser_Switching10
	{
		// id=<Switch:<Sequential:<false:false:ASTERISK:>,<true:true:factor:rhs>,<Action: lhs = lhs * rhs; >>,<Sequential:<false:false:SLASH:>,<true:true:factor:rhs>,<Action: lhs = lhs / rhs; >>,<Sequential:<false:false:PERCENT:>,<true:true:factor:rhs>,<Action: lhs = lhs % rhs; >>>
		private alias ResultType = Result!(PartialTree!10);
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential7.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential8.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential9.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified11
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:ASTERISK:>,<true:true:factor:rhs>,<Action: lhs = lhs * rhs; >>,<Sequential:<false:false:SLASH:>,<true:true:factor:rhs>,<Action: lhs = lhs / rhs; >>,<Sequential:<false:false:PERCENT:>,<true:true:factor:rhs>,<Action: lhs = lhs % rhs; >>>>
		private alias ResultType = Result!(PartialTree!11);
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching10.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTree(treeList));
		}
	}
	private static class ComplexParser_Sequential12
	{
		// id=<Sequential:<true:true:factor:lhs>,<LoopQualified:false:<Switch:<Sequential:<false:false:ASTERISK:>,<true:true:factor:rhs>,<Action: lhs = lhs * rhs; >>,<Sequential:<false:false:SLASH:>,<true:true:factor:rhs>,<Action: lhs = lhs / rhs; >>,<Sequential:<false:false:PERCENT:>,<true:true:factor:rhs>,<Action: lhs = lhs % rhs; >>>>,<Action: return rhs; >>
		private alias ResultType = Result!(PartialTree!12);
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

			resTemp = ComplexParser_LoopQualified11.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree(treeList));
		}
	}
	private static class ComplexParser_Sequential13
	{
		// id=<Sequential:<false:false:PLUS:>,<true:true:factor:t>,<Action: return t; >>
		private alias ResultType = Result!(PartialTree!13);
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree(treeList));
		}
	}
	private static class ComplexParser_Sequential14
	{
		// id=<Sequential:<false:false:MINUS:>,<true:true:factor:t>,<Action: return -t; >>
		private alias ResultType = Result!(PartialTree!14);
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree(treeList));
		}
	}
	private static class ComplexParser_Switching15
	{
		// id=<Switch:<Sequential:<false:false:PLUS:>,<true:true:factor:t>,<Action: return t; >>,<Sequential:<false:false:MINUS:>,<true:true:factor:t>,<Action: return -t; >>,<false:true:primary:>>
		private alias ResultType = Result!(PartialTree!15);
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential13.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential14.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = primary.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_INUMBER = ElementParser!(EnumTokenType.INUMBER);
	private static class ComplexParser_Sequential16
	{
		// id=<Sequential:<true:false:INUMBER:t>,<Action: return t.to!real; >>
		private alias ResultType = Result!(PartialTree!16);
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree(treeList));
		}
	}
	private alias ElementParser_FNUMBER = ElementParser!(EnumTokenType.FNUMBER);
	private alias ElementParser_LP = ElementParser!(EnumTokenType.LP);
	private alias ElementParser_RP = ElementParser!(EnumTokenType.RP);
	private static class ComplexParser_Sequential17
	{
		// id=<Sequential:<false:false:LP:>,<true:true:expr:e>,<false:false:RP:>,<Action: return e; >>
		private alias ResultType = Result!(PartialTree!17);
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree(treeList));
		}
	}
	private static class ComplexParser_Switching18
	{
		// id=<Switch:<Sequential:<true:false:INUMBER:t>,<Action: return t.to!real; >>,<false:false:FNUMBER:>,<Sequential:<false:false:LP:>,<true:true:expr:e>,<false:false:RP:>,<Action: return e; >>>
		private alias ResultType = Result!(PartialTree!18);
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential16.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_FNUMBER.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential17.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTree([resTemp.value]));
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
	public alias calc = RuleParser!("calc", ComplexParser_LoopQualified1);
	public alias expr = RuleParser!("expr", ComplexParser_Sequential6);
	public alias term = RuleParser!("term", ComplexParser_Sequential12);
	public alias factor = RuleParser!("factor", ComplexParser_Switching15);
	public alias primary = RuleParser!("primary", ComplexParser_Switching18);
}

public auto parse(Token[] tokenList)
{
	auto res = Grammar.calc.parse(TokenIterator(0, tokenList));
	if(res.iterNext.current.type != EnumTokenType.__INPUT_END__)
	{
		return Grammar.calc.ResultType(false, res.iterNext, res.iterError);
	}

	res.value.startReducing();
	return res;
}

public class TreeReduce
{
	private alias calcValueT = ReturnType!__infered_calc__;
	private static auto __infered_calc__()
	{
		{ std.stdio.writeln("  = ", e); }
	}
	static if(!is(calcValueT == void)) static calcValueT calc_value;
	static real expr_value;
	static real term_value;
	static real factor_value;
	static real primary_value;

	static void reduce(RuleTree!"calc" tree)
	{
	}
	static void reduce(RuleTree!"expr" tree)
	{
	}
	static void reduce(RuleTree!"term" tree)
	{
	}
	static void reduce(RuleTree!"factor" tree)
	{
	}
	static void reduce(RuleTree!"primary" tree)
	{
	}
}
