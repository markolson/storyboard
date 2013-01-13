# Storyboard

Read the TV and Movies you don't have time to watch.

## Storyboard

Storyboard is _very much_ a work in progress, and only works most of some of the time.

    storyboard /path/to/video-file.mkv

Will generate a folder called `video-file` in the directory that the command is run from, eventually generating `video-file/video-file.pdf`. ePub and Mobi support will come later. You can see available commands by running the program without any options

    Usage: storyboard [options] videofile [output_directory]
      -v, --[no-]verbose               Run verbosely
          --[no-]scenes                Detect scene changes. This increases the time it takes to generate a file.
      -ct FLOAT                        Scene detection threshold. 0.2 is too low, 0.8 is too high. Play with it!
      -s, --subs FILE                  SRT subtitle file to use. Will skip extracting/downloading one.
          --make x,y,z                 Filetypes to output
                                       (pdf, mobi, epub)
      -h, --help                       Show this message

Any subtitle file has to be in SRT format.

## Requirements

Storyboard requires a recent version of *ffmpeg*. This gem includes a build of *ffprobe* that will only work on OS X 1.8, 64 bit. It's probably best not to use this on any different system for now.

## Known Issues

Subtitles are always downloaded, never extracted from video files. Because the subtitles are searched for based on the filename it's best that you have then named in a standard format, e.g., `The X-Files - 1x21 - Tooms.avi`.

Some subtitles are encoded in UTF-16, and I haven't care quite enough yet to get them to work.

Sometimes the wrong subtitle file will be returned from the site. In those cases, download it manually and use the `-s` option

If there is a scene change followed by dialog in the next frame or two, the dialog may not be shown sometimes.
