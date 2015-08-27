module com.cterm2.tpeg.parserGenerator;

import settings = com.cterm2.tpeg.settings;
import com.cterm2.tpeg.visitor;
import com.cterm2.tpeg.tree;
import com.cterm2.tpeg.processTree;
import std.stdio, std.path, std.array, std.algorithm, std.regex, std.range;
import std.conv;

void writeModuleName(File f, string[] modulePath) in { assert(f.isOpen); } body
{
    f.writeln("module ", modulePath.join("."), ";");
}
void writeImports(File f, string[][] importPaths) in { assert(f.isOpen); } body
{
    f.writeln("import ", importPaths.map!(a => a.join(".")).join(", "), ";");
}
string toTabs(uint indent){ return "\t".repeat(indent).join(); }
void writeDeclarationBegin(File f, uint indent, string[] qualifiers, string type, string name, string[] templateParameters = null, string inheritFrom = null)
in { assert(f.isOpen); } body
{
    f.write(indent.toTabs, qualifiers.join(" "), " ", type, " ", name);
    if(templateParameters !is null)
    {
        f.write("(", templateParameters.join(", "), ")");
    }
    if(inheritFrom !is null)
    {
        f.write(" : ", inheritFrom);
    }
    f.writeln();
    f.writeln(indent.toTabs, "{");
}
void writeField(File f, uint indent, string type, string name) in { assert(f.isOpen); } body
{
    f.writeln(indent.toTabs, type, " ", name, ";");
}
void writeAutoProperty(File f, uint indent, string[] qualifier, string name, string expr) in { assert(f.isOpen); } body
{
    f.writeln(indent.toTabs, qualifier.join(" "), " @property ", name, "(){ return ", expr, "; }");
}
void writeReadonlyExport(File f, uint indent, string name) in { assert(f.isOpen); } body
{
    auto rxUpper = ctRegex!(r"[A-Z]");
    auto vname = "_" ~ name;
    if(!name.match(rxUpper).empty) vname = name.replaceAll(rxUpper, "_$&");
    f.writeAutoProperty(indent, ["public"], name, vname);
}
void writeConstructorBegin(File f, uint indent, string[] qualifiers, string[][] args)
in { assert(f.isOpen); } body
{
    f.writeln(indent.toTabs, qualifiers.join(" "), " this(", args.map!(a => a.join(" ")).join(", "), ")");
    f.writeln(indent.toTabs, "{");
}
void writeDeclarationEnd(File f, uint indent) in { assert(f.isOpen); } body
{
    f.writeln(indent.toTabs, "}");
}

