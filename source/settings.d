module com.cterm2.tpeg.settings;

// settings
import std.file;

const OutputDirectory = "tpeg_output";

void acquireOutputDirectory()
{
    if(!exists(OutputDirectory) || !isDir(OutputDirectory))
    {
        mkdir(OutputDirectory);
    }
}
