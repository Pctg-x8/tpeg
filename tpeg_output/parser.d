module com.cterm2.tpeg.sample.calc.parser;

import com.cterm2.tpeg.sample.calc.lexer;
import std.traits;

// header part from tpeg file //
import std.stdio, std.conv;

struct TokenIterator
{
	size_t pos;
	Token[] token;

	size_t toHash() const @safe pure nothrow { return pos; }
	bool opEquals(ref const TokenIterator iter) const @safe pure nothrow
	{
		return pos == iter.pos && token.ptr == iter.token.ptr;
	}
}

struct Result(ValueType)
{
	bool succeeded;
	TokeIterator iterNext;
	static if(!is(ValueType == void)) ValueType value;

	@property bool failed(){ return !succeeded; }
}

public class Grammar
{
			// PEGLoopQualifiedNode: id = <LoopQualified::<Sequential:<::expr:e>,<Action: std.stdio.writeln("  = ", e); >>>
			// PEGSequentialNode id=<Sequential:<::expr:e>,<Action: std.stdio.writeln("  = ", e); >>
			// PEGSequentialNode id=<Sequential:<::term:lhs>,<LoopQualified: :<Switch:<Sequential:< : :PLUS:>,<::term:rhs>,<Action: lhs = lhs + rhs; >>,<Sequential:< : :MINUS:>,<::term:rhs>,<Action: lhs = lhs - rhs; >>>>,<Action: return lhs; >>
			// PEGLoopQualifiedNode: id = <LoopQualified: :<Switch:<Sequential:< : :PLUS:>,<::term:rhs>,<Action: lhs = lhs + rhs; >>,<Sequential:< : :MINUS:>,<::term:rhs>,<Action: lhs = lhs - rhs; >>>>
			// PEGSwitchingNode id=<Switch:<Sequential:< : :PLUS:>,<::term:rhs>,<Action: lhs = lhs + rhs; >>,<Sequential:< : :MINUS:>,<::term:rhs>,<Action: lhs = lhs - rhs; >>>
			// PEGSequentialNode id=<Sequential:< : :PLUS:>,<::term:rhs>,<Action: lhs = lhs + rhs; >>
	private class ElementParser(EnumTokenType ParseE)
	{
		protected alias ResultType = Result!string;
		private static ResultType[TokenIterator] _memo;

		public static auto parse(TokenIterator r)
		{
			if((r in this._memo) is null)
			{
				// register new result
				this._memo[r] = this.innerParse(r);
			}

			return this._memo[r];
		}