// lazy requirement generators //
void generateRuleParser(File f) in { assert(f.isOpen); } body
{
    f.writeDeclarationBegin(1, ["private", "static"], "class", "RuleParser", ["string Name", "alias PrimaryParser"]);
    f.writeln(2.toTabs, "private alias ResultType = Result!(RuleTree!Name);");
    f.writeln(2.toTabs, "private static ResultType[TokenIterator] _memo;");
    f.writeln();
    f.writeln(2.toTabs, "public static ResultType parse(TokenIterator r)");
    f.writeln(2.toTabs, "{");
    f.writeln(3.toTabs, "if((r in _memo) is null)");
    f.writeln(3.toTabs, "{");
    f.writeln(4.toTabs, "// register new result");
    f.writeln(4.toTabs, "auto res = PrimaryParser.parse(r);");
    f.writeln(4.toTabs, "if(res.succeeded) _memo[r] = ResultType(true, res.iterNext, res.iterError, new RuleTree!Name(res.value));");
    f.writeln(4.toTabs, "else _memo[r] = ResultType(false, r, res.iterError);");
    f.writeDeclarationEnd(3);
    f.writeln();
    f.writeln(3.toTabs, "return _memo[r];");
    f.writeDeclarationEnd(2);
    f.writeDeclarationEnd(1);
}
void generatePartialParserHeaderTemplate(File f) in { assert(f.isOpen); } body
{
    f.writeDeclarationBegin(1, ["private"], "template", "PartialParserHeader", ["alias InternalParserMethod"]);
    f.writeln(2.toTabs, "private static ResultType[TokenIterator] _memo;");
    f.writeln();
    f.writeln(2.toTabs, "public static ResultType parse(TokenIterator r)");
    f.writeln(2.toTabs, "{");
    f.writeln(3.toTabs, "if((r in _memo) is null) _memo[r] = InternalParserMethod(r);");
    f.writeln(3.toTabs, "return _memo[r];");
    f.writeDeclarationEnd(2);
    f.writeDeclarationEnd(1);
}
void generateElementParser(File f) in { assert(f.isOpen); } body
{
    f.writeDeclarationBegin(1, ["private", "static"], "class", "ElementParser", ["EnumTokenType ParseE"]);
    f.writeln(2.toTabs, "private alias ResultType = Result!TokenTree;");
    f.writeln(2.toTabs, "private static ResultType[TokenIterator] _memo;");
    f.writeln();
    f.writeln(2.toTabs, "public static ResultType parse(TokenIterator r)");
    f.writeln(2.toTabs, "{");
    f.writeln(3.toTabs, "if((r in _memo) is null)");
    f.writeln(3.toTabs, "{");
    f.writeln(4.toTabs, "// register new result");
    f.writeln(4.toTabs, "if(r.current.type == ParseE)");
    f.writeln(4.toTabs, "{");
    f.writeln(5.toTabs, "_memo[r] = ResultType(true, TokenIterator(r.pos + 1, r.token), TokenIterator(r.pos + 1, r.token), new TokenTree(r.current));");
    f.writeDeclarationEnd(4);
    f.writeln(4.toTabs, "else");
    f.writeln(4.toTabs, "{");
    f.writeln(5.toTabs, "_memo[r] = ResultType(false, r, TokenIterator(r.pos + 1, r.token));");
    f.writeDeclarationEnd(4);
    f.writeDeclarationEnd(3);
    f.writeln();
    f.writeln(3.toTabs, "return _memo[r];");
    f.writeDeclarationEnd(2);
    f.writeDeclarationEnd(1);
}
void writePartialParserHeader(File f, string className, string ruleIdentifier, uint complexRuleOrdinal) in { assert(f.isOpen); } body
{
    f.writeDeclarationBegin(1, ["private", "static"], "class", className);
    f.writeln(2.toTabs, "// id=", ruleIdentifier);
    f.writeln(2.toTabs, "private alias PartialTreeType = PartialTree!", complexRuleOrdinal.to!string, ";");
    f.writeln(2.toTabs, "private alias ResultType = Result!PartialTreeType;");
    f.writeln(2.toTabs, "mixin PartialParserHeader!innerParse;");
    f.writeln();
    f.writeln(2.toTabs, "private static ResultType innerParse(TokenIterator r)");
    f.writeln(2.toTabs, "{");
}
void writePartialParserFooter(File f) in { assert(f.isOpen); } body
{
    f.writeDeclarationEnd(2);
    f.writeDeclarationEnd(1);
}

enum EnumCurrentState
{
    None, GenerateParsingStructures, GenerateParserClassName, GenerateParserUsingCode, GenerateReduceMethods
}

class ParserGenerator : IVisitor
{
    // Parser Generator
    string[] packageName;
    string lexerModuleName;
    File currentFile;
    EnumCurrentState currentState;
    string[] parseClassDefinedList;
    ProcessGenerator pProcessGenerator;

    public void entry(ScriptNode node)
    {
        this.packageName = null;
        this.lexerModuleName = "tokenizer";
        this.currentState = EnumCurrentState.None;

        node.accept(this);
    }
    private void acquirePartialParserHeaderTemplate()
    {
        if(!this.parseClassDefinedList.any!(a => a == "PartialParserHeader"))
        {
            this.parseClassDefinedList ~= "PartialParserHeader";
            this.currentFile.generatePartialParserHeaderTemplate();
        }
    }

    // IVisitor //
    public void visit(ScriptNode node)
    {
        this.packageName = node.packageName;
        if(node.tokenizer !is null) this.lexerModuleName = node.tokenizer.moduleName;
        if(node.parser !is null) node.parser.accept(this);
    }
    public void visit(TokenizerNode node){ assert(false); }
    public void visit(PatternNode node){ assert(false); }

