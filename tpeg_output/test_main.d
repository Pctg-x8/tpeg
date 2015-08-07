module com.cterm2.tpeg.sample.calc.main;

import std.stdio, std.array, std.algorithm;
import Lexer = com.cterm2.tpeg.sample.calc.lexer;

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
            auto toks = Lexer.tokenizeStr(expr);
            writeln("result: ", toks);
        }
        catch(Lexer.TokenizeError e)
        {
            writeln("Parsing Error(input \"quit\" or \"q\" to exit)\n", e);
        }
    }
}