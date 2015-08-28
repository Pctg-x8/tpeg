module com.cterm2.ml.parser;

import com.cterm2.ml.lexer;
import std.array, std.algorithm;

// Header part from user tpeg file //
import com.cterm2.ml.syntaxTree;
import std.typecons, std.conv;

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
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:EQUAL:>,<true:true:expression:e>,<Action: return new NameValuePair(id.location, id.text, e); >>
		private alias PartialTreeType = PartialTree!61;
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
	private static class ComplexParser_Sequential62
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<Action: return new NameValuePair(id.location, id.text, null); >>
		private alias PartialTreeType = PartialTree!62;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching63
	{
		// id=<Switch:<Sequential:<true:false:IDENTIFIER:id>,<false:false:EQUAL:>,<true:true:expression:e>,<Action: return new NameValuePair(id.location, id.text, e); >>,<Sequential:<true:false:IDENTIFIER:id>,<Action: return new NameValuePair(id.location, id.text, null); >>>
		private alias PartialTreeType = PartialTree!63;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential61.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential62.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
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
		// id=<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:id>,<Action: return new TypeNamePair(t.location, t, id.text); >>
		private alias PartialTreeType = PartialTree!84;
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
	private static class ComplexParser_Sequential85
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<Action: return new TypeNamePair(id.location, null, id.text); >>
		private alias PartialTreeType = PartialTree!85;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching86
	{
		// id=<Switch:<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:id>,<Action: return new TypeNamePair(t.location, t, id.text); >>,<Sequential:<true:false:IDENTIFIER:id>,<Action: return new TypeNamePair(id.location, null, id.text); >>>
		private alias PartialTreeType = PartialTree!86;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential84.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential85.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential87
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:tn_pair:tnp2>,<Action: tnps ~= tnp2; >>
		private alias PartialTreeType = PartialTree!87;
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

			resTemp = tn_pair.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified88
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:tn_pair:tnp2>,<Action: tnps ~= tnp2; >>>
		private alias PartialTreeType = PartialTree!88;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential87.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential89
	{
		// id=<Sequential:<Action: TypeNamePair[] tnps; >,<true:true:tn_pair:tnp>,<Action: tnps ~= tnp; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:tn_pair:tnp2>,<Action: tnps ~= tnp2; >>>,<Action: return tnps; >>
		private alias PartialTreeType = PartialTree!89;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = tn_pair.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified88.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential90
	{
		// id=<Sequential:<true:true:if_stmt:ifs>,<Action: return ifs; >>
		private alias PartialTreeType = PartialTree!90;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = if_stmt.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential91
	{
		// id=<Sequential:<true:true:while_stmt:ws>,<Action: return ws; >>
		private alias PartialTreeType = PartialTree!91;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = while_stmt.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential92
	{
		// id=<Sequential:<true:true:do_stmt:ds>,<Action: return ds; >>
		private alias PartialTreeType = PartialTree!92;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = do_stmt.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential93
	{
		// id=<Sequential:<true:true:foreach_stmt:fes>,<Action: return fes; >>
		private alias PartialTreeType = PartialTree!93;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = foreach_stmt.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential94
	{
		// id=<Sequential:<true:true:for_stmt:fs>,<Action: return fs; >>
		private alias PartialTreeType = PartialTree!94;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = for_stmt.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential95
	{
		// id=<Sequential:<true:true:return_stmt:rs>,<Action: return rs; >>
		private alias PartialTreeType = PartialTree!95;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = return_stmt.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential96
	{
		// id=<Sequential:<true:true:break_stmt:bs>,<Action: return bs; >>
		private alias PartialTreeType = PartialTree!96;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = break_stmt.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential97
	{
		// id=<Sequential:<true:true:continue_stmt:cs>,<Action: return cs; >>
		private alias PartialTreeType = PartialTree!97;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = continue_stmt.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential98
	{
		// id=<Sequential:<true:true:switch_stmt:ss>,<Action: return ss; >>
		private alias PartialTreeType = PartialTree!98;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = switch_stmt.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential99
	{
		// id=<Sequential:<true:true:block_stmt:bls>,<Action: return bls; >>
		private alias PartialTreeType = PartialTree!99;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = block_stmt.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential100
	{
		// id=<Sequential:<true:true:expression:e>,<false:false:SEMICOLON:>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!100;
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
	private static class ComplexParser_Sequential101
	{
		// id=<Sequential:<false:false:SEMICOLON:>,<Action: return null; >>
		private alias PartialTreeType = PartialTree!101;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

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
	private static class ComplexParser_Switching102
	{
		// id=<Switch:<Sequential:<true:true:if_stmt:ifs>,<Action: return ifs; >>,<Sequential:<true:true:while_stmt:ws>,<Action: return ws; >>,<Sequential:<true:true:do_stmt:ds>,<Action: return ds; >>,<Sequential:<true:true:foreach_stmt:fes>,<Action: return fes; >>,<Sequential:<true:true:for_stmt:fs>,<Action: return fs; >>,<Sequential:<true:true:return_stmt:rs>,<Action: return rs; >>,<Sequential:<true:true:break_stmt:bs>,<Action: return bs; >>,<Sequential:<true:true:continue_stmt:cs>,<Action: return cs; >>,<Sequential:<true:true:switch_stmt:ss>,<Action: return ss; >>,<Sequential:<true:true:block_stmt:bls>,<Action: return bls; >>,<Sequential:<true:true:expression:e>,<false:false:SEMICOLON:>,<Action: return e; >>,<Sequential:<false:false:SEMICOLON:>,<Action: return null; >>>
		private alias PartialTreeType = PartialTree!102;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential90.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential91.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential92.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential93.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential94.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential95.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential96.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential97.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential98.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential99.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential100.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential101.parse(r);
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
	private static class ComplexParser_Sequential103
	{
		// id=<Sequential:<true:false:IF:ft>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<true:true:statement:t>,<false:false:ELSE:>,<true:true:statement:n>,<Action: return new ConditionalNode(ft.location, c, t, n); >>
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
	private static class ComplexParser_Sequential104
	{
		// id=<Sequential:<true:false:IF:ft>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<true:true:statement:t>,<Action: return new ConditionalNode(ft.location, c, t, null); >>
		private alias PartialTreeType = PartialTree!104;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching105
	{
		// id=<Switch:<Sequential:<true:false:IF:ft>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<true:true:statement:t>,<false:false:ELSE:>,<true:true:statement:n>,<Action: return new ConditionalNode(ft.location, c, t, n); >>,<Sequential:<true:false:IF:ft>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<true:true:statement:t>,<Action: return new ConditionalNode(ft.location, c, t, null); >>>
		private alias PartialTreeType = PartialTree!105;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential103.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential104.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_COLON = ElementParser!(EnumTokenType.COLON);
	private alias ElementParser_WHILE = ElementParser!(EnumTokenType.WHILE);
	private static class ComplexParser_Sequential106
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:false:WHILE:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:RP:>,<true:true:statement:st>,<Action: return new PreConditionLoopNode(ft.location, id.text, e, st); >>
		private alias PartialTreeType = PartialTree!106;
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
	private static class ComplexParser_Sequential107
	{
		// id=<Sequential:<true:false:WHILE:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:RP:>,<true:true:statement:st>,<Action: return new PreConditionLoopNode(ft.location, e, st); >>
		private alias PartialTreeType = PartialTree!107;
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
	private static class ComplexParser_Switching108
	{
		// id=<Switch:<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:false:WHILE:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:RP:>,<true:true:statement:st>,<Action: return new PreConditionLoopNode(ft.location, id.text, e, st); >>,<Sequential:<true:false:WHILE:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:RP:>,<true:true:statement:st>,<Action: return new PreConditionLoopNode(ft.location, e, st); >>>
		private alias PartialTreeType = PartialTree!108;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential106.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential107.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_DO = ElementParser!(EnumTokenType.DO);
	private static class ComplexParser_Sequential109
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:false:DO:ft>,<true:true:statement:st>,<false:false:WHILE:>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<false:false:SEMICOLON:>,<Action: return new PostConditionLoopNode(ft.location, id.text, c, st); >>
		private alias PartialTreeType = PartialTree!109;
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
	private static class ComplexParser_Sequential110
	{
		// id=<Sequential:<true:false:DO:ft>,<true:true:statement:st>,<false:false:WHILE:>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<false:false:SEMICOLON:>,<Action: return new PostConditionLoopNode(ft.location, c, st); >>
		private alias PartialTreeType = PartialTree!110;
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
	private static class ComplexParser_Switching111
	{
		// id=<Switch:<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:false:DO:ft>,<true:true:statement:st>,<false:false:WHILE:>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<false:false:SEMICOLON:>,<Action: return new PostConditionLoopNode(ft.location, id.text, c, st); >>,<Sequential:<true:false:DO:ft>,<true:true:statement:st>,<false:false:WHILE:>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<false:false:SEMICOLON:>,<Action: return new PostConditionLoopNode(ft.location, c, st); >>>
		private alias PartialTreeType = PartialTree!111;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential109.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential110.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential112
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:true:foreach_stmt_impl:fs>,<Action: return fs.withName(id.text); >>
		private alias PartialTreeType = PartialTree!112;
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

			resTemp = foreach_stmt_impl.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential113
	{
		// id=<Sequential:<true:true:foreach_stmt_impl:fs>,<Action: return fs; >>
		private alias PartialTreeType = PartialTree!113;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = foreach_stmt_impl.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching114
	{
		// id=<Switch:<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:true:foreach_stmt_impl:fs>,<Action: return fs.withName(id.text); >>,<Sequential:<true:true:foreach_stmt_impl:fs>,<Action: return fs; >>>
		private alias PartialTreeType = PartialTree!114;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential112.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential113.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_FOREACH = ElementParser!(EnumTokenType.FOREACH);
	private alias ElementParser_LARROW = ElementParser!(EnumTokenType.LARROW);
	private static class ComplexParser_Sequential115
	{
		// id=<Sequential:<true:false:FOREACH:ft>,<false:false:LP:>,<true:true:tn_list:tnl>,<false:false:LARROW:>,<true:true:expression:e>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForeachStatementNode(ft.location, tnl, e, st); >>
		private alias PartialTreeType = PartialTree!115;
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

			resTemp = tn_list.parse(r);
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
	private static class ComplexParser_Sequential116
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:true:for_stmt_impl:fs>,<Action: return fs.withName(id.text); >>
		private alias PartialTreeType = PartialTree!116;
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

			resTemp = for_stmt_impl.parse(r);
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
		// id=<Sequential:<true:true:for_stmt_impl:fs>,<Action: return fs; >>
		private alias PartialTreeType = PartialTree!117;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = for_stmt_impl.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching118
	{
		// id=<Switch:<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:true:for_stmt_impl:fs>,<Action: return fs.withName(id.text); >>,<Sequential:<true:true:for_stmt_impl:fs>,<Action: return fs; >>>
		private alias PartialTreeType = PartialTree!118;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential116.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential117.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_FOR = ElementParser!(EnumTokenType.FOR);
	private static class ComplexParser_Sequential119
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, e2, e3, st); >>
		private alias PartialTreeType = PartialTree!119;
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
	private static class ComplexParser_Sequential120
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, e2, null, st); >>
		private alias PartialTreeType = PartialTree!120;
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
	private static class ComplexParser_Sequential121
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, null, e3, st); >>
		private alias PartialTreeType = PartialTree!121;
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

			resTemp = ElementParser_SEMICOLON.parse(r);
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
	private static class ComplexParser_Sequential122
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, null, null, st); >>
		private alias PartialTreeType = PartialTree!122;
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

			resTemp = ElementParser_SEMICOLON.parse(r);
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
	private static class ComplexParser_Sequential123
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, e2, e3, st); >>
		private alias PartialTreeType = PartialTree!123;
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

			resTemp = ElementParser_SEMICOLON.parse(r);
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
	private static class ComplexParser_Sequential124
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, e2, null, st); >>
		private alias PartialTreeType = PartialTree!124;
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

			resTemp = ElementParser_SEMICOLON.parse(r);
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
	private static class ComplexParser_Sequential125
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, null, e3, st); >>
		private alias PartialTreeType = PartialTree!125;
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

			resTemp = ElementParser_SEMICOLON.parse(r);
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
	private static class ComplexParser_Sequential126
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, null, null, st); >>
		private alias PartialTreeType = PartialTree!126;
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

			resTemp = ElementParser_SEMICOLON.parse(r);
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

			resTemp = ElementParser_SEMICOLON.parse(r);
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
	private static class ComplexParser_Switching127
	{
		// id=<Switch:<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, e2, e3, st); >>,<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, e2, null, st); >>,<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, null, e3, st); >>,<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, null, null, st); >>,<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, e2, e3, st); >>,<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, e2, null, st); >>,<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, null, e3, st); >>,<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, null, null, st); >>>
		private alias PartialTreeType = PartialTree!127;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential119.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential120.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential121.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential122.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential123.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential124.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential125.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential126.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_RETURN = ElementParser!(EnumTokenType.RETURN);
	private static class ComplexParser_Sequential128
	{
		// id=<Sequential:<true:false:RETURN:ft>,<true:true:expression:e>,<false:false:SEMICOLON:>,<Action: return new ReturnNode(ft.location, e); >>
		private alias PartialTreeType = PartialTree!128;
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
	private static class ComplexParser_Sequential129
	{
		// id=<Sequential:<true:false:RETURN:ft>,<false:false:SEMICOLON:>,<Action: return new ReturnNode(ft.location, null); >>
		private alias PartialTreeType = PartialTree!129;
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
	private static class ComplexParser_Switching130
	{
		// id=<Switch:<Sequential:<true:false:RETURN:ft>,<true:true:expression:e>,<false:false:SEMICOLON:>,<Action: return new ReturnNode(ft.location, e); >>,<Sequential:<true:false:RETURN:ft>,<false:false:SEMICOLON:>,<Action: return new ReturnNode(ft.location, null); >>>
		private alias PartialTreeType = PartialTree!130;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

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
	private alias ElementParser_BREAK = ElementParser!(EnumTokenType.BREAK);
	private static class ComplexParser_Sequential131
	{
		// id=<Sequential:<true:false:BREAK:ft>,<true:false:IDENTIFIER:id>,<false:false:SEMICOLON:>,<Action: return new BreakLoopNode(ft.location, id.text); >>
		private alias PartialTreeType = PartialTree!131;
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

			resTemp = ElementParser_IDENTIFIER.parse(r);
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
	private static class ComplexParser_Sequential132
	{
		// id=<Sequential:<true:false:BREAK:ft>,<false:false:SEMICOLON:>,<Action: return new BreakLoopNode(ft.location, null); >>
		private alias PartialTreeType = PartialTree!132;
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
	private static class ComplexParser_Switching133
	{
		// id=<Switch:<Sequential:<true:false:BREAK:ft>,<true:false:IDENTIFIER:id>,<false:false:SEMICOLON:>,<Action: return new BreakLoopNode(ft.location, id.text); >>,<Sequential:<true:false:BREAK:ft>,<false:false:SEMICOLON:>,<Action: return new BreakLoopNode(ft.location, null); >>>
		private alias PartialTreeType = PartialTree!133;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential131.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential132.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_CONTINUE = ElementParser!(EnumTokenType.CONTINUE);
	private static class ComplexParser_Sequential134
	{
		// id=<Sequential:<true:false:CONTINUE:ft>,<true:false:IDENTIFIER:id>,<false:false:SEMICOLON:>,<Action: return new ContinueLoopNode(ft.location, id.text); >>
		private alias PartialTreeType = PartialTree!134;
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

			resTemp = ElementParser_IDENTIFIER.parse(r);
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
	private static class ComplexParser_Sequential135
	{
		// id=<Sequential:<true:false:CONTINUE:ft>,<false:false:SEMICOLON:>,<Action: return new ContinueLoopNode(ft.location, null); >>
		private alias PartialTreeType = PartialTree!135;
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
	private static class ComplexParser_Switching136
	{
		// id=<Switch:<Sequential:<true:false:CONTINUE:ft>,<true:false:IDENTIFIER:id>,<false:false:SEMICOLON:>,<Action: return new ContinueLoopNode(ft.location, id.text); >>,<Sequential:<true:false:CONTINUE:ft>,<false:false:SEMICOLON:>,<Action: return new ContinueLoopNode(ft.location, null); >>>
		private alias PartialTreeType = PartialTree!136;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_SWITCH = ElementParser!(EnumTokenType.SWITCH);
	private static class ComplexParser_Sequential137
	{
		// id=<Sequential:<true:true:case_stmt:cs>,<Action: sects ~= cs; >>
		private alias PartialTreeType = PartialTree!137;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = case_stmt.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential138
	{
		// id=<Sequential:<true:true:default_stmt:ds>,<Action: sects ~= ds; >>
		private alias PartialTreeType = PartialTree!138;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = default_stmt.parse(r);
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
		// id=<Switch:<Sequential:<true:true:case_stmt:cs>,<Action: sects ~= cs; >>,<Sequential:<true:true:default_stmt:ds>,<Action: sects ~= ds; >>>
		private alias PartialTreeType = PartialTree!139;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

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
		// id=<LoopQualified:false:<Switch:<Sequential:<true:true:case_stmt:cs>,<Action: sects ~= cs; >>,<Sequential:<true:true:default_stmt:ds>,<Action: sects ~= ds; >>>>
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
		// id=<Sequential:<true:false:SWITCH:ft>,<false:false:LP:>,<true:true:expression:te>,<false:false:RP:>,<false:false:LB:>,<Action: SwitchSectionNode[] sects; >,<LoopQualified:false:<Switch:<Sequential:<true:true:case_stmt:cs>,<Action: sects ~= cs; >>,<Sequential:<true:true:default_stmt:ds>,<Action: sects ~= ds; >>>>,<false:false:RB:>,<Action: return new SwitchStatementNode(ft.location, te, sects); >>
		private alias PartialTreeType = PartialTree!141;
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

			resTemp = ComplexParser_LoopQualified140.parse(r);
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
	private static class ComplexParser_Sequential142
	{
		// id=<Sequential:<true:true:value_case_sect:vcs>,<Action: return vcs; >>
		private alias PartialTreeType = PartialTree!142;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = value_case_sect.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential143
	{
		// id=<Sequential:<true:true:type_case_sect:tcs>,<Action: return tcs; >>
		private alias PartialTreeType = PartialTree!143;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = type_case_sect.parse(r);
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
		// id=<Switch:<Sequential:<true:true:value_case_sect:vcs>,<Action: return vcs; >>,<Sequential:<true:true:type_case_sect:tcs>,<Action: return tcs; >>>
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
	private alias ElementParser_CASE = ElementParser!(EnumTokenType.CASE);
	private alias ElementParser_RARROW2 = ElementParser!(EnumTokenType.RARROW2);
	private static class ComplexParser_Sequential145
	{
		// id=<Sequential:<true:false:CASE:ft>,<true:true:expression_list:el>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new ValueCaseSectionNode(ft.location, el, st); >>
		private alias PartialTreeType = PartialTree!145;
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

			resTemp = expression_list.parse(r);
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
	private alias ElementParser_CONST = ElementParser!(EnumTokenType.CONST);
	private static class ComplexParser_Sequential146
	{
		// id=<Sequential:<true:false:CASE:ft>,<false:false:CONST:>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:IF:>,<true:true:expression:e>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, true, id, t, e, st); >>
		private alias PartialTreeType = PartialTree!146;
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

			resTemp = ElementParser_CONST.parse(r);
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
	private static class ComplexParser_Sequential147
	{
		// id=<Sequential:<true:false:CASE:ft>,<false:false:CONST:>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, true, id, t, null, st); >>
		private alias PartialTreeType = PartialTree!147;
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

			resTemp = ElementParser_CONST.parse(r);
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
	private static class ComplexParser_Sequential148
	{
		// id=<Sequential:<true:false:CASE:ft>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:IF:>,<true:true:expression:e>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, false, id, t, e, st); >>
		private alias PartialTreeType = PartialTree!148;
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
	private static class ComplexParser_Sequential149
	{
		// id=<Sequential:<true:false:CASE:ft>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, false, id, t, null, st); >>
		private alias PartialTreeType = PartialTree!149;
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
	private static class ComplexParser_Switching150
	{
		// id=<Switch:<Sequential:<true:false:CASE:ft>,<false:false:CONST:>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:IF:>,<true:true:expression:e>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, true, id, t, e, st); >>,<Sequential:<true:false:CASE:ft>,<false:false:CONST:>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, true, id, t, null, st); >>,<Sequential:<true:false:CASE:ft>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:IF:>,<true:true:expression:e>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, false, id, t, e, st); >>,<Sequential:<true:false:CASE:ft>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, false, id, t, null, st); >>>
		private alias PartialTreeType = PartialTree!150;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential146.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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
	private alias ElementParser_DEFAULT = ElementParser!(EnumTokenType.DEFAULT);
	private static class ComplexParser_Sequential151
	{
		// id=<Sequential:<true:false:DEFAULT:ft>,<false:false:RARROW2:>,<true:true:statement:s>,<Action: return new DefaultSectionNode(ft.location, s); >>
		private alias PartialTreeType = PartialTree!151;
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
	private static class ComplexParser_Sequential152
	{
		// id=<Sequential:<true:true:localvar_def:lvd>,<Action: stmts ~= lvd; >>
		private alias PartialTreeType = PartialTree!152;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = localvar_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential153
	{
		// id=<Sequential:<true:true:statement:st>,<Action: stmts ~= st; >>
		private alias PartialTreeType = PartialTree!153;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

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
	private static class ComplexParser_Switching154
	{
		// id=<Switch:<Sequential:<true:true:localvar_def:lvd>,<Action: stmts ~= lvd; >>,<Sequential:<true:true:statement:st>,<Action: stmts ~= st; >>>
		private alias PartialTreeType = PartialTree!154;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential152.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential153.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified155
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<true:true:localvar_def:lvd>,<Action: stmts ~= lvd; >>,<Sequential:<true:true:statement:st>,<Action: stmts ~= st; >>>>
		private alias PartialTreeType = PartialTree!155;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching154.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_RBR = ElementParser!(EnumTokenType.RBR);
	private static class ComplexParser_Sequential156
	{
		// id=<Sequential:<true:false:LBR:t>,<Action: StatementNode[] stmts; >,<LoopQualified:false:<Switch:<Sequential:<true:true:localvar_def:lvd>,<Action: stmts ~= lvd; >>,<Sequential:<true:true:statement:st>,<Action: stmts ~= st; >>>>,<false:false:RBR:>,<Action: return new BlockStatementNode(t.location, stmts); >>
		private alias PartialTreeType = PartialTree!156;
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

			resTemp = ComplexParser_LoopQualified155.parse(r);
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
	private static class ComplexParser_Sequential157
	{
		// id=<Sequential:<true:true:full_lvd:flvd>,<Action: return flvd; >>
		private alias PartialTreeType = PartialTree!157;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = full_lvd.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential158
	{
		// id=<Sequential:<true:true:inferenced_lvd:ilvd>,<Action: return ilvd; >>
		private alias PartialTreeType = PartialTree!158;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = inferenced_lvd.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching159
	{
		// id=<Switch:<Sequential:<true:true:full_lvd:flvd>,<Action: return flvd; >>,<Sequential:<true:true:inferenced_lvd:ilvd>,<Action: return ilvd; >>>
		private alias PartialTreeType = PartialTree!159;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential157.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential158.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential160
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:nvpair:nvp2>,<Action: nvps ~= nvp2; >>
		private alias PartialTreeType = PartialTree!160;
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
	private static class ComplexParser_LoopQualified161
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:nvpair:nvp2>,<Action: nvps ~= nvp2; >>>
		private alias PartialTreeType = PartialTree!161;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential160.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential162
	{
		// id=<Sequential:<Action: NameValuePair[] nvps; >,<true:true:nvpair:nvp>,<Action: nvps ~= nvp; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:nvpair:nvp2>,<Action: nvps ~= nvp2; >>>,<Action: return nvps; >>
		private alias PartialTreeType = PartialTree!162;
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

			resTemp = ComplexParser_LoopQualified161.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential163
	{
		// id=<Sequential:<true:true:lvar_qualifier:lq>,<Action: q = q.combine(lq); >>
		private alias PartialTreeType = PartialTree!163;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = lvar_qualifier.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified164
	{
		// id=<LoopQualified:false:<Sequential:<true:true:lvar_qualifier:lq>,<Action: q = q.combine(lq); >>>
		private alias PartialTreeType = PartialTree!164;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential163.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential165
	{
		// id=<Sequential:<Action: auto q = Qualifier(Location(int.max, int.max), Qualifiers.Public); >,<LoopQualified:false:<Sequential:<true:true:lvar_qualifier:lq>,<Action: q = q.combine(lq); >>>,<true:true:type:tp>,<true:true:nvp_list:nvps>,<false:false:SEMICOLON:>,<Action: return new LocalVariableDeclarationNode(q.location.line == int.max ? tp.location : q.location, q, tp, nvps); >>
		private alias PartialTreeType = PartialTree!165;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified164.parse(r);
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

			resTemp = nvp_list.parse(r);
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
	private static class ComplexParser_Sequential166
	{
		// id=<Sequential:<true:true:lvar_qualifier:q2>,<Action: q = q.combine(q2); >>
		private alias PartialTreeType = PartialTree!166;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = lvar_qualifier.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified167
	{
		// id=<LoopQualified:false:<Sequential:<true:true:lvar_qualifier:q2>,<Action: q = q.combine(q2); >>>
		private alias PartialTreeType = PartialTree!167;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential166.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential168
	{
		// id=<Sequential:<true:true:lvar_qualifier:q>,<LoopQualified:false:<Sequential:<true:true:lvar_qualifier:q2>,<Action: q = q.combine(q2); >>>,<true:true:nvp_list:nvps>,<false:false:SEMICOLON:>,<Action: return new LocalVariableDeclarationNode(q.location, q, new InferenceTypeNode(q.location), nvps); >>
		private alias PartialTreeType = PartialTree!168;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = lvar_qualifier.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified167.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = nvp_list.parse(r);
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
	private static class ComplexParser_Sequential169
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:expression:e2>,<Action: elist ~= e2; >>
		private alias PartialTreeType = PartialTree!169;
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
	private static class ComplexParser_LoopQualified170
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:expression:e2>,<Action: elist ~= e2; >>>
		private alias PartialTreeType = PartialTree!170;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential169.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential171
	{
		// id=<Sequential:<Action: ExpressionNode[] elist; >,<true:true:expression:e>,<Action: elist ~= e; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:expression:e2>,<Action: elist ~= e2; >>>,<Action: return elist; >>
		private alias PartialTreeType = PartialTree!171;
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

			resTemp = ComplexParser_LoopQualified170.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential172
	{
		// id=<Sequential:<true:true:postfix_expr:l>,<false:false:EQUAL:>,<true:true:expression:r>,<Action: return new AssignOperatorNode(l, r); >>
		private alias PartialTreeType = PartialTree!172;
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
	private static class ComplexParser_Sequential173
	{
		// id=<Sequential:<true:true:postfix_expr:l>,<true:true:assign_ops:o>,<true:true:expression:r>,<Action: return new OperatedAssignNode(l, o, r); >>
		private alias PartialTreeType = PartialTree!173;
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

			resTemp = assign_ops.parse(r);
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
	private static class ComplexParser_Sequential174
	{
		// id=<Sequential:<true:true:alternate_expr:e>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!174;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = alternate_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching175
	{
		// id=<Switch:<Sequential:<true:true:postfix_expr:l>,<false:false:EQUAL:>,<true:true:expression:r>,<Action: return new AssignOperatorNode(l, r); >>,<Sequential:<true:true:postfix_expr:l>,<true:true:assign_ops:o>,<true:true:expression:r>,<Action: return new OperatedAssignNode(l, o, r); >>,<Sequential:<true:true:alternate_expr:e>,<Action: return e; >>>
		private alias PartialTreeType = PartialTree!175;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential172.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential173.parse(r);
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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_PLUS_EQ = ElementParser!(EnumTokenType.PLUS_EQ);
	private static class ComplexParser_Sequential176
	{
		// id=<Sequential:<false:false:PLUS_EQ:>,<Action: return BinaryOperatorType.Add; >>
		private alias PartialTreeType = PartialTree!176;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PLUS_EQ.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_MINUS_EQ = ElementParser!(EnumTokenType.MINUS_EQ);
	private static class ComplexParser_Sequential177
	{
		// id=<Sequential:<false:false:MINUS_EQ:>,<Action: return BinaryOperatorType.Sub; >>
		private alias PartialTreeType = PartialTree!177;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_MINUS_EQ.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_ASTERISK_EQ = ElementParser!(EnumTokenType.ASTERISK_EQ);
	private static class ComplexParser_Sequential178
	{
		// id=<Sequential:<false:false:ASTERISK_EQ:>,<Action: return BinaryOperatorType.Mul; >>
		private alias PartialTreeType = PartialTree!178;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_ASTERISK_EQ.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_SLASH_EQ = ElementParser!(EnumTokenType.SLASH_EQ);
	private static class ComplexParser_Sequential179
	{
		// id=<Sequential:<false:false:SLASH_EQ:>,<Action: return BinaryOperatorType.Div; >>
		private alias PartialTreeType = PartialTree!179;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_SLASH_EQ.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PERCENT_EQ = ElementParser!(EnumTokenType.PERCENT_EQ);
	private static class ComplexParser_Sequential180
	{
		// id=<Sequential:<false:false:PERCENT_EQ:>,<Action: return BinaryOperatorType.Mod; >>
		private alias PartialTreeType = PartialTree!180;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PERCENT_EQ.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_AMPASAND_EQ = ElementParser!(EnumTokenType.AMPASAND_EQ);
	private static class ComplexParser_Sequential181
	{
		// id=<Sequential:<false:false:AMPASAND_EQ:>,<Action: return BinaryOperatorType.And; >>
		private alias PartialTreeType = PartialTree!181;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_AMPASAND_EQ.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_VL_EQ = ElementParser!(EnumTokenType.VL_EQ);
	private static class ComplexParser_Sequential182
	{
		// id=<Sequential:<false:false:VL_EQ:>,<Action: return BinaryOperatorType.Or; >>
		private alias PartialTreeType = PartialTree!182;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_VL_EQ.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_CA_EQ = ElementParser!(EnumTokenType.CA_EQ);
	private static class ComplexParser_Sequential183
	{
		// id=<Sequential:<false:false:CA_EQ:>,<Action: return BinaryOperatorType.Xor; >>
		private alias PartialTreeType = PartialTree!183;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_CA_EQ.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LAB2_EQ = ElementParser!(EnumTokenType.LAB2_EQ);
	private static class ComplexParser_Sequential184
	{
		// id=<Sequential:<false:false:LAB2_EQ:>,<Action: return BinaryOperatorType.LeftShift; >>
		private alias PartialTreeType = PartialTree!184;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LAB2_EQ.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_RAB2_EQ = ElementParser!(EnumTokenType.RAB2_EQ);
	private static class ComplexParser_Sequential185
	{
		// id=<Sequential:<false:false:RAB2_EQ:>,<Action: return BinaryOperatorType.RightShift; >>
		private alias PartialTreeType = PartialTree!185;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_RAB2_EQ.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching186
	{
		// id=<Switch:<Sequential:<false:false:PLUS_EQ:>,<Action: return BinaryOperatorType.Add; >>,<Sequential:<false:false:MINUS_EQ:>,<Action: return BinaryOperatorType.Sub; >>,<Sequential:<false:false:ASTERISK_EQ:>,<Action: return BinaryOperatorType.Mul; >>,<Sequential:<false:false:SLASH_EQ:>,<Action: return BinaryOperatorType.Div; >>,<Sequential:<false:false:PERCENT_EQ:>,<Action: return BinaryOperatorType.Mod; >>,<Sequential:<false:false:AMPASAND_EQ:>,<Action: return BinaryOperatorType.And; >>,<Sequential:<false:false:VL_EQ:>,<Action: return BinaryOperatorType.Or; >>,<Sequential:<false:false:CA_EQ:>,<Action: return BinaryOperatorType.Xor; >>,<Sequential:<false:false:LAB2_EQ:>,<Action: return BinaryOperatorType.LeftShift; >>,<Sequential:<false:false:RAB2_EQ:>,<Action: return BinaryOperatorType.RightShift; >>>
		private alias PartialTreeType = PartialTree!186;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential176.parse(r);
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

			resTemp = ComplexParser_Sequential178.parse(r);
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

			resTemp = ComplexParser_Sequential180.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential181.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential182.parse(r);
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

			resTemp = ComplexParser_Sequential185.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_QUESTION = ElementParser!(EnumTokenType.QUESTION);
	private static class ComplexParser_Sequential187
	{
		// id=<Sequential:<false:false:QUESTION:>,<true:true:short_expr:t>,<false:false:COLON:>,<true:true:short_expr:n>,<Action: e = new AlternateValueNode(e, t, n); >>
		private alias PartialTreeType = PartialTree!187;
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
	private static class ComplexParser_Skippable188
	{
		// id=<Skippable:<Sequential:<false:false:QUESTION:>,<true:true:short_expr:t>,<false:false:COLON:>,<true:true:short_expr:n>,<Action: e = new AlternateValueNode(e, t, n); >>>
		private alias PartialTreeType = PartialTree!188;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential187.parse(r);
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
	private static class ComplexParser_Sequential189
	{
		// id=<Sequential:<true:true:short_expr:e>,<Skippable:<Sequential:<false:false:QUESTION:>,<true:true:short_expr:t>,<false:false:COLON:>,<true:true:short_expr:n>,<Action: e = new AlternateValueNode(e, t, n); >>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!189;
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

			resTemp = ComplexParser_Skippable188.parse(r);
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
	private static class ComplexParser_Sequential190
	{
		// id=<Sequential:<false:false:AMPASAND2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogAnd, e2); >>
		private alias PartialTreeType = PartialTree!190;
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
	private static class ComplexParser_Sequential191
	{
		// id=<Sequential:<false:false:VL2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogOr, e2); >>
		private alias PartialTreeType = PartialTree!191;
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
	private static class ComplexParser_Sequential192
	{
		// id=<Sequential:<false:false:CA2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogXor, e2); >>
		private alias PartialTreeType = PartialTree!192;
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
	private static class ComplexParser_Switching193
	{
		// id=<Switch:<Sequential:<false:false:AMPASAND2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogAnd, e2); >>,<Sequential:<false:false:VL2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogOr, e2); >>,<Sequential:<false:false:CA2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogXor, e2); >>>
		private alias PartialTreeType = PartialTree!193;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential190.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential191.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential192.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified194
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:AMPASAND2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogAnd, e2); >>,<Sequential:<false:false:VL2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogOr, e2); >>,<Sequential:<false:false:CA2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogXor, e2); >>>>
		private alias PartialTreeType = PartialTree!194;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching193.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential195
	{
		// id=<Sequential:<true:true:comp_expr:e>,<LoopQualified:false:<Switch:<Sequential:<false:false:AMPASAND2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogAnd, e2); >>,<Sequential:<false:false:VL2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogOr, e2); >>,<Sequential:<false:false:CA2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogXor, e2); >>>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!195;
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

			resTemp = ComplexParser_LoopQualified194.parse(r);
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
	private static class ComplexParser_Sequential196
	{
		// id=<Sequential:<false:false:LAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Less, e2); >>
		private alias PartialTreeType = PartialTree!196;
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
	private static class ComplexParser_Sequential197
	{
		// id=<Sequential:<false:false:RAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Greater, e2); >>
		private alias PartialTreeType = PartialTree!197;
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
	private static class ComplexParser_Sequential198
	{
		// id=<Sequential:<false:false:EQ2:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Equiv, e2); >>
		private alias PartialTreeType = PartialTree!198;
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
	private static class ComplexParser_Sequential199
	{
		// id=<Sequential:<false:false:EX_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Inequiv, e2); >>
		private alias PartialTreeType = PartialTree!199;
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
	private static class ComplexParser_Sequential200
	{
		// id=<Sequential:<false:false:LAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LessEq, e2); >>
		private alias PartialTreeType = PartialTree!200;
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
	private static class ComplexParser_Sequential201
	{
		// id=<Sequential:<false:false:RAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.GreaterEq, e2); >>
		private alias PartialTreeType = PartialTree!201;
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
	private static class ComplexParser_Switching202
	{
		// id=<Switch:<Sequential:<false:false:LAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Less, e2); >>,<Sequential:<false:false:RAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Greater, e2); >>,<Sequential:<false:false:EQ2:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Equiv, e2); >>,<Sequential:<false:false:EX_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Inequiv, e2); >>,<Sequential:<false:false:LAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LessEq, e2); >>,<Sequential:<false:false:RAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.GreaterEq, e2); >>>
		private alias PartialTreeType = PartialTree!202;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential196.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential197.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential198.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential199.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential200.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential201.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified203
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:LAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Less, e2); >>,<Sequential:<false:false:RAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Greater, e2); >>,<Sequential:<false:false:EQ2:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Equiv, e2); >>,<Sequential:<false:false:EX_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Inequiv, e2); >>,<Sequential:<false:false:LAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LessEq, e2); >>,<Sequential:<false:false:RAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.GreaterEq, e2); >>>>
		private alias PartialTreeType = PartialTree!203;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching202.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential204
	{
		// id=<Sequential:<true:true:shift_expr:e>,<LoopQualified:false:<Switch:<Sequential:<false:false:LAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Less, e2); >>,<Sequential:<false:false:RAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Greater, e2); >>,<Sequential:<false:false:EQ2:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Equiv, e2); >>,<Sequential:<false:false:EX_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Inequiv, e2); >>,<Sequential:<false:false:LAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LessEq, e2); >>,<Sequential:<false:false:RAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.GreaterEq, e2); >>>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!204;
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

			resTemp = ComplexParser_LoopQualified203.parse(r);
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
	private static class ComplexParser_Sequential205
	{
		// id=<Sequential:<false:false:LAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LeftShift, e2); >>
		private alias PartialTreeType = PartialTree!205;
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
	private static class ComplexParser_Sequential206
	{
		// id=<Sequential:<false:false:RAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.RightShift, e2); >>
		private alias PartialTreeType = PartialTree!206;
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
	private static class ComplexParser_Switching207
	{
		// id=<Switch:<Sequential:<false:false:LAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LeftShift, e2); >>,<Sequential:<false:false:RAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.RightShift, e2); >>>
		private alias PartialTreeType = PartialTree!207;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential205.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential206.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified208
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:LAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LeftShift, e2); >>,<Sequential:<false:false:RAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.RightShift, e2); >>>>
		private alias PartialTreeType = PartialTree!208;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching207.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential209
	{
		// id=<Sequential:<true:true:bit_expr:e>,<LoopQualified:false:<Switch:<Sequential:<false:false:LAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LeftShift, e2); >>,<Sequential:<false:false:RAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.RightShift, e2); >>>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!209;
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

			resTemp = ComplexParser_LoopQualified208.parse(r);
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
	private static class ComplexParser_Sequential210
	{
		// id=<Sequential:<false:false:AMPASAND:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.And, e2); >>
		private alias PartialTreeType = PartialTree!210;
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
	private static class ComplexParser_Sequential211
	{
		// id=<Sequential:<false:false:VL:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Or, e2); >>
		private alias PartialTreeType = PartialTree!211;
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
	private static class ComplexParser_Sequential212
	{
		// id=<Sequential:<false:false:CA:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Xor, e2); >>
		private alias PartialTreeType = PartialTree!212;
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
	private static class ComplexParser_Switching213
	{
		// id=<Switch:<Sequential:<false:false:AMPASAND:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.And, e2); >>,<Sequential:<false:false:VL:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Or, e2); >>,<Sequential:<false:false:CA:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Xor, e2); >>>
		private alias PartialTreeType = PartialTree!213;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential210.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential211.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential212.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified214
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:AMPASAND:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.And, e2); >>,<Sequential:<false:false:VL:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Or, e2); >>,<Sequential:<false:false:CA:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Xor, e2); >>>>
		private alias PartialTreeType = PartialTree!214;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching213.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential215
	{
		// id=<Sequential:<true:true:a1_expr:e>,<LoopQualified:false:<Switch:<Sequential:<false:false:AMPASAND:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.And, e2); >>,<Sequential:<false:false:VL:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Or, e2); >>,<Sequential:<false:false:CA:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Xor, e2); >>>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!215;
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

			resTemp = ComplexParser_LoopQualified214.parse(r);
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
	private static class ComplexParser_Sequential216
	{
		// id=<Sequential:<false:false:PLUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Add, e2); >>
		private alias PartialTreeType = PartialTree!216;
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
	private static class ComplexParser_Sequential217
	{
		// id=<Sequential:<false:false:MINUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Sub, e2); >>
		private alias PartialTreeType = PartialTree!217;
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
	private static class ComplexParser_Switching218
	{
		// id=<Switch:<Sequential:<false:false:PLUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Add, e2); >>,<Sequential:<false:false:MINUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Sub, e2); >>>
		private alias PartialTreeType = PartialTree!218;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential216.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential217.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified219
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:PLUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Add, e2); >>,<Sequential:<false:false:MINUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Sub, e2); >>>>
		private alias PartialTreeType = PartialTree!219;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching218.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential220
	{
		// id=<Sequential:<true:true:a2_expr:e>,<LoopQualified:false:<Switch:<Sequential:<false:false:PLUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Add, e2); >>,<Sequential:<false:false:MINUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Sub, e2); >>>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!220;
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

			resTemp = ComplexParser_LoopQualified219.parse(r);
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
	private static class ComplexParser_Sequential221
	{
		// id=<Sequential:<false:false:ASTERISK:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mul, e2); >>
		private alias PartialTreeType = PartialTree!221;
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
	private static class ComplexParser_Sequential222
	{
		// id=<Sequential:<false:false:SLASH:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Div, e2); >>
		private alias PartialTreeType = PartialTree!222;
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
	private static class ComplexParser_Sequential223
	{
		// id=<Sequential:<false:false:PERCENT:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mod, e2); >>
		private alias PartialTreeType = PartialTree!223;
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
	private static class ComplexParser_Switching224
	{
		// id=<Switch:<Sequential:<false:false:ASTERISK:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mul, e2); >>,<Sequential:<false:false:SLASH:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Div, e2); >>,<Sequential:<false:false:PERCENT:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mod, e2); >>>
		private alias PartialTreeType = PartialTree!224;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential221.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential222.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential223.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified225
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:ASTERISK:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mul, e2); >>,<Sequential:<false:false:SLASH:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Div, e2); >>,<Sequential:<false:false:PERCENT:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mod, e2); >>>>
		private alias PartialTreeType = PartialTree!225;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching224.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential226
	{
		// id=<Sequential:<true:true:range_expr:e>,<LoopQualified:false:<Switch:<Sequential:<false:false:ASTERISK:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mul, e2); >>,<Sequential:<false:false:SLASH:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Div, e2); >>,<Sequential:<false:false:PERCENT:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mod, e2); >>>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!226;
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

			resTemp = ComplexParser_LoopQualified225.parse(r);
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
	private static class ComplexParser_Sequential227
	{
		// id=<Sequential:<false:false:PERIOD2:>,<true:true:prefix_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Ranged, e2); >>
		private alias PartialTreeType = PartialTree!227;
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
	private static class ComplexParser_LoopQualified228
	{
		// id=<LoopQualified:false:<Sequential:<false:false:PERIOD2:>,<true:true:prefix_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Ranged, e2); >>>
		private alias PartialTreeType = PartialTree!228;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential227.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential229
	{
		// id=<Sequential:<true:true:prefix_expr:e>,<LoopQualified:false:<Sequential:<false:false:PERIOD2:>,<true:true:prefix_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Ranged, e2); >>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!229;
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

			resTemp = ComplexParser_LoopQualified228.parse(r);
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
		// id=<Sequential:<false:false:PLUS:>,<true:true:prefix_expr:e>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!230;
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
	private static class ComplexParser_Sequential231
	{
		// id=<Sequential:<true:false:MINUS:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Negate); >>
		private alias PartialTreeType = PartialTree!231;
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
	private static class ComplexParser_Sequential232
	{
		// id=<Sequential:<true:false:PLUS2:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Increase); >>
		private alias PartialTreeType = PartialTree!232;
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
	private static class ComplexParser_Sequential233
	{
		// id=<Sequential:<true:false:MINUS2:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Decrease); >>
		private alias PartialTreeType = PartialTree!233;
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
	private static class ComplexParser_Sequential234
	{
		// id=<Sequential:<true:false:ASTERISK2:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Square); >>
		private alias PartialTreeType = PartialTree!234;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_ASTERISK2.parse(r);
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
	private static class ComplexParser_Sequential235
	{
		// id=<Sequential:<true:true:postfix_expr:e>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!235;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching236
	{
		// id=<Switch:<Sequential:<false:false:PLUS:>,<true:true:prefix_expr:e>,<Action: return e; >>,<Sequential:<true:false:MINUS:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Negate); >>,<Sequential:<true:false:PLUS2:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Increase); >>,<Sequential:<true:false:MINUS2:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Decrease); >>,<Sequential:<true:false:ASTERISK2:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Square); >>,<Sequential:<true:true:postfix_expr:e>,<Action: return e; >>>
		private alias PartialTreeType = PartialTree!236;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential230.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential231.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential232.parse(r);
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

			resTemp = ComplexParser_Sequential235.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential237
	{
		// id=<Sequential:<false:false:PLUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Increase); >>
		private alias PartialTreeType = PartialTree!237;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential238
	{
		// id=<Sequential:<false:false:MINUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Decrease); >>
		private alias PartialTreeType = PartialTree!238;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential239
	{
		// id=<Sequential:<false:false:ASTERISK2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Square); >>
		private alias PartialTreeType = PartialTree!239;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_ASTERISK2.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential240
	{
		// id=<Sequential:<false:false:LBR:>,<true:true:expression:d>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, [d]); >>
		private alias PartialTreeType = PartialTree!240;
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

			resTemp = expression.parse(r);
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
	private static class ComplexParser_Sequential241
	{
		// id=<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, null); >>
		private alias PartialTreeType = PartialTree!241;
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
	private static class ComplexParser_Sequential242
	{
		// id=<Sequential:<false:false:LP:>,<true:true:expression_list:ps>,<false:false:RP:>,<Action: e = new FuncallNode(e, ps); >>
		private alias PartialTreeType = PartialTree!242;
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
	private static class ComplexParser_Sequential243
	{
		// id=<Sequential:<false:false:LP:>,<false:false:RP:>,<Action: e = new FuncallNode(e, null); >>
		private alias PartialTreeType = PartialTree!243;
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
	private alias ElementParser_PERIOD = ElementParser!(EnumTokenType.PERIOD);
	private static class ComplexParser_Sequential244
	{
		// id=<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<true:true:template_tail:tt>,<Action: e = new ObjectRefNode(e, new TemplateInstantiateNode(id.location, id.text, tt)); >>
		private alias PartialTreeType = PartialTree!244;
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

			resTemp = template_tail.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential245
	{
		// id=<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<Action: e = new ObjectRefNode(e, new IdentifierReferenceNode(id.location, id.text)); >>
		private alias PartialTreeType = PartialTree!245;
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
	private alias ElementParser_RARROW = ElementParser!(EnumTokenType.RARROW);
	private static class ComplexParser_Sequential246
	{
		// id=<Sequential:<false:false:RARROW:>,<true:true:single_types:st>,<Action: e = new CastingNode(e, st); >>
		private alias PartialTreeType = PartialTree!246;
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

			resTemp = single_types.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential247
	{
		// id=<Sequential:<false:false:RARROW:>,<false:false:LP:>,<true:true:restricted_type:rt>,<false:false:RP:>,<Action: e = new CastingNode(e, rt); >>
		private alias PartialTreeType = PartialTree!247;
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
	private static class ComplexParser_Switching248
	{
		// id=<Switch:<Sequential:<false:false:PLUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Increase); >>,<Sequential:<false:false:MINUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Decrease); >>,<Sequential:<false:false:ASTERISK2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Square); >>,<Sequential:<false:false:LBR:>,<true:true:expression:d>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, [d]); >>,<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, null); >>,<Sequential:<false:false:LP:>,<true:true:expression_list:ps>,<false:false:RP:>,<Action: e = new FuncallNode(e, ps); >>,<Sequential:<false:false:LP:>,<false:false:RP:>,<Action: e = new FuncallNode(e, null); >>,<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<true:true:template_tail:tt>,<Action: e = new ObjectRefNode(e, new TemplateInstantiateNode(id.location, id.text, tt)); >>,<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<Action: e = new ObjectRefNode(e, new IdentifierReferenceNode(id.location, id.text)); >>,<Sequential:<false:false:RARROW:>,<true:true:single_types:st>,<Action: e = new CastingNode(e, st); >>,<Sequential:<false:false:RARROW:>,<false:false:LP:>,<true:true:restricted_type:rt>,<false:false:RP:>,<Action: e = new CastingNode(e, rt); >>>
		private alias PartialTreeType = PartialTree!248;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential237.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential238.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential239.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential240.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential241.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential242.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential243.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential244.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential245.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential246.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential247.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified249
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:PLUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Increase); >>,<Sequential:<false:false:MINUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Decrease); >>,<Sequential:<false:false:ASTERISK2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Square); >>,<Sequential:<false:false:LBR:>,<true:true:expression:d>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, [d]); >>,<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, null); >>,<Sequential:<false:false:LP:>,<true:true:expression_list:ps>,<false:false:RP:>,<Action: e = new FuncallNode(e, ps); >>,<Sequential:<false:false:LP:>,<false:false:RP:>,<Action: e = new FuncallNode(e, null); >>,<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<true:true:template_tail:tt>,<Action: e = new ObjectRefNode(e, new TemplateInstantiateNode(id.location, id.text, tt)); >>,<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<Action: e = new ObjectRefNode(e, new IdentifierReferenceNode(id.location, id.text)); >>,<Sequential:<false:false:RARROW:>,<true:true:single_types:st>,<Action: e = new CastingNode(e, st); >>,<Sequential:<false:false:RARROW:>,<false:false:LP:>,<true:true:restricted_type:rt>,<false:false:RP:>,<Action: e = new CastingNode(e, rt); >>>>
		private alias PartialTreeType = PartialTree!249;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching248.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential250
	{
		// id=<Sequential:<true:true:primary_expr:e>,<LoopQualified:false:<Switch:<Sequential:<false:false:PLUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Increase); >>,<Sequential:<false:false:MINUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Decrease); >>,<Sequential:<false:false:ASTERISK2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Square); >>,<Sequential:<false:false:LBR:>,<true:true:expression:d>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, [d]); >>,<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, null); >>,<Sequential:<false:false:LP:>,<true:true:expression_list:ps>,<false:false:RP:>,<Action: e = new FuncallNode(e, ps); >>,<Sequential:<false:false:LP:>,<false:false:RP:>,<Action: e = new FuncallNode(e, null); >>,<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<true:true:template_tail:tt>,<Action: e = new ObjectRefNode(e, new TemplateInstantiateNode(id.location, id.text, tt)); >>,<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<Action: e = new ObjectRefNode(e, new IdentifierReferenceNode(id.location, id.text)); >>,<Sequential:<false:false:RARROW:>,<true:true:single_types:st>,<Action: e = new CastingNode(e, st); >>,<Sequential:<false:false:RARROW:>,<false:false:LP:>,<true:true:restricted_type:rt>,<false:false:RP:>,<Action: e = new CastingNode(e, rt); >>>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!250;
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

			resTemp = ComplexParser_LoopQualified249.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential251
	{
		// id=<Sequential:<true:true:literals:l>,<Action: return l; >>
		private alias PartialTreeType = PartialTree!251;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = literals.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential252
	{
		// id=<Sequential:<true:true:special_literals:sl>,<Action: return sl; >>
		private alias PartialTreeType = PartialTree!252;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = special_literals.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential253
	{
		// id=<Sequential:<true:true:lambda_expr:le>,<Action: return le; >>
		private alias PartialTreeType = PartialTree!253;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = lambda_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential254
	{
		// id=<Sequential:<false:false:LP:>,<true:true:expression:e>,<false:false:RP:>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!254;
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
	private static class ComplexParser_Sequential255
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<true:true:template_tail:tt>,<Action: return new TemplateInstantiateNode(id.location, id.text, tt); >>
		private alias PartialTreeType = PartialTree!255;
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

			resTemp = template_tail.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential256
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<Action: return new IdentifierReferenceNode(id.location, id.text); >>
		private alias PartialTreeType = PartialTree!256;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching257
	{
		// id=<Switch:<Sequential:<true:true:literals:l>,<Action: return l; >>,<Sequential:<true:true:special_literals:sl>,<Action: return sl; >>,<Sequential:<true:true:lambda_expr:le>,<Action: return le; >>,<Sequential:<false:false:LP:>,<true:true:expression:e>,<false:false:RP:>,<Action: return e; >>,<Sequential:<true:false:IDENTIFIER:id>,<true:true:template_tail:tt>,<Action: return new TemplateInstantiateNode(id.location, id.text, tt); >>,<Sequential:<true:false:IDENTIFIER:id>,<Action: return new IdentifierReferenceNode(id.location, id.text); >>>
		private alias PartialTreeType = PartialTree!257;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential251.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential252.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential253.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential254.parse(r);
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

			resTemp = ComplexParser_Sequential256.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_INUMBER = ElementParser!(EnumTokenType.INUMBER);
	private static class ComplexParser_Sequential258
	{
		// id=<Sequential:<true:false:INUMBER:t>,<Action: return new IntLiteralNode(t.location, t.text.to!int); >>
		private alias PartialTreeType = PartialTree!258;
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
	private alias ElementParser_HNUMBER = ElementParser!(EnumTokenType.HNUMBER);
	private static class ComplexParser_Sequential259
	{
		// id=<Sequential:<true:false:HNUMBER:t>,<Action: return new IntLiteralNode(t.location, t.text.to!int(16)); >>
		private alias PartialTreeType = PartialTree!259;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_HNUMBER.parse(r);
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
	private static class ComplexParser_Sequential260
	{
		// id=<Sequential:<true:false:FNUMBER:t>,<Action: return new FloatLiteralNode(t.location, t.text.to!float); >>
		private alias PartialTreeType = PartialTree!260;
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
	private alias ElementParser_DNUMBER = ElementParser!(EnumTokenType.DNUMBER);
	private static class ComplexParser_Sequential261
	{
		// id=<Sequential:<true:false:DNUMBER:t>,<Action: return new DoubleLiteralNode(t.location, t.text.to!double); >>
		private alias PartialTreeType = PartialTree!261;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_DNUMBER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_NUMBER = ElementParser!(EnumTokenType.NUMBER);
	private static class ComplexParser_Sequential262
	{
		// id=<Sequential:<true:false:NUMBER:t>,<Action: return new NumericLiteralNode(t.location, t.text.to!real); >>
		private alias PartialTreeType = PartialTree!262;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_NUMBER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_STRING = ElementParser!(EnumTokenType.STRING);
	private static class ComplexParser_Sequential263
	{
		// id=<Sequential:<true:false:STRING:t>,<Action: return new StringLiteralNode(t.location, t.text); >>
		private alias PartialTreeType = PartialTree!263;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_STRING.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_CHARACTER = ElementParser!(EnumTokenType.CHARACTER);
	private static class ComplexParser_Sequential264
	{
		// id=<Sequential:<true:false:CHARACTER:t>,<Action: return new CharacterLiteralNode(t.location, t.text[0]); >>
		private alias PartialTreeType = PartialTree!264;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_CHARACTER.parse(r);
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
		// id=<Sequential:<true:true:function_literal:fl>,<Action: return fl; >>
		private alias PartialTreeType = PartialTree!265;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = function_literal.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential266
	{
		// id=<Sequential:<true:true:array_literal:al>,<Action: return al; >>
		private alias PartialTreeType = PartialTree!266;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = array_literal.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching267
	{
		// id=<Switch:<Sequential:<true:false:INUMBER:t>,<Action: return new IntLiteralNode(t.location, t.text.to!int); >>,<Sequential:<true:false:HNUMBER:t>,<Action: return new IntLiteralNode(t.location, t.text.to!int(16)); >>,<Sequential:<true:false:FNUMBER:t>,<Action: return new FloatLiteralNode(t.location, t.text.to!float); >>,<Sequential:<true:false:DNUMBER:t>,<Action: return new DoubleLiteralNode(t.location, t.text.to!double); >>,<Sequential:<true:false:NUMBER:t>,<Action: return new NumericLiteralNode(t.location, t.text.to!real); >>,<Sequential:<true:false:STRING:t>,<Action: return new StringLiteralNode(t.location, t.text); >>,<Sequential:<true:false:CHARACTER:t>,<Action: return new CharacterLiteralNode(t.location, t.text[0]); >>,<Sequential:<true:true:function_literal:fl>,<Action: return fl; >>,<Sequential:<true:true:array_literal:al>,<Action: return al; >>>
		private alias PartialTreeType = PartialTree!267;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential258.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential259.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential260.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential261.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential262.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential263.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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

			resTemp = ComplexParser_Sequential266.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_FUNCTION = ElementParser!(EnumTokenType.FUNCTION);
	private static class ComplexParser_Sequential268
	{
		// id=<Sequential:<true:false:FUNCTION:f>,<false:false:LP:>,<true:true:literal_varg_list:vl>,<false:false:RP:>,<true:true:block_stmt:bs>,<Action: return new FunctionLiteralNode(f.location, vl, bs); >>
		private alias PartialTreeType = PartialTree!268;
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

			resTemp = literal_varg_list.parse(r);
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

			resTemp = block_stmt.parse(r);
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
		// id=<Sequential:<true:false:FUNCTION:f>,<false:false:LP:>,<false:false:RP:>,<true:true:block_stmt:bs>,<Action: return new FunctionLiteralNode(f.location, null, bs); >>
		private alias PartialTreeType = PartialTree!269;
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

			resTemp = ElementParser_RP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = block_stmt.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching270
	{
		// id=<Switch:<Sequential:<true:false:FUNCTION:f>,<false:false:LP:>,<true:true:literal_varg_list:vl>,<false:false:RP:>,<true:true:block_stmt:bs>,<Action: return new FunctionLiteralNode(f.location, vl, bs); >>,<Sequential:<true:false:FUNCTION:f>,<false:false:LP:>,<false:false:RP:>,<true:true:block_stmt:bs>,<Action: return new FunctionLiteralNode(f.location, null, bs); >>>
		private alias PartialTreeType = PartialTree!270;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential268.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential269.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential271
	{
		// id=<Sequential:<true:false:LBR:ft>,<true:true:expression_list:el>,<false:false:RBR:>,<Action: return new ArrayLiteralNode(ft.location, el); >>
		private alias PartialTreeType = PartialTree!271;
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

			resTemp = expression_list.parse(r);
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
	private static class ComplexParser_Sequential272
	{
		// id=<Sequential:<true:false:LBR:ft>,<true:true:assoc_array_element_list:el>,<false:false:RBR:>,<Action: return new AssocArrayLiteralNode(ft.location, el); >>
		private alias PartialTreeType = PartialTree!272;
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

			resTemp = assoc_array_element_list.parse(r);
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
	private static class ComplexParser_Sequential273
	{
		// id=<Sequential:<true:false:LBR:ft>,<false:false:RBR:>,<Action: return new ArrayLiteralNode(ft.location, null); >>
		private alias PartialTreeType = PartialTree!273;
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
	private static class ComplexParser_Switching274
	{
		// id=<Switch:<Sequential:<true:false:LBR:ft>,<true:true:expression_list:el>,<false:false:RBR:>,<Action: return new ArrayLiteralNode(ft.location, el); >>,<Sequential:<true:false:LBR:ft>,<true:true:assoc_array_element_list:el>,<false:false:RBR:>,<Action: return new AssocArrayLiteralNode(ft.location, el); >>,<Sequential:<true:false:LBR:ft>,<false:false:RBR:>,<Action: return new ArrayLiteralNode(ft.location, null); >>>
		private alias PartialTreeType = PartialTree!274;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential271.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential272.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential273.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential275
	{
		// id=<Sequential:<true:false:THIS:t>,<Action: return new ThisReferenceNode(t.location); >>
		private alias PartialTreeType = PartialTree!275;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_THIS.parse(r);
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
	private static class ComplexParser_Sequential276
	{
		// id=<Sequential:<true:false:SUPER:t>,<Action: return new SuperReferenceNode(t.location); >>
		private alias PartialTreeType = PartialTree!276;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_SUPER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_TRUE = ElementParser!(EnumTokenType.TRUE);
	private static class ComplexParser_Sequential277
	{
		// id=<Sequential:<true:false:TRUE:t>,<Action: return new BooleanLiteralNode(t.location, true); >>
		private alias PartialTreeType = PartialTree!277;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_TRUE.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_FALSE = ElementParser!(EnumTokenType.FALSE);
	private static class ComplexParser_Sequential278
	{
		// id=<Sequential:<true:false:FALSE:t>,<Action: return new BooleanLiteralNode(t.location, false); >>
		private alias PartialTreeType = PartialTree!278;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_FALSE.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_NULL = ElementParser!(EnumTokenType.NULL);
	private static class ComplexParser_Sequential279
	{
		// id=<Sequential:<true:false:NULL:t>,<Action: return new NullLiteralNode(t.location); >>
		private alias PartialTreeType = PartialTree!279;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_NULL.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching280
	{
		// id=<Switch:<Sequential:<true:false:THIS:t>,<Action: return new ThisReferenceNode(t.location); >>,<Sequential:<true:false:SUPER:t>,<Action: return new SuperReferenceNode(t.location); >>,<Sequential:<true:false:TRUE:t>,<Action: return new BooleanLiteralNode(t.location, true); >>,<Sequential:<true:false:FALSE:t>,<Action: return new BooleanLiteralNode(t.location, false); >>,<Sequential:<true:false:NULL:t>,<Action: return new NullLiteralNode(t.location); >>>
		private alias PartialTreeType = PartialTree!280;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential275.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential276.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential277.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential278.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential279.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential281
	{
		// id=<Sequential:<true:false:LP:t>,<true:true:literal_varg_list:ps>,<false:false:RP:>,<false:false:RARROW2:>,<true:true:expression:e>,<Action: return new FunctionLiteralNode(t.location, ps, e); >>
		private alias PartialTreeType = PartialTree!281;
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

			resTemp = literal_varg_list.parse(r);
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
	private static class ComplexParser_Sequential282
	{
		// id=<Sequential:<true:false:LP:t>,<false:false:RP:>,<false:false:RARROW2:>,<true:true:expression:e>,<Action: return new FunctionLiteralNode(t.location, null, e); >>
		private alias PartialTreeType = PartialTree!282;
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
	private static class ComplexParser_Sequential283
	{
		// id=<Sequential:<true:true:literal_varg:vp>,<false:false:RARROW2:>,<true:true:expression:e>,<Action: return new FunctionLiteralNode(vp, e); >>
		private alias PartialTreeType = PartialTree!283;
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
	private static class ComplexParser_Switching284
	{
		// id=<Switch:<Sequential:<true:false:LP:t>,<true:true:literal_varg_list:ps>,<false:false:RP:>,<false:false:RARROW2:>,<true:true:expression:e>,<Action: return new FunctionLiteralNode(t.location, ps, e); >>,<Sequential:<true:false:LP:t>,<false:false:RP:>,<false:false:RARROW2:>,<true:true:expression:e>,<Action: return new FunctionLiteralNode(t.location, null, e); >>,<Sequential:<true:true:literal_varg:vp>,<false:false:RARROW2:>,<true:true:expression:e>,<Action: return new FunctionLiteralNode(vp, e); >>>
		private alias PartialTreeType = PartialTree!284;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential281.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential282.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential283.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential285
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:template_arg:p2>,<Action: params ~= p2; >>
		private alias PartialTreeType = PartialTree!285;
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
	private static class ComplexParser_LoopQualified286
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:template_arg:p2>,<Action: params ~= p2; >>>
		private alias PartialTreeType = PartialTree!286;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential285.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential287
	{
		// id=<Sequential:<Action: TemplateVirtualParamNode[] params; >,<true:true:template_arg:p>,<Action: params ~= p; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:template_arg:p2>,<Action: params ~= p2; >>>,<Action: return params; >>
		private alias PartialTreeType = PartialTree!287;
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

			resTemp = ComplexParser_LoopQualified286.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential288
	{
		// id=<Sequential:<false:false:EQUAL:>,<true:true:type:t>,<Action: head = new TemplateVirtualParamNode(head, t); >>
		private alias PartialTreeType = PartialTree!288;
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
	private static class ComplexParser_LoopQualified289
	{
		// id=<LoopQualified:false:<Sequential:<false:false:EQUAL:>,<true:true:type:t>,<Action: head = new TemplateVirtualParamNode(head, t); >>>
		private alias PartialTreeType = PartialTree!289;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential288.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential290
	{
		// id=<Sequential:<true:true:template_arg_head:head>,<LoopQualified:false:<Sequential:<false:false:EQUAL:>,<true:true:type:t>,<Action: head = new TemplateVirtualParamNode(head, t); >>>,<Action: return head; >>
		private alias PartialTreeType = PartialTree!290;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = template_arg_head.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified289.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential291
	{
		// id=<Sequential:<true:true:type:t>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.Type, t, t.location); >>
		private alias PartialTreeType = PartialTree!291;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential292
	{
		// id=<Sequential:<true:false:CLASS:tk>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.Class, null, tk.location); >>
		private alias PartialTreeType = PartialTree!292;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_CLASS.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential293
	{
		// id=<Sequential:<true:false:ALIAS:tk>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.SymbolAlias, null, tk.location); >>
		private alias PartialTreeType = PartialTree!293;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_ALIAS.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching294
	{
		// id=<Switch:<Sequential:<true:true:type:t>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.Type, t, t.location); >>,<Sequential:<true:false:CLASS:tk>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.Class, null, tk.location); >>,<Sequential:<true:false:ALIAS:tk>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.SymbolAlias, null, tk.location); >>>
		private alias PartialTreeType = PartialTree!294;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential291.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential292.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential293.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential295
	{
		// id=<Sequential:<Action: alias ReturnType = Tuple!(TemplateVirtualParamNode.ParamType, "type", TypeNode, "stype", Location, "location"); >,<Switch:<Sequential:<true:true:type:t>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.Type, t, t.location); >>,<Sequential:<true:false:CLASS:tk>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.Class, null, tk.location); >>,<Sequential:<true:false:ALIAS:tk>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.SymbolAlias, null, tk.location); >>>>
		private alias PartialTreeType = PartialTree!295;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_Switching294.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential296
	{
		// id=<Sequential:<true:true:template_arg_type:type>,<true:false:IDENTIFIER:id>,<Action: return new TemplateVirtualParamNode(type.location, type.type, type.stype, id.text); >>
		private alias PartialTreeType = PartialTree!296;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = template_arg_type.parse(r);
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
	private static class ComplexParser_Sequential297
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<Action: return new TemplateVirtualParamNode(id.location, TemplateVirtualParamNode.ParamType.Any, null, id.text); >>
		private alias PartialTreeType = PartialTree!297;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching298
	{
		// id=<Switch:<Sequential:<true:true:template_arg_type:type>,<true:false:IDENTIFIER:id>,<Action: return new TemplateVirtualParamNode(type.location, type.type, type.stype, id.text); >>,<Sequential:<true:false:IDENTIFIER:id>,<Action: return new TemplateVirtualParamNode(id.location, TemplateVirtualParamNode.ParamType.Any, null, id.text); >>>
		private alias PartialTreeType = PartialTree!298;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential296.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential297.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential299
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:varg:v>,<Action: params ~= v; >>
		private alias PartialTreeType = PartialTree!299;
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
	private static class ComplexParser_LoopQualified300
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:varg:v>,<Action: params ~= v; >>>
		private alias PartialTreeType = PartialTree!300;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential299.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential301
	{
		// id=<Sequential:<Action: VirtualParamNode params[]; >,<true:true:varg:t>,<Action: params ~= t; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:varg:v>,<Action: params ~= v; >>>,<Action: return params; >>
		private alias PartialTreeType = PartialTree!301;
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

			resTemp = ComplexParser_LoopQualified300.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PERIOD3 = ElementParser!(EnumTokenType.PERIOD3);
	private static class ComplexParser_Sequential302
	{
		// id=<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<false:false:EQUAL:>,<true:true:expression:dv>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, n.text, dv, true); >>
		private alias PartialTreeType = PartialTree!302;
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

			resTemp = ElementParser_PERIOD3.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential303
	{
		// id=<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<false:false:EQUAL:>,<true:true:expression:dv>,<Action: return new VirtualParamNode(t, n.text, dv, false); >>
		private alias PartialTreeType = PartialTree!303;
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
	private static class ComplexParser_Sequential304
	{
		// id=<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, n.text, null, true); >>
		private alias PartialTreeType = PartialTree!304;
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

			resTemp = ElementParser_PERIOD3.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential305
	{
		// id=<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<Action: return new VirtualParamNode(t, n.text, null, false); >>
		private alias PartialTreeType = PartialTree!305;
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
	private static class ComplexParser_Sequential306
	{
		// id=<Sequential:<true:true:type:t>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, null, null, true); >>
		private alias PartialTreeType = PartialTree!306;
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

			resTemp = ElementParser_PERIOD3.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential307
	{
		// id=<Sequential:<true:true:type:t>,<Action: return new VirtualParamNode(t, null, null, false); >>
		private alias PartialTreeType = PartialTree!307;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching308
	{
		// id=<Switch:<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<false:false:EQUAL:>,<true:true:expression:dv>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, n.text, dv, true); >>,<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<false:false:EQUAL:>,<true:true:expression:dv>,<Action: return new VirtualParamNode(t, n.text, dv, false); >>,<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, n.text, null, true); >>,<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<Action: return new VirtualParamNode(t, n.text, null, false); >>,<Sequential:<true:true:type:t>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, null, null, true); >>,<Sequential:<true:true:type:t>,<Action: return new VirtualParamNode(t, null, null, false); >>>
		private alias PartialTreeType = PartialTree!308;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential302.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential303.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential304.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential305.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential306.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential307.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential309
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:literal_varg:p2>,<Action: params ~= p2; >>
		private alias PartialTreeType = PartialTree!309;
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
	private static class ComplexParser_LoopQualified310
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:literal_varg:p2>,<Action: params ~= p2; >>>
		private alias PartialTreeType = PartialTree!310;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential309.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential311
	{
		// id=<Sequential:<Action: VirtualParamNode[] params; >,<true:true:literal_varg:p1>,<Action: params ~= p1; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:literal_varg:p2>,<Action: params ~= p2; >>>,<Action: return params; >>
		private alias PartialTreeType = PartialTree!311;
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

			resTemp = ComplexParser_LoopQualified310.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential312
	{
		// id=<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:id>,<false:false:EQUAL:>,<true:true:expression:e>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, id.text, e, true); >>
		private alias PartialTreeType = PartialTree!312;
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

			resTemp = ElementParser_PERIOD3.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential313
	{
		// id=<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:id>,<false:false:EQUAL:>,<true:true:expression:e>,<Action: return new VirtualParamNode(t, id.text, e, false); >>
		private alias PartialTreeType = PartialTree!313;
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
	private static class ComplexParser_Sequential314
	{
		// id=<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:id>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, id.text, null, true); >>
		private alias PartialTreeType = PartialTree!314;
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

			resTemp = ElementParser_PERIOD3.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential315
	{
		// id=<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:id>,<Action: return new VirtualParamNode(t, id.text, null, false); >>
		private alias PartialTreeType = PartialTree!315;
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
	private static class ComplexParser_Sequential316
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:EQUAL:>,<true:true:expression:e>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(new InferenceTypeNode(id.location), id.text, e, true); >>
		private alias PartialTreeType = PartialTree!316;
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

			resTemp = expression.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_PERIOD3.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential317
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:EQUAL:>,<true:true:expression:e>,<Action: return new VirtualParamNode(new InferenceTypeNode(id.location), id.text, e, false); >>
		private alias PartialTreeType = PartialTree!317;
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
	private static class ComplexParser_Sequential318
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(new InferenceTypeNode(id.location), id.text, null, true); >>
		private alias PartialTreeType = PartialTree!318;
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

			resTemp = ElementParser_PERIOD3.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential319
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<Action: return new VirtualParamNode(new InferenceTypeNode(id.location), id.text, null, false); >>
		private alias PartialTreeType = PartialTree!319;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching320
	{
		// id=<Switch:<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:id>,<false:false:EQUAL:>,<true:true:expression:e>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, id.text, e, true); >>,<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:id>,<false:false:EQUAL:>,<true:true:expression:e>,<Action: return new VirtualParamNode(t, id.text, e, false); >>,<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:id>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, id.text, null, true); >>,<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:id>,<Action: return new VirtualParamNode(t, id.text, null, false); >>,<Sequential:<true:false:IDENTIFIER:id>,<false:false:EQUAL:>,<true:true:expression:e>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(new InferenceTypeNode(id.location), id.text, e, true); >>,<Sequential:<true:false:IDENTIFIER:id>,<false:false:EQUAL:>,<true:true:expression:e>,<Action: return new VirtualParamNode(new InferenceTypeNode(id.location), id.text, e, false); >>,<Sequential:<true:false:IDENTIFIER:id>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(new InferenceTypeNode(id.location), id.text, null, true); >>,<Sequential:<true:false:IDENTIFIER:id>,<Action: return new VirtualParamNode(new InferenceTypeNode(id.location), id.text, null, false); >>>
		private alias PartialTreeType = PartialTree!320;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential312.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential313.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential314.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential315.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential316.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential317.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential318.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential319.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential321
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:assoc_array_element:n2>,<Action: nodes ~= n2; >>
		private alias PartialTreeType = PartialTree!321;
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
	private static class ComplexParser_LoopQualified322
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:assoc_array_element:n2>,<Action: nodes ~= n2; >>>
		private alias PartialTreeType = PartialTree!322;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential321.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential323
	{
		// id=<Sequential:<Action: AssocArrayElementNode[] nodes; >,<true:true:assoc_array_element:n>,<Action: nodes ~= n; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:assoc_array_element:n2>,<Action: nodes ~= n2; >>>,<Action: return nodes; >>
		private alias PartialTreeType = PartialTree!323;
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

			resTemp = ComplexParser_LoopQualified322.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential324
	{
		// id=<Sequential:<true:true:expression:k>,<false:false:COLON:>,<true:true:expression:v>,<Action: return new AssocArrayElementNode(k, v); >>
		private alias PartialTreeType = PartialTree!324;
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
	private static class ComplexParser_Sequential325
	{
		// id=<Sequential:<true:false:PUBLIC:t>,<Action: return Qualifier(t.location, Qualifiers.Public); >>
		private alias PartialTreeType = PartialTree!325;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PUBLIC.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PRIVATE = ElementParser!(EnumTokenType.PRIVATE);
	private static class ComplexParser_Sequential326
	{
		// id=<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>
		private alias PartialTreeType = PartialTree!326;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PRIVATE.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_FINAL = ElementParser!(EnumTokenType.FINAL);
	private static class ComplexParser_Sequential327
	{
		// id=<Sequential:<true:false:FINAL:t>,<Action: return Qualifier(t.location, Qualifiers.Final); >>
		private alias PartialTreeType = PartialTree!327;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_FINAL.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_STATIC = ElementParser!(EnumTokenType.STATIC);
	private static class ComplexParser_Sequential328
	{
		// id=<Sequential:<true:false:STATIC:t>,<Action: return Qualifier(t.location, Qualifiers.Static); >>
		private alias PartialTreeType = PartialTree!328;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_STATIC.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching329
	{
		// id=<Switch:<Sequential:<true:false:PUBLIC:t>,<Action: return Qualifier(t.location, Qualifiers.Public); >>,<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>,<Sequential:<true:false:FINAL:t>,<Action: return Qualifier(t.location, Qualifiers.Final); >>,<Sequential:<true:false:STATIC:t>,<Action: return Qualifier(t.location, Qualifiers.Static); >>>
		private alias PartialTreeType = PartialTree!329;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential325.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential326.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential327.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential328.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Switching330
	{
		// id=<Switch:<Sequential:<true:false:PUBLIC:t>,<Action: return Qualifier(t.location, Qualifiers.Public); >>,<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>,<Sequential:<true:false:STATIC:t>,<Action: return Qualifier(t.location, Qualifiers.Static); >>>
		private alias PartialTreeType = PartialTree!330;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential325.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential326.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential328.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Switching331
	{
		// id=<Switch:<Sequential:<true:false:PUBLIC:t>,<Action: return Qualifier(t.location, Qualifiers.Public); >>,<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>>
		private alias PartialTreeType = PartialTree!331;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential325.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential326.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential332
	{
		// id=<Sequential:<true:false:CONST:t>,<Action: return Qualifier(t.location, Qualifiers.Const); >>
		private alias PartialTreeType = PartialTree!332;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_CONST.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PROTECTED = ElementParser!(EnumTokenType.PROTECTED);
	private static class ComplexParser_Sequential333
	{
		// id=<Sequential:<true:false:PROTECTED:t>,<Action: return Qualifier(t.location, Qualifiers.Protected); >>
		private alias PartialTreeType = PartialTree!333;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PROTECTED.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching334
	{
		// id=<Switch:<Sequential:<true:false:PUBLIC:t>,<Action: return Qualifier(t.location, Qualifiers.Public); >>,<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>,<Sequential:<true:false:PROTECTED:t>,<Action: return Qualifier(t.location, Qualifiers.Protected); >>,<Sequential:<true:false:STATIC:t>,<Action: return Qualifier(t.location, Qualifiers.Static); >>,<Sequential:<true:false:FINAL:t>,<Action: return Qualifier(t.location, Qualifiers.Final); >>,<Sequential:<true:false:CONST:t>,<Action: return Qualifier(t.location, Qualifiers.Const); >>>
		private alias PartialTreeType = PartialTree!334;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential325.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential326.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential333.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential328.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential327.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential332.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_OVERRIDE = ElementParser!(EnumTokenType.OVERRIDE);
	private static class ComplexParser_Sequential335
	{
		// id=<Sequential:<true:false:OVERRIDE:t>,<Action: return Qualifier(t.location, Qualifiers.Override); >>
		private alias PartialTreeType = PartialTree!335;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_OVERRIDE.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching336
	{
		// id=<Switch:<Sequential:<true:false:PUBLIC:t>,<Action: return Qualifier(t.location, Qualifiers.Public); >>,<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>,<Sequential:<true:false:PROTECTED:t>,<Action: return Qualifier(t.location, Qualifiers.Protected); >>,<Sequential:<true:false:STATIC:t>,<Action: return Qualifier(t.location, Qualifiers.Static); >>,<Sequential:<true:false:FINAL:t>,<Action: return Qualifier(t.location, Qualifiers.Final); >>,<Sequential:<true:false:CONST:t>,<Action: return Qualifier(t.location, Qualifiers.Const); >>,<Sequential:<true:false:OVERRIDE:t>,<Action: return Qualifier(t.location, Qualifiers.Override); >>>
		private alias PartialTreeType = PartialTree!336;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential325.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential326.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential333.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential328.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential327.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential332.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential335.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Switching337
	{
		// id=<Switch:<Sequential:<true:false:PUBLIC:t>,<Action: return Qualifier(t.location, Qualifiers.Public); >>,<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>,<Sequential:<true:false:PROTECTED:t>,<Action: return Qualifier(t.location, Qualifiers.Protected); >>,<Sequential:<true:false:CONST:t>,<Action: return Qualifier(t.location, Qualifiers.Const); >>>
		private alias PartialTreeType = PartialTree!337;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential325.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential326.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential333.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential332.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Switching338
	{
		// id=<Switch:<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>,<Sequential:<true:false:PROTECTED:t>,<Action: return Qualifier(t.location, Qualifiers.Protected); >>,<Sequential:<true:false:CONST:t>,<Action: return Qualifier(t.location, Qualifiers.Const); >>,<Sequential:<true:false:STATIC:t>,<Action: return Qualifier(t.location, Qualifiers.Static); >>>
		private alias PartialTreeType = PartialTree!338;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential326.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential333.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential332.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential328.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential339
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:LBR:>,<true:true:def_id_arg_list:params>,<false:false:RBR:>,<Action: return new DefinitionIdentifierNode(id.location, id.text, params); >>
		private alias PartialTreeType = PartialTree!339;
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

			resTemp = ElementParser_LBR.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = def_id_arg_list.parse(r);
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
	private static class ComplexParser_Sequential340
	{
		// id=<Sequential:<false:false:LBR:>,<false:false:RBR:>>
		private alias PartialTreeType = PartialTree!340;
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
	private static class ComplexParser_Skippable341
	{
		// id=<Skippable:<Sequential:<false:false:LBR:>,<false:false:RBR:>>>
		private alias PartialTreeType = PartialTree!341;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential340.parse(r);
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
	private static class ComplexParser_Sequential342
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<Skippable:<Sequential:<false:false:LBR:>,<false:false:RBR:>>>,<Action: return new DefinitionIdentifierNode(id.location, id.text, null); >>
		private alias PartialTreeType = PartialTree!342;
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

			resTemp = ComplexParser_Skippable341.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching343
	{
		// id=<Switch:<Sequential:<true:false:IDENTIFIER:id>,<false:false:LBR:>,<true:true:def_id_arg_list:params>,<false:false:RBR:>,<Action: return new DefinitionIdentifierNode(id.location, id.text, params); >>,<Sequential:<true:false:IDENTIFIER:id>,<Skippable:<Sequential:<false:false:LBR:>,<false:false:RBR:>>>,<Action: return new DefinitionIdentifierNode(id.location, id.text, null); >>>
		private alias PartialTreeType = PartialTree!343;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential339.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential342.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential344
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:def_id_arg:second_t>,<Action: nodes ~= second_t; >>
		private alias PartialTreeType = PartialTree!344;
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
	private static class ComplexParser_LoopQualified345
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:def_id_arg:second_t>,<Action: nodes ~= second_t; >>>
		private alias PartialTreeType = PartialTree!345;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential344.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential346
	{
		// id=<Sequential:<Action: DefinitionIdentifierParamNode[] nodes; >,<true:true:def_id_arg:first_t>,<Action: nodes ~= first_t; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:def_id_arg:second_t>,<Action: nodes ~= second_t; >>>,<Action: return nodes; >>
		private alias PartialTreeType = PartialTree!346;
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

			resTemp = ComplexParser_LoopQualified345.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential347
	{
		// id=<Sequential:<false:false:EQUAL:>,<true:true:type:t>,<Action: n = n.withDefaultValue(t); >>
		private alias PartialTreeType = PartialTree!347;
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
	private static class ComplexParser_Sequential348
	{
		// id=<Sequential:<false:false:COLON:>,<true:true:type:t>,<Action: n = n.withExtendedFrom(t); >>
		private alias PartialTreeType = PartialTree!348;
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
	private static class ComplexParser_Sequential349
	{
		// id=<Sequential:<false:false:RARROW:>,<true:true:type:t>,<Action: n = n.withCastableTo(t); >>
		private alias PartialTreeType = PartialTree!349;
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
	private static class ComplexParser_Switching350
	{
		// id=<Switch:<Sequential:<false:false:EQUAL:>,<true:true:type:t>,<Action: n = n.withDefaultValue(t); >>,<Sequential:<false:false:COLON:>,<true:true:type:t>,<Action: n = n.withExtendedFrom(t); >>,<Sequential:<false:false:RARROW:>,<true:true:type:t>,<Action: n = n.withCastableTo(t); >>>
		private alias PartialTreeType = PartialTree!350;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential347.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential348.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential349.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified351
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:EQUAL:>,<true:true:type:t>,<Action: n = n.withDefaultValue(t); >>,<Sequential:<false:false:COLON:>,<true:true:type:t>,<Action: n = n.withExtendedFrom(t); >>,<Sequential:<false:false:RARROW:>,<true:true:type:t>,<Action: n = n.withCastableTo(t); >>>>
		private alias PartialTreeType = PartialTree!351;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching350.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential352
	{
		// id=<Sequential:<true:true:def_id_argname:n>,<LoopQualified:false:<Switch:<Sequential:<false:false:EQUAL:>,<true:true:type:t>,<Action: n = n.withDefaultValue(t); >>,<Sequential:<false:false:COLON:>,<true:true:type:t>,<Action: n = n.withExtendedFrom(t); >>,<Sequential:<false:false:RARROW:>,<true:true:type:t>,<Action: n = n.withCastableTo(t); >>>>,<Action: return n; >>
		private alias PartialTreeType = PartialTree!352;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = def_id_argname.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified351.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential353
	{
		// id=<Sequential:<true:false:IDENTIFIER:t>,<Action: return new DefinitionIdentifierParamNode(t.location, t.text); >>
		private alias PartialTreeType = PartialTree!353;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential354
	{
		// id=<Sequential:<true:true:type_qualifier:tqq>,<Action: tq = tq.combine(tqq); hasQualifier = true; >>
		private alias PartialTreeType = PartialTree!354;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = type_qualifier.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified355
	{
		// id=<LoopQualified:false:<Sequential:<true:true:type_qualifier:tqq>,<Action: tq = tq.combine(tqq); hasQualifier = true; >>>
		private alias PartialTreeType = PartialTree!355;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential354.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential356
	{
		// id=<Sequential:<Action: auto tq = Qualifier(Location(int.max, int.max), 0); bool hasQualifier = false; >,<LoopQualified:false:<Sequential:<true:true:type_qualifier:tqq>,<Action: tq = tq.combine(tqq); hasQualifier = true; >>>,<true:true:type_body:tb>,<Action: return hasQualifier ? new QualifiedTypeNode(tq, tb) : tb; >>
		private alias PartialTreeType = PartialTree!356;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified355.parse(r);
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
	private static class ComplexParser_Sequential357
	{
		// id=<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<true:true:varg_list:vpl>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, vpl); >>
		private alias PartialTreeType = PartialTree!357;
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

			resTemp = varg_list.parse(r);
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
	private static class ComplexParser_Sequential358
	{
		// id=<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, null); >>
		private alias PartialTreeType = PartialTree!358;
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
	private static class ComplexParser_Switching359
	{
		// id=<Switch:<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<true:true:varg_list:vpl>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, vpl); >>,<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, null); >>>
		private alias PartialTreeType = PartialTree!359;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential357.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential358.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Skippable360
	{
		// id=<Skippable:<Switch:<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<true:true:varg_list:vpl>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, vpl); >>,<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, null); >>>>
		private alias PartialTreeType = PartialTree!360;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Switching359.parse(r);
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
	private static class ComplexParser_Sequential361
	{
		// id=<Sequential:<true:true:type_body_base:tbb>,<Skippable:<Switch:<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<true:true:varg_list:vpl>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, vpl); >>,<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, null); >>>>,<Action: return tbb; >>
		private alias PartialTreeType = PartialTree!361;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = type_body_base.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable360.parse(r);
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
	private static class ComplexParser_Sequential362
	{
		// id=<Sequential:<true:false:AUTO:a>,<Action: return new InferenceTypeNode(a.location); >>
		private alias PartialTreeType = PartialTree!362;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_AUTO.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential363
	{
		// id=<Sequential:<true:true:restricted_type:rt>,<Action: return rt; >>
		private alias PartialTreeType = PartialTree!363;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching364
	{
		// id=<Switch:<Sequential:<true:false:AUTO:a>,<Action: return new InferenceTypeNode(a.location); >>,<Sequential:<true:true:restricted_type:rt>,<Action: return rt; >>>
		private alias PartialTreeType = PartialTree!364;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential362.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential363.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential365
	{
		// id=<Sequential:<false:false:LBR:>,<true:true:expression:e>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, e); >>
		private alias PartialTreeType = PartialTree!365;
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

			resTemp = expression.parse(r);
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
	private static class ComplexParser_Sequential366
	{
		// id=<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, null); >>
		private alias PartialTreeType = PartialTree!366;
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
	private static class ComplexParser_Switching367
	{
		// id=<Switch:<Sequential:<false:false:LBR:>,<true:true:expression:e>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, e); >>,<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, null); >>>
		private alias PartialTreeType = PartialTree!367;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential365.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential366.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified368
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:LBR:>,<true:true:expression:e>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, e); >>,<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, null); >>>>
		private alias PartialTreeType = PartialTree!368;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching367.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential369
	{
		// id=<Sequential:<true:true:primitive_types:pt>,<LoopQualified:false:<Switch:<Sequential:<false:false:LBR:>,<true:true:expression:e>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, e); >>,<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, null); >>>>,<Action: return pt; >>
		private alias PartialTreeType = PartialTree!369;
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

			resTemp = ComplexParser_LoopQualified368.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential370
	{
		// id=<Sequential:<true:true:register_types:rt>,<Action: return rt; >>
		private alias PartialTreeType = PartialTree!370;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = register_types.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential371
	{
		// id=<Sequential:<true:true:template_instance:ti>,<Action: return ti; >>
		private alias PartialTreeType = PartialTree!371;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = template_instance.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential372
	{
		// id=<Sequential:<true:true:__typeof:to>,<Action: return to; >>
		private alias PartialTreeType = PartialTree!372;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = __typeof.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching373
	{
		// id=<Switch:<Sequential:<true:true:register_types:rt>,<Action: return rt; >>,<Sequential:<true:true:template_instance:ti>,<Action: return ti; >>,<Sequential:<true:true:__typeof:to>,<Action: return to; >>>
		private alias PartialTreeType = PartialTree!373;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential370.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential371.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential372.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_TYPEOF = ElementParser!(EnumTokenType.TYPEOF);
	private static class ComplexParser_Sequential374
	{
		// id=<Sequential:<true:true:expression:e>,<false:false:RP:>,<Action: return new TypeofNode(f.location, e); >>
		private alias PartialTreeType = PartialTree!374;
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
	private static class ComplexParser_Sequential375
	{
		// id=<Sequential:<true:true:restricted_type:rt>,<false:false:RP:>,<Action: return new TypeofNode(f.location, rt); >>
		private alias PartialTreeType = PartialTree!375;
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
	private static class ComplexParser_Switching376
	{
		// id=<Switch:<Sequential:<true:true:expression:e>,<false:false:RP:>,<Action: return new TypeofNode(f.location, e); >>,<Sequential:<true:true:restricted_type:rt>,<false:false:RP:>,<Action: return new TypeofNode(f.location, rt); >>>
		private alias PartialTreeType = PartialTree!376;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential374.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential375.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential377
	{
		// id=<Sequential:<true:false:TYPEOF:f>,<false:false:LP:>,<Switch:<Sequential:<true:true:expression:e>,<false:false:RP:>,<Action: return new TypeofNode(f.location, e); >>,<Sequential:<true:true:restricted_type:rt>,<false:false:RP:>,<Action: return new TypeofNode(f.location, rt); >>>>
		private alias PartialTreeType = PartialTree!377;
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

			resTemp = ComplexParser_Switching376.parse(r);
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
	private static class ComplexParser_Sequential378
	{
		// id=<Sequential:<true:false:VOID:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Void); >>
		private alias PartialTreeType = PartialTree!378;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_VOID.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_CHAR = ElementParser!(EnumTokenType.CHAR);
	private static class ComplexParser_Sequential379
	{
		// id=<Sequential:<true:false:CHAR:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Char); >>
		private alias PartialTreeType = PartialTree!379;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_CHAR.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_UCHAR = ElementParser!(EnumTokenType.UCHAR);
	private static class ComplexParser_Sequential380
	{
		// id=<Sequential:<true:false:UCHAR:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Uchar); >>
		private alias PartialTreeType = PartialTree!380;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_UCHAR.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_BYTE = ElementParser!(EnumTokenType.BYTE);
	private static class ComplexParser_Sequential381
	{
		// id=<Sequential:<true:false:BYTE:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Byte); >>
		private alias PartialTreeType = PartialTree!381;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_BYTE.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_SHORT = ElementParser!(EnumTokenType.SHORT);
	private static class ComplexParser_Sequential382
	{
		// id=<Sequential:<true:false:SHORT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Short); >>
		private alias PartialTreeType = PartialTree!382;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_SHORT.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_USHORT = ElementParser!(EnumTokenType.USHORT);
	private static class ComplexParser_Sequential383
	{
		// id=<Sequential:<true:false:USHORT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Ushort); >>
		private alias PartialTreeType = PartialTree!383;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_USHORT.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_INT = ElementParser!(EnumTokenType.INT);
	private static class ComplexParser_Sequential384
	{
		// id=<Sequential:<true:false:INT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Int); >>
		private alias PartialTreeType = PartialTree!384;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_INT.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_UINT = ElementParser!(EnumTokenType.UINT);
	private static class ComplexParser_Sequential385
	{
		// id=<Sequential:<true:false:UINT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Uint); >>
		private alias PartialTreeType = PartialTree!385;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_UINT.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LONG = ElementParser!(EnumTokenType.LONG);
	private static class ComplexParser_Sequential386
	{
		// id=<Sequential:<true:false:LONG:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Long); >>
		private alias PartialTreeType = PartialTree!386;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_LONG.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_ULONG = ElementParser!(EnumTokenType.ULONG);
	private static class ComplexParser_Sequential387
	{
		// id=<Sequential:<true:false:ULONG:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Ulong); >>
		private alias PartialTreeType = PartialTree!387;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_ULONG.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching388
	{
		// id=<Switch:<Sequential:<true:false:VOID:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Void); >>,<Sequential:<true:false:CHAR:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Char); >>,<Sequential:<true:false:UCHAR:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Uchar); >>,<Sequential:<true:false:BYTE:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Byte); >>,<Sequential:<true:false:SHORT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Short); >>,<Sequential:<true:false:USHORT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Ushort); >>,<Sequential:<true:false:INT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Int); >>,<Sequential:<true:false:UINT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Uint); >>,<Sequential:<true:false:LONG:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Long); >>,<Sequential:<true:false:ULONG:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Ulong); >>>
		private alias PartialTreeType = PartialTree!388;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential378.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential379.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential380.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential381.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential382.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential383.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential384.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential385.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential386.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential387.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential389
	{
		// id=<Sequential:<true:true:template_tail:v>,<Action: return new TemplateInstanceTypeNode(t.location, t.text, v); >>
		private alias PartialTreeType = PartialTree!389;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = template_tail.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable390
	{
		// id=<Skippable:<Sequential:<true:true:template_tail:v>,<Action: return new TemplateInstanceTypeNode(t.location, t.text, v); >>>
		private alias PartialTreeType = PartialTree!390;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential389.parse(r);
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
	private static class ComplexParser_Sequential391
	{
		// id=<Sequential:<true:false:IDENTIFIER:t>,<Skippable:<Sequential:<true:true:template_tail:v>,<Action: return new TemplateInstanceTypeNode(t.location, t.text, v); >>>,<Action: return new TemplateInstanceTypeNode(t.location, t.text, null); >>
		private alias PartialTreeType = PartialTree!391;
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

			resTemp = ComplexParser_Skippable390.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_SHARP = ElementParser!(EnumTokenType.SHARP);
	private static class ComplexParser_Sequential392
	{
		// id=<Sequential:<false:false:SHARP:>,<true:true:single_types:st>,<Action: return [new TemplateParamNode(st.location, st)]; >>
		private alias PartialTreeType = PartialTree!392;
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

			resTemp = single_types.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential393
	{
		// id=<Sequential:<false:false:SHARP:>,<true:true:primary_expr:pe>,<Action: return [new TemplateParamNode(pe.location, pe)]; >>
		private alias PartialTreeType = PartialTree!393;
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

			resTemp = primary_expr.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential394
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:template_param:second_t>,<Action: params ~= second_t; >>
		private alias PartialTreeType = PartialTree!394;
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

			resTemp = template_param.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified395
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:template_param:second_t>,<Action: params ~= second_t; >>>
		private alias PartialTreeType = PartialTree!395;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential394.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential396
	{
		// id=<Sequential:<Action: TemplateParamNode[] params; >,<false:false:SHARP:>,<false:false:LP:>,<true:true:template_param:first_t>,<Action: params ~= first_t; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:template_param:second_t>,<Action: params ~= second_t; >>>,<false:false:RP:>,<Action: return params; >>
		private alias PartialTreeType = PartialTree!396;
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

			resTemp = ElementParser_LP.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = template_param.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified395.parse(r);
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
	private static class ComplexParser_Sequential397
	{
		// id=<Sequential:<false:false:SHARP:>,<false:false:LP:>,<false:false:RP:>,<Action: return null; >>
		private alias PartialTreeType = PartialTree!397;
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
	private static class ComplexParser_Switching398
	{
		// id=<Switch:<Sequential:<false:false:SHARP:>,<true:true:single_types:st>,<Action: return [new TemplateParamNode(st.location, st)]; >>,<Sequential:<false:false:SHARP:>,<true:true:primary_expr:pe>,<Action: return [new TemplateParamNode(pe.location, pe)]; >>,<Sequential:<Action: TemplateParamNode[] params; >,<false:false:SHARP:>,<false:false:LP:>,<true:true:template_param:first_t>,<Action: params ~= first_t; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:template_param:second_t>,<Action: params ~= second_t; >>>,<false:false:RP:>,<Action: return params; >>,<Sequential:<false:false:SHARP:>,<false:false:LP:>,<false:false:RP:>,<Action: return null; >>>
		private alias PartialTreeType = PartialTree!398;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential392.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential393.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential396.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential397.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential399
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<Action: return new TemplateParamNode(id.location, id.text); >>
		private alias PartialTreeType = PartialTree!399;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential400
	{
		// id=<Sequential:<true:true:restricted_type:rt>,<Action: return new TemplateParamNode(rt.location, rt); >>
		private alias PartialTreeType = PartialTree!400;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential401
	{
		// id=<Sequential:<true:true:expression:e>,<Action: return new TemplateParamNode(e.location, e); >>
		private alias PartialTreeType = PartialTree!401;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching402
	{
		// id=<Switch:<Sequential:<true:false:IDENTIFIER:id>,<Action: return new TemplateParamNode(id.location, id.text); >>,<Sequential:<true:true:restricted_type:rt>,<Action: return new TemplateParamNode(rt.location, rt); >>,<Sequential:<true:true:expression:e>,<Action: return new TemplateParamNode(e.location, e); >>>
		private alias PartialTreeType = PartialTree!402;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential399.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential400.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential401.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential403
	{
		// id=<Sequential:<true:true:single_restricted_type:srt>,<Action: return srt; >>
		private alias PartialTreeType = PartialTree!403;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = single_restricted_type.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching404
	{
		// id=<Switch:<Sequential:<true:false:AUTO:a>,<Action: return new InferenceTypeNode(a.location); >>,<Sequential:<true:true:single_restricted_type:srt>,<Action: return srt; >>>
		private alias PartialTreeType = PartialTree!404;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential362.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential403.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential405
	{
		// id=<Sequential:<true:false:IDENTIFIER:t>,<Action: return new TemplateInstanceTypeNode(t.location, t.text, null); >>
		private alias PartialTreeType = PartialTree!405;
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
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching406
	{
		// id=<Switch:<Sequential:<true:true:register_types:rt>,<Action: return rt; >>,<Sequential:<true:false:IDENTIFIER:t>,<Action: return new TemplateInstanceTypeNode(t.location, t.text, null); >>>
		private alias PartialTreeType = PartialTree!406;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential370.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential405.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential407
	{
		// id=<Sequential:<false:false:COMMA:>,<false:true:import_item:>>
		private alias PartialTreeType = PartialTree!407;
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
	private static class ComplexParser_LoopQualified408
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:import_item:>>>
		private alias PartialTreeType = PartialTree!408;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential407.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential409
	{
		// id=<Sequential:<false:true:import_item:>,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<false:true:import_item:>>>>
		private alias PartialTreeType = PartialTree!409;
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

			resTemp = ComplexParser_LoopQualified408.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential410
	{
		// id=<Sequential:<false:false:PERIOD:>,<false:false:IDENTIFIER:>>
		private alias PartialTreeType = PartialTree!410;
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
	private static class ComplexParser_LoopQualified411
	{
		// id=<LoopQualified:false:<Sequential:<false:false:PERIOD:>,<false:false:IDENTIFIER:>>>
		private alias PartialTreeType = PartialTree!411;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential410.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential412
	{
		// id=<Sequential:<false:false:PERIOD:>,<false:false:ASTERISK:>>
		private alias PartialTreeType = PartialTree!412;
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
	private static class ComplexParser_Sequential413
	{
		// id=<Sequential:<false:false:PERIOD:>,<false:false:LB:>,<false:true:import_list:>,<false:false:RB:>>
		private alias PartialTreeType = PartialTree!413;
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
	private static class ComplexParser_Switching414
	{
		// id=<Switch:<Sequential:<false:false:PERIOD:>,<false:false:ASTERISK:>>,<Sequential:<false:false:PERIOD:>,<false:false:LB:>,<false:true:import_list:>,<false:false:RB:>>>
		private alias PartialTreeType = PartialTree!414;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential412.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential413.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Skippable415
	{
		// id=<Skippable:<Switch:<Sequential:<false:false:PERIOD:>,<false:false:ASTERISK:>>,<Sequential:<false:false:PERIOD:>,<false:false:LB:>,<false:true:import_list:>,<false:false:RB:>>>>
		private alias PartialTreeType = PartialTree!415;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Switching414.parse(r);
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
	private static class ComplexParser_Sequential416
	{
		// id=<Sequential:<false:false:IDENTIFIER:>,<LoopQualified:false:<Sequential:<false:false:PERIOD:>,<false:false:IDENTIFIER:>>>,<Skippable:<Switch:<Sequential:<false:false:PERIOD:>,<false:false:ASTERISK:>>,<Sequential:<false:false:PERIOD:>,<false:false:LB:>,<false:true:import_list:>,<false:false:RB:>>>>>
		private alias PartialTreeType = PartialTree!416;
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

			resTemp = ComplexParser_LoopQualified411.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable415.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential417
	{
		// id=<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:t2>,<Action: ids ~= t2; >>
		private alias PartialTreeType = PartialTree!417;
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
	private static class ComplexParser_LoopQualified418
	{
		// id=<LoopQualified:false:<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:t2>,<Action: ids ~= t2; >>>
		private alias PartialTreeType = PartialTree!418;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential417.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential419
	{
		// id=<Sequential:<Action: Token[] ids; >,<true:false:IDENTIFIER:t>,<Action: ids ~= t; >,<LoopQualified:false:<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:t2>,<Action: ids ~= t2; >>>,<Action: return ids; >>
		private alias PartialTreeType = PartialTree!419;
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

			resTemp = ComplexParser_LoopQualified418.parse(r);
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
	public alias nvpair = RuleParser!("nvpair", ComplexParser_Switching63);
	public alias method_def = RuleParser!("method_def", ComplexParser_Switching64);
	public alias procedure_def = RuleParser!("procedure_def", ComplexParser_Sequential70);
	public alias function_def = RuleParser!("function_def", ComplexParser_Sequential71);
	public alias abstract_method_def = RuleParser!("abstract_method_def", ComplexParser_Sequential72);
	public alias property_def = RuleParser!("property_def", ComplexParser_Switching73);
	public alias setter_def = RuleParser!("setter_def", ComplexParser_Sequential76);
	public alias getter_def = RuleParser!("getter_def", ComplexParser_Sequential81);
	public alias ctor_def = RuleParser!("ctor_def", ComplexParser_Sequential83);
	public alias tn_pair = RuleParser!("tn_pair", ComplexParser_Switching86);
	public alias tn_list = RuleParser!("tn_list", ComplexParser_Sequential89);
	public alias statement = RuleParser!("statement", ComplexParser_Switching102);
	public alias if_stmt = RuleParser!("if_stmt", ComplexParser_Switching105);
	public alias while_stmt = RuleParser!("while_stmt", ComplexParser_Switching108);
	public alias do_stmt = RuleParser!("do_stmt", ComplexParser_Switching111);
	public alias foreach_stmt = RuleParser!("foreach_stmt", ComplexParser_Switching114);
	public alias foreach_stmt_impl = RuleParser!("foreach_stmt_impl", ComplexParser_Sequential115);
	public alias for_stmt = RuleParser!("for_stmt", ComplexParser_Switching118);
	public alias for_stmt_impl = RuleParser!("for_stmt_impl", ComplexParser_Switching127);
	public alias return_stmt = RuleParser!("return_stmt", ComplexParser_Switching130);
	public alias break_stmt = RuleParser!("break_stmt", ComplexParser_Switching133);
	public alias continue_stmt = RuleParser!("continue_stmt", ComplexParser_Switching136);
	public alias switch_stmt = RuleParser!("switch_stmt", ComplexParser_Sequential141);
	public alias case_stmt = RuleParser!("case_stmt", ComplexParser_Switching144);
	public alias value_case_sect = RuleParser!("value_case_sect", ComplexParser_Sequential145);
	public alias type_case_sect = RuleParser!("type_case_sect", ComplexParser_Switching150);
	public alias default_stmt = RuleParser!("default_stmt", ComplexParser_Sequential151);
	public alias block_stmt = RuleParser!("block_stmt", ComplexParser_Sequential156);
	public alias localvar_def = RuleParser!("localvar_def", ComplexParser_Switching159);
	public alias nvp_list = RuleParser!("nvp_list", ComplexParser_Sequential162);
	public alias full_lvd = RuleParser!("full_lvd", ComplexParser_Sequential165);
	public alias inferenced_lvd = RuleParser!("inferenced_lvd", ComplexParser_Sequential168);
	public alias expression_list = RuleParser!("expression_list", ComplexParser_Sequential171);
	public alias expression = RuleParser!("expression", ComplexParser_Switching175);
	public alias assign_ops = RuleParser!("assign_ops", ComplexParser_Switching186);
	public alias alternate_expr = RuleParser!("alternate_expr", ComplexParser_Sequential189);
	public alias short_expr = RuleParser!("short_expr", ComplexParser_Sequential195);
	public alias comp_expr = RuleParser!("comp_expr", ComplexParser_Sequential204);
	public alias shift_expr = RuleParser!("shift_expr", ComplexParser_Sequential209);
	public alias bit_expr = RuleParser!("bit_expr", ComplexParser_Sequential215);
	public alias a1_expr = RuleParser!("a1_expr", ComplexParser_Sequential220);
	public alias a2_expr = RuleParser!("a2_expr", ComplexParser_Sequential226);
	public alias range_expr = RuleParser!("range_expr", ComplexParser_Sequential229);
	public alias prefix_expr = RuleParser!("prefix_expr", ComplexParser_Switching236);
	public alias postfix_expr = RuleParser!("postfix_expr", ComplexParser_Sequential250);
	public alias primary_expr = RuleParser!("primary_expr", ComplexParser_Switching257);
	public alias literals = RuleParser!("literals", ComplexParser_Switching267);
	public alias function_literal = RuleParser!("function_literal", ComplexParser_Switching270);
	public alias array_literal = RuleParser!("array_literal", ComplexParser_Switching274);
	public alias special_literals = RuleParser!("special_literals", ComplexParser_Switching280);
	public alias lambda_expr = RuleParser!("lambda_expr", ComplexParser_Switching284);
	public alias template_arg_list = RuleParser!("template_arg_list", ComplexParser_Sequential287);
	public alias template_arg = RuleParser!("template_arg", ComplexParser_Sequential290);
	public alias template_arg_type = RuleParser!("template_arg_type", ComplexParser_Sequential295);
	public alias template_arg_head = RuleParser!("template_arg_head", ComplexParser_Switching298);
	public alias varg_list = RuleParser!("varg_list", ComplexParser_Sequential301);
	public alias varg = RuleParser!("varg", ComplexParser_Switching308);
	public alias literal_varg_list = RuleParser!("literal_varg_list", ComplexParser_Sequential311);
	public alias literal_varg = RuleParser!("literal_varg", ComplexParser_Switching320);
	public alias assoc_array_element_list = RuleParser!("assoc_array_element_list", ComplexParser_Sequential323);
	public alias assoc_array_element = RuleParser!("assoc_array_element", ComplexParser_Sequential324);
	public alias class_qualifier = RuleParser!("class_qualifier", ComplexParser_Switching329);
	public alias trait_qualifier = RuleParser!("trait_qualifier", ComplexParser_Switching330);
	public alias enum_qualifier = RuleParser!("enum_qualifier", ComplexParser_Switching330);
	public alias template_qualifier = RuleParser!("template_qualifier", ComplexParser_Switching331);
	public alias alias_qualifier = RuleParser!("alias_qualifier", ComplexParser_Switching331);
	public alias type_qualifier = RuleParser!("type_qualifier", ComplexParser_Sequential332);
	public alias field_qualifier = RuleParser!("field_qualifier", ComplexParser_Switching334);
	public alias method_qualifier = RuleParser!("method_qualifier", ComplexParser_Switching336);
	public alias ctor_qualifier = RuleParser!("ctor_qualifier", ComplexParser_Switching337);
	public alias lvar_qualifier = RuleParser!("lvar_qualifier", ComplexParser_Switching338);
	public alias def_id = RuleParser!("def_id", ComplexParser_Switching343);
	public alias def_id_arg_list = RuleParser!("def_id_arg_list", ComplexParser_Sequential346);
	public alias def_id_arg = RuleParser!("def_id_arg", ComplexParser_Sequential352);
	public alias def_id_argname = RuleParser!("def_id_argname", ComplexParser_Sequential353);
	public alias type = RuleParser!("type", ComplexParser_Sequential356);
	public alias type_body = RuleParser!("type_body", ComplexParser_Sequential361);
	public alias type_body_base = RuleParser!("type_body_base", ComplexParser_Switching364);
	public alias restricted_type = RuleParser!("restricted_type", ComplexParser_Sequential369);
	public alias primitive_types = RuleParser!("primitive_types", ComplexParser_Switching373);
	public alias __typeof = RuleParser!("__typeof", ComplexParser_Sequential377);
	public alias register_types = RuleParser!("register_types", ComplexParser_Switching388);
	public alias template_instance = RuleParser!("template_instance", ComplexParser_Sequential391);
	public alias template_tail = RuleParser!("template_tail", ComplexParser_Switching398);
	public alias template_param = RuleParser!("template_param", ComplexParser_Switching402);
	public alias single_types = RuleParser!("single_types", ComplexParser_Switching404);
	public alias single_restricted_type = RuleParser!("single_restricted_type", ComplexParser_Switching406);
	public alias import_list = RuleParser!("import_list", ComplexParser_Sequential409);
	public alias import_item = RuleParser!("import_item", ComplexParser_Sequential416);
	public alias package_id = RuleParser!("package_id", ComplexParser_Sequential419);
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
		}
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
		}
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
			}
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
		}
		assert(false);
	}
	private static auto reduce_enum_element(RuleTree!"enum_element" node) in { assert(node !is null); } body
	{
		if(node.content.child[1].child[0].child.length > 0)
		{
		}
		assert(false);
	}
	private static auto reduce_template_def(RuleTree!"template_def" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[0].child)
		{
		}
		if(node.content.child[4].child[0].child.length > 0)
		{
		}
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
		if((cast(PartialTree!61)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!61)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[2]));
			 return new NameValuePair(id.location, id.text, e); 
		}
		else if((cast(PartialTree!62)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!62)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new NameValuePair(id.location, id.text, null); 
		}
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
		}
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
		}
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
		}
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
		}
		assert(false);
	}
	private static auto reduce_getter_def(RuleTree!"getter_def" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[0].child)
		{
		}
		if(node.content.child[2].child[0].child.length > 0)
		{
		}
		if(node.content.child[4].child[0].child.length > 0)
		{
		}
		assert(false);
	}
	private static auto reduce_ctor_def(RuleTree!"ctor_def" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[0].child)
		{
		}
		if(node.content.child[3].child[0].child.length > 0)
		{
		}
		assert(false);
	}
	private static auto reduce_tn_pair(RuleTree!"tn_pair" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!84)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!84)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[0]));
			auto id = (cast(TokenTree)(__tree_ref__.child[1])).token;
			 return new TypeNamePair(t.location, t, id.text); 
		}
		else if((cast(PartialTree!85)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!85)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new TypeNamePair(id.location, null, id.text); 
		}
		assert(false);
	}
	private static auto reduce_tn_list(RuleTree!"tn_list" node) in { assert(node !is null); } body
	{
		 TypeNamePair[] tnps; 
		auto tnp = reduce_tn_pair(cast(RuleTree!"tn_pair")(node.content.child[1]));
		 tnps ~= tnp; 
		foreach(n0; node.content.child[3].child)
		{
			auto tnp2 = reduce_tn_pair(cast(RuleTree!"tn_pair")(n0.child[1]));
			 tnps ~= tnp2; 
		}
		 return tnps; 
		assert(false);
	}
	private static StatementNode reduce_statement(RuleTree!"statement" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!90)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!90)(node.content.child[0]);
			auto ifs = reduce_if_stmt(cast(RuleTree!"if_stmt")(__tree_ref__.child[0]));
			 return ifs; 
		}
		else if((cast(PartialTree!91)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!91)(node.content.child[0]);
			auto ws = reduce_while_stmt(cast(RuleTree!"while_stmt")(__tree_ref__.child[0]));
			 return ws; 
		}
		else if((cast(PartialTree!92)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!92)(node.content.child[0]);
			auto ds = reduce_do_stmt(cast(RuleTree!"do_stmt")(__tree_ref__.child[0]));
			 return ds; 
		}
		else if((cast(PartialTree!93)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!93)(node.content.child[0]);
			auto fes = reduce_foreach_stmt(cast(RuleTree!"foreach_stmt")(__tree_ref__.child[0]));
			 return fes; 
		}
		else if((cast(PartialTree!94)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!94)(node.content.child[0]);
			auto fs = reduce_for_stmt(cast(RuleTree!"for_stmt")(__tree_ref__.child[0]));
			 return fs; 
		}
		else if((cast(PartialTree!95)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!95)(node.content.child[0]);
			auto rs = reduce_return_stmt(cast(RuleTree!"return_stmt")(__tree_ref__.child[0]));
			 return rs; 
		}
		else if((cast(PartialTree!96)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!96)(node.content.child[0]);
			auto bs = reduce_break_stmt(cast(RuleTree!"break_stmt")(__tree_ref__.child[0]));
			 return bs; 
		}
		else if((cast(PartialTree!97)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!97)(node.content.child[0]);
			auto cs = reduce_continue_stmt(cast(RuleTree!"continue_stmt")(__tree_ref__.child[0]));
			 return cs; 
		}
		else if((cast(PartialTree!98)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!98)(node.content.child[0]);
			auto ss = reduce_switch_stmt(cast(RuleTree!"switch_stmt")(__tree_ref__.child[0]));
			 return ss; 
		}
		else if((cast(PartialTree!99)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!99)(node.content.child[0]);
			auto bls = reduce_block_stmt(cast(RuleTree!"block_stmt")(__tree_ref__.child[0]));
			 return bls; 
		}
		else if((cast(PartialTree!100)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!100)(node.content.child[0]);
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[0]));
			 return e; 
		}
		else if((cast(PartialTree!101)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!101)(node.content.child[0]);
			 return null; 
		}
		assert(false);
	}
	private static auto reduce_if_stmt(RuleTree!"if_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!103)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!103)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto c = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[2]));
			auto t = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[4]));
			auto n = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[6]));
			 return new ConditionalNode(ft.location, c, t, n); 
		}
		else if((cast(PartialTree!104)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!104)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto c = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[2]));
			auto t = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[4]));
			 return new ConditionalNode(ft.location, c, t, null); 
		}
		assert(false);
	}
	private static auto reduce_while_stmt(RuleTree!"while_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!106)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!106)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto ft = (cast(TokenTree)(__tree_ref__.child[2])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[4]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[6]));
			 return new PreConditionLoopNode(ft.location, id.text, e, st); 
		}
		else if((cast(PartialTree!107)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!107)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[2]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[4]));
			 return new PreConditionLoopNode(ft.location, e, st); 
		}
		assert(false);
	}
	private static auto reduce_do_stmt(RuleTree!"do_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!109)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!109)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto ft = (cast(TokenTree)(__tree_ref__.child[2])).token;
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[3]));
			auto c = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[6]));
			 return new PostConditionLoopNode(ft.location, id.text, c, st); 
		}
		else if((cast(PartialTree!110)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!110)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[1]));
			auto c = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[4]));
			 return new PostConditionLoopNode(ft.location, c, st); 
		}
		assert(false);
	}
	private static auto reduce_foreach_stmt(RuleTree!"foreach_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!112)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!112)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto fs = reduce_foreach_stmt_impl(cast(RuleTree!"foreach_stmt_impl")(__tree_ref__.child[2]));
			 return fs.withName(id.text); 
		}
		else if((cast(PartialTree!113)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!113)(node.content.child[0]);
			auto fs = reduce_foreach_stmt_impl(cast(RuleTree!"foreach_stmt_impl")(__tree_ref__.child[0]));
			 return fs; 
		}
		assert(false);
	}
	private static auto reduce_foreach_stmt_impl(RuleTree!"foreach_stmt_impl" node) in { assert(node !is null); } body
	{
		auto ft = (cast(TokenTree)(node.content.child[0])).token;
		auto tnl = reduce_tn_list(cast(RuleTree!"tn_list")(node.content.child[2]));
		auto e = reduce_expression(cast(RuleTree!"expression")(node.content.child[4]));
		auto st = reduce_statement(cast(RuleTree!"statement")(node.content.child[6]));
		 return new ForeachStatementNode(ft.location, tnl, e, st); 
		assert(false);
	}
	private static auto reduce_for_stmt(RuleTree!"for_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!116)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!116)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto fs = reduce_for_stmt_impl(cast(RuleTree!"for_stmt_impl")(__tree_ref__.child[2]));
			 return fs.withName(id.text); 
		}
		else if((cast(PartialTree!117)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!117)(node.content.child[0]);
			auto fs = reduce_for_stmt_impl(cast(RuleTree!"for_stmt_impl")(__tree_ref__.child[0]));
			 return fs; 
		}
		assert(false);
	}
	private static auto reduce_for_stmt_impl(RuleTree!"for_stmt_impl" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!119)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!119)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[2]));
			auto e2 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[4]));
			auto e3 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[6]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[8]));
			 return new ForStatementNode(ft.location, e, e2, e3, st); 
		}
		else if((cast(PartialTree!120)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!120)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[2]));
			auto e2 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[4]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[7]));
			 return new ForStatementNode(ft.location, e, e2, null, st); 
		}
		else if((cast(PartialTree!121)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!121)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[2]));
			auto e3 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[5]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[7]));
			 return new ForStatementNode(ft.location, e, null, e3, st); 
		}
		else if((cast(PartialTree!122)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!122)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[2]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[6]));
			 return new ForStatementNode(ft.location, e, null, null, st); 
		}
		else if((cast(PartialTree!123)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!123)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e2 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[3]));
			auto e3 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[5]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[7]));
			 return new ForStatementNode(ft.location, null, e2, e3, st); 
		}
		else if((cast(PartialTree!124)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!124)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e2 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[3]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[6]));
			 return new ForStatementNode(ft.location, null, e2, null, st); 
		}
		else if((cast(PartialTree!125)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!125)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e3 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[4]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[6]));
			 return new ForStatementNode(ft.location, null, null, e3, st); 
		}
		else if((cast(PartialTree!126)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!126)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[6]));
			 return new ForStatementNode(ft.location, null, null, null, st); 
		}
		assert(false);
	}
	private static auto reduce_return_stmt(RuleTree!"return_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!128)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!128)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[1]));
			 return new ReturnNode(ft.location, e); 
		}
		else if((cast(PartialTree!129)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!129)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new ReturnNode(ft.location, null); 
		}
		assert(false);
	}
	private static auto reduce_break_stmt(RuleTree!"break_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!131)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!131)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto id = (cast(TokenTree)(__tree_ref__.child[1])).token;
			 return new BreakLoopNode(ft.location, id.text); 
		}
		else if((cast(PartialTree!132)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!132)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new BreakLoopNode(ft.location, null); 
		}
		assert(false);
	}
	private static auto reduce_continue_stmt(RuleTree!"continue_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!134)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!134)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto id = (cast(TokenTree)(__tree_ref__.child[1])).token;
			 return new ContinueLoopNode(ft.location, id.text); 
		}
		else if((cast(PartialTree!135)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!135)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new ContinueLoopNode(ft.location, null); 
		}
		assert(false);
	}
	private static auto reduce_switch_stmt(RuleTree!"switch_stmt" node) in { assert(node !is null); } body
	{
		auto ft = (cast(TokenTree)(node.content.child[0])).token;
		auto te = reduce_expression(cast(RuleTree!"expression")(node.content.child[2]));
		 SwitchSectionNode[] sects; 
		foreach(n0; node.content.child[6].child)
		{
			if((cast(PartialTree!137)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!137)(n0.child[0]);
				auto cs = reduce_case_stmt(cast(RuleTree!"case_stmt")(__tree_ref__.child[0]));
				 sects ~= cs; 
			}
			else if((cast(PartialTree!138)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!138)(n0.child[0]);
				auto ds = reduce_default_stmt(cast(RuleTree!"default_stmt")(__tree_ref__.child[0]));
				 sects ~= ds; 
			}
		}
		 return new SwitchStatementNode(ft.location, te, sects); 
		assert(false);
	}
	private static SwitchSectionNode reduce_case_stmt(RuleTree!"case_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!142)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!142)(node.content.child[0]);
			auto vcs = reduce_value_case_sect(cast(RuleTree!"value_case_sect")(__tree_ref__.child[0]));
			 return vcs; 
		}
		else if((cast(PartialTree!143)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!143)(node.content.child[0]);
			auto tcs = reduce_type_case_sect(cast(RuleTree!"type_case_sect")(__tree_ref__.child[0]));
			 return tcs; 
		}
		assert(false);
	}
	private static auto reduce_value_case_sect(RuleTree!"value_case_sect" node) in { assert(node !is null); } body
	{
		auto ft = (cast(TokenTree)(node.content.child[0])).token;
		auto el = reduce_expression_list(cast(RuleTree!"expression_list")(node.content.child[1]));
		auto st = reduce_statement(cast(RuleTree!"statement")(node.content.child[3]));
		 return new ValueCaseSectionNode(ft.location, el, st); 
		assert(false);
	}
	private static auto reduce_type_case_sect(RuleTree!"type_case_sect" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!146)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!146)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto id = reduce_def_id(cast(RuleTree!"def_id")(__tree_ref__.child[2]));
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[4]));
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[6]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[8]));
			 return new TypeCaseSectionNode(ft.location, true, id, t, e, st); 
		}
		else if((cast(PartialTree!147)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!147)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto id = reduce_def_id(cast(RuleTree!"def_id")(__tree_ref__.child[2]));
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[4]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[6]));
			 return new TypeCaseSectionNode(ft.location, true, id, t, null, st); 
		}
		else if((cast(PartialTree!148)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!148)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto id = reduce_def_id(cast(RuleTree!"def_id")(__tree_ref__.child[1]));
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[3]));
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[5]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[7]));
			 return new TypeCaseSectionNode(ft.location, false, id, t, e, st); 
		}
		else if((cast(PartialTree!149)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!149)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto id = reduce_def_id(cast(RuleTree!"def_id")(__tree_ref__.child[1]));
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[3]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[5]));
			 return new TypeCaseSectionNode(ft.location, false, id, t, null, st); 
		}
		assert(false);
	}
	private static auto reduce_default_stmt(RuleTree!"default_stmt" node) in { assert(node !is null); } body
	{
		auto ft = (cast(TokenTree)(node.content.child[0])).token;
		auto s = reduce_statement(cast(RuleTree!"statement")(node.content.child[2]));
		 return new DefaultSectionNode(ft.location, s); 
		assert(false);
	}
	private static auto reduce_block_stmt(RuleTree!"block_stmt" node) in { assert(node !is null); } body
	{
		auto t = (cast(TokenTree)(node.content.child[0])).token;
		 StatementNode[] stmts; 
		foreach(n0; node.content.child[2].child)
		{
			if((cast(PartialTree!152)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!152)(n0.child[0]);
				auto lvd = reduce_localvar_def(cast(RuleTree!"localvar_def")(__tree_ref__.child[0]));
				 stmts ~= lvd; 
			}
			else if((cast(PartialTree!153)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!153)(n0.child[0]);
				auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__.child[0]));
				 stmts ~= st; 
			}
		}
		 return new BlockStatementNode(t.location, stmts); 
		assert(false);
	}
	private static auto reduce_localvar_def(RuleTree!"localvar_def" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!157)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!157)(node.content.child[0]);
			auto flvd = reduce_full_lvd(cast(RuleTree!"full_lvd")(__tree_ref__.child[0]));
			 return flvd; 
		}
		else if((cast(PartialTree!158)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!158)(node.content.child[0]);
			auto ilvd = reduce_inferenced_lvd(cast(RuleTree!"inferenced_lvd")(__tree_ref__.child[0]));
			 return ilvd; 
		}
		assert(false);
	}
	private static auto reduce_nvp_list(RuleTree!"nvp_list" node) in { assert(node !is null); } body
	{
		 NameValuePair[] nvps; 
		auto nvp = reduce_nvpair(cast(RuleTree!"nvpair")(node.content.child[1]));
		 nvps ~= nvp; 
		foreach(n0; node.content.child[3].child)
		{
			auto nvp2 = reduce_nvpair(cast(RuleTree!"nvpair")(n0.child[1]));
			 nvps ~= nvp2; 
		}
		 return nvps; 
		assert(false);
	}
	private static auto reduce_full_lvd(RuleTree!"full_lvd" node) in { assert(node !is null); } body
	{
		 auto q = Qualifier(Location(int.max, int.max), Qualifiers.Public); 
		foreach(n0; node.content.child[1].child)
		{
			auto lq = reduce_lvar_qualifier(cast(RuleTree!"lvar_qualifier")(n0.child[0]));
			 q = q.combine(lq); 
		}
		auto tp = reduce_type(cast(RuleTree!"type")(node.content.child[2]));
		auto nvps = reduce_nvp_list(cast(RuleTree!"nvp_list")(node.content.child[3]));
		 return new LocalVariableDeclarationNode(q.location.line == int.max ? tp.location : q.location, q, tp, nvps); 
		assert(false);
	}
	private static auto reduce_inferenced_lvd(RuleTree!"inferenced_lvd" node) in { assert(node !is null); } body
	{
		auto q = reduce_lvar_qualifier(cast(RuleTree!"lvar_qualifier")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			auto q2 = reduce_lvar_qualifier(cast(RuleTree!"lvar_qualifier")(n0.child[0]));
			 q = q.combine(q2); 
		}
		auto nvps = reduce_nvp_list(cast(RuleTree!"nvp_list")(node.content.child[2]));
		 return new LocalVariableDeclarationNode(q.location, q, new InferenceTypeNode(q.location), nvps); 
		assert(false);
	}
	private static auto reduce_expression_list(RuleTree!"expression_list" node) in { assert(node !is null); } body
	{
		 ExpressionNode[] elist; 
		auto e = reduce_expression(cast(RuleTree!"expression")(node.content.child[1]));
		 elist ~= e; 
		foreach(n0; node.content.child[3].child)
		{
			auto e2 = reduce_expression(cast(RuleTree!"expression")(n0.child[1]));
			 elist ~= e2; 
		}
		 return elist; 
		assert(false);
	}
	private static ExpressionNode reduce_expression(RuleTree!"expression" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!172)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!172)(node.content.child[0]);
			auto l = reduce_postfix_expr(cast(RuleTree!"postfix_expr")(__tree_ref__.child[0]));
			auto r = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[2]));
			 return new AssignOperatorNode(l, r); 
		}
		else if((cast(PartialTree!173)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!173)(node.content.child[0]);
			auto l = reduce_postfix_expr(cast(RuleTree!"postfix_expr")(__tree_ref__.child[0]));
			auto o = reduce_assign_ops(cast(RuleTree!"assign_ops")(__tree_ref__.child[1]));
			auto r = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[2]));
			 return new OperatedAssignNode(l, o, r); 
		}
		else if((cast(PartialTree!174)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!174)(node.content.child[0]);
			auto e = reduce_alternate_expr(cast(RuleTree!"alternate_expr")(__tree_ref__.child[0]));
			 return e; 
		}
		assert(false);
	}
	private static auto reduce_assign_ops(RuleTree!"assign_ops" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!176)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!176)(node.content.child[0]);
			 return BinaryOperatorType.Add; 
		}
		else if((cast(PartialTree!177)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!177)(node.content.child[0]);
			 return BinaryOperatorType.Sub; 
		}
		else if((cast(PartialTree!178)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!178)(node.content.child[0]);
			 return BinaryOperatorType.Mul; 
		}
		else if((cast(PartialTree!179)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!179)(node.content.child[0]);
			 return BinaryOperatorType.Div; 
		}
		else if((cast(PartialTree!180)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!180)(node.content.child[0]);
			 return BinaryOperatorType.Mod; 
		}
		else if((cast(PartialTree!181)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!181)(node.content.child[0]);
			 return BinaryOperatorType.And; 
		}
		else if((cast(PartialTree!182)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!182)(node.content.child[0]);
			 return BinaryOperatorType.Or; 
		}
		else if((cast(PartialTree!183)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!183)(node.content.child[0]);
			 return BinaryOperatorType.Xor; 
		}
		else if((cast(PartialTree!184)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!184)(node.content.child[0]);
			 return BinaryOperatorType.LeftShift; 
		}
		else if((cast(PartialTree!185)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!185)(node.content.child[0]);
			 return BinaryOperatorType.RightShift; 
		}
		assert(false);
	}
	private static ExpressionNode reduce_alternate_expr(RuleTree!"alternate_expr" node) in { assert(node !is null); } body
	{
		auto e = reduce_short_expr(cast(RuleTree!"short_expr")(node.content.child[0]));
		if(node.content.child[1].child[0].child.length > 0)
		{
			auto t = reduce_short_expr(cast(RuleTree!"short_expr")(node.content.child[1].child[0].child[0].child[1]));
			auto n = reduce_short_expr(cast(RuleTree!"short_expr")(node.content.child[1].child[0].child[0].child[3]));
			 e = new AlternateValueNode(e, t, n); 
		}
		 return e; 
		assert(false);
	}
	private static ExpressionNode reduce_short_expr(RuleTree!"short_expr" node) in { assert(node !is null); } body
	{
		auto e = reduce_comp_expr(cast(RuleTree!"comp_expr")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			if((cast(PartialTree!190)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!190)(n0.child[0]);
				auto e2 = reduce_comp_expr(cast(RuleTree!"comp_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.LogAnd, e2); 
			}
			else if((cast(PartialTree!191)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!191)(n0.child[0]);
				auto e2 = reduce_comp_expr(cast(RuleTree!"comp_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.LogOr, e2); 
			}
			else if((cast(PartialTree!192)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!192)(n0.child[0]);
				auto e2 = reduce_comp_expr(cast(RuleTree!"comp_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.LogXor, e2); 
			}
		}
		 return e; 
		assert(false);
	}
	private static ExpressionNode reduce_comp_expr(RuleTree!"comp_expr" node) in { assert(node !is null); } body
	{
		auto e = reduce_shift_expr(cast(RuleTree!"shift_expr")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			if((cast(PartialTree!196)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!196)(n0.child[0]);
				auto e2 = reduce_shift_expr(cast(RuleTree!"shift_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Less, e2); 
			}
			else if((cast(PartialTree!197)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!197)(n0.child[0]);
				auto e2 = reduce_shift_expr(cast(RuleTree!"shift_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Greater, e2); 
			}
			else if((cast(PartialTree!198)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!198)(n0.child[0]);
				auto e2 = reduce_shift_expr(cast(RuleTree!"shift_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Equiv, e2); 
			}
			else if((cast(PartialTree!199)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!199)(n0.child[0]);
				auto e2 = reduce_shift_expr(cast(RuleTree!"shift_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Inequiv, e2); 
			}
			else if((cast(PartialTree!200)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!200)(n0.child[0]);
				auto e2 = reduce_shift_expr(cast(RuleTree!"shift_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.LessEq, e2); 
			}
			else if((cast(PartialTree!201)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!201)(n0.child[0]);
				auto e2 = reduce_shift_expr(cast(RuleTree!"shift_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.GreaterEq, e2); 
			}
		}
		 return e; 
		assert(false);
	}
	private static ExpressionNode reduce_shift_expr(RuleTree!"shift_expr" node) in { assert(node !is null); } body
	{
		auto e = reduce_bit_expr(cast(RuleTree!"bit_expr")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			if((cast(PartialTree!205)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!205)(n0.child[0]);
				auto e2 = reduce_bit_expr(cast(RuleTree!"bit_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.LeftShift, e2); 
			}
			else if((cast(PartialTree!206)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!206)(n0.child[0]);
				auto e2 = reduce_bit_expr(cast(RuleTree!"bit_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.RightShift, e2); 
			}
		}
		 return e; 
		assert(false);
	}
	private static ExpressionNode reduce_bit_expr(RuleTree!"bit_expr" node) in { assert(node !is null); } body
	{
		auto e = reduce_a1_expr(cast(RuleTree!"a1_expr")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			if((cast(PartialTree!210)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!210)(n0.child[0]);
				auto e2 = reduce_a1_expr(cast(RuleTree!"a1_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.And, e2); 
			}
			else if((cast(PartialTree!211)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!211)(n0.child[0]);
				auto e2 = reduce_a1_expr(cast(RuleTree!"a1_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Or, e2); 
			}
			else if((cast(PartialTree!212)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!212)(n0.child[0]);
				auto e2 = reduce_a1_expr(cast(RuleTree!"a1_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Xor, e2); 
			}
		}
		 return e; 
		assert(false);
	}
	private static ExpressionNode reduce_a1_expr(RuleTree!"a1_expr" node) in { assert(node !is null); } body
	{
		auto e = reduce_a2_expr(cast(RuleTree!"a2_expr")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			if((cast(PartialTree!216)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!216)(n0.child[0]);
				auto e2 = reduce_a2_expr(cast(RuleTree!"a2_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Add, e2); 
			}
			else if((cast(PartialTree!217)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!217)(n0.child[0]);
				auto e2 = reduce_a2_expr(cast(RuleTree!"a2_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Sub, e2); 
			}
		}
		 return e; 
		assert(false);
	}
	private static ExpressionNode reduce_a2_expr(RuleTree!"a2_expr" node) in { assert(node !is null); } body
	{
		auto e = reduce_range_expr(cast(RuleTree!"range_expr")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			if((cast(PartialTree!221)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!221)(n0.child[0]);
				auto e2 = reduce_range_expr(cast(RuleTree!"range_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Mul, e2); 
			}
			else if((cast(PartialTree!222)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!222)(n0.child[0]);
				auto e2 = reduce_range_expr(cast(RuleTree!"range_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Div, e2); 
			}
			else if((cast(PartialTree!223)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!223)(n0.child[0]);
				auto e2 = reduce_range_expr(cast(RuleTree!"range_expr")(__tree_ref__.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Mod, e2); 
			}
		}
		 return e; 
		assert(false);
	}
	private static ExpressionNode reduce_range_expr(RuleTree!"range_expr" node) in { assert(node !is null); } body
	{
		auto e = reduce_prefix_expr(cast(RuleTree!"prefix_expr")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			auto e2 = reduce_prefix_expr(cast(RuleTree!"prefix_expr")(n0.child[1]));
			 e = new BinaryOperatorNode(e, BinaryOperatorType.Ranged, e2); 
		}
		 return e; 
		assert(false);
	}
	private static ExpressionNode reduce_prefix_expr(RuleTree!"prefix_expr" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!230)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!230)(node.content.child[0]);
			auto e = reduce_prefix_expr(cast(RuleTree!"prefix_expr")(__tree_ref__.child[1]));
			 return e; 
		}
		else if((cast(PartialTree!231)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!231)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e = reduce_prefix_expr(cast(RuleTree!"prefix_expr")(__tree_ref__.child[1]));
			 return new PreOperatorNode(t.location, e, UnaryOperatorType.Negate); 
		}
		else if((cast(PartialTree!232)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!232)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e = reduce_prefix_expr(cast(RuleTree!"prefix_expr")(__tree_ref__.child[1]));
			 return new PreOperatorNode(t.location, e, UnaryOperatorType.Increase); 
		}
		else if((cast(PartialTree!233)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!233)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e = reduce_prefix_expr(cast(RuleTree!"prefix_expr")(__tree_ref__.child[1]));
			 return new PreOperatorNode(t.location, e, UnaryOperatorType.Decrease); 
		}
		else if((cast(PartialTree!234)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!234)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e = reduce_prefix_expr(cast(RuleTree!"prefix_expr")(__tree_ref__.child[1]));
			 return new PreOperatorNode(t.location, e, UnaryOperatorType.Square); 
		}
		else if((cast(PartialTree!235)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!235)(node.content.child[0]);
			auto e = reduce_postfix_expr(cast(RuleTree!"postfix_expr")(__tree_ref__.child[0]));
			 return e; 
		}
		assert(false);
	}
	private static ExpressionNode reduce_postfix_expr(RuleTree!"postfix_expr" node) in { assert(node !is null); } body
	{
		auto e = reduce_primary_expr(cast(RuleTree!"primary_expr")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			if((cast(PartialTree!237)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!237)(n0.child[0]);
				 e = new PostOperatorNode(e, UnaryOperatorType.Increase); 
			}
			else if((cast(PartialTree!238)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!238)(n0.child[0]);
				 e = new PostOperatorNode(e, UnaryOperatorType.Decrease); 
			}
			else if((cast(PartialTree!239)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!239)(n0.child[0]);
				 e = new PostOperatorNode(e, UnaryOperatorType.Square); 
			}
			else if((cast(PartialTree!240)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!240)(n0.child[0]);
				auto d = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[1]));
				 e = new ArrayRefNode(e, [d]); 
			}
			else if((cast(PartialTree!241)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!241)(n0.child[0]);
				 e = new ArrayRefNode(e, null); 
			}
			else if((cast(PartialTree!242)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!242)(n0.child[0]);
				auto ps = reduce_expression_list(cast(RuleTree!"expression_list")(__tree_ref__.child[1]));
				 e = new FuncallNode(e, ps); 
			}
			else if((cast(PartialTree!243)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!243)(n0.child[0]);
				 e = new FuncallNode(e, null); 
			}
			else if((cast(PartialTree!244)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!244)(n0.child[0]);
				auto id = (cast(TokenTree)(__tree_ref__.child[1])).token;
				auto tt = reduce_template_tail(cast(RuleTree!"template_tail")(__tree_ref__.child[2]));
				 e = new ObjectRefNode(e, new TemplateInstantiateNode(id.location, id.text, tt)); 
			}
			else if((cast(PartialTree!245)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!245)(n0.child[0]);
				auto id = (cast(TokenTree)(__tree_ref__.child[1])).token;
				 e = new ObjectRefNode(e, new IdentifierReferenceNode(id.location, id.text)); 
			}
			else if((cast(PartialTree!246)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!246)(n0.child[0]);
				auto st = reduce_single_types(cast(RuleTree!"single_types")(__tree_ref__.child[1]));
				 e = new CastingNode(e, st); 
			}
			else if((cast(PartialTree!247)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!247)(n0.child[0]);
				auto rt = reduce_restricted_type(cast(RuleTree!"restricted_type")(__tree_ref__.child[2]));
				 e = new CastingNode(e, rt); 
			}
		}
		 return e; 
		assert(false);
	}
	private static ExpressionNode reduce_primary_expr(RuleTree!"primary_expr" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!251)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!251)(node.content.child[0]);
			auto l = reduce_literals(cast(RuleTree!"literals")(__tree_ref__.child[0]));
			 return l; 
		}
		else if((cast(PartialTree!252)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!252)(node.content.child[0]);
			auto sl = reduce_special_literals(cast(RuleTree!"special_literals")(__tree_ref__.child[0]));
			 return sl; 
		}
		else if((cast(PartialTree!253)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!253)(node.content.child[0]);
			auto le = reduce_lambda_expr(cast(RuleTree!"lambda_expr")(__tree_ref__.child[0]));
			 return le; 
		}
		else if((cast(PartialTree!254)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!254)(node.content.child[0]);
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[1]));
			 return e; 
		}
		else if((cast(PartialTree!255)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!255)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto tt = reduce_template_tail(cast(RuleTree!"template_tail")(__tree_ref__.child[1]));
			 return new TemplateInstantiateNode(id.location, id.text, tt); 
		}
		else if((cast(PartialTree!256)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!256)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new IdentifierReferenceNode(id.location, id.text); 
		}
		assert(false);
	}
	private static ExpressionNode reduce_literals(RuleTree!"literals" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!258)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!258)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new IntLiteralNode(t.location, t.text.to!int); 
		}
		else if((cast(PartialTree!259)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!259)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new IntLiteralNode(t.location, t.text.to!int(16)); 
		}
		else if((cast(PartialTree!260)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!260)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new FloatLiteralNode(t.location, t.text.to!float); 
		}
		else if((cast(PartialTree!261)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!261)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new DoubleLiteralNode(t.location, t.text.to!double); 
		}
		else if((cast(PartialTree!262)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!262)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new NumericLiteralNode(t.location, t.text.to!real); 
		}
		else if((cast(PartialTree!263)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!263)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new StringLiteralNode(t.location, t.text); 
		}
		else if((cast(PartialTree!264)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!264)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new CharacterLiteralNode(t.location, t.text[0]); 
		}
		else if((cast(PartialTree!265)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!265)(node.content.child[0]);
			auto fl = reduce_function_literal(cast(RuleTree!"function_literal")(__tree_ref__.child[0]));
			 return fl; 
		}
		else if((cast(PartialTree!266)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!266)(node.content.child[0]);
			auto al = reduce_array_literal(cast(RuleTree!"array_literal")(__tree_ref__.child[0]));
			 return al; 
		}
		assert(false);
	}
	private static auto reduce_function_literal(RuleTree!"function_literal" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!268)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!268)(node.content.child[0]);
			auto f = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto vl = reduce_literal_varg_list(cast(RuleTree!"literal_varg_list")(__tree_ref__.child[2]));
			auto bs = reduce_block_stmt(cast(RuleTree!"block_stmt")(__tree_ref__.child[4]));
			 return new FunctionLiteralNode(f.location, vl, bs); 
		}
		else if((cast(PartialTree!269)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!269)(node.content.child[0]);
			auto f = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto bs = reduce_block_stmt(cast(RuleTree!"block_stmt")(__tree_ref__.child[3]));
			 return new FunctionLiteralNode(f.location, null, bs); 
		}
		assert(false);
	}
	private static ExpressionNode reduce_array_literal(RuleTree!"array_literal" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!271)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!271)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto el = reduce_expression_list(cast(RuleTree!"expression_list")(__tree_ref__.child[1]));
			 return new ArrayLiteralNode(ft.location, el); 
		}
		else if((cast(PartialTree!272)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!272)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto el = reduce_assoc_array_element_list(cast(RuleTree!"assoc_array_element_list")(__tree_ref__.child[1]));
			 return new AssocArrayLiteralNode(ft.location, el); 
		}
		else if((cast(PartialTree!273)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!273)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new ArrayLiteralNode(ft.location, null); 
		}
		assert(false);
	}
	private static ExpressionNode reduce_special_literals(RuleTree!"special_literals" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!275)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!275)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new ThisReferenceNode(t.location); 
		}
		else if((cast(PartialTree!276)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!276)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new SuperReferenceNode(t.location); 
		}
		else if((cast(PartialTree!277)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!277)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new BooleanLiteralNode(t.location, true); 
		}
		else if((cast(PartialTree!278)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!278)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new BooleanLiteralNode(t.location, false); 
		}
		else if((cast(PartialTree!279)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!279)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new NullLiteralNode(t.location); 
		}
		assert(false);
	}
	private static auto reduce_lambda_expr(RuleTree!"lambda_expr" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!281)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!281)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto ps = reduce_literal_varg_list(cast(RuleTree!"literal_varg_list")(__tree_ref__.child[1]));
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[4]));
			 return new FunctionLiteralNode(t.location, ps, e); 
		}
		else if((cast(PartialTree!282)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!282)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[3]));
			 return new FunctionLiteralNode(t.location, null, e); 
		}
		else if((cast(PartialTree!283)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!283)(node.content.child[0]);
			auto vp = reduce_literal_varg(cast(RuleTree!"literal_varg")(__tree_ref__.child[0]));
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[2]));
			 return new FunctionLiteralNode(vp, e); 
		}
		assert(false);
	}
	private static auto reduce_template_arg_list(RuleTree!"template_arg_list" node) in { assert(node !is null); } body
	{
		 TemplateVirtualParamNode[] params; 
		auto p = reduce_template_arg(cast(RuleTree!"template_arg")(node.content.child[1]));
		 params ~= p; 
		foreach(n0; node.content.child[3].child)
		{
			auto p2 = reduce_template_arg(cast(RuleTree!"template_arg")(n0.child[1]));
			 params ~= p2; 
		}
		 return params; 
		assert(false);
	}
	private static auto reduce_template_arg(RuleTree!"template_arg" node) in { assert(node !is null); } body
	{
		auto head = reduce_template_arg_head(cast(RuleTree!"template_arg_head")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			auto t = reduce_type(cast(RuleTree!"type")(n0.child[1]));
			 head = new TemplateVirtualParamNode(head, t); 
		}
		 return head; 
		assert(false);
	}
	private static auto reduce_template_arg_type(RuleTree!"template_arg_type" node) in { assert(node !is null); } body
	{
		 alias ReturnType = Tuple!(TemplateVirtualParamNode.ParamType, "type", TypeNode, "stype", Location, "location"); 
		if((cast(PartialTree!291)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!291)(node.content.child[1].child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[0]));
			 return ReturnType(TemplateVirtualParamNode.ParamType.Type, t, t.location); 
		}
		else if((cast(PartialTree!292)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!292)(node.content.child[1].child[0]);
			auto tk = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return ReturnType(TemplateVirtualParamNode.ParamType.Class, null, tk.location); 
		}
		else if((cast(PartialTree!293)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!293)(node.content.child[1].child[0]);
			auto tk = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return ReturnType(TemplateVirtualParamNode.ParamType.SymbolAlias, null, tk.location); 
		}
		assert(false);
	}
	private static auto reduce_template_arg_head(RuleTree!"template_arg_head" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!296)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!296)(node.content.child[0]);
			auto type = reduce_template_arg_type(cast(RuleTree!"template_arg_type")(__tree_ref__.child[0]));
			auto id = (cast(TokenTree)(__tree_ref__.child[1])).token;
			 return new TemplateVirtualParamNode(type.location, type.type, type.stype, id.text); 
		}
		else if((cast(PartialTree!297)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!297)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new TemplateVirtualParamNode(id.location, TemplateVirtualParamNode.ParamType.Any, null, id.text); 
		}
		assert(false);
	}
	private static auto reduce_varg_list(RuleTree!"varg_list" node) in { assert(node !is null); } body
	{
		 VirtualParamNode params[]; 
		auto t = reduce_varg(cast(RuleTree!"varg")(node.content.child[1]));
		 params ~= t; 
		foreach(n0; node.content.child[3].child)
		{
			auto v = reduce_varg(cast(RuleTree!"varg")(n0.child[1]));
			 params ~= v; 
		}
		 return params; 
		assert(false);
	}
	private static auto reduce_varg(RuleTree!"varg" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!302)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!302)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[0]));
			auto n = (cast(TokenTree)(__tree_ref__.child[1])).token;
			auto dv = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[3]));
			 return new VirtualParamNode(t, n.text, dv, true); 
		}
		else if((cast(PartialTree!303)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!303)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[0]));
			auto n = (cast(TokenTree)(__tree_ref__.child[1])).token;
			auto dv = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[3]));
			 return new VirtualParamNode(t, n.text, dv, false); 
		}
		else if((cast(PartialTree!304)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!304)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[0]));
			auto n = (cast(TokenTree)(__tree_ref__.child[1])).token;
			 return new VirtualParamNode(t, n.text, null, true); 
		}
		else if((cast(PartialTree!305)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!305)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[0]));
			auto n = (cast(TokenTree)(__tree_ref__.child[1])).token;
			 return new VirtualParamNode(t, n.text, null, false); 
		}
		else if((cast(PartialTree!306)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!306)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[0]));
			 return new VirtualParamNode(t, null, null, true); 
		}
		else if((cast(PartialTree!307)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!307)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[0]));
			 return new VirtualParamNode(t, null, null, false); 
		}
		assert(false);
	}
	private static auto reduce_literal_varg_list(RuleTree!"literal_varg_list" node) in { assert(node !is null); } body
	{
		 VirtualParamNode[] params; 
		auto p1 = reduce_literal_varg(cast(RuleTree!"literal_varg")(node.content.child[1]));
		 params ~= p1; 
		foreach(n0; node.content.child[3].child)
		{
			auto p2 = reduce_literal_varg(cast(RuleTree!"literal_varg")(n0.child[1]));
			 params ~= p2; 
		}
		 return params; 
		assert(false);
	}
	private static auto reduce_literal_varg(RuleTree!"literal_varg" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!312)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!312)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[0]));
			auto id = (cast(TokenTree)(__tree_ref__.child[1])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[3]));
			 return new VirtualParamNode(t, id.text, e, true); 
		}
		else if((cast(PartialTree!313)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!313)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[0]));
			auto id = (cast(TokenTree)(__tree_ref__.child[1])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[3]));
			 return new VirtualParamNode(t, id.text, e, false); 
		}
		else if((cast(PartialTree!314)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!314)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[0]));
			auto id = (cast(TokenTree)(__tree_ref__.child[1])).token;
			 return new VirtualParamNode(t, id.text, null, true); 
		}
		else if((cast(PartialTree!315)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!315)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[0]));
			auto id = (cast(TokenTree)(__tree_ref__.child[1])).token;
			 return new VirtualParamNode(t, id.text, null, false); 
		}
		else if((cast(PartialTree!316)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!316)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[2]));
			 return new VirtualParamNode(new InferenceTypeNode(id.location), id.text, e, true); 
		}
		else if((cast(PartialTree!317)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!317)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[2]));
			 return new VirtualParamNode(new InferenceTypeNode(id.location), id.text, e, false); 
		}
		else if((cast(PartialTree!318)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!318)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new VirtualParamNode(new InferenceTypeNode(id.location), id.text, null, true); 
		}
		else if((cast(PartialTree!319)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!319)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new VirtualParamNode(new InferenceTypeNode(id.location), id.text, null, false); 
		}
		assert(false);
	}
	private static auto reduce_assoc_array_element_list(RuleTree!"assoc_array_element_list" node) in { assert(node !is null); } body
	{
		 AssocArrayElementNode[] nodes; 
		auto n = reduce_assoc_array_element(cast(RuleTree!"assoc_array_element")(node.content.child[1]));
		 nodes ~= n; 
		foreach(n0; node.content.child[3].child)
		{
			auto n2 = reduce_assoc_array_element(cast(RuleTree!"assoc_array_element")(n0.child[1]));
			 nodes ~= n2; 
		}
		 return nodes; 
		assert(false);
	}
	private static auto reduce_assoc_array_element(RuleTree!"assoc_array_element" node) in { assert(node !is null); } body
	{
		auto k = reduce_expression(cast(RuleTree!"expression")(node.content.child[0]));
		auto v = reduce_expression(cast(RuleTree!"expression")(node.content.child[2]));
		 return new AssocArrayElementNode(k, v); 
		assert(false);
	}
	private static auto reduce_class_qualifier(RuleTree!"class_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!325)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!325)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!326)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!326)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		else if((cast(PartialTree!327)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!327)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Final); 
		}
		else if((cast(PartialTree!328)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!328)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Static); 
		}
		assert(false);
	}
	private static auto reduce_trait_qualifier(RuleTree!"trait_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!325)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!325)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!326)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!326)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		else if((cast(PartialTree!328)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!328)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Static); 
		}
		assert(false);
	}
	private static auto reduce_enum_qualifier(RuleTree!"enum_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!325)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!325)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!326)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!326)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		else if((cast(PartialTree!328)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!328)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Static); 
		}
		assert(false);
	}
	private static auto reduce_template_qualifier(RuleTree!"template_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!325)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!325)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!326)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!326)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		assert(false);
	}
	private static auto reduce_alias_qualifier(RuleTree!"alias_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!325)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!325)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!326)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!326)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		assert(false);
	}
	private static auto reduce_type_qualifier(RuleTree!"type_qualifier" node) in { assert(node !is null); } body
	{
		auto t = (cast(TokenTree)(node.content.child[0])).token;
		 return Qualifier(t.location, Qualifiers.Const); 
		assert(false);
	}
	private static auto reduce_field_qualifier(RuleTree!"field_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!325)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!325)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!326)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!326)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		else if((cast(PartialTree!333)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!333)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Protected); 
		}
		else if((cast(PartialTree!328)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!328)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Static); 
		}
		else if((cast(PartialTree!327)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!327)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Final); 
		}
		else if((cast(PartialTree!332)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!332)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Const); 
		}
		assert(false);
	}
	private static auto reduce_method_qualifier(RuleTree!"method_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!325)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!325)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!326)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!326)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		else if((cast(PartialTree!333)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!333)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Protected); 
		}
		else if((cast(PartialTree!328)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!328)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Static); 
		}
		else if((cast(PartialTree!327)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!327)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Final); 
		}
		else if((cast(PartialTree!332)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!332)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Const); 
		}
		else if((cast(PartialTree!335)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!335)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Override); 
		}
		assert(false);
	}
	private static auto reduce_ctor_qualifier(RuleTree!"ctor_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!325)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!325)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!326)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!326)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		else if((cast(PartialTree!333)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!333)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Protected); 
		}
		else if((cast(PartialTree!332)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!332)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Const); 
		}
		assert(false);
	}
	private static auto reduce_lvar_qualifier(RuleTree!"lvar_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!326)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!326)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		else if((cast(PartialTree!333)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!333)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Protected); 
		}
		else if((cast(PartialTree!332)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!332)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Const); 
		}
		else if((cast(PartialTree!328)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!328)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Static); 
		}
		assert(false);
	}
	private static DefinitionIdentifierNode reduce_def_id(RuleTree!"def_id" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!339)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!339)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			auto params = reduce_def_id_arg_list(cast(RuleTree!"def_id_arg_list")(__tree_ref__.child[2]));
			 return new DefinitionIdentifierNode(id.location, id.text, params); 
		}
		else if((cast(PartialTree!342)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!342)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			if(__tree_ref__.child[1].child[0].child.length > 0)
			{
			}
			 return new DefinitionIdentifierNode(id.location, id.text, null); 
		}
		assert(false);
	}
	private static DefinitionIdentifierParamNode[] reduce_def_id_arg_list(RuleTree!"def_id_arg_list" node) in { assert(node !is null); } body
	{
		 DefinitionIdentifierParamNode[] nodes; 
		auto first_t = reduce_def_id_arg(cast(RuleTree!"def_id_arg")(node.content.child[1]));
		 nodes ~= first_t; 
		foreach(n0; node.content.child[3].child)
		{
			auto second_t = reduce_def_id_arg(cast(RuleTree!"def_id_arg")(n0.child[1]));
			 nodes ~= second_t; 
		}
		 return nodes; 
		assert(false);
	}
	private static DefinitionIdentifierParamNode reduce_def_id_arg(RuleTree!"def_id_arg" node) in { assert(node !is null); } body
	{
		auto n = reduce_def_id_argname(cast(RuleTree!"def_id_argname")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			if((cast(PartialTree!347)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!347)(n0.child[0]);
				auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[1]));
				 n = n.withDefaultValue(t); 
			}
			else if((cast(PartialTree!348)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!348)(n0.child[0]);
				auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[1]));
				 n = n.withExtendedFrom(t); 
			}
			else if((cast(PartialTree!349)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!349)(n0.child[0]);
				auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__.child[1]));
				 n = n.withCastableTo(t); 
			}
		}
		 return n; 
		assert(false);
	}
	private static auto reduce_def_id_argname(RuleTree!"def_id_argname" node) in { assert(node !is null); } body
	{
		auto t = (cast(TokenTree)(node.content.child[0])).token;
		 return new DefinitionIdentifierParamNode(t.location, t.text); 
		assert(false);
	}
	private static TypeNode reduce_type(RuleTree!"type" node) in { assert(node !is null); } body
	{
		 auto tq = Qualifier(Location(int.max, int.max), 0); bool hasQualifier = false; 
		foreach(n0; node.content.child[1].child)
		{
			auto tqq = reduce_type_qualifier(cast(RuleTree!"type_qualifier")(n0.child[0]));
			 tq = tq.combine(tqq); hasQualifier = true; 
		}
		auto tb = reduce_type_body(cast(RuleTree!"type_body")(node.content.child[2]));
		 return hasQualifier ? new QualifiedTypeNode(tq, tb) : tb; 
		assert(false);
	}
	private static auto reduce_type_body(RuleTree!"type_body" node) in { assert(node !is null); } body
	{
		auto tbb = reduce_type_body_base(cast(RuleTree!"type_body_base")(node.content.child[0]));
		if(node.content.child[1].child[0].child.length > 0)
		{
			if((cast(PartialTree!357)(node.content.child[1].child[0].child[0].child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!357)(node.content.child[1].child[0].child[0].child[0]);
				auto vpl = reduce_varg_list(cast(RuleTree!"varg_list")(__tree_ref__.child[2]));
				 tbb = new FunctionTypeNode(tbb, vpl); 
			}
			else if((cast(PartialTree!358)(node.content.child[1].child[0].child[0].child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!358)(node.content.child[1].child[0].child[0].child[0]);
				 tbb = new FunctionTypeNode(tbb, null); 
			}
		}
		 return tbb; 
		assert(false);
	}
	private static auto reduce_type_body_base(RuleTree!"type_body_base" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!362)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!362)(node.content.child[0]);
			auto a = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new InferenceTypeNode(a.location); 
		}
		else if((cast(PartialTree!363)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!363)(node.content.child[0]);
			auto rt = reduce_restricted_type(cast(RuleTree!"restricted_type")(__tree_ref__.child[0]));
			 return rt; 
		}
		assert(false);
	}
	private static TypeNode reduce_restricted_type(RuleTree!"restricted_type" node) in { assert(node !is null); } body
	{
		auto pt = reduce_primitive_types(cast(RuleTree!"primitive_types")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			if((cast(PartialTree!365)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!365)(n0.child[0]);
				auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[1]));
				 pt = new ArrayTypeNode(pt, e); 
			}
			else if((cast(PartialTree!366)(n0.child[0])) !is null)
			{
				auto __tree_ref__ = cast(PartialTree!366)(n0.child[0]);
				 pt = new ArrayTypeNode(pt, null); 
			}
		}
		 return pt; 
		assert(false);
	}
	private static TypeNode reduce_primitive_types(RuleTree!"primitive_types" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!370)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!370)(node.content.child[0]);
			auto rt = reduce_register_types(cast(RuleTree!"register_types")(__tree_ref__.child[0]));
			 return rt; 
		}
		else if((cast(PartialTree!371)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!371)(node.content.child[0]);
			auto ti = reduce_template_instance(cast(RuleTree!"template_instance")(__tree_ref__.child[0]));
			 return ti; 
		}
		else if((cast(PartialTree!372)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!372)(node.content.child[0]);
			auto to = reduce___typeof(cast(RuleTree!"__typeof")(__tree_ref__.child[0]));
			 return to; 
		}
		assert(false);
	}
	private static TypeofNode reduce___typeof(RuleTree!"__typeof" node) in { assert(node !is null); } body
	{
		auto f = (cast(TokenTree)(node.content.child[0])).token;
		if((cast(PartialTree!374)(node.content.child[2].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!374)(node.content.child[2].child[0]);
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[0]));
			 return new TypeofNode(f.location, e); 
		}
		else if((cast(PartialTree!375)(node.content.child[2].child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!375)(node.content.child[2].child[0]);
			auto rt = reduce_restricted_type(cast(RuleTree!"restricted_type")(__tree_ref__.child[0]));
			 return new TypeofNode(f.location, rt); 
		}
		assert(false);
	}
	private static RegisterTypeNode reduce_register_types(RuleTree!"register_types" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!378)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!378)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Void); 
		}
		else if((cast(PartialTree!379)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!379)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Char); 
		}
		else if((cast(PartialTree!380)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!380)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Uchar); 
		}
		else if((cast(PartialTree!381)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!381)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Byte); 
		}
		else if((cast(PartialTree!382)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!382)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Short); 
		}
		else if((cast(PartialTree!383)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!383)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Ushort); 
		}
		else if((cast(PartialTree!384)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!384)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Int); 
		}
		else if((cast(PartialTree!385)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!385)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Uint); 
		}
		else if((cast(PartialTree!386)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!386)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Long); 
		}
		else if((cast(PartialTree!387)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!387)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Ulong); 
		}
		assert(false);
	}
	private static TemplateInstanceTypeNode reduce_template_instance(RuleTree!"template_instance" node) in { assert(node !is null); } body
	{
		auto t = (cast(TokenTree)(node.content.child[0])).token;
		if(node.content.child[1].child[0].child.length > 0)
		{
			auto v = reduce_template_tail(cast(RuleTree!"template_tail")(node.content.child[1].child[0].child[0].child[0]));
			 return new TemplateInstanceTypeNode(t.location, t.text, v); 
		}
		 return new TemplateInstanceTypeNode(t.location, t.text, null); 
		assert(false);
	}
	private static TemplateParamNode[] reduce_template_tail(RuleTree!"template_tail" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!392)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!392)(node.content.child[0]);
			auto st = reduce_single_types(cast(RuleTree!"single_types")(__tree_ref__.child[1]));
			 return [new TemplateParamNode(st.location, st)]; 
		}
		else if((cast(PartialTree!393)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!393)(node.content.child[0]);
			auto pe = reduce_primary_expr(cast(RuleTree!"primary_expr")(__tree_ref__.child[1]));
			 return [new TemplateParamNode(pe.location, pe)]; 
		}
		else if((cast(PartialTree!396)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!396)(node.content.child[0]);
			 TemplateParamNode[] params; 
			auto first_t = reduce_template_param(cast(RuleTree!"template_param")(__tree_ref__.child[3]));
			 params ~= first_t; 
			foreach(n0; __tree_ref__.child[5].child)
			{
				auto second_t = reduce_template_param(cast(RuleTree!"template_param")(n0.child[1]));
				 params ~= second_t; 
			}
			 return params; 
		}
		else if((cast(PartialTree!397)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!397)(node.content.child[0]);
			 return null; 
		}
		assert(false);
	}
	private static TemplateParamNode reduce_template_param(RuleTree!"template_param" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!399)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!399)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new TemplateParamNode(id.location, id.text); 
		}
		else if((cast(PartialTree!400)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!400)(node.content.child[0]);
			auto rt = reduce_restricted_type(cast(RuleTree!"restricted_type")(__tree_ref__.child[0]));
			 return new TemplateParamNode(rt.location, rt); 
		}
		else if((cast(PartialTree!401)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!401)(node.content.child[0]);
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__.child[0]));
			 return new TemplateParamNode(e.location, e); 
		}
		assert(false);
	}
	private static TypeNode reduce_single_types(RuleTree!"single_types" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!362)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!362)(node.content.child[0]);
			auto a = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new InferenceTypeNode(a.location); 
		}
		else if((cast(PartialTree!403)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!403)(node.content.child[0]);
			auto srt = reduce_single_restricted_type(cast(RuleTree!"single_restricted_type")(__tree_ref__.child[0]));
			 return srt; 
		}
		assert(false);
	}
	private static TypeNode reduce_single_restricted_type(RuleTree!"single_restricted_type" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!370)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!370)(node.content.child[0]);
			auto rt = reduce_register_types(cast(RuleTree!"register_types")(__tree_ref__.child[0]));
			 return rt; 
		}
		else if((cast(PartialTree!405)(node.content.child[0])) !is null)
		{
			auto __tree_ref__ = cast(PartialTree!405)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__.child[0])).token;
			 return new TemplateInstanceTypeNode(t.location, t.text, null); 
		}
		assert(false);
	}
	private static auto reduce_import_list(RuleTree!"import_list" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		assert(false);
	}
	private static auto reduce_import_item(RuleTree!"import_item" node) in { assert(node !is null); } body
	{
		foreach(n0; node.content.child[1].child)
		{
		}
		if(node.content.child[2].child[0].child.length > 0)
		{
		}
		assert(false);
	}
	private static Token[] reduce_package_id(RuleTree!"package_id" node) in { assert(node !is null); } body
	{
		 Token[] ids; 
		auto t = (cast(TokenTree)(node.content.child[1])).token;
		 ids ~= t; 
		foreach(n0; node.content.child[3].child)
		{
			auto t2 = (cast(TokenTree)(n0.child[1])).token;
			 ids ~= t2; 
		}
		 return ids; 
		assert(false);
	}
}