		private static auto innerParse(TokenIterator r)
		{
			if(r.current.type == ParseE)
			{
				return ResultType(true, TokenIterator(r.pos + 1, r.token), r.current.text);
			}
			else
			{
				return ResultType(false, r);
			}
		}
	}
	private alias ElementParser_PLUS = ElementParser!(EnumTokenType.PLUS);
			// PEGSequentialNode id=<Sequential:< : :MINUS:>,<::term:rhs>,<Action: lhs = lhs - rhs; >>
	private alias ElementParser_MINUS = ElementParser!(EnumTokenType.MINUS);
			// PEGSequentialNode id=<Sequential:<::factor:lhs>,<LoopQualified: :<Switch:<Sequential:< : :ASTERISK:>,<::factor:rhs>,<Action: lhs = lhs * rhs; >>,<Sequential:< : :SLASH:>,<::factor:rhs>,<Action: lhs = lhs / rhs; >>,<Sequential:< : :PERCENT:>,<::factor:rhs>,<Action: lhs = lhs % rhs; >>>>,<Action: return rhs; >>
			// PEGLoopQualifiedNode: id = <LoopQualified: :<Switch:<Sequential:< : :ASTERISK:>,<::factor:rhs>,<Action: lhs = lhs * rhs; >>,<Sequential:< : :SLASH:>,<::factor:rhs>,<Action: lhs = lhs / rhs; >>,<Sequential:< : :PERCENT:>,<::factor:rhs>,<Action: lhs = lhs % rhs; >>>>
			// PEGSwitchingNode id=<Switch:<Sequential:< : :ASTERISK:>,<::factor:rhs>,<Action: lhs = lhs * rhs; >>,<Sequential:< : :SLASH:>,<::factor:rhs>,<Action: lhs = lhs / rhs; >>,<Sequential:< : :PERCENT:>,<::factor:rhs>,<Action: lhs = lhs % rhs; >>>
			// PEGSequentialNode id=<Sequential:< : :ASTERISK:>,<::factor:rhs>,<Action: lhs = lhs * rhs; >>
	private alias ElementParser_ASTERISK = ElementParser!(EnumTokenType.ASTERISK);
			// PEGSequentialNode id=<Sequential:< : :SLASH:>,<::factor:rhs>,<Action: lhs = lhs / rhs; >>
	private alias ElementParser_SLASH = ElementParser!(EnumTokenType.SLASH);
			// PEGSequentialNode id=<Sequential:< : :PERCENT:>,<::factor:rhs>,<Action: lhs = lhs % rhs; >>
	private alias ElementParser_PERCENT = ElementParser!(EnumTokenType.PERCENT);
			// PEGSwitchingNode id=<Switch:<Sequential:< : :PLUS:>,<::factor:t>,<Action: return t; >>,<Sequential:< : :MINUS:>,<::factor:t>,<Action: return -t; >>,< ::primary:>>
			// PEGSequentialNode id=<Sequential:< : :PLUS:>,<::factor:t>,<Action: return t; >>
			// PEGSequentialNode id=<Sequential:< : :MINUS:>,<::factor:t>,<Action: return -t; >>
			// PEGSwitchingNode id=<Switch:<Sequential:<: :INUMBER:t>,<Action: return t.to!real; >>,< : :FNUMBER:>,<Sequential:< : :LP:>,<::expr:e>,< : :RP:>,<Action: return e; >>>
			// PEGSequentialNode id=<Sequential:<: :INUMBER:t>,<Action: return t.to!real; >>
	private alias ElementParser_INUMBER = ElementParser!(EnumTokenType.INUMBER);
	private alias ElementParser_FNUMBER = ElementParser!(EnumTokenType.FNUMBER);
			// PEGSequentialNode id=<Sequential:< : :LP:>,<::expr:e>,< : :RP:>,<Action: return e; >>
	private alias ElementParser_LP = ElementParser!(EnumTokenType.LP);
	private alias ElementParser_RP = ElementParser!(EnumTokenType.RP);
	public static class calc
	{
		private alias ValueType = ReturnType!__vtype_inferer__;
		private auto __vtype_inferer__()
		{
			// actions...
			// PEGLoopQualifiedNode: id = <LoopQualified::<Sequential:<::expr:e>,<Action: std.stdio.writeln("  = ", e); >>>
			// PEGSequentialNode id=<Sequential:<::expr:e>,<Action: std.stdio.writeln("  = ", e); >>
			{ std.stdio.writeln("  = ", e); }
		}

		private alias ResultType = Result!ValueType;
		private ResultType[TokenIterator] _memo;

		public auto parse(TokenIterator r)
		{
			if((r in this._memo) is null)
			{
				// register new result

				bool succeeded = false;
				static if(is(ValueType == void))
				{
					this.innerParse(r, succeeded);
					this._memo[r] = ResultType(succeeded);
				}
				else
				{
					auto result = this.innerParse(r, succeeded);
					this._memo[r] = ResultType(succeeded, result);
				}
			}

			return this._memo[r];
		}

		private auto innerParse(TokenIterator r, out bool succeeded)
		{
			succeeded = true;

			// parsing rule code here
			// PEGLoopQualifiedNode: id = <LoopQualified::<Sequential:<::expr:e>,<Action: std.stdio.writeln("  = ", e); >>>
			// PEGSequentialNode id=<Sequential:<::expr:e>,<Action: std.stdio.writeln("  = ", e); >>
			static if(!is(ValueType == void)) return ValueType();
		}
	}
	public static class expr
	{
		private alias ResultType = Result!real;
		private ResultType[TokenIterator] _memo;

		public auto parse(TokenIterator r)
		{
			if((r in this._memo) is null)
			{
				// register new result

				bool succeeded = false;
				auto result = this.innerParse(r, succeeded);
				this._memo[r] = ResultType(succeeded, result);
			}

			return this._memo[r];
		}

		private auto innerParse(TokenIterator r, out bool succeeded)
		{
			succeeded = true;

			// parsing rule code here
			// PEGSequentialNode id=<Sequential:<::term:lhs>,<LoopQualified: :<Switch:<Sequential:< : :PLUS:>,<::term:rhs>,<Action: lhs = lhs + rhs; >>,<Sequential:< : :MINUS:>,<::term:rhs>,<Action: lhs = lhs - rhs; >>>>,<Action: return lhs; >>
			// PEGLoopQualifiedNode: id = <LoopQualified: :<Switch:<Sequential:< : :PLUS:>,<::term:rhs>,<Action: lhs = lhs + rhs; >>,<Sequential:< : :MINUS:>,<::term:rhs>,<Action: lhs = lhs - rhs; >>>>
			// PEGSwitchingNode id=<Switch:<Sequential:< : :PLUS:>,<::term:rhs>,<Action: lhs = lhs + rhs; >>,<Sequential:< : :MINUS:>,<::term:rhs>,<Action: lhs = lhs - rhs; >>>
			// PEGSequentialNode id=<Sequential:< : :PLUS:>,<::term:rhs>,<Action: lhs = lhs + rhs; >>
			// PEGSequentialNode id=<Sequential:< : :MINUS:>,<::term:rhs>,<Action: lhs = lhs - rhs; >>
			return real();
		}
	}
	public static class term
	{
		private alias ResultType = Result!real;
		private ResultType[TokenIterator] _memo;

