module com.cterm2.tpeg.linkGraph;

// Link Graph Node Classes

import std.algorithm, std.array, std.range, std.conv, std.stdio;
import com.cterm2.tpeg.patternParser : ReduceAction;

abstract class LinkNodeBase
{
	size_t _generation;
	bool single_from_chain = false;
	LinkNodeBase[] connection_to;

	public final @property connectionTo(){ return this.connection_to; }
	public final @property generation(){ return this._generation; }
	public final @property singleFromChain(){ return this.single_from_chain; }
	public final void setRejectMultichained(){ this.single_from_chain = true; }

	public final void connectNode(LinkNodeBase p)
	{
		if(this.connection_to.find(p).empty)
		{
			writeln("[Debug]Link ", this.representation, " -> ", p.representation, "(ID=", cast(ptrdiff_t)cast(void*)p, ")");
			this.connection_to ~= p;
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

	public final override bool opEquals(Object o)
	{
		if(auto t = cast(LinkNodeBase)o) return this.representation == t.representation;
		return false;
	}
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

	public override @property string representation() { return "\"" ~ (ch < ' ' ? "\\x" ~ to!string(cast(uint)ch, 16) : ch.to!string) ~ "\"(" ~ this.generation.to!string ~ ")"; }
}
final class LinkWildcard : LinkNodeBase
{
	public override @property string representation() { return "[*](" ~ this.generation.to!string ~ ")"; }

	public this(size_t g)
	{
		super(g);
	}
}
final class LinkAcceptNode : LinkNodeBase
{
	ReduceAction reduce;

	public override @property string representation() { return "[Accept to " ~ this.reduce.to!string ~ "(" ~ this.generation.to!string ~ ")]"; }
	public this(size_t g, ReduceAction r)
	{
		super(g);
		this.reduce = r;
	}
}
final class LinkChaosNode : LinkNodeBase
{
	public override @property string representation() { return "[Chaos(" ~ this.generation.to!string ~ ")]"; }

	public this(size_t g)
	{
		super(g);
	}
}