module com.cterm2.tpeg.patternParser;

import com.cterm2.tpeg.tree;
import com.cterm2.tpeg.visitor;
import com.cterm2.tpeg.scriptParser;
import std.stdio, std.algorithm, std.range, std.array, std.conv;

import com.cterm2.tpeg.patternTree;

class TableActionBase
{
	// require deep-copyable
	public abstract @property TableActionBase dup();
}
class ShiftAction : TableActionBase
{
	size_t stateNum;

	public override @property TableActionBase dup() { return new ShiftAction(this.stateNum); }
	public this(size_t sn) { this.stateNum = sn; }
}
class ReduceAction : TableActionBase
{
	size_t reduceNum;
	bool isSkip;

	public override @property TableActionBase dup() { return this.isSkip ? new ReduceAction() : new ReduceAction(this.reduceNum); }
	public this(size_t rn) { this.reduceNum = rn; this.isSkip = false; }
	public this() { this.reduceNum = size_t.max; this.isSkip = true; }
}
class ShiftTable
{
	static class ShiftState
	{
		TableActionBase[] actionList;
	}
	ShiftState[] states;
	dchar[] candidates;
	size_t[dchar] candidateToIndex;
	size_t currentStateIndex;

	public auto appendNewState()
	{
		this.states ~= new ShiftState();
		return this.states.length - 1;
	}
	public auto appendNewCandidate(dchar ch)
	{
		if(ch in this.candidateToIndex) return this.candidateToIndex[ch];
		this.candidates ~= ch;
		this.candidateToIndex[ch] = this.candidates.length - 1;
		foreach(st; this.states) st.actionList ~= null;
		return this.candidates.length - 1;
	}
	public auto setCurrentState(size_t st) in { assert(0 <= st && st < this.states.length); } body
	{
		auto ps = this.currentStateIndex;
		this.currentStateIndex = st;
		return ps;
	}
	public auto registerAction(dchar ch, TableActionBase ta)
	{
		if(ch !in this.candidateToIndex) this.appendNewCandidate(ch);
		this.states[this.currentStateIndex].actionList[this.candidateToIndex[ch]] = ta.dup;
	}

	public this()
	{
		this.states ~= new ShiftState();
		this.setCurrentState(0);
	}
}
class ReduceTable
{
	string[] reduceTargets;
	size_t[string] reduceTargetsToIndex;

	public auto registerTarget(string targetName)
	{
		this.reduceTargets ~= targetName;
		this.reduceTargetsToIndex[targetName] = this.reduceTargets.length - 1;
		return this.reduceTargets.length - 1;
	}
	public auto getReduceIndexFromTarget(string targetName)
	{
		return this.reduceTargetsToIndex[targetName];
	}
	public @property maxIndex() pure { return this.reduceTargets.length - 1; }
	public @property maxTargetNameLength() pure { return this.reduceTargets.map!(a => a.length).reduce!max; }
}

class PatternParser : IVisitor
{
	bool has_error;
	ShiftTable shiftTable;
	ReduceTable reduceTable;

	public @property hasError() pure { return this.has_error; }
	public void entry(ScriptNode node)
	{
		this.has_error = false;
		this.shiftTable = new ShiftTable();
		this.reduceTable = new ReduceTable();
		node.accept(this);

		writeln("--- Reduce Table ---");
		auto columnSpace1 = [reduceTable.maxIndex.to!string.length, "state".length].reduce!max;
		auto columnSpace2 = [reduceTable.maxTargetNameLength, "target".length].reduce!max;
		writeln("+", "-".repeat(columnSpace1 + 2).join, "+", "-".repeat(columnSpace2 + 2).join, "+");
		void writeRow(string c1, string c2)
		{
			immutable auto c1w = c1.length, c2w = c2.length;
			immutable auto c1lp = (columnSpace1 - c1w) / 2, c2lp = (columnSpace2 - c2w) / 2;
			writeln("| ", " ".repeat(c1lp).join, c1, " ".repeat(columnSpace1 - (c1lp + c1w)).join, " | ",
				" ".repeat(c2lp).join, c2, " ".repeat(columnSpace2 - (c2lp + c2w)).join, " |");
		}
		writeRow("state", "target");
		writeln("+", "-".repeat(columnSpace1 + 2).join, "+", "-".repeat(columnSpace2 + 2).join, "+");
		foreach(i, a; this.reduceTable.reduceTargets)
		{
			writeRow(i.to!string, a.to!string);
		}
		writeln("+", "-".repeat(columnSpace1 + 2).join, "+", "-".repeat(columnSpace2 + 2).join, "+");
	}