    public void visit(ParserNode node) in { assert(!this.currentFile.isOpen); } body
    {
        this.parseClassDefinedList = null;

        this.pProcessGenerator = new ProcessGenerator();
        this.currentFile.open(buildPath(settings.OutputDirectory, node.moduleName ~ ".d"), "w");
        this.currentFile.writeModuleName(this.packageName ~ node.moduleName);
        this.currentFile.writeln();
        this.currentFile.writeImports([this.packageName ~ this.lexerModuleName]);
        this.currentFile.writeImports([["std", "array"], ["std", "algorithm"]]);
        this.currentFile.writeln();
        if(!node.headerPart.empty)
        {
            // write user-defined header
            this.currentFile.writeln("// Header part from user tpeg file //");
            this.currentFile.writeln(node.headerPart);
            this.currentFile.writeln();
        }

        // declare utilities //
        this.currentFile.writeDeclarationBegin(0, ["public"], "struct", "TokenIterator");
        this.currentFile.writeField(1, "size_t", "pos");
        this.currentFile.writeField(1, "Token[]", "token");
        this.currentFile.writeln();
        this.currentFile.writeAutoProperty(1, [], "current", q{pos >= token.length ? token[$ - 1] : token[pos]});
        this.currentFile.writeln();
        this.currentFile.writeln(1.toTabs, "size_t toHash() const @safe pure nothrow { return pos; }");
        this.currentFile.writeln(1.toTabs, "bool opEquals(ref const TokenIterator iter) const @safe pure nothrow");
        this.currentFile.writeln(1.toTabs, "{");
        this.currentFile.writeln(2.toTabs, "return pos == iter.pos && token.ptr == iter.token.ptr;");
        this.currentFile.writeln(1.toTabs, "}");
        this.currentFile.writeDeclarationEnd(0);

        this.currentFile.writeDeclarationBegin(0, ["public"], "struct", "Result", ["ValueType : ISyntaxTree"]);
        this.currentFile.writeField(1, "bool", "succeeded");
        this.currentFile.writeField(1, "TokenIterator", "iterNext");
        this.currentFile.writeField(1, "TokenIterator", "iterError");
        this.currentFile.writeField(1, "ValueType", "value");
        this.currentFile.writeln();
        this.currentFile.writeAutoProperty(1, [], "failed", q{!succeeded});
        this.currentFile.writeln();
        this.currentFile.writeln(1.toTabs, "auto opAssign(T : ISyntaxTree)(Result!T val)");
        this.currentFile.writeln(1.toTabs, "{");
        this.currentFile.writeln(2.toTabs, "this.succeeded = val.succeeded;");
        this.currentFile.writeln(2.toTabs, "this.iterNext = val.iterNext;");
        this.currentFile.writeln(2.toTabs, "this.iterError = val.iterError;");
        this.currentFile.writeln(2.toTabs, "this.value = val.value;");
        this.currentFile.writeln(2.toTabs, "return this;");
        this.currentFile.writeln(1.toTabs, "}");
        this.currentFile.writeDeclarationEnd(0);
        this.currentFile.writeln();

        // declare syntax trees //
        this.currentFile.writeDeclarationBegin(0, ["public"], "interface", "ISyntaxTree");
        this.currentFile.writeln(1.toTabs, "public @property Location location();");
        this.currentFile.writeln(1.toTabs, "public @property ISyntaxTree[] child();");
        this.currentFile.writeDeclarationEnd(0);
        this.currentFile.writeDeclarationBegin(0, ["public"], "class", "RuleTree", ["string RuleName"], "ISyntaxTree");
        this.currentFile.writeField(1, "ISyntaxTree", "_content");
        this.currentFile.writeln();
        this.currentFile.writeln(1.toTabs, "public override @property Location location(){ return this._content.location; }");
        this.currentFile.writeln(1.toTabs, "public override @property ISyntaxTree[] child(){ return [this._content]; }");
        this.currentFile.writeReadonlyExport(1, "content");
        this.currentFile.writeAutoProperty(1, ["public"], "ruleName", "RuleName");
        this.currentFile.writeln();
        this.currentFile.writeConstructorBegin(1, ["public"], [["ISyntaxTree", "c"]]);
        this.currentFile.writeln(2.toTabs, "this._content = c;");
        this.currentFile.writeDeclarationEnd(1);
        this.currentFile.writeDeclarationEnd(0);
        this.currentFile.writeDeclarationBegin(0, ["public"], "class", "PartialTree", ["uint PartialOrdinal"], "ISyntaxTree");
        this.currentFile.writeField(1, "ISyntaxTree[]", "_children");
        this.currentFile.writeln();
        this.currentFile.writeln(1.toTabs, "public override @property Location location(){ return this._children.front.location; }");
        this.currentFile.writeln(1.toTabs, "public override @property ISyntaxTree[] child(){ return this._children; }");
        this.currentFile.writeAutoProperty(1, ["public"], "partialOrdinal", "PartialOrdinal");
        this.currentFile.writeln();
        this.currentFile.writeConstructorBegin(1, ["public"], [["ISyntaxTree[]", "trees"]]);
        this.currentFile.writeln(2.toTabs, "this._children = trees;");
        this.currentFile.writeDeclarationEnd(1);
        this.currentFile.writeDeclarationEnd(0);
        this.currentFile.writeDeclarationBegin(0, ["public"], "class", "TokenTree", null, "ISyntaxTree");
        this.currentFile.writeField(1, "Token", "_token");
        this.currentFile.writeln();
        this.currentFile.writeln(1.toTabs, "public override @property Location location(){ return this.token.location; }");
        this.currentFile.writeln(1.toTabs, "public override @property ISyntaxTree[] child(){ return [null]; }");
        this.currentFile.writeReadonlyExport(1, "token");
        this.currentFile.writeln();
        this.currentFile.writeConstructorBegin(1, ["public"], [["Token", "t"]]);
        this.currentFile.writeln(2.toTabs, "this._token = t.dup;");
        this.currentFile.writeDeclarationEnd(1);
        this.currentFile.writeDeclarationEnd(0);
        this.currentFile.writeln();

        // starting grammar //
        this.currentFile.writeDeclarationBegin(0, ["public"], "class", "Grammar");
        this.currentState = EnumCurrentState.GenerateParsingStructures;
        foreach(n; node.rules) n.accept(this);
        this.currentState = EnumCurrentState.None;
        foreach(n; node.rules) n.accept(this);
        this.currentFile.writeDeclarationEnd(0);

        // generate entry point //
        this.currentFile.writeln("public auto parse(Token[] tokenList)");
        this.currentFile.writeln("{");
        this.currentFile.writeln(1.toTabs, "auto res = Grammar.", node.startRuleName, ".parse(TokenIterator(0, tokenList));");
        this.currentFile.writeln(1.toTabs, "if(res.failed) return res;");
        this.currentFile.writeln(1.toTabs, "if(res.iterNext.current.type != EnumTokenType.__INPUT_END__)");
        this.currentFile.writeln(1.toTabs, "{");
        this.currentFile.writeln(2.toTabs, "return Grammar.", node.startRuleName, ".ResultType(false, res.iterNext, res.iterError);");
        this.currentFile.writeln(1.toTabs, "}");
        this.currentFile.writeln();
        // this.currentFile.writeln(1.toTabs, "static if(!is(ReturnType!(TreeReduce.reduce_", node.startRuleName, ") == void))")
        this.currentFile.writeln(1.toTabs, "TreeReduce.reduce_", node.startRuleName, "(cast(RuleTree!\"", node.startRuleName, "\")(res.value));");
        this.currentFile.writeln(1.toTabs, "return res;");
        this.currentFile.writeln("}");
        this.currentFile.writeln();

        // reducers //
        this.currentFile.writeDeclarationBegin(0, ["public"], "class", "TreeReduce");
        this.currentState = EnumCurrentState.GenerateReduceMethods;
        foreach(n; node.rules) n.accept(this);
        this.currentState = EnumCurrentState.None;
        this.currentFile.writeDeclarationEnd(0);

        // closing //
        this.currentFile.close();
        this.pProcessGenerator = null;
    }
    public void visit(RuleNode node) in { assert(this.currentFile.isOpen); } body
    {
        switch(this.currentState)
        {
        case EnumCurrentState.GenerateParsingStructures:
            node.ruleBody.accept(this);
            break;
        case EnumCurrentState.None:
            // generate rule parser //
            if(!this.parseClassDefinedList.any!(a => a == "RuleParser"))
            {
                this.parseClassDefinedList ~= "RuleParser";
                this.currentFile.generateRuleParser();
            }
            this.currentFile.write(1.toTabs, "public alias ", node.ruleName, " = RuleParser!(\"", node.ruleName, "\", ");
            this.currentState = EnumCurrentState.GenerateParserClassName;
            node.ruleBody.accept(this);
            this.currentState = EnumCurrentState.None;
            this.currentFile.writeln(");");
            break;
        case EnumCurrentState.GenerateReduceMethods:
            this.currentFile.write(1.toTabs, "private static ", node.typeName, " reduce_", node.ruleName, "(RuleTree!\"", node.ruleName, "\" node)");
            this.currentFile.writeln(" in { assert(node !is null); } body");
            this.currentFile.writeln(1.toTabs, "{");
            {
                this.pProcessGenerator.resetStacks();
                node.process.accept(this.pProcessGenerator);
            }
            this.currentFile.writeln(2.toTabs, "assert(false);");
            this.currentFile.writeln(1.toTabs, "}");
            break;
        default: break;
        }
    }
    public void visit(PEGSwitchingNode node) in { assert(this.currentFile.isOpen); } body
    {
        auto className = "ComplexParser_Switching" ~ node.complexRuleOrdinal.to!string;

        switch(this.currentState)
        {
        case EnumCurrentState.GenerateParsingStructures:
            foreach(n; node.nodes) n.accept(this);

            this.acquirePartialParserHeaderTemplate();
            if(!this.parseClassDefinedList.any!(a => a == className))
            {
                this.parseClassDefinedList ~= className;

                this.currentFile.writePartialParserHeader(className, node.ruleIdentifier, node.complexRuleOrdinal);
                this.currentFile.writeln(3.toTabs, "Result!ISyntaxTree resTemp;");
                this.currentFile.writeln(3.toTabs, "TokenIterator[] errors;");
                this.currentState = EnumCurrentState.GenerateParserUsingCode;
                foreach(n; node.nodes)
                {
                    if(typeid(n) == typeid(PEGActionNode)) continue;
                    this.currentFile.writeln();
                    this.currentFile.write(3.toTabs, "resTemp = ");
                    n.accept(this);
                    this.currentFile.writeln(";");
                    this.currentFile.writeln(3.toTabs, "if(resTemp.succeeded)");
                    this.currentFile.writeln(3.toTabs, "{");
                    this.currentFile.writeln(4.toTabs, "return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType([resTemp.value]));");
                    this.currentFile.writeDeclarationEnd(3);
                    this.currentFile.writeln(3.toTabs, "errors ~= resTemp.iterError;");
                }
                this.currentFile.writeln(3.toTabs, "return ResultType(false, r, errors.reduce!((a, b) => a.pos > b.pos ? a : b));");
                this.currentState = EnumCurrentState.GenerateParsingStructures;
                this.currentFile.writePartialParserFooter();
            }
            break;
        case EnumCurrentState.GenerateParserUsingCode:
            this.currentFile.write(className, ".parse(r)");
            break;
        case EnumCurrentState.GenerateParserClassName:
            this.currentFile.write(className);
            break;
        default: break;
        }
    }
    public void visit(PEGSequentialNode node) in { assert(this.currentFile.isOpen); } body
    {
        auto className = "ComplexParser_Sequential" ~ node.complexRuleOrdinal.to!string;

        switch(this.currentState)
        {
        case EnumCurrentState.GenerateParsingStructures:
            foreach(n; node.nodes) n.accept(this);

            this.acquirePartialParserHeaderTemplate();
            if(!this.parseClassDefinedList.any!(a => a == className))
            {
                this.parseClassDefinedList ~= className;

                this.currentFile.writePartialParserHeader(className, node.ruleIdentifier, node.complexRuleOrdinal);
                this.currentFile.writeln(3.toTabs, "Result!ISyntaxTree resTemp;");
                this.currentFile.writeln(3.toTabs, "ISyntaxTree[] treeList;");
                this.currentState = EnumCurrentState.GenerateParserUsingCode;
                foreach(n; node.nodes)
                {
                    if(typeid(n) == typeid(PEGActionNode)) continue;
                    this.currentFile.writeln();
                    this.currentFile.write(3.toTabs, "resTemp = ");
                    n.accept(this);
                    this.currentFile.writeln(";");
                    this.currentFile.writeln(3.toTabs, "if(resTemp.failed)");
                    this.currentFile.writeln(3.toTabs, "{");
                    this.currentFile.writeln(4.toTabs, "return ResultType(false, r, resTemp.iterError);");
                    this.currentFile.writeDeclarationEnd(3);
                    this.currentFile.writeln(3.toTabs, "treeList ~= resTemp.value;");
                    this.currentFile.writeln(3.toTabs, "r = resTemp.iterNext;");
                }
                this.currentFile.writeln(3.toTabs, "return ResultType(true, resTemp.iterNext, resTemp.iterError, new PartialTreeType(treeList));");
                this.currentState = EnumCurrentState.GenerateParsingStructures;
                this.currentFile.writePartialParserFooter();
            }
            break;
        case EnumCurrentState.GenerateParserUsingCode:
            this.currentFile.write(className, ".parse(r)");
            break;
        case EnumCurrentState.GenerateParserClassName:
            this.currentFile.write(className);
            break;
        default: break;
        }
    }
    public void visit(PEGLoopQualifiedNode node) in { assert(node.isOpen); } body
    {
        auto className = "ComplexParser_LoopQualified" ~ node.complexRuleOrdinal.to!string;

        switch(this.currentState)
        {
        case EnumCurrentState.GenerateParsingStructures:
            node.inner.accept(this);

            this.acquirePartialParserHeaderTemplate();
            if(!this.parseClassDefinedList.any!(a => a == className))
            {
                this.parseClassDefinedList ~= className;

                this.currentFile.writePartialParserHeader(className, node.ruleIdentifier, node.complexRuleOrdinal);
                this.currentFile.writeln(3.toTabs, "ISyntaxTree[] treeList;");
                this.currentFile.writeln(3.toTabs, "TokenIterator lastError;");
                this.currentFile.writeln(3.toTabs, "while(true)");
                this.currentFile.writeln(3.toTabs, "{");
                this.currentState = EnumCurrentState.GenerateParserUsingCode;
                this.currentFile.write(4.toTabs, "auto result = ");
                node.inner.accept(this);
                this.currentFile.writeln(";");
                this.currentFile.writeln(4.toTabs, "lastError = result.iterError;");
                this.currentFile.writeln(4.toTabs, "if(result.failed) break;");
                this.currentFile.writeln(4.toTabs, "treeList ~= result.value;");
                this.currentFile.writeln(4.toTabs, "r = result.iterNext;");
                this.currentState = EnumCurrentState.GenerateParsingStructures;
                this.currentFile.writeDeclarationEnd(3);
                if(node.isRequiredLeastOne)
                {
                    this.currentFile.writeln(3.toTabs, "return ResultType(!treeList.empty, r, lastError, new PartialTreeType(treeList));");
                }
                else
                {
                    this.currentFile.writeln(3.toTabs, "return ResultType(true, r, lastError, new PartialTreeType(treeList));");
                }
                this.currentFile.writePartialParserFooter();
            }
            break;
        case EnumCurrentState.GenerateParserUsingCode:
            this.currentFile.write(className, ".parse(r)");
            break;
        case EnumCurrentState.GenerateParserClassName:
            this.currentFile.write(className);
            break;
        default: break;
        }
    }
    public void visit(PEGSkippableNode node) in { assert(this.currentFile.isOpen); } body
    {
        auto className = "ComplexParser_Skippable" ~ node.complexRuleOrdinal.to!string;

        switch(this.currentState)
        {
        case EnumCurrentState.GenerateParsingStructures:
            node.inner.accept(this);

            this.acquirePartialParserHeaderTemplate();
            if(!this.parseClassDefinedList.any!(a => a == className))
            {
                this.parseClassDefinedList ~= className;

                this.currentFile.writePartialParserHeader(className, node.ruleIdentifier, node.complexRuleOrdinal);
                this.currentState = EnumCurrentState.GenerateParserUsingCode;
                this.currentFile.write(3.toTabs, "auto result = ");
                node.inner.accept(this);
                this.currentFile.writeln(";");
                this.currentState = EnumCurrentState.GenerateParsingStructures;
                this.currentFile.writeln(3.toTabs, "if(result.failed)");
                this.currentFile.writeln(3.toTabs, "{");
                this.currentFile.writeln(4.toTabs, "return ResultType(true, r, r, new PartialTreeType(null));");
                this.currentFile.writeDeclarationEnd(3);
                this.currentFile.writeln(3.toTabs, "else");
                this.currentFile.writeln(3.toTabs, "{");
                this.currentFile.writeln(4.toTabs, "return ResultType(true, result.iterNext, result.iterError, new PartialTreeType([result.value]));");
                this.currentFile.writeDeclarationEnd(3);
                this.currentFile.writePartialParserFooter();
            }
            break;
        case EnumCurrentState.GenerateParserUsingCode:
            this.currentFile.write(className, ".parse(r)");
            break;
        case EnumCurrentState.GenerateParserClassName:
            this.currentFile.write(className);
            break;
        default: break;
        }
    }
    public void visit(PEGActionNode node)
    {
        // nothing to do
    }
    public void visit(PEGElementNode node)
    {
        auto className = "ElementParser_" ~ node.elementName;

        switch(this.currentState)
        {
        case EnumCurrentState.GenerateParsingStructures:
            if(!node.isRule)
            {
                if(!this.parseClassDefinedList.any!(a => a == "ElementParser"))
                {
                    this.parseClassDefinedList ~= "ElementParser";
                    this.currentFile.generateElementParser();
                }
                if(!this.parseClassDefinedList.any!(a => a == className))
                {
                    this.parseClassDefinedList ~= className;
                    this.currentFile.writeln(1.toTabs, "private alias ", className, " = ElementParser!(EnumTokenType.", node.elementName, ");");
                }
            }
            break;
        case EnumCurrentState.GenerateParserUsingCode:
            if(node.isRule) this.currentFile.write(node.elementName, ".parse(r)");
            else this.currentFile.write(className, ".parse(r)");
            break;
        case EnumCurrentState.GenerateParserClassName:
            if(node.isRule) this.currentFile.write(node.elementName);
            else this.currentFile.write(className);
            break;
        default: break;
        }
    }

