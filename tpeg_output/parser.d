module com.cterm2.tpeg.sample.calc.parser;

import com.cterm2.tpeg.sample.calc.lexer;

// header part from tpeg file //
import std.stdio, std.conv;

struct Result(ResultType)
{
	bool succeeded;
	static if(!is(ResultType == void)) ResultType value;

	public this(ResultType t)
	{
		this.succeeded = true;
		this.value = t;
	}

	public @property failed(){ return !succeeded; }
}
auto makeResult(ResultType)(bool suc, ResultType r)
{
	return Result!ResultType(suc, r);
}
auto makeResult(bool suc, lazy void dg)
{
	dg();
	return Result!void(suc);
}
struct TokenRange
{
	immutable(Token[]) innerList;
	size_t currentPos;

	public size_t toHash() const pure @safe nothrow { return this.currentPos; }
	public bool opEquals(ref const TokenRange r) const pure @safe nothrow
	{
		return this.currentPos == r.currentPos;
	}
}

public class Grammar
{
	public static class calc
	{
		private alias ResultType = typeof(parseInternal(TokenRange()));
		private ResultType[TokenRange] _memo;

		public Result!auto parseInternal(TokenRange r)
		{
			return 3;
		}

		public auto parse(TokenRange r)
		{
			if(r in this._memo) return this._memo[r];
			else
			{
				// parsing rule code here


				return ResultType();
			}
		}
	}
	public static class expr
	{
		private alias ResultType = Result;
		private ResultType[TokenRange] _memo;

		public auto parse(TokenRange r)
		{
			if(r in this._memo) return this._memo[r];
			else
			{
				// parsing rule code here
				// PEGSequentialNode: 2 childs.


				return ResultType();
			}
		}
	}
	public static class term
	{
		private alias ResultType = Result;
		private ResultType[TokenRange] _memo;

		public auto parse(TokenRange r)
		{
			if(r in this._memo) return this._memo[r];
			else
			{
				// parsing rule code here
				// PEGSequentialNode: 2 childs.


				return ResultType();
			}
		}
	}
	public static class factor
	{
		private alias ResultType = Result;
		private ResultType[TokenRange] _memo;

		public auto parse(TokenRange r)
		{
			if(r in this._memo) return this._memo[r];
			else
			{
				// parsing rule code here
				// PEGSwitchingNode: 3 childs.


				return ResultType();
			}
		}
	}
	public static class primary
	{
		private alias ResultType = Result;
		private ResultType[TokenRange] _memo;

		public auto parse(TokenRange r)
		{
			if(r in this._memo) return this._memo[r];
			else
			{
				// parsing rule code here
				// PEGSwitchingNode: 3 childs.


				return ResultType();
			}
		}
	}
}