	public override void visit(ScriptNode node)
	{
		if(node.tokenizer) node.tokenizer.accept(this);
	}
	public override void visit(TokenizerNode node)
	{
		foreach(n; node.skipPatterns) n.accept(this);
		foreach(n; node.patterns) n.accept(this);
	}
	public override void visit(ParserNode){}
	public override void visit(PatternNode node)
	{
		try
		{
			scope auto patternParserImpl = new PatternParserImpl(node.patternString, node.location);
			scope auto tdump = new PatternTreeDumper();
			tdump.entry(patternParserImpl.parsedTree);
			node.patternTree = patternParserImpl.parsedTree;
		}
		catch(PatternParserImpl.PatternSyntaxError err)
		{
			writeln("PatternSyntaxError: ", err.msg);
			this.has_error = true;
		}

		// registration
		ReduceAction reduceAct;
		if(node.tokenName !is null)
		{
			auto reduceNumToThis = this.reduceTable.registerTarget(node.tokenName);
			writeln("ReduceAction: registered ", node.tokenName, " to ", reduceNumToThis);
			reduceAct = new ReduceAction(reduceNumToThis);
		}
		else reduceAct = new ReduceAction();	// for skipping
	}
	public override void visit(RuleNode){}
	public override void visit(PEGSwitchingNode){}
	public override void visit(PEGSequentialNode){}
	public override void visit(PEGLoopQualifiedNode){}
	public override void visit(PEGSkippableNode){}
	public override void visit(PEGActionNode){}
	public override void visit(PEGElementNode){}
}

class PatternParserImpl
{
	import std.array, std.range, std.algorithm;

	string line;
	string current;
	Location ploc;
	size_t cloc;
	PatternTreeBase parsedTree;

	class PatternSyntaxError : Exception
	{
		public this(string msg)
		{
			import std.string;

			super(msg ~ format(" at Line %d, Column %d in pattern", this.outer.ploc.line, this.outer.cloc));
		}
	}

	this(string l, Location pl)
	{
		this.line = this.current = l;
		this.ploc = pl;
		this.cloc = 0;

		this.parsedTree = this.parseLine();
	}

