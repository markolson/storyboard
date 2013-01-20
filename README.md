# Storyboard

Read the TV and Movies you don't have time to watch. Given a video file, it will generate a PDF (or soon, ePub and Mobi) containing every scene change and line of dialog.

## Storyboard

![Seinfeld](http://i.imgur.com/lTRuC.jpg)

Storyboard is _very much_ a work in progress, though it works most of the time. Using it is simple:

    $ storyboard /path/to/video-file.mkv

Storyboard will try to generate a file at `/path/to/video-file.pdf` containing the final product. Simiarly, you can pass in the path to a folder containing multiple files and it will output a PDF for each video it finds.

    $ ls "~/TV/ShowName/Season 1"
    ShowName.1x01.EpisodeName.mkv    ShowName.1x02.AnotherEpisode.mkv    ShowName.1x03.ThirdEp.mkv
    $ storyboard "~/TV/ShowName/Season 1"
    $ ls .
    ShowName.1x01.EpisodeName.pdf    ShowName.1x02.AnotherEpisode.pdf    ShowName.1x03.ThirdEp.pdf

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

The INSTALL.md file talks about requirements some more, but Storyboard requires Ruby 1.9.3, FFMpeg 1.1, and any recent version of Imagemagick. If you already have those available, just install the storyboard gem.

    gem install storyboard
