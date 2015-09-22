module com.cterm2.tpeg.patternLinkProcessor;

import com.cterm2.tpeg.tree, com.cterm2.tpeg.visitor;
import com.cterm2.tpeg.patternParser;
import com.cterm2.tpeg.patternTree;
import com.cterm2.tpeg.linkGraph;
import com.cterm2.tpeg.tableStructure;
import std.stdio, std.algorithm, std.array, std.range, std.conv;
import std.variant;

class LinkGenerator : IPatternTreeVisitor
{
	alias GenerationRow = LinkNodeBase[];

	private GenerationRow[size_t] generationPartedObjects;
	private size_t currentGeneration;
	private LinkNodeBase[] firstObjects, lastObjects, currentParents;
	private LinkChaosNode root;
	private size_t maxGenerationIndex;
	private bool linkBranched;

	public @property rootNode() { return this.root; }

	public this()
	{
		this.root = new LinkChaosNode(0);
	}
	public void generate(PatternTreeBase node, ReduceAction acceptor)
	{
		this.linkBranched = false;
		this.currentGeneration = 1;
		this.currentParents = [this.root];
		this.maxGenerationIndex = 0;
		this.lastObjects = null;
		this.firstObjects = null;
		node.accept(this);
		auto reduceNode = new LinkAcceptNode(this.currentGeneration + 1, acceptor);
		foreach(p; this.lastObjects) p.connectNode(reduceNode);
	}

