module com.cterm2.ml.parser;

import com.cterm2.ml.lexer;
import std.array, std.algorithm, std.stdio;

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
	private static class ComplexParser_Sequential0
	{
		// id=<Sequential:<true:true:package_def:pd>,<Action: pn = pd; >>
		private alias PartialTreeType = PartialTree!0;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = package_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable1
	{
		// id=<Skippable:<Sequential:<true:true:package_def:pd>,<Action: pn = pd; >>>
		private alias PartialTreeType = PartialTree!1;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential0.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential2
	{
		// id=<Sequential:<true:true:script_element:se>,<Action: ds ~= se; >>
		private alias PartialTreeType = PartialTree!2;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = script_element.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified3
	{
		// id=<LoopQualified:false:<Sequential:<true:true:script_element:se>,<Action: ds ~= se; >>>
		private alias PartialTreeType = PartialTree!3;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential2.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential4
	{
		// id=<Sequential:<Action: Token[] pn; DeclarationNode[] ds; >,<Skippable:<Sequential:<true:true:package_def:pd>,<Action: pn = pd; >>>,<LoopQualified:false:<Sequential:<true:true:script_element:se>,<Action: ds ~= se; >>>,<Action: return new ScriptNode(pn, ds); >>
		private alias PartialTreeType = PartialTree!4;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_Skippable1.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified3.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
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
					_memo[r] = ResultType(false, r, TokenIterator(r.pos, r.token));
				}
			}

			return _memo[r];
		}
	}
	private alias ElementParser_PACKAGE = ElementParser!(EnumTokenType.PACKAGE);
	private alias ElementParser_SEMICOLON = ElementParser!(EnumTokenType.SEMICOLON);
	private static class ComplexParser_Sequential5
	{
		// id=<Sequential:<false:false:PACKAGE:>,<true:true:package_id:pid>,<false:false:SEMICOLON:>,<Action: return pid; >>
		private alias PartialTreeType = PartialTree!5;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential6
	{
		// id=<Sequential:<true:true:import_decl:id>,<Action: return id; >>
		private alias PartialTreeType = PartialTree!6;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = import_decl.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential7
	{
		// id=<Sequential:<true:true:partial_package_def:ppd>,<Action: return ppd; >>
		private alias PartialTreeType = PartialTree!7;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = partial_package_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential8
	{
		// id=<Sequential:<true:true:class_def:cd>,<Action: return cd; >>
		private alias PartialTreeType = PartialTree!8;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = class_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential9
	{
		// id=<Sequential:<true:true:trait_def:td>,<Action: return td; >>
		private alias PartialTreeType = PartialTree!9;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = trait_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential10
	{
		// id=<Sequential:<true:true:enum_def:ed>,<Action: return ed; >>
		private alias PartialTreeType = PartialTree!10;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = enum_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential11
	{
		// id=<Sequential:<true:true:template_def:tmd>,<Action: return tmd; >>
		private alias PartialTreeType = PartialTree!11;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = template_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential12
	{
		// id=<Sequential:<true:true:alias_def:ad>,<Action: return ad; >>
		private alias PartialTreeType = PartialTree!12;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = alias_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential13
	{
		// id=<Sequential:<true:true:class_body:cb>,<Action: return cb; >>
		private alias PartialTreeType = PartialTree!13;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = class_body.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching14
	{
		// id=<Switch:<Sequential:<true:true:import_decl:id>,<Action: return id; >>,<Sequential:<true:true:partial_package_def:ppd>,<Action: return ppd; >>,<Sequential:<true:true:class_def:cd>,<Action: return cd; >>,<Sequential:<true:true:trait_def:td>,<Action: return td; >>,<Sequential:<true:true:enum_def:ed>,<Action: return ed; >>,<Sequential:<true:true:template_def:tmd>,<Action: return tmd; >>,<Sequential:<true:true:alias_def:ad>,<Action: return ad; >>,<Sequential:<true:true:class_body:cb>,<Action: return cb; >>>
		private alias PartialTreeType = PartialTree!14;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential6.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential7.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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

			resTemp = ComplexParser_Sequential11.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential12.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential13.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_IMPORT = ElementParser!(EnumTokenType.IMPORT);
	private static class ComplexParser_Sequential15
	{
		// id=<Sequential:<true:false:IMPORT:ft>,<true:true:import_list:il>,<false:false:SEMICOLON:>,<Action: return new ImportDeclarationNode(ft.location, il); >>
		private alias PartialTreeType = PartialTree!15;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential16
	{
		// id=<Sequential:<true:true:script_element:e>,<Action: return new PartialPackageDeclarationNode(ft.location, pid, [e]); >>
		private alias PartialTreeType = PartialTree!16;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = script_element.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LB = ElementParser!(EnumTokenType.LB);
	private static class ComplexParser_Sequential17
	{
		// id=<Sequential:<true:true:script_element:se>,<Action: elms ~= se; >>
		private alias PartialTreeType = PartialTree!17;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = script_element.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified18
	{
		// id=<LoopQualified:false:<Sequential:<true:true:script_element:se>,<Action: elms ~= se; >>>
		private alias PartialTreeType = PartialTree!18;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential17.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_RB = ElementParser!(EnumTokenType.RB);
	private static class ComplexParser_Sequential19
	{
		// id=<Sequential:<false:false:LB:>,<Action: DeclarationNode[] elms; >,<LoopQualified:false:<Sequential:<true:true:script_element:se>,<Action: elms ~= se; >>>,<false:false:RB:>,<Action: return new PartialPackageDeclarationNode(ft.location, pid, elms); >>
		private alias PartialTreeType = PartialTree!19;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified18.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching20
	{
		// id=<Switch:<Sequential:<true:true:script_element:e>,<Action: return new PartialPackageDeclarationNode(ft.location, pid, [e]); >>,<Sequential:<false:false:LB:>,<Action: DeclarationNode[] elms; >,<LoopQualified:false:<Sequential:<true:true:script_element:se>,<Action: elms ~= se; >>>,<false:false:RB:>,<Action: return new PartialPackageDeclarationNode(ft.location, pid, elms); >>>
		private alias PartialTreeType = PartialTree!20;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential16.parse(r);
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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential21
	{
		// id=<Sequential:<true:false:PACKAGE:ft>,<true:true:package_id:pid>,<Switch:<Sequential:<true:true:script_element:e>,<Action: return new PartialPackageDeclarationNode(ft.location, pid, [e]); >>,<Sequential:<false:false:LB:>,<Action: DeclarationNode[] elms; >,<LoopQualified:false:<Sequential:<true:true:script_element:se>,<Action: elms ~= se; >>>,<false:false:RB:>,<Action: return new PartialPackageDeclarationNode(ft.location, pid, elms); >>>>
		private alias PartialTreeType = PartialTree!21;
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

			resTemp = ComplexParser_Switching20.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential22
	{
		// id=<Sequential:<true:true:class_qualifier:cq>,<Action: q = q.combine(cq); >>
		private alias PartialTreeType = PartialTree!22;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = class_qualifier.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified23
	{
		// id=<LoopQualified:false:<Sequential:<true:true:class_qualifier:cq>,<Action: q = q.combine(cq); >>>
		private alias PartialTreeType = PartialTree!23;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential22.parse(r);
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
	private static class ComplexParser_Sequential24
	{
		// id=<Sequential:<false:false:EXTENDS:>,<true:true:type:t>,<Action: ef = t; >>
		private alias PartialTreeType = PartialTree!24;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable25
	{
		// id=<Skippable:<Sequential:<false:false:EXTENDS:>,<true:true:type:t>,<Action: ef = t; >>>
		private alias PartialTreeType = PartialTree!25;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential24.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private alias ElementParser_WITH = ElementParser!(EnumTokenType.WITH);
	private static class ComplexParser_Sequential26
	{
		// id=<Sequential:<false:false:WITH:>,<true:true:type:wt>,<Action: wts ~= wt; >>
		private alias PartialTreeType = PartialTree!26;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified27
	{
		// id=<LoopQualified:false:<Sequential:<false:false:WITH:>,<true:true:type:wt>,<Action: wts ~= wt; >>>
		private alias PartialTreeType = PartialTree!27;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential26.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential28
	{
		// id=<Sequential:<false:false:SEMICOLON:>,<Action: return new ClassDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, ef, wts, null); >>
		private alias PartialTreeType = PartialTree!28;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential29
	{
		// id=<Sequential:<true:true:import_decl:idl>,<Action: dns ~= idl; >>
		private alias PartialTreeType = PartialTree!29;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = import_decl.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential30
	{
		// id=<Sequential:<true:true:class_body:cb>,<Action: dns ~= cb; >>
		private alias PartialTreeType = PartialTree!30;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = class_body.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching31
	{
		// id=<Switch:<Sequential:<true:true:import_decl:idl>,<Action: dns ~= idl; >>,<Sequential:<true:true:class_body:cb>,<Action: dns ~= cb; >>>
		private alias PartialTreeType = PartialTree!31;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential29.parse(r);
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
	private static class ComplexParser_LoopQualified32
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<true:true:import_decl:idl>,<Action: dns ~= idl; >>,<Sequential:<true:true:class_body:cb>,<Action: dns ~= cb; >>>>
		private alias PartialTreeType = PartialTree!32;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching31.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential33
	{
		// id=<Sequential:<false:false:LB:>,<Action: DeclarationNode[] dns; >,<LoopQualified:false:<Switch:<Sequential:<true:true:import_decl:idl>,<Action: dns ~= idl; >>,<Sequential:<true:true:class_body:cb>,<Action: dns ~= cb; >>>>,<false:false:RB:>,<Action: return new ClassDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, ef, wts, dns); >>
		private alias PartialTreeType = PartialTree!33;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified32.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching34
	{
		// id=<Switch:<Sequential:<false:false:SEMICOLON:>,<Action: return new ClassDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, ef, wts, null); >>,<Sequential:<false:false:LB:>,<Action: DeclarationNode[] dns; >,<LoopQualified:false:<Switch:<Sequential:<true:true:import_decl:idl>,<Action: dns ~= idl; >>,<Sequential:<true:true:class_body:cb>,<Action: dns ~= cb; >>>>,<false:false:RB:>,<Action: return new ClassDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, ef, wts, dns); >>>
		private alias PartialTreeType = PartialTree!34;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential28.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential33.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential35
	{
		// id=<Sequential:<Action: auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); TypeNode ef; TypeNode[] wts; >,<LoopQualified:false:<Sequential:<true:true:class_qualifier:cq>,<Action: q = q.combine(cq); >>>,<true:false:CLASS:ft>,<true:true:def_id:id>,<Skippable:<Sequential:<false:false:EXTENDS:>,<true:true:type:t>,<Action: ef = t; >>>,<LoopQualified:false:<Sequential:<false:false:WITH:>,<true:true:type:wt>,<Action: wts ~= wt; >>>,<Switch:<Sequential:<false:false:SEMICOLON:>,<Action: return new ClassDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, ef, wts, null); >>,<Sequential:<false:false:LB:>,<Action: DeclarationNode[] dns; >,<LoopQualified:false:<Switch:<Sequential:<true:true:import_decl:idl>,<Action: dns ~= idl; >>,<Sequential:<true:true:class_body:cb>,<Action: dns ~= cb; >>>>,<false:false:RB:>,<Action: return new ClassDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, ef, wts, dns); >>>>
		private alias PartialTreeType = PartialTree!35;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified23.parse(r);
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

			resTemp = ComplexParser_Skippable25.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified27.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Switching34.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential36
	{
		// id=<Sequential:<true:true:field_def:fd>,<Action: return fd; >>
		private alias PartialTreeType = PartialTree!36;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = field_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential37
	{
		// id=<Sequential:<true:true:method_def:md>,<Action: return md; >>
		private alias PartialTreeType = PartialTree!37;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = method_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential38
	{
		// id=<Sequential:<true:true:property_def:pd>,<Action: return pd; >>
		private alias PartialTreeType = PartialTree!38;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = property_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential39
	{
		// id=<Sequential:<true:true:ctor_def:cd>,<Action: return cd; >>
		private alias PartialTreeType = PartialTree!39;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ctor_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential40
	{
		// id=<Sequential:<true:true:statement:st>,<Action: return new StaticInitializerNode(st); >>
		private alias PartialTreeType = PartialTree!40;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching41
	{
		// id=<Switch:<Sequential:<true:true:field_def:fd>,<Action: return fd; >>,<Sequential:<true:true:method_def:md>,<Action: return md; >>,<Sequential:<true:true:property_def:pd>,<Action: return pd; >>,<Sequential:<true:true:ctor_def:cd>,<Action: return cd; >>,<Sequential:<true:true:alias_def:ad>,<Action: return ad; >>,<Sequential:<true:true:statement:st>,<Action: return new StaticInitializerNode(st); >>>
		private alias PartialTreeType = PartialTree!41;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential36.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential37.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential38.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential39.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential12.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential40.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential42
	{
		// id=<Sequential:<true:true:trait_qualifier:tq>,<Action: q = q.combine(tq); >>
		private alias PartialTreeType = PartialTree!42;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = trait_qualifier.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified43
	{
		// id=<LoopQualified:false:<Sequential:<true:true:trait_qualifier:tq>,<Action: q = q.combine(tq); >>>
		private alias PartialTreeType = PartialTree!43;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential42.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_TRAIT = ElementParser!(EnumTokenType.TRAIT);
	private static class ComplexParser_Sequential44
	{
		// id=<Sequential:<false:false:WITH:>,<true:true:type:t>,<Action: wts ~= t; >>
		private alias PartialTreeType = PartialTree!44;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified45
	{
		// id=<LoopQualified:false:<Sequential:<false:false:WITH:>,<true:true:type:t>,<Action: wts ~= t; >>>
		private alias PartialTreeType = PartialTree!45;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential44.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential46
	{
		// id=<Sequential:<false:false:SEMICOLON:>,<Action: return new TraitDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, wts, null); >>
		private alias PartialTreeType = PartialTree!46;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential47
	{
		// id=<Sequential:<true:true:trait_body:tb>,<Action: dns ~= tb; >>
		private alias PartialTreeType = PartialTree!47;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = trait_body.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching48
	{
		// id=<Switch:<Sequential:<true:true:import_decl:idl>,<Action: dns ~= idl; >>,<Sequential:<true:true:trait_body:tb>,<Action: dns ~= tb; >>>
		private alias PartialTreeType = PartialTree!48;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential29.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential47.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified49
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<true:true:import_decl:idl>,<Action: dns ~= idl; >>,<Sequential:<true:true:trait_body:tb>,<Action: dns ~= tb; >>>>
		private alias PartialTreeType = PartialTree!49;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching48.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential50
	{
		// id=<Sequential:<false:false:LB:>,<Action: DeclarationNode[] dns; >,<LoopQualified:false:<Switch:<Sequential:<true:true:import_decl:idl>,<Action: dns ~= idl; >>,<Sequential:<true:true:trait_body:tb>,<Action: dns ~= tb; >>>>,<false:false:RB:>,<Action: return new TraitDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, wts, dns); >>
		private alias PartialTreeType = PartialTree!50;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified49.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching51
	{
		// id=<Switch:<Sequential:<false:false:SEMICOLON:>,<Action: return new TraitDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, wts, null); >>,<Sequential:<false:false:LB:>,<Action: DeclarationNode[] dns; >,<LoopQualified:false:<Switch:<Sequential:<true:true:import_decl:idl>,<Action: dns ~= idl; >>,<Sequential:<true:true:trait_body:tb>,<Action: dns ~= tb; >>>>,<false:false:RB:>,<Action: return new TraitDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, wts, dns); >>>
		private alias PartialTreeType = PartialTree!51;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential46.parse(r);
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
		// id=<Sequential:<Action: auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); TypeNode[] wts; >,<LoopQualified:false:<Sequential:<true:true:trait_qualifier:tq>,<Action: q = q.combine(tq); >>>,<true:false:TRAIT:ft>,<true:true:def_id:id>,<LoopQualified:false:<Sequential:<false:false:WITH:>,<true:true:type:t>,<Action: wts ~= t; >>>,<Switch:<Sequential:<false:false:SEMICOLON:>,<Action: return new TraitDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, wts, null); >>,<Sequential:<false:false:LB:>,<Action: DeclarationNode[] dns; >,<LoopQualified:false:<Switch:<Sequential:<true:true:import_decl:idl>,<Action: dns ~= idl; >>,<Sequential:<true:true:trait_body:tb>,<Action: dns ~= tb; >>>>,<false:false:RB:>,<Action: return new TraitDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, wts, dns); >>>>
		private alias PartialTreeType = PartialTree!52;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified43.parse(r);
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

			resTemp = ComplexParser_LoopQualified45.parse(r);
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
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching53
	{
		// id=<Switch:<Sequential:<true:true:method_def:md>,<Action: return md; >>,<Sequential:<true:true:property_def:pd>,<Action: return pd; >>,<Sequential:<true:true:ctor_def:cd>,<Action: return cd; >>,<Sequential:<true:true:alias_def:ad>,<Action: return ad; >>>
		private alias PartialTreeType = PartialTree!53;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential37.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential38.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential39.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential12.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential54
	{
		// id=<Sequential:<true:true:enum_qualifier:eq>,<Action: q = q.combine(eq); >>
		private alias PartialTreeType = PartialTree!54;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = enum_qualifier.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified55
	{
		// id=<LoopQualified:false:<Sequential:<true:true:enum_qualifier:eq>,<Action: q = q.combine(eq); >>>
		private alias PartialTreeType = PartialTree!55;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential54.parse(r);
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
	private static class ComplexParser_Sequential56
	{
		// id=<Sequential:<false:false:SEMICOLON:>,<Action: return new EnumDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, null, null); >>
		private alias PartialTreeType = PartialTree!56;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential57
	{
		// id=<Sequential:<true:true:import_decl:idl>,<Action: nodes ~= idl; >>
		private alias PartialTreeType = PartialTree!57;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = import_decl.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified58
	{
		// id=<LoopQualified:false:<Sequential:<true:true:import_decl:idl>,<Action: nodes ~= idl; >>>
		private alias PartialTreeType = PartialTree!58;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential57.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential59
	{
		// id=<Sequential:<true:true:enum_body:eb>,<Action: bodies = eb; >>
		private alias PartialTreeType = PartialTree!59;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = enum_body.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable60
	{
		// id=<Skippable:<Sequential:<true:true:enum_body:eb>,<Action: bodies = eb; >>>
		private alias PartialTreeType = PartialTree!60;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential59.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential61
	{
		// id=<Sequential:<true:true:import_decl:idl2>,<Action: nodes ~= idl2; >>
		private alias PartialTreeType = PartialTree!61;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = import_decl.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential62
	{
		// id=<Sequential:<true:true:class_body:cb>,<Action: nodes ~= cb; >>
		private alias PartialTreeType = PartialTree!62;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = class_body.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching63
	{
		// id=<Switch:<Sequential:<true:true:import_decl:idl2>,<Action: nodes ~= idl2; >>,<Sequential:<true:true:class_body:cb>,<Action: nodes ~= cb; >>>
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
	private static class ComplexParser_LoopQualified64
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<true:true:import_decl:idl2>,<Action: nodes ~= idl2; >>,<Sequential:<true:true:class_body:cb>,<Action: nodes ~= cb; >>>>
		private alias PartialTreeType = PartialTree!64;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching63.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential65
	{
		// id=<Sequential:<false:false:LB:>,<Action: DeclarationNode[] nodes; EnumElementNode[] bodies; >,<LoopQualified:false:<Sequential:<true:true:import_decl:idl>,<Action: nodes ~= idl; >>>,<Skippable:<Sequential:<true:true:enum_body:eb>,<Action: bodies = eb; >>>,<LoopQualified:false:<Switch:<Sequential:<true:true:import_decl:idl2>,<Action: nodes ~= idl2; >>,<Sequential:<true:true:class_body:cb>,<Action: nodes ~= cb; >>>>,<false:false:RB:>,<Action: return new EnumDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, bodies, nodes); >>
		private alias PartialTreeType = PartialTree!65;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified58.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable60.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified64.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching66
	{
		// id=<Switch:<Sequential:<false:false:SEMICOLON:>,<Action: return new EnumDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, null, null); >>,<Sequential:<false:false:LB:>,<Action: DeclarationNode[] nodes; EnumElementNode[] bodies; >,<LoopQualified:false:<Sequential:<true:true:import_decl:idl>,<Action: nodes ~= idl; >>>,<Skippable:<Sequential:<true:true:enum_body:eb>,<Action: bodies = eb; >>>,<LoopQualified:false:<Switch:<Sequential:<true:true:import_decl:idl2>,<Action: nodes ~= idl2; >>,<Sequential:<true:true:class_body:cb>,<Action: nodes ~= cb; >>>>,<false:false:RB:>,<Action: return new EnumDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, bodies, nodes); >>>
		private alias PartialTreeType = PartialTree!66;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential56.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential65.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential67
	{
		// id=<Sequential:<Action: auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); >,<LoopQualified:false:<Sequential:<true:true:enum_qualifier:eq>,<Action: q = q.combine(eq); >>>,<true:false:ENUM:ft>,<true:false:IDENTIFIER:id>,<Switch:<Sequential:<false:false:SEMICOLON:>,<Action: return new EnumDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, null, null); >>,<Sequential:<false:false:LB:>,<Action: DeclarationNode[] nodes; EnumElementNode[] bodies; >,<LoopQualified:false:<Sequential:<true:true:import_decl:idl>,<Action: nodes ~= idl; >>>,<Skippable:<Sequential:<true:true:enum_body:eb>,<Action: bodies = eb; >>>,<LoopQualified:false:<Switch:<Sequential:<true:true:import_decl:idl2>,<Action: nodes ~= idl2; >>,<Sequential:<true:true:class_body:cb>,<Action: nodes ~= cb; >>>>,<false:false:RB:>,<Action: return new EnumDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, bodies, nodes); >>>>
		private alias PartialTreeType = PartialTree!67;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified55.parse(r);
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

			resTemp = ComplexParser_Switching66.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_COMMA = ElementParser!(EnumTokenType.COMMA);
	private static class ComplexParser_Sequential68
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:enum_element:ee2>,<Action: eens ~= ee2; >>
		private alias PartialTreeType = PartialTree!68;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified69
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:enum_element:ee2>,<Action: eens ~= ee2; >>>
		private alias PartialTreeType = PartialTree!69;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential68.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching70
	{
		// id=<Switch:<false:false:COMMA:>,<false:false:SEMICOLON:>>
		private alias PartialTreeType = PartialTree!70;
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
	private static class ComplexParser_Skippable71
	{
		// id=<Skippable:<Switch:<false:false:COMMA:>,<false:false:SEMICOLON:>>>
		private alias PartialTreeType = PartialTree!71;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Switching70.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential72
	{
		// id=<Sequential:<Action: EnumElementNode[] eens; >,<true:true:enum_element:ee>,<Action: eens ~= ee; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:enum_element:ee2>,<Action: eens ~= ee2; >>>,<Skippable:<Switch:<false:false:COMMA:>,<false:false:SEMICOLON:>>>,<Action: return eens; >>
		private alias PartialTreeType = PartialTree!72;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = enum_element.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified69.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable71.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LP = ElementParser!(EnumTokenType.LP);
	private static class ComplexParser_Sequential73
	{
		// id=<Sequential:<true:true:expression_list:el>,<Action: els = el; >>
		private alias PartialTreeType = PartialTree!73;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = expression_list.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable74
	{
		// id=<Skippable:<Sequential:<true:true:expression_list:el>,<Action: els = el; >>>
		private alias PartialTreeType = PartialTree!74;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential73.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private alias ElementParser_RP = ElementParser!(EnumTokenType.RP);
	private static class ComplexParser_Sequential75
	{
		// id=<Sequential:<false:false:LP:>,<Skippable:<Sequential:<true:true:expression_list:el>,<Action: els = el; >>>,<false:false:RP:>>
		private alias PartialTreeType = PartialTree!75;
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

			resTemp = ComplexParser_Skippable74.parse(r);
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
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable76
	{
		// id=<Skippable:<Sequential:<false:false:LP:>,<Skippable:<Sequential:<true:true:expression_list:el>,<Action: els = el; >>>,<false:false:RP:>>>
		private alias PartialTreeType = PartialTree!76;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential75.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential77
	{
		// id=<Sequential:<Action: ExpressionNode[] els; >,<true:false:IDENTIFIER:id>,<Skippable:<Sequential:<false:false:LP:>,<Skippable:<Sequential:<true:true:expression_list:el>,<Action: els = el; >>>,<false:false:RP:>>>,<Action: return new EnumElementNode(id.location, id.text, els); >>
		private alias PartialTreeType = PartialTree!77;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable76.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential78
	{
		// id=<Sequential:<true:true:template_qualifier:tq>,<Action: q = q.combine(tq); >>
		private alias PartialTreeType = PartialTree!78;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = template_qualifier.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified79
	{
		// id=<LoopQualified:false:<Sequential:<true:true:template_qualifier:tq>,<Action: q = q.combine(tq); >>>
		private alias PartialTreeType = PartialTree!79;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential78.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_TEMPLATE = ElementParser!(EnumTokenType.TEMPLATE);
	private static class ComplexParser_Sequential80
	{
		// id=<Sequential:<true:true:template_arg_list:tvps>,<Action: template_vps = tvps; >>
		private alias PartialTreeType = PartialTree!80;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = template_arg_list.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable81
	{
		// id=<Skippable:<Sequential:<true:true:template_arg_list:tvps>,<Action: template_vps = tvps; >>>
		private alias PartialTreeType = PartialTree!81;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential80.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential82
	{
		// id=<Sequential:<false:false:SEMICOLON:>,<Action: return new TemplateDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, template_vps, null); >>
		private alias PartialTreeType = PartialTree!82;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential83
	{
		// id=<Sequential:<true:true:template_body:tb>,<Action: return new TemplateDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, template_vps, [tb]); >>
		private alias PartialTreeType = PartialTree!83;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = template_body.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential84
	{
		// id=<Sequential:<true:true:template_body:tb>,<Action: child ~= tb; >>
		private alias PartialTreeType = PartialTree!84;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = template_body.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified85
	{
		// id=<LoopQualified:false:<Sequential:<true:true:template_body:tb>,<Action: child ~= tb; >>>
		private alias PartialTreeType = PartialTree!85;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential84.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential86
	{
		// id=<Sequential:<false:false:LB:>,<Action: DeclarationNode[] child; >,<LoopQualified:false:<Sequential:<true:true:template_body:tb>,<Action: child ~= tb; >>>,<false:false:RB:>,<Action: return new TemplateDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, template_vps, child); >>
		private alias PartialTreeType = PartialTree!86;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified85.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching87
	{
		// id=<Switch:<Sequential:<false:false:SEMICOLON:>,<Action: return new TemplateDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, template_vps, null); >>,<Sequential:<true:true:template_body:tb>,<Action: return new TemplateDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, template_vps, [tb]); >>,<Sequential:<false:false:LB:>,<Action: DeclarationNode[] child; >,<LoopQualified:false:<Sequential:<true:true:template_body:tb>,<Action: child ~= tb; >>>,<false:false:RB:>,<Action: return new TemplateDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, template_vps, child); >>>
		private alias PartialTreeType = PartialTree!87;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential82.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential83.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential86.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential88
	{
		// id=<Sequential:<Action: TemplateVirtualParamNode[] template_vps = null; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); >,<LoopQualified:false:<Sequential:<true:true:template_qualifier:tq>,<Action: q = q.combine(tq); >>>,<true:false:TEMPLATE:ft>,<true:false:IDENTIFIER:id>,<false:false:LP:>,<Skippable:<Sequential:<true:true:template_arg_list:tvps>,<Action: template_vps = tvps; >>>,<false:false:RP:>,<Switch:<Sequential:<false:false:SEMICOLON:>,<Action: return new TemplateDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, template_vps, null); >>,<Sequential:<true:true:template_body:tb>,<Action: return new TemplateDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, template_vps, [tb]); >>,<Sequential:<false:false:LB:>,<Action: DeclarationNode[] child; >,<LoopQualified:false:<Sequential:<true:true:template_body:tb>,<Action: child ~= tb; >>>,<false:false:RB:>,<Action: return new TemplateDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, template_vps, child); >>>>
		private alias PartialTreeType = PartialTree!88;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified79.parse(r);
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

			resTemp = ComplexParser_Skippable81.parse(r);
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

			resTemp = ComplexParser_Switching87.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching89
	{
		// id=<Switch:<Sequential:<true:true:import_decl:id>,<Action: return id; >>,<Sequential:<true:true:class_def:cd>,<Action: return cd; >>,<Sequential:<true:true:trait_def:td>,<Action: return td; >>,<Sequential:<true:true:enum_def:ed>,<Action: return ed; >>,<Sequential:<true:true:template_def:tmd>,<Action: return tmd; >>,<Sequential:<true:true:alias_def:ad>,<Action: return ad; >>>
		private alias PartialTreeType = PartialTree!89;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential6.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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

			resTemp = ComplexParser_Sequential11.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential12.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential90
	{
		// id=<Sequential:<true:true:alias_qualifier:aq>,<Action: q = q.combine(aq); >>
		private alias PartialTreeType = PartialTree!90;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = alias_qualifier.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified91
	{
		// id=<LoopQualified:false:<Sequential:<true:true:alias_qualifier:aq>,<Action: q = q.combine(aq); >>>
		private alias PartialTreeType = PartialTree!91;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential90.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_USING = ElementParser!(EnumTokenType.USING);
	private alias ElementParser_EQUAL = ElementParser!(EnumTokenType.EQUAL);
	private static class ComplexParser_Sequential92
	{
		// id=<Sequential:<true:true:def_id:did>,<false:false:EQUAL:>,<true:true:type:tt>,<Action: id = did; t = tt; >>
		private alias PartialTreeType = PartialTree!92;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = def_id.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential93
	{
		// id=<Sequential:<true:true:type:tt>,<true:true:def_id:did>,<Action: id = did; t = tt; >>
		private alias PartialTreeType = PartialTree!93;
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

			resTemp = def_id.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching94
	{
		// id=<Switch:<Sequential:<true:true:def_id:did>,<false:false:EQUAL:>,<true:true:type:tt>,<Action: id = did; t = tt; >>,<Sequential:<true:true:type:tt>,<true:true:def_id:did>,<Action: id = did; t = tt; >>>
		private alias PartialTreeType = PartialTree!94;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential95
	{
		// id=<Sequential:<Action: DefinitionIdentifierNode id; TypeNode t; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); >,<LoopQualified:false:<Sequential:<true:true:alias_qualifier:aq>,<Action: q = q.combine(aq); >>>,<true:false:USING:ft>,<Switch:<Sequential:<true:true:def_id:did>,<false:false:EQUAL:>,<true:true:type:tt>,<Action: id = did; t = tt; >>,<Sequential:<true:true:type:tt>,<true:true:def_id:did>,<Action: id = did; t = tt; >>>,<Action: return new AliasDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, t, id); >>
		private alias PartialTreeType = PartialTree!95;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified91.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ElementParser_USING.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Switching94.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential96
	{
		// id=<Sequential:<true:true:field_qualifier:fq>,<Action: q = q.combine(fq); >>
		private alias PartialTreeType = PartialTree!96;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = field_qualifier.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified97
	{
		// id=<LoopQualified:false:<Sequential:<true:true:field_qualifier:fq>,<Action: q = q.combine(fq); >>>
		private alias PartialTreeType = PartialTree!97;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential96.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential98
	{
		// id=<Sequential:<LoopQualified:false:<Sequential:<true:true:field_qualifier:fq>,<Action: q = q.combine(fq); >>>,<true:true:type:tp>,<Action: t = tp; >>
		private alias PartialTreeType = PartialTree!98;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified97.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified99
	{
		// id=<LoopQualified:true:<Sequential:<true:true:field_qualifier:fq>,<Action: q = q.combine(fq); >>>
		private alias PartialTreeType = PartialTree!99;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential96.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(!treeList.empty, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching100
	{
		// id=<Switch:<Sequential:<LoopQualified:false:<Sequential:<true:true:field_qualifier:fq>,<Action: q = q.combine(fq); >>>,<true:true:type:tp>,<Action: t = tp; >>,<LoopQualified:true:<Sequential:<true:true:field_qualifier:fq>,<Action: q = q.combine(fq); >>>>
		private alias PartialTreeType = PartialTree!100;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential98.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_LoopQualified99.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential101
	{
		// id=<Sequential:<Action: TypeNode t = null; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); >,<Switch:<Sequential:<LoopQualified:false:<Sequential:<true:true:field_qualifier:fq>,<Action: q = q.combine(fq); >>>,<true:true:type:tp>,<Action: t = tp; >>,<LoopQualified:true:<Sequential:<true:true:field_qualifier:fq>,<Action: q = q.combine(fq); >>>>,<true:true:field_def_list:fdl>,<false:false:SEMICOLON:>,<Action: return new FieldDeclarationNode(q.location.line == int.max ? t.location : q.location, q, t, fdl); >>
		private alias PartialTreeType = PartialTree!101;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_Switching100.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential102
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:nvpair:nvp2>,<Action: nvplist ~= nvp2; >>
		private alias PartialTreeType = PartialTree!102;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified103
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:nvpair:nvp2>,<Action: nvplist ~= nvp2; >>>
		private alias PartialTreeType = PartialTree!103;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential102.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential104
	{
		// id=<Sequential:<Action: NameValuePair[] nvplist; >,<true:true:nvpair:nvp>,<Action: nvplist ~= nvp; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:nvpair:nvp2>,<Action: nvplist ~= nvp2; >>>,<Action: return nvplist; >>
		private alias PartialTreeType = PartialTree!104;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = nvpair.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified103.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential105
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:EQUAL:>,<true:true:expression:e>,<Action: return new NameValuePair(id.location, id.text, e); >>
		private alias PartialTreeType = PartialTree!105;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential106
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<Action: return new NameValuePair(id.location, id.text, null); >>
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching107
	{
		// id=<Switch:<Sequential:<true:false:IDENTIFIER:id>,<false:false:EQUAL:>,<true:true:expression:e>,<Action: return new NameValuePair(id.location, id.text, e); >>,<Sequential:<true:false:IDENTIFIER:id>,<Action: return new NameValuePair(id.location, id.text, null); >>>
		private alias PartialTreeType = PartialTree!107;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential105.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential106.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential108
	{
		// id=<Sequential:<true:true:function_def:fd>,<Action: return fd; >>
		private alias PartialTreeType = PartialTree!108;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = function_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential109
	{
		// id=<Sequential:<true:true:procedure_def:pd>,<Action: return pd; >>
		private alias PartialTreeType = PartialTree!109;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = procedure_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential110
	{
		// id=<Sequential:<true:true:abstract_method_def:amd>,<Action: return amd; >>
		private alias PartialTreeType = PartialTree!110;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = abstract_method_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching111
	{
		// id=<Switch:<Sequential:<true:true:function_def:fd>,<Action: return fd; >>,<Sequential:<true:true:procedure_def:pd>,<Action: return pd; >>,<Sequential:<true:true:abstract_method_def:amd>,<Action: return amd; >>>
		private alias PartialTreeType = PartialTree!111;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential108.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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
		// id=<Sequential:<true:true:method_qualifier:mq>,<Action:q = q.combine(mq);>>
		private alias PartialTreeType = PartialTree!112;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = method_qualifier.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified113
	{
		// id=<LoopQualified:false:<Sequential:<true:true:method_qualifier:mq>,<Action:q = q.combine(mq);>>>
		private alias PartialTreeType = PartialTree!113;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential112.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential114
	{
		// id=<Sequential:<LoopQualified:false:<Sequential:<true:true:method_qualifier:mq>,<Action:q = q.combine(mq);>>>,<true:true:type:tt>,<Action: t = tt; >>
		private alias PartialTreeType = PartialTree!114;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ComplexParser_LoopQualified113.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified115
	{
		// id=<LoopQualified:true:<Sequential:<true:true:method_qualifier:mq>,<Action:q = q.combine(mq);>>>
		private alias PartialTreeType = PartialTree!115;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential112.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(!treeList.empty, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching116
	{
		// id=<Switch:<Sequential:<LoopQualified:false:<Sequential:<true:true:method_qualifier:mq>,<Action:q = q.combine(mq);>>>,<true:true:type:tt>,<Action: t = tt; >>,<LoopQualified:true:<Sequential:<true:true:method_qualifier:mq>,<Action:q = q.combine(mq);>>>>
		private alias PartialTreeType = PartialTree!116;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential114.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_LoopQualified115.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential117
	{
		// id=<Sequential:<true:true:varg_list:vpl>,<Action: vps = vpl; >>
		private alias PartialTreeType = PartialTree!117;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = varg_list.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable118
	{
		// id=<Skippable:<Sequential:<true:true:varg_list:vpl>,<Action: vps = vpl; >>>
		private alias PartialTreeType = PartialTree!118;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential117.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential119
	{
		// id=<Sequential:<Action: TypeNode t = null; VirtualParamNode[] vps = null; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); >,<Switch:<Sequential:<LoopQualified:false:<Sequential:<true:true:method_qualifier:mq>,<Action:q = q.combine(mq);>>>,<true:true:type:tt>,<Action: t = tt; >>,<LoopQualified:true:<Sequential:<true:true:method_qualifier:mq>,<Action:q = q.combine(mq);>>>>,<true:true:def_id:id>,<false:false:LP:>,<Skippable:<Sequential:<true:true:varg_list:vpl>,<Action: vps = vpl; >>>,<false:false:RP:>,<true:true:statement:st>,<Action: return new MethodDeclarationNode(q.location.line == int.max ? t.location : q.location, q, t, id, vps, st); >>
		private alias PartialTreeType = PartialTree!119;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_Switching116.parse(r);
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

			resTemp = ComplexParser_Skippable118.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential120
	{
		// id=<Sequential:<Action: TypeNode t = null; VirtualParamNode[] vps = null; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); >,<Switch:<Sequential:<LoopQualified:false:<Sequential:<true:true:method_qualifier:mq>,<Action:q = q.combine(mq);>>>,<true:true:type:tt>,<Action: t = tt; >>,<LoopQualified:true:<Sequential:<true:true:method_qualifier:mq>,<Action:q = q.combine(mq);>>>>,<true:true:def_id:id>,<false:false:LP:>,<Skippable:<Sequential:<true:true:varg_list:vpl>,<Action: vps = vpl; >>>,<false:false:RP:>,<false:false:EQUAL:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<Action: return new MethodDeclarationNode(q.location.line == int.max ? t.location : q.location, q, t, id, vps, e); >>
		private alias PartialTreeType = PartialTree!120;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_Switching116.parse(r);
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

			resTemp = ComplexParser_Skippable118.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential121
	{
		// id=<Sequential:<Action: TypeNode t = null; VirtualParamNode[] vps = null; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); >,<Switch:<Sequential:<LoopQualified:false:<Sequential:<true:true:method_qualifier:mq>,<Action:q = q.combine(mq);>>>,<true:true:type:tt>,<Action: t = tt; >>,<LoopQualified:true:<Sequential:<true:true:method_qualifier:mq>,<Action:q = q.combine(mq);>>>>,<true:true:def_id:id>,<false:false:LP:>,<Skippable:<Sequential:<true:true:varg_list:vpl>,<Action: vps = vpl; >>>,<false:false:RP:>,<false:false:SEMICOLON:>,<Action: return new MethodDeclarationNode(q.location.line == int.max ? t.location : q.location, q, t, id, vps); >>
		private alias PartialTreeType = PartialTree!121;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_Switching116.parse(r);
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

			resTemp = ComplexParser_Skippable118.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential122
	{
		// id=<Sequential:<true:true:getter_def:gd>,<Action: return gd; >>
		private alias PartialTreeType = PartialTree!122;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = getter_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential123
	{
		// id=<Sequential:<true:true:setter_def:sd>,<Action: return sd; >>
		private alias PartialTreeType = PartialTree!123;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = setter_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching124
	{
		// id=<Switch:<Sequential:<true:true:getter_def:gd>,<Action: return gd; >>,<Sequential:<true:true:setter_def:sd>,<Action: return sd; >>>
		private alias PartialTreeType = PartialTree!124;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential125
	{
		// id=<Sequential:<true:true:method_qualifier:q2>,<Action: q = q.combine(q2); >>
		private alias PartialTreeType = PartialTree!125;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = method_qualifier.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified126
	{
		// id=<LoopQualified:false:<Sequential:<true:true:method_qualifier:q2>,<Action: q = q.combine(q2); >>>
		private alias PartialTreeType = PartialTree!126;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential125.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PROPERTY = ElementParser!(EnumTokenType.PROPERTY);
	private static class ComplexParser_Sequential127
	{
		// id=<Sequential:<true:true:type:t>,<Action: tp = t; >>
		private alias PartialTreeType = PartialTree!127;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable128
	{
		// id=<Skippable:<Sequential:<true:true:type:t>,<Action: tp = t; >>>
		private alias PartialTreeType = PartialTree!128;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential127.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential129
	{
		// id=<Sequential:<true:true:statement:st>,<Action: return new SetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, p, st); >>
		private alias PartialTreeType = PartialTree!129;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential130
	{
		// id=<Sequential:<false:false:SEMICOLON:>,<Action: return new SetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, p, null); >>
		private alias PartialTreeType = PartialTree!130;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching131
	{
		// id=<Switch:<Sequential:<true:true:statement:st>,<Action: return new SetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, p, st); >>,<Sequential:<false:false:SEMICOLON:>,<Action: return new SetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, p, null); >>>
		private alias PartialTreeType = PartialTree!131;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential129.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential130.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential132
	{
		// id=<Sequential:<Action: TypeNode tp = null; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); >,<LoopQualified:false:<Sequential:<true:true:method_qualifier:q2>,<Action: q = q.combine(q2); >>>,<true:false:PROPERTY:ft>,<Skippable:<Sequential:<true:true:type:t>,<Action: tp = t; >>>,<true:true:def_id:id>,<false:false:LP:>,<true:true:tn_pair:p>,<false:false:RP:>,<Switch:<Sequential:<true:true:statement:st>,<Action: return new SetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, p, st); >>,<Sequential:<false:false:SEMICOLON:>,<Action: return new SetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, p, null); >>>>
		private alias PartialTreeType = PartialTree!132;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified126.parse(r);
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

			resTemp = ComplexParser_Skippable128.parse(r);
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

			resTemp = tn_pair.parse(r);
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

			resTemp = ComplexParser_Switching131.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential133
	{
		// id=<Sequential:<false:false:LP:>,<false:false:RP:>>
		private alias PartialTreeType = PartialTree!133;
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
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable134
	{
		// id=<Skippable:<Sequential:<false:false:LP:>,<false:false:RP:>>>
		private alias PartialTreeType = PartialTree!134;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential133.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential135
	{
		// id=<Sequential:<false:false:EQUAL:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<Action: return new GetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, e); >>
		private alias PartialTreeType = PartialTree!135;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential136
	{
		// id=<Sequential:<false:false:SEMICOLON:>,<Action: return new GetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, null); >>
		private alias PartialTreeType = PartialTree!136;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential137
	{
		// id=<Sequential:<true:true:statement:st>,<Action: return new GetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, st); >>
		private alias PartialTreeType = PartialTree!137;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching138
	{
		// id=<Switch:<Sequential:<false:false:EQUAL:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<Action: return new GetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, e); >>,<Sequential:<false:false:SEMICOLON:>,<Action: return new GetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, null); >>,<Sequential:<true:true:statement:st>,<Action: return new GetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, st); >>>
		private alias PartialTreeType = PartialTree!138;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential139
	{
		// id=<Sequential:<Action: TypeNode tp = null; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); >,<LoopQualified:false:<Sequential:<true:true:method_qualifier:q2>,<Action: q = q.combine(q2); >>>,<true:false:PROPERTY:ft>,<Skippable:<Sequential:<true:true:type:t>,<Action: tp = t; >>>,<true:true:def_id:id>,<Skippable:<Sequential:<false:false:LP:>,<false:false:RP:>>>,<Switch:<Sequential:<false:false:EQUAL:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<Action: return new GetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, e); >>,<Sequential:<false:false:SEMICOLON:>,<Action: return new GetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, null); >>,<Sequential:<true:true:statement:st>,<Action: return new GetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, st); >>>>
		private alias PartialTreeType = PartialTree!139;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified126.parse(r);
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

			resTemp = ComplexParser_Skippable128.parse(r);
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

			resTemp = ComplexParser_Skippable134.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Switching138.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential140
	{
		// id=<Sequential:<true:true:full_ctor_def:fcd>,<Action: return fcd; >>
		private alias PartialTreeType = PartialTree!140;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = full_ctor_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential141
	{
		// id=<Sequential:<true:true:abs_ctor_def:acd>,<Action: return acd; >>
		private alias PartialTreeType = PartialTree!141;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = abs_ctor_def.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching142
	{
		// id=<Switch:<Sequential:<true:true:full_ctor_def:fcd>,<Action: return fcd; >>,<Sequential:<true:true:abs_ctor_def:acd>,<Action: return acd; >>>
		private alias PartialTreeType = PartialTree!142;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential140.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential141.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential143
	{
		// id=<Sequential:<true:true:ctor_qualifier:cq>,<Action: q = q.combine(cq); >>
		private alias PartialTreeType = PartialTree!143;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ctor_qualifier.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified144
	{
		// id=<LoopQualified:false:<Sequential:<true:true:ctor_qualifier:cq>,<Action: q = q.combine(cq); >>>
		private alias PartialTreeType = PartialTree!144;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential143.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential145
	{
		// id=<Sequential:<Action: auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); >,<LoopQualified:false:<Sequential:<true:true:ctor_qualifier:cq>,<Action: q = q.combine(cq); >>>,<Action: return q; >>
		private alias PartialTreeType = PartialTree!145;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified144.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_THIS = ElementParser!(EnumTokenType.THIS);
	private static class ComplexParser_Sequential146
	{
		// id=<Sequential:<true:true:ctor_quals:q>,<true:false:THIS:ft>,<false:false:LP:>,<true:true:varg_list:vl>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ConstructorDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, vl, st); >>
		private alias PartialTreeType = PartialTree!146;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ctor_quals.parse(r);
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

			resTemp = statement.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential147
	{
		// id=<Sequential:<true:true:ctor_quals:q>,<true:false:THIS:ft>,<false:false:LP:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ConstructorDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, null, st); >>
		private alias PartialTreeType = PartialTree!147;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ctor_quals.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching148
	{
		// id=<Switch:<Sequential:<true:true:ctor_quals:q>,<true:false:THIS:ft>,<false:false:LP:>,<true:true:varg_list:vl>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ConstructorDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, vl, st); >>,<Sequential:<true:true:ctor_quals:q>,<true:false:THIS:ft>,<false:false:LP:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ConstructorDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, null, st); >>>
		private alias PartialTreeType = PartialTree!148;
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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential149
	{
		// id=<Sequential:<true:true:ctor_quals:q>,<true:false:THIS:ft>,<false:false:LP:>,<true:true:varg_list:vl>,<false:false:RP:>,<false:false:SEMICOLON:>,<Action: return new ConstructorDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, vl, null); >>
		private alias PartialTreeType = PartialTree!149;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ctor_quals.parse(r);
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

			resTemp = ElementParser_SEMICOLON.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential150
	{
		// id=<Sequential:<true:true:ctor_quals:q>,<true:false:THIS:ft>,<false:false:LP:>,<false:false:RP:>,<false:false:SEMICOLON:>,<Action: return new ConstructorDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, null, null); >>
		private alias PartialTreeType = PartialTree!150;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ctor_quals.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching151
	{
		// id=<Switch:<Sequential:<true:true:ctor_quals:q>,<true:false:THIS:ft>,<false:false:LP:>,<true:true:varg_list:vl>,<false:false:RP:>,<false:false:SEMICOLON:>,<Action: return new ConstructorDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, vl, null); >>,<Sequential:<true:true:ctor_quals:q>,<true:false:THIS:ft>,<false:false:LP:>,<false:false:RP:>,<false:false:SEMICOLON:>,<Action: return new ConstructorDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, null, null); >>>
		private alias PartialTreeType = PartialTree!151;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential149.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential150.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential152
	{
		// id=<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:id>,<Action: return new TypeNamePair(t.location, t, id.text); >>
		private alias PartialTreeType = PartialTree!152;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential153
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<Action: return new TypeNamePair(id.location, null, id.text); >>
		private alias PartialTreeType = PartialTree!153;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching154
	{
		// id=<Switch:<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:id>,<Action: return new TypeNamePair(t.location, t, id.text); >>,<Sequential:<true:false:IDENTIFIER:id>,<Action: return new TypeNamePair(id.location, null, id.text); >>>
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
	private static class ComplexParser_Sequential155
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:tn_pair:tnp2>,<Action: tnps ~= tnp2; >>
		private alias PartialTreeType = PartialTree!155;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified156
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:tn_pair:tnp2>,<Action: tnps ~= tnp2; >>>
		private alias PartialTreeType = PartialTree!156;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential155.parse(r);
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
		// id=<Sequential:<Action: TypeNamePair[] tnps; >,<true:true:tn_pair:tnp>,<Action: tnps ~= tnp; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:tn_pair:tnp2>,<Action: tnps ~= tnp2; >>>,<Action: return tnps; >>
		private alias PartialTreeType = PartialTree!157;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = tn_pair.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified156.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential158
	{
		// id=<Sequential:<true:true:if_stmt:ifs>,<Action: return ifs; >>
		private alias PartialTreeType = PartialTree!158;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential159
	{
		// id=<Sequential:<true:true:while_stmt:ws>,<Action: return ws; >>
		private alias PartialTreeType = PartialTree!159;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential160
	{
		// id=<Sequential:<true:true:do_stmt:ds>,<Action: return ds; >>
		private alias PartialTreeType = PartialTree!160;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential161
	{
		// id=<Sequential:<true:true:foreach_stmt:fes>,<Action: return fes; >>
		private alias PartialTreeType = PartialTree!161;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential162
	{
		// id=<Sequential:<true:true:for_stmt:fs>,<Action: return fs; >>
		private alias PartialTreeType = PartialTree!162;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential163
	{
		// id=<Sequential:<true:true:return_stmt:rs>,<Action: return rs; >>
		private alias PartialTreeType = PartialTree!163;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential164
	{
		// id=<Sequential:<true:true:break_stmt:bs>,<Action: return bs; >>
		private alias PartialTreeType = PartialTree!164;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential165
	{
		// id=<Sequential:<true:true:continue_stmt:cs>,<Action: return cs; >>
		private alias PartialTreeType = PartialTree!165;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential166
	{
		// id=<Sequential:<true:true:switch_stmt:ss>,<Action: return ss; >>
		private alias PartialTreeType = PartialTree!166;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential167
	{
		// id=<Sequential:<true:true:block_stmt:bls>,<Action: return bls; >>
		private alias PartialTreeType = PartialTree!167;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential168
	{
		// id=<Sequential:<true:true:expression:e>,<false:false:SEMICOLON:>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!168;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential169
	{
		// id=<Sequential:<false:false:SEMICOLON:>,<Action: return null; >>
		private alias PartialTreeType = PartialTree!169;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching170
	{
		// id=<Switch:<Sequential:<true:true:if_stmt:ifs>,<Action: return ifs; >>,<Sequential:<true:true:while_stmt:ws>,<Action: return ws; >>,<Sequential:<true:true:do_stmt:ds>,<Action: return ds; >>,<Sequential:<true:true:foreach_stmt:fes>,<Action: return fes; >>,<Sequential:<true:true:for_stmt:fs>,<Action: return fs; >>,<Sequential:<true:true:return_stmt:rs>,<Action: return rs; >>,<Sequential:<true:true:break_stmt:bs>,<Action: return bs; >>,<Sequential:<true:true:continue_stmt:cs>,<Action: return cs; >>,<Sequential:<true:true:switch_stmt:ss>,<Action: return ss; >>,<Sequential:<true:true:block_stmt:bls>,<Action: return bls; >>,<Sequential:<true:true:expression:e>,<false:false:SEMICOLON:>,<Action: return e; >>,<Sequential:<false:false:SEMICOLON:>,<Action: return null; >>>
		private alias PartialTreeType = PartialTree!170;
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

			resTemp = ComplexParser_Sequential161.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential162.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential163.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential164.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential165.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential166.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_IF = ElementParser!(EnumTokenType.IF);
	private alias ElementParser_ELSE = ElementParser!(EnumTokenType.ELSE);
	private static class ComplexParser_Sequential171
	{
		// id=<Sequential:<true:false:IF:ft>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<true:true:statement:t>,<false:false:ELSE:>,<true:true:statement:n>,<Action: return new ConditionalNode(ft.location, c, t, n); >>
		private alias PartialTreeType = PartialTree!171;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential172
	{
		// id=<Sequential:<true:false:IF:ft>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<true:true:statement:t>,<Action: return new ConditionalNode(ft.location, c, t, null); >>
		private alias PartialTreeType = PartialTree!172;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching173
	{
		// id=<Switch:<Sequential:<true:false:IF:ft>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<true:true:statement:t>,<false:false:ELSE:>,<true:true:statement:n>,<Action: return new ConditionalNode(ft.location, c, t, n); >>,<Sequential:<true:false:IF:ft>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<true:true:statement:t>,<Action: return new ConditionalNode(ft.location, c, t, null); >>>
		private alias PartialTreeType = PartialTree!173;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential171.parse(r);
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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_COLON = ElementParser!(EnumTokenType.COLON);
	private alias ElementParser_WHILE = ElementParser!(EnumTokenType.WHILE);
	private static class ComplexParser_Sequential174
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:false:WHILE:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:RP:>,<true:true:statement:st>,<Action: return new PreConditionLoopNode(ft.location, id.text, e, st); >>
		private alias PartialTreeType = PartialTree!174;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential175
	{
		// id=<Sequential:<true:false:WHILE:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:RP:>,<true:true:statement:st>,<Action: return new PreConditionLoopNode(ft.location, e, st); >>
		private alias PartialTreeType = PartialTree!175;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching176
	{
		// id=<Switch:<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:false:WHILE:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:RP:>,<true:true:statement:st>,<Action: return new PreConditionLoopNode(ft.location, id.text, e, st); >>,<Sequential:<true:false:WHILE:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:RP:>,<true:true:statement:st>,<Action: return new PreConditionLoopNode(ft.location, e, st); >>>
		private alias PartialTreeType = PartialTree!176;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential174.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential175.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_DO = ElementParser!(EnumTokenType.DO);
	private static class ComplexParser_Sequential177
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:false:DO:ft>,<true:true:statement:st>,<false:false:WHILE:>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<false:false:SEMICOLON:>,<Action: return new PostConditionLoopNode(ft.location, id.text, c, st); >>
		private alias PartialTreeType = PartialTree!177;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential178
	{
		// id=<Sequential:<true:false:DO:ft>,<true:true:statement:st>,<false:false:WHILE:>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<false:false:SEMICOLON:>,<Action: return new PostConditionLoopNode(ft.location, c, st); >>
		private alias PartialTreeType = PartialTree!178;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching179
	{
		// id=<Switch:<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:false:DO:ft>,<true:true:statement:st>,<false:false:WHILE:>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<false:false:SEMICOLON:>,<Action: return new PostConditionLoopNode(ft.location, id.text, c, st); >>,<Sequential:<true:false:DO:ft>,<true:true:statement:st>,<false:false:WHILE:>,<false:false:LP:>,<true:true:expression:c>,<false:false:RP:>,<false:false:SEMICOLON:>,<Action: return new PostConditionLoopNode(ft.location, c, st); >>>
		private alias PartialTreeType = PartialTree!179;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential180
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:true:foreach_stmt_impl:fs>,<Action: return fs.withName(id.text); >>
		private alias PartialTreeType = PartialTree!180;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential181
	{
		// id=<Sequential:<true:true:foreach_stmt_impl:fs>,<Action: return fs; >>
		private alias PartialTreeType = PartialTree!181;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching182
	{
		// id=<Switch:<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:true:foreach_stmt_impl:fs>,<Action: return fs.withName(id.text); >>,<Sequential:<true:true:foreach_stmt_impl:fs>,<Action: return fs; >>>
		private alias PartialTreeType = PartialTree!182;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_FOREACH = ElementParser!(EnumTokenType.FOREACH);
	private alias ElementParser_LARROW = ElementParser!(EnumTokenType.LARROW);
	private static class ComplexParser_Sequential183
	{
		// id=<Sequential:<true:false:FOREACH:ft>,<false:false:LP:>,<true:true:tn_list:tnl>,<false:false:LARROW:>,<true:true:expression:e>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForeachStatementNode(ft.location, tnl, e, st); >>
		private alias PartialTreeType = PartialTree!183;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential184
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:true:for_stmt_impl:fs>,<Action: return fs.withName(id.text); >>
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential185
	{
		// id=<Sequential:<true:true:for_stmt_impl:fs>,<Action: return fs; >>
		private alias PartialTreeType = PartialTree!185;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching186
	{
		// id=<Switch:<Sequential:<true:false:IDENTIFIER:id>,<false:false:COLON:>,<true:true:for_stmt_impl:fs>,<Action: return fs.withName(id.text); >>,<Sequential:<true:true:for_stmt_impl:fs>,<Action: return fs; >>>
		private alias PartialTreeType = PartialTree!186;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

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
	private alias ElementParser_FOR = ElementParser!(EnumTokenType.FOR);
	private static class ComplexParser_Sequential187
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, e2, e3, st); >>
		private alias PartialTreeType = PartialTree!187;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential188
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, e2, null, st); >>
		private alias PartialTreeType = PartialTree!188;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential189
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, null, e3, st); >>
		private alias PartialTreeType = PartialTree!189;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential190
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, null, null, st); >>
		private alias PartialTreeType = PartialTree!190;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential191
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, e2, e3, st); >>
		private alias PartialTreeType = PartialTree!191;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential192
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, e2, null, st); >>
		private alias PartialTreeType = PartialTree!192;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential193
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, null, e3, st); >>
		private alias PartialTreeType = PartialTree!193;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential194
	{
		// id=<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, null, null, st); >>
		private alias PartialTreeType = PartialTree!194;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching195
	{
		// id=<Switch:<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, e2, e3, st); >>,<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, e2, null, st); >>,<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, null, e3, st); >>,<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<true:true:expression:e>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, e, null, null, st); >>,<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, e2, e3, st); >>,<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<true:true:expression:e2>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, e2, null, st); >>,<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<true:true:expression:e3>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, null, e3, st); >>,<Sequential:<true:false:FOR:ft>,<false:false:LP:>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<false:false:SEMICOLON:>,<false:false:RP:>,<true:true:statement:st>,<Action: return new ForStatementNode(ft.location, null, null, null, st); >>>
		private alias PartialTreeType = PartialTree!195;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential187.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential188.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential189.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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

			resTemp = ComplexParser_Sequential193.parse(r);
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
	private alias ElementParser_RETURN = ElementParser!(EnumTokenType.RETURN);
	private static class ComplexParser_Sequential196
	{
		// id=<Sequential:<true:false:RETURN:ft>,<true:true:expression:e>,<false:false:SEMICOLON:>,<Action: return new ReturnNode(ft.location, e); >>
		private alias PartialTreeType = PartialTree!196;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential197
	{
		// id=<Sequential:<true:false:RETURN:ft>,<false:false:SEMICOLON:>,<Action: return new ReturnNode(ft.location, null); >>
		private alias PartialTreeType = PartialTree!197;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching198
	{
		// id=<Switch:<Sequential:<true:false:RETURN:ft>,<true:true:expression:e>,<false:false:SEMICOLON:>,<Action: return new ReturnNode(ft.location, e); >>,<Sequential:<true:false:RETURN:ft>,<false:false:SEMICOLON:>,<Action: return new ReturnNode(ft.location, null); >>>
		private alias PartialTreeType = PartialTree!198;
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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_BREAK = ElementParser!(EnumTokenType.BREAK);
	private static class ComplexParser_Sequential199
	{
		// id=<Sequential:<true:false:BREAK:ft>,<true:false:IDENTIFIER:id>,<false:false:SEMICOLON:>,<Action: return new BreakLoopNode(ft.location, id.text); >>
		private alias PartialTreeType = PartialTree!199;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential200
	{
		// id=<Sequential:<true:false:BREAK:ft>,<false:false:SEMICOLON:>,<Action: return new BreakLoopNode(ft.location, null); >>
		private alias PartialTreeType = PartialTree!200;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching201
	{
		// id=<Switch:<Sequential:<true:false:BREAK:ft>,<true:false:IDENTIFIER:id>,<false:false:SEMICOLON:>,<Action: return new BreakLoopNode(ft.location, id.text); >>,<Sequential:<true:false:BREAK:ft>,<false:false:SEMICOLON:>,<Action: return new BreakLoopNode(ft.location, null); >>>
		private alias PartialTreeType = PartialTree!201;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_CONTINUE = ElementParser!(EnumTokenType.CONTINUE);
	private static class ComplexParser_Sequential202
	{
		// id=<Sequential:<true:false:CONTINUE:ft>,<true:false:IDENTIFIER:id>,<false:false:SEMICOLON:>,<Action: return new ContinueLoopNode(ft.location, id.text); >>
		private alias PartialTreeType = PartialTree!202;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential203
	{
		// id=<Sequential:<true:false:CONTINUE:ft>,<false:false:SEMICOLON:>,<Action: return new ContinueLoopNode(ft.location, null); >>
		private alias PartialTreeType = PartialTree!203;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching204
	{
		// id=<Switch:<Sequential:<true:false:CONTINUE:ft>,<true:false:IDENTIFIER:id>,<false:false:SEMICOLON:>,<Action: return new ContinueLoopNode(ft.location, id.text); >>,<Sequential:<true:false:CONTINUE:ft>,<false:false:SEMICOLON:>,<Action: return new ContinueLoopNode(ft.location, null); >>>
		private alias PartialTreeType = PartialTree!204;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential202.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential203.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_SWITCH = ElementParser!(EnumTokenType.SWITCH);
	private static class ComplexParser_Sequential205
	{
		// id=<Sequential:<true:true:case_stmt:cs>,<Action: sects ~= cs; >>
		private alias PartialTreeType = PartialTree!205;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential206
	{
		// id=<Sequential:<true:true:default_stmt:ds>,<Action: sects ~= ds; >>
		private alias PartialTreeType = PartialTree!206;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching207
	{
		// id=<Switch:<Sequential:<true:true:case_stmt:cs>,<Action: sects ~= cs; >>,<Sequential:<true:true:default_stmt:ds>,<Action: sects ~= ds; >>>
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
		// id=<LoopQualified:false:<Switch:<Sequential:<true:true:case_stmt:cs>,<Action: sects ~= cs; >>,<Sequential:<true:true:default_stmt:ds>,<Action: sects ~= ds; >>>>
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
		// id=<Sequential:<true:false:SWITCH:ft>,<false:false:LP:>,<true:true:expression:te>,<false:false:RP:>,<false:false:LB:>,<Action: SwitchSectionNode[] sects; >,<LoopQualified:false:<Switch:<Sequential:<true:true:case_stmt:cs>,<Action: sects ~= cs; >>,<Sequential:<true:true:default_stmt:ds>,<Action: sects ~= ds; >>>>,<false:false:RB:>,<Action: return new SwitchStatementNode(ft.location, te, sects); >>
		private alias PartialTreeType = PartialTree!209;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified208.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential210
	{
		// id=<Sequential:<true:true:value_case_sect:vcs>,<Action: return vcs; >>
		private alias PartialTreeType = PartialTree!210;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential211
	{
		// id=<Sequential:<true:true:type_case_sect:tcs>,<Action: return tcs; >>
		private alias PartialTreeType = PartialTree!211;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching212
	{
		// id=<Switch:<Sequential:<true:true:value_case_sect:vcs>,<Action: return vcs; >>,<Sequential:<true:true:type_case_sect:tcs>,<Action: return tcs; >>>
		private alias PartialTreeType = PartialTree!212;
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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_CASE = ElementParser!(EnumTokenType.CASE);
	private alias ElementParser_RARROW2 = ElementParser!(EnumTokenType.RARROW2);
	private static class ComplexParser_Sequential213
	{
		// id=<Sequential:<true:false:CASE:ft>,<true:true:expression_list:el>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new ValueCaseSectionNode(ft.location, el, st); >>
		private alias PartialTreeType = PartialTree!213;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_CONST = ElementParser!(EnumTokenType.CONST);
	private static class ComplexParser_Sequential214
	{
		// id=<Sequential:<true:false:CASE:ft>,<false:false:CONST:>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:IF:>,<true:true:expression:e>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, true, id, t, e, st); >>
		private alias PartialTreeType = PartialTree!214;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential215
	{
		// id=<Sequential:<true:false:CASE:ft>,<false:false:CONST:>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, true, id, t, null, st); >>
		private alias PartialTreeType = PartialTree!215;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential216
	{
		// id=<Sequential:<true:false:CASE:ft>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:IF:>,<true:true:expression:e>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, false, id, t, e, st); >>
		private alias PartialTreeType = PartialTree!216;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential217
	{
		// id=<Sequential:<true:false:CASE:ft>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, false, id, t, null, st); >>
		private alias PartialTreeType = PartialTree!217;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching218
	{
		// id=<Switch:<Sequential:<true:false:CASE:ft>,<false:false:CONST:>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:IF:>,<true:true:expression:e>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, true, id, t, e, st); >>,<Sequential:<true:false:CASE:ft>,<false:false:CONST:>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, true, id, t, null, st); >>,<Sequential:<true:false:CASE:ft>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:IF:>,<true:true:expression:e>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, false, id, t, e, st); >>,<Sequential:<true:false:CASE:ft>,<true:true:def_id:id>,<false:false:COLON:>,<true:true:type:t>,<false:false:RARROW2:>,<true:true:statement:st>,<Action: return new TypeCaseSectionNode(ft.location, false, id, t, null, st); >>>
		private alias PartialTreeType = PartialTree!218;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential214.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential215.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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
	private alias ElementParser_DEFAULT = ElementParser!(EnumTokenType.DEFAULT);
	private static class ComplexParser_Sequential219
	{
		// id=<Sequential:<true:false:DEFAULT:ft>,<false:false:RARROW2:>,<true:true:statement:s>,<Action: return new DefaultSectionNode(ft.location, s); >>
		private alias PartialTreeType = PartialTree!219;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential220
	{
		// id=<Sequential:<true:true:localvar_def:lvd>,<Action: stmts ~= lvd; >>
		private alias PartialTreeType = PartialTree!220;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential221
	{
		// id=<Sequential:<true:true:statement:st>,<Action: stmts ~= st; >>
		private alias PartialTreeType = PartialTree!221;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching222
	{
		// id=<Switch:<Sequential:<true:true:localvar_def:lvd>,<Action: stmts ~= lvd; >>,<Sequential:<true:true:statement:st>,<Action: stmts ~= st; >>>
		private alias PartialTreeType = PartialTree!222;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential220.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential221.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified223
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<true:true:localvar_def:lvd>,<Action: stmts ~= lvd; >>,<Sequential:<true:true:statement:st>,<Action: stmts ~= st; >>>>
		private alias PartialTreeType = PartialTree!223;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching222.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential224
	{
		// id=<Sequential:<true:false:LB:t>,<Action: StatementNode[] stmts; >,<LoopQualified:false:<Switch:<Sequential:<true:true:localvar_def:lvd>,<Action: stmts ~= lvd; >>,<Sequential:<true:true:statement:st>,<Action: stmts ~= st; >>>>,<false:false:RB:>,<Action: return new BlockStatementNode(t.location, stmts); >>
		private alias PartialTreeType = PartialTree!224;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified223.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential225
	{
		// id=<Sequential:<true:true:full_lvd:flvd>,<Action: return flvd; >>
		private alias PartialTreeType = PartialTree!225;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential226
	{
		// id=<Sequential:<true:true:inferenced_lvd:ilvd>,<Action: return ilvd; >>
		private alias PartialTreeType = PartialTree!226;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching227
	{
		// id=<Switch:<Sequential:<true:true:full_lvd:flvd>,<Action: return flvd; >>,<Sequential:<true:true:inferenced_lvd:ilvd>,<Action: return ilvd; >>>
		private alias PartialTreeType = PartialTree!227;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential225.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential226.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential228
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:nvpair:nvp2>,<Action: nvps ~= nvp2; >>
		private alias PartialTreeType = PartialTree!228;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified229
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:nvpair:nvp2>,<Action: nvps ~= nvp2; >>>
		private alias PartialTreeType = PartialTree!229;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential228.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential230
	{
		// id=<Sequential:<Action: NameValuePair[] nvps; >,<true:true:nvpair:nvp>,<Action: nvps ~= nvp; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:nvpair:nvp2>,<Action: nvps ~= nvp2; >>>,<Action: return nvps; >>
		private alias PartialTreeType = PartialTree!230;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = nvpair.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified229.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential231
	{
		// id=<Sequential:<true:true:lvar_qualifier:lq>,<Action: q = q.combine(lq); >>
		private alias PartialTreeType = PartialTree!231;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified232
	{
		// id=<LoopQualified:false:<Sequential:<true:true:lvar_qualifier:lq>,<Action: q = q.combine(lq); >>>
		private alias PartialTreeType = PartialTree!232;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential231.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential233
	{
		// id=<Sequential:<Action: auto q = Qualifier(Location(int.max, int.max), Qualifiers.Public); >,<LoopQualified:false:<Sequential:<true:true:lvar_qualifier:lq>,<Action: q = q.combine(lq); >>>,<true:true:type:tp>,<true:true:nvp_list:nvps>,<false:false:SEMICOLON:>,<Action: return new LocalVariableDeclarationNode(q.location.line == int.max ? tp.location : q.location, q, tp, nvps); >>
		private alias PartialTreeType = PartialTree!233;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified232.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential234
	{
		// id=<Sequential:<true:true:lvar_qualifier:q2>,<Action: q = q.combine(q2); >>
		private alias PartialTreeType = PartialTree!234;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified235
	{
		// id=<LoopQualified:false:<Sequential:<true:true:lvar_qualifier:q2>,<Action: q = q.combine(q2); >>>
		private alias PartialTreeType = PartialTree!235;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential234.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential236
	{
		// id=<Sequential:<true:true:lvar_qualifier:q>,<LoopQualified:false:<Sequential:<true:true:lvar_qualifier:q2>,<Action: q = q.combine(q2); >>>,<true:true:nvp_list:nvps>,<false:false:SEMICOLON:>,<Action: return new LocalVariableDeclarationNode(q.location, q, new InferenceTypeNode(q.location), nvps); >>
		private alias PartialTreeType = PartialTree!236;
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

			resTemp = ComplexParser_LoopQualified235.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential237
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:expression:e2>,<Action: elist ~= e2; >>
		private alias PartialTreeType = PartialTree!237;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified238
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:expression:e2>,<Action: elist ~= e2; >>>
		private alias PartialTreeType = PartialTree!238;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential237.parse(r);
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
		// id=<Sequential:<Action: ExpressionNode[] elist; >,<true:true:expression:e>,<Action: elist ~= e; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:expression:e2>,<Action: elist ~= e2; >>>,<Action: return elist; >>
		private alias PartialTreeType = PartialTree!239;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = expression.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified238.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential240
	{
		// id=<Sequential:<true:true:postfix_expr:l>,<false:false:EQUAL:>,<true:true:expression:r>,<Action: return new AssignOperatorNode(l, r); >>
		private alias PartialTreeType = PartialTree!240;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential241
	{
		// id=<Sequential:<true:true:postfix_expr:l>,<true:true:assign_ops:o>,<true:true:expression:r>,<Action: return new OperatedAssignNode(l, o, r); >>
		private alias PartialTreeType = PartialTree!241;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential242
	{
		// id=<Sequential:<true:true:alternate_expr:e>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!242;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching243
	{
		// id=<Switch:<Sequential:<true:true:postfix_expr:l>,<false:false:EQUAL:>,<true:true:expression:r>,<Action: return new AssignOperatorNode(l, r); >>,<Sequential:<true:true:postfix_expr:l>,<true:true:assign_ops:o>,<true:true:expression:r>,<Action: return new OperatedAssignNode(l, o, r); >>,<Sequential:<true:true:alternate_expr:e>,<Action: return e; >>>
		private alias PartialTreeType = PartialTree!243;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_PLUS_EQ = ElementParser!(EnumTokenType.PLUS_EQ);
	private static class ComplexParser_Sequential244
	{
		// id=<Sequential:<false:false:PLUS_EQ:>,<Action: return BinaryOperatorType.Add; >>
		private alias PartialTreeType = PartialTree!244;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_MINUS_EQ = ElementParser!(EnumTokenType.MINUS_EQ);
	private static class ComplexParser_Sequential245
	{
		// id=<Sequential:<false:false:MINUS_EQ:>,<Action: return BinaryOperatorType.Sub; >>
		private alias PartialTreeType = PartialTree!245;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_ASTERISK_EQ = ElementParser!(EnumTokenType.ASTERISK_EQ);
	private static class ComplexParser_Sequential246
	{
		// id=<Sequential:<false:false:ASTERISK_EQ:>,<Action: return BinaryOperatorType.Mul; >>
		private alias PartialTreeType = PartialTree!246;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_SLASH_EQ = ElementParser!(EnumTokenType.SLASH_EQ);
	private static class ComplexParser_Sequential247
	{
		// id=<Sequential:<false:false:SLASH_EQ:>,<Action: return BinaryOperatorType.Div; >>
		private alias PartialTreeType = PartialTree!247;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PERCENT_EQ = ElementParser!(EnumTokenType.PERCENT_EQ);
	private static class ComplexParser_Sequential248
	{
		// id=<Sequential:<false:false:PERCENT_EQ:>,<Action: return BinaryOperatorType.Mod; >>
		private alias PartialTreeType = PartialTree!248;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_AMPASAND_EQ = ElementParser!(EnumTokenType.AMPASAND_EQ);
	private static class ComplexParser_Sequential249
	{
		// id=<Sequential:<false:false:AMPASAND_EQ:>,<Action: return BinaryOperatorType.And; >>
		private alias PartialTreeType = PartialTree!249;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_VL_EQ = ElementParser!(EnumTokenType.VL_EQ);
	private static class ComplexParser_Sequential250
	{
		// id=<Sequential:<false:false:VL_EQ:>,<Action: return BinaryOperatorType.Or; >>
		private alias PartialTreeType = PartialTree!250;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_CA_EQ = ElementParser!(EnumTokenType.CA_EQ);
	private static class ComplexParser_Sequential251
	{
		// id=<Sequential:<false:false:CA_EQ:>,<Action: return BinaryOperatorType.Xor; >>
		private alias PartialTreeType = PartialTree!251;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LAB2_EQ = ElementParser!(EnumTokenType.LAB2_EQ);
	private static class ComplexParser_Sequential252
	{
		// id=<Sequential:<false:false:LAB2_EQ:>,<Action: return BinaryOperatorType.LeftShift; >>
		private alias PartialTreeType = PartialTree!252;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_RAB2_EQ = ElementParser!(EnumTokenType.RAB2_EQ);
	private static class ComplexParser_Sequential253
	{
		// id=<Sequential:<false:false:RAB2_EQ:>,<Action: return BinaryOperatorType.RightShift; >>
		private alias PartialTreeType = PartialTree!253;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching254
	{
		// id=<Switch:<Sequential:<false:false:PLUS_EQ:>,<Action: return BinaryOperatorType.Add; >>,<Sequential:<false:false:MINUS_EQ:>,<Action: return BinaryOperatorType.Sub; >>,<Sequential:<false:false:ASTERISK_EQ:>,<Action: return BinaryOperatorType.Mul; >>,<Sequential:<false:false:SLASH_EQ:>,<Action: return BinaryOperatorType.Div; >>,<Sequential:<false:false:PERCENT_EQ:>,<Action: return BinaryOperatorType.Mod; >>,<Sequential:<false:false:AMPASAND_EQ:>,<Action: return BinaryOperatorType.And; >>,<Sequential:<false:false:VL_EQ:>,<Action: return BinaryOperatorType.Or; >>,<Sequential:<false:false:CA_EQ:>,<Action: return BinaryOperatorType.Xor; >>,<Sequential:<false:false:LAB2_EQ:>,<Action: return BinaryOperatorType.LeftShift; >>,<Sequential:<false:false:RAB2_EQ:>,<Action: return BinaryOperatorType.RightShift; >>>
		private alias PartialTreeType = PartialTree!254;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

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

			resTemp = ComplexParser_Sequential248.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential249.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential250.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_QUESTION = ElementParser!(EnumTokenType.QUESTION);
	private static class ComplexParser_Sequential255
	{
		// id=<Sequential:<false:false:QUESTION:>,<true:true:short_expr:t>,<false:false:COLON:>,<true:true:short_expr:n>,<Action: e = new AlternateValueNode(e, t, n); >>
		private alias PartialTreeType = PartialTree!255;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable256
	{
		// id=<Skippable:<Sequential:<false:false:QUESTION:>,<true:true:short_expr:t>,<false:false:COLON:>,<true:true:short_expr:n>,<Action: e = new AlternateValueNode(e, t, n); >>>
		private alias PartialTreeType = PartialTree!256;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential255.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential257
	{
		// id=<Sequential:<true:true:short_expr:e>,<Skippable:<Sequential:<false:false:QUESTION:>,<true:true:short_expr:t>,<false:false:COLON:>,<true:true:short_expr:n>,<Action: e = new AlternateValueNode(e, t, n); >>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!257;
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

			resTemp = ComplexParser_Skippable256.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_AMPASAND2 = ElementParser!(EnumTokenType.AMPASAND2);
	private static class ComplexParser_Sequential258
	{
		// id=<Sequential:<false:false:AMPASAND2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogAnd, e2); >>
		private alias PartialTreeType = PartialTree!258;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_VL2 = ElementParser!(EnumTokenType.VL2);
	private static class ComplexParser_Sequential259
	{
		// id=<Sequential:<false:false:VL2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogOr, e2); >>
		private alias PartialTreeType = PartialTree!259;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_CA2 = ElementParser!(EnumTokenType.CA2);
	private static class ComplexParser_Sequential260
	{
		// id=<Sequential:<false:false:CA2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogXor, e2); >>
		private alias PartialTreeType = PartialTree!260;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching261
	{
		// id=<Switch:<Sequential:<false:false:AMPASAND2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogAnd, e2); >>,<Sequential:<false:false:VL2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogOr, e2); >>,<Sequential:<false:false:CA2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogXor, e2); >>>
		private alias PartialTreeType = PartialTree!261;
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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified262
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:AMPASAND2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogAnd, e2); >>,<Sequential:<false:false:VL2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogOr, e2); >>,<Sequential:<false:false:CA2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogXor, e2); >>>>
		private alias PartialTreeType = PartialTree!262;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching261.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential263
	{
		// id=<Sequential:<true:true:comp_expr:e>,<LoopQualified:false:<Switch:<Sequential:<false:false:AMPASAND2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogAnd, e2); >>,<Sequential:<false:false:VL2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogOr, e2); >>,<Sequential:<false:false:CA2:>,<true:true:comp_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LogXor, e2); >>>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!263;
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

			resTemp = ComplexParser_LoopQualified262.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LAB = ElementParser!(EnumTokenType.LAB);
	private static class ComplexParser_Sequential264
	{
		// id=<Sequential:<false:false:LAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Less, e2); >>
		private alias PartialTreeType = PartialTree!264;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_RAB = ElementParser!(EnumTokenType.RAB);
	private static class ComplexParser_Sequential265
	{
		// id=<Sequential:<false:false:RAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Greater, e2); >>
		private alias PartialTreeType = PartialTree!265;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_EQ2 = ElementParser!(EnumTokenType.EQ2);
	private static class ComplexParser_Sequential266
	{
		// id=<Sequential:<false:false:EQ2:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Equiv, e2); >>
		private alias PartialTreeType = PartialTree!266;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_EX_EQ = ElementParser!(EnumTokenType.EX_EQ);
	private static class ComplexParser_Sequential267
	{
		// id=<Sequential:<false:false:EX_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Inequiv, e2); >>
		private alias PartialTreeType = PartialTree!267;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LAB_EQ = ElementParser!(EnumTokenType.LAB_EQ);
	private static class ComplexParser_Sequential268
	{
		// id=<Sequential:<false:false:LAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LessEq, e2); >>
		private alias PartialTreeType = PartialTree!268;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_RAB_EQ = ElementParser!(EnumTokenType.RAB_EQ);
	private static class ComplexParser_Sequential269
	{
		// id=<Sequential:<false:false:RAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.GreaterEq, e2); >>
		private alias PartialTreeType = PartialTree!269;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching270
	{
		// id=<Switch:<Sequential:<false:false:LAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Less, e2); >>,<Sequential:<false:false:RAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Greater, e2); >>,<Sequential:<false:false:EQ2:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Equiv, e2); >>,<Sequential:<false:false:EX_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Inequiv, e2); >>,<Sequential:<false:false:LAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LessEq, e2); >>,<Sequential:<false:false:RAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.GreaterEq, e2); >>>
		private alias PartialTreeType = PartialTree!270;
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

			resTemp = ComplexParser_Sequential266.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential267.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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
	private static class ComplexParser_LoopQualified271
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:LAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Less, e2); >>,<Sequential:<false:false:RAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Greater, e2); >>,<Sequential:<false:false:EQ2:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Equiv, e2); >>,<Sequential:<false:false:EX_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Inequiv, e2); >>,<Sequential:<false:false:LAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LessEq, e2); >>,<Sequential:<false:false:RAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.GreaterEq, e2); >>>>
		private alias PartialTreeType = PartialTree!271;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching270.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential272
	{
		// id=<Sequential:<true:true:shift_expr:e>,<LoopQualified:false:<Switch:<Sequential:<false:false:LAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Less, e2); >>,<Sequential:<false:false:RAB:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Greater, e2); >>,<Sequential:<false:false:EQ2:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Equiv, e2); >>,<Sequential:<false:false:EX_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Inequiv, e2); >>,<Sequential:<false:false:LAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LessEq, e2); >>,<Sequential:<false:false:RAB_EQ:>,<true:true:shift_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.GreaterEq, e2); >>>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!272;
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

			resTemp = ComplexParser_LoopQualified271.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LAB2 = ElementParser!(EnumTokenType.LAB2);
	private static class ComplexParser_Sequential273
	{
		// id=<Sequential:<false:false:LAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LeftShift, e2); >>
		private alias PartialTreeType = PartialTree!273;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_RAB2 = ElementParser!(EnumTokenType.RAB2);
	private static class ComplexParser_Sequential274
	{
		// id=<Sequential:<false:false:RAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.RightShift, e2); >>
		private alias PartialTreeType = PartialTree!274;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching275
	{
		// id=<Switch:<Sequential:<false:false:LAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LeftShift, e2); >>,<Sequential:<false:false:RAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.RightShift, e2); >>>
		private alias PartialTreeType = PartialTree!275;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential273.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential274.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified276
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:LAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LeftShift, e2); >>,<Sequential:<false:false:RAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.RightShift, e2); >>>>
		private alias PartialTreeType = PartialTree!276;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching275.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential277
	{
		// id=<Sequential:<true:true:bit_expr:e>,<LoopQualified:false:<Switch:<Sequential:<false:false:LAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.LeftShift, e2); >>,<Sequential:<false:false:RAB2:>,<true:true:bit_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.RightShift, e2); >>>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!277;
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

			resTemp = ComplexParser_LoopQualified276.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_AMPASAND = ElementParser!(EnumTokenType.AMPASAND);
	private static class ComplexParser_Sequential278
	{
		// id=<Sequential:<false:false:AMPASAND:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.And, e2); >>
		private alias PartialTreeType = PartialTree!278;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_VL = ElementParser!(EnumTokenType.VL);
	private static class ComplexParser_Sequential279
	{
		// id=<Sequential:<false:false:VL:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Or, e2); >>
		private alias PartialTreeType = PartialTree!279;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_CA = ElementParser!(EnumTokenType.CA);
	private static class ComplexParser_Sequential280
	{
		// id=<Sequential:<false:false:CA:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Xor, e2); >>
		private alias PartialTreeType = PartialTree!280;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching281
	{
		// id=<Switch:<Sequential:<false:false:AMPASAND:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.And, e2); >>,<Sequential:<false:false:VL:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Or, e2); >>,<Sequential:<false:false:CA:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Xor, e2); >>>
		private alias PartialTreeType = PartialTree!281;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

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

			resTemp = ComplexParser_Sequential280.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified282
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:AMPASAND:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.And, e2); >>,<Sequential:<false:false:VL:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Or, e2); >>,<Sequential:<false:false:CA:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Xor, e2); >>>>
		private alias PartialTreeType = PartialTree!282;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching281.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential283
	{
		// id=<Sequential:<true:true:a1_expr:e>,<LoopQualified:false:<Switch:<Sequential:<false:false:AMPASAND:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.And, e2); >>,<Sequential:<false:false:VL:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Or, e2); >>,<Sequential:<false:false:CA:>,<true:true:a1_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Xor, e2); >>>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!283;
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

			resTemp = ComplexParser_LoopQualified282.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PLUS = ElementParser!(EnumTokenType.PLUS);
	private static class ComplexParser_Sequential284
	{
		// id=<Sequential:<false:false:PLUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Add, e2); >>
		private alias PartialTreeType = PartialTree!284;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_MINUS = ElementParser!(EnumTokenType.MINUS);
	private static class ComplexParser_Sequential285
	{
		// id=<Sequential:<false:false:MINUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Sub, e2); >>
		private alias PartialTreeType = PartialTree!285;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching286
	{
		// id=<Switch:<Sequential:<false:false:PLUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Add, e2); >>,<Sequential:<false:false:MINUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Sub, e2); >>>
		private alias PartialTreeType = PartialTree!286;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential284.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential285.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified287
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:PLUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Add, e2); >>,<Sequential:<false:false:MINUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Sub, e2); >>>>
		private alias PartialTreeType = PartialTree!287;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching286.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential288
	{
		// id=<Sequential:<true:true:a2_expr:e>,<LoopQualified:false:<Switch:<Sequential:<false:false:PLUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Add, e2); >>,<Sequential:<false:false:MINUS:>,<true:true:a2_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Sub, e2); >>>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!288;
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

			resTemp = ComplexParser_LoopQualified287.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_ASTERISK = ElementParser!(EnumTokenType.ASTERISK);
	private static class ComplexParser_Sequential289
	{
		// id=<Sequential:<false:false:ASTERISK:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mul, e2); >>
		private alias PartialTreeType = PartialTree!289;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_SLASH = ElementParser!(EnumTokenType.SLASH);
	private static class ComplexParser_Sequential290
	{
		// id=<Sequential:<false:false:SLASH:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Div, e2); >>
		private alias PartialTreeType = PartialTree!290;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PERCENT = ElementParser!(EnumTokenType.PERCENT);
	private static class ComplexParser_Sequential291
	{
		// id=<Sequential:<false:false:PERCENT:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mod, e2); >>
		private alias PartialTreeType = PartialTree!291;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching292
	{
		// id=<Switch:<Sequential:<false:false:ASTERISK:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mul, e2); >>,<Sequential:<false:false:SLASH:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Div, e2); >>,<Sequential:<false:false:PERCENT:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mod, e2); >>>
		private alias PartialTreeType = PartialTree!292;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential289.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential290.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential291.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified293
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:ASTERISK:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mul, e2); >>,<Sequential:<false:false:SLASH:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Div, e2); >>,<Sequential:<false:false:PERCENT:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mod, e2); >>>>
		private alias PartialTreeType = PartialTree!293;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching292.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential294
	{
		// id=<Sequential:<true:true:range_expr:e>,<LoopQualified:false:<Switch:<Sequential:<false:false:ASTERISK:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mul, e2); >>,<Sequential:<false:false:SLASH:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Div, e2); >>,<Sequential:<false:false:PERCENT:>,<true:true:range_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Mod, e2); >>>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!294;
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

			resTemp = ComplexParser_LoopQualified293.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PERIOD2 = ElementParser!(EnumTokenType.PERIOD2);
	private static class ComplexParser_Sequential295
	{
		// id=<Sequential:<false:false:PERIOD2:>,<true:true:prefix_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Ranged, e2); >>
		private alias PartialTreeType = PartialTree!295;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified296
	{
		// id=<LoopQualified:false:<Sequential:<false:false:PERIOD2:>,<true:true:prefix_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Ranged, e2); >>>
		private alias PartialTreeType = PartialTree!296;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential295.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential297
	{
		// id=<Sequential:<true:true:prefix_expr:e>,<LoopQualified:false:<Sequential:<false:false:PERIOD2:>,<true:true:prefix_expr:e2>,<Action: e = new BinaryOperatorNode(e, BinaryOperatorType.Ranged, e2); >>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!297;
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

			resTemp = ComplexParser_LoopQualified296.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential298
	{
		// id=<Sequential:<false:false:PLUS:>,<true:true:prefix_expr:e>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!298;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential299
	{
		// id=<Sequential:<true:false:MINUS:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Negate); >>
		private alias PartialTreeType = PartialTree!299;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PLUS2 = ElementParser!(EnumTokenType.PLUS2);
	private static class ComplexParser_Sequential300
	{
		// id=<Sequential:<true:false:PLUS2:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Increase); >>
		private alias PartialTreeType = PartialTree!300;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_MINUS2 = ElementParser!(EnumTokenType.MINUS2);
	private static class ComplexParser_Sequential301
	{
		// id=<Sequential:<true:false:MINUS2:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Decrease); >>
		private alias PartialTreeType = PartialTree!301;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_ASTERISK2 = ElementParser!(EnumTokenType.ASTERISK2);
	private static class ComplexParser_Sequential302
	{
		// id=<Sequential:<true:false:ASTERISK2:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Square); >>
		private alias PartialTreeType = PartialTree!302;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential303
	{
		// id=<Sequential:<true:true:postfix_expr:e>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!303;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching304
	{
		// id=<Switch:<Sequential:<false:false:PLUS:>,<true:true:prefix_expr:e>,<Action: return e; >>,<Sequential:<true:false:MINUS:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Negate); >>,<Sequential:<true:false:PLUS2:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Increase); >>,<Sequential:<true:false:MINUS2:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Decrease); >>,<Sequential:<true:false:ASTERISK2:t>,<true:true:prefix_expr:e>,<Action: return new PreOperatorNode(t.location, e, UnaryOperatorType.Square); >>,<Sequential:<true:true:postfix_expr:e>,<Action: return e; >>>
		private alias PartialTreeType = PartialTree!304;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential298.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential299.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential300.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential301.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential305
	{
		// id=<Sequential:<false:false:PLUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Increase); >>
		private alias PartialTreeType = PartialTree!305;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential306
	{
		// id=<Sequential:<false:false:MINUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Decrease); >>
		private alias PartialTreeType = PartialTree!306;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential307
	{
		// id=<Sequential:<false:false:ASTERISK2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Square); >>
		private alias PartialTreeType = PartialTree!307;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LBR = ElementParser!(EnumTokenType.LBR);
	private alias ElementParser_RBR = ElementParser!(EnumTokenType.RBR);
	private static class ComplexParser_Sequential308
	{
		// id=<Sequential:<false:false:LBR:>,<true:true:expression:d>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, [d]); >>
		private alias PartialTreeType = PartialTree!308;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential309
	{
		// id=<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, null); >>
		private alias PartialTreeType = PartialTree!309;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential310
	{
		// id=<Sequential:<false:false:LP:>,<true:true:expression_list:ps>,<false:false:RP:>,<Action: e = new FuncallNode(e, ps); >>
		private alias PartialTreeType = PartialTree!310;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential311
	{
		// id=<Sequential:<false:false:LP:>,<false:false:RP:>,<Action: e = new FuncallNode(e, null); >>
		private alias PartialTreeType = PartialTree!311;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PERIOD = ElementParser!(EnumTokenType.PERIOD);
	private static class ComplexParser_Sequential312
	{
		// id=<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<true:true:template_tail:tt>,<Action: e = new ObjectRefNode(e, new TemplateInstantiateNode(id.location, id.text, tt)); >>
		private alias PartialTreeType = PartialTree!312;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential313
	{
		// id=<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<Action: e = new ObjectRefNode(e, new IdentifierReferenceNode(id.location, id.text)); >>
		private alias PartialTreeType = PartialTree!313;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_RARROW = ElementParser!(EnumTokenType.RARROW);
	private static class ComplexParser_Sequential314
	{
		// id=<Sequential:<false:false:RARROW:>,<true:true:single_types:st>,<Action: e = new CastingNode(e, st); >>
		private alias PartialTreeType = PartialTree!314;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential315
	{
		// id=<Sequential:<false:false:RARROW:>,<false:false:LP:>,<true:true:restricted_type:rt>,<false:false:RP:>,<Action: e = new CastingNode(e, rt); >>
		private alias PartialTreeType = PartialTree!315;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching316
	{
		// id=<Switch:<Sequential:<false:false:PLUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Increase); >>,<Sequential:<false:false:MINUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Decrease); >>,<Sequential:<false:false:ASTERISK2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Square); >>,<Sequential:<false:false:LBR:>,<true:true:expression:d>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, [d]); >>,<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, null); >>,<Sequential:<false:false:LP:>,<true:true:expression_list:ps>,<false:false:RP:>,<Action: e = new FuncallNode(e, ps); >>,<Sequential:<false:false:LP:>,<false:false:RP:>,<Action: e = new FuncallNode(e, null); >>,<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<true:true:template_tail:tt>,<Action: e = new ObjectRefNode(e, new TemplateInstantiateNode(id.location, id.text, tt)); >>,<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<Action: e = new ObjectRefNode(e, new IdentifierReferenceNode(id.location, id.text)); >>,<Sequential:<false:false:RARROW:>,<true:true:single_types:st>,<Action: e = new CastingNode(e, st); >>,<Sequential:<false:false:RARROW:>,<false:false:LP:>,<true:true:restricted_type:rt>,<false:false:RP:>,<Action: e = new CastingNode(e, rt); >>>
		private alias PartialTreeType = PartialTree!316;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

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

			resTemp = ComplexParser_Sequential308.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential309.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential310.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential311.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified317
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:PLUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Increase); >>,<Sequential:<false:false:MINUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Decrease); >>,<Sequential:<false:false:ASTERISK2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Square); >>,<Sequential:<false:false:LBR:>,<true:true:expression:d>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, [d]); >>,<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, null); >>,<Sequential:<false:false:LP:>,<true:true:expression_list:ps>,<false:false:RP:>,<Action: e = new FuncallNode(e, ps); >>,<Sequential:<false:false:LP:>,<false:false:RP:>,<Action: e = new FuncallNode(e, null); >>,<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<true:true:template_tail:tt>,<Action: e = new ObjectRefNode(e, new TemplateInstantiateNode(id.location, id.text, tt)); >>,<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<Action: e = new ObjectRefNode(e, new IdentifierReferenceNode(id.location, id.text)); >>,<Sequential:<false:false:RARROW:>,<true:true:single_types:st>,<Action: e = new CastingNode(e, st); >>,<Sequential:<false:false:RARROW:>,<false:false:LP:>,<true:true:restricted_type:rt>,<false:false:RP:>,<Action: e = new CastingNode(e, rt); >>>>
		private alias PartialTreeType = PartialTree!317;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching316.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential318
	{
		// id=<Sequential:<true:true:primary_expr:e>,<LoopQualified:false:<Switch:<Sequential:<false:false:PLUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Increase); >>,<Sequential:<false:false:MINUS2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Decrease); >>,<Sequential:<false:false:ASTERISK2:>,<Action: e = new PostOperatorNode(e, UnaryOperatorType.Square); >>,<Sequential:<false:false:LBR:>,<true:true:expression:d>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, [d]); >>,<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: e = new ArrayRefNode(e, null); >>,<Sequential:<false:false:LP:>,<true:true:expression_list:ps>,<false:false:RP:>,<Action: e = new FuncallNode(e, ps); >>,<Sequential:<false:false:LP:>,<false:false:RP:>,<Action: e = new FuncallNode(e, null); >>,<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<true:true:template_tail:tt>,<Action: e = new ObjectRefNode(e, new TemplateInstantiateNode(id.location, id.text, tt)); >>,<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:id>,<Action: e = new ObjectRefNode(e, new IdentifierReferenceNode(id.location, id.text)); >>,<Sequential:<false:false:RARROW:>,<true:true:single_types:st>,<Action: e = new CastingNode(e, st); >>,<Sequential:<false:false:RARROW:>,<false:false:LP:>,<true:true:restricted_type:rt>,<false:false:RP:>,<Action: e = new CastingNode(e, rt); >>>>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!318;
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

			resTemp = ComplexParser_LoopQualified317.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential319
	{
		// id=<Sequential:<true:true:literals:l>,<Action: return l; >>
		private alias PartialTreeType = PartialTree!319;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential320
	{
		// id=<Sequential:<true:true:special_literals:sl>,<Action: return sl; >>
		private alias PartialTreeType = PartialTree!320;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential321
	{
		// id=<Sequential:<true:true:lambda_expr:le>,<Action: return le; >>
		private alias PartialTreeType = PartialTree!321;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential322
	{
		// id=<Sequential:<false:false:LP:>,<true:true:expression:e>,<false:false:RP:>,<Action: return e; >>
		private alias PartialTreeType = PartialTree!322;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_NEW = ElementParser!(EnumTokenType.NEW);
	private static class ComplexParser_Sequential323
	{
		// id=<Sequential:<true:false:NEW:t>,<true:true:type:tp>,<Action: return new NewInstanceNode(t.location, tp); >>
		private alias PartialTreeType = PartialTree!323;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_NEW.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential324
	{
		// id=<Sequential:<true:false:NEW:t>,<true:true:type:tp>,<false:false:LP:>,<true:true:expression_list:ps>,<false:false:RP:>,<Action: return new NewInstanceNode(t.location, tp, ps); >>
		private alias PartialTreeType = PartialTree!324;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_NEW.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential325
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<true:true:template_tail:tt>,<Action: return new TemplateInstantiateNode(id.location, id.text, tt); >>
		private alias PartialTreeType = PartialTree!325;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential326
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<Action: return new IdentifierReferenceNode(id.location, id.text); >>
		private alias PartialTreeType = PartialTree!326;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching327
	{
		// id=<Switch:<Sequential:<true:true:literals:l>,<Action: return l; >>,<Sequential:<true:true:special_literals:sl>,<Action: return sl; >>,<Sequential:<true:true:lambda_expr:le>,<Action: return le; >>,<Sequential:<false:false:LP:>,<true:true:expression:e>,<false:false:RP:>,<Action: return e; >>,<Sequential:<true:false:NEW:t>,<true:true:type:tp>,<Action: return new NewInstanceNode(t.location, tp); >>,<Sequential:<true:false:NEW:t>,<true:true:type:tp>,<false:false:LP:>,<true:true:expression_list:ps>,<false:false:RP:>,<Action: return new NewInstanceNode(t.location, tp, ps); >>,<Sequential:<true:false:IDENTIFIER:id>,<true:true:template_tail:tt>,<Action: return new TemplateInstantiateNode(id.location, id.text, tt); >>,<Sequential:<true:false:IDENTIFIER:id>,<Action: return new IdentifierReferenceNode(id.location, id.text); >>>
		private alias PartialTreeType = PartialTree!327;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential319.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential320.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential321.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential322.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential323.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential324.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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
	private alias ElementParser_INUMBER = ElementParser!(EnumTokenType.INUMBER);
	private static class ComplexParser_Sequential328
	{
		// id=<Sequential:<true:false:INUMBER:t>,<Action: return new IntLiteralNode(t.location, t.text.to!int); >>
		private alias PartialTreeType = PartialTree!328;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_HNUMBER = ElementParser!(EnumTokenType.HNUMBER);
	private static class ComplexParser_Sequential329
	{
		// id=<Sequential:<true:false:HNUMBER:t>,<Action: return new IntLiteralNode(t.location, t.text.to!int(16)); >>
		private alias PartialTreeType = PartialTree!329;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_FNUMBER = ElementParser!(EnumTokenType.FNUMBER);
	private static class ComplexParser_Sequential330
	{
		// id=<Sequential:<true:false:FNUMBER:t>,<Action: return new FloatLiteralNode(t.location, t.text.to!float); >>
		private alias PartialTreeType = PartialTree!330;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_DNUMBER = ElementParser!(EnumTokenType.DNUMBER);
	private static class ComplexParser_Sequential331
	{
		// id=<Sequential:<true:false:DNUMBER:t>,<Action: return new DoubleLiteralNode(t.location, t.text.to!double); >>
		private alias PartialTreeType = PartialTree!331;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_NUMBER = ElementParser!(EnumTokenType.NUMBER);
	private static class ComplexParser_Sequential332
	{
		// id=<Sequential:<true:false:NUMBER:t>,<Action: return new NumericLiteralNode(t.location, t.text.to!real); >>
		private alias PartialTreeType = PartialTree!332;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_STRING = ElementParser!(EnumTokenType.STRING);
	private static class ComplexParser_Sequential333
	{
		// id=<Sequential:<true:false:STRING:t>,<Action: return new StringLiteralNode(t.location, t.text); >>
		private alias PartialTreeType = PartialTree!333;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_CHARACTER = ElementParser!(EnumTokenType.CHARACTER);
	private static class ComplexParser_Sequential334
	{
		// id=<Sequential:<true:false:CHARACTER:t>,<Action: return new CharacterLiteralNode(t.location, t.text[0]); >>
		private alias PartialTreeType = PartialTree!334;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential335
	{
		// id=<Sequential:<true:true:function_literal:fl>,<Action: return fl; >>
		private alias PartialTreeType = PartialTree!335;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential336
	{
		// id=<Sequential:<true:true:array_literal:al>,<Action: return al; >>
		private alias PartialTreeType = PartialTree!336;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching337
	{
		// id=<Switch:<Sequential:<true:false:INUMBER:t>,<Action: return new IntLiteralNode(t.location, t.text.to!int); >>,<Sequential:<true:false:HNUMBER:t>,<Action: return new IntLiteralNode(t.location, t.text.to!int(16)); >>,<Sequential:<true:false:FNUMBER:t>,<Action: return new FloatLiteralNode(t.location, t.text.to!float); >>,<Sequential:<true:false:DNUMBER:t>,<Action: return new DoubleLiteralNode(t.location, t.text.to!double); >>,<Sequential:<true:false:NUMBER:t>,<Action: return new NumericLiteralNode(t.location, t.text.to!real); >>,<Sequential:<true:false:STRING:t>,<Action: return new StringLiteralNode(t.location, t.text); >>,<Sequential:<true:false:CHARACTER:t>,<Action: return new CharacterLiteralNode(t.location, t.text[0]); >>,<Sequential:<true:true:function_literal:fl>,<Action: return fl; >>,<Sequential:<true:true:array_literal:al>,<Action: return al; >>>
		private alias PartialTreeType = PartialTree!337;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential328.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential329.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential330.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential331.parse(r);
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

			resTemp = ComplexParser_Sequential333.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential334.parse(r);
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

			resTemp = ComplexParser_Sequential336.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_FUNCTION = ElementParser!(EnumTokenType.FUNCTION);
	private static class ComplexParser_Sequential338
	{
		// id=<Sequential:<true:false:FUNCTION:f>,<false:false:LP:>,<true:true:literal_varg_list:vl>,<false:false:RP:>,<true:true:block_stmt:bs>,<Action: return new FunctionLiteralNode(f.location, vl, bs); >>
		private alias PartialTreeType = PartialTree!338;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential339
	{
		// id=<Sequential:<true:false:FUNCTION:f>,<false:false:LP:>,<false:false:RP:>,<true:true:block_stmt:bs>,<Action: return new FunctionLiteralNode(f.location, null, bs); >>
		private alias PartialTreeType = PartialTree!339;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching340
	{
		// id=<Switch:<Sequential:<true:false:FUNCTION:f>,<false:false:LP:>,<true:true:literal_varg_list:vl>,<false:false:RP:>,<true:true:block_stmt:bs>,<Action: return new FunctionLiteralNode(f.location, vl, bs); >>,<Sequential:<true:false:FUNCTION:f>,<false:false:LP:>,<false:false:RP:>,<true:true:block_stmt:bs>,<Action: return new FunctionLiteralNode(f.location, null, bs); >>>
		private alias PartialTreeType = PartialTree!340;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential338.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential339.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential341
	{
		// id=<Sequential:<true:false:LBR:ft>,<true:true:expression_list:el>,<false:false:RBR:>,<Action: return new ArrayLiteralNode(ft.location, el); >>
		private alias PartialTreeType = PartialTree!341;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential342
	{
		// id=<Sequential:<true:false:LBR:ft>,<true:true:assoc_array_element_list:el>,<false:false:RBR:>,<Action: return new AssocArrayLiteralNode(ft.location, el); >>
		private alias PartialTreeType = PartialTree!342;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential343
	{
		// id=<Sequential:<true:false:LBR:ft>,<false:false:RBR:>,<Action: return new ArrayLiteralNode(ft.location, null); >>
		private alias PartialTreeType = PartialTree!343;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching344
	{
		// id=<Switch:<Sequential:<true:false:LBR:ft>,<true:true:expression_list:el>,<false:false:RBR:>,<Action: return new ArrayLiteralNode(ft.location, el); >>,<Sequential:<true:false:LBR:ft>,<true:true:assoc_array_element_list:el>,<false:false:RBR:>,<Action: return new AssocArrayLiteralNode(ft.location, el); >>,<Sequential:<true:false:LBR:ft>,<false:false:RBR:>,<Action: return new ArrayLiteralNode(ft.location, null); >>>
		private alias PartialTreeType = PartialTree!344;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential341.parse(r);
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

			resTemp = ComplexParser_Sequential343.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential345
	{
		// id=<Sequential:<true:false:THIS:t>,<Action: return new ThisReferenceNode(t.location); >>
		private alias PartialTreeType = PartialTree!345;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_SUPER = ElementParser!(EnumTokenType.SUPER);
	private static class ComplexParser_Sequential346
	{
		// id=<Sequential:<true:false:SUPER:t>,<Action: return new SuperReferenceNode(t.location); >>
		private alias PartialTreeType = PartialTree!346;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_TRUE = ElementParser!(EnumTokenType.TRUE);
	private static class ComplexParser_Sequential347
	{
		// id=<Sequential:<true:false:TRUE:t>,<Action: return new BooleanLiteralNode(t.location, true); >>
		private alias PartialTreeType = PartialTree!347;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_FALSE = ElementParser!(EnumTokenType.FALSE);
	private static class ComplexParser_Sequential348
	{
		// id=<Sequential:<true:false:FALSE:t>,<Action: return new BooleanLiteralNode(t.location, false); >>
		private alias PartialTreeType = PartialTree!348;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_NULL = ElementParser!(EnumTokenType.NULL);
	private static class ComplexParser_Sequential349
	{
		// id=<Sequential:<true:false:NULL:t>,<Action: return new NullLiteralNode(t.location); >>
		private alias PartialTreeType = PartialTree!349;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching350
	{
		// id=<Switch:<Sequential:<true:false:THIS:t>,<Action: return new ThisReferenceNode(t.location); >>,<Sequential:<true:false:SUPER:t>,<Action: return new SuperReferenceNode(t.location); >>,<Sequential:<true:false:TRUE:t>,<Action: return new BooleanLiteralNode(t.location, true); >>,<Sequential:<true:false:FALSE:t>,<Action: return new BooleanLiteralNode(t.location, false); >>,<Sequential:<true:false:NULL:t>,<Action: return new NullLiteralNode(t.location); >>>
		private alias PartialTreeType = PartialTree!350;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential345.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential346.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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
	private static class ComplexParser_Sequential351
	{
		// id=<Sequential:<true:false:LP:t>,<true:true:literal_varg_list:ps>,<false:false:RP:>,<false:false:RARROW2:>,<true:true:expression:e>,<Action: return new FunctionLiteralNode(t.location, ps, e); >>
		private alias PartialTreeType = PartialTree!351;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential352
	{
		// id=<Sequential:<true:false:LP:t>,<false:false:RP:>,<false:false:RARROW2:>,<true:true:expression:e>,<Action: return new FunctionLiteralNode(t.location, null, e); >>
		private alias PartialTreeType = PartialTree!352;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential353
	{
		// id=<Sequential:<true:true:literal_varg:vp>,<false:false:RARROW2:>,<true:true:expression:e>,<Action: return new FunctionLiteralNode(vp, e); >>
		private alias PartialTreeType = PartialTree!353;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching354
	{
		// id=<Switch:<Sequential:<true:false:LP:t>,<true:true:literal_varg_list:ps>,<false:false:RP:>,<false:false:RARROW2:>,<true:true:expression:e>,<Action: return new FunctionLiteralNode(t.location, ps, e); >>,<Sequential:<true:false:LP:t>,<false:false:RP:>,<false:false:RARROW2:>,<true:true:expression:e>,<Action: return new FunctionLiteralNode(t.location, null, e); >>,<Sequential:<true:true:literal_varg:vp>,<false:false:RARROW2:>,<true:true:expression:e>,<Action: return new FunctionLiteralNode(vp, e); >>>
		private alias PartialTreeType = PartialTree!354;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential351.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential352.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential353.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential355
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:template_arg:p2>,<Action: params ~= p2; >>
		private alias PartialTreeType = PartialTree!355;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified356
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:template_arg:p2>,<Action: params ~= p2; >>>
		private alias PartialTreeType = PartialTree!356;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential355.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential357
	{
		// id=<Sequential:<Action: TemplateVirtualParamNode[] params; >,<true:true:template_arg:p>,<Action: params ~= p; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:template_arg:p2>,<Action: params ~= p2; >>>,<Action: return params; >>
		private alias PartialTreeType = PartialTree!357;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = template_arg.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified356.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential358
	{
		// id=<Sequential:<false:false:EQUAL:>,<true:true:type:t>,<Action: head = new TemplateVirtualParamNode(head, t); >>
		private alias PartialTreeType = PartialTree!358;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified359
	{
		// id=<LoopQualified:false:<Sequential:<false:false:EQUAL:>,<true:true:type:t>,<Action: head = new TemplateVirtualParamNode(head, t); >>>
		private alias PartialTreeType = PartialTree!359;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential358.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential360
	{
		// id=<Sequential:<true:true:template_arg_head:head>,<LoopQualified:false:<Sequential:<false:false:EQUAL:>,<true:true:type:t>,<Action: head = new TemplateVirtualParamNode(head, t); >>>,<Action: return head; >>
		private alias PartialTreeType = PartialTree!360;
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

			resTemp = ComplexParser_LoopQualified359.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential361
	{
		// id=<Sequential:<true:true:type:t>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.Type, t, t.location); >>
		private alias PartialTreeType = PartialTree!361;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential362
	{
		// id=<Sequential:<true:false:CLASS:tk>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.Class, null, tk.location); >>
		private alias PartialTreeType = PartialTree!362;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_ALIAS = ElementParser!(EnumTokenType.ALIAS);
	private static class ComplexParser_Sequential363
	{
		// id=<Sequential:<true:false:ALIAS:tk>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.SymbolAlias, null, tk.location); >>
		private alias PartialTreeType = PartialTree!363;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching364
	{
		// id=<Switch:<Sequential:<true:true:type:t>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.Type, t, t.location); >>,<Sequential:<true:false:CLASS:tk>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.Class, null, tk.location); >>,<Sequential:<true:false:ALIAS:tk>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.SymbolAlias, null, tk.location); >>>
		private alias PartialTreeType = PartialTree!364;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential361.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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
		// id=<Sequential:<Action: alias ReturnType = Tuple!(TemplateVirtualParamNode.ParamType, "type", TypeNode, "stype", Location, "location"); >,<Switch:<Sequential:<true:true:type:t>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.Type, t, t.location); >>,<Sequential:<true:false:CLASS:tk>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.Class, null, tk.location); >>,<Sequential:<true:false:ALIAS:tk>,<Action: return ReturnType(TemplateVirtualParamNode.ParamType.SymbolAlias, null, tk.location); >>>>
		private alias PartialTreeType = PartialTree!365;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_Switching364.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential366
	{
		// id=<Sequential:<true:true:template_arg_type:type>,<true:false:IDENTIFIER:id>,<Action: return new TemplateVirtualParamNode(type.location, type.type, type.stype, id.text); >>
		private alias PartialTreeType = PartialTree!366;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential367
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<Action: return new TemplateVirtualParamNode(id.location, TemplateVirtualParamNode.ParamType.Any, null, id.text); >>
		private alias PartialTreeType = PartialTree!367;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching368
	{
		// id=<Switch:<Sequential:<true:true:template_arg_type:type>,<true:false:IDENTIFIER:id>,<Action: return new TemplateVirtualParamNode(type.location, type.type, type.stype, id.text); >>,<Sequential:<true:false:IDENTIFIER:id>,<Action: return new TemplateVirtualParamNode(id.location, TemplateVirtualParamNode.ParamType.Any, null, id.text); >>>
		private alias PartialTreeType = PartialTree!368;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential366.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential367.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential369
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:varg:v>,<Action: params ~= v; >>
		private alias PartialTreeType = PartialTree!369;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified370
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:varg:v>,<Action: params ~= v; >>>
		private alias PartialTreeType = PartialTree!370;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential369.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential371
	{
		// id=<Sequential:<Action: VirtualParamNode params[]; >,<true:true:varg:t>,<Action: params ~= t; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:varg:v>,<Action: params ~= v; >>>,<Action: return params; >>
		private alias PartialTreeType = PartialTree!371;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = varg.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified370.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PERIOD3 = ElementParser!(EnumTokenType.PERIOD3);
	private static class ComplexParser_Sequential372
	{
		// id=<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<false:false:EQUAL:>,<true:true:expression:dv>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, n.text, dv, true); >>
		private alias PartialTreeType = PartialTree!372;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential373
	{
		// id=<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<false:false:EQUAL:>,<true:true:expression:dv>,<Action: return new VirtualParamNode(t, n.text, dv, false); >>
		private alias PartialTreeType = PartialTree!373;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential374
	{
		// id=<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, n.text, null, true); >>
		private alias PartialTreeType = PartialTree!374;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential375
	{
		// id=<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<Action: return new VirtualParamNode(t, n.text, null, false); >>
		private alias PartialTreeType = PartialTree!375;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential376
	{
		// id=<Sequential:<true:true:type:t>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, null, null, true); >>
		private alias PartialTreeType = PartialTree!376;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential377
	{
		// id=<Sequential:<true:true:type:t>,<Action: return new VirtualParamNode(t, null, null, false); >>
		private alias PartialTreeType = PartialTree!377;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching378
	{
		// id=<Switch:<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<false:false:EQUAL:>,<true:true:expression:dv>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, n.text, dv, true); >>,<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<false:false:EQUAL:>,<true:true:expression:dv>,<Action: return new VirtualParamNode(t, n.text, dv, false); >>,<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, n.text, null, true); >>,<Sequential:<true:true:type:t>,<true:false:IDENTIFIER:n>,<Action: return new VirtualParamNode(t, n.text, null, false); >>,<Sequential:<true:true:type:t>,<false:false:PERIOD3:>,<Action: return new VirtualParamNode(t, null, null, true); >>,<Sequential:<true:true:type:t>,<Action: return new VirtualParamNode(t, null, null, false); >>>
		private alias PartialTreeType = PartialTree!378;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential372.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential373.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

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

			resTemp = ComplexParser_Sequential376.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential377.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential379
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:literal_varg:p2>,<Action: params ~= p2; >>
		private alias PartialTreeType = PartialTree!379;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified380
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:literal_varg:p2>,<Action: params ~= p2; >>>
		private alias PartialTreeType = PartialTree!380;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential379.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential381
	{
		// id=<Sequential:<Action: VirtualParamNode[] params; >,<true:true:literal_varg:p1>,<Action: params ~= p1; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:literal_varg:p2>,<Action: params ~= p2; >>>,<Action: return params; >>
		private alias PartialTreeType = PartialTree!381;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = literal_varg.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified380.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential382
	{
		// id=<Sequential:<true:true:type:t>,<Action: at = t; >>
		private alias PartialTreeType = PartialTree!382;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable383
	{
		// id=<Skippable:<Sequential:<true:true:type:t>,<Action: at = t; >>>
		private alias PartialTreeType = PartialTree!383;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential382.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential384
	{
		// id=<Sequential:<false:false:EQUAL:>,<true:true:expression:e>,<Action: dv = e; >>
		private alias PartialTreeType = PartialTree!384;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable385
	{
		// id=<Skippable:<Sequential:<false:false:EQUAL:>,<true:true:expression:e>,<Action: dv = e; >>>
		private alias PartialTreeType = PartialTree!385;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential384.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential386
	{
		// id=<Sequential:<false:false:PERIOD3:>,<Action: isVariant = true; >>
		private alias PartialTreeType = PartialTree!386;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;

			resTemp = ElementParser_PERIOD3.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable387
	{
		// id=<Skippable:<Sequential:<false:false:PERIOD3:>,<Action: isVariant = true; >>>
		private alias PartialTreeType = PartialTree!387;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential386.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential388
	{
		// id=<Sequential:<Action: TypeNode at = null; ExpressionNode dv = null; bool isVariant = false; >,<Skippable:<Sequential:<true:true:type:t>,<Action: at = t; >>>,<true:false:IDENTIFIER:id>,<Skippable:<Sequential:<false:false:EQUAL:>,<true:true:expression:e>,<Action: dv = e; >>>,<Skippable:<Sequential:<false:false:PERIOD3:>,<Action: isVariant = true; >>>,<Action: return new VirtualParamNode(at !is null ? at : new InferenceTypeNode(id.location), id.text, dv, isVariant); >>
		private alias PartialTreeType = PartialTree!388;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_Skippable383.parse(r);
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

			resTemp = ComplexParser_Skippable385.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable387.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential389
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:assoc_array_element:n2>,<Action: nodes ~= n2; >>
		private alias PartialTreeType = PartialTree!389;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified390
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:assoc_array_element:n2>,<Action: nodes ~= n2; >>>
		private alias PartialTreeType = PartialTree!390;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential389.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential391
	{
		// id=<Sequential:<Action: AssocArrayElementNode[] nodes; >,<true:true:assoc_array_element:n>,<Action: nodes ~= n; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:assoc_array_element:n2>,<Action: nodes ~= n2; >>>,<Action: return nodes; >>
		private alias PartialTreeType = PartialTree!391;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = assoc_array_element.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified390.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential392
	{
		// id=<Sequential:<true:true:expression:k>,<false:false:COLON:>,<true:true:expression:v>,<Action: return new AssocArrayElementNode(k, v); >>
		private alias PartialTreeType = PartialTree!392;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PUBLIC = ElementParser!(EnumTokenType.PUBLIC);
	private static class ComplexParser_Sequential393
	{
		// id=<Sequential:<true:false:PUBLIC:t>,<Action: return Qualifier(t.location, Qualifiers.Public); >>
		private alias PartialTreeType = PartialTree!393;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PRIVATE = ElementParser!(EnumTokenType.PRIVATE);
	private static class ComplexParser_Sequential394
	{
		// id=<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>
		private alias PartialTreeType = PartialTree!394;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_FINAL = ElementParser!(EnumTokenType.FINAL);
	private static class ComplexParser_Sequential395
	{
		// id=<Sequential:<true:false:FINAL:t>,<Action: return Qualifier(t.location, Qualifiers.Final); >>
		private alias PartialTreeType = PartialTree!395;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_STATIC = ElementParser!(EnumTokenType.STATIC);
	private static class ComplexParser_Sequential396
	{
		// id=<Sequential:<true:false:STATIC:t>,<Action: return Qualifier(t.location, Qualifiers.Static); >>
		private alias PartialTreeType = PartialTree!396;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching397
	{
		// id=<Switch:<Sequential:<true:false:PUBLIC:t>,<Action: return Qualifier(t.location, Qualifiers.Public); >>,<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>,<Sequential:<true:false:FINAL:t>,<Action: return Qualifier(t.location, Qualifiers.Final); >>,<Sequential:<true:false:STATIC:t>,<Action: return Qualifier(t.location, Qualifiers.Static); >>>
		private alias PartialTreeType = PartialTree!397;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential393.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential394.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential395.parse(r);
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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Switching398
	{
		// id=<Switch:<Sequential:<true:false:PUBLIC:t>,<Action: return Qualifier(t.location, Qualifiers.Public); >>,<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>,<Sequential:<true:false:STATIC:t>,<Action: return Qualifier(t.location, Qualifiers.Static); >>>
		private alias PartialTreeType = PartialTree!398;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential393.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential394.parse(r);
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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Switching399
	{
		// id=<Switch:<Sequential:<true:false:PUBLIC:t>,<Action: return Qualifier(t.location, Qualifiers.Public); >>,<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>>
		private alias PartialTreeType = PartialTree!399;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential393.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential394.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential400
	{
		// id=<Sequential:<true:false:CONST:t>,<Action: return Qualifier(t.location, Qualifiers.Const); >>
		private alias PartialTreeType = PartialTree!400;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_PROTECTED = ElementParser!(EnumTokenType.PROTECTED);
	private static class ComplexParser_Sequential401
	{
		// id=<Sequential:<true:false:PROTECTED:t>,<Action: return Qualifier(t.location, Qualifiers.Protected); >>
		private alias PartialTreeType = PartialTree!401;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching402
	{
		// id=<Switch:<Sequential:<true:false:PUBLIC:t>,<Action: return Qualifier(t.location, Qualifiers.Public); >>,<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>,<Sequential:<true:false:PROTECTED:t>,<Action: return Qualifier(t.location, Qualifiers.Protected); >>,<Sequential:<true:false:STATIC:t>,<Action: return Qualifier(t.location, Qualifiers.Static); >>,<Sequential:<true:false:FINAL:t>,<Action: return Qualifier(t.location, Qualifiers.Final); >>,<Sequential:<true:false:CONST:t>,<Action: return Qualifier(t.location, Qualifiers.Const); >>>
		private alias PartialTreeType = PartialTree!402;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential393.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential394.parse(r);
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

			resTemp = ComplexParser_Sequential396.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential395.parse(r);
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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_OVERRIDE = ElementParser!(EnumTokenType.OVERRIDE);
	private static class ComplexParser_Sequential403
	{
		// id=<Sequential:<true:false:OVERRIDE:t>,<Action: return Qualifier(t.location, Qualifiers.Override); >>
		private alias PartialTreeType = PartialTree!403;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching404
	{
		// id=<Switch:<Sequential:<true:false:PUBLIC:t>,<Action: return Qualifier(t.location, Qualifiers.Public); >>,<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>,<Sequential:<true:false:PROTECTED:t>,<Action: return Qualifier(t.location, Qualifiers.Protected); >>,<Sequential:<true:false:STATIC:t>,<Action: return Qualifier(t.location, Qualifiers.Static); >>,<Sequential:<true:false:FINAL:t>,<Action: return Qualifier(t.location, Qualifiers.Final); >>,<Sequential:<true:false:CONST:t>,<Action: return Qualifier(t.location, Qualifiers.Const); >>,<Sequential:<true:false:OVERRIDE:t>,<Action: return Qualifier(t.location, Qualifiers.Override); >>>
		private alias PartialTreeType = PartialTree!404;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential393.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential394.parse(r);
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

			resTemp = ComplexParser_Sequential396.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential395.parse(r);
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

			resTemp = ComplexParser_Sequential403.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Switching405
	{
		// id=<Switch:<Sequential:<true:false:PUBLIC:t>,<Action: return Qualifier(t.location, Qualifiers.Public); >>,<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>,<Sequential:<true:false:PROTECTED:t>,<Action: return Qualifier(t.location, Qualifiers.Protected); >>,<Sequential:<true:false:CONST:t>,<Action: return Qualifier(t.location, Qualifiers.Const); >>>
		private alias PartialTreeType = PartialTree!405;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential393.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential394.parse(r);
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

			resTemp = ComplexParser_Sequential400.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Switching406
	{
		// id=<Switch:<Sequential:<true:false:PRIVATE:t>,<Action: return Qualifier(t.location, Qualifiers.Private); >>,<Sequential:<true:false:PROTECTED:t>,<Action: return Qualifier(t.location, Qualifiers.Protected); >>,<Sequential:<true:false:CONST:t>,<Action: return Qualifier(t.location, Qualifiers.Const); >>,<Sequential:<true:false:STATIC:t>,<Action: return Qualifier(t.location, Qualifiers.Static); >>>
		private alias PartialTreeType = PartialTree!406;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential394.parse(r);
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

			resTemp = ComplexParser_Sequential400.parse(r);
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
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential407
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<false:false:LBR:>,<true:true:def_id_arg_list:params>,<false:false:RBR:>,<Action: return new DefinitionIdentifierNode(id.location, id.text, params); >>
		private alias PartialTreeType = PartialTree!407;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential408
	{
		// id=<Sequential:<false:false:LBR:>,<false:false:RBR:>>
		private alias PartialTreeType = PartialTree!408;
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
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable409
	{
		// id=<Skippable:<Sequential:<false:false:LBR:>,<false:false:RBR:>>>
		private alias PartialTreeType = PartialTree!409;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential408.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential410
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<Skippable:<Sequential:<false:false:LBR:>,<false:false:RBR:>>>,<Action: return new DefinitionIdentifierNode(id.location, id.text, null); >>
		private alias PartialTreeType = PartialTree!410;
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

			resTemp = ComplexParser_Skippable409.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching411
	{
		// id=<Switch:<Sequential:<true:false:IDENTIFIER:id>,<false:false:LBR:>,<true:true:def_id_arg_list:params>,<false:false:RBR:>,<Action: return new DefinitionIdentifierNode(id.location, id.text, params); >>,<Sequential:<true:false:IDENTIFIER:id>,<Skippable:<Sequential:<false:false:LBR:>,<false:false:RBR:>>>,<Action: return new DefinitionIdentifierNode(id.location, id.text, null); >>>
		private alias PartialTreeType = PartialTree!411;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential407.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential410.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential412
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:def_id_arg:second_t>,<Action: nodes ~= second_t; >>
		private alias PartialTreeType = PartialTree!412;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified413
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:def_id_arg:second_t>,<Action: nodes ~= second_t; >>>
		private alias PartialTreeType = PartialTree!413;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential412.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential414
	{
		// id=<Sequential:<Action: DefinitionIdentifierParamNode[] nodes; >,<true:true:def_id_arg:first_t>,<Action: nodes ~= first_t; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:def_id_arg:second_t>,<Action: nodes ~= second_t; >>>,<Action: return nodes; >>
		private alias PartialTreeType = PartialTree!414;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = def_id_arg.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified413.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential415
	{
		// id=<Sequential:<false:false:EQUAL:>,<true:true:type:t>,<Action: n = n.withDefaultValue(t); >>
		private alias PartialTreeType = PartialTree!415;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential416
	{
		// id=<Sequential:<false:false:COLON:>,<true:true:type:t>,<Action: n = n.withExtendedFrom(t); >>
		private alias PartialTreeType = PartialTree!416;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential417
	{
		// id=<Sequential:<false:false:RARROW:>,<true:true:type:t>,<Action: n = n.withCastableTo(t); >>
		private alias PartialTreeType = PartialTree!417;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching418
	{
		// id=<Switch:<Sequential:<false:false:EQUAL:>,<true:true:type:t>,<Action: n = n.withDefaultValue(t); >>,<Sequential:<false:false:COLON:>,<true:true:type:t>,<Action: n = n.withExtendedFrom(t); >>,<Sequential:<false:false:RARROW:>,<true:true:type:t>,<Action: n = n.withCastableTo(t); >>>
		private alias PartialTreeType = PartialTree!418;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential415.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential416.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential417.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified419
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:EQUAL:>,<true:true:type:t>,<Action: n = n.withDefaultValue(t); >>,<Sequential:<false:false:COLON:>,<true:true:type:t>,<Action: n = n.withExtendedFrom(t); >>,<Sequential:<false:false:RARROW:>,<true:true:type:t>,<Action: n = n.withCastableTo(t); >>>>
		private alias PartialTreeType = PartialTree!419;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching418.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential420
	{
		// id=<Sequential:<true:true:def_id_argname:n>,<LoopQualified:false:<Switch:<Sequential:<false:false:EQUAL:>,<true:true:type:t>,<Action: n = n.withDefaultValue(t); >>,<Sequential:<false:false:COLON:>,<true:true:type:t>,<Action: n = n.withExtendedFrom(t); >>,<Sequential:<false:false:RARROW:>,<true:true:type:t>,<Action: n = n.withCastableTo(t); >>>>,<Action: return n; >>
		private alias PartialTreeType = PartialTree!420;
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

			resTemp = ComplexParser_LoopQualified419.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential421
	{
		// id=<Sequential:<true:false:IDENTIFIER:t>,<Action: return new DefinitionIdentifierParamNode(t.location, t.text); >>
		private alias PartialTreeType = PartialTree!421;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential422
	{
		// id=<Sequential:<true:true:type_qualifier:tqq>,<Action: tq = tq.combine(tqq); hasQualifier = true; >>
		private alias PartialTreeType = PartialTree!422;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified423
	{
		// id=<LoopQualified:false:<Sequential:<true:true:type_qualifier:tqq>,<Action: tq = tq.combine(tqq); hasQualifier = true; >>>
		private alias PartialTreeType = PartialTree!423;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential422.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential424
	{
		// id=<Sequential:<Action: auto tq = Qualifier(Location(int.max, int.max), 0); bool hasQualifier = false; >,<LoopQualified:false:<Sequential:<true:true:type_qualifier:tqq>,<Action: tq = tq.combine(tqq); hasQualifier = true; >>>,<true:true:type_body:tb>,<Action: return hasQualifier ? new QualifiedTypeNode(tq, tb) : tb; >>
		private alias PartialTreeType = PartialTree!424;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified423.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential425
	{
		// id=<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<true:true:varg_list:vpl>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, vpl); >>
		private alias PartialTreeType = PartialTree!425;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential426
	{
		// id=<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, null); >>
		private alias PartialTreeType = PartialTree!426;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching427
	{
		// id=<Switch:<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<true:true:varg_list:vpl>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, vpl); >>,<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, null); >>>
		private alias PartialTreeType = PartialTree!427;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential425.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential426.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Skippable428
	{
		// id=<Skippable:<Switch:<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<true:true:varg_list:vpl>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, vpl); >>,<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, null); >>>>
		private alias PartialTreeType = PartialTree!428;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Switching427.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential429
	{
		// id=<Sequential:<true:true:type_body_base:tbb>,<Skippable:<Switch:<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<true:true:varg_list:vpl>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, vpl); >>,<Sequential:<false:false:FUNCTION:>,<false:false:LP:>,<false:false:RP:>,<Action: tbb = new FunctionTypeNode(tbb, null); >>>>,<Action: return tbb; >>
		private alias PartialTreeType = PartialTree!429;
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

			resTemp = ComplexParser_Skippable428.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_AUTO = ElementParser!(EnumTokenType.AUTO);
	private static class ComplexParser_Sequential430
	{
		// id=<Sequential:<true:false:AUTO:a>,<Action: return new InferenceTypeNode(a.location); >>
		private alias PartialTreeType = PartialTree!430;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential431
	{
		// id=<Sequential:<true:true:restricted_type:rt>,<Action: return rt; >>
		private alias PartialTreeType = PartialTree!431;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching432
	{
		// id=<Switch:<Sequential:<true:false:AUTO:a>,<Action: return new InferenceTypeNode(a.location); >>,<Sequential:<true:true:restricted_type:rt>,<Action: return rt; >>>
		private alias PartialTreeType = PartialTree!432;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential430.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential431.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential433
	{
		// id=<Sequential:<false:false:LBR:>,<true:true:expression:e>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, e); >>
		private alias PartialTreeType = PartialTree!433;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential434
	{
		// id=<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, null); >>
		private alias PartialTreeType = PartialTree!434;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching435
	{
		// id=<Switch:<Sequential:<false:false:LBR:>,<true:true:expression:e>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, e); >>,<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, null); >>>
		private alias PartialTreeType = PartialTree!435;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential433.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential434.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_LoopQualified436
	{
		// id=<LoopQualified:false:<Switch:<Sequential:<false:false:LBR:>,<true:true:expression:e>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, e); >>,<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, null); >>>>
		private alias PartialTreeType = PartialTree!436;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Switching435.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential437
	{
		// id=<Sequential:<true:true:primitive_types:pt>,<LoopQualified:false:<Switch:<Sequential:<false:false:LBR:>,<true:true:expression:e>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, e); >>,<Sequential:<false:false:LBR:>,<false:false:RBR:>,<Action: pt = new ArrayTypeNode(pt, null); >>>>,<Action: return pt; >>
		private alias PartialTreeType = PartialTree!437;
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

			resTemp = ComplexParser_LoopQualified436.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential438
	{
		// id=<Sequential:<true:true:register_types:rt>,<Action: return rt; >>
		private alias PartialTreeType = PartialTree!438;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential439
	{
		// id=<Sequential:<true:true:template_instance:ti>,<Action: tnode = ti; >>
		private alias PartialTreeType = PartialTree!439;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential440
	{
		// id=<Sequential:<true:true:__typeof:to>,<Action: tnode = to; >>
		private alias PartialTreeType = PartialTree!440;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching441
	{
		// id=<Switch:<Sequential:<true:true:template_instance:ti>,<Action: tnode = ti; >>,<Sequential:<true:true:__typeof:to>,<Action: tnode = to; >>>
		private alias PartialTreeType = PartialTree!441;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential439.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential440.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential442
	{
		// id=<Sequential:<false:false:PERIOD:>,<true:true:template_instance:tint>,<Action: tnode = new TypeScopeResolverNode(tnode, tint); >>
		private alias PartialTreeType = PartialTree!442;
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

			resTemp = template_instance.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified443
	{
		// id=<LoopQualified:false:<Sequential:<false:false:PERIOD:>,<true:true:template_instance:tint>,<Action: tnode = new TypeScopeResolverNode(tnode, tint); >>>
		private alias PartialTreeType = PartialTree!443;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential442.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential444
	{
		// id=<Sequential:<Action: TypeNode tnode; >,<Switch:<Sequential:<true:true:template_instance:ti>,<Action: tnode = ti; >>,<Sequential:<true:true:__typeof:to>,<Action: tnode = to; >>>,<LoopQualified:false:<Sequential:<false:false:PERIOD:>,<true:true:template_instance:tint>,<Action: tnode = new TypeScopeResolverNode(tnode, tint); >>>,<Action: return tnode; >>
		private alias PartialTreeType = PartialTree!444;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_Switching441.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_LoopQualified443.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching445
	{
		// id=<Switch:<Sequential:<true:true:register_types:rt>,<Action: return rt; >>,<Sequential:<Action: TypeNode tnode; >,<Switch:<Sequential:<true:true:template_instance:ti>,<Action: tnode = ti; >>,<Sequential:<true:true:__typeof:to>,<Action: tnode = to; >>>,<LoopQualified:false:<Sequential:<false:false:PERIOD:>,<true:true:template_instance:tint>,<Action: tnode = new TypeScopeResolverNode(tnode, tint); >>>,<Action: return tnode; >>>
		private alias PartialTreeType = PartialTree!445;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential438.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential444.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private alias ElementParser_TYPEOF = ElementParser!(EnumTokenType.TYPEOF);
	private static class ComplexParser_Sequential446
	{
		// id=<Sequential:<true:true:expression:e>,<false:false:RP:>,<Action: return new TypeofNode(f.location, e); >>
		private alias PartialTreeType = PartialTree!446;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential447
	{
		// id=<Sequential:<true:true:restricted_type:rt>,<false:false:RP:>,<Action: return new TypeofNode(f.location, rt); >>
		private alias PartialTreeType = PartialTree!447;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching448
	{
		// id=<Switch:<Sequential:<true:true:expression:e>,<false:false:RP:>,<Action: return new TypeofNode(f.location, e); >>,<Sequential:<true:true:restricted_type:rt>,<false:false:RP:>,<Action: return new TypeofNode(f.location, rt); >>>
		private alias PartialTreeType = PartialTree!448;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential446.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential447.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential449
	{
		// id=<Sequential:<true:false:TYPEOF:f>,<false:false:LP:>,<Switch:<Sequential:<true:true:expression:e>,<false:false:RP:>,<Action: return new TypeofNode(f.location, e); >>,<Sequential:<true:true:restricted_type:rt>,<false:false:RP:>,<Action: return new TypeofNode(f.location, rt); >>>>
		private alias PartialTreeType = PartialTree!449;
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

			resTemp = ComplexParser_Switching448.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_VOID = ElementParser!(EnumTokenType.VOID);
	private static class ComplexParser_Sequential450
	{
		// id=<Sequential:<true:false:VOID:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Void); >>
		private alias PartialTreeType = PartialTree!450;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_CHAR = ElementParser!(EnumTokenType.CHAR);
	private static class ComplexParser_Sequential451
	{
		// id=<Sequential:<true:false:CHAR:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Char); >>
		private alias PartialTreeType = PartialTree!451;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_UCHAR = ElementParser!(EnumTokenType.UCHAR);
	private static class ComplexParser_Sequential452
	{
		// id=<Sequential:<true:false:UCHAR:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Uchar); >>
		private alias PartialTreeType = PartialTree!452;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_BYTE = ElementParser!(EnumTokenType.BYTE);
	private static class ComplexParser_Sequential453
	{
		// id=<Sequential:<true:false:BYTE:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Byte); >>
		private alias PartialTreeType = PartialTree!453;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_SHORT = ElementParser!(EnumTokenType.SHORT);
	private static class ComplexParser_Sequential454
	{
		// id=<Sequential:<true:false:SHORT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Short); >>
		private alias PartialTreeType = PartialTree!454;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_USHORT = ElementParser!(EnumTokenType.USHORT);
	private static class ComplexParser_Sequential455
	{
		// id=<Sequential:<true:false:USHORT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Ushort); >>
		private alias PartialTreeType = PartialTree!455;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_INT = ElementParser!(EnumTokenType.INT);
	private static class ComplexParser_Sequential456
	{
		// id=<Sequential:<true:false:INT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Int); >>
		private alias PartialTreeType = PartialTree!456;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_UINT = ElementParser!(EnumTokenType.UINT);
	private static class ComplexParser_Sequential457
	{
		// id=<Sequential:<true:false:UINT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Uint); >>
		private alias PartialTreeType = PartialTree!457;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_LONG = ElementParser!(EnumTokenType.LONG);
	private static class ComplexParser_Sequential458
	{
		// id=<Sequential:<true:false:LONG:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Long); >>
		private alias PartialTreeType = PartialTree!458;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_ULONG = ElementParser!(EnumTokenType.ULONG);
	private static class ComplexParser_Sequential459
	{
		// id=<Sequential:<true:false:ULONG:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Ulong); >>
		private alias PartialTreeType = PartialTree!459;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching460
	{
		// id=<Switch:<Sequential:<true:false:VOID:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Void); >>,<Sequential:<true:false:CHAR:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Char); >>,<Sequential:<true:false:UCHAR:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Uchar); >>,<Sequential:<true:false:BYTE:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Byte); >>,<Sequential:<true:false:SHORT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Short); >>,<Sequential:<true:false:USHORT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Ushort); >>,<Sequential:<true:false:INT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Int); >>,<Sequential:<true:false:UINT:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Uint); >>,<Sequential:<true:false:LONG:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Long); >>,<Sequential:<true:false:ULONG:t>,<Action: return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Ulong); >>>
		private alias PartialTreeType = PartialTree!460;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential450.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential451.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential452.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential453.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential454.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential455.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential456.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential457.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential458.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential459.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential461
	{
		// id=<Sequential:<true:true:template_tail:v>,<Action: return new TemplateInstanceTypeNode(t.location, t.text, v); >>
		private alias PartialTreeType = PartialTree!461;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Skippable462
	{
		// id=<Skippable:<Sequential:<true:true:template_tail:v>,<Action: return new TemplateInstanceTypeNode(t.location, t.text, v); >>>
		private alias PartialTreeType = PartialTree!462;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Sequential461.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential463
	{
		// id=<Sequential:<true:false:IDENTIFIER:t>,<Skippable:<Sequential:<true:true:template_tail:v>,<Action: return new TemplateInstanceTypeNode(t.location, t.text, v); >>>,<Action: return new TemplateInstanceTypeNode(t.location, t.text, null); >>
		private alias PartialTreeType = PartialTree!463;
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

			resTemp = ComplexParser_Skippable462.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private alias ElementParser_SHARP = ElementParser!(EnumTokenType.SHARP);
	private static class ComplexParser_Sequential464
	{
		// id=<Sequential:<false:false:SHARP:>,<true:true:single_types:st>,<Action: return [new TemplateParamNode(st.location, st)]; >>
		private alias PartialTreeType = PartialTree!464;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential465
	{
		// id=<Sequential:<false:false:SHARP:>,<true:true:primary_expr:pe>,<Action: return [new TemplateParamNode(pe.location, pe)]; >>
		private alias PartialTreeType = PartialTree!465;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential466
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:template_param:second_t>,<Action: params ~= second_t; >>
		private alias PartialTreeType = PartialTree!466;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified467
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:template_param:second_t>,<Action: params ~= second_t; >>>
		private alias PartialTreeType = PartialTree!467;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential466.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential468
	{
		// id=<Sequential:<Action: TemplateParamNode[] params; >,<false:false:SHARP:>,<false:false:LP:>,<true:true:template_param:first_t>,<Action: params ~= first_t; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:template_param:second_t>,<Action: params ~= second_t; >>>,<false:false:RP:>,<Action: return params; >>
		private alias PartialTreeType = PartialTree!468;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified467.parse(r);
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential469
	{
		// id=<Sequential:<false:false:SHARP:>,<false:false:LP:>,<false:false:RP:>,<Action: return null; >>
		private alias PartialTreeType = PartialTree!469;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching470
	{
		// id=<Switch:<Sequential:<false:false:SHARP:>,<true:true:single_types:st>,<Action: return [new TemplateParamNode(st.location, st)]; >>,<Sequential:<false:false:SHARP:>,<true:true:primary_expr:pe>,<Action: return [new TemplateParamNode(pe.location, pe)]; >>,<Sequential:<Action: TemplateParamNode[] params; >,<false:false:SHARP:>,<false:false:LP:>,<true:true:template_param:first_t>,<Action: params ~= first_t; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:template_param:second_t>,<Action: params ~= second_t; >>>,<false:false:RP:>,<Action: return params; >>,<Sequential:<false:false:SHARP:>,<false:false:LP:>,<false:false:RP:>,<Action: return null; >>>
		private alias PartialTreeType = PartialTree!470;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential464.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential465.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential468.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential469.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential471
	{
		// id=<Sequential:<true:false:IDENTIFIER:id>,<Action: return new TemplateParamNode(id.location, id.text); >>
		private alias PartialTreeType = PartialTree!471;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential472
	{
		// id=<Sequential:<true:true:restricted_type:rt>,<Action: return new TemplateParamNode(rt.location, rt); >>
		private alias PartialTreeType = PartialTree!472;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential473
	{
		// id=<Sequential:<true:true:expression:e>,<Action: return new TemplateParamNode(e.location, e); >>
		private alias PartialTreeType = PartialTree!473;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching474
	{
		// id=<Switch:<Sequential:<true:false:IDENTIFIER:id>,<Action: return new TemplateParamNode(id.location, id.text); >>,<Sequential:<true:true:restricted_type:rt>,<Action: return new TemplateParamNode(rt.location, rt); >>,<Sequential:<true:true:expression:e>,<Action: return new TemplateParamNode(e.location, e); >>>
		private alias PartialTreeType = PartialTree!474;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential471.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential472.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential473.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential475
	{
		// id=<Sequential:<true:true:single_restricted_type:srt>,<Action: return srt; >>
		private alias PartialTreeType = PartialTree!475;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching476
	{
		// id=<Switch:<Sequential:<true:false:AUTO:a>,<Action: return new InferenceTypeNode(a.location); >>,<Sequential:<true:true:single_restricted_type:srt>,<Action: return srt; >>>
		private alias PartialTreeType = PartialTree!476;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential430.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential475.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential477
	{
		// id=<Sequential:<true:false:IDENTIFIER:t>,<Action: return new TemplateInstanceTypeNode(t.location, t.text, null); >>
		private alias PartialTreeType = PartialTree!477;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching478
	{
		// id=<Switch:<Sequential:<true:true:register_types:rt>,<Action: return rt; >>,<Sequential:<true:false:IDENTIFIER:t>,<Action: return new TemplateInstanceTypeNode(t.location, t.text, null); >>>
		private alias PartialTreeType = PartialTree!478;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential438.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential477.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Sequential479
	{
		// id=<Sequential:<false:false:COMMA:>,<true:true:import_item:ii2>,<Action: ius ~= ii2; >>
		private alias PartialTreeType = PartialTree!479;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified480
	{
		// id=<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:import_item:ii2>,<Action: ius ~= ii2; >>>
		private alias PartialTreeType = PartialTree!480;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential479.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential481
	{
		// id=<Sequential:<Action: ImportUnitNode[] ius; >,<true:true:import_item:ii>,<Action: ius ~= ii; >,<LoopQualified:false:<Sequential:<false:false:COMMA:>,<true:true:import_item:ii2>,<Action: ius ~= ii2; >>>,<Action: return ius; >>
		private alias PartialTreeType = PartialTree!481;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = import_item.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified480.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential482
	{
		// id=<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:st>,<Action: ppath ~= st.text; >>
		private alias PartialTreeType = PartialTree!482;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified483
	{
		// id=<LoopQualified:false:<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:st>,<Action: ppath ~= st.text; >>>
		private alias PartialTreeType = PartialTree!483;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential482.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential484
	{
		// id=<Sequential:<false:false:PERIOD:>,<false:false:ASTERISK:>,<Action: return new ImportUnitNode(ft.location, ppath, true); >>
		private alias PartialTreeType = PartialTree!484;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential485
	{
		// id=<Sequential:<false:false:PERIOD:>,<false:false:LB:>,<true:true:import_list:sps>,<false:false:RB:>,<Action: return new ImportUnitNode(ft.location, ppath, sps); >>
		private alias PartialTreeType = PartialTree!485;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Switching486
	{
		// id=<Switch:<Sequential:<false:false:PERIOD:>,<false:false:ASTERISK:>,<Action: return new ImportUnitNode(ft.location, ppath, true); >>,<Sequential:<false:false:PERIOD:>,<false:false:LB:>,<true:true:import_list:sps>,<false:false:RB:>,<Action: return new ImportUnitNode(ft.location, ppath, sps); >>>
		private alias PartialTreeType = PartialTree!486;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			TokenIterator[] errors;

			resTemp = ComplexParser_Sequential484.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;

			resTemp = ComplexParser_Sequential485.parse(r);
			if(resTemp.succeeded)
			{
				return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));
			}
			errors ~= resTemp.iterError;
			return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));
		}
	}
	private static class ComplexParser_Skippable487
	{
		// id=<Skippable:<Switch:<Sequential:<false:false:PERIOD:>,<false:false:ASTERISK:>,<Action: return new ImportUnitNode(ft.location, ppath, true); >>,<Sequential:<false:false:PERIOD:>,<false:false:LB:>,<true:true:import_list:sps>,<false:false:RB:>,<Action: return new ImportUnitNode(ft.location, ppath, sps); >>>>
		private alias PartialTreeType = PartialTree!487;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			auto result = ComplexParser_Switching486.parse(r);
			if(result.failed)
			{
				return ResultType(true, r, result.iterError, new PartialTreeType(null));
			}
			else
			{
				return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));
			}
		}
	}
	private static class ComplexParser_Sequential488
	{
		// id=<Sequential:<Action: string[] ppath; >,<true:false:IDENTIFIER:ft>,<Action: ppath ~= ft.text; >,<LoopQualified:false:<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:st>,<Action: ppath ~= st.text; >>>,<Skippable:<Switch:<Sequential:<false:false:PERIOD:>,<false:false:ASTERISK:>,<Action: return new ImportUnitNode(ft.location, ppath, true); >>,<Sequential:<false:false:PERIOD:>,<false:false:LB:>,<true:true:import_list:sps>,<false:false:RB:>,<Action: return new ImportUnitNode(ft.location, ppath, sps); >>>>,<Action: return new ImportUnitNode(ft.location, ppath, false); >>
		private alias PartialTreeType = PartialTree!488;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified483.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;

			resTemp = ComplexParser_Skippable487.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential489
	{
		// id=<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:t2>,<Action: ids ~= t2; >>
		private alias PartialTreeType = PartialTree!489;
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
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_LoopQualified490
	{
		// id=<LoopQualified:false:<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:t2>,<Action: ids ~= t2; >>>
		private alias PartialTreeType = PartialTree!490;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			ISyntaxTree[] treeList;
			TokenIterator lastError;
			while(true)
			{
				auto result = ComplexParser_Sequential489.parse(r);
				lastError = result.iterError;
				if(result.failed) break;
				treeList ~= result.value;
				r = result.iterNext;
			}
			return ResultType(true, r, lastError, new PartialTreeType(treeList));
		}
	}
	private static class ComplexParser_Sequential491
	{
		// id=<Sequential:<Action: Token[] ids; >,<true:false:IDENTIFIER:t>,<Action: ids ~= t; >,<LoopQualified:false:<Sequential:<false:false:PERIOD:>,<true:false:IDENTIFIER:t2>,<Action: ids ~= t2; >>>,<Action: return ids; >>
		private alias PartialTreeType = PartialTree!491;
		private alias ResultType = Result!PartialTreeType;
		mixin PartialParserHeader!innerParse;

		private static ResultType innerParse(TokenIterator r)
		{
			Result!ISyntaxTree resTemp;
			ISyntaxTree[] treeList;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ElementParser_IDENTIFIER.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;

			resTemp = ComplexParser_LoopQualified490.parse(r);
			if(resTemp.failed)
			{
				return ResultType(false, r, resTemp.iterError);
			}
			treeList ~= resTemp.value;
			r = resTemp.iterNext;
			/* DUMMY FOR ACTION REFERENCING */
			treeList ~= null;
			return ResultType(true, r, resTemp.iterError, new PartialTreeType(treeList));
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
	public alias compilation_unit = RuleParser!("compilation_unit", ComplexParser_Sequential4);
	public alias package_def = RuleParser!("package_def", ComplexParser_Sequential5);
	public alias script_element = RuleParser!("script_element", ComplexParser_Switching14);
	public alias import_decl = RuleParser!("import_decl", ComplexParser_Sequential15);
	public alias partial_package_def = RuleParser!("partial_package_def", ComplexParser_Sequential21);
	public alias class_def = RuleParser!("class_def", ComplexParser_Sequential35);
	public alias class_body = RuleParser!("class_body", ComplexParser_Switching41);
	public alias trait_def = RuleParser!("trait_def", ComplexParser_Sequential52);
	public alias trait_body = RuleParser!("trait_body", ComplexParser_Switching53);
	public alias enum_def = RuleParser!("enum_def", ComplexParser_Sequential67);
	public alias enum_body = RuleParser!("enum_body", ComplexParser_Sequential72);
	public alias enum_element = RuleParser!("enum_element", ComplexParser_Sequential77);
	public alias template_def = RuleParser!("template_def", ComplexParser_Sequential88);
	public alias template_body = RuleParser!("template_body", ComplexParser_Switching89);
	public alias alias_def = RuleParser!("alias_def", ComplexParser_Sequential95);
	public alias field_def = RuleParser!("field_def", ComplexParser_Sequential101);
	public alias field_def_list = RuleParser!("field_def_list", ComplexParser_Sequential104);
	public alias nvpair = RuleParser!("nvpair", ComplexParser_Switching107);
	public alias method_def = RuleParser!("method_def", ComplexParser_Switching111);
	public alias procedure_def = RuleParser!("procedure_def", ComplexParser_Sequential119);
	public alias function_def = RuleParser!("function_def", ComplexParser_Sequential120);
	public alias abstract_method_def = RuleParser!("abstract_method_def", ComplexParser_Sequential121);
	public alias property_def = RuleParser!("property_def", ComplexParser_Switching124);
	public alias setter_def = RuleParser!("setter_def", ComplexParser_Sequential132);
	public alias getter_def = RuleParser!("getter_def", ComplexParser_Sequential139);
	public alias ctor_def = RuleParser!("ctor_def", ComplexParser_Switching142);
	public alias ctor_quals = RuleParser!("ctor_quals", ComplexParser_Sequential145);
	public alias full_ctor_def = RuleParser!("full_ctor_def", ComplexParser_Switching148);
	public alias abs_ctor_def = RuleParser!("abs_ctor_def", ComplexParser_Switching151);
	public alias tn_pair = RuleParser!("tn_pair", ComplexParser_Switching154);
	public alias tn_list = RuleParser!("tn_list", ComplexParser_Sequential157);
	public alias statement = RuleParser!("statement", ComplexParser_Switching170);
	public alias if_stmt = RuleParser!("if_stmt", ComplexParser_Switching173);
	public alias while_stmt = RuleParser!("while_stmt", ComplexParser_Switching176);
	public alias do_stmt = RuleParser!("do_stmt", ComplexParser_Switching179);
	public alias foreach_stmt = RuleParser!("foreach_stmt", ComplexParser_Switching182);
	public alias foreach_stmt_impl = RuleParser!("foreach_stmt_impl", ComplexParser_Sequential183);
	public alias for_stmt = RuleParser!("for_stmt", ComplexParser_Switching186);
	public alias for_stmt_impl = RuleParser!("for_stmt_impl", ComplexParser_Switching195);
	public alias return_stmt = RuleParser!("return_stmt", ComplexParser_Switching198);
	public alias break_stmt = RuleParser!("break_stmt", ComplexParser_Switching201);
	public alias continue_stmt = RuleParser!("continue_stmt", ComplexParser_Switching204);
	public alias switch_stmt = RuleParser!("switch_stmt", ComplexParser_Sequential209);
	public alias case_stmt = RuleParser!("case_stmt", ComplexParser_Switching212);
	public alias value_case_sect = RuleParser!("value_case_sect", ComplexParser_Sequential213);
	public alias type_case_sect = RuleParser!("type_case_sect", ComplexParser_Switching218);
	public alias default_stmt = RuleParser!("default_stmt", ComplexParser_Sequential219);
	public alias block_stmt = RuleParser!("block_stmt", ComplexParser_Sequential224);
	public alias localvar_def = RuleParser!("localvar_def", ComplexParser_Switching227);
	public alias nvp_list = RuleParser!("nvp_list", ComplexParser_Sequential230);
	public alias full_lvd = RuleParser!("full_lvd", ComplexParser_Sequential233);
	public alias inferenced_lvd = RuleParser!("inferenced_lvd", ComplexParser_Sequential236);
	public alias expression_list = RuleParser!("expression_list", ComplexParser_Sequential239);
	public alias expression = RuleParser!("expression", ComplexParser_Switching243);
	public alias assign_ops = RuleParser!("assign_ops", ComplexParser_Switching254);
	public alias alternate_expr = RuleParser!("alternate_expr", ComplexParser_Sequential257);
	public alias short_expr = RuleParser!("short_expr", ComplexParser_Sequential263);
	public alias comp_expr = RuleParser!("comp_expr", ComplexParser_Sequential272);
	public alias shift_expr = RuleParser!("shift_expr", ComplexParser_Sequential277);
	public alias bit_expr = RuleParser!("bit_expr", ComplexParser_Sequential283);
	public alias a1_expr = RuleParser!("a1_expr", ComplexParser_Sequential288);
	public alias a2_expr = RuleParser!("a2_expr", ComplexParser_Sequential294);
	public alias range_expr = RuleParser!("range_expr", ComplexParser_Sequential297);
	public alias prefix_expr = RuleParser!("prefix_expr", ComplexParser_Switching304);
	public alias postfix_expr = RuleParser!("postfix_expr", ComplexParser_Sequential318);
	public alias primary_expr = RuleParser!("primary_expr", ComplexParser_Switching327);
	public alias literals = RuleParser!("literals", ComplexParser_Switching337);
	public alias function_literal = RuleParser!("function_literal", ComplexParser_Switching340);
	public alias array_literal = RuleParser!("array_literal", ComplexParser_Switching344);
	public alias special_literals = RuleParser!("special_literals", ComplexParser_Switching350);
	public alias lambda_expr = RuleParser!("lambda_expr", ComplexParser_Switching354);
	public alias template_arg_list = RuleParser!("template_arg_list", ComplexParser_Sequential357);
	public alias template_arg = RuleParser!("template_arg", ComplexParser_Sequential360);
	public alias template_arg_type = RuleParser!("template_arg_type", ComplexParser_Sequential365);
	public alias template_arg_head = RuleParser!("template_arg_head", ComplexParser_Switching368);
	public alias varg_list = RuleParser!("varg_list", ComplexParser_Sequential371);
	public alias varg = RuleParser!("varg", ComplexParser_Switching378);
	public alias literal_varg_list = RuleParser!("literal_varg_list", ComplexParser_Sequential381);
	public alias literal_varg = RuleParser!("literal_varg", ComplexParser_Sequential388);
	public alias assoc_array_element_list = RuleParser!("assoc_array_element_list", ComplexParser_Sequential391);
	public alias assoc_array_element = RuleParser!("assoc_array_element", ComplexParser_Sequential392);
	public alias class_qualifier = RuleParser!("class_qualifier", ComplexParser_Switching397);
	public alias trait_qualifier = RuleParser!("trait_qualifier", ComplexParser_Switching398);
	public alias enum_qualifier = RuleParser!("enum_qualifier", ComplexParser_Switching398);
	public alias template_qualifier = RuleParser!("template_qualifier", ComplexParser_Switching399);
	public alias alias_qualifier = RuleParser!("alias_qualifier", ComplexParser_Switching399);
	public alias type_qualifier = RuleParser!("type_qualifier", ComplexParser_Sequential400);
	public alias field_qualifier = RuleParser!("field_qualifier", ComplexParser_Switching402);
	public alias method_qualifier = RuleParser!("method_qualifier", ComplexParser_Switching404);
	public alias ctor_qualifier = RuleParser!("ctor_qualifier", ComplexParser_Switching405);
	public alias lvar_qualifier = RuleParser!("lvar_qualifier", ComplexParser_Switching406);
	public alias def_id = RuleParser!("def_id", ComplexParser_Switching411);
	public alias def_id_arg_list = RuleParser!("def_id_arg_list", ComplexParser_Sequential414);
	public alias def_id_arg = RuleParser!("def_id_arg", ComplexParser_Sequential420);
	public alias def_id_argname = RuleParser!("def_id_argname", ComplexParser_Sequential421);
	public alias type = RuleParser!("type", ComplexParser_Sequential424);
	public alias type_body = RuleParser!("type_body", ComplexParser_Sequential429);
	public alias type_body_base = RuleParser!("type_body_base", ComplexParser_Switching432);
	public alias restricted_type = RuleParser!("restricted_type", ComplexParser_Sequential437);
	public alias primitive_types = RuleParser!("primitive_types", ComplexParser_Switching445);
	public alias __typeof = RuleParser!("__typeof", ComplexParser_Sequential449);
	public alias register_types = RuleParser!("register_types", ComplexParser_Switching460);
	public alias template_instance = RuleParser!("template_instance", ComplexParser_Sequential463);
	public alias template_tail = RuleParser!("template_tail", ComplexParser_Switching470);
	public alias template_param = RuleParser!("template_param", ComplexParser_Switching474);
	public alias single_types = RuleParser!("single_types", ComplexParser_Switching476);
	public alias single_restricted_type = RuleParser!("single_restricted_type", ComplexParser_Switching478);
	public alias import_list = RuleParser!("import_list", ComplexParser_Sequential481);
	public alias import_item = RuleParser!("import_item", ComplexParser_Sequential488);
	public alias package_id = RuleParser!("package_id", ComplexParser_Sequential491);
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
		 Token[] pn; DeclarationNode[] ds; 
		if(node.content.child[1].child.length > 0)
		{
			auto pd = reduce_package_def(cast(RuleTree!"package_def")(node.content.child[1].child[0].child[0]));
			 pn = pd; 
		}
		foreach(n0; node.content.child[2].child)
		{
			auto se = reduce_script_element(cast(RuleTree!"script_element")(n0.child[0]));
			 ds ~= se; 
		}
		 return new ScriptNode(pn, ds); 
		assert(false);
	}
	private static auto reduce_package_def(RuleTree!"package_def" node) in { assert(node !is null); } body
	{
		auto pid = reduce_package_id(cast(RuleTree!"package_id")(node.content.child[1]));
		 return pid; 
		assert(false);
	}
	private static DeclarationNode reduce_script_element(RuleTree!"script_element" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!6)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!6)(node.content.child[0]);
			auto id = reduce_import_decl(cast(RuleTree!"import_decl")(__tree_ref__1.child[0]));
			 return id; 
		}
		else if((cast(PartialTree!7)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!7)(node.content.child[0]);
			auto ppd = reduce_partial_package_def(cast(RuleTree!"partial_package_def")(__tree_ref__2.child[0]));
			 return ppd; 
		}
		else if((cast(PartialTree!8)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!8)(node.content.child[0]);
			auto cd = reduce_class_def(cast(RuleTree!"class_def")(__tree_ref__3.child[0]));
			 return cd; 
		}
		else if((cast(PartialTree!9)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!9)(node.content.child[0]);
			auto td = reduce_trait_def(cast(RuleTree!"trait_def")(__tree_ref__4.child[0]));
			 return td; 
		}
		else if((cast(PartialTree!10)(node.content.child[0])) !is null)
		{
			auto __tree_ref__5 = cast(PartialTree!10)(node.content.child[0]);
			auto ed = reduce_enum_def(cast(RuleTree!"enum_def")(__tree_ref__5.child[0]));
			 return ed; 
		}
		else if((cast(PartialTree!11)(node.content.child[0])) !is null)
		{
			auto __tree_ref__6 = cast(PartialTree!11)(node.content.child[0]);
			auto tmd = reduce_template_def(cast(RuleTree!"template_def")(__tree_ref__6.child[0]));
			 return tmd; 
		}
		else if((cast(PartialTree!12)(node.content.child[0])) !is null)
		{
			auto __tree_ref__7 = cast(PartialTree!12)(node.content.child[0]);
			auto ad = reduce_alias_def(cast(RuleTree!"alias_def")(__tree_ref__7.child[0]));
			 return ad; 
		}
		else if((cast(PartialTree!13)(node.content.child[0])) !is null)
		{
			auto __tree_ref__8 = cast(PartialTree!13)(node.content.child[0]);
			auto cb = reduce_class_body(cast(RuleTree!"class_body")(__tree_ref__8.child[0]));
			 return cb; 
		}
		assert(false);
	}
	private static auto reduce_import_decl(RuleTree!"import_decl" node) in { assert(node !is null); } body
	{
		auto ft = (cast(TokenTree)(node.content.child[0])).token;
		auto il = reduce_import_list(cast(RuleTree!"import_list")(node.content.child[1]));
		 return new ImportDeclarationNode(ft.location, il); 
		assert(false);
	}
	private static auto reduce_partial_package_def(RuleTree!"partial_package_def" node) in { assert(node !is null); } body
	{
		auto ft = (cast(TokenTree)(node.content.child[0])).token;
		auto pid = reduce_package_id(cast(RuleTree!"package_id")(node.content.child[1]));
		if((cast(PartialTree!16)(node.content.child[2].child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!16)(node.content.child[2].child[0]);
			auto e = reduce_script_element(cast(RuleTree!"script_element")(__tree_ref__1.child[0]));
			 return new PartialPackageDeclarationNode(ft.location, pid, [e]); 
		}
		else if((cast(PartialTree!19)(node.content.child[2].child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!19)(node.content.child[2].child[0]);
			 DeclarationNode[] elms; 
			foreach(n0; __tree_ref__2.child[2].child)
			{
				auto se = reduce_script_element(cast(RuleTree!"script_element")(n0.child[0]));
				 elms ~= se; 
			}
			 return new PartialPackageDeclarationNode(ft.location, pid, elms); 
		}
		assert(false);
	}
	private static auto reduce_class_def(RuleTree!"class_def" node) in { assert(node !is null); } body
	{
		 auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); TypeNode ef; TypeNode[] wts; 
		foreach(n0; node.content.child[1].child)
		{
			auto cq = reduce_class_qualifier(cast(RuleTree!"class_qualifier")(n0.child[0]));
			 q = q.combine(cq); 
		}
		auto ft = (cast(TokenTree)(node.content.child[2])).token;
		auto id = reduce_def_id(cast(RuleTree!"def_id")(node.content.child[3]));
		if(node.content.child[4].child.length > 0)
		{
			auto t = reduce_type(cast(RuleTree!"type")(node.content.child[4].child[0].child[1]));
			 ef = t; 
		}
		foreach(n0; node.content.child[5].child)
		{
			auto wt = reduce_type(cast(RuleTree!"type")(n0.child[1]));
			 wts ~= wt; 
		}
		if((cast(PartialTree!28)(node.content.child[6].child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!28)(node.content.child[6].child[0]);
			 return new ClassDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, ef, wts, null); 
		}
		else if((cast(PartialTree!33)(node.content.child[6].child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!33)(node.content.child[6].child[0]);
			 DeclarationNode[] dns; 
			foreach(n0; __tree_ref__2.child[2].child)
			{
				if((cast(PartialTree!29)(n0.child[0])) !is null)
				{
					auto __tree_ref__3 = cast(PartialTree!29)(n0.child[0]);
					auto idl = reduce_import_decl(cast(RuleTree!"import_decl")(__tree_ref__3.child[0]));
					 dns ~= idl; 
				}
				else if((cast(PartialTree!30)(n0.child[0])) !is null)
				{
					auto __tree_ref__4 = cast(PartialTree!30)(n0.child[0]);
					auto cb = reduce_class_body(cast(RuleTree!"class_body")(__tree_ref__4.child[0]));
					 dns ~= cb; 
				}
			}
			 return new ClassDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, ef, wts, dns); 
		}
		assert(false);
	}
	private static DeclarationNode reduce_class_body(RuleTree!"class_body" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!36)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!36)(node.content.child[0]);
			auto fd = reduce_field_def(cast(RuleTree!"field_def")(__tree_ref__1.child[0]));
			 return fd; 
		}
		else if((cast(PartialTree!37)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!37)(node.content.child[0]);
			auto md = reduce_method_def(cast(RuleTree!"method_def")(__tree_ref__2.child[0]));
			 return md; 
		}
		else if((cast(PartialTree!38)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!38)(node.content.child[0]);
			auto pd = reduce_property_def(cast(RuleTree!"property_def")(__tree_ref__3.child[0]));
			 return pd; 
		}
		else if((cast(PartialTree!39)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!39)(node.content.child[0]);
			auto cd = reduce_ctor_def(cast(RuleTree!"ctor_def")(__tree_ref__4.child[0]));
			 return cd; 
		}
		else if((cast(PartialTree!12)(node.content.child[0])) !is null)
		{
			auto __tree_ref__5 = cast(PartialTree!12)(node.content.child[0]);
			auto ad = reduce_alias_def(cast(RuleTree!"alias_def")(__tree_ref__5.child[0]));
			 return ad; 
		}
		else if((cast(PartialTree!40)(node.content.child[0])) !is null)
		{
			auto __tree_ref__6 = cast(PartialTree!40)(node.content.child[0]);
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__6.child[0]));
			 return new StaticInitializerNode(st); 
		}
		assert(false);
	}
	private static auto reduce_trait_def(RuleTree!"trait_def" node) in { assert(node !is null); } body
	{
		 auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); TypeNode[] wts; 
		foreach(n0; node.content.child[1].child)
		{
			auto tq = reduce_trait_qualifier(cast(RuleTree!"trait_qualifier")(n0.child[0]));
			 q = q.combine(tq); 
		}
		auto ft = (cast(TokenTree)(node.content.child[2])).token;
		auto id = reduce_def_id(cast(RuleTree!"def_id")(node.content.child[3]));
		foreach(n0; node.content.child[4].child)
		{
			auto t = reduce_type(cast(RuleTree!"type")(n0.child[1]));
			 wts ~= t; 
		}
		if((cast(PartialTree!46)(node.content.child[5].child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!46)(node.content.child[5].child[0]);
			 return new TraitDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, wts, null); 
		}
		else if((cast(PartialTree!50)(node.content.child[5].child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!50)(node.content.child[5].child[0]);
			 DeclarationNode[] dns; 
			foreach(n0; __tree_ref__2.child[2].child)
			{
				if((cast(PartialTree!29)(n0.child[0])) !is null)
				{
					auto __tree_ref__3 = cast(PartialTree!29)(n0.child[0]);
					auto idl = reduce_import_decl(cast(RuleTree!"import_decl")(__tree_ref__3.child[0]));
					 dns ~= idl; 
				}
				else if((cast(PartialTree!47)(n0.child[0])) !is null)
				{
					auto __tree_ref__4 = cast(PartialTree!47)(n0.child[0]);
					auto tb = reduce_trait_body(cast(RuleTree!"trait_body")(__tree_ref__4.child[0]));
					 dns ~= tb; 
				}
			}
			 return new TraitDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id, wts, dns); 
		}
		assert(false);
	}
	private static DeclarationNode reduce_trait_body(RuleTree!"trait_body" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!37)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!37)(node.content.child[0]);
			auto md = reduce_method_def(cast(RuleTree!"method_def")(__tree_ref__1.child[0]));
			 return md; 
		}
		else if((cast(PartialTree!38)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!38)(node.content.child[0]);
			auto pd = reduce_property_def(cast(RuleTree!"property_def")(__tree_ref__2.child[0]));
			 return pd; 
		}
		else if((cast(PartialTree!39)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!39)(node.content.child[0]);
			auto cd = reduce_ctor_def(cast(RuleTree!"ctor_def")(__tree_ref__3.child[0]));
			 return cd; 
		}
		else if((cast(PartialTree!12)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!12)(node.content.child[0]);
			auto ad = reduce_alias_def(cast(RuleTree!"alias_def")(__tree_ref__4.child[0]));
			 return ad; 
		}
		assert(false);
	}
	private static auto reduce_enum_def(RuleTree!"enum_def" node) in { assert(node !is null); } body
	{
		 auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); 
		foreach(n0; node.content.child[1].child)
		{
			auto eq = reduce_enum_qualifier(cast(RuleTree!"enum_qualifier")(n0.child[0]));
			 q = q.combine(eq); 
		}
		auto ft = (cast(TokenTree)(node.content.child[2])).token;
		auto id = (cast(TokenTree)(node.content.child[3])).token;
		if((cast(PartialTree!56)(node.content.child[4].child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!56)(node.content.child[4].child[0]);
			 return new EnumDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, null, null); 
		}
		else if((cast(PartialTree!65)(node.content.child[4].child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!65)(node.content.child[4].child[0]);
			 DeclarationNode[] nodes; EnumElementNode[] bodies; 
			foreach(n0; __tree_ref__2.child[2].child)
			{
				auto idl = reduce_import_decl(cast(RuleTree!"import_decl")(n0.child[0]));
				 nodes ~= idl; 
			}
			if(__tree_ref__2.child[3].child.length > 0)
			{
				auto eb = reduce_enum_body(cast(RuleTree!"enum_body")(__tree_ref__2.child[3].child[0].child[0]));
				 bodies = eb; 
			}
			foreach(n0; __tree_ref__2.child[4].child)
			{
				if((cast(PartialTree!61)(n0.child[0])) !is null)
				{
					auto __tree_ref__3 = cast(PartialTree!61)(n0.child[0]);
					auto idl2 = reduce_import_decl(cast(RuleTree!"import_decl")(__tree_ref__3.child[0]));
					 nodes ~= idl2; 
				}
				else if((cast(PartialTree!62)(n0.child[0])) !is null)
				{
					auto __tree_ref__4 = cast(PartialTree!62)(n0.child[0]);
					auto cb = reduce_class_body(cast(RuleTree!"class_body")(__tree_ref__4.child[0]));
					 nodes ~= cb; 
				}
			}
			 return new EnumDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, bodies, nodes); 
		}
		assert(false);
	}
	private static auto reduce_enum_body(RuleTree!"enum_body" node) in { assert(node !is null); } body
	{
		 EnumElementNode[] eens; 
		auto ee = reduce_enum_element(cast(RuleTree!"enum_element")(node.content.child[1]));
		 eens ~= ee; 
		foreach(n0; node.content.child[3].child)
		{
			auto ee2 = reduce_enum_element(cast(RuleTree!"enum_element")(n0.child[1]));
			 eens ~= ee2; 
		}
		if(node.content.child[4].child.length > 0)
		{
		}
		 return eens; 
		assert(false);
	}
	private static auto reduce_enum_element(RuleTree!"enum_element" node) in { assert(node !is null); } body
	{
		 ExpressionNode[] els; 
		auto id = (cast(TokenTree)(node.content.child[1])).token;
		if(node.content.child[2].child.length > 0)
		{
			if(node.content.child[2].child[0].child[1].child.length > 0)
			{
				auto el = reduce_expression_list(cast(RuleTree!"expression_list")(node.content.child[2].child[0].child[1].child[0].child[0]));
				 els = el; 
			}
		}
		 return new EnumElementNode(id.location, id.text, els); 
		assert(false);
	}
	private static auto reduce_template_def(RuleTree!"template_def" node) in { assert(node !is null); } body
	{
		 TemplateVirtualParamNode[] template_vps = null; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); 
		foreach(n0; node.content.child[1].child)
		{
			auto tq = reduce_template_qualifier(cast(RuleTree!"template_qualifier")(n0.child[0]));
			 q = q.combine(tq); 
		}
		auto ft = (cast(TokenTree)(node.content.child[2])).token;
		auto id = (cast(TokenTree)(node.content.child[3])).token;
		if(node.content.child[5].child.length > 0)
		{
			auto tvps = reduce_template_arg_list(cast(RuleTree!"template_arg_list")(node.content.child[5].child[0].child[0]));
			 template_vps = tvps; 
		}
		if((cast(PartialTree!82)(node.content.child[7].child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!82)(node.content.child[7].child[0]);
			 return new TemplateDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, template_vps, null); 
		}
		else if((cast(PartialTree!83)(node.content.child[7].child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!83)(node.content.child[7].child[0]);
			auto tb = reduce_template_body(cast(RuleTree!"template_body")(__tree_ref__2.child[0]));
			 return new TemplateDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, template_vps, [tb]); 
		}
		else if((cast(PartialTree!86)(node.content.child[7].child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!86)(node.content.child[7].child[0]);
			 DeclarationNode[] child; 
			foreach(n0; __tree_ref__3.child[2].child)
			{
				auto tb = reduce_template_body(cast(RuleTree!"template_body")(n0.child[0]));
				 child ~= tb; 
			}
			 return new TemplateDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, id.text, template_vps, child); 
		}
		assert(false);
	}
	private static DeclarationNode reduce_template_body(RuleTree!"template_body" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!6)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!6)(node.content.child[0]);
			auto id = reduce_import_decl(cast(RuleTree!"import_decl")(__tree_ref__1.child[0]));
			 return id; 
		}
		else if((cast(PartialTree!8)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!8)(node.content.child[0]);
			auto cd = reduce_class_def(cast(RuleTree!"class_def")(__tree_ref__2.child[0]));
			 return cd; 
		}
		else if((cast(PartialTree!9)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!9)(node.content.child[0]);
			auto td = reduce_trait_def(cast(RuleTree!"trait_def")(__tree_ref__3.child[0]));
			 return td; 
		}
		else if((cast(PartialTree!10)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!10)(node.content.child[0]);
			auto ed = reduce_enum_def(cast(RuleTree!"enum_def")(__tree_ref__4.child[0]));
			 return ed; 
		}
		else if((cast(PartialTree!11)(node.content.child[0])) !is null)
		{
			auto __tree_ref__5 = cast(PartialTree!11)(node.content.child[0]);
			auto tmd = reduce_template_def(cast(RuleTree!"template_def")(__tree_ref__5.child[0]));
			 return tmd; 
		}
		else if((cast(PartialTree!12)(node.content.child[0])) !is null)
		{
			auto __tree_ref__6 = cast(PartialTree!12)(node.content.child[0]);
			auto ad = reduce_alias_def(cast(RuleTree!"alias_def")(__tree_ref__6.child[0]));
			 return ad; 
		}
		assert(false);
	}
	private static auto reduce_alias_def(RuleTree!"alias_def" node) in { assert(node !is null); } body
	{
		 DefinitionIdentifierNode id; TypeNode t; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); 
		foreach(n0; node.content.child[1].child)
		{
			auto aq = reduce_alias_qualifier(cast(RuleTree!"alias_qualifier")(n0.child[0]));
			 q = q.combine(aq); 
		}
		auto ft = (cast(TokenTree)(node.content.child[2])).token;
		if((cast(PartialTree!92)(node.content.child[3].child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!92)(node.content.child[3].child[0]);
			auto did = reduce_def_id(cast(RuleTree!"def_id")(__tree_ref__1.child[0]));
			auto tt = reduce_type(cast(RuleTree!"type")(__tree_ref__1.child[2]));
			 id = did; t = tt; 
		}
		else if((cast(PartialTree!93)(node.content.child[3].child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!93)(node.content.child[3].child[0]);
			auto tt = reduce_type(cast(RuleTree!"type")(__tree_ref__2.child[0]));
			auto did = reduce_def_id(cast(RuleTree!"def_id")(__tree_ref__2.child[1]));
			 id = did; t = tt; 
		}
		 return new AliasDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, t, id); 
		assert(false);
	}
	private static auto reduce_field_def(RuleTree!"field_def" node) in { assert(node !is null); } body
	{
		 TypeNode t = null; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); 
		if((cast(PartialTree!98)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!98)(node.content.child[1].child[0]);
			foreach(n0; __tree_ref__1.child[0].child)
			{
				auto fq = reduce_field_qualifier(cast(RuleTree!"field_qualifier")(n0.child[0]));
				 q = q.combine(fq); 
			}
			auto tp = reduce_type(cast(RuleTree!"type")(__tree_ref__1.child[1]));
			 t = tp; 
		}
		else if((cast(PartialTree!99)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!99)(node.content.child[1].child[0]);
			foreach(n0; __tree_ref__2.child)
			{
				auto fq = reduce_field_qualifier(cast(RuleTree!"field_qualifier")(n0.child[0]));
				 q = q.combine(fq); 
			}
		}
		auto fdl = reduce_field_def_list(cast(RuleTree!"field_def_list")(node.content.child[2]));
		 return new FieldDeclarationNode(q.location.line == int.max ? t.location : q.location, q, t, fdl); 
		assert(false);
	}
	private static auto reduce_field_def_list(RuleTree!"field_def_list" node) in { assert(node !is null); } body
	{
		 NameValuePair[] nvplist; 
		auto nvp = reduce_nvpair(cast(RuleTree!"nvpair")(node.content.child[1]));
		 nvplist ~= nvp; 
		foreach(n0; node.content.child[3].child)
		{
			auto nvp2 = reduce_nvpair(cast(RuleTree!"nvpair")(n0.child[1]));
			 nvplist ~= nvp2; 
		}
		 return nvplist; 
		assert(false);
	}
	private static auto reduce_nvpair(RuleTree!"nvpair" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!105)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!105)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[2]));
			 return new NameValuePair(id.location, id.text, e); 
		}
		else if((cast(PartialTree!106)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!106)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return new NameValuePair(id.location, id.text, null); 
		}
		assert(false);
	}
	private static auto reduce_method_def(RuleTree!"method_def" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!108)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!108)(node.content.child[0]);
			auto fd = reduce_function_def(cast(RuleTree!"function_def")(__tree_ref__1.child[0]));
			 return fd; 
		}
		else if((cast(PartialTree!109)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!109)(node.content.child[0]);
			auto pd = reduce_procedure_def(cast(RuleTree!"procedure_def")(__tree_ref__2.child[0]));
			 return pd; 
		}
		else if((cast(PartialTree!110)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!110)(node.content.child[0]);
			auto amd = reduce_abstract_method_def(cast(RuleTree!"abstract_method_def")(__tree_ref__3.child[0]));
			 return amd; 
		}
		assert(false);
	}
	private static auto reduce_procedure_def(RuleTree!"procedure_def" node) in { assert(node !is null); } body
	{
		 TypeNode t = null; VirtualParamNode[] vps = null; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); 
		if((cast(PartialTree!114)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!114)(node.content.child[1].child[0]);
			foreach(n0; __tree_ref__1.child[0].child)
			{
				auto mq = reduce_method_qualifier(cast(RuleTree!"method_qualifier")(n0.child[0]));
				q = q.combine(mq);
			}
			auto tt = reduce_type(cast(RuleTree!"type")(__tree_ref__1.child[1]));
			 t = tt; 
		}
		else if((cast(PartialTree!115)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!115)(node.content.child[1].child[0]);
			foreach(n0; __tree_ref__2.child)
			{
				auto mq = reduce_method_qualifier(cast(RuleTree!"method_qualifier")(n0.child[0]));
				q = q.combine(mq);
			}
		}
		auto id = reduce_def_id(cast(RuleTree!"def_id")(node.content.child[2]));
		if(node.content.child[4].child.length > 0)
		{
			auto vpl = reduce_varg_list(cast(RuleTree!"varg_list")(node.content.child[4].child[0].child[0]));
			 vps = vpl; 
		}
		auto st = reduce_statement(cast(RuleTree!"statement")(node.content.child[6]));
		 return new MethodDeclarationNode(q.location.line == int.max ? t.location : q.location, q, t, id, vps, st); 
		assert(false);
	}
	private static auto reduce_function_def(RuleTree!"function_def" node) in { assert(node !is null); } body
	{
		 TypeNode t = null; VirtualParamNode[] vps = null; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); 
		if((cast(PartialTree!114)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!114)(node.content.child[1].child[0]);
			foreach(n0; __tree_ref__1.child[0].child)
			{
				auto mq = reduce_method_qualifier(cast(RuleTree!"method_qualifier")(n0.child[0]));
				q = q.combine(mq);
			}
			auto tt = reduce_type(cast(RuleTree!"type")(__tree_ref__1.child[1]));
			 t = tt; 
		}
		else if((cast(PartialTree!115)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!115)(node.content.child[1].child[0]);
			foreach(n0; __tree_ref__2.child)
			{
				auto mq = reduce_method_qualifier(cast(RuleTree!"method_qualifier")(n0.child[0]));
				q = q.combine(mq);
			}
		}
		auto id = reduce_def_id(cast(RuleTree!"def_id")(node.content.child[2]));
		if(node.content.child[4].child.length > 0)
		{
			auto vpl = reduce_varg_list(cast(RuleTree!"varg_list")(node.content.child[4].child[0].child[0]));
			 vps = vpl; 
		}
		auto e = reduce_expression(cast(RuleTree!"expression")(node.content.child[7]));
		 return new MethodDeclarationNode(q.location.line == int.max ? t.location : q.location, q, t, id, vps, e); 
		assert(false);
	}
	private static auto reduce_abstract_method_def(RuleTree!"abstract_method_def" node) in { assert(node !is null); } body
	{
		 TypeNode t = null; VirtualParamNode[] vps = null; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); 
		if((cast(PartialTree!114)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!114)(node.content.child[1].child[0]);
			foreach(n0; __tree_ref__1.child[0].child)
			{
				auto mq = reduce_method_qualifier(cast(RuleTree!"method_qualifier")(n0.child[0]));
				q = q.combine(mq);
			}
			auto tt = reduce_type(cast(RuleTree!"type")(__tree_ref__1.child[1]));
			 t = tt; 
		}
		else if((cast(PartialTree!115)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!115)(node.content.child[1].child[0]);
			foreach(n0; __tree_ref__2.child)
			{
				auto mq = reduce_method_qualifier(cast(RuleTree!"method_qualifier")(n0.child[0]));
				q = q.combine(mq);
			}
		}
		auto id = reduce_def_id(cast(RuleTree!"def_id")(node.content.child[2]));
		if(node.content.child[4].child.length > 0)
		{
			auto vpl = reduce_varg_list(cast(RuleTree!"varg_list")(node.content.child[4].child[0].child[0]));
			 vps = vpl; 
		}
		 return new MethodDeclarationNode(q.location.line == int.max ? t.location : q.location, q, t, id, vps); 
		assert(false);
	}
	private static DeclarationNode reduce_property_def(RuleTree!"property_def" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!122)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!122)(node.content.child[0]);
			auto gd = reduce_getter_def(cast(RuleTree!"getter_def")(__tree_ref__1.child[0]));
			 return gd; 
		}
		else if((cast(PartialTree!123)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!123)(node.content.child[0]);
			auto sd = reduce_setter_def(cast(RuleTree!"setter_def")(__tree_ref__2.child[0]));
			 return sd; 
		}
		assert(false);
	}
	private static auto reduce_setter_def(RuleTree!"setter_def" node) in { assert(node !is null); } body
	{
		 TypeNode tp = null; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); 
		foreach(n0; node.content.child[1].child)
		{
			auto q2 = reduce_method_qualifier(cast(RuleTree!"method_qualifier")(n0.child[0]));
			 q = q.combine(q2); 
		}
		auto ft = (cast(TokenTree)(node.content.child[2])).token;
		if(node.content.child[3].child.length > 0)
		{
			auto t = reduce_type(cast(RuleTree!"type")(node.content.child[3].child[0].child[0]));
			 tp = t; 
		}
		auto id = reduce_def_id(cast(RuleTree!"def_id")(node.content.child[4]));
		auto p = reduce_tn_pair(cast(RuleTree!"tn_pair")(node.content.child[6]));
		if((cast(PartialTree!129)(node.content.child[8].child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!129)(node.content.child[8].child[0]);
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__1.child[0]));
			 return new SetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, p, st); 
		}
		else if((cast(PartialTree!130)(node.content.child[8].child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!130)(node.content.child[8].child[0]);
			 return new SetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, p, null); 
		}
		assert(false);
	}
	private static auto reduce_getter_def(RuleTree!"getter_def" node) in { assert(node !is null); } body
	{
		 TypeNode tp = null; auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); 
		foreach(n0; node.content.child[1].child)
		{
			auto q2 = reduce_method_qualifier(cast(RuleTree!"method_qualifier")(n0.child[0]));
			 q = q.combine(q2); 
		}
		auto ft = (cast(TokenTree)(node.content.child[2])).token;
		if(node.content.child[3].child.length > 0)
		{
			auto t = reduce_type(cast(RuleTree!"type")(node.content.child[3].child[0].child[0]));
			 tp = t; 
		}
		auto id = reduce_def_id(cast(RuleTree!"def_id")(node.content.child[4]));
		if(node.content.child[5].child.length > 0)
		{
		}
		if((cast(PartialTree!135)(node.content.child[6].child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!135)(node.content.child[6].child[0]);
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[1]));
			 return new GetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, e); 
		}
		else if((cast(PartialTree!136)(node.content.child[6].child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!136)(node.content.child[6].child[0]);
			 return new GetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, null); 
		}
		else if((cast(PartialTree!137)(node.content.child[6].child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!137)(node.content.child[6].child[0]);
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__3.child[0]));
			 return new GetterDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, tp, id, st); 
		}
		assert(false);
	}
	private static auto reduce_ctor_def(RuleTree!"ctor_def" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!140)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!140)(node.content.child[0]);
			auto fcd = reduce_full_ctor_def(cast(RuleTree!"full_ctor_def")(__tree_ref__1.child[0]));
			 return fcd; 
		}
		else if((cast(PartialTree!141)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!141)(node.content.child[0]);
			auto acd = reduce_abs_ctor_def(cast(RuleTree!"abs_ctor_def")(__tree_ref__2.child[0]));
			 return acd; 
		}
		assert(false);
	}
	private static auto reduce_ctor_quals(RuleTree!"ctor_quals" node) in { assert(node !is null); } body
	{
		 auto q = Qualifier(Location(int.max, int.max), Qualifiers.Private); 
		foreach(n0; node.content.child[1].child)
		{
			auto cq = reduce_ctor_qualifier(cast(RuleTree!"ctor_qualifier")(n0.child[0]));
			 q = q.combine(cq); 
		}
		 return q; 
		assert(false);
	}
	private static auto reduce_full_ctor_def(RuleTree!"full_ctor_def" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!146)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!146)(node.content.child[0]);
			auto q = reduce_ctor_quals(cast(RuleTree!"ctor_quals")(__tree_ref__1.child[0]));
			auto ft = (cast(TokenTree)(__tree_ref__1.child[1])).token;
			auto vl = reduce_varg_list(cast(RuleTree!"varg_list")(__tree_ref__1.child[3]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__1.child[5]));
			 return new ConstructorDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, vl, st); 
		}
		else if((cast(PartialTree!147)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!147)(node.content.child[0]);
			auto q = reduce_ctor_quals(cast(RuleTree!"ctor_quals")(__tree_ref__2.child[0]));
			auto ft = (cast(TokenTree)(__tree_ref__2.child[1])).token;
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__2.child[4]));
			 return new ConstructorDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, null, st); 
		}
		assert(false);
	}
	private static auto reduce_abs_ctor_def(RuleTree!"abs_ctor_def" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!149)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!149)(node.content.child[0]);
			auto q = reduce_ctor_quals(cast(RuleTree!"ctor_quals")(__tree_ref__1.child[0]));
			auto ft = (cast(TokenTree)(__tree_ref__1.child[1])).token;
			auto vl = reduce_varg_list(cast(RuleTree!"varg_list")(__tree_ref__1.child[3]));
			 return new ConstructorDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, vl, null); 
		}
		else if((cast(PartialTree!150)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!150)(node.content.child[0]);
			auto q = reduce_ctor_quals(cast(RuleTree!"ctor_quals")(__tree_ref__2.child[0]));
			auto ft = (cast(TokenTree)(__tree_ref__2.child[1])).token;
			 return new ConstructorDeclarationNode(q.location.line == int.max ? ft.location : q.location, q, null, null); 
		}
		assert(false);
	}
	private static auto reduce_tn_pair(RuleTree!"tn_pair" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!152)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!152)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__1.child[0]));
			auto id = (cast(TokenTree)(__tree_ref__1.child[1])).token;
			 return new TypeNamePair(t.location, t, id.text); 
		}
		else if((cast(PartialTree!153)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!153)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__2.child[0])).token;
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
		if((cast(PartialTree!158)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!158)(node.content.child[0]);
			auto ifs = reduce_if_stmt(cast(RuleTree!"if_stmt")(__tree_ref__1.child[0]));
			 return ifs; 
		}
		else if((cast(PartialTree!159)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!159)(node.content.child[0]);
			auto ws = reduce_while_stmt(cast(RuleTree!"while_stmt")(__tree_ref__2.child[0]));
			 return ws; 
		}
		else if((cast(PartialTree!160)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!160)(node.content.child[0]);
			auto ds = reduce_do_stmt(cast(RuleTree!"do_stmt")(__tree_ref__3.child[0]));
			 return ds; 
		}
		else if((cast(PartialTree!161)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!161)(node.content.child[0]);
			auto fes = reduce_foreach_stmt(cast(RuleTree!"foreach_stmt")(__tree_ref__4.child[0]));
			 return fes; 
		}
		else if((cast(PartialTree!162)(node.content.child[0])) !is null)
		{
			auto __tree_ref__5 = cast(PartialTree!162)(node.content.child[0]);
			auto fs = reduce_for_stmt(cast(RuleTree!"for_stmt")(__tree_ref__5.child[0]));
			 return fs; 
		}
		else if((cast(PartialTree!163)(node.content.child[0])) !is null)
		{
			auto __tree_ref__6 = cast(PartialTree!163)(node.content.child[0]);
			auto rs = reduce_return_stmt(cast(RuleTree!"return_stmt")(__tree_ref__6.child[0]));
			 return rs; 
		}
		else if((cast(PartialTree!164)(node.content.child[0])) !is null)
		{
			auto __tree_ref__7 = cast(PartialTree!164)(node.content.child[0]);
			auto bs = reduce_break_stmt(cast(RuleTree!"break_stmt")(__tree_ref__7.child[0]));
			 return bs; 
		}
		else if((cast(PartialTree!165)(node.content.child[0])) !is null)
		{
			auto __tree_ref__8 = cast(PartialTree!165)(node.content.child[0]);
			auto cs = reduce_continue_stmt(cast(RuleTree!"continue_stmt")(__tree_ref__8.child[0]));
			 return cs; 
		}
		else if((cast(PartialTree!166)(node.content.child[0])) !is null)
		{
			auto __tree_ref__9 = cast(PartialTree!166)(node.content.child[0]);
			auto ss = reduce_switch_stmt(cast(RuleTree!"switch_stmt")(__tree_ref__9.child[0]));
			 return ss; 
		}
		else if((cast(PartialTree!167)(node.content.child[0])) !is null)
		{
			auto __tree_ref__10 = cast(PartialTree!167)(node.content.child[0]);
			auto bls = reduce_block_stmt(cast(RuleTree!"block_stmt")(__tree_ref__10.child[0]));
			 return bls; 
		}
		else if((cast(PartialTree!168)(node.content.child[0])) !is null)
		{
			auto __tree_ref__11 = cast(PartialTree!168)(node.content.child[0]);
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__11.child[0]));
			 return e; 
		}
		else if((cast(PartialTree!169)(node.content.child[0])) !is null)
		{
			auto __tree_ref__12 = cast(PartialTree!169)(node.content.child[0]);
			 return null; 
		}
		assert(false);
	}
	private static auto reduce_if_stmt(RuleTree!"if_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!171)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!171)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto c = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[2]));
			auto t = reduce_statement(cast(RuleTree!"statement")(__tree_ref__1.child[4]));
			auto n = reduce_statement(cast(RuleTree!"statement")(__tree_ref__1.child[6]));
			 return new ConditionalNode(ft.location, c, t, n); 
		}
		else if((cast(PartialTree!172)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!172)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			auto c = reduce_expression(cast(RuleTree!"expression")(__tree_ref__2.child[2]));
			auto t = reduce_statement(cast(RuleTree!"statement")(__tree_ref__2.child[4]));
			 return new ConditionalNode(ft.location, c, t, null); 
		}
		assert(false);
	}
	private static auto reduce_while_stmt(RuleTree!"while_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!174)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!174)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto ft = (cast(TokenTree)(__tree_ref__1.child[2])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[4]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__1.child[6]));
			 return new PreConditionLoopNode(ft.location, id.text, e, st); 
		}
		else if((cast(PartialTree!175)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!175)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__2.child[2]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__2.child[4]));
			 return new PreConditionLoopNode(ft.location, e, st); 
		}
		assert(false);
	}
	private static auto reduce_do_stmt(RuleTree!"do_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!177)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!177)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto ft = (cast(TokenTree)(__tree_ref__1.child[2])).token;
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__1.child[3]));
			auto c = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[6]));
			 return new PostConditionLoopNode(ft.location, id.text, c, st); 
		}
		else if((cast(PartialTree!178)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!178)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__2.child[1]));
			auto c = reduce_expression(cast(RuleTree!"expression")(__tree_ref__2.child[4]));
			 return new PostConditionLoopNode(ft.location, c, st); 
		}
		assert(false);
	}
	private static auto reduce_foreach_stmt(RuleTree!"foreach_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!180)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!180)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto fs = reduce_foreach_stmt_impl(cast(RuleTree!"foreach_stmt_impl")(__tree_ref__1.child[2]));
			 return fs.withName(id.text); 
		}
		else if((cast(PartialTree!181)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!181)(node.content.child[0]);
			auto fs = reduce_foreach_stmt_impl(cast(RuleTree!"foreach_stmt_impl")(__tree_ref__2.child[0]));
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
		if((cast(PartialTree!184)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!184)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto fs = reduce_for_stmt_impl(cast(RuleTree!"for_stmt_impl")(__tree_ref__1.child[2]));
			 return fs.withName(id.text); 
		}
		else if((cast(PartialTree!185)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!185)(node.content.child[0]);
			auto fs = reduce_for_stmt_impl(cast(RuleTree!"for_stmt_impl")(__tree_ref__2.child[0]));
			 return fs; 
		}
		assert(false);
	}
	private static auto reduce_for_stmt_impl(RuleTree!"for_stmt_impl" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!187)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!187)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[2]));
			auto e2 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[4]));
			auto e3 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[6]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__1.child[8]));
			 return new ForStatementNode(ft.location, e, e2, e3, st); 
		}
		else if((cast(PartialTree!188)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!188)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__2.child[2]));
			auto e2 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__2.child[4]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__2.child[7]));
			 return new ForStatementNode(ft.location, e, e2, null, st); 
		}
		else if((cast(PartialTree!189)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!189)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__3.child[2]));
			auto e3 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__3.child[5]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__3.child[7]));
			 return new ForStatementNode(ft.location, e, null, e3, st); 
		}
		else if((cast(PartialTree!190)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!190)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__4.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__4.child[2]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__4.child[6]));
			 return new ForStatementNode(ft.location, e, null, null, st); 
		}
		else if((cast(PartialTree!191)(node.content.child[0])) !is null)
		{
			auto __tree_ref__5 = cast(PartialTree!191)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__5.child[0])).token;
			auto e2 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__5.child[3]));
			auto e3 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__5.child[5]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__5.child[7]));
			 return new ForStatementNode(ft.location, null, e2, e3, st); 
		}
		else if((cast(PartialTree!192)(node.content.child[0])) !is null)
		{
			auto __tree_ref__6 = cast(PartialTree!192)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__6.child[0])).token;
			auto e2 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__6.child[3]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__6.child[6]));
			 return new ForStatementNode(ft.location, null, e2, null, st); 
		}
		else if((cast(PartialTree!193)(node.content.child[0])) !is null)
		{
			auto __tree_ref__7 = cast(PartialTree!193)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__7.child[0])).token;
			auto e3 = reduce_expression(cast(RuleTree!"expression")(__tree_ref__7.child[4]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__7.child[6]));
			 return new ForStatementNode(ft.location, null, null, e3, st); 
		}
		else if((cast(PartialTree!194)(node.content.child[0])) !is null)
		{
			auto __tree_ref__8 = cast(PartialTree!194)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__8.child[0])).token;
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__8.child[6]));
			 return new ForStatementNode(ft.location, null, null, null, st); 
		}
		assert(false);
	}
	private static auto reduce_return_stmt(RuleTree!"return_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!196)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!196)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[1]));
			 return new ReturnNode(ft.location, e); 
		}
		else if((cast(PartialTree!197)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!197)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return new ReturnNode(ft.location, null); 
		}
		assert(false);
	}
	private static auto reduce_break_stmt(RuleTree!"break_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!199)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!199)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto id = (cast(TokenTree)(__tree_ref__1.child[1])).token;
			 return new BreakLoopNode(ft.location, id.text); 
		}
		else if((cast(PartialTree!200)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!200)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return new BreakLoopNode(ft.location, null); 
		}
		assert(false);
	}
	private static auto reduce_continue_stmt(RuleTree!"continue_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!202)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!202)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto id = (cast(TokenTree)(__tree_ref__1.child[1])).token;
			 return new ContinueLoopNode(ft.location, id.text); 
		}
		else if((cast(PartialTree!203)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!203)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__2.child[0])).token;
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
			if((cast(PartialTree!205)(n0.child[0])) !is null)
			{
				auto __tree_ref__1 = cast(PartialTree!205)(n0.child[0]);
				auto cs = reduce_case_stmt(cast(RuleTree!"case_stmt")(__tree_ref__1.child[0]));
				 sects ~= cs; 
			}
			else if((cast(PartialTree!206)(n0.child[0])) !is null)
			{
				auto __tree_ref__2 = cast(PartialTree!206)(n0.child[0]);
				auto ds = reduce_default_stmt(cast(RuleTree!"default_stmt")(__tree_ref__2.child[0]));
				 sects ~= ds; 
			}
		}
		 return new SwitchStatementNode(ft.location, te, sects); 
		assert(false);
	}
	private static SwitchSectionNode reduce_case_stmt(RuleTree!"case_stmt" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!210)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!210)(node.content.child[0]);
			auto vcs = reduce_value_case_sect(cast(RuleTree!"value_case_sect")(__tree_ref__1.child[0]));
			 return vcs; 
		}
		else if((cast(PartialTree!211)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!211)(node.content.child[0]);
			auto tcs = reduce_type_case_sect(cast(RuleTree!"type_case_sect")(__tree_ref__2.child[0]));
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
		if((cast(PartialTree!214)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!214)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto id = reduce_def_id(cast(RuleTree!"def_id")(__tree_ref__1.child[2]));
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__1.child[4]));
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[6]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__1.child[8]));
			 return new TypeCaseSectionNode(ft.location, true, id, t, e, st); 
		}
		else if((cast(PartialTree!215)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!215)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			auto id = reduce_def_id(cast(RuleTree!"def_id")(__tree_ref__2.child[2]));
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__2.child[4]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__2.child[6]));
			 return new TypeCaseSectionNode(ft.location, true, id, t, null, st); 
		}
		else if((cast(PartialTree!216)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!216)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			auto id = reduce_def_id(cast(RuleTree!"def_id")(__tree_ref__3.child[1]));
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__3.child[3]));
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__3.child[5]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__3.child[7]));
			 return new TypeCaseSectionNode(ft.location, false, id, t, e, st); 
		}
		else if((cast(PartialTree!217)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!217)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__4.child[0])).token;
			auto id = reduce_def_id(cast(RuleTree!"def_id")(__tree_ref__4.child[1]));
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__4.child[3]));
			auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__4.child[5]));
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
			if((cast(PartialTree!220)(n0.child[0])) !is null)
			{
				auto __tree_ref__1 = cast(PartialTree!220)(n0.child[0]);
				auto lvd = reduce_localvar_def(cast(RuleTree!"localvar_def")(__tree_ref__1.child[0]));
				 stmts ~= lvd; 
			}
			else if((cast(PartialTree!221)(n0.child[0])) !is null)
			{
				auto __tree_ref__2 = cast(PartialTree!221)(n0.child[0]);
				auto st = reduce_statement(cast(RuleTree!"statement")(__tree_ref__2.child[0]));
				 stmts ~= st; 
			}
		}
		 return new BlockStatementNode(t.location, stmts); 
		assert(false);
	}
	private static auto reduce_localvar_def(RuleTree!"localvar_def" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!225)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!225)(node.content.child[0]);
			auto flvd = reduce_full_lvd(cast(RuleTree!"full_lvd")(__tree_ref__1.child[0]));
			 return flvd; 
		}
		else if((cast(PartialTree!226)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!226)(node.content.child[0]);
			auto ilvd = reduce_inferenced_lvd(cast(RuleTree!"inferenced_lvd")(__tree_ref__2.child[0]));
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
		if((cast(PartialTree!240)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!240)(node.content.child[0]);
			auto l = reduce_postfix_expr(cast(RuleTree!"postfix_expr")(__tree_ref__1.child[0]));
			auto r = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[2]));
			 return new AssignOperatorNode(l, r); 
		}
		else if((cast(PartialTree!241)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!241)(node.content.child[0]);
			auto l = reduce_postfix_expr(cast(RuleTree!"postfix_expr")(__tree_ref__2.child[0]));
			auto o = reduce_assign_ops(cast(RuleTree!"assign_ops")(__tree_ref__2.child[1]));
			auto r = reduce_expression(cast(RuleTree!"expression")(__tree_ref__2.child[2]));
			 return new OperatedAssignNode(l, o, r); 
		}
		else if((cast(PartialTree!242)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!242)(node.content.child[0]);
			auto e = reduce_alternate_expr(cast(RuleTree!"alternate_expr")(__tree_ref__3.child[0]));
			 return e; 
		}
		assert(false);
	}
	private static auto reduce_assign_ops(RuleTree!"assign_ops" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!244)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!244)(node.content.child[0]);
			 return BinaryOperatorType.Add; 
		}
		else if((cast(PartialTree!245)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!245)(node.content.child[0]);
			 return BinaryOperatorType.Sub; 
		}
		else if((cast(PartialTree!246)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!246)(node.content.child[0]);
			 return BinaryOperatorType.Mul; 
		}
		else if((cast(PartialTree!247)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!247)(node.content.child[0]);
			 return BinaryOperatorType.Div; 
		}
		else if((cast(PartialTree!248)(node.content.child[0])) !is null)
		{
			auto __tree_ref__5 = cast(PartialTree!248)(node.content.child[0]);
			 return BinaryOperatorType.Mod; 
		}
		else if((cast(PartialTree!249)(node.content.child[0])) !is null)
		{
			auto __tree_ref__6 = cast(PartialTree!249)(node.content.child[0]);
			 return BinaryOperatorType.And; 
		}
		else if((cast(PartialTree!250)(node.content.child[0])) !is null)
		{
			auto __tree_ref__7 = cast(PartialTree!250)(node.content.child[0]);
			 return BinaryOperatorType.Or; 
		}
		else if((cast(PartialTree!251)(node.content.child[0])) !is null)
		{
			auto __tree_ref__8 = cast(PartialTree!251)(node.content.child[0]);
			 return BinaryOperatorType.Xor; 
		}
		else if((cast(PartialTree!252)(node.content.child[0])) !is null)
		{
			auto __tree_ref__9 = cast(PartialTree!252)(node.content.child[0]);
			 return BinaryOperatorType.LeftShift; 
		}
		else if((cast(PartialTree!253)(node.content.child[0])) !is null)
		{
			auto __tree_ref__10 = cast(PartialTree!253)(node.content.child[0]);
			 return BinaryOperatorType.RightShift; 
		}
		assert(false);
	}
	private static ExpressionNode reduce_alternate_expr(RuleTree!"alternate_expr" node) in { assert(node !is null); } body
	{
		auto e = reduce_short_expr(cast(RuleTree!"short_expr")(node.content.child[0]));
		if(node.content.child[1].child.length > 0)
		{
			auto t = reduce_short_expr(cast(RuleTree!"short_expr")(node.content.child[1].child[0].child[1]));
			auto n = reduce_short_expr(cast(RuleTree!"short_expr")(node.content.child[1].child[0].child[3]));
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
			if((cast(PartialTree!258)(n0.child[0])) !is null)
			{
				auto __tree_ref__1 = cast(PartialTree!258)(n0.child[0]);
				auto e2 = reduce_comp_expr(cast(RuleTree!"comp_expr")(__tree_ref__1.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.LogAnd, e2); 
			}
			else if((cast(PartialTree!259)(n0.child[0])) !is null)
			{
				auto __tree_ref__2 = cast(PartialTree!259)(n0.child[0]);
				auto e2 = reduce_comp_expr(cast(RuleTree!"comp_expr")(__tree_ref__2.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.LogOr, e2); 
			}
			else if((cast(PartialTree!260)(n0.child[0])) !is null)
			{
				auto __tree_ref__3 = cast(PartialTree!260)(n0.child[0]);
				auto e2 = reduce_comp_expr(cast(RuleTree!"comp_expr")(__tree_ref__3.child[1]));
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
			if((cast(PartialTree!264)(n0.child[0])) !is null)
			{
				auto __tree_ref__1 = cast(PartialTree!264)(n0.child[0]);
				auto e2 = reduce_shift_expr(cast(RuleTree!"shift_expr")(__tree_ref__1.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Less, e2); 
			}
			else if((cast(PartialTree!265)(n0.child[0])) !is null)
			{
				auto __tree_ref__2 = cast(PartialTree!265)(n0.child[0]);
				auto e2 = reduce_shift_expr(cast(RuleTree!"shift_expr")(__tree_ref__2.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Greater, e2); 
			}
			else if((cast(PartialTree!266)(n0.child[0])) !is null)
			{
				auto __tree_ref__3 = cast(PartialTree!266)(n0.child[0]);
				auto e2 = reduce_shift_expr(cast(RuleTree!"shift_expr")(__tree_ref__3.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Equiv, e2); 
			}
			else if((cast(PartialTree!267)(n0.child[0])) !is null)
			{
				auto __tree_ref__4 = cast(PartialTree!267)(n0.child[0]);
				auto e2 = reduce_shift_expr(cast(RuleTree!"shift_expr")(__tree_ref__4.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Inequiv, e2); 
			}
			else if((cast(PartialTree!268)(n0.child[0])) !is null)
			{
				auto __tree_ref__5 = cast(PartialTree!268)(n0.child[0]);
				auto e2 = reduce_shift_expr(cast(RuleTree!"shift_expr")(__tree_ref__5.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.LessEq, e2); 
			}
			else if((cast(PartialTree!269)(n0.child[0])) !is null)
			{
				auto __tree_ref__6 = cast(PartialTree!269)(n0.child[0]);
				auto e2 = reduce_shift_expr(cast(RuleTree!"shift_expr")(__tree_ref__6.child[1]));
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
			if((cast(PartialTree!273)(n0.child[0])) !is null)
			{
				auto __tree_ref__1 = cast(PartialTree!273)(n0.child[0]);
				auto e2 = reduce_bit_expr(cast(RuleTree!"bit_expr")(__tree_ref__1.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.LeftShift, e2); 
			}
			else if((cast(PartialTree!274)(n0.child[0])) !is null)
			{
				auto __tree_ref__2 = cast(PartialTree!274)(n0.child[0]);
				auto e2 = reduce_bit_expr(cast(RuleTree!"bit_expr")(__tree_ref__2.child[1]));
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
			if((cast(PartialTree!278)(n0.child[0])) !is null)
			{
				auto __tree_ref__1 = cast(PartialTree!278)(n0.child[0]);
				auto e2 = reduce_a1_expr(cast(RuleTree!"a1_expr")(__tree_ref__1.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.And, e2); 
			}
			else if((cast(PartialTree!279)(n0.child[0])) !is null)
			{
				auto __tree_ref__2 = cast(PartialTree!279)(n0.child[0]);
				auto e2 = reduce_a1_expr(cast(RuleTree!"a1_expr")(__tree_ref__2.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Or, e2); 
			}
			else if((cast(PartialTree!280)(n0.child[0])) !is null)
			{
				auto __tree_ref__3 = cast(PartialTree!280)(n0.child[0]);
				auto e2 = reduce_a1_expr(cast(RuleTree!"a1_expr")(__tree_ref__3.child[1]));
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
			if((cast(PartialTree!284)(n0.child[0])) !is null)
			{
				auto __tree_ref__1 = cast(PartialTree!284)(n0.child[0]);
				auto e2 = reduce_a2_expr(cast(RuleTree!"a2_expr")(__tree_ref__1.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Add, e2); 
			}
			else if((cast(PartialTree!285)(n0.child[0])) !is null)
			{
				auto __tree_ref__2 = cast(PartialTree!285)(n0.child[0]);
				auto e2 = reduce_a2_expr(cast(RuleTree!"a2_expr")(__tree_ref__2.child[1]));
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
			if((cast(PartialTree!289)(n0.child[0])) !is null)
			{
				auto __tree_ref__1 = cast(PartialTree!289)(n0.child[0]);
				auto e2 = reduce_range_expr(cast(RuleTree!"range_expr")(__tree_ref__1.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Mul, e2); 
			}
			else if((cast(PartialTree!290)(n0.child[0])) !is null)
			{
				auto __tree_ref__2 = cast(PartialTree!290)(n0.child[0]);
				auto e2 = reduce_range_expr(cast(RuleTree!"range_expr")(__tree_ref__2.child[1]));
				 e = new BinaryOperatorNode(e, BinaryOperatorType.Div, e2); 
			}
			else if((cast(PartialTree!291)(n0.child[0])) !is null)
			{
				auto __tree_ref__3 = cast(PartialTree!291)(n0.child[0]);
				auto e2 = reduce_range_expr(cast(RuleTree!"range_expr")(__tree_ref__3.child[1]));
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
		if((cast(PartialTree!298)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!298)(node.content.child[0]);
			auto e = reduce_prefix_expr(cast(RuleTree!"prefix_expr")(__tree_ref__1.child[1]));
			 return e; 
		}
		else if((cast(PartialTree!299)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!299)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			auto e = reduce_prefix_expr(cast(RuleTree!"prefix_expr")(__tree_ref__2.child[1]));
			 return new PreOperatorNode(t.location, e, UnaryOperatorType.Negate); 
		}
		else if((cast(PartialTree!300)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!300)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			auto e = reduce_prefix_expr(cast(RuleTree!"prefix_expr")(__tree_ref__3.child[1]));
			 return new PreOperatorNode(t.location, e, UnaryOperatorType.Increase); 
		}
		else if((cast(PartialTree!301)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!301)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__4.child[0])).token;
			auto e = reduce_prefix_expr(cast(RuleTree!"prefix_expr")(__tree_ref__4.child[1]));
			 return new PreOperatorNode(t.location, e, UnaryOperatorType.Decrease); 
		}
		else if((cast(PartialTree!302)(node.content.child[0])) !is null)
		{
			auto __tree_ref__5 = cast(PartialTree!302)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__5.child[0])).token;
			auto e = reduce_prefix_expr(cast(RuleTree!"prefix_expr")(__tree_ref__5.child[1]));
			 return new PreOperatorNode(t.location, e, UnaryOperatorType.Square); 
		}
		else if((cast(PartialTree!303)(node.content.child[0])) !is null)
		{
			auto __tree_ref__6 = cast(PartialTree!303)(node.content.child[0]);
			auto e = reduce_postfix_expr(cast(RuleTree!"postfix_expr")(__tree_ref__6.child[0]));
			 return e; 
		}
		assert(false);
	}
	private static ExpressionNode reduce_postfix_expr(RuleTree!"postfix_expr" node) in { assert(node !is null); } body
	{
		auto e = reduce_primary_expr(cast(RuleTree!"primary_expr")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			if((cast(PartialTree!305)(n0.child[0])) !is null)
			{
				auto __tree_ref__1 = cast(PartialTree!305)(n0.child[0]);
				 e = new PostOperatorNode(e, UnaryOperatorType.Increase); 
			}
			else if((cast(PartialTree!306)(n0.child[0])) !is null)
			{
				auto __tree_ref__2 = cast(PartialTree!306)(n0.child[0]);
				 e = new PostOperatorNode(e, UnaryOperatorType.Decrease); 
			}
			else if((cast(PartialTree!307)(n0.child[0])) !is null)
			{
				auto __tree_ref__3 = cast(PartialTree!307)(n0.child[0]);
				 e = new PostOperatorNode(e, UnaryOperatorType.Square); 
			}
			else if((cast(PartialTree!308)(n0.child[0])) !is null)
			{
				auto __tree_ref__4 = cast(PartialTree!308)(n0.child[0]);
				auto d = reduce_expression(cast(RuleTree!"expression")(__tree_ref__4.child[1]));
				 e = new ArrayRefNode(e, [d]); 
			}
			else if((cast(PartialTree!309)(n0.child[0])) !is null)
			{
				auto __tree_ref__5 = cast(PartialTree!309)(n0.child[0]);
				 e = new ArrayRefNode(e, null); 
			}
			else if((cast(PartialTree!310)(n0.child[0])) !is null)
			{
				auto __tree_ref__6 = cast(PartialTree!310)(n0.child[0]);
				auto ps = reduce_expression_list(cast(RuleTree!"expression_list")(__tree_ref__6.child[1]));
				 e = new FuncallNode(e, ps); 
			}
			else if((cast(PartialTree!311)(n0.child[0])) !is null)
			{
				auto __tree_ref__7 = cast(PartialTree!311)(n0.child[0]);
				 e = new FuncallNode(e, null); 
			}
			else if((cast(PartialTree!312)(n0.child[0])) !is null)
			{
				auto __tree_ref__8 = cast(PartialTree!312)(n0.child[0]);
				auto id = (cast(TokenTree)(__tree_ref__8.child[1])).token;
				auto tt = reduce_template_tail(cast(RuleTree!"template_tail")(__tree_ref__8.child[2]));
				 e = new ObjectRefNode(e, new TemplateInstantiateNode(id.location, id.text, tt)); 
			}
			else if((cast(PartialTree!313)(n0.child[0])) !is null)
			{
				auto __tree_ref__9 = cast(PartialTree!313)(n0.child[0]);
				auto id = (cast(TokenTree)(__tree_ref__9.child[1])).token;
				 e = new ObjectRefNode(e, new IdentifierReferenceNode(id.location, id.text)); 
			}
			else if((cast(PartialTree!314)(n0.child[0])) !is null)
			{
				auto __tree_ref__10 = cast(PartialTree!314)(n0.child[0]);
				auto st = reduce_single_types(cast(RuleTree!"single_types")(__tree_ref__10.child[1]));
				 e = new CastingNode(e, st); 
			}
			else if((cast(PartialTree!315)(n0.child[0])) !is null)
			{
				auto __tree_ref__11 = cast(PartialTree!315)(n0.child[0]);
				auto rt = reduce_restricted_type(cast(RuleTree!"restricted_type")(__tree_ref__11.child[2]));
				 e = new CastingNode(e, rt); 
			}
		}
		 return e; 
		assert(false);
	}
	private static ExpressionNode reduce_primary_expr(RuleTree!"primary_expr" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!319)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!319)(node.content.child[0]);
			auto l = reduce_literals(cast(RuleTree!"literals")(__tree_ref__1.child[0]));
			 return l; 
		}
		else if((cast(PartialTree!320)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!320)(node.content.child[0]);
			auto sl = reduce_special_literals(cast(RuleTree!"special_literals")(__tree_ref__2.child[0]));
			 return sl; 
		}
		else if((cast(PartialTree!321)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!321)(node.content.child[0]);
			auto le = reduce_lambda_expr(cast(RuleTree!"lambda_expr")(__tree_ref__3.child[0]));
			 return le; 
		}
		else if((cast(PartialTree!322)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!322)(node.content.child[0]);
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__4.child[1]));
			 return e; 
		}
		else if((cast(PartialTree!323)(node.content.child[0])) !is null)
		{
			auto __tree_ref__5 = cast(PartialTree!323)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__5.child[0])).token;
			auto tp = reduce_type(cast(RuleTree!"type")(__tree_ref__5.child[1]));
			 return new NewInstanceNode(t.location, tp); 
		}
		else if((cast(PartialTree!324)(node.content.child[0])) !is null)
		{
			auto __tree_ref__6 = cast(PartialTree!324)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__6.child[0])).token;
			auto tp = reduce_type(cast(RuleTree!"type")(__tree_ref__6.child[1]));
			auto ps = reduce_expression_list(cast(RuleTree!"expression_list")(__tree_ref__6.child[3]));
			 return new NewInstanceNode(t.location, tp, ps); 
		}
		else if((cast(PartialTree!325)(node.content.child[0])) !is null)
		{
			auto __tree_ref__7 = cast(PartialTree!325)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__7.child[0])).token;
			auto tt = reduce_template_tail(cast(RuleTree!"template_tail")(__tree_ref__7.child[1]));
			 return new TemplateInstantiateNode(id.location, id.text, tt); 
		}
		else if((cast(PartialTree!326)(node.content.child[0])) !is null)
		{
			auto __tree_ref__8 = cast(PartialTree!326)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__8.child[0])).token;
			 return new IdentifierReferenceNode(id.location, id.text); 
		}
		assert(false);
	}
	private static ExpressionNode reduce_literals(RuleTree!"literals" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!328)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!328)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return new IntLiteralNode(t.location, t.text.to!int); 
		}
		else if((cast(PartialTree!329)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!329)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return new IntLiteralNode(t.location, t.text.to!int(16)); 
		}
		else if((cast(PartialTree!330)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!330)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			 return new FloatLiteralNode(t.location, t.text.to!float); 
		}
		else if((cast(PartialTree!331)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!331)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__4.child[0])).token;
			 return new DoubleLiteralNode(t.location, t.text.to!double); 
		}
		else if((cast(PartialTree!332)(node.content.child[0])) !is null)
		{
			auto __tree_ref__5 = cast(PartialTree!332)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__5.child[0])).token;
			 return new NumericLiteralNode(t.location, t.text.to!real); 
		}
		else if((cast(PartialTree!333)(node.content.child[0])) !is null)
		{
			auto __tree_ref__6 = cast(PartialTree!333)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__6.child[0])).token;
			 return new StringLiteralNode(t.location, t.text); 
		}
		else if((cast(PartialTree!334)(node.content.child[0])) !is null)
		{
			auto __tree_ref__7 = cast(PartialTree!334)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__7.child[0])).token;
			 return new CharacterLiteralNode(t.location, t.text[0]); 
		}
		else if((cast(PartialTree!335)(node.content.child[0])) !is null)
		{
			auto __tree_ref__8 = cast(PartialTree!335)(node.content.child[0]);
			auto fl = reduce_function_literal(cast(RuleTree!"function_literal")(__tree_ref__8.child[0]));
			 return fl; 
		}
		else if((cast(PartialTree!336)(node.content.child[0])) !is null)
		{
			auto __tree_ref__9 = cast(PartialTree!336)(node.content.child[0]);
			auto al = reduce_array_literal(cast(RuleTree!"array_literal")(__tree_ref__9.child[0]));
			 return al; 
		}
		assert(false);
	}
	private static auto reduce_function_literal(RuleTree!"function_literal" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!338)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!338)(node.content.child[0]);
			auto f = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto vl = reduce_literal_varg_list(cast(RuleTree!"literal_varg_list")(__tree_ref__1.child[2]));
			auto bs = reduce_block_stmt(cast(RuleTree!"block_stmt")(__tree_ref__1.child[4]));
			 return new FunctionLiteralNode(f.location, vl, bs); 
		}
		else if((cast(PartialTree!339)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!339)(node.content.child[0]);
			auto f = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			auto bs = reduce_block_stmt(cast(RuleTree!"block_stmt")(__tree_ref__2.child[3]));
			 return new FunctionLiteralNode(f.location, null, bs); 
		}
		assert(false);
	}
	private static ExpressionNode reduce_array_literal(RuleTree!"array_literal" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!341)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!341)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto el = reduce_expression_list(cast(RuleTree!"expression_list")(__tree_ref__1.child[1]));
			 return new ArrayLiteralNode(ft.location, el); 
		}
		else if((cast(PartialTree!342)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!342)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			auto el = reduce_assoc_array_element_list(cast(RuleTree!"assoc_array_element_list")(__tree_ref__2.child[1]));
			 return new AssocArrayLiteralNode(ft.location, el); 
		}
		else if((cast(PartialTree!343)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!343)(node.content.child[0]);
			auto ft = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			 return new ArrayLiteralNode(ft.location, null); 
		}
		assert(false);
	}
	private static ExpressionNode reduce_special_literals(RuleTree!"special_literals" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!345)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!345)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return new ThisReferenceNode(t.location); 
		}
		else if((cast(PartialTree!346)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!346)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return new SuperReferenceNode(t.location); 
		}
		else if((cast(PartialTree!347)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!347)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			 return new BooleanLiteralNode(t.location, true); 
		}
		else if((cast(PartialTree!348)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!348)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__4.child[0])).token;
			 return new BooleanLiteralNode(t.location, false); 
		}
		else if((cast(PartialTree!349)(node.content.child[0])) !is null)
		{
			auto __tree_ref__5 = cast(PartialTree!349)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__5.child[0])).token;
			 return new NullLiteralNode(t.location); 
		}
		assert(false);
	}
	private static auto reduce_lambda_expr(RuleTree!"lambda_expr" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!351)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!351)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto ps = reduce_literal_varg_list(cast(RuleTree!"literal_varg_list")(__tree_ref__1.child[1]));
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[4]));
			 return new FunctionLiteralNode(t.location, ps, e); 
		}
		else if((cast(PartialTree!352)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!352)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__2.child[3]));
			 return new FunctionLiteralNode(t.location, null, e); 
		}
		else if((cast(PartialTree!353)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!353)(node.content.child[0]);
			auto vp = reduce_literal_varg(cast(RuleTree!"literal_varg")(__tree_ref__3.child[0]));
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__3.child[2]));
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
		if((cast(PartialTree!361)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!361)(node.content.child[1].child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__1.child[0]));
			 return ReturnType(TemplateVirtualParamNode.ParamType.Type, t, t.location); 
		}
		else if((cast(PartialTree!362)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!362)(node.content.child[1].child[0]);
			auto tk = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return ReturnType(TemplateVirtualParamNode.ParamType.Class, null, tk.location); 
		}
		else if((cast(PartialTree!363)(node.content.child[1].child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!363)(node.content.child[1].child[0]);
			auto tk = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			 return ReturnType(TemplateVirtualParamNode.ParamType.SymbolAlias, null, tk.location); 
		}
		assert(false);
	}
	private static auto reduce_template_arg_head(RuleTree!"template_arg_head" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!366)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!366)(node.content.child[0]);
			auto type = reduce_template_arg_type(cast(RuleTree!"template_arg_type")(__tree_ref__1.child[0]));
			auto id = (cast(TokenTree)(__tree_ref__1.child[1])).token;
			 return new TemplateVirtualParamNode(type.location, type.type, type.stype, id.text); 
		}
		else if((cast(PartialTree!367)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!367)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__2.child[0])).token;
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
		if((cast(PartialTree!372)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!372)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__1.child[0]));
			auto n = (cast(TokenTree)(__tree_ref__1.child[1])).token;
			auto dv = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[3]));
			 return new VirtualParamNode(t, n.text, dv, true); 
		}
		else if((cast(PartialTree!373)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!373)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__2.child[0]));
			auto n = (cast(TokenTree)(__tree_ref__2.child[1])).token;
			auto dv = reduce_expression(cast(RuleTree!"expression")(__tree_ref__2.child[3]));
			 return new VirtualParamNode(t, n.text, dv, false); 
		}
		else if((cast(PartialTree!374)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!374)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__3.child[0]));
			auto n = (cast(TokenTree)(__tree_ref__3.child[1])).token;
			 return new VirtualParamNode(t, n.text, null, true); 
		}
		else if((cast(PartialTree!375)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!375)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__4.child[0]));
			auto n = (cast(TokenTree)(__tree_ref__4.child[1])).token;
			 return new VirtualParamNode(t, n.text, null, false); 
		}
		else if((cast(PartialTree!376)(node.content.child[0])) !is null)
		{
			auto __tree_ref__5 = cast(PartialTree!376)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__5.child[0]));
			 return new VirtualParamNode(t, null, null, true); 
		}
		else if((cast(PartialTree!377)(node.content.child[0])) !is null)
		{
			auto __tree_ref__6 = cast(PartialTree!377)(node.content.child[0]);
			auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__6.child[0]));
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
		 TypeNode at = null; ExpressionNode dv = null; bool isVariant = false; 
		if(node.content.child[1].child.length > 0)
		{
			auto t = reduce_type(cast(RuleTree!"type")(node.content.child[1].child[0].child[0]));
			 at = t; 
		}
		auto id = (cast(TokenTree)(node.content.child[2])).token;
		if(node.content.child[3].child.length > 0)
		{
			auto e = reduce_expression(cast(RuleTree!"expression")(node.content.child[3].child[0].child[1]));
			 dv = e; 
		}
		if(node.content.child[4].child.length > 0)
		{
			 isVariant = true; 
		}
		 return new VirtualParamNode(at !is null ? at : new InferenceTypeNode(id.location), id.text, dv, isVariant); 
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
		if((cast(PartialTree!393)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!393)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!394)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!394)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		else if((cast(PartialTree!395)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!395)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Final); 
		}
		else if((cast(PartialTree!396)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!396)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__4.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Static); 
		}
		assert(false);
	}
	private static auto reduce_trait_qualifier(RuleTree!"trait_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!393)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!393)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!394)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!394)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		else if((cast(PartialTree!396)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!396)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Static); 
		}
		assert(false);
	}
	private static auto reduce_enum_qualifier(RuleTree!"enum_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!393)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!393)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!394)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!394)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		else if((cast(PartialTree!396)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!396)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Static); 
		}
		assert(false);
	}
	private static auto reduce_template_qualifier(RuleTree!"template_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!393)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!393)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!394)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!394)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		assert(false);
	}
	private static auto reduce_alias_qualifier(RuleTree!"alias_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!393)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!393)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!394)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!394)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
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
		if((cast(PartialTree!393)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!393)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!394)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!394)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		else if((cast(PartialTree!401)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!401)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Protected); 
		}
		else if((cast(PartialTree!396)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!396)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__4.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Static); 
		}
		else if((cast(PartialTree!395)(node.content.child[0])) !is null)
		{
			auto __tree_ref__5 = cast(PartialTree!395)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__5.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Final); 
		}
		else if((cast(PartialTree!400)(node.content.child[0])) !is null)
		{
			auto __tree_ref__6 = cast(PartialTree!400)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__6.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Const); 
		}
		assert(false);
	}
	private static auto reduce_method_qualifier(RuleTree!"method_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!393)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!393)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!394)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!394)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		else if((cast(PartialTree!401)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!401)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Protected); 
		}
		else if((cast(PartialTree!396)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!396)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__4.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Static); 
		}
		else if((cast(PartialTree!395)(node.content.child[0])) !is null)
		{
			auto __tree_ref__5 = cast(PartialTree!395)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__5.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Final); 
		}
		else if((cast(PartialTree!400)(node.content.child[0])) !is null)
		{
			auto __tree_ref__6 = cast(PartialTree!400)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__6.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Const); 
		}
		else if((cast(PartialTree!403)(node.content.child[0])) !is null)
		{
			auto __tree_ref__7 = cast(PartialTree!403)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__7.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Override); 
		}
		assert(false);
	}
	private static auto reduce_ctor_qualifier(RuleTree!"ctor_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!393)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!393)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Public); 
		}
		else if((cast(PartialTree!394)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!394)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		else if((cast(PartialTree!401)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!401)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Protected); 
		}
		else if((cast(PartialTree!400)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!400)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__4.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Const); 
		}
		assert(false);
	}
	private static auto reduce_lvar_qualifier(RuleTree!"lvar_qualifier" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!394)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!394)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Private); 
		}
		else if((cast(PartialTree!401)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!401)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Protected); 
		}
		else if((cast(PartialTree!400)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!400)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Const); 
		}
		else if((cast(PartialTree!396)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!396)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__4.child[0])).token;
			 return Qualifier(t.location, Qualifiers.Static); 
		}
		assert(false);
	}
	private static DefinitionIdentifierNode reduce_def_id(RuleTree!"def_id" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!407)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!407)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			auto params = reduce_def_id_arg_list(cast(RuleTree!"def_id_arg_list")(__tree_ref__1.child[2]));
			 return new DefinitionIdentifierNode(id.location, id.text, params); 
		}
		else if((cast(PartialTree!410)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!410)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			if(__tree_ref__2.child[1].child.length > 0)
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
			if((cast(PartialTree!415)(n0.child[0])) !is null)
			{
				auto __tree_ref__1 = cast(PartialTree!415)(n0.child[0]);
				auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__1.child[1]));
				 n = n.withDefaultValue(t); 
			}
			else if((cast(PartialTree!416)(n0.child[0])) !is null)
			{
				auto __tree_ref__2 = cast(PartialTree!416)(n0.child[0]);
				auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__2.child[1]));
				 n = n.withExtendedFrom(t); 
			}
			else if((cast(PartialTree!417)(n0.child[0])) !is null)
			{
				auto __tree_ref__3 = cast(PartialTree!417)(n0.child[0]);
				auto t = reduce_type(cast(RuleTree!"type")(__tree_ref__3.child[1]));
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
		if(node.content.child[1].child.length > 0)
		{
			if((cast(PartialTree!425)(node.content.child[1].child[0].child[0])) !is null)
			{
				auto __tree_ref__1 = cast(PartialTree!425)(node.content.child[1].child[0].child[0]);
				auto vpl = reduce_varg_list(cast(RuleTree!"varg_list")(__tree_ref__1.child[2]));
				 tbb = new FunctionTypeNode(tbb, vpl); 
			}
			else if((cast(PartialTree!426)(node.content.child[1].child[0].child[0])) !is null)
			{
				auto __tree_ref__2 = cast(PartialTree!426)(node.content.child[1].child[0].child[0]);
				 tbb = new FunctionTypeNode(tbb, null); 
			}
		}
		 return tbb; 
		assert(false);
	}
	private static auto reduce_type_body_base(RuleTree!"type_body_base" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!430)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!430)(node.content.child[0]);
			auto a = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return new InferenceTypeNode(a.location); 
		}
		else if((cast(PartialTree!431)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!431)(node.content.child[0]);
			auto rt = reduce_restricted_type(cast(RuleTree!"restricted_type")(__tree_ref__2.child[0]));
			 return rt; 
		}
		assert(false);
	}
	private static TypeNode reduce_restricted_type(RuleTree!"restricted_type" node) in { assert(node !is null); } body
	{
		auto pt = reduce_primitive_types(cast(RuleTree!"primitive_types")(node.content.child[0]));
		foreach(n0; node.content.child[1].child)
		{
			if((cast(PartialTree!433)(n0.child[0])) !is null)
			{
				auto __tree_ref__1 = cast(PartialTree!433)(n0.child[0]);
				auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[1]));
				 pt = new ArrayTypeNode(pt, e); 
			}
			else if((cast(PartialTree!434)(n0.child[0])) !is null)
			{
				auto __tree_ref__2 = cast(PartialTree!434)(n0.child[0]);
				 pt = new ArrayTypeNode(pt, null); 
			}
		}
		 return pt; 
		assert(false);
	}
	private static TypeNode reduce_primitive_types(RuleTree!"primitive_types" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!438)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!438)(node.content.child[0]);
			auto rt = reduce_register_types(cast(RuleTree!"register_types")(__tree_ref__1.child[0]));
			 return rt; 
		}
		else if((cast(PartialTree!444)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!444)(node.content.child[0]);
			 TypeNode tnode; 
			if((cast(PartialTree!439)(__tree_ref__2.child[1].child[0])) !is null)
			{
				auto __tree_ref__3 = cast(PartialTree!439)(__tree_ref__2.child[1].child[0]);
				auto ti = reduce_template_instance(cast(RuleTree!"template_instance")(__tree_ref__3.child[0]));
				 tnode = ti; 
			}
			else if((cast(PartialTree!440)(__tree_ref__2.child[1].child[0])) !is null)
			{
				auto __tree_ref__4 = cast(PartialTree!440)(__tree_ref__2.child[1].child[0]);
				auto to = reduce___typeof(cast(RuleTree!"__typeof")(__tree_ref__4.child[0]));
				 tnode = to; 
			}
			foreach(n0; __tree_ref__2.child[2].child)
			{
				auto tint = reduce_template_instance(cast(RuleTree!"template_instance")(n0.child[1]));
				 tnode = new TypeScopeResolverNode(tnode, tint); 
			}
			 return tnode; 
		}
		assert(false);
	}
	private static TypeofNode reduce___typeof(RuleTree!"__typeof" node) in { assert(node !is null); } body
	{
		auto f = (cast(TokenTree)(node.content.child[0])).token;
		if((cast(PartialTree!446)(node.content.child[2].child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!446)(node.content.child[2].child[0]);
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__1.child[0]));
			 return new TypeofNode(f.location, e); 
		}
		else if((cast(PartialTree!447)(node.content.child[2].child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!447)(node.content.child[2].child[0]);
			auto rt = reduce_restricted_type(cast(RuleTree!"restricted_type")(__tree_ref__2.child[0]));
			 return new TypeofNode(f.location, rt); 
		}
		assert(false);
	}
	private static RegisterTypeNode reduce_register_types(RuleTree!"register_types" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!450)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!450)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Void); 
		}
		else if((cast(PartialTree!451)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!451)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Char); 
		}
		else if((cast(PartialTree!452)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!452)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__3.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Uchar); 
		}
		else if((cast(PartialTree!453)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!453)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__4.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Byte); 
		}
		else if((cast(PartialTree!454)(node.content.child[0])) !is null)
		{
			auto __tree_ref__5 = cast(PartialTree!454)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__5.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Short); 
		}
		else if((cast(PartialTree!455)(node.content.child[0])) !is null)
		{
			auto __tree_ref__6 = cast(PartialTree!455)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__6.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Ushort); 
		}
		else if((cast(PartialTree!456)(node.content.child[0])) !is null)
		{
			auto __tree_ref__7 = cast(PartialTree!456)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__7.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Int); 
		}
		else if((cast(PartialTree!457)(node.content.child[0])) !is null)
		{
			auto __tree_ref__8 = cast(PartialTree!457)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__8.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Uint); 
		}
		else if((cast(PartialTree!458)(node.content.child[0])) !is null)
		{
			auto __tree_ref__9 = cast(PartialTree!458)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__9.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Long); 
		}
		else if((cast(PartialTree!459)(node.content.child[0])) !is null)
		{
			auto __tree_ref__10 = cast(PartialTree!459)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__10.child[0])).token;
			 return new RegisterTypeNode(t.location, RegisterTypeNode.Type.Ulong); 
		}
		assert(false);
	}
	private static TemplateInstanceTypeNode reduce_template_instance(RuleTree!"template_instance" node) in { assert(node !is null); } body
	{
		auto t = (cast(TokenTree)(node.content.child[0])).token;
		if(node.content.child[1].child.length > 0)
		{
			auto v = reduce_template_tail(cast(RuleTree!"template_tail")(node.content.child[1].child[0].child[0]));
			 return new TemplateInstanceTypeNode(t.location, t.text, v); 
		}
		 return new TemplateInstanceTypeNode(t.location, t.text, null); 
		assert(false);
	}
	private static TemplateParamNode[] reduce_template_tail(RuleTree!"template_tail" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!464)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!464)(node.content.child[0]);
			auto st = reduce_single_types(cast(RuleTree!"single_types")(__tree_ref__1.child[1]));
			 return [new TemplateParamNode(st.location, st)]; 
		}
		else if((cast(PartialTree!465)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!465)(node.content.child[0]);
			auto pe = reduce_primary_expr(cast(RuleTree!"primary_expr")(__tree_ref__2.child[1]));
			 return [new TemplateParamNode(pe.location, pe)]; 
		}
		else if((cast(PartialTree!468)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!468)(node.content.child[0]);
			 TemplateParamNode[] params; 
			auto first_t = reduce_template_param(cast(RuleTree!"template_param")(__tree_ref__3.child[3]));
			 params ~= first_t; 
			foreach(n0; __tree_ref__3.child[5].child)
			{
				auto second_t = reduce_template_param(cast(RuleTree!"template_param")(n0.child[1]));
				 params ~= second_t; 
			}
			 return params; 
		}
		else if((cast(PartialTree!469)(node.content.child[0])) !is null)
		{
			auto __tree_ref__4 = cast(PartialTree!469)(node.content.child[0]);
			 return null; 
		}
		assert(false);
	}
	private static TemplateParamNode reduce_template_param(RuleTree!"template_param" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!471)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!471)(node.content.child[0]);
			auto id = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return new TemplateParamNode(id.location, id.text); 
		}
		else if((cast(PartialTree!472)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!472)(node.content.child[0]);
			auto rt = reduce_restricted_type(cast(RuleTree!"restricted_type")(__tree_ref__2.child[0]));
			 return new TemplateParamNode(rt.location, rt); 
		}
		else if((cast(PartialTree!473)(node.content.child[0])) !is null)
		{
			auto __tree_ref__3 = cast(PartialTree!473)(node.content.child[0]);
			auto e = reduce_expression(cast(RuleTree!"expression")(__tree_ref__3.child[0]));
			 return new TemplateParamNode(e.location, e); 
		}
		assert(false);
	}
	private static TypeNode reduce_single_types(RuleTree!"single_types" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!430)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!430)(node.content.child[0]);
			auto a = (cast(TokenTree)(__tree_ref__1.child[0])).token;
			 return new InferenceTypeNode(a.location); 
		}
		else if((cast(PartialTree!475)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!475)(node.content.child[0]);
			auto srt = reduce_single_restricted_type(cast(RuleTree!"single_restricted_type")(__tree_ref__2.child[0]));
			 return srt; 
		}
		assert(false);
	}
	private static TypeNode reduce_single_restricted_type(RuleTree!"single_restricted_type" node) in { assert(node !is null); } body
	{
		if((cast(PartialTree!438)(node.content.child[0])) !is null)
		{
			auto __tree_ref__1 = cast(PartialTree!438)(node.content.child[0]);
			auto rt = reduce_register_types(cast(RuleTree!"register_types")(__tree_ref__1.child[0]));
			 return rt; 
		}
		else if((cast(PartialTree!477)(node.content.child[0])) !is null)
		{
			auto __tree_ref__2 = cast(PartialTree!477)(node.content.child[0]);
			auto t = (cast(TokenTree)(__tree_ref__2.child[0])).token;
			 return new TemplateInstanceTypeNode(t.location, t.text, null); 
		}
		assert(false);
	}
	private static ImportUnitNode[] reduce_import_list(RuleTree!"import_list" node) in { assert(node !is null); } body
	{
		 ImportUnitNode[] ius; 
		auto ii = reduce_import_item(cast(RuleTree!"import_item")(node.content.child[1]));
		 ius ~= ii; 
		foreach(n0; node.content.child[3].child)
		{
			auto ii2 = reduce_import_item(cast(RuleTree!"import_item")(n0.child[1]));
			 ius ~= ii2; 
		}
		 return ius; 
		assert(false);
	}
	private static ImportUnitNode reduce_import_item(RuleTree!"import_item" node) in { assert(node !is null); } body
	{
		 string[] ppath; 
		auto ft = (cast(TokenTree)(node.content.child[1])).token;
		 ppath ~= ft.text; 
		foreach(n0; node.content.child[3].child)
		{
			auto st = (cast(TokenTree)(n0.child[1])).token;
			 ppath ~= st.text; 
		}
		if(node.content.child[4].child.length > 0)
		{
			if((cast(PartialTree!484)(node.content.child[4].child[0].child[0])) !is null)
			{
				auto __tree_ref__1 = cast(PartialTree!484)(node.content.child[4].child[0].child[0]);
				 return new ImportUnitNode(ft.location, ppath, true); 
			}
			else if((cast(PartialTree!485)(node.content.child[4].child[0].child[0])) !is null)
			{
				auto __tree_ref__2 = cast(PartialTree!485)(node.content.child[4].child[0].child[0]);
				auto sps = reduce_import_list(cast(RuleTree!"import_list")(__tree_ref__2.child[2]));
				 return new ImportUnitNode(ft.location, ppath, sps); 
			}
		}
		 return new ImportUnitNode(ft.location, ppath, false); 
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
