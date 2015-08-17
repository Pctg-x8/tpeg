module com.cterm2.tpeg.settings;

// settings
import std.file;

auto OutputDirectory = "tpeg_output";

void setOutputDirectory(string s)
{
    OutputDirectory = s;
}

void acquireOutputDirectory()
{
    if(!exists(OutputDirectory) || !isDir(OutputDirectory))
    {
        mkdir(OutputDirectory);
    }
}