	PatternTreeBase parseLine()
	{
		this.skipSpaces();
		auto t = this.parseSwitch();
		this.skipSpaces();
		if(!this.current.empty) throw new PatternSyntaxError("syntax error");
		return t;
	}
	PatternTreeBase parseSwitch()
	{
		// A / B ...
		PatternTreeBase[] pts;
		pts ~= this.parseSequence();
		while(!this.current.empty)
		{
			this.skipSpaces();
			if(this.current.empty) break;				// end rule
			if(this.current.front != '/') break;		// end rule
			this.forward();
			this.skipSpaces();
			pts ~= this.parseSequence();
		}
		if(pts.length == 1) return pts[0];
		else return new PatternSwitchNode(pts);
	}
	PatternTreeBase parseSequence()
	{
		// A B...
		PatternTreeBase[] pts;
		pts ~= this.parseElement();
		while(!this.current.empty)
		{
			this.skipSpaces();
			if(this.current.empty) break;				// end rule
			if(this.current.front == '/') break;		// fallback to switch(upper rule)
			if(this.current.front == ')') break;		// fallback to group end
			pts ~= this.parseElement();
		}
		if(pts.length == 1) return pts[0];
		else return new PatternSequenceNode(pts);
	}
	PatternTreeBase parseElement()
	{
		// group or literal auto detection
		PatternTreeBase t;

		switch(this.current.front)
		{
		case '(':
			// nested group
			t = this.parseGroup();
			break;
		case '"':
			// literal
			t = this.parseLiteral();
			break;
		case '!':
			// exclude
			t = this.parseExclude();
			break;
		default:
			// syntax error
			throw new PatternSyntaxError("Invalid Sequence");
		}

		this.skipSpaces();
		if(!this.current.empty)
		{
			if(this.current.front == '+')
			{
				// loop qualified
				this.forward();
				return new LoopQualifiedPatternNode(t);
			}
			else if(this.current.front == '*')
			{
				// loop qualified(0)
				this.forward();
				return new ZeroLoopQualifiedPatternNode(t);
			}
		}
		return t;
	}
	auto parseGroup() in { assert(!this.current.empty && this.current.front == '('); } body
	{
		// group: ( [Switch] )
		auto ltemp = PatternTreeLocation(this.ploc.line, this.cloc);
		this.forward();
		this.skipSpaces();
		auto c = this.parseSwitch();
		this.skipSpaces();
		if(this.current.empty || this.current.front != ')') throw new PatternSyntaxError("Not closed group");
		this.forward();
		// return new PatternGroupNode(ltemp, c);
		return c;
	}
	PatternTreeBase parseLiteral() in { assert(!this.current.empty && this.current.front == '"'); } body
	{
		// literal " UTF8-sequences... " [- "UTF8-sequences"]
		auto l = this.parseLiteralString();

		this.skipSpaces();
		if(!this.current.empty && this.current.front == '-')
		{
			// ranged
			this.forward();
			this.skipSpaces();
			if(this.current.empty || this.current.front != '"') throw new PatternSyntaxError("Expected a literal");
			auto r = this.parseLiteralString();
			if(l.content.length != 1 || r.content.length != 1) throw new PatternSyntaxError("Cannot make ranged literal.");
			if(l.content.front > r.content.front) throw new PatternSyntaxError("Invalid order for range");
			if(l.content.front == r.content.front) return l;	// same(convert to single literal)
			return new RangedLiteralNode(l, r);
		}
		if(l.content.empty) throw new PatternSyntaxError("Empty literal is not allowed.");
		if(l.content.length == 1) return l;
		else return new PatternSequenceNode(l.purge().map!(a => cast(PatternTreeBase)a).array);
	}
	auto parseLiteralString() in { assert(!this.current.empty && this.current.front == '"'); } body
	{
		// parse UTF8-Sequences

		this.forward();
		bool in_escape = false;
		string temp;
		auto ltemp = PatternTreeLocation(this.ploc.line, this.cloc);
		while(in_escape || (!this.current.empty && this.current.front != '"'))
		{
			if(in_escape)
			{
				in_escape = false;
				temp ~= this.current.front;
			}
			else
			{
				if(this.current.front == '\\')
				{
					in_escape = true;
				}
				temp ~= this.current.front;
			}
			this.forward();
		}
		if(this.current.empty || this.current.front != '"') throw new PatternSyntaxError("Not closed literal");
		this.forward();

		return new LiteralStringNode(ltemp, temp);
	}
	auto parseExclude() in { assert(!this.current.empty && this.current.front == '!'); } body
	{
		// exclude ![element...]
		auto ltemp = PatternTreeLocation(this.ploc.line, this.cloc);
		this.forward();
		this.skipSpaces();
		return new ExcludingPatternNode(ltemp, this.parseElement());
	}

	// primitive
	void skipSpaces()
	{
		size_t ptr = 0;
		while(ptr < this.current.length && [' ', '\t', '\r', '\n'].any!(a => a == this.current[ptr])){ ++ptr; }
		this.forward(ptr);
	}

	void forward(size_t amount = 1)
	{
		auto t = this.current[amount .. $];
		this.current = t;
		this.cloc += amount;
	}
}