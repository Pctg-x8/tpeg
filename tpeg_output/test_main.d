module com.cterm2.tpeg.sample.calc.main;

import std.stdio, std.array, std.algorithm, std.datetime;
//import Lexer = com.cterm2.tpeg.sample.calc.lexer;
//import Parser = com.cterm2.tpeg.sample.calc.parser;
import Lexer = com.cterm2.ml.lexer;
import Parser = com.cterm2.ml.parser;

void main()
{
    string promptedReadLine(string prompt)
    {
        write(prompt, " ");
        return readln();
    }

    string expr;
    while(!(expr = promptedReadLine(">")).empty)
    {
        if(expr == "q\n" || expr == "quit\n") break;

        try
        {
            StopWatch sw;
            sw.start();
            scope(exit)
            {
                writeln("- process time: ", sw.peek.usecs, " us.");
            }
            auto toks = Lexer.tokenize(expr[0 .. $ - 1]);
            // writeln("result: ", toks);
            auto parseRes = Parser.parse(toks);
            if(parseRes.failed)
            {
                writeln("Failed to parsing(input \"quit\" or \"q\" to exit) at ",
                    parseRes.iterError.current.location, ": type=", parseRes.iterError.current.type);
            }
            // writeln("result: ", parseRes);
        }
        catch(Lexer.TokenizeError e)
        {
            writeln("Parsing Error(input \"quit\" or \"q\" to exit)\n", e);
        }
    }
}
