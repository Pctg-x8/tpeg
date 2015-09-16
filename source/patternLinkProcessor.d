module com.cterm2.tpeg.patternLinkProcessor;

import com.cterm2.tpeg.tree, com.cterm2.tpeg.visitor;
import com.cterm2.tpeg.patternParser;
import com.cterm2.tpeg.patternTree;
import com.cterm2.tpeg.linkGraph;
import std.stdio, std.algorithm, std.array, std.range;

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
		foreach(p; this.lastObjects) p.connectNodes(this.firstObjects);		// Loop junction
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
			auto obj = new LinkCharacter(this.currentGeneration, c);

			if(!this.linkBranched)
			{
				auto finder = this.generationPartedObjects[this.currentGeneration]
					.filter!(a => !a.singleFromChain /*Multichainable*/ || this.currentParents.any!(b => !b.connectionTo.find(a).empty) /*Parent is active*/).find(obj);
				if(finder.empty)
				{
					// Branch
					this.linkBranched = true;
					writeln("Branch Link.");

					obj.setRejectMultichained();
					this.generationPartedObjects[this.currentGeneration] ~= obj;
					foreach(p; this.currentParents) p.connectNode(obj);
					this.firstObjects ~= obj;
					this.lastObjects ~= obj;
				}
				else
				{
					// Single path
					foreach(p; this.currentParents) p.connectNode(finder.front);
					this.firstObjects ~= finder.front;
					this.lastObjects ~= finder.front;
				}
			}
			else
			{
				// Branched
				obj.setRejectMultichained();
				this.generationPartedObjects[this.currentGeneration] ~= obj;
				foreach(p; this.currentParents) p.connectNode(obj);
				this.firstObjects ~= obj;
				this.lastObjects ~= obj;
			}
		}
		this.currentGeneration++;
	}
	public override void visit(LiteralStringNode node)
	{
		if(this.currentGeneration !in this.generationPartedObjects) this.generationPartedObjects[this.currentGeneration] = null;
		auto obj = new LinkCharacter(this.currentGeneration, node.escapedContent.front);

		if(!this.linkBranched)
		{
			auto finder = this.generationPartedObjects[this.currentGeneration]
				.filter!(a => !a.singleFromChain /*Multichainable*/ || this.currentParents.any!(b => !b.connectionTo.find(a).empty) /*Parent is active*/).find(obj);
			if(finder.empty)
			{
				// Branch
				this.linkBranched = true;
				writeln("Branch Link.");

				obj.setRejectMultichained();
				this.generationPartedObjects[this.currentGeneration] ~= obj;
				foreach(p; this.currentParents) p.connectNode(obj);
				this.firstObjects ~= obj;
				this.lastObjects ~= obj;
			}
			else
			{
				// Single path
				foreach(p; this.currentParents) p.connectNode(finder.front);
				this.firstObjects ~= finder.front;
				this.lastObjects ~= finder.front;
			}
		}
		else
		{
			// Branched
			obj.setRejectMultichained();
			this.generationPartedObjects[this.currentGeneration] ~= obj;
			foreach(p; this.currentParents) p.connectNode(obj);
			this.firstObjects ~= obj;
			this.lastObjects ~= obj;
		}
		this.currentGeneration++;
	}
	public override void visit(AnyCharacterNode node)
	{
		if(this.currentGeneration !in this.generationPartedObjects) this.generationPartedObjects[this.currentGeneration] = null;
		auto obj = new LinkWildcard(this.currentGeneration);

		if(!this.linkBranched)
		{
			auto finder = this.generationPartedObjects[this.currentGeneration]
				.filter!(a => !a.singleFromChain /*Multichainable*/ || this.currentParents.any!(b => !b.connectionTo.find(a).empty) /*Parent is active*/).find(obj);
			if(finder.empty)
			{
				// Branch
				this.linkBranched = true;
				writeln("Branch Link.");

				obj.setRejectMultichained();
				this.generationPartedObjects[this.currentGeneration] ~= obj;
				foreach(p; this.currentParents) p.connectNode(obj);
				this.firstObjects ~= obj;
				this.lastObjects ~= obj;
			}
			else
			{
				// Single path
				foreach(p; this.currentParents) p.connectNode(finder.front);
				this.firstObjects ~= finder.front;
				this.lastObjects ~= finder.front;
			}
		}
		else
		{
			// Branched
			obj.setRejectMultichained();
			this.generationPartedObjects[this.currentGeneration] ~= obj;
			foreach(p; this.currentParents) p.connectNode(obj);
			this.firstObjects ~= obj;
			this.lastObjects ~= obj;
		}
		this.currentGeneration++;
	}
}
