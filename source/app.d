module com.cterm2.tpeg.main;

import std.stdio, std.datetime, std.algorithm, std.array;
import com.cterm2.tpeg.scriptParser;
import com.cterm2.tpeg.treeDump;
import com.cterm2.tpeg.symbolFinder;
import com.cterm2.tpeg.processTree;
import com.cterm2.tpeg.codegen;
import com.cterm2.tpeg.parserGenerator;

void main(string[] args)
{
	if(args.length <= 1)
	{
		writeln("Tokenized-PEG Parser Generator version indev.");
		writeln("Usage: tpeg [-v] [InputFile]");
		writeln("  (-v for verbose process)");
		return;
	}

	bool isVerbose = args.any!(a => a == "-v");

	StopWatch sw;
	sw.start();
	if(isVerbose) writeln("parsing input...");
	scope auto parser = new ScriptParser(args[1]);
	auto sourceTree = parser.run();
	if(isVerbose) writeln("symbol finding...");
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
	/*scope auto dumper = new TreeDump();
	dumper.dump(sourceTree);*/
	if(isVerbose) writeln("1st generating code...");
	scope auto codeGenerator = new CodeGenerator();
	codeGenerator.entry(sourceTree);
	if(isVerbose) writeln("generating reducing process tree...");
	scope auto processTreeGen = new ProcessTreeGenerator();
	processTreeGen.entry(sourceTree);
	if(processTreeGen.hasError)
	{
		writeln("one or more errors detected. generator stopped.");
		return;
	}
	if(isVerbose) writeln("2nd generating code...");
	scope auto parserGenerator = new ParserGenerator();
	parserGenerator.entry(sourceTree);
	sw.stop();

	if(isVerbose) writeln("done. (", sw.peek.usecs, " us)");
}
