module com.cterm2.tpeg.linkGraph;

// Link Graph Node Classes

import std.algorithm, std.array, std.range, std.conv, std.stdio;
import com.cterm2.tpeg.tableStructure;

abstract class LinkNodeBase : ILinkNodeAcceptor
{
	size_t _generation;
	bool single_from_chain = false;
	LinkNodeBase[] connection_to, connected_from;
	size_t node_transit_state;
	bool has_transit = false;

	public final @property connectionTo(){ return this.connection_to; }
	public final @property connectedFrom(){ return this.connected_from; }
	public final @property generation(){ return this._generation; }
	public final @property singleFromChain(){ return this.single_from_chain; }
	public final void setRejectMultichained(){ this.single_from_chain = true; }
	public final @property nodeTransitState(){ return this.node_transit_state; }
	public final void updateTransitState(size_t nts)
	in { assert(!this.has_transit); }
	body { this.node_transit_state = nts; this.has_transit = true; }
	public final @property hasTransitState(){ return this.has_transit; }

	public final void connectNode(LinkNodeBase p)
	{
		if(this.connection_to.find(p).empty)
		{
			// writeln("[Debug]Link ", this.representation, "(ID=", cast(void*)this, ") -> ", p.representation, "(ID=", cast(void*)p, ")");
			this.connection_to ~= p;
			p.connected_from ~= this;
		}
		else
		{
			// writeln("[Debug]Linked ", this.representation, "(ID=", cast(void*)this, ") -> ", p.representation, "(ID=", cast(void*)p, ")");
		}
	}
	public final void connectNodes(LinkNodeBase[] p)
	{
		p.each!(a => this.connectNode(a))();
	}

	public this(size_t g)
	{
		this._generation = g;
	}

	public final void dump(size_t indent, LinkNodeBase[] dumpedObjects = null)
	{
		if(!dumpedObjects.find(this).empty) return;

		foreach(c; this.connectionTo)
		{
			writeln(" ".repeat(indent).join, this.representation, " -> ", c.representation);
			if(c.generation > this.generation)
			{
				c.dump(indent + 1, dumpedObjects ~ this);
			}
		}
		// this.connectionTo.filter!(c => c.generation > this.generation).each!(c => c.dump(indent + 1, dumpedObjects ~ this));
	}
	public abstract @property string representation();
	public abstract @property string rawRepresentation();

	public final override bool opEquals(Object o)
	{
		if(auto t = cast(LinkNodeBase)o) return this.rawRepresentation == t.rawRepresentation;
		return false;
	}

	mixin LinkNodeAcceptorImpl;
}

final class LinkCharacter : LinkNodeBase
{
	dchar ch;

	public @property character(){ return this.ch; }

	public this(size_t g, dchar c)
	{
		super(g);
		this.ch = c;
	}

	public override @property string representation() { return this.rawRepresentation ~ "(" ~ this.generation.to!string ~ ")"; }
	public override @property string rawRepresentation() { return "\"" ~ (ch < ' ' ? "\\x" ~ to!string(cast(uint)ch, 16) : ch.to!string) ~ "\""; }

	mixin LinkNodeAcceptorImpl;
}
final class LinkWildcard : LinkNodeBase
{
	public override @property string representation() { return "[*](" ~ this.generation.to!string ~ ")"; }
	public override @property string rawRepresentation(){ return "[*]"; }

	public this(size_t g)
	{
		super(g);
	}

	mixin LinkNodeAcceptorImpl;
}
final class LinkAcceptNode : LinkNodeBase
{
	ReduceAction reduce;

	public override @property string representation() { return "[Accept to " ~ this.reduce.to!string ~ "(" ~ this.generation.to!string ~ ")]"; }
	public override @property string rawRepresentation() { return "[Accept to " ~ this.reduce.to!string ~ "]"; }
	public @property reduceAction(){ return this.reduce; }
	
	public this(size_t g, ReduceAction r)
	{
		super(g);
		this.reduce = r;
	}

	mixin LinkNodeAcceptorImpl;
}
final class LinkChaosNode : LinkNodeBase
{
	public override @property string representation() { return "[Chaos(" ~ this.generation.to!string ~ ")]"; }
	public override @property string rawRepresentation(){ return "[Chaos]"; }

	public this(size_t g)
	{
		super(g);
	}

	mixin LinkNodeAcceptorImpl;
}

interface ILinkNodeVisitor
{
	public void visit(LinkCharacter);
	public void visit(LinkWildcard);
	public void visit(LinkAcceptNode);
	public void visit(LinkChaosNode);

	public final void visit(LinkNodeBase) { assert(false); }
}
interface ILinkNodeAcceptor
{
	public void accept(ILinkNodeVisitor v);
}

mixin template LinkNodeAcceptorImpl()
{
	public override void accept(ILinkNodeVisitor v) { v.visit(this); }
}