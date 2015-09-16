module com.cterm2.tpeg.tableStructure;

import std.stdio, std.conv, std.range, std.array, std.algorithm;

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
	size_t[] stateStock;

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
	public void pushCurrentState()
	{
		this.stateStock ~= this.currentStateIndex;
	}
	public void popCurrentState()
	{
		auto st = this.stateStock.back;
		this.stateStock.popBack;
		this.setCurrentState(st);
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