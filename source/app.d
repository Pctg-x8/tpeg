module com.cterm2.tpeg.main;

import std.stdio;
import com.cterm2.tpeg.scriptParser;
import com.cterm2.tpeg.treeDump;
import com.cterm2.tpeg.symbolFinder;

void main(string[] args)
{
	if(args.length <= 1)
	{
		writeln("Tokenized-PEG Parser Generator version indev.");
		writeln("Usage: tpeg [InputFile]");
		return;
	}

	scope auto parser = new ScriptParser(args[1]);
	auto sourceTree = parser.run();
	scope auto sfinder = new SymbolFinder();
	sfinder.prepare(sourceTree);
	auto er = sfinder.hasError;
	if(!er)
	{
		sfinder.resolve(sourceTree);
		er = sfinder.hasError;
	}
	if(er)
	{
		writeln("one or more errors detected. generator stopped.");
		return;
	}
	scope auto dumper = new TreeDump();
	dumper.dump(sourceTree);
}
