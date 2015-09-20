module com.cterm2.tpeg.main;

import std.stdio, std.datetime, std.algorithm, std.array;
import com.cterm2.tpeg.scriptParser;
import com.cterm2.tpeg.treeDump;
import com.cterm2.tpeg.symbolFinder;
import com.cterm2.tpeg.patternParser;
import com.cterm2.tpeg.processTree;
import com.cterm2.tpeg.tokenizerGenerator;
import com.cterm2.tpeg.parserGenerator;
import com.cterm2.tpeg.parserIndexAlloc;
import Settings = com.cterm2.tpeg.settings;

enum ErrorState : int
{
	Success, Failure, NoArg = -1
}

int main(string[] args)
{
	if(args.length <= 1)
	{
		writeln("Tokenized-PEG Parser Generator version indev.");
		writeln("Usage: tpeg [-v] [-o(OutputDir)] [InputFile]");
		writeln("  (-v for verbose process)");
		writeln("  (-o for specify output directory(default is \"tpeg_output\"))");
		return ErrorState.NoArg;
	}

	bool isVerbose = args.any!(a => a == "-v");
	auto getOutputDirectoryParam = args.find!(a => a.startsWith("-o"));
	if(!getOutputDirectoryParam.empty)
	{
		Settings.setOutputDirectory(getOutputDirectoryParam.front[2 .. $]);
	}

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
		return ErrorState.Failure;
	}
	scope auto dumper = new TreeDump();
	dumper.dump(sourceTree);
	if(isVerbose) writeln("Tokenizer Pattern parsing...");
	scope auto patternParser = new PatternParser();
	patternParser.entry(sourceTree);
	if(patternParser.hasError)
	{
		writeln("one or more errors detected. generator stopped.");
		return ErrorState.Failure;
	}

	if(isVerbose) writeln("1st generating code...");
	scope auto tokenizerGenerator = new TokenizerGenerator();
	tokenizerGenerator.run(patternParser);
	if(isVerbose) writeln("allocating parser index...");
	scope auto parserIndexAllocator = new ParserIndexAllocator();
	parserIndexAllocator.entry(sourceTree);
	if(isVerbose) writeln("generating reducing process tree...");
	scope auto processTreeGen = new ProcessTreeGenerator();
	processTreeGen.entry(sourceTree);
	if(processTreeGen.hasError)
	{
		writeln("one or more errors detected. generator stopped.");
		return ErrorState.Failure;
	}
	if(isVerbose) writeln("2nd generating code...");
	scope auto parserGenerator = new ParserGenerator();
	parserGenerator.entry(sourceTree);
	sw.stop();

	if(isVerbose) writeln("done. (", sw.peek.usecs, " us)");
	return ErrorState.Success;
}
