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

	public @property state(){ return this.stateNum; }
	public override @property TableActionBase dup() { return new ShiftAction(this.stateNum); }
	public this(size_t sn) { this.stateNum = sn; }
	public override string toString() { return "s" ~ this.stateNum.to!string; }
	public override bool opEquals(Object o)
	{
		if(auto t = cast(ShiftAction)o) return t.stateNum == this.stateNum;
		else return false;

	}
}
class ReduceAction : TableActionBase
{
	bool with_shift = true;
	size_t reduceNum;
	bool isSkip;

	public @property reduceIndex(){ return this.reduceNum; }

	public override @property TableActionBase dup()
	{
		auto instance = this.isSkip ? new ReduceAction() : new ReduceAction(this.reduceNum);
		instance.with_shift = this.with_shift;
		return instance;
	}
	public @property withoutShift()
	{
		auto clone = this.isSkip ? new ReduceAction() : new ReduceAction(this.reduceNum);
		clone.with_shift = false;
		return clone;
	}
	public @property withShift()
	{
		auto clone = this.isSkip ? new ReduceAction() : new ReduceAction(this.reduceNum);
		clone.with_shift = true;
		return clone;
	}
	public @property isShift() { return this.with_shift; }
	public this(size_t rn) { this.reduceNum = rn; this.isSkip = false; }
	public this() { this.reduceNum = size_t.max; this.isSkip = true; }
	public override string toString() { return (this.with_shift ? "sr" : "r") ~ (this.isSkip ? "X" : this.reduceNum.to!string); }
	public override bool opEquals(Object o)
	{
		if(auto t = cast(ReduceAction)o)
		{
			if(t.isSkip && this.isSkip) return true;
			else return ((!t.isSkip && !this.isSkip) && t.reduceNum == this.reduceNum && t.with_shift == this.with_shift);
		}
		else return false;
	}
}
class ShiftTable
{
	public static class ShiftState
	{
		public TableActionBase[] actionList;
		public TableActionBase wildcardAction;

		public @property nothing(){ return this.actionList.all!(a => a is null) && this.wildcardAction is null; }
		public @property wildcardOnly(){ return this.actionList.all!(a => a is null) && this.wildcardAction !is null; }
		public @property solid(){ return this.wildcardOnly || this.actionList.filter!(a => a !is null).count == 1; }

		public override bool opEquals(Object o)
		{
			if(auto t = cast(ShiftState)o) return t.actionList[] == this.actionList[] && t.wildcardAction == this.wildcardAction;
			return false;
		}
	}
	ShiftState[] states;
	dchar[] _candidates;
	size_t[dchar] candidateToIndex;
	size_t currentStateIndex;
	size_t[] stateStock;

	public @property maxIndex() pure { return this.states.length - 1; }
	public @property unescapedCandidates() pure
	{
		immutable string[dchar] unescapeMap = ['\n': "\\n", '\r': "\\r", '\t': "\\t"];
		return this.candidates.map!(a => (a in unescapeMap) ? unescapeMap[a] : a.to!string);
	}
	public @property candidates() pure { return this._candidates; }
	public @property stateList() pure { return this.states; }
	public auto indexFromUnescapedCandidate(string c) pure
	{
		immutable dchar[string] escapeMap = [r"\n": '\n', r"\r": '\r', r"\t": '\t'];
		return this.candidateToIndex[c in escapeMap ? escapeMap[c] : c.front];
	}

	public auto getState(size_t st) { return this.states[st]; }

	public auto appendNewState()
	{
		this.states ~= new ShiftState();
		this.states[$ - 1].actionList.length = this.candidates.length;
		return this.states.length - 1;
	}
	public auto appendNewCandidate(dchar ch)
	{
		if(ch in this.candidateToIndex) return this.candidateToIndex[ch];
		this._candidates ~= ch;
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
	public void pushCurrentState(size_t st)
	{
		this.stateStock ~= this.currentStateIndex;
		this.setCurrentState(st);
	}
	public void popCurrentState()
	{
		auto st = this.stateStock.back;
		this.stateStock.popBack;
		this.setCurrentState(st);
	}
	public auto registerAction(dchar ch, TableActionBase ta)
	{
		// Reporter Functions
		void reportInfo(string msg)
		{
			writeln("Info: ", msg, " on candidate ", ch, ", state ", this.currentStateIndex);
		}
		void reportWarn(string msg)
		{
			writeln("Warn: ", msg, " on candidate ", ch, ", state ", this.currentStateIndex);
		}
		template RaiseConflict(string type)
		{
			const RaiseConflict =
				"throw new Exception(\"" ~ type ~ "/" ~ type ~ " conflict " ~
				"on candidate \" ~ ch.to!string ~ \", state \" ~ this.currentStateIndex.to!string ~ " ~ 
				"\"(Already registered: \" ~ this.anyAction(ch).toString ~ \")\");";
		}
		if(ch !in this.candidateToIndex) this.appendNewCandidate(ch);

		if(ta is null) return;	// no place
		auto cr = this.anyAction(ch);
		if(cr !is null && ta != cr)
		{
			if(auto targetRecord = cast(ShiftAction)ta)
			{
				// shift
				if(auto currentRecord = cast(ReduceAction)cr)
				{
					// reduce -> shift
					reportInfo("overwriting reduce by shift.");
				}
				else if(auto currentRecord = cast(ShiftAction)cr)
				{
					// shift -> shift
					mixin(RaiseConflict!"shift");
				}
				else assert(false, "internal error");
			}
			else if(auto targetRecord = cast(ReduceAction)ta)
			{
				// reduce
				if(auto currentRecord = cast(ReduceAction)cr)
				{
					// reduce -> reduce
					mixin(RaiseConflict!"reduce");
				}
				else if(auto currentRecord = cast(ShiftAction)cr)
				{
					// shift -> reduce
					reportWarn("overwriting shift by reduce is not allowed. ignored.");
					return;
				}
				else assert(false, "internal error");
			}
		}
		this.states[this.currentStateIndex].actionList[this.candidateToIndex[ch]] = ta.dup;
	}
	public auto registerAnyAction(TableActionBase ta)
	{
		this.states[this.currentStateIndex].wildcardAction = ta is null ? null : ta.dup;
	}
	template actionGetter(ActionT)
	{
		public ActionT actionGetter(dchar ch)
		{
			if(ch !in this.candidateToIndex) return null;
			return cast(ActionT)this.states[this.currentStateIndex].actionList[this.candidateToIndex[ch]];
		}
		public ActionT actionGetter()
		{
			return cast(ActionT)this.states[this.currentStateIndex].wildcardAction;
		}
	}
	public alias anyAction = actionGetter!TableActionBase;
	public alias shift = actionGetter!ShiftAction;
	public alias reduce = actionGetter!ReduceAction;

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

	public @property reduceTargetNames(){ return this.reduceTargets; }
	public auto reduceTargetName(size_t index) { return this.reduceTargets[index]; }

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