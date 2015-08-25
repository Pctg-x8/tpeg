module com.cterm2.ml.parser;

import com.cterm2.ml.lexer;
import std.array, std.algorithm;

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
	private static class ComplexParser_Skippable0
	{
		// id=<Skippable:<false:true:package_def:>>
		private alias PartialTreeType = PartialTree!0;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = package_def.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_LoopQualified1
	{
		// id=<LoopQualified:false:<false:true:script_element:>>
		private alias PartialTreeType = PartialTree!1;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = script_element.parse(r);
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
		// id=<Sequential:<Skippable:<false:true:package_def:>>,<LoopQualified:false:<false:true:script_element:>>>
		private alias PartialTreeType = PartialTree!2;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_Skippable0.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

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
	private alias ElementParser_PACKAGE = ElementParser!(EnumTokenType.PACKAGE);
	private alias ElementParser_SEMICOLON = ElementParser!(EnumTokenType.SEMICOLON);
	private static class ComplexParser_Sequential3
	{
		// id=<Sequential:<false:false:PACKAGE:>,<false:true:package_id:>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!3;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PACKAGE.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = package_id.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching4
	{
		// id=<Switch:<false:true:import_decl:>,<false:true:partial_package_def:>,<false:true:class_def:>,<false:true:trait_def:>,<false:true:enum_def:>,<false:true:template_def:>,<false:true:alias_def:>,<false:true:class_body:>>
		private alias PartialTreeType = PartialTree!4;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = import_decl.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = partial_package_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = class_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = trait_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = enum_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = template_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = alias_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = class_body.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_IMPORT = ElementParser!(EnumTokenType.IMPORT);
	private static class ComplexParser_Sequential5
	{
		// id=<Sequential:<false:false:IMPORT:>,<false:true:import_list:>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!5;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_IMPORT.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = import_list.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LB = ElementParser!(EnumTokenType.LB);
	private alias ElementParser_RB = ElementParser!(EnumTokenType.RB);
	private static class ComplexParser_Sequential6
	{
		// id=<Sequential:<false:false:LB:>,<LoopQualified:false:<false:true:script_element:>>,<false:false:RB:>>
		private alias PartialTreeType = PartialTree!6;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified1.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching7
	{
		// id=<Switch:<false:true:script_element:>,<Sequential:<false:false:LB:>,<LoopQualified:false:<false:true:script_element:>>,<false:false:RB:>>>
		private alias PartialTreeType = PartialTree!7;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = script_element.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential6.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential8
	{
		// id=<Sequential:<false:false:PACKAGE:>,<false:true:package_id:>,<Switch:<false:true:script_element:>,<Sequential:<false:false:LB:>,<LoopQualified:false:<false:true:script_element:>>,<false:false:RB:>>>>
		private alias PartialTreeType = PartialTree!8;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PACKAGE.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = package_id.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Switching7.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified9
	{
		// id=<LoopQualified:false:<false:true:class_qualifier:>>
		private alias PartialTreeType = PartialTree!9;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = class_qualifier.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_CLASS = ElementParser!(EnumTokenType.CLASS);
	private alias ElementParser_EXTENDS = ElementParser!(EnumTokenType.EXTENDS);
	private static class ComplexParser_Sequential10
	{
		// id=<Sequential:<false:false:EXTENDS:>,<false:true:type:>>
		private alias PartialTreeType = PartialTree!10;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_EXTENDS.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable11
	{
		// id=<Skippable:<Sequential:<false:false:EXTENDS:>,<false:true:type:>>>
		private alias PartialTreeType = PartialTree!11;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential10.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private alias ElementParser_WITH = ElementParser!(EnumTokenType.WITH);
	private static class ComplexParser_Sequential12
	{
		// id=<Sequential:<false:false:WITH:>,<false:true:type:>>
		private alias PartialTreeType = PartialTree!12;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_WITH.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified13
	{
		// id=<LoopQualified:false:<Sequential:<false:false:WITH:>,<false:true:type:>>>
		private alias PartialTreeType = PartialTree!13;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential12.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching14
	{
		// id=<Switch:<false:true:import_decl:>,<false:true:class_body:>>
		private alias PartialTreeType = PartialTree!14;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = import_decl.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = class_body.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified15
	{
		// id=<LoopQualified:false:<Switch:<false:true:import_decl:>,<false:true:class_body:>>>
		private alias PartialTreeType = PartialTree!15;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching14.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential16
	{
		// id=<Sequential:<false:false:LB:>,<LoopQualified:false:<Switch:<false:true:import_decl:>,<false:true:class_body:>>>,<false:false:RB:>>
		private alias PartialTreeType = PartialTree!16;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified15.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RB.parse(r);
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
		// id=<Switch:<false:false:SEMICOLON:>,<Sequential:<false:false:LB:>,<LoopQualified:false:<Switch:<false:true:import_decl:>,<false:true:class_body:>>>,<false:false:RB:>>>
		private alias PartialTreeType = PartialTree!17;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_SEMICOLON.parse(r);
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
	private static class ComplexParser_Sequential18
	{
		// id=<Sequential:<LoopQualified:false:<false:true:class_qualifier:>>,<false:false:CLASS:>,<false:true:def_id:>,<Skippable:<Sequential:<false:false:EXTENDS:>,<false:true:type:>>>,<LoopQualified:false:<Sequential:<false:false:WITH:>,<false:true:type:>>>,<Switch:<false:false:SEMICOLON:>,<Sequential:<false:false:LB:>,<LoopQualified:false:<Switch:<false:true:import_decl:>,<false:true:class_body:>>>,<false:false:RB:>>>>
		private alias PartialTreeType = PartialTree!18;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified9.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_CLASS.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = def_id.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable11.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified13.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Switching17.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching19
	{
		// id=<Switch:<false:true:field_def:>,<false:true:method_def:>,<false:true:property_def:>,<false:true:ctor_def:>>
		private alias PartialTreeType = PartialTree!19;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = field_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = method_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = property_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ctor_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified20
	{
		// id=<LoopQualified:false:<false:true:trait_qualifier:>>
		private alias PartialTreeType = PartialTree!20;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = trait_qualifier.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_TRAIT = ElementParser!(EnumTokenType.TRAIT);
	private static class ComplexParser_Switching21
	{
		// id=<Switch:<false:true:import_decl:>,<false:true:trait_body:>>
		private alias PartialTreeType = PartialTree!21;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = import_decl.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = trait_body.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified22
	{
		// id=<LoopQualified:false:<Switch:<false:true:import_decl:>,<false:true:trait_body:>>>
		private alias PartialTreeType = PartialTree!22;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching21.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential23
	{
		// id=<Sequential:<false:false:LB:>,<LoopQualified:false:<Switch:<false:true:import_decl:>,<false:true:trait_body:>>>,<false:false:RB:>>
		private alias PartialTreeType = PartialTree!23;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified22.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching24
	{
		// id=<Switch:<false:false:SEMICOLON:>,<Sequential:<false:false:LB:>,<LoopQualified:false:<Switch:<false:true:import_decl:>,<false:true:trait_body:>>>,<false:false:RB:>>>
		private alias PartialTreeType = PartialTree!24;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential23.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential25
	{
		// id=<Sequential:<LoopQualified:false:<false:true:trait_qualifier:>>,<false:false:TRAIT:>,<false:true:def_id:>,<LoopQualified:false:<Sequential:<false:false:WITH:>,<false:true:type:>>>,<Switch:<false:false:SEMICOLON:>,<Sequential:<false:false:LB:>,<LoopQualified:false:<Switch:<false:true:import_decl:>,<false:true:trait_body:>>>,<false:false:RB:>>>>
		private alias PartialTreeType = PartialTree!25;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified20.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_TRAIT.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = def_id.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified13.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Switching24.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching26
	{
		// id=<Switch:<false:true:method_def:>,<false:true:property_def:>,<false:true:ctor_def:>>
		private alias PartialTreeType = PartialTree!26;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = method_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = property_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ctor_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified27
	{
		// id=<LoopQualified:false:<false:true:enum_qualifier:>>
		private alias PartialTreeType = PartialTree!27;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = enum_qualifier.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_ENUM = ElementParser!(EnumTokenType.ENUM);
	private alias ElementParser_IDENTIFIER = ElementParser!(EnumTokenType.IDENTIFIER);
	private static class ComplexParser_LoopQualified28
	{
		// id=<LoopQualified:false:<false:true:import_decl:>>
		private alias PartialTreeType = PartialTree!28;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = import_decl.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable29
	{
		// id=<Skippable:<false:true:enum_body:>>
		private alias PartialTreeType = PartialTree!29;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = enum_body.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential30
	{
		// id=<Sequential:<false:false:LB:>,<LoopQualified:false:<false:true:import_decl:>>,<Skippable:<false:true:enum_body:>>,<LoopQualified:false:<Switch:<false:true:import_decl:>,<false:true:class_body:>>>,<false:false:RB:>>
		private alias PartialTreeType = PartialTree!30;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified28.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable29.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified15.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching31
	{
		// id=<Switch:<false:false:SEMICOLON:>,<Sequential:<false:false:LB:>,<LoopQualified:false:<false:true:import_decl:>>,<Skippable:<false:true:enum_body:>>,<LoopQualified:false:<Switch:<false:true:import_decl:>,<false:true:class_body:>>>,<false:false:RB:>>>
		private alias PartialTreeType = PartialTree!31;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential30.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential32
	{
		// id=<Sequential:<LoopQualified:false:<false:true:enum_qualifier:>>,<false:false:ENUM:>,<false:false:IDENTIFIER:>,<Switch:<false:false:SEMICOLON:>,<Sequential:<false:false:LB:>,<LoopQualified:false:<false:true:import_decl:>>,<Skippable:<false:true:enum_body:>>,<LoopQualified:false:<Switch:<false:true:import_decl:>,<false:true:class_body:>>>,<false:false:RB:>>>>
		private alias PartialTreeType = PartialTree!32;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified27.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_ENUM.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Switching31.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_COMMA = ElementParser!(EnumTokenType.COMMA);
	private static class ComplexParser_Sequential33
	{
		// id=<Sequential:<false:false:COMMA:>,<false:true:enum_element:>>
		private alias PartialTreeType = PartialTree!33;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_COMMA.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = enum_element.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified34
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:enum_element:>>>
		private alias PartialTreeType = PartialTree!34;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential33.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching35
	{
		// id=<Switch:<false:false:COMMA:>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!35;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_COMMA.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Skippable36
	{
		// id=<Skippable:<Switch:<false:false:COMMA:>,<false:false:SEMICOLON:>>>
		private alias PartialTreeType = PartialTree!36;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Switching35.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential37
	{
		// id=<Sequential:<false:true:enum_element:>,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:enum_element:>>>,<Skippable:<Switch:<false:false:COMMA:>,<false:false:SEMICOLON:>>>>
		private alias PartialTreeType = PartialTree!37;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = enum_element.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified34.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable36.parse(r);
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
	private static class ComplexParser_Sequential38
	{
		// id=<Sequential:<false:false:LP:>,<false:true:expression_list:>,<false:false:RP:>>
		private alias PartialTreeType = PartialTree!38;
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

			resTemp = expression_list.parse(r);
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
	private static class ComplexParser_Skippable39
	{
		// id=<Skippable:<Sequential:<false:false:LP:>,<false:true:expression_list:>,<false:false:RP:>>>
		private alias PartialTreeType = PartialTree!39;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential38.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential40
	{
		// id=<Sequential:<false:false:IDENTIFIER:>,<Skippable:<Sequential:<false:false:LP:>,<false:true:expression_list:>,<false:false:RP:>>>>
		private alias PartialTreeType = PartialTree!40;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable39.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified41
	{
		// id=<LoopQualified:false:<false:true:template_qualifier:>>
		private alias PartialTreeType = PartialTree!41;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = template_qualifier.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_TEMPLATE = ElementParser!(EnumTokenType.TEMPLATE);
	private static class ComplexParser_Skippable42
	{
		// id=<Skippable:<false:true:template_arg_list:>>
		private alias PartialTreeType = PartialTree!42;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = template_arg_list.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_LoopQualified43
	{
		// id=<LoopQualified:false:<false:true:template_body:>>
		private alias PartialTreeType = PartialTree!43;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = template_body.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential44
	{
		// id=<Sequential:<false:false:LB:>,<LoopQualified:false:<false:true:template_body:>>,<false:false:RB:>>
		private alias PartialTreeType = PartialTree!44;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified43.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching45
	{
		// id=<Switch:<false:false:SEMICOLON:>,<false:true:template_body:>,<Sequential:<false:false:LB:>,<LoopQualified:false:<false:true:template_body:>>,<false:false:RB:>>>
		private alias PartialTreeType = PartialTree!45;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = template_body.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential44.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential46
	{
		// id=<Sequential:<LoopQualified:false:<false:true:template_qualifier:>>,<false:false:TEMPLATE:>,<false:false:IDENTIFIER:>,<false:false:LP:>,<Skippable:<false:true:template_arg_list:>>,<false:false:RP:>,<Switch:<false:false:SEMICOLON:>,<false:true:template_body:>,<Sequential:<false:false:LB:>,<LoopQualified:false:<false:true:template_body:>>,<false:false:RB:>>>>
		private alias PartialTreeType = PartialTree!46;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified41.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_TEMPLATE.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable42.parse(r);
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

			resTemp = ComplexParser_Switching45.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching47
	{
		// id=<Switch:<false:true:import_decl:>,<false:true:class_def:>,<false:true:trait_def:>,<false:true:enum_def:>,<false:true:template_def:>,<false:true:alias_def:>>
		private alias PartialTreeType = PartialTree!47;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = import_decl.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = class_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = trait_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = enum_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = template_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = alias_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified48
	{
		// id=<LoopQualified:false:<false:true:alias_qualifier:>>
		private alias PartialTreeType = PartialTree!48;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = alias_qualifier.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_ALIAS = ElementParser!(EnumTokenType.ALIAS);
	private alias ElementParser_EQUAL = ElementParser!(EnumTokenType.EQUAL);
	private static class ComplexParser_Sequential49
	{
		// id=<Sequential:<false:false:IDENTIFIER:>,<false:false:EQUAL:>,<false:true:type:>>
		private alias PartialTreeType = PartialTree!49;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_EQUAL.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential50
	{
		// id=<Sequential:<false:true:type:>,<false:false:IDENTIFIER:>>
		private alias PartialTreeType = PartialTree!50;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching51
	{
		// id=<Switch:<Sequential:<false:false:IDENTIFIER:>,<false:false:EQUAL:>,<false:true:type:>>,<Sequential:<false:true:type:>,<false:false:IDENTIFIER:>>>
		private alias PartialTreeType = PartialTree!51;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential49.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential50.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential52
	{
		// id=<Sequential:<LoopQualified:false:<false:true:alias_qualifier:>>,<false:false:ALIAS:>,<Switch:<Sequential:<false:false:IDENTIFIER:>,<false:false:EQUAL:>,<false:true:type:>>,<Sequential:<false:true:type:>,<false:false:IDENTIFIER:>>>>
		private alias PartialTreeType = PartialTree!52;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified48.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_ALIAS.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Switching51.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified53
	{
		// id=<LoopQualified:false:<false:true:field_qualifier:>>
		private alias PartialTreeType = PartialTree!53;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = field_qualifier.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential54
	{
		// id=<Sequential:<LoopQualified:false:<false:true:field_qualifier:>>,<false:true:type:>>
		private alias PartialTreeType = PartialTree!54;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified53.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified55
	{
		// id=<LoopQualified:true:<false:true:field_qualifier:>>
		private alias PartialTreeType = PartialTree!55;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = field_qualifier.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(!treeList.empty, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching56
	{
		// id=<Switch:<Sequential:<LoopQualified:false:<false:true:field_qualifier:>>,<false:true:type:>>,<LoopQualified:true:<false:true:field_qualifier:>>>
		private alias PartialTreeType = PartialTree!56;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential54.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_LoopQualified55.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential57
	{
		// id=<Sequential:<Switch:<Sequential:<LoopQualified:false:<false:true:field_qualifier:>>,<false:true:type:>>,<LoopQualified:true:<false:true:field_qualifier:>>>,<false:true:field_def_list:>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!57;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_Switching56.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = field_def_list.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential58
	{
		// id=<Sequential:<false:false:COMMA:>,<false:true:nvpair:>>
		private alias PartialTreeType = PartialTree!58;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_COMMA.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = nvpair.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified59
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:nvpair:>>>
		private alias PartialTreeType = PartialTree!59;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential58.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential60
	{
		// id=<Sequential:<false:true:nvpair:>,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:nvpair:>>>>
		private alias PartialTreeType = PartialTree!60;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = nvpair.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified59.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential61
	{
		// id=<Sequential:<false:false:EQUAL:>,<false:true:expression:>>
		private alias PartialTreeType = PartialTree!61;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_EQUAL.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = expression.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable62
	{
		// id=<Skippable:<Sequential:<false:false:EQUAL:>,<false:true:expression:>>>
		private alias PartialTreeType = PartialTree!62;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential61.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential63
	{
		// id=<Sequential:<false:false:IDENTIFIER:>,<Skippable:<Sequential:<false:false:EQUAL:>,<false:true:expression:>>>>
		private alias PartialTreeType = PartialTree!63;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable62.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching64
	{
		// id=<Switch:<false:true:function_def:>,<false:true:procedure_def:>,<false:true:abstract_method_def:>>
		private alias PartialTreeType = PartialTree!64;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = function_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = procedure_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = abstract_method_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified65
	{
		// id=<LoopQualified:false:<false:true:method_qualifier:>>
		private alias PartialTreeType = PartialTree!65;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = method_qualifier.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential66
	{
		// id=<Sequential:<LoopQualified:false:<false:true:method_qualifier:>>,<false:true:type:>>
		private alias PartialTreeType = PartialTree!66;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified65.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified67
	{
		// id=<LoopQualified:true:<false:true:method_qualifier:>>
		private alias PartialTreeType = PartialTree!67;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = method_qualifier.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(!treeList.empty, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching68
	{
		// id=<Switch:<Sequential:<LoopQualified:false:<false:true:method_qualifier:>>,<false:true:type:>>,<LoopQualified:true:<false:true:method_qualifier:>>>
		private alias PartialTreeType = PartialTree!68;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential66.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_LoopQualified67.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Skippable69
	{
		// id=<Skippable:<false:true:varg_list:>>
		private alias PartialTreeType = PartialTree!69;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = varg_list.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential70
	{
		// id=<Sequential:<Switch:<Sequential:<LoopQualified:false:<false:true:method_qualifier:>>,<false:true:type:>>,<LoopQualified:true:<false:true:method_qualifier:>>>,<false:true:def_id:>,<false:false:LP:>,<Skippable:<false:true:varg_list:>>,<false:false:RP:>,<false:true:statement:>>
		private alias PartialTreeType = PartialTree!70;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_Switching68.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = def_id.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable69.parse(r);
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

			resTemp = statement.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential71
	{
		// id=<Sequential:<Switch:<Sequential:<LoopQualified:false:<false:true:method_qualifier:>>,<false:true:type:>>,<LoopQualified:true:<false:true:method_qualifier:>>>,<false:true:def_id:>,<false:false:LP:>,<Skippable:<false:true:varg_list:>>,<false:false:RP:>,<false:false:EQUAL:>,<false:true:expression:>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!71;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_Switching68.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = def_id.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable69.parse(r);
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

			resTemp = ElementParser_EQUAL.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = expression.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential72
	{
		// id=<Sequential:<Switch:<Sequential:<LoopQualified:false:<false:true:method_qualifier:>>,<false:true:type:>>,<LoopQualified:true:<false:true:method_qualifier:>>>,<false:true:def_id:>,<false:false:LP:>,<Skippable:<false:true:varg_list:>>,<false:false:RP:>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!72;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_Switching68.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = def_id.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable69.parse(r);
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

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching73
	{
		// id=<Switch:<false:true:getter_def:>,<false:true:setter_def:>>
		private alias PartialTreeType = PartialTree!73;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = getter_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = setter_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_PROPERTY = ElementParser!(EnumTokenType.PROPERTY);
	private static class ComplexParser_Skippable74
	{
		// id=<Skippable:<false:true:type:>>
		private alias PartialTreeType = PartialTree!74;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = type.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Switching75
	{
		// id=<Switch:<false:true:statement:>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!75;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = statement.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential76
	{
		// id=<Sequential:<LoopQualified:false:<false:true:method_qualifier:>>,<false:false:PROPERTY:>,<Skippable:<false:true:type:>>,<false:true:def_id:>,<false:false:LP:>,<false:true:type:>,<false:false:IDENTIFIER:>,<false:false:RP:>,<Switch:<false:true:statement:>,<false:false:SEMICOLON:>>>
		private alias PartialTreeType = PartialTree!76;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified65.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_PROPERTY.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable74.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = def_id.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_IDENTIFIER.parse(r);
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

			resTemp = ComplexParser_Switching75.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential77
	{
		// id=<Sequential:<false:false:LP:>,<false:false:RP:>>
		private alias PartialTreeType = PartialTree!77;
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
	private static class ComplexParser_Skippable78
	{
		// id=<Skippable:<Sequential:<false:false:LP:>,<false:false:RP:>>>
		private alias PartialTreeType = PartialTree!78;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential77.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential79
	{
		// id=<Sequential:<false:false:EQUAL:>,<false:true:expression:>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!79;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_EQUAL.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = expression.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching80
	{
		// id=<Switch:<Sequential:<false:false:EQUAL:>,<false:true:expression:>,<false:false:SEMICOLON:>>,<false:true:statement:>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!80;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential79.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = statement.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential81
	{
		// id=<Sequential:<LoopQualified:false:<false:true:method_qualifier:>>,<false:false:PROPERTY:>,<Skippable:<false:true:type:>>,<false:true:def_id:>,<Skippable:<Sequential:<false:false:LP:>,<false:false:RP:>>>,<Switch:<Sequential:<false:false:EQUAL:>,<false:true:expression:>,<false:false:SEMICOLON:>>,<false:true:statement:>,<false:false:SEMICOLON:>>>
		private alias PartialTreeType = PartialTree!81;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified65.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_PROPERTY.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable74.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = def_id.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable78.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Switching80.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified82
	{
		// id=<LoopQualified:false:<false:true:ctor_qualifier:>>
		private alias PartialTreeType = PartialTree!82;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ctor_qualifier.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_THIS = ElementParser!(EnumTokenType.THIS);
	private static class ComplexParser_Sequential83
	{
		// id=<Sequential:<LoopQualified:false:<false:true:ctor_qualifier:>>,<false:false:THIS:>,<false:false:LP:>,<Skippable:<false:true:varg_list:>>,<false:false:RP:>,<Switch:<false:true:statement:>,<false:false:SEMICOLON:>>>
		private alias PartialTreeType = PartialTree!83;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified82.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_THIS.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable69.parse(r);
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

			resTemp = ComplexParser_Switching75.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential84
	{
		// id=<Sequential:<false:true:expression:>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!84;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = expression.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching85
	{
		// id=<Switch:<false:true:if_stmt:>,<false:true:while_stmt:>,<false:true:do_stmt:>,<false:true:foreach_stmt:>,<false:true:for_stmt:>,<false:true:return_stmt:>,<false:true:break_stmt:>,<false:true:continue_stmt:>,<false:true:label_stmt:>,<false:true:switch_stmt:>,<false:true:block_stmt:>,<Sequential:<false:true:expression:>,<false:false:SEMICOLON:>>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!85;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = if_stmt.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = while_stmt.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = do_stmt.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = foreach_stmt.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = for_stmt.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = return_stmt.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = break_stmt.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = continue_stmt.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = label_stmt.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = switch_stmt.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = block_stmt.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential84.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_IF = ElementParser!(EnumTokenType.IF);
	private alias ElementParser_ELSE = ElementParser!(EnumTokenType.ELSE);
	private static class ComplexParser_Sequential86
	{
		// id=<Sequential:<false:false:ELSE:>,<false:true:statement:>>
		private alias PartialTreeType = PartialTree!86;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_ELSE.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = statement.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable87
	{
		// id=<Skippable:<Sequential:<false:false:ELSE:>,<false:true:statement:>>>
		private alias PartialTreeType = PartialTree!87;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential86.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential88
	{
		// id=<Sequential:<false:false:IF:>,<false:false:LP:>,<false:true:expression:>,<false:false:RP:>,<false:true:statement:>,<Skippable:<Sequential:<false:false:ELSE:>,<false:true:statement:>>>>
		private alias PartialTreeType = PartialTree!88;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_IF.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = expression.parse(r);
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

			resTemp = statement.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable87.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_WHILE = ElementParser!(EnumTokenType.WHILE);
	private static class ComplexParser_Sequential89
	{
		// id=<Sequential:<false:false:WHILE:>,<false:false:LP:>,<false:true:expression:>,<false:false:RP:>,<false:true:statement:>>
		private alias PartialTreeType = PartialTree!89;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_WHILE.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = expression.parse(r);
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

			resTemp = statement.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_DO = ElementParser!(EnumTokenType.DO);
	private static class ComplexParser_Sequential90
	{
		// id=<Sequential:<false:false:DO:>,<false:true:statement:>,<false:false:WHILE:>,<false:false:LP:>,<false:true:expression:>,<false:false:RP:>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!90;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_DO.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = statement.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_WHILE.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = expression.parse(r);
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

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_FOREACH = ElementParser!(EnumTokenType.FOREACH);
	private alias ElementParser_LARROW = ElementParser!(EnumTokenType.LARROW);
	private static class ComplexParser_Sequential91
	{
		// id=<Sequential:<false:false:FOREACH:>,<false:false:LP:>,<Skippable:<false:true:type:>>,<false:false:IDENTIFIER:>,<false:false:LARROW:>,<false:true:expression:>,<false:false:RP:>,<false:true:statement:>>
		private alias PartialTreeType = PartialTree!91;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_FOREACH.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable74.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LARROW.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = expression.parse(r);
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

			resTemp = statement.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_FOR = ElementParser!(EnumTokenType.FOR);
	private static class ComplexParser_Skippable92
	{
		// id=<Skippable:<false:true:expression:>>
		private alias PartialTreeType = PartialTree!92;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = expression.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential93
	{
		// id=<Sequential:<false:false:FOR:>,<false:false:LP:>,<Skippable:<false:true:expression:>>,<false:false:SEMICOLON:>,<Skippable:<false:true:expression:>>,<false:false:SEMICOLON:>,<Skippable:<false:true:expression:>>,<false:false:RP:>,<false:true:statement:>>
		private alias PartialTreeType = PartialTree!93;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_FOR.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable92.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable92.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable92.parse(r);
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

			resTemp = statement.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_RETURN = ElementParser!(EnumTokenType.RETURN);
	private static class ComplexParser_Sequential94
	{
		// id=<Sequential:<false:false:RETURN:>,<Skippable:<false:true:expression:>>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!94;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_RETURN.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable92.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_BREAK = ElementParser!(EnumTokenType.BREAK);
	private static class ComplexParser_Skippable95
	{
		// id=<Skippable:<false:false:IDENTIFIER:>>
		private alias PartialTreeType = PartialTree!95;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ElementParser_IDENTIFIER.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential96
	{
		// id=<Sequential:<false:false:BREAK:>,<Skippable:<false:false:IDENTIFIER:>>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!96;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_BREAK.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable95.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_CONTINUE = ElementParser!(EnumTokenType.CONTINUE);
	private static class ComplexParser_Sequential97
	{
		// id=<Sequential:<false:false:CONTINUE:>,<Skippable:<false:false:IDENTIFIER:>>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!97;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_CONTINUE.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable95.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_COLON = ElementParser!(EnumTokenType.COLON);
	private static class ComplexParser_Sequential98
	{
		// id=<Sequential:<false:false:IDENTIFIER:>,<false:false:COLON:>>
		private alias PartialTreeType = PartialTree!98;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_COLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_SWITCH = ElementParser!(EnumTokenType.SWITCH);
	private static class ComplexParser_Switching99
	{
		// id=<Switch:<false:true:case_stmt:>,<false:true:default_stmt:>>
		private alias PartialTreeType = PartialTree!99;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = case_stmt.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = default_stmt.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified100
	{
		// id=<LoopQualified:false:<Switch:<false:true:case_stmt:>,<false:true:default_stmt:>>>
		private alias PartialTreeType = PartialTree!100;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching99.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential101
	{
		// id=<Sequential:<false:false:SWITCH:>,<false:false:LP:>,<false:true:expression:>,<false:false:RP:>,<false:false:LB:>,<LoopQualified:false:<Switch:<false:true:case_stmt:>,<false:true:default_stmt:>>>,<false:false:RB:>>
		private alias PartialTreeType = PartialTree!101;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_SWITCH.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = expression.parse(r);
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

			resTemp = ElementParser_LB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified100.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_CASE = ElementParser!(EnumTokenType.CASE);
	private alias ElementParser_CONST = ElementParser!(EnumTokenType.CONST);
	private static class ComplexParser_Skippable102
	{
		// id=<Skippable:<false:false:CONST:>>
		private alias PartialTreeType = PartialTree!102;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ElementParser_CONST.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential103
	{
		// id=<Sequential:<false:false:IF:>,<false:true:expression:>>
		private alias PartialTreeType = PartialTree!103;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_IF.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = expression.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable104
	{
		// id=<Skippable:<Sequential:<false:false:IF:>,<false:true:expression:>>>
		private alias PartialTreeType = PartialTree!104;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential103.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential105
	{
		// id=<Sequential:<Skippable:<false:false:CONST:>>,<false:true:def_id:>,<false:false:COLON:>,<false:true:type:>,<Skippable:<Sequential:<false:false:IF:>,<false:true:expression:>>>>
		private alias PartialTreeType = PartialTree!105;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_Skippable102.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = def_id.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_COLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable104.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching106
	{
		// id=<Switch:<false:true:expression_list:>,<Sequential:<Skippable:<false:false:CONST:>>,<false:true:def_id:>,<false:false:COLON:>,<false:true:type:>,<Skippable:<Sequential:<false:false:IF:>,<false:true:expression:>>>>>
		private alias PartialTreeType = PartialTree!106;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = expression_list.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential105.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_RARROW2 = ElementParser!(EnumTokenType.RARROW2);
	private static class ComplexParser_Sequential107
	{
		// id=<Sequential:<false:false:CASE:>,<Switch:<false:true:expression_list:>,<Sequential:<Skippable:<false:false:CONST:>>,<false:true:def_id:>,<false:false:COLON:>,<false:true:type:>,<Skippable:<Sequential:<false:false:IF:>,<false:true:expression:>>>>>,<false:false:RARROW2:>,<false:true:statement:>>
		private alias PartialTreeType = PartialTree!107;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_CASE.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Switching106.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RARROW2.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = statement.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_DEFAULT = ElementParser!(EnumTokenType.DEFAULT);
	private static class ComplexParser_Sequential108
	{
		// id=<Sequential:<false:false:DEFAULT:>,<false:false:RARROW2:>,<false:true:statement:>>
		private alias PartialTreeType = PartialTree!108;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_DEFAULT.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RARROW2.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = statement.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LBR = ElementParser!(EnumTokenType.LBR);
	private static class ComplexParser_Switching109
	{
		// id=<Switch:<false:true:localvar_def:>,<false:true:statement:>>
		private alias PartialTreeType = PartialTree!109;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = localvar_def.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = statement.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified110
	{
		// id=<LoopQualified:false:<Switch:<false:true:localvar_def:>,<false:true:statement:>>>
		private alias PartialTreeType = PartialTree!110;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching109.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_RBR = ElementParser!(EnumTokenType.RBR);
	private static class ComplexParser_Sequential111
	{
		// id=<Sequential:<false:false:LBR:>,<LoopQualified:false:<Switch:<false:true:localvar_def:>,<false:true:statement:>>>,<false:false:RBR:>>
		private alias PartialTreeType = PartialTree!111;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LBR.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified110.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RBR.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified112
	{
		// id=<LoopQualified:false:<false:true:lvar_qualifier:>>
		private alias PartialTreeType = PartialTree!112;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = lvar_qualifier.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential113
	{
		// id=<Sequential:<LoopQualified:false:<false:true:lvar_qualifier:>>,<false:true:type:>>
		private alias PartialTreeType = PartialTree!113;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified112.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified114
	{
		// id=<LoopQualified:true:<false:true:lvar_qualifier:>>
		private alias PartialTreeType = PartialTree!114;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = lvar_qualifier.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(!treeList.empty, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching115
	{
		// id=<Switch:<Sequential:<LoopQualified:false:<false:true:lvar_qualifier:>>,<false:true:type:>>,<LoopQualified:true:<false:true:lvar_qualifier:>>>
		private alias PartialTreeType = PartialTree!115;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential113.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_LoopQualified114.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential116
	{
		// id=<Sequential:<Switch:<Sequential:<LoopQualified:false:<false:true:lvar_qualifier:>>,<false:true:type:>>,<LoopQualified:true:<false:true:lvar_qualifier:>>>,<false:true:nvpair:>,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:nvpair:>>>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!116;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_Switching115.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = nvpair.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified59.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential117
	{
		// id=<Sequential:<false:false:COMMA:>,<false:true:expression:>>
		private alias PartialTreeType = PartialTree!117;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_COMMA.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = expression.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified118
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:expression:>>>
		private alias PartialTreeType = PartialTree!118;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential117.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential119
	{
		// id=<Sequential:<false:true:expression:>,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:expression:>>>>
		private alias PartialTreeType = PartialTree!119;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = expression.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified118.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching120
	{
		// id=<Switch:<false:false:EQUAL:>,<false:true:assign_ops:>>
		private alias PartialTreeType = PartialTree!120;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_EQUAL.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = assign_ops.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential121
	{
		// id=<Sequential:<false:true:postfix_expr:>,<Switch:<false:false:EQUAL:>,<false:true:assign_ops:>>,<false:true:expression:>>
		private alias PartialTreeType = PartialTree!121;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = postfix_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Switching120.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = expression.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching122
	{
		// id=<Switch:<Sequential:<false:true:postfix_expr:>,<Switch:<false:false:EQUAL:>,<false:true:assign_ops:>>,<false:true:expression:>>,<false:true:alternate_expr:>>
		private alias PartialTreeType = PartialTree!122;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential121.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = alternate_expr.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_PLUS_EQ = ElementParser!(EnumTokenType.PLUS_EQ);
	private alias ElementParser_MINUS_EQ = ElementParser!(EnumTokenType.MINUS_EQ);
	private alias ElementParser_ASTERISK_EQ = ElementParser!(EnumTokenType.ASTERISK_EQ);
	private alias ElementParser_SLASH_EQ = ElementParser!(EnumTokenType.SLASH_EQ);
	private alias ElementParser_PERCENT_EQ = ElementParser!(EnumTokenType.PERCENT_EQ);
	private alias ElementParser_AMPASAND_EQ = ElementParser!(EnumTokenType.AMPASAND_EQ);
	private alias ElementParser_VL_EQ = ElementParser!(EnumTokenType.VL_EQ);
	private alias ElementParser_CA_EQ = ElementParser!(EnumTokenType.CA_EQ);
	private alias ElementParser_LAB2_EQ = ElementParser!(EnumTokenType.LAB2_EQ);
	private alias ElementParser_RAB2_EQ = ElementParser!(EnumTokenType.RAB2_EQ);
	private static class ComplexParser_Switching123
	{
		// id=<Switch:<false:false:PLUS_EQ:>,<false:false:MINUS_EQ:>,<false:false:ASTERISK_EQ:>,<false:false:SLASH_EQ:>,<false:false:PERCENT_EQ:>,<false:false:AMPASAND_EQ:>,<false:false:VL_EQ:>,<false:false:CA_EQ:>,<false:false:LAB2_EQ:>,<false:false:RAB2_EQ:>>
		private alias PartialTreeType = PartialTree!123;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_PLUS_EQ.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_MINUS_EQ.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_ASTERISK_EQ.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_SLASH_EQ.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_PERCENT_EQ.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_AMPASAND_EQ.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_VL_EQ.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_CA_EQ.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_LAB2_EQ.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_RAB2_EQ.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_QUESTION = ElementParser!(EnumTokenType.QUESTION);
	private static class ComplexParser_Sequential124
	{
		// id=<Sequential:<false:false:QUESTION:>,<false:true:short_expr:>,<false:false:COLON:>,<false:true:short_expr:>>
		private alias PartialTreeType = PartialTree!124;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_QUESTION.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = short_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_COLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = short_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable125
	{
		// id=<Skippable:<Sequential:<false:false:QUESTION:>,<false:true:short_expr:>,<false:false:COLON:>,<false:true:short_expr:>>>
		private alias PartialTreeType = PartialTree!125;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential124.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential126
	{
		// id=<Sequential:<false:true:short_expr:>,<Skippable:<Sequential:<false:false:QUESTION:>,<false:true:short_expr:>,<false:false:COLON:>,<false:true:short_expr:>>>>
		private alias PartialTreeType = PartialTree!126;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = short_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable125.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_AMPASAND2 = ElementParser!(EnumTokenType.AMPASAND2);
	private static class ComplexParser_Sequential127
	{
		// id=<Sequential:<false:false:AMPASAND2:>,<false:true:comp_expr:>>
		private alias PartialTreeType = PartialTree!127;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_AMPASAND2.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = comp_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_VL2 = ElementParser!(EnumTokenType.VL2);
	private static class ComplexParser_Sequential128
	{
		// id=<Sequential:<false:false:VL2:>,<false:true:comp_expr:>>
		private alias PartialTreeType = PartialTree!128;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_VL2.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = comp_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_CA2 = ElementParser!(EnumTokenType.CA2);
	private static class ComplexParser_Sequential129
	{
		// id=<Sequential:<false:false:CA2:>,<false:true:comp_expr:>>
		private alias PartialTreeType = PartialTree!129;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_CA2.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = comp_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching130
	{
		// id=<Switch:<Sequential:<false:false:AMPASAND2:>,<false:true:comp_expr:>>,<Sequential:<false:false:VL2:>,<false:true:comp_expr:>>,<Sequential:<false:false:CA2:>,<false:true:comp_expr:>>>
		private alias PartialTreeType = PartialTree!130;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential127.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential128.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential129.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified131
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:AMPASAND2:>,<false:true:comp_expr:>>,<Sequential:<false:false:VL2:>,<false:true:comp_expr:>>,<Sequential:<false:false:CA2:>,<false:true:comp_expr:>>>>
		private alias PartialTreeType = PartialTree!131;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching130.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential132
	{
		// id=<Sequential:<false:true:comp_expr:>,<LoopQualified:false:<Switch:<Sequential:<false:false:AMPASAND2:>,<false:true:comp_expr:>>,<Sequential:<false:false:VL2:>,<false:true:comp_expr:>>,<Sequential:<false:false:CA2:>,<false:true:comp_expr:>>>>>
		private alias PartialTreeType = PartialTree!132;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = comp_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified131.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LAB = ElementParser!(EnumTokenType.LAB);
	private static class ComplexParser_Sequential133
	{
		// id=<Sequential:<false:false:LAB:>,<false:true:shift_expr:>>
		private alias PartialTreeType = PartialTree!133;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LAB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = shift_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_RAB = ElementParser!(EnumTokenType.RAB);
	private static class ComplexParser_Sequential134
	{
		// id=<Sequential:<false:false:RAB:>,<false:true:shift_expr:>>
		private alias PartialTreeType = PartialTree!134;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_RAB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = shift_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_EQ2 = ElementParser!(EnumTokenType.EQ2);
	private static class ComplexParser_Sequential135
	{
		// id=<Sequential:<false:false:EQ2:>,<false:true:shift_expr:>>
		private alias PartialTreeType = PartialTree!135;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_EQ2.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = shift_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_EX_EQ = ElementParser!(EnumTokenType.EX_EQ);
	private static class ComplexParser_Sequential136
	{
		// id=<Sequential:<false:false:EX_EQ:>,<false:true:shift_expr:>>
		private alias PartialTreeType = PartialTree!136;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_EX_EQ.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = shift_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LAB_EQ = ElementParser!(EnumTokenType.LAB_EQ);
	private static class ComplexParser_Sequential137
	{
		// id=<Sequential:<false:false:LAB_EQ:>,<false:true:shift_expr:>>
		private alias PartialTreeType = PartialTree!137;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LAB_EQ.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = shift_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_RAB_EQ = ElementParser!(EnumTokenType.RAB_EQ);
	private static class ComplexParser_Sequential138
	{
		// id=<Sequential:<false:false:RAB_EQ:>,<false:true:shift_expr:>>
		private alias PartialTreeType = PartialTree!138;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_RAB_EQ.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = shift_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching139
	{
		// id=<Switch:<Sequential:<false:false:LAB:>,<false:true:shift_expr:>>,<Sequential:<false:false:RAB:>,<false:true:shift_expr:>>,<Sequential:<false:false:EQ2:>,<false:true:shift_expr:>>,<Sequential:<false:false:EX_EQ:>,<false:true:shift_expr:>>,<Sequential:<false:false:LAB_EQ:>,<false:true:shift_expr:>>,<Sequential:<false:false:RAB_EQ:>,<false:true:shift_expr:>>>
		private alias PartialTreeType = PartialTree!139;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential133.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential134.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential135.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential136.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential137.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential138.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified140
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:LAB:>,<false:true:shift_expr:>>,<Sequential:<false:false:RAB:>,<false:true:shift_expr:>>,<Sequential:<false:false:EQ2:>,<false:true:shift_expr:>>,<Sequential:<false:false:EX_EQ:>,<false:true:shift_expr:>>,<Sequential:<false:false:LAB_EQ:>,<false:true:shift_expr:>>,<Sequential:<false:false:RAB_EQ:>,<false:true:shift_expr:>>>>
		private alias PartialTreeType = PartialTree!140;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching139.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential141
	{
		// id=<Sequential:<false:true:shift_expr:>,<LoopQualified:false:<Switch:<Sequential:<false:false:LAB:>,<false:true:shift_expr:>>,<Sequential:<false:false:RAB:>,<false:true:shift_expr:>>,<Sequential:<false:false:EQ2:>,<false:true:shift_expr:>>,<Sequential:<false:false:EX_EQ:>,<false:true:shift_expr:>>,<Sequential:<false:false:LAB_EQ:>,<false:true:shift_expr:>>,<Sequential:<false:false:RAB_EQ:>,<false:true:shift_expr:>>>>>
		private alias PartialTreeType = PartialTree!141;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = shift_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified140.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LAB2 = ElementParser!(EnumTokenType.LAB2);
	private static class ComplexParser_Sequential142
	{
		// id=<Sequential:<false:false:LAB2:>,<false:true:bit_expr:>>
		private alias PartialTreeType = PartialTree!142;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LAB2.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = bit_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_RAB2 = ElementParser!(EnumTokenType.RAB2);
	private static class ComplexParser_Sequential143
	{
		// id=<Sequential:<false:false:RAB2:>,<false:true:bit_expr:>>
		private alias PartialTreeType = PartialTree!143;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_RAB2.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = bit_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching144
	{
		// id=<Switch:<Sequential:<false:false:LAB2:>,<false:true:bit_expr:>>,<Sequential:<false:false:RAB2:>,<false:true:bit_expr:>>>
		private alias PartialTreeType = PartialTree!144;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential142.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential143.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified145
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:LAB2:>,<false:true:bit_expr:>>,<Sequential:<false:false:RAB2:>,<false:true:bit_expr:>>>>
		private alias PartialTreeType = PartialTree!145;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching144.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential146
	{
		// id=<Sequential:<false:true:bit_expr:>,<LoopQualified:false:<Switch:<Sequential:<false:false:LAB2:>,<false:true:bit_expr:>>,<Sequential:<false:false:RAB2:>,<false:true:bit_expr:>>>>>
		private alias PartialTreeType = PartialTree!146;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = bit_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified145.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_AMPASAND = ElementParser!(EnumTokenType.AMPASAND);
	private static class ComplexParser_Sequential147
	{
		// id=<Sequential:<false:false:AMPASAND:>,<false:true:a1_expr:>>
		private alias PartialTreeType = PartialTree!147;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_AMPASAND.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = a1_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_VL = ElementParser!(EnumTokenType.VL);
	private static class ComplexParser_Sequential148
	{
		// id=<Sequential:<false:false:VL:>,<false:true:a1_expr:>>
		private alias PartialTreeType = PartialTree!148;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_VL.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = a1_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_CA = ElementParser!(EnumTokenType.CA);
	private static class ComplexParser_Sequential149
	{
		// id=<Sequential:<false:false:CA:>,<false:true:a1_expr:>>
		private alias PartialTreeType = PartialTree!149;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_CA.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = a1_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching150
	{
		// id=<Switch:<Sequential:<false:false:AMPASAND:>,<false:true:a1_expr:>>,<Sequential:<false:false:VL:>,<false:true:a1_expr:>>,<Sequential:<false:false:CA:>,<false:true:a1_expr:>>>
		private alias PartialTreeType = PartialTree!150;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential147.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential148.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential149.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified151
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:AMPASAND:>,<false:true:a1_expr:>>,<Sequential:<false:false:VL:>,<false:true:a1_expr:>>,<Sequential:<false:false:CA:>,<false:true:a1_expr:>>>>
		private alias PartialTreeType = PartialTree!151;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching150.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential152
	{
		// id=<Sequential:<false:true:a1_expr:>,<LoopQualified:false:<Switch:<Sequential:<false:false:AMPASAND:>,<false:true:a1_expr:>>,<Sequential:<false:false:VL:>,<false:true:a1_expr:>>,<Sequential:<false:false:CA:>,<false:true:a1_expr:>>>>>
		private alias PartialTreeType = PartialTree!152;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = a1_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified151.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PLUS = ElementParser!(EnumTokenType.PLUS);
	private static class ComplexParser_Sequential153
	{
		// id=<Sequential:<false:false:PLUS:>,<false:true:a2_expr:>>
		private alias PartialTreeType = PartialTree!153;
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

			resTemp = a2_expr.parse(r);
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
	private static class ComplexParser_Sequential154
	{
		// id=<Sequential:<false:false:MINUS:>,<false:true:a2_expr:>>
		private alias PartialTreeType = PartialTree!154;
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

			resTemp = a2_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching155
	{
		// id=<Switch:<Sequential:<false:false:PLUS:>,<false:true:a2_expr:>>,<Sequential:<false:false:MINUS:>,<false:true:a2_expr:>>>
		private alias PartialTreeType = PartialTree!155;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential153.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential154.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified156
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:PLUS:>,<false:true:a2_expr:>>,<Sequential:<false:false:MINUS:>,<false:true:a2_expr:>>>>
		private alias PartialTreeType = PartialTree!156;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching155.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential157
	{
		// id=<Sequential:<false:true:a2_expr:>,<LoopQualified:false:<Switch:<Sequential:<false:false:PLUS:>,<false:true:a2_expr:>>,<Sequential:<false:false:MINUS:>,<false:true:a2_expr:>>>>>
		private alias PartialTreeType = PartialTree!157;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = a2_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified156.parse(r);
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
	private static class ComplexParser_Sequential158
	{
		// id=<Sequential:<false:false:ASTERISK:>,<false:true:range_expr:>>
		private alias PartialTreeType = PartialTree!158;
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

			resTemp = range_expr.parse(r);
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
	private static class ComplexParser_Sequential159
	{
		// id=<Sequential:<false:false:SLASH:>,<false:true:range_expr:>>
		private alias PartialTreeType = PartialTree!159;
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

			resTemp = range_expr.parse(r);
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
	private static class ComplexParser_Sequential160
	{
		// id=<Sequential:<false:false:PERCENT:>,<false:true:range_expr:>>
		private alias PartialTreeType = PartialTree!160;
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

			resTemp = range_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching161
	{
		// id=<Switch:<Sequential:<false:false:ASTERISK:>,<false:true:range_expr:>>,<Sequential:<false:false:SLASH:>,<false:true:range_expr:>>,<Sequential:<false:false:PERCENT:>,<false:true:range_expr:>>>
		private alias PartialTreeType = PartialTree!161;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential158.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential159.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential160.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified162
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:ASTERISK:>,<false:true:range_expr:>>,<Sequential:<false:false:SLASH:>,<false:true:range_expr:>>,<Sequential:<false:false:PERCENT:>,<false:true:range_expr:>>>>
		private alias PartialTreeType = PartialTree!162;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching161.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential163
	{
		// id=<Sequential:<false:true:range_expr:>,<LoopQualified:false:<Switch:<Sequential:<false:false:ASTERISK:>,<false:true:range_expr:>>,<Sequential:<false:false:SLASH:>,<false:true:range_expr:>>,<Sequential:<false:false:PERCENT:>,<false:true:range_expr:>>>>>
		private alias PartialTreeType = PartialTree!163;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = range_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified162.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PERIOD2 = ElementParser!(EnumTokenType.PERIOD2);
	private static class ComplexParser_Sequential164
	{
		// id=<Sequential:<false:false:PERIOD2:>,<false:true:prefix_expr:>>
		private alias PartialTreeType = PartialTree!164;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PERIOD2.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = prefix_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified165
	{
		// id=<LoopQualified:false:<Sequential:<false:false:PERIOD2:>,<false:true:prefix_expr:>>>
		private alias PartialTreeType = PartialTree!165;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential164.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential166
	{
		// id=<Sequential:<false:true:prefix_expr:>,<LoopQualified:false:<Sequential:<false:false:PERIOD2:>,<false:true:prefix_expr:>>>>
		private alias PartialTreeType = PartialTree!166;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = prefix_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified165.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential167
	{
		// id=<Sequential:<false:false:PLUS:>,<false:true:prefix_expr:>>
		private alias PartialTreeType = PartialTree!167;
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

			resTemp = prefix_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential168
	{
		// id=<Sequential:<false:false:MINUS:>,<false:true:prefix_expr:>>
		private alias PartialTreeType = PartialTree!168;
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

			resTemp = prefix_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PLUS2 = ElementParser!(EnumTokenType.PLUS2);
	private static class ComplexParser_Sequential169
	{
		// id=<Sequential:<false:false:PLUS2:>,<false:true:prefix_expr:>>
		private alias PartialTreeType = PartialTree!169;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PLUS2.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = prefix_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_MINUS2 = ElementParser!(EnumTokenType.MINUS2);
	private static class ComplexParser_Sequential170
	{
		// id=<Sequential:<false:false:MINUS2:>,<false:true:prefix_expr:>>
		private alias PartialTreeType = PartialTree!170;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_MINUS2.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = prefix_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_ASTERISK2 = ElementParser!(EnumTokenType.ASTERISK2);
	private static class ComplexParser_Switching171
	{
		// id=<Switch:<Sequential:<false:false:PLUS:>,<false:true:prefix_expr:>>,<Sequential:<false:false:MINUS:>,<false:true:prefix_expr:>>,<Sequential:<false:false:PLUS2:>,<false:true:prefix_expr:>>,<Sequential:<false:false:MINUS2:>,<false:true:prefix_expr:>>,<false:false:ASTERISK2:>,<false:true:prefix_expr:>,<false:true:postfix_expr:>>
		private alias PartialTreeType = PartialTree!171;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential167.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential168.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential169.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential170.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_ASTERISK2.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = prefix_expr.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = postfix_expr.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential172
	{
		// id=<Sequential:<false:false:LBR:>,<Skippable:<false:true:expression:>>,<false:false:RBR:>>
		private alias PartialTreeType = PartialTree!172;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LBR.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable92.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RBR.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable173
	{
		// id=<Skippable:<false:true:expression_list:>>
		private alias PartialTreeType = PartialTree!173;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = expression_list.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential174
	{
		// id=<Sequential:<false:false:LP:>,<Skippable:<false:true:expression_list:>>,<false:false:RP:>>
		private alias PartialTreeType = PartialTree!174;
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

			resTemp = ComplexParser_Skippable173.parse(r);
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
	private alias ElementParser_PERIOD = ElementParser!(EnumTokenType.PERIOD);
	private static class ComplexParser_Skippable175
	{
		// id=<Skippable:<false:true:template_tail:>>
		private alias PartialTreeType = PartialTree!175;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = template_tail.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential176
	{
		// id=<Sequential:<false:false:PERIOD:>,<false:false:IDENTIFIER:>,<Skippable:<false:true:template_tail:>>>
		private alias PartialTreeType = PartialTree!176;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PERIOD.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable175.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_RARROW = ElementParser!(EnumTokenType.RARROW);
	private static class ComplexParser_Sequential177
	{
		// id=<Sequential:<false:false:LP:>,<false:true:restricted_type:>,<false:false:RP:>>
		private alias PartialTreeType = PartialTree!177;
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

			resTemp = restricted_type.parse(r);
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
	private static class ComplexParser_Switching178
	{
		// id=<Switch:<false:true:single_types:>,<Sequential:<false:false:LP:>,<false:true:restricted_type:>,<false:false:RP:>>>
		private alias PartialTreeType = PartialTree!178;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = single_types.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential177.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential179
	{
		// id=<Sequential:<false:false:RARROW:>,<Switch:<false:true:single_types:>,<Sequential:<false:false:LP:>,<false:true:restricted_type:>,<false:false:RP:>>>>
		private alias PartialTreeType = PartialTree!179;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_RARROW.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Switching178.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching180
	{
		// id=<Switch:<false:false:PLUS2:>,<false:false:MINUS2:>,<false:false:ASTERISK2:>,<Sequential:<false:false:LBR:>,<Skippable:<false:true:expression:>>,<false:false:RBR:>>,<Sequential:<false:false:LP:>,<Skippable:<false:true:expression_list:>>,<false:false:RP:>>,<Sequential:<false:false:PERIOD:>,<false:false:IDENTIFIER:>,<Skippable:<false:true:template_tail:>>>,<Sequential:<false:false:RARROW:>,<Switch:<false:true:single_types:>,<Sequential:<false:false:LP:>,<false:true:restricted_type:>,<false:false:RP:>>>>>
		private alias PartialTreeType = PartialTree!180;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_PLUS2.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_MINUS2.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_ASTERISK2.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential172.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential174.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential176.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential179.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified181
	{
		// id=<LoopQualified:false:<Switch:<false:false:PLUS2:>,<false:false:MINUS2:>,<false:false:ASTERISK2:>,<Sequential:<false:false:LBR:>,<Skippable:<false:true:expression:>>,<false:false:RBR:>>,<Sequential:<false:false:LP:>,<Skippable:<false:true:expression_list:>>,<false:false:RP:>>,<Sequential:<false:false:PERIOD:>,<false:false:IDENTIFIER:>,<Skippable:<false:true:template_tail:>>>,<Sequential:<false:false:RARROW:>,<Switch:<false:true:single_types:>,<Sequential:<false:false:LP:>,<false:true:restricted_type:>,<false:false:RP:>>>>>>
		private alias PartialTreeType = PartialTree!181;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching180.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential182
	{
		// id=<Sequential:<false:true:primary_expr:>,<LoopQualified:false:<Switch:<false:false:PLUS2:>,<false:false:MINUS2:>,<false:false:ASTERISK2:>,<Sequential:<false:false:LBR:>,<Skippable:<false:true:expression:>>,<false:false:RBR:>>,<Sequential:<false:false:LP:>,<Skippable:<false:true:expression_list:>>,<false:false:RP:>>,<Sequential:<false:false:PERIOD:>,<false:false:IDENTIFIER:>,<Skippable:<false:true:template_tail:>>>,<Sequential:<false:false:RARROW:>,<Switch:<false:true:single_types:>,<Sequential:<false:false:LP:>,<false:true:restricted_type:>,<false:false:RP:>>>>>>>
		private alias PartialTreeType = PartialTree!182;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = primary_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified181.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential183
	{
		// id=<Sequential:<false:false:LP:>,<false:true:expression:>,<false:false:RP:>>
		private alias PartialTreeType = PartialTree!183;
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

			resTemp = expression.parse(r);
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
	private static class ComplexParser_Sequential184
	{
		// id=<Sequential:<false:false:IDENTIFIER:>,<Skippable:<false:true:template_tail:>>>
		private alias PartialTreeType = PartialTree!184;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable175.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching185
	{
		// id=<Switch:<false:true:literals:>,<false:true:special_literals:>,<false:true:lambda_expr:>,<Sequential:<false:false:LP:>,<false:true:expression:>,<false:false:RP:>>,<Sequential:<false:false:IDENTIFIER:>,<Skippable:<false:true:template_tail:>>>>
		private alias PartialTreeType = PartialTree!185;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = literals.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = special_literals.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = lambda_expr.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential183.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential184.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_INUMBER = ElementParser!(EnumTokenType.INUMBER);
	private alias ElementParser_HNUMBER = ElementParser!(EnumTokenType.HNUMBER);
	private alias ElementParser_FNUMBER = ElementParser!(EnumTokenType.FNUMBER);
	private alias ElementParser_DNUMBER = ElementParser!(EnumTokenType.DNUMBER);
	private alias ElementParser_NUMBER = ElementParser!(EnumTokenType.NUMBER);
	private alias ElementParser_STRING = ElementParser!(EnumTokenType.STRING);
	private alias ElementParser_CHARACTER = ElementParser!(EnumTokenType.CHARACTER);
	private static class ComplexParser_Switching186
	{
		// id=<Switch:<false:false:INUMBER:>,<false:false:HNUMBER:>,<false:false:FNUMBER:>,<false:false:DNUMBER:>,<false:false:NUMBER:>,<false:false:STRING:>,<false:false:CHARACTER:>,<false:true:function_literal:>,<false:true:array_literal:>>
		private alias PartialTreeType = PartialTree!186;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_INUMBER.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_HNUMBER.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_FNUMBER.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_DNUMBER.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_NUMBER.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_STRING.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_CHARACTER.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = function_literal.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = array_literal.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_FUNCTION = ElementParser!(EnumTokenType.FUNCTION);
	private static class ComplexParser_Skippable187
	{
		// id=<Skippable:<false:true:literal_varg_list:>>
		private alias PartialTreeType = PartialTree!187;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = literal_varg_list.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_LoopQualified188
	{
		// id=<LoopQualified:false:<false:true:statement:>>
		private alias PartialTreeType = PartialTree!188;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = statement.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential189
	{
		// id=<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<Skippable:<false:true:literal_varg_list:>>,<false:false:RP:>,<false:false:LB:>,<LoopQualified:false:<false:true:statement:>>,<false:false:RB:>>
		private alias PartialTreeType = PartialTree!189;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_FUNCTION.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable187.parse(r);
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

			resTemp = ElementParser_LB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified188.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching190
	{
		// id=<Switch:<false:true:expression_list:>,<false:true:assoc_array_element_list:>>
		private alias PartialTreeType = PartialTree!190;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = expression_list.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = assoc_array_element_list.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Skippable191
	{
		// id=<Skippable:<Switch:<false:true:expression_list:>,<false:true:assoc_array_element_list:>>>
		private alias PartialTreeType = PartialTree!191;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Switching190.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential192
	{
		// id=<Sequential:<false:false:LBR:>,<Skippable:<Switch:<false:true:expression_list:>,<false:true:assoc_array_element_list:>>>,<false:false:RBR:>>
		private alias PartialTreeType = PartialTree!192;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LBR.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable191.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RBR.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_SUPER = ElementParser!(EnumTokenType.SUPER);
	private alias ElementParser_TRUE = ElementParser!(EnumTokenType.TRUE);
	private alias ElementParser_FALSE = ElementParser!(EnumTokenType.FALSE);
	private alias ElementParser_NULL = ElementParser!(EnumTokenType.NULL);
	private static class ComplexParser_Switching193
	{
		// id=<Switch:<false:false:THIS:>,<false:false:SUPER:>,<false:false:TRUE:>,<false:false:FALSE:>,<false:false:NULL:>>
		private alias PartialTreeType = PartialTree!193;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_THIS.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_SUPER.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_TRUE.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_FALSE.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_NULL.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential194
	{
		// id=<Sequential:<false:false:LP:>,<Skippable:<false:true:literal_varg_list:>>,<false:false:RP:>>
		private alias PartialTreeType = PartialTree!194;
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

			resTemp = ComplexParser_Skippable187.parse(r);
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
	private static class ComplexParser_Switching195
	{
		// id=<Switch:<false:true:literal_varg:>,<Sequential:<false:false:LP:>,<Skippable:<false:true:literal_varg_list:>>,<false:false:RP:>>>
		private alias PartialTreeType = PartialTree!195;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = literal_varg.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential194.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential196
	{
		// id=<Sequential:<Switch:<false:true:literal_varg:>,<Sequential:<false:false:LP:>,<Skippable:<false:true:literal_varg_list:>>,<false:false:RP:>>>,<false:false:RARROW2:>,<false:true:expression:>>
		private alias PartialTreeType = PartialTree!196;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_Switching195.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RARROW2.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = expression.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential197
	{
		// id=<Sequential:<false:false:COMMA:>,<false:true:template_arg:>>
		private alias PartialTreeType = PartialTree!197;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_COMMA.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = template_arg.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified198
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:template_arg:>>>
		private alias PartialTreeType = PartialTree!198;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential197.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential199
	{
		// id=<Sequential:<false:true:template_arg:>,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:template_arg:>>>>
		private alias PartialTreeType = PartialTree!199;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = template_arg.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified198.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching200
	{
		// id=<Switch:<false:true:type:>,<false:false:CLASS:>,<false:false:ALIAS:>>
		private alias PartialTreeType = PartialTree!200;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = type.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_CLASS.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_ALIAS.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential201
	{
		// id=<Sequential:<Switch:<false:true:type:>,<false:false:CLASS:>,<false:false:ALIAS:>>,<false:false:IDENTIFIER:>>
		private alias PartialTreeType = PartialTree!201;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_Switching200.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching202
	{
		// id=<Switch:<Sequential:<Switch:<false:true:type:>,<false:false:CLASS:>,<false:false:ALIAS:>>,<false:false:IDENTIFIER:>>,<false:false:IDENTIFIER:>>
		private alias PartialTreeType = PartialTree!202;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential201.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential203
	{
		// id=<Sequential:<false:false:EQUAL:>,<false:true:type:>>
		private alias PartialTreeType = PartialTree!203;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_EQUAL.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified204
	{
		// id=<LoopQualified:false:<Sequential:<false:false:EQUAL:>,<false:true:type:>>>
		private alias PartialTreeType = PartialTree!204;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential203.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential205
	{
		// id=<Sequential:<Switch:<Sequential:<Switch:<false:true:type:>,<false:false:CLASS:>,<false:false:ALIAS:>>,<false:false:IDENTIFIER:>>,<false:false:IDENTIFIER:>>,<LoopQualified:false:<Sequential:<false:false:EQUAL:>,<false:true:type:>>>>
		private alias PartialTreeType = PartialTree!205;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_Switching202.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified204.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential206
	{
		// id=<Sequential:<false:false:COMMA:>,<false:true:varg:>>
		private alias PartialTreeType = PartialTree!206;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_COMMA.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = varg.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified207
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:varg:>>>
		private alias PartialTreeType = PartialTree!207;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential206.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential208
	{
		// id=<Sequential:<false:true:varg:>,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:varg:>>>>
		private alias PartialTreeType = PartialTree!208;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = varg.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified207.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable209
	{
		// id=<Skippable:<Sequential:<false:false:IDENTIFIER:>,<Skippable:<Sequential:<false:false:EQUAL:>,<false:true:expression:>>>>>
		private alias PartialTreeType = PartialTree!209;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential63.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private alias ElementParser_PERIOD3 = ElementParser!(EnumTokenType.PERIOD3);
	private static class ComplexParser_Skippable210
	{
		// id=<Skippable:<false:false:PERIOD3:>>
		private alias PartialTreeType = PartialTree!210;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ElementParser_PERIOD3.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential211
	{
		// id=<Sequential:<false:true:type:>,<Skippable:<Sequential:<false:false:IDENTIFIER:>,<Skippable:<Sequential:<false:false:EQUAL:>,<false:true:expression:>>>>>,<Skippable:<false:false:PERIOD3:>>>
		private alias PartialTreeType = PartialTree!211;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable209.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable210.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential212
	{
		// id=<Sequential:<false:false:COMMA:>,<false:true:literal_varg:>>
		private alias PartialTreeType = PartialTree!212;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_COMMA.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = literal_varg.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential213
	{
		// id=<Sequential:<false:true:literal_varg:>,<Sequential:<false:false:COMMA:>,<false:true:literal_varg:>>>
		private alias PartialTreeType = PartialTree!213;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = literal_varg.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Sequential212.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential214
	{
		// id=<Sequential:<Skippable:<false:true:type:>>,<false:false:IDENTIFIER:>,<Skippable:<Sequential:<false:false:EQUAL:>,<false:true:expression:>>>,<Skippable:<false:false:PERIOD3:>>>
		private alias PartialTreeType = PartialTree!214;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_Skippable74.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable62.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable210.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential215
	{
		// id=<Sequential:<false:false:COMMA:>,<false:true:assoc_array_element:>>
		private alias PartialTreeType = PartialTree!215;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_COMMA.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = assoc_array_element.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified216
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:assoc_array_element:>>>
		private alias PartialTreeType = PartialTree!216;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential215.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential217
	{
		// id=<Sequential:<false:true:assoc_array_element:>,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:assoc_array_element:>>>>
		private alias PartialTreeType = PartialTree!217;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = assoc_array_element.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified216.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential218
	{
		// id=<Sequential:<false:true:expression:>,<false:false:COLON:>,<false:true:expression:>>
		private alias PartialTreeType = PartialTree!218;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = expression.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_COLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = expression.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PUBLIC = ElementParser!(EnumTokenType.PUBLIC);
	private alias ElementParser_PRIVATE = ElementParser!(EnumTokenType.PRIVATE);
	private alias ElementParser_FINAL = ElementParser!(EnumTokenType.FINAL);
	private alias ElementParser_STATIC = ElementParser!(EnumTokenType.STATIC);
	private static class ComplexParser_Switching219
	{
		// id=<Switch:<false:false:PUBLIC:>,<false:false:PRIVATE:>,<false:false:FINAL:>,<false:false:STATIC:>>
		private alias PartialTreeType = PartialTree!219;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_PUBLIC.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_PRIVATE.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_FINAL.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_STATIC.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Switching220
	{
		// id=<Switch:<false:false:PUBLIC:>,<false:false:PRIVATE:>,<false:false:STATIC:>>
		private alias PartialTreeType = PartialTree!220;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_PUBLIC.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_PRIVATE.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_STATIC.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Switching221
	{
		// id=<Switch:<false:false:PUBLIC:>,<false:false:PRIVATE:>>
		private alias PartialTreeType = PartialTree!221;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_PUBLIC.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_PRIVATE.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_PROTECTED = ElementParser!(EnumTokenType.PROTECTED);
	private static class ComplexParser_Switching222
	{
		// id=<Switch:<false:false:PUBLIC:>,<false:false:PRIVATE:>,<false:false:PROTECTED:>,<false:false:STATIC:>,<false:false:FINAL:>,<false:false:CONST:>>
		private alias PartialTreeType = PartialTree!222;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_PUBLIC.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_PRIVATE.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_PROTECTED.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_STATIC.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_FINAL.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_CONST.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_OVERRIDE = ElementParser!(EnumTokenType.OVERRIDE);
	private static class ComplexParser_Switching223
	{
		// id=<Switch:<false:false:PUBLIC:>,<false:false:PRIVATE:>,<false:false:PROTECTED:>,<false:false:STATIC:>,<false:false:FINAL:>,<false:false:CONST:>,<false:false:OVERRIDE:>>
		private alias PartialTreeType = PartialTree!223;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_PUBLIC.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_PRIVATE.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_PROTECTED.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_STATIC.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_FINAL.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_CONST.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_OVERRIDE.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Switching224
	{
		// id=<Switch:<false:false:PUBLIC:>,<false:false:PRIVATE:>,<false:false:PROTECTED:>,<false:false:CONST:>>
		private alias PartialTreeType = PartialTree!224;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_PUBLIC.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_PRIVATE.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_PROTECTED.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_CONST.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Switching225
	{
		// id=<Switch:<false:false:PRIVATE:>,<false:false:PROTECTED:>,<false:false:CONST:>,<false:false:STATIC:>>
		private alias PartialTreeType = PartialTree!225;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_PRIVATE.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_PROTECTED.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_CONST.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_STATIC.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Skippable226
	{
		// id=<Skippable:<false:true:def_id_arg_list:>>
		private alias PartialTreeType = PartialTree!226;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = def_id_arg_list.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential227
	{
		// id=<Sequential:<false:false:LBR:>,<Skippable:<false:true:def_id_arg_list:>>,<false:false:RBR:>>
		private alias PartialTreeType = PartialTree!227;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LBR.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable226.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RBR.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable228
	{
		// id=<Skippable:<Sequential:<false:false:LBR:>,<Skippable:<false:true:def_id_arg_list:>>,<false:false:RBR:>>>
		private alias PartialTreeType = PartialTree!228;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential227.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential229
	{
		// id=<Sequential:<false:false:IDENTIFIER:>,<Skippable:<Sequential:<false:false:LBR:>,<Skippable:<false:true:def_id_arg_list:>>,<false:false:RBR:>>>>
		private alias PartialTreeType = PartialTree!229;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable228.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential230
	{
		// id=<Sequential:<false:false:COMMA:>,<false:true:def_id_arg:>>
		private alias PartialTreeType = PartialTree!230;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_COMMA.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = def_id_arg.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified231
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:def_id_arg:>>>
		private alias PartialTreeType = PartialTree!231;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential230.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential232
	{
		// id=<Sequential:<false:true:def_id_arg:>,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:def_id_arg:>>>>
		private alias PartialTreeType = PartialTree!232;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = def_id_arg.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified231.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential233
	{
		// id=<Sequential:<false:false:COLON:>,<false:true:type:>>
		private alias PartialTreeType = PartialTree!233;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_COLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential234
	{
		// id=<Sequential:<false:false:RARROW:>,<false:true:type:>>
		private alias PartialTreeType = PartialTree!234;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_RARROW.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching235
	{
		// id=<Switch:<Sequential:<false:false:EQUAL:>,<false:true:type:>>,<Sequential:<false:false:COLON:>,<false:true:type:>>,<Sequential:<false:false:RARROW:>,<false:true:type:>>>
		private alias PartialTreeType = PartialTree!235;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential203.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential233.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential234.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified236
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:EQUAL:>,<false:true:type:>>,<Sequential:<false:false:COLON:>,<false:true:type:>>,<Sequential:<false:false:RARROW:>,<false:true:type:>>>>
		private alias PartialTreeType = PartialTree!236;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching235.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential237
	{
		// id=<Sequential:<false:false:IDENTIFIER:>,<LoopQualified:false:<Switch:<Sequential:<false:false:EQUAL:>,<false:true:type:>>,<Sequential:<false:false:COLON:>,<false:true:type:>>,<Sequential:<false:false:RARROW:>,<false:true:type:>>>>>
		private alias PartialTreeType = PartialTree!237;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified236.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified238
	{
		// id=<LoopQualified:false:<false:true:type_qualifier:>>
		private alias PartialTreeType = PartialTree!238;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = type_qualifier.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential239
	{
		// id=<Sequential:<LoopQualified:false:<false:true:type_qualifier:>>,<false:true:type_body:>>
		private alias PartialTreeType = PartialTree!239;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified238.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = type_body.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_AUTO = ElementParser!(EnumTokenType.AUTO);
	private static class ComplexParser_Switching240
	{
		// id=<Switch:<false:false:AUTO:>,<false:true:restricted_type:>>
		private alias PartialTreeType = PartialTree!240;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_AUTO.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = restricted_type.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential241
	{
		// id=<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<Skippable:<false:true:varg_list:>>,<false:false:RP:>>
		private alias PartialTreeType = PartialTree!241;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_FUNCTION.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable69.parse(r);
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
	private static class ComplexParser_Skippable242
	{
		// id=<Skippable:<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<Skippable:<false:true:varg_list:>>,<false:false:RP:>>>
		private alias PartialTreeType = PartialTree!242;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential241.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential243
	{
		// id=<Sequential:<Switch:<false:false:AUTO:>,<false:true:restricted_type:>>,<Skippable:<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<Skippable:<false:true:varg_list:>>,<false:false:RP:>>>>
		private alias PartialTreeType = PartialTree!243;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_Switching240.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable242.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified244
	{
		// id=<LoopQualified:false:<Sequential:<false:false:LBR:>,<Skippable:<false:true:expression:>>,<false:false:RBR:>>>
		private alias PartialTreeType = PartialTree!244;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential172.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential245
	{
		// id=<Sequential:<false:true:primitive_types:>,<LoopQualified:false:<Sequential:<false:false:LBR:>,<Skippable:<false:true:expression:>>,<false:false:RBR:>>>>
		private alias PartialTreeType = PartialTree!245;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = primitive_types.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified244.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching246
	{
		// id=<Switch:<false:true:register_types:>,<false:true:template_instance:>,<false:true:__typeof:>>
		private alias PartialTreeType = PartialTree!246;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = register_types.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = template_instance.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = __typeof.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_TYPEOF = ElementParser!(EnumTokenType.TYPEOF);
	private static class ComplexParser_Switching247
	{
		// id=<Switch:<false:true:expression:>,<false:true:restricted_type:>>
		private alias PartialTreeType = PartialTree!247;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = expression.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = restricted_type.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Skippable248
	{
		// id=<Skippable:<Switch:<false:true:expression:>,<false:true:restricted_type:>>>
		private alias PartialTreeType = PartialTree!248;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Switching247.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential249
	{
		// id=<Sequential:<false:false:TYPEOF:>,<false:false:LP:>,<Skippable:<Switch:<false:true:expression:>,<false:true:restricted_type:>>>,<false:false:RP:>>
		private alias PartialTreeType = PartialTree!249;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_TYPEOF.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable248.parse(r);
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
	private alias ElementParser_VOID = ElementParser!(EnumTokenType.VOID);
	private alias ElementParser_CHAR = ElementParser!(EnumTokenType.CHAR);
	private alias ElementParser_UCHAR = ElementParser!(EnumTokenType.UCHAR);
	private alias ElementParser_BYTE = ElementParser!(EnumTokenType.BYTE);
	private alias ElementParser_SHORT = ElementParser!(EnumTokenType.SHORT);
	private alias ElementParser_USHORT = ElementParser!(EnumTokenType.USHORT);
	private alias ElementParser_INT = ElementParser!(EnumTokenType.INT);
	private alias ElementParser_UINT = ElementParser!(EnumTokenType.UINT);
	private alias ElementParser_LONG = ElementParser!(EnumTokenType.LONG);
	private alias ElementParser_ULONG = ElementParser!(EnumTokenType.ULONG);
	private static class ComplexParser_Switching250
	{
		// id=<Switch:<false:false:VOID:>,<false:false:CHAR:>,<false:false:UCHAR:>,<false:false:BYTE:>,<false:false:SHORT:>,<false:false:USHORT:>,<false:false:INT:>,<false:false:UINT:>,<false:false:LONG:>,<false:false:ULONG:>>
		private alias PartialTreeType = PartialTree!250;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_VOID.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_CHAR.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_UCHAR.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_BYTE.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_SHORT.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_USHORT.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_INT.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_UINT.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_LONG.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_ULONG.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_SHARP = ElementParser!(EnumTokenType.SHARP);
	private static class ComplexParser_Sequential251
	{
		// id=<Sequential:<false:false:COMMA:>,<false:true:restricted_type:>>
		private alias PartialTreeType = PartialTree!251;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_COMMA.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = restricted_type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified252
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:restricted_type:>>>
		private alias PartialTreeType = PartialTree!252;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential251.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential253
	{
		// id=<Sequential:<false:true:restricted_type:>,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:restricted_type:>>>>
		private alias PartialTreeType = PartialTree!253;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = restricted_type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified252.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable254
	{
		// id=<Skippable:<Sequential:<false:true:restricted_type:>,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:restricted_type:>>>>>
		private alias PartialTreeType = PartialTree!254;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential253.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential255
	{
		// id=<Sequential:<false:false:LP:>,<Skippable:<Sequential:<false:true:restricted_type:>,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:restricted_type:>>>>>,<false:false:RP:>>
		private alias PartialTreeType = PartialTree!255;
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

			resTemp = ComplexParser_Skippable254.parse(r);
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
	private static class ComplexParser_Switching256
	{
		// id=<Switch:<false:true:single_types:>,<Sequential:<false:false:LP:>,<Skippable:<Sequential:<false:true:restricted_type:>,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:restricted_type:>>>>>,<false:false:RP:>>>
		private alias PartialTreeType = PartialTree!256;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = single_types.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential255.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential257
	{
		// id=<Sequential:<false:false:SHARP:>,<Switch:<false:true:single_types:>,<Sequential:<false:false:LP:>,<Skippable:<Sequential:<false:true:restricted_type:>,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:restricted_type:>>>>>,<false:false:RP:>>>>
		private alias PartialTreeType = PartialTree!257;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_SHARP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Switching256.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching258
	{
		// id=<Switch:<false:false:AUTO:>,<false:true:single_restricted_type:>>
		private alias PartialTreeType = PartialTree!258;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ElementParser_AUTO.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = single_restricted_type.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Switching259
	{
		// id=<Switch:<false:true:register_types:>,<false:false:IDENTIFIER:>>
		private alias PartialTreeType = PartialTree!259;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = register_types.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential260
	{
		// id=<Sequential:<false:false:COMMA:>,<false:true:import_item:>>
		private alias PartialTreeType = PartialTree!260;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_COMMA.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = import_item.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential261
	{
		// id=<Sequential:<false:true:import_item:>,<Sequential:<false:false:COMMA:>,<false:true:import_item:>>>
		private alias PartialTreeType = PartialTree!261;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = import_item.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Sequential260.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential262
	{
		// id=<Sequential:<false:false:PERIOD:>,<false:false:IDENTIFIER:>>
		private alias PartialTreeType = PartialTree!262;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PERIOD.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified263
	{
		// id=<LoopQualified:false:<Sequential:<false:false:PERIOD:>,<false:false:IDENTIFIER:>>>
		private alias PartialTreeType = PartialTree!263;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential262.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential264
	{
		// id=<Sequential:<false:false:PERIOD:>,<false:false:ASTERISK:>>
		private alias PartialTreeType = PartialTree!264;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PERIOD.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_ASTERISK.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential265
	{
		// id=<Sequential:<false:false:PERIOD:>,<false:false:LB:>,<false:true:import_list:>,<false:false:RB:>>
		private alias PartialTreeType = PartialTree!265;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PERIOD.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_LB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = import_list.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_RB.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching266
	{
		// id=<Switch:<Sequential:<false:false:PERIOD:>,<false:false:ASTERISK:>>,<Sequential:<false:false:PERIOD:>,<false:false:LB:>,<false:true:import_list:>,<false:false:RB:>>>
		private alias PartialTreeType = PartialTree!266;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential264.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential265.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Skippable267
	{
		// id=<Skippable:<Switch:<Sequential:<false:false:PERIOD:>,<false:false:ASTERISK:>>,<Sequential:<false:false:PERIOD:>,<false:false:LB:>,<false:true:import_list:>,<false:false:RB:>>>>
		private alias PartialTreeType = PartialTree!267;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Switching266.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, r, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential268
	{
		// id=<Sequential:<false:false:IDENTIFIER:>,<LoopQualified:false:<Sequential:<false:false:PERIOD:>,<false:false:IDENTIFIER:>>>,<Skippable:<Switch:<Sequential:<false:false:PERIOD:>,<false:false:ASTERISK:>>,<Sequential:<false:false:PERIOD:>,<false:false:LB:>,<false:true:import_list:>,<false:false:RB:>>>>>
		private alias PartialTreeType = PartialTree!268;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified263.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable267.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential269
	{
		// id=<Sequential:<false:false:IDENTIFIER:>,<LoopQualified:false:<Sequential:<false:false:PERIOD:>,<false:false:IDENTIFIER:>>>>
		private alias PartialTreeType = PartialTree!269;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified263.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
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
	public alias compilation_unit = RuleParser!("compilation_unit", ComplexParser_Sequential2);
	public alias package_def = RuleParser!("package_def", ComplexParser_Sequential3);
	public alias script_element = RuleParser!("script_element", ComplexParser_Switching4);
	public alias import_decl = RuleParser!("import_decl", ComplexParser_Sequential5);
	public alias partial_package_def = RuleParser!("partial_package_def", ComplexParser_Sequential8);
	public alias class_def = RuleParser!("class_def", ComplexParser_Sequential18);
	public alias class_body = RuleParser!("class_body", ComplexParser_Switching19);
	public alias trait_def = RuleParser!("trait_def", ComplexParser_Sequential25);
	public alias trait_body = RuleParser!("trait_body", ComplexParser_Switching26);
	public alias enum_def = RuleParser!("enum_def", ComplexParser_Sequential32);
	public alias enum_body = RuleParser!("enum_body", ComplexParser_Sequential37);
	public alias enum_element = RuleParser!("enum_element", ComplexParser_Sequential40);
	public alias template_def = RuleParser!("template_def", ComplexParser_Sequential46);
	public alias template_body = RuleParser!("template_body", ComplexParser_Switching47);
	public alias alias_def = RuleParser!("alias_def", ComplexParser_Sequential52);
	public alias field_def = RuleParser!("field_def", ComplexParser_Sequential57);
	public alias field_def_list = RuleParser!("field_def_list", ComplexParser_Sequential60);
	public alias nvpair = RuleParser!("nvpair", ComplexParser_Sequential63);
	public alias method_def = RuleParser!("method_def", ComplexParser_Switching64);
	public alias procedure_def = RuleParser!("procedure_def", ComplexParser_Sequential70);
	public alias function_def = RuleParser!("function_def", ComplexParser_Sequential71);
	public alias abstract_method_def = RuleParser!("abstract_method_def", ComplexParser_Sequential72);
	public alias property_def = RuleParser!("property_def", ComplexParser_Switching73);
	public alias setter_def = RuleParser!("setter_def", ComplexParser_Sequential76);
	public alias getter_def = RuleParser!("getter_def", ComplexParser_Sequential81);
	public alias ctor_def = RuleParser!("ctor_def", ComplexParser_Sequential83);
	public alias statement = RuleParser!("statement", ComplexParser_Switching85);
	public alias if_stmt = RuleParser!("if_stmt", ComplexParser_Sequential88);
	public alias while_stmt = RuleParser!("while_stmt", ComplexParser_Sequential89);
	public alias do_stmt = RuleParser!("do_stmt", ComplexParser_Sequential90);
	public alias foreach_stmt = RuleParser!("foreach_stmt", ComplexParser_Sequential91);
	public alias for_stmt = RuleParser!("for_stmt", ComplexParser_Sequential93);
	public alias return_stmt = RuleParser!("return_stmt", ComplexParser_Sequential94);
	public alias break_stmt = RuleParser!("break_stmt", ComplexParser_Sequential96);
	public alias continue_stmt = RuleParser!("continue_stmt", ComplexParser_Sequential97);
	public alias label_stmt = RuleParser!("label_stmt", ComplexParser_Sequential98);
	public alias switch_stmt = RuleParser!("switch_stmt", ComplexParser_Sequential101);
	public alias case_stmt = RuleParser!("case_stmt", ComplexParser_Sequential107);
	public alias default_stmt = RuleParser!("default_stmt", ComplexParser_Sequential108);
	public alias block_stmt = RuleParser!("block_stmt", ComplexParser_Sequential111);
	public alias localvar_def = RuleParser!("localvar_def", ComplexParser_Sequential116);
	public alias expression_list = RuleParser!("expression_list", ComplexParser_Sequential119);
	public alias expression = RuleParser!("expression", ComplexParser_Switching122);
	public alias assign_ops = RuleParser!("assign_ops", ComplexParser_Switching123);
	public alias alternate_expr = RuleParser!("alternate_expr", ComplexParser_Sequential126);
	public alias short_expr = RuleParser!("short_expr", ComplexParser_Sequential132);
	public alias comp_expr = RuleParser!("comp_expr", ComplexParser_Sequential141);
	public alias shift_expr = RuleParser!("shift_expr", ComplexParser_Sequential146);
	public alias bit_expr = RuleParser!("bit_expr", ComplexParser_Sequential152);
	public alias a1_expr = RuleParser!("a1_expr", ComplexParser_Sequential157);
	public alias a2_expr = RuleParser!("a2_expr", ComplexParser_Sequential163);
	public alias range_expr = RuleParser!("range_expr", ComplexParser_Sequential166);
	public alias prefix_expr = RuleParser!("prefix_expr", ComplexParser_Switching171);
	public alias postfix_expr = RuleParser!("postfix_expr", ComplexParser_Sequential182);
	public alias primary_expr = RuleParser!("primary_expr", ComplexParser_Switching185);
	public alias literals = RuleParser!("literals", ComplexParser_Switching186);
	public alias function_literal = RuleParser!("function_literal", ComplexParser_Sequential189);
	public alias array_literal = RuleParser!("array_literal", ComplexParser_Sequential192);
	public alias special_literals = RuleParser!("special_literals", ComplexParser_Switching193);
	public alias lambda_expr = RuleParser!("lambda_expr", ComplexParser_Sequential196);
	public alias template_arg_list = RuleParser!("template_arg_list", ComplexParser_Sequential199);
	public alias template_arg = RuleParser!("template_arg", ComplexParser_Sequential205);
	public alias varg_list = RuleParser!("varg_list", ComplexParser_Sequential208);
	public alias varg = RuleParser!("varg", ComplexParser_Sequential211);
	public alias literal_varg_list = RuleParser!("literal_varg_list", ComplexParser_Sequential213);
	public alias literal_varg = RuleParser!("literal_varg", ComplexParser_Sequential214);
	public alias assoc_array_element_list = RuleParser!("assoc_array_element_list", ComplexParser_Sequential217);
	public alias assoc_array_element = RuleParser!("assoc_array_element", ComplexParser_Sequential218);
	public alias class_qualifier = RuleParser!("class_qualifier", ComplexParser_Switching219);
	public alias trait_qualifier = RuleParser!("trait_qualifier", ComplexParser_Switching220);
	public alias enum_qualifier = RuleParser!("enum_qualifier", ComplexParser_Switching220);
	public alias template_qualifier = RuleParser!("template_qualifier", ComplexParser_Switching221);
	public alias alias_qualifier = RuleParser!("alias_qualifier", ComplexParser_Switching221);
	public alias type_qualifier = RuleParser!("type_qualifier", ElementParser_CONST);
	public alias field_qualifier = RuleParser!("field_qualifier", ComplexParser_Switching222);
	public alias method_qualifier = RuleParser!("method_qualifier", ComplexParser_Switching223);
	public alias ctor_qualifier = RuleParser!("ctor_qualifier", ComplexParser_Switching224);
	public alias lvar_qualifier = RuleParser!("lvar_qualifier", ComplexParser_Switching225);
	public alias def_id = RuleParser!("def_id", ComplexParser_Sequential229);
	public alias def_id_arg_list = RuleParser!("def_id_arg_list", ComplexParser_Sequential232);
	public alias def_id_arg = RuleParser!("def_id_arg", ComplexParser_Sequential237);
	public alias type = RuleParser!("type", ComplexParser_Sequential239);
	public alias type_body = RuleParser!("type_body", ComplexParser_Sequential243);
	public alias restricted_type = RuleParser!("restricted_type", ComplexParser_Sequential245);
	public alias primitive_types = RuleParser!("primitive_types", ComplexParser_Switching246);
	public alias __typeof = RuleParser!("__typeof", ComplexParser_Sequential249);
	public alias register_types = RuleParser!("register_types", ComplexParser_Switching250);
	public alias template_instance = RuleParser!("template_instance", ComplexParser_Sequential184);
	public alias template_tail = RuleParser!("template_tail", ComplexParser_Sequential257);
	public alias single_types = RuleParser!("single_types", ComplexParser_Switching258);
	public alias single_restricted_type = RuleParser!("single_restricted_type", ComplexParser_Switching259);
	public alias import_list = RuleParser!("import_list", ComplexParser_Sequential261);
	public alias import_item = RuleParser!("import_item", ComplexParser_Sequential268);
	public alias package_id = RuleParser!("package_id", ComplexParser_Sequential269);
}
public auto parse(Token[] tokenList)
{
	auto res = Grammar.compilation_unit.parse(TokenIterator(0, tokenList));
	if(res.failed) return res;
	if(res.iterNext.current.type != EnumTokenType.__INPUT_END__)
	{
		return Grammar.compilation_unit.ResultType(false, res.iterNext, res.iterError);
	}

	TreeReduce.reduce_compilation_unit(cast(RuleTree!"compilation_unit")(res.value));
	return res;
}

public class TreeReduce
{
	private static auto reduce_compilation_unit(RuleTree!"compilation_unit" node) in { assert(node !is null); } body
	{
		if(node.content.child[0].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[0].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[0].child[0]
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_package_def(RuleTree!"package_def" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_script_element(RuleTree!"script_element" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_import_decl(RuleTree!"import_decl" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_partial_package_def(RuleTree!"partial_package_def" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!6)(node.content.child[2].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!6)(node.content.child[2].child[0]);
			foreach(n0; __tree_ref__.child[1].child)
			{
			}
		}
		assert(false);
	}
	private static auto reduce_class_def(RuleTree!"class_def" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[0].child)
		{
		}
		if(node.content.child[3].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[3].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[3].child[0]
		foreach(n0; node.content.child[4].child)
		{
		}
		if((cast(PartialTree!16)(node.content.child[5].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!16)(node.content.child[5].child[0]);
			foreach(n0; __tree_ref__.child[1].child)
			{
			}
		}
		assert(false);
	}
	private static auto reduce_class_body(RuleTree!"class_body" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_trait_def(RuleTree!"trait_def" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[0].child)
		{
		}
		foreach(n0; node.content.child[3].child)
		{
		}
		if((cast(PartialTree!23)(node.content.child[4].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!23)(node.content.child[4].child[0]);
			foreach(n0; __tree_ref__.child[1].child)
			{
			}
		}
		assert(false);
	}
	private static auto reduce_trait_body(RuleTree!"trait_body" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_enum_def(RuleTree!"enum_def" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[0].child)
		{
		}
		if((cast(PartialTree!30)(node.content.child[3].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!30)(node.content.child[3].child[0]);
			foreach(n0; __tree_ref__.child[1].child)
			{
			}
			if(__tree_ref__.child[2].child[0].child.length > 0)
			{
		// HasValue: Reference Base: __tree_ref__.child[2].child[0].child[0]
			}
		// HasValue: Reference Base: __tree_ref__.child[2].child[0]
			foreach(n0; __tree_ref__.child[3].child)
			{
			}
		}
		assert(false);
	}
	private static auto reduce_enum_body(RuleTree!"enum_body" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		if(node.content.child[2].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[2].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[2].child[0]
		assert(false);
	}
	private static auto reduce_enum_element(RuleTree!"enum_element" node) in { assert(node !is null); } body
	{
		if(node.content.child[1].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[1].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[1].child[0]
		assert(false);
	}
	private static auto reduce_template_def(RuleTree!"template_def" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[0].child)
		{
		}
		if(node.content.child[4].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[4].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[4].child[0]
		if((cast(PartialTree!44)(node.content.child[6].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!44)(node.content.child[6].child[0]);
			foreach(n0; __tree_ref__.child[1].child)
			{
			}
		}
		assert(false);
	}
	private static auto reduce_template_body(RuleTree!"template_body" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_alias_def(RuleTree!"alias_def" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[0].child)
		{
		}
		assert(false);
	}
	private static auto reduce_field_def(RuleTree!"field_def" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!54)(node.content.child[0].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!54)(node.content.child[0].child[0]);
			foreach(n0; __tree_ref__.child[0].child)
			{
			}
		}
		else if((cast(PartialTree!55)(node.content.child[0].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!55)(node.content.child[0].child[0]);
			foreach(n0; __tree_ref__.child)
			{
			}
		}
		assert(false);
	}
	private static auto reduce_field_def_list(RuleTree!"field_def_list" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_nvpair(RuleTree!"nvpair" node) in { assert(node !is null); } body
	{
		if(node.content.child[1].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[1].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[1].child[0]
		assert(false);
	}
	private static auto reduce_method_def(RuleTree!"method_def" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_procedure_def(RuleTree!"procedure_def" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!66)(node.content.child[0].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!66)(node.content.child[0].child[0]);
			foreach(n0; __tree_ref__.child[0].child)
			{
			}
		}
		else if((cast(PartialTree!67)(node.content.child[0].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!67)(node.content.child[0].child[0]);
			foreach(n0; __tree_ref__.child)
			{
			}
		}
		if(node.content.child[3].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[3].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[3].child[0]
		assert(false);
	}
	private static auto reduce_function_def(RuleTree!"function_def" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!66)(node.content.child[0].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!66)(node.content.child[0].child[0]);
			foreach(n0; __tree_ref__.child[0].child)
			{
			}
		}
		else if((cast(PartialTree!67)(node.content.child[0].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!67)(node.content.child[0].child[0]);
			foreach(n0; __tree_ref__.child)
			{
			}
		}
		if(node.content.child[3].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[3].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[3].child[0]
		assert(false);
	}
	private static auto reduce_abstract_method_def(RuleTree!"abstract_method_def" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!66)(node.content.child[0].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!66)(node.content.child[0].child[0]);
			foreach(n0; __tree_ref__.child[0].child)
			{
			}
		}
		else if((cast(PartialTree!67)(node.content.child[0].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!67)(node.content.child[0].child[0]);
			foreach(n0; __tree_ref__.child)
			{
			}
		}
		if(node.content.child[3].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[3].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[3].child[0]
		assert(false);
	}
	private static auto reduce_property_def(RuleTree!"property_def" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_setter_def(RuleTree!"setter_def" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[0].child)
		{
		}
		if(node.content.child[2].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[2].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[2].child[0]
		assert(false);
	}
	private static auto reduce_getter_def(RuleTree!"getter_def" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[0].child)
		{
		}
		if(node.content.child[2].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[2].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[2].child[0]
		if(node.content.child[4].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[4].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[4].child[0]
		assert(false);
	}
	private static auto reduce_ctor_def(RuleTree!"ctor_def" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[0].child)
		{
		}
		if(node.content.child[3].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[3].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[3].child[0]
		assert(false);
	}
	private static auto reduce_statement(RuleTree!"statement" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_if_stmt(RuleTree!"if_stmt" node) in { assert(node !is null); } body
	{
		if(node.content.child[5].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[5].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[5].child[0]
		assert(false);
	}
	private static auto reduce_while_stmt(RuleTree!"while_stmt" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_do_stmt(RuleTree!"do_stmt" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_foreach_stmt(RuleTree!"foreach_stmt" node) in { assert(node !is null); } body
	{
		if(node.content.child[2].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[2].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[2].child[0]
		assert(false);
	}
	private static auto reduce_for_stmt(RuleTree!"for_stmt" node) in { assert(node !is null); } body
	{
		if(node.content.child[2].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[2].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[2].child[0]
		if(node.content.child[4].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[4].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[4].child[0]
		if(node.content.child[6].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[6].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[6].child[0]
		assert(false);
	}
	private static auto reduce_return_stmt(RuleTree!"return_stmt" node) in { assert(node !is null); } body
	{
		if(node.content.child[1].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[1].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[1].child[0]
		assert(false);
	}
	private static auto reduce_break_stmt(RuleTree!"break_stmt" node) in { assert(node !is null); } body
	{
		if(node.content.child[1].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[1].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[1].child[0]
		assert(false);
	}
	private static auto reduce_continue_stmt(RuleTree!"continue_stmt" node) in { assert(node !is null); } body
	{
		if(node.content.child[1].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[1].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[1].child[0]
		assert(false);
	}
	private static auto reduce_label_stmt(RuleTree!"label_stmt" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_switch_stmt(RuleTree!"switch_stmt" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[5].child)
		{
		}
		assert(false);
	}
	private static auto reduce_case_stmt(RuleTree!"case_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!105)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!105)(node.content.child[1].child[0]);
			if(__tree_ref__.child[0].child[0].child.length > 0)
			{
		// HasValue: Reference Base: __tree_ref__.child[0].child[0].child[0]
			}
		// HasValue: Reference Base: __tree_ref__.child[0].child[0]
			if(__tree_ref__.child[4].child[0].child.length > 0)
			{
		// HasValue: Reference Base: __tree_ref__.child[4].child[0].child[0]
			}
		// HasValue: Reference Base: __tree_ref__.child[4].child[0]
		}
		assert(false);
	}
	private static auto reduce_default_stmt(RuleTree!"default_stmt" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_block_stmt(RuleTree!"block_stmt" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_localvar_def(RuleTree!"localvar_def" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!113)(node.content.child[0].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!113)(node.content.child[0].child[0]);
			foreach(n0; __tree_ref__.child[0].child)
			{
			}
		}
		else if((cast(PartialTree!114)(node.content.child[0].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!114)(node.content.child[0].child[0]);
			foreach(n0; __tree_ref__.child)
			{
			}
		}
		foreach(n0; node.content.child[2].child)
		{
		}
		assert(false);
	}
	private static auto reduce_expression_list(RuleTree!"expression_list" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_expression(RuleTree!"expression" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!121)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!121)(node.content.child[0]);
		}
		assert(false);
	}
	private static auto reduce_assign_ops(RuleTree!"assign_ops" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_alternate_expr(RuleTree!"alternate_expr" node) in { assert(node !is null); } body
	{
		if(node.content.child[1].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[1].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[1].child[0]
		assert(false);
	}
	private static auto reduce_short_expr(RuleTree!"short_expr" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_comp_expr(RuleTree!"comp_expr" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_shift_expr(RuleTree!"shift_expr" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_bit_expr(RuleTree!"bit_expr" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_a1_expr(RuleTree!"a1_expr" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_a2_expr(RuleTree!"a2_expr" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_range_expr(RuleTree!"range_expr" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_prefix_expr(RuleTree!"prefix_expr" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_postfix_expr(RuleTree!"postfix_expr" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
			if((cast(PartialTree!172)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!172)(n0.child[0]);
				if(__tree_ref__.child[1].child[0].child.length > 0)
				{
		// HasValue: Reference Base: __tree_ref__.child[1].child[0].child[0]
				}
		// HasValue: Reference Base: __tree_ref__.child[1].child[0]
			}
			else if((cast(PartialTree!174)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!174)(n0.child[0]);
				if(__tree_ref__.child[1].child[0].child.length > 0)
				{
		// HasValue: Reference Base: __tree_ref__.child[1].child[0].child[0]
				}
		// HasValue: Reference Base: __tree_ref__.child[1].child[0]
			}
			else if((cast(PartialTree!176)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!176)(n0.child[0]);
				if(__tree_ref__.child[2].child[0].child.length > 0)
				{
		// HasValue: Reference Base: __tree_ref__.child[2].child[0].child[0]
				}
		// HasValue: Reference Base: __tree_ref__.child[2].child[0]
			}
			else if((cast(PartialTree!179)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!179)(n0.child[0]);
			}
		}
		assert(false);
	}
	private static auto reduce_primary_expr(RuleTree!"primary_expr" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!184)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!184)(node.content.child[0]);
			if(__tree_ref__.child[1].child[0].child.length > 0)
			{
		// HasValue: Reference Base: __tree_ref__.child[1].child[0].child[0]
			}
		// HasValue: Reference Base: __tree_ref__.child[1].child[0]
		}
		assert(false);
	}
	private static auto reduce_literals(RuleTree!"literals" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_function_literal(RuleTree!"function_literal" node) in { assert(node !is null); } body
	{
		if(node.content.child[2].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[2].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[2].child[0]
		foreach(n0; node.content.child[5].child)
		{
		}
		assert(false);
	}
	private static auto reduce_array_literal(RuleTree!"array_literal" node) in { assert(node !is null); } body
	{
		if(node.content.child[1].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[1].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[1].child[0]
		assert(false);
	}
	private static auto reduce_special_literals(RuleTree!"special_literals" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_lambda_expr(RuleTree!"lambda_expr" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!194)(node.content.child[0].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!194)(node.content.child[0].child[0]);
			if(__tree_ref__.child[1].child[0].child.length > 0)
			{
		// HasValue: Reference Base: __tree_ref__.child[1].child[0].child[0]
			}
		// HasValue: Reference Base: __tree_ref__.child[1].child[0]
		}
		assert(false);
	}
	private static auto reduce_template_arg_list(RuleTree!"template_arg_list" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_template_arg(RuleTree!"template_arg" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!201)(node.content.child[0].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!201)(node.content.child[0].child[0]);
		}
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_varg_list(RuleTree!"varg_list" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_varg(RuleTree!"varg" node) in { assert(node !is null); } body
	{
		if(node.content.child[1].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[1].child[0].child[0]
			if(node.content.child[1].child[0].child[0].child[1].child[0].child.length > 0)
			{
		// HasValue: Reference Base: node.content.child[1].child[0].child[0].child[1].child[0].child[0]
			}
		// HasValue: Reference Base: node.content.child[1].child[0].child[0].child[1].child[0]
		}
		// HasValue: Reference Base: node.content.child[1].child[0]
		if(node.content.child[2].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[2].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[2].child[0]
		assert(false);
	}
	private static auto reduce_literal_varg_list(RuleTree!"literal_varg_list" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_literal_varg(RuleTree!"literal_varg" node) in { assert(node !is null); } body
	{
		if(node.content.child[0].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[0].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[0].child[0]
		if(node.content.child[2].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[2].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[2].child[0]
		if(node.content.child[3].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[3].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[3].child[0]
		assert(false);
	}
	private static auto reduce_assoc_array_element_list(RuleTree!"assoc_array_element_list" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_assoc_array_element(RuleTree!"assoc_array_element" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_class_qualifier(RuleTree!"class_qualifier" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_trait_qualifier(RuleTree!"trait_qualifier" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_enum_qualifier(RuleTree!"enum_qualifier" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_template_qualifier(RuleTree!"template_qualifier" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_alias_qualifier(RuleTree!"alias_qualifier" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_type_qualifier(RuleTree!"type_qualifier" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_field_qualifier(RuleTree!"field_qualifier" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_method_qualifier(RuleTree!"method_qualifier" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_ctor_qualifier(RuleTree!"ctor_qualifier" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_lvar_qualifier(RuleTree!"lvar_qualifier" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_def_id(RuleTree!"def_id" node) in { assert(node !is null); } body
	{
		if(node.content.child[1].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[1].child[0].child[0]
			if(node.content.child[1].child[0].child[0].child[1].child[0].child.length > 0)
			{
		// HasValue: Reference Base: node.content.child[1].child[0].child[0].child[1].child[0].child[0]
			}
		// HasValue: Reference Base: node.content.child[1].child[0].child[0].child[1].child[0]
		}
		// HasValue: Reference Base: node.content.child[1].child[0]
		assert(false);
	}
	private static auto reduce_def_id_arg_list(RuleTree!"def_id_arg_list" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_def_id_arg(RuleTree!"def_id_arg" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_type(RuleTree!"type" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[0].child)
		{
		}
		assert(false);
	}
	private static auto reduce_type_body(RuleTree!"type_body" node) in { assert(node !is null); } body
	{
		if(node.content.child[1].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[1].child[0].child[0]
			if(node.content.child[1].child[0].child[0].child[2].child[0].child.length > 0)
			{
		// HasValue: Reference Base: node.content.child[1].child[0].child[0].child[2].child[0].child[0]
			}
		// HasValue: Reference Base: node.content.child[1].child[0].child[0].child[2].child[0]
		}
		// HasValue: Reference Base: node.content.child[1].child[0]
		assert(false);
	}
	private static auto reduce_restricted_type(RuleTree!"restricted_type" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
			if(n0.child[1].child[0].child.length > 0)
			{
		// HasValue: Reference Base: n0.child[1].child[0].child[0]
			}
		// HasValue: Reference Base: n0.child[1].child[0]
		}
		assert(false);
	}
	private static auto reduce_primitive_types(RuleTree!"primitive_types" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce___typeof(RuleTree!"__typeof" node) in { assert(node !is null); } body
	{
		if(node.content.child[2].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[2].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[2].child[0]
		assert(false);
	}
	private static auto reduce_register_types(RuleTree!"register_types" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_template_instance(RuleTree!"template_instance" node) in { assert(node !is null); } body
	{
		if(node.content.child[1].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[1].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[1].child[0]
		assert(false);
	}
	private static auto reduce_template_tail(RuleTree!"template_tail" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!255)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!255)(node.content.child[1].child[0]);
			if(__tree_ref__.child[1].child[0].child.length > 0)
			{
		// HasValue: Reference Base: __tree_ref__.child[1].child[0].child[0]
				foreach(n0; __tree_ref__.child[1].child[0].child[0].child[1].child)
				{
				}
			}
		// HasValue: Reference Base: __tree_ref__.child[1].child[0]
		}
		assert(false);
	}
	private static auto reduce_single_types(RuleTree!"single_types" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_single_restricted_type(RuleTree!"single_restricted_type" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_import_list(RuleTree!"import_list" node) in { assert(node !is null); } body
	{
		assert(false);
	}
	private static auto reduce_import_item(RuleTree!"import_item" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		if(node.content.child[2].child[0].child.length > 0)
		{
		// HasValue: Reference Base: node.content.child[2].child[0].child[0]
		}
		// HasValue: Reference Base: node.content.child[2].child[0]
		assert(false);
	}
	private static auto reduce_package_id(RuleTree!"package_id" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
}
