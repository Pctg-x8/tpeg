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
	public override string toString() { return "s" ~ this.stateNum.to!string; }
}
class ReduceAction : TableActionBase
{
	size_t reduceNum;
	bool isSkip;

	public override @property TableActionBase dup() { return this.isSkip ? new ReduceAction() : new ReduceAction(this.reduceNum); }
	public this(size_t rn) { this.reduceNum = rn; this.isSkip = false; }
	public this() { this.reduceNum = size_t.max; this.isSkip = true; }
	public override string toString() { return "r" ~ (this.isSkip ? "X" : this.reduceNum.to!string); }
}
class ShiftTable
{
	static class ShiftState
	{
		TableActionBase[] actionList;
		TableActionBase wildcardAction;
	}
	ShiftState[] states;
	dchar[] candidates;
	size_t[dchar] candidateToIndex;
	size_t currentStateIndex;

	public @property maxIndex() pure { return this.states.length - 1; }
	public @property unescapedCandidates() pure
	{
		immutable string[dchar] unescapeMap = ['\n': "\\n", '\r': "\\r", '\t': "\\t"];
		return this.candidates.map!(a => (a in unescapeMap) ? unescapeMap[a] : a.to!string);
	}

	public auto appendNewState()
	{
		this.states ~= new ShiftState();
		this.states[$ - 1].actionList.length = this.candidates.length;
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

		if(ta.toString.front == 's')
		{
			// shift
			if(this.states[this.currentStateIndex].actionList[this.candidateToIndex[ch]] !is null)
			{
				switch(this.states[this.currentStateIndex].actionList[this.candidateToIndex[ch]].toString.front)
				{
				case 'r': writeln("Info: overwriting reduce by shift. on candidate " ~ ch.to!string ~ ", state " ~ this.currentStateIndex.to!string); break;
				case 's': throw new Exception("shift/shift conflict on candidate " ~ ch.to!string ~ ", state " ~ this.currentStateIndex.to!string);
				default: assert(0, "internal error");
				}
				
			}
		}
		else if(ta.toString.front == 'r')
		{
			// reduce
			if(this.states[this.currentStateIndex].actionList[this.candidateToIndex[ch]] !is null)
			{
				switch(this.states[this.currentStateIndex].actionList[this.candidateToIndex[ch]].toString.front)
				{
				case 'r': throw new Exception("reduce/reduce conflict on candidate " ~ ch.to!string ~ ", state " ~ this.currentStateIndex.to!string);
				case 's': writeln("Warn: overwriting shift by reduce is not allowed. ignored. on candidate " ~ ch.to!string ~ ", state " ~ this.currentStateIndex.to!string); break;
				default: assert(0, "internal error");
				}
			}
		}
		this.states[this.currentStateIndex].actionList[this.candidateToIndex[ch]] = ta.dup;
	}
	public auto registerAnyAction(TableActionBase ta)
	{
		this.states[this.currentStateIndex].wildcardAction = ta.dup;
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

// table utils
auto centering(string content, size_t totalSpace)
{
	// callable as content.centering(totalSpace)
	auto spaceLeft = (totalSpace - content.length) / 2;
	return " ".repeat(spaceLeft).join ~ content ~ " ".repeat(totalSpace - (spaceLeft + content.length)).join;
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

		writeln("--- Shift Table ---");
		{
			size_t[] columnSpaces = [[shiftTable.maxIndex.to!string.length, "state".length].reduce!max + 2];
			string[] separatorContents = ["-".repeat(columnSpaces[0]).join];
			string[] headerContents = ["state".centering(columnSpaces[0])];
			foreach(i, c; this.shiftTable.unescapedCandidates.array)
			{
				auto colChars = [c.length];
				colChars ~= this.shiftTable.states.map!(a => a.actionList[i]).map!(a => a !is null ? a.toString.length : "  ".length).array;
				columnSpaces ~= colChars.reduce!max;
				separatorContents ~= "-".repeat(columnSpaces[$ - 1]).join;
				headerContents ~= c.centering(columnSpaces[$ - 1]);
			}

			writeln("+", separatorContents.join("+"), "+");
			writeln("|", headerContents.join("|"), "|");
			writeln("+", separatorContents.join("+"), "+");
			foreach(i, c; this.shiftTable.states)
			{
				auto rowContents = [i.to!string.centering(columnSpaces[0])];
				foreach(j, a; c.actionList)
				{
					if(a !is null) rowContents ~= a.toString.centering(columnSpaces[j + 1]);
					else rowContents ~= "  ".centering(columnSpaces[j + 1]);
				}
				writeln("|", rowContents.join("|"), "|");
			}
			writeln("+", separatorContents.join("+"), "+");
		}

		writeln("--- Reduce Table ---");
		{
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

		try
		{
			scope auto generator = new ShiftTableGenerator();
			generator.generate(this.shiftTable, reduceAct, node.patternTree);
		}
		catch(Exception e)
		{
			writeln("Exception in generating pattern table: ", e.msg);
			this.has_error = true;
		}
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
		auto e_first = this.parseElement();
		if(auto e_first_seq = cast(PatternSequenceNode)e_first)
		{
			foreach(e; e_first_seq.trees) pts ~= e;
		}
		else pts ~= e_first;
		while(!this.current.empty)
		{
			this.skipSpaces();
			if(this.current.empty) break;				// end rule
			if(this.current.front == '/') break;		// fallback to switch(upper rule)
			if(this.current.front == ')') break;		// fallback to group end
			auto elm = this.parseElement();
			if(auto elm_seq = cast(PatternSequenceNode)elm)
			{
				// extract
				foreach(e; elm_seq.trees) pts ~= e;
			}
			else pts ~= elm;
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
		case '?':
			// anychar
			t = new AnyCharacterNode(PatternTreeLocation(this.ploc.line, this.cloc));
			this.forward();
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

class ShiftTableGenerator : IPatternTreeVisitor
{
	private ShiftTable shiftTable;
	private size_t newState;
	private TableActionBase currentAction;

	public void generate(ShiftTable tableTo, ReduceAction raStruct, PatternTreeBase node)
	{
		this.shiftTable = tableTo;
		this.newState = 1;
		this.shiftTable.setCurrentState(0);
		this.currentAction = raStruct;
		node.accept(this);

		// add all to reduces
		/*this.shiftTable.setCurrentState(this.currentState);
		foreach(c; this.shiftTable.candidates) this.shiftTable.registerAction(c, raStruct);
		this.shiftTable.registerAnyAction(raStruct);*/
		/*foreach(c; this.insertionReservedCandidates.uniq)
		{
			this.shiftTable.registerAction(c, raStruct);
		}
		if(this.insertionReservedToAnyChar)
		{
			this.shiftTable.registerAnyAction(raStruct);
		}
		this.insertionReservedCandidates = null;
		this.insertionReservedToAnyChar = false;*/
	}

	public override void visit(PatternSwitchNode node)
	{
		auto finalAction = this.currentAction;	// save
		foreach(n; node.trees)
		{
			this.currentAction = finalAction;
			n.accept(this);
		}
	}
	public override void visit(PatternSequenceNode node)
	{
		auto finalAction = this.currentAction;	// save
		foreach(i, n; node.trees)
		{
			auto newState = this.shiftTable.appendNewState();
			this.currentAction = new ShiftAction(newState);
			n.accept(this);
			this.shiftTable.setCurrentState(newState);
		}
	}
	public override void visit(RangedLiteralNode node)
	{
		foreach(d; node.left.content.front .. node.right.content.front + 1)
		{
			this.shiftTable.registerAction(d, this.currentAction);
		}
	}
	public override void visit(LoopQualifiedPatternNode node)
	{
		node.content.accept(this);
	}
	public override void visit(ZeroLoopQualifiedPatternNode node)
	{
		node.content.accept(this);
	}
	public override void visit(ExcludingPatternNode node)
	{
		node.content.accept(this);
	}
	public override void visit(LiteralStringNode node)
	{
		assert(node.escapedContent.length == 1);

		this.shiftTable.registerAction(node.escapedContent.front, this.currentAction);
	}
	public override void visit(AnyCharacterNode node)
	{
		this.shiftTable.registerAnyAction(this.currentAction);
	}
}