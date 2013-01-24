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

To quickly test if the subtitles that are used look ok, you can use the `--preview NUMBER` option, which generates a PDF with as many pages as you specify, defaulting to 10.

    storyboard --preview /path/to/video-file.mkv

If the subtitles are off, you can nudge them back or forward with the `-n TIME` option. This can be positive or negative, and if you make it too large it can cause Storyboard to throw an error. This would nudge the subtitles back 2 seconds, and generate just the preview PDF.

   storyboard -n -2 --preview /path/to/video-file.mkv

You can see all the available options by using the help option:

    storyboard -h

## Requirements

The INSTALL.md file talks about requirements some more, but Storyboard requires Ruby 1.9.3, FFMpeg 1.1, and any recent version of Imagemagick. If you already have those available, just install the storyboard gem.

    gem install storyboard