	// IPatternTreeVisitor impl //
	public override void visit(PatternSwitchNode node)
	{
		auto savedParents = this.currentParents;
		LinkNodeBase[] aggregatedFirstObjects, aggregatedLastObjects;
		auto inGeneration = this.currentGeneration, maxGeneration = this.currentGeneration;

		foreach(n; node.trees)
		{
			this.firstObjects = null;
			this.lastObjects = null;
			this.currentParents = savedParents;
			this.currentGeneration = inGeneration;
			n.accept(this);
			maxGeneration = [maxGeneration, this.currentGeneration].reduce!max;
			aggregatedFirstObjects ~= this.firstObjects;
			aggregatedLastObjects ~= this.lastObjects;
		}
		this.currentGeneration = maxGeneration;
		this.firstObjects = aggregatedFirstObjects;
		this.lastObjects = aggregatedLastObjects;
	}
	public override void visit(PatternSequenceNode node)
	{
		LinkNodeBase[] first;

		foreach(i, n; node.trees)
		{
			this.firstObjects = null;
			this.lastObjects = null;
			n.accept(this);
			this.currentParents = this.lastObjects;
			if(i == 0) first = this.firstObjects;
		}
		this.firstObjects = first;
	}
	public override void visit(LoopQualifiedPatternNode node)
	{
		this.firstObjects = null;
		this.lastObjects = null;
		node.content.accept(this);

		// -- ZeroLoopQualifiedPatternNode -- //
		auto savedFirstObjects = this.firstObjects;
		this.currentParents = this.lastObjects;
		auto savedParents = this.currentParents;
		this.firstObjects = null;
		this.lastObjects = null;
		node.content.accept(this);
		foreach(p; this.lastObjects) p.connectNodes(this.firstObjects);		// Loop junction
		this.lastObjects ~= savedParents;		// junction
		this.firstObjects = savedFirstObjects;
	}
	public override void visit(ZeroLoopQualifiedPatternNode node)
	{
		auto savedParents = this.currentParents;
		this.firstObjects = null;
		this.lastObjects = null;
		node.content.accept(this);
		foreach(p; this.lastObjects) p.connectNodes(this.firstObjects);		// Loop junction
		this.lastObjects ~= savedParents;		// junction
	}
	public override void visit(ExcludingPatternNode node)
	{
		this.firstObjects = null;
		this.lastObjects = null;
		node.content.accept(this);
	}
	public override void visit(RangedLiteralNode node)
	{
		if(this.currentGeneration !in this.generationPartedObjects) this.generationPartedObjects[this.currentGeneration] = null;
		foreach(c; node.left.escapedContent.front .. node.right.escapedContent.front + 1)
		{
			LinkNodeBase obj = new LinkCharacter(this.currentGeneration, c);

			if(!this.linkBranched)
			{
				LinkNodeBase[] linkedObjects;
				this.currentParents.map!(a => a.connectionTo).each!(a => linkedObjects ~= a.filter!(b => b == obj).array);
				linkedObjects = linkedObjects.uniq!q{cast(void*)a == cast(void*)b}.array;

				if(!linkedObjects.empty)
				{
					// use
					assert(linkedObjects.length == 1);
					obj = linkedObjects.front;
				}
				else
				{
					this.linkBranched = true;
					// branch
					// writeln("Branch link.");
				}
			}
			else
			{
				// writeln("Branched connection...");
			}

			this.currentParents.each!(a => a.connectNode(obj));
			this.firstObjects ~= obj;
			this.lastObjects ~= obj;
		}
		this.currentGeneration++;
	}
	public override void visit(LiteralStringNode node)
	{
		if(this.currentGeneration !in this.generationPartedObjects) this.generationPartedObjects[this.currentGeneration] = null;
		LinkNodeBase obj = new LinkCharacter(this.currentGeneration, node.escapedContent.front);

		if(!this.linkBranched)
		{
			LinkNodeBase[] linkedObjects;
			this.currentParents.map!(a => a.connectionTo).each!(a => linkedObjects ~= a.filter!(b => b == obj).array);
			linkedObjects = linkedObjects.uniq!q{cast(void*)a == cast(void*)b}.array;

			if(!linkedObjects.empty)
			{
				// use
				assert(linkedObjects.length == 1);
				obj = linkedObjects.front;
			}
			else
			{
				this.linkBranched = true;
				// branch
				// writeln("Branch link.");
			}
		}
		else
		{
			// writeln("Branched connection...");
		}

		this.currentParents.each!(a => a.connectNode(obj));
		this.firstObjects ~= obj;
		this.lastObjects ~= obj;
		this.currentGeneration++;
	}
	public override void visit(AnyCharacterNode node)
	{
		if(this.currentGeneration !in this.generationPartedObjects) this.generationPartedObjects[this.currentGeneration] = null;
		LinkNodeBase obj = new LinkWildcard(this.currentGeneration);

		if(!this.linkBranched)
		{
			LinkNodeBase[] linkedObjects;
			this.currentParents.map!(a => a.connectionTo).each!(a => linkedObjects ~= a.filter!(b => b == obj).array);
			linkedObjects = linkedObjects.uniq!q{cast(void*)a == cast(void*)b}.array;

			if(!linkedObjects.empty)
			{
				// use
				assert(linkedObjects.length == 1);
				obj = linkedObjects.front;
			}
			else
			{
				this.linkBranched = true;
				// branch
				// writeln("Branch link.");
			}
		}
		else
		{
			// writeln("Branched connection...");
		}

		this.currentParents.each!(a => a.connectNode(obj));
		this.firstObjects ~= obj;
		this.lastObjects ~= obj;
		this.currentGeneration++;
	}
}

// table utils
auto centering(string content, size_t totalSpace)
{
	// callable as content.centering(totalSpace)
	auto spaceLeft = (totalSpace - content.length) / 2;
	return " ".repeat(spaceLeft).join ~ content ~ " ".repeat(totalSpace - (spaceLeft + content.length)).join;
}

class ShiftTableGenerator
{
	ShiftTable table;
	public @property shiftTable(){ return this.table; }

	public void generate(LinkNodeBase base)
	{
		this.table = new ShiftTable();

		(new ShiftTableStateAllocator).generate(base);
		(new ShiftTableActionWriter).generate(base);
		auto opt = new Optimizer;
		opt.run();
		this.table = opt.newTable;
	}

	class ShiftTableStateAllocator : ILinkNodeVisitor
	{
		public void generate(LinkNodeBase node)
		{
			node.accept(this);
		}

		// ILinkNodeVisitor //
		public override void visit(LinkCharacter node) in { assert(!node.hasTransitState); } body
		{
			// writeln("Generating state for generation ", node.generation, "(", node.character, ")...");

			if(!node.hasTransitState)
			{
				node.updateTransitState(table.appendNewState());
				writeln("[Debug]Allocate state ", node.nodeTransitState, " for ", node.representation);
				node.connectionTo.each!(n => n.accept(this));
			}
		}
		public override void visit(LinkWildcard node) in { assert(!node.hasTransitState); } body
		{
			// writeln("Generating state for generation ", node.generation, "(WILDCARD)...");

			if(!node.hasTransitState)
			{
				node.updateTransitState(table.appendNewState());
				node.connectionTo.each!(n => n.accept(this));
			}
		}
		public override void visit(LinkAcceptNode node)
		{
			// writeln("Generating Accept(Ignored in this phase)");
		}
		public override void visit(LinkChaosNode node)
		{
			node.connectionTo.each!(n => n.accept(this));
		}
	}
	class ShiftTableActionWriter : ILinkNodeVisitor
	{
		bool isDescendent;
		string[] debugLinkLog;
		public void generate(LinkNodeBase node)
		{
			this.isDescendent = true;
			this.debugLinkLog = null;
			try
			{
				node.accept(this);
			}
			catch(Exception e)
			{
				writeln(e);
				writeln("LinkLog: ", this.debugLinkLog.join("->"));
			}
		}

		// ILinkNodeVisitor //
		public override void visit(LinkCharacter node) in { assert(node.hasTransitState); } body
		{
			this.debugLinkLog ~= "\"" ~ node.character.to!string ~ "\"";

			// writeln("Shift to ", node.nodeTransitState, ": LinkLog=", this.debugLinkLog.join("->"));
			table.registerAction(node.character, new ShiftAction(node.nodeTransitState));
			if(this.isDescendent)
			{
				table.pushCurrentState(node.nodeTransitState);
				node.connectionTo.filter!(a => a.generation > node.generation).each!(n => n.accept(this));
				this.isDescendent = false;
				node.connectionTo.filter!(a => a.generation <= node.generation).each!(n => n.accept(this));
				this.isDescendent = true;
				table.popCurrentState();
			}

			this.debugLinkLog.popBack;
		}
		public override void visit(LinkWildcard node) in { assert(node.hasTransitState); } body
		{
			this.debugLinkLog ~= "[*]";

			// writeln("Shift to ", node.nodeTransitState, ": LinkLog=", this.debugLinkLog.join("->"));
			table.registerAnyAction(new ShiftAction(node.nodeTransitState));
			if(this.isDescendent)
			{
				table.pushCurrentState(node.nodeTransitState);
				node.connectionTo.filter!(a => a.generation > node.generation).each!(n => n.accept(this));
				this.isDescendent = false;
				node.connectionTo.filter!(a => a.generation <= node.generation).each!(n => n.accept(this));
				this.isDescendent = true;
				table.popCurrentState();
			}

			this.debugLinkLog.popBack;
		}
		public override void visit(LinkAcceptNode node)
		{
			// reduce
			this.debugLinkLog ~= node.representation;

			// writeln("Reduce to ", node.reduceAction.toString, ": LinkLog=", this.debugLinkLog.join("->"));
			table.registerAnyAction(node.reduceAction.withoutShift);

			this.debugLinkLog.popBack;
		}
		public override void visit(LinkChaosNode node)
		{
			node.connectionTo.each!(n => n.accept(this));
		}
	}

	class Optimizer
	{
		struct ShiftStateTranslated
		{
			size_t stateFrom, stateTo;

			public auto toString(){ return "st" ~ this.stateFrom.to!string ~ "(placed to st" ~ this.stateTo.to!string ~ ")"; }
		}
		alias ConversionTarget = Algebraic!(ShiftStateTranslated, ShiftAction, ReduceAction);
		ShiftTable newTable;
		ConversionTarget[size_t] conversionTable;
		size_t[] reservedStateLines;