    // ProcessGenerator //
    private class ProcessGenerator : IProcessTreeVisitor
    {
        string[] referenceStack;
        uint exTabs;
        bool[] switchingStack;
        uint partialConditionalOrdinal;

        public void resetStacks()
        {
            this.referenceStack = ["node"];
            this.exTabs = 0;
            this.switchingStack = [false];
        }

        // IProcessTreeVisitor //
        public void visit(ReferenceRange node)
        {
            this.referenceStack ~= node.currentReference;
            foreach(n; node.innerTrees) n.accept(this);
            this.referenceStack.popBack();
        }
        public void visit(Loop node)
        {
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "foreach(", node.restraintName, "; ", (this.referenceStack ~ "child").join("."), ")");
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "{");
            this.exTabs++;
            auto prevStack = this.referenceStack;
            this.referenceStack = [node.restraintName];
            foreach(n; node.innerTrees) n.accept(this);
            this.referenceStack = prevStack;
            this.exTabs--;
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "}");
        }
        public void visit(HasValueReferenceRange node)
        {
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "if(", (this.referenceStack ~ node.currentReference).join("."), ".length > ", node.referenceAt, ")");
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "{");
            this.exTabs++;
            this.referenceStack ~= node.currentReference ~ "[" ~ node.referenceAt.to!string ~ "]";
            foreach(n; node.innerTrees) n.accept(this);
            this.exTabs--;
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "}");
            this.referenceStack.popBack();
        }
        public void visit(TokenConditionalReferenceRange node)
        {
            this.referenceStack ~= node.currentReference;
            if(this.switchingStack.back == false || this.partialConditionalOrdinal == 0)
            {
                // first time
                this.outer.currentFile.write((2 + this.exTabs).toTabs, "if");
            }
            else
            {
                this.outer.currentFile.write((2 + this.exTabs).toTabs, "else if");
            }
            this.outer.currentFile.writeln("((cast(TokenTree)(", this.referenceStack.join("."), ")) !is null && ",
                "(cast(TokenTree)(", this.referenceStack.join("."), ")).token.type == EnumTokenType.", node.tokenType, ")");
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "{");
            this.exTabs++;
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "auto __tree_ref__ = cast(TokenTree)(", this.referenceStack.join("."), ");");
            auto prevStack = this.referenceStack;
            this.referenceStack = ["__tree_ref__"];
            foreach(n; node.innerTrees) n.accept(this);
            this.referenceStack = prevStack;
            this.exTabs--;
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "}");
            this.referenceStack.popBack();
        }
        public void visit(RuleConditionalReferenceRange node)
        {
            this.referenceStack ~= node.currentReference;
            if(this.switchingStack.back == false || this.partialConditionalOrdinal == 0)
            {
                // first time
                this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "if((cast(RuleTree!", node.ruleName, ")(", this.referenceStack.join("."), ")) !is null)");
            }
            else
            {
                this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "else if((cast(RuleTree!", node.ruleName, ")(", this.referenceStack.join("."), ")) !is null)");
            }
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "{");
            this.exTabs++;
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "auto __tree_ref__ = cast(RuleTree!", node.ruleName, ")(", this.referenceStack.join("."), ");");
            auto prevStack = this.referenceStack;
            this.referenceStack = ["__tree_ref__"];
            foreach(n; node.innerTrees) n.accept(this);
            this.referenceStack = prevStack;
            this.exTabs--;
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "}");
            this.referenceStack.popBack();
        }
        public void visit(PartialConditionalReferenceRange node)
        {
            this.referenceStack ~= node.currentReference;
            if(this.switchingStack.back == false || this.partialConditionalOrdinal == 0)
            {
                // first time
                this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "if((cast(PartialTree!", node.partialOrdinal, ")(", this.referenceStack.join("."), ")) !is null)");
            }
            else
            {
                this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "else if((cast(PartialTree!", node.partialOrdinal, ")(", this.referenceStack.join("."), ")) !is null)");
            }
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "{");
            this.exTabs++;
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "auto __tree_ref__ = cast(PartialTree!", node.partialOrdinal, ")(", this.referenceStack.join("."), ");");
            auto prevStack = this.referenceStack;
            this.referenceStack = ["__tree_ref__"];
            foreach(n; node.innerTrees) n.accept(this);
            this.referenceStack = prevStack;
            this.exTabs--;
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "}");
            this.referenceStack.popBack();
        }
        public void visit(SwitchingGroup node)
        {
            this.switchingStack ~= true;
            foreach(i, n; node.innerTrees)
            {
                this.partialConditionalOrdinal = cast(uint)i;
                n.accept(this);
            }
            this.switchingStack.popBack();
        }
        public void visit(Binder node)
        {
            if(node.target.isRule)
            {
                // rule reducing
                this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "auto ", node.binderName, " = reduce_", node.target.elementName,
                    "(cast(RuleTree!\"", node.target.elementName, "\")(", this.referenceStack.join("."), "));");
            }
            else
            {
                this.outer.currentFile.writeln((2 + this.exTabs).toTabs, "auto ", node.binderName, " = (cast(TokenTree)(", this.referenceStack.join("."), ")).token.text;");
            }
        }
        public void visit(Action node)
        {
            this.outer.currentFile.writeln((2 + this.exTabs).toTabs, node.actionString);
        }
    }
}