		public auto parse(TokenIterator r)
		{
			if((r in this._memo) is null)
			{
				// register new result

				bool succeeded = false;
				auto result = this.innerParse(r, succeeded);
				this._memo[r] = ResultType(succeeded, result);
			}

			return this._memo[r];
		}

		private auto innerParse(TokenIterator r, out bool succeeded)
		{
			succeeded = true;

			// parsing rule code here
			// PEGSequentialNode id=<Sequential:<::factor:lhs>,<LoopQualified: :<Switch:<Sequential:< : :ASTERISK:>,<::factor:rhs>,<Action: lhs = lhs * rhs; >>,<Sequential:< : :SLASH:>,<::factor:rhs>,<Action: lhs = lhs / rhs; >>,<Sequential:< : :PERCENT:>,<::factor:rhs>,<Action: lhs = lhs % rhs; >>>>,<Action: return rhs; >>
			// PEGLoopQualifiedNode: id = <LoopQualified: :<Switch:<Sequential:< : :ASTERISK:>,<::factor:rhs>,<Action: lhs = lhs * rhs; >>,<Sequential:< : :SLASH:>,<::factor:rhs>,<Action: lhs = lhs / rhs; >>,<Sequential:< : :PERCENT:>,<::factor:rhs>,<Action: lhs = lhs % rhs; >>>>
			// PEGSwitchingNode id=<Switch:<Sequential:< : :ASTERISK:>,<::factor:rhs>,<Action: lhs = lhs * rhs; >>,<Sequential:< : :SLASH:>,<::factor:rhs>,<Action: lhs = lhs / rhs; >>,<Sequential:< : :PERCENT:>,<::factor:rhs>,<Action: lhs = lhs % rhs; >>>
			// PEGSequentialNode id=<Sequential:< : :ASTERISK:>,<::factor:rhs>,<Action: lhs = lhs * rhs; >>
			// PEGSequentialNode id=<Sequential:< : :SLASH:>,<::factor:rhs>,<Action: lhs = lhs / rhs; >>
			// PEGSequentialNode id=<Sequential:< : :PERCENT:>,<::factor:rhs>,<Action: lhs = lhs % rhs; >>
			return real();
		}
	}
	public static class factor
	{
		private alias ResultType = Result!real;
		private ResultType[TokenIterator] _memo;

		public auto parse(TokenIterator r)
		{
			if((r in this._memo) is null)
			{
				// register new result

				bool succeeded = false;
				auto result = this.innerParse(r, succeeded);
				this._memo[r] = ResultType(succeeded, result);
			}

			return this._memo[r];
		}

		private auto innerParse(TokenIterator r, out bool succeeded)
		{
			succeeded = true;

			// parsing rule code here
			// PEGSwitchingNode id=<Switch:<Sequential:< : :PLUS:>,<::factor:t>,<Action: return t; >>,<Sequential:< : :MINUS:>,<::factor:t>,<Action: return -t; >>,< ::primary:>>
			// PEGSequentialNode id=<Sequential:< : :PLUS:>,<::factor:t>,<Action: return t; >>
			// PEGSequentialNode id=<Sequential:< : :MINUS:>,<::factor:t>,<Action: return -t; >>
			return real();
		}
	}
	public static class primary
	{
		private alias ResultType = Result!real;
		private ResultType[TokenIterator] _memo;

		public auto parse(TokenIterator r)
		{
			if((r in this._memo) is null)
			{
				// register new result

				bool succeeded = false;
				auto result = this.innerParse(r, succeeded);
				this._memo[r] = ResultType(succeeded, result);
			}

			return this._memo[r];
		}

		private auto innerParse(TokenIterator r, out bool succeeded)
		{
			succeeded = true;

			// parsing rule code here
			// PEGSwitchingNode id=<Switch:<Sequential:<: :INUMBER:t>,<Action: return t.to!real; >>,< : :FNUMBER:>,<Sequential:< : :LP:>,<::expr:e>,< : :RP:>,<Action: return e; >>>
			// PEGSequentialNode id=<Sequential:<: :INUMBER:t>,<Action: return t.to!real; >>
			// PEGSequentialNode id=<Sequential:< : :LP:>,<::expr:e>,< : :RP:>,<Action: return e; >>
			return real();
		}
	}
}
