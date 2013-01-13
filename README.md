# Storyboard

Read the TV and Movies you don't have time to watch.

## Storyboard

Storyboard is _very much_ a work in progress, and only works (most of) some of the time. Using it is simple:

    storyboard /path/to/video-file.mkv

Storyboard will try to generate a file at `/path/to/video-file.pdf` containing the final product. ePub and Mobi support will come later.

You can see available commands by running the program without any options

    Usage: storyboard [options] videofile [output_directory]
      -v, --[no-]verbose               Run verbosely
          --[no-]scenes                Detect scene changes. This increases the time it takes to generate a file.
      -ct FLOAT                        Scene detection threshold. 0.2 is too low, 0.8 is too high. Play with it!
      -s, --subs FILE                  SRT subtitle file to use. Will skip extracting/downloading one.
          --make x,y,z                 Filetypes to output
                                       (pdf, mobi, epub)
      -h, --help                       Show this message

## Requirements

Storyboard requires a recent version of *ffmpeg*. This gem includes a build of *ffprobe* that will only work on OS X 1.8, 64 bit. It's probably best not to use this on any different system for now. It's also best to run it on something with at least 8 cores.

## Known Issues

* If there is a scene change followed by dialog in the next frame or two, the dialog may not be shown.
* Subtitles are always downloaded, never extracted from video files. Because the subtitles are searched for based on the filename it's best that you have then named in a standard format, e.g., `The X-Files - 1x21 - Tooms.avi`.
* Sometimes the wrong subtitle file will be returned from the site. In those cases, download it manually and use the `-s` option to pass in the path to an SRT formatted subtitle file.
* Some subtitles are encoded in UTF-16, and I haven't care quite enough yet to get them to work.
* The subtitles are uuuuuugly.
* Hardcoding 8 for the number of threads is a bad idea
* Almost definitely some path-escaping issues, so avoid files with apostrophes and slashes

## Help

For now, best to email me theothermarkolson@gmail.com