		public void run()
		{
			writeln("--- Shift Table(old) ---");
			{
				size_t[] columnSpaces = [[table.maxIndex.to!string.length, "state".length].reduce!max + 2];
				string[] separatorContents = ["-".repeat(columnSpaces[0]).join];
				string[] headerContents = ["state".centering(columnSpaces[0])];
				foreach(i, c; table.unescapedCandidates.array)
				{
					auto colChars = [c.length];
					colChars ~= table.states.map!(a => a.actionList[i]).map!(a => a !is null ? a.toString.length : "  ".length).array;
					columnSpaces ~= colChars.reduce!max;
					separatorContents ~= "-".repeat(columnSpaces[$ - 1]).join;
					headerContents ~= c.centering(columnSpaces[$ - 1]);
				}
				{
					// Cell for Wildcard(Default Behavior)
					auto colChars = ["[*]".length];
					colChars ~= table.states.map!(a => a.wildcardAction).map!(a => a !is null ? a.toString.length : "  ".length).array;
					columnSpaces ~= colChars.reduce!max;
					separatorContents ~= "-".repeat(columnSpaces[$ - 1]).join;
					headerContents ~= "[*]".centering(columnSpaces[$ - 1]);
				}


				writeln("+", separatorContents.join("+"), "+");
				writeln("|", headerContents.join("|"), "|");
				writeln("+", separatorContents.join("+"), "+");
				foreach(i, c; table.states)
				{
					auto rowContents = [i.to!string.centering(columnSpaces[0])];
					foreach(j, a; c.actionList)
					{
						if(a !is null) rowContents ~= a.toString.centering(columnSpaces[j + 1]);
						else rowContents ~= "  ".centering(columnSpaces[j + 1]);
					}
					rowContents ~= (c.wildcardAction !is null ? c.wildcardAction.toString : "  ").centering(columnSpaces[$ - 1]);
					writeln("|", rowContents.join("|"), "|");
				}
				writeln("+", separatorContents.join("+"), "+");
			}

			this.newTable = new ShiftTable;
			this.conversionTable = null;
			this.reservedStateLines = null;
			this.conversionTable[0] = ShiftStateTranslated(0, 0);
			foreach(i, st; table.stateList[1 .. $])
			{
				if(st.actionList.all!(a => a is null))
				{
					if(auto re = cast(ReduceAction)st.wildcardAction)
					{
						if(!re.isShift)
						{
							this.conversionTable[i + 1] = re.withShift;
							continue;
						}
					}
				}
				auto preservedLine = this.reservedStateLines.filter!(a => table.getState(a) == st);
				if(!preservedLine.empty)
				{
					this.conversionTable[i + 1] = new ShiftAction(preservedLine.front);
					continue;
				}
				this.reservedStateLines ~= i + 1;
				auto newState = this.newTable.appendNewState();
				this.conversionTable[i + 1] = ShiftStateTranslated(i + 1, newState);
			}

			/*writeln("--Optimizer Conversion Table---");
			foreach(from; this.conversionTable.keys.sort!"a < b")
			{
				writeln("-- s", from, " -> ", this.conversionTable[from]);
			}*/

			// replace all shift actions and place new state lines
			// state 0(specialize)
			this.newTable.setCurrentState(0);
			table.setCurrentState(0);
			table.candidates.each!(c => this.copyState(c));
			this.copyState();
			// other states
			foreach(st_conv; this.conversionTable.values.filter!(a => a.type == typeid(ShiftStateTranslated)).map!(a => a.get!ShiftStateTranslated))
			{
				this.newTable.setCurrentState(st_conv.stateTo);
				table.setCurrentState(st_conv.stateFrom);
				table.candidates.each!(c => this.copyState(c));
				this.copyState();
			}
		}

		private void copyState(dchar c)
		{
			// writeln("copying ", c, ": ", table.anyAction(c), "...");
			this.newTable.registerAction(c, this.determineAction(table.anyAction(c)));
		}
		private void copyState()
		{
			// writeln("copying [*]: ", table.anyAction(), "...");
			this.newTable.registerAnyAction(this.determineAction(table.anyAction()));
		}
		private TableActionBase determineAction(TableActionBase ta)
		{
			if(ta is null) return null;
			if(auto sh = cast(ShiftAction)ta)
			{
				auto convTo = this.conversionTable[sh.state];
				if(convTo.type == typeid(ReduceAction)) return convTo.get!ReduceAction;	// new reduce
				else if(convTo.type == typeid(ShiftAction))
				{
					if(this.conversionTable[convTo.get!ShiftAction.state].type == typeid(ShiftStateTranslated))
					{
						// new shift(replaced)
						auto convertedState = this.conversionTable[convTo.get!ShiftAction.state].get!ShiftStateTranslated.stateTo;
						return new ShiftAction(convertedState);
					}
					else assert(false);
				}
				else return new ShiftAction(convTo.get!ShiftStateTranslated.stateTo);
			}
			else return ta;
		}
	}
}
