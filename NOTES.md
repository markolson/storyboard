# Goals
* General 
    * Downloading subtitles as needed, and providing an interface to select an appropriate one
    * Creating "fair" quality output by default
* Create PDFs, ePubs, and HTML files from video files
* Create GIFs from sections of video files
    * By time range + arbitrary text
    * By subtitle + it's time range
* Create fullmoviegifs
    * 30 seconds for a full movie

# CLI

## Common

By default, storyboard will output PDFs of the given video file.

    storyboard [mode] [options] video_file.avi [outputpath]

Sole unnamed parameter can be the video file:

    storyboard video_file.avi

  * `-v`: Verbose/Debug output.
  * `-s PATH` `--subtitle PATH`: Path to a valid srt, ass or ssa file
  * `--start TIME`: Time to start processing, in HH:MM:SS.MS format.
  * `--end TIME`: Time to end processing, in HH:MM:SS.ms format.
  * `-n TIME` `--nudge [TIME]`: Nudge the subtitles forward or backward this many seconds to fix minor alignment issues. Defaults to 0.0
  * `--quality [INT%]`: Relative quality of the output file
  * `--preview [FRAMES]`: Only putput this number of frames. Defaults to 10 if FRAMES isn't specified
  * `-d DIMENSIONS` `--output-size DIMENSIONS`: Output size of the image(s) created.

## Storyboard

Default of the `storyboard` bin, it can be selected by:

    storyboard book [options] video_file.avi [outputpath]

  * `-k` `--skip-scene-detection`: Skips scene detection - a potentially lengthy process
  * `-f [FORMAT]`: The type of file to generate. Defaults to PDF
  * `--colors`: Retains colors

## Gifboard

Default of the `gifboard` bin, but can be selected by:

    storyboard gif [options] video_file.avi [outputpath]
    gifboard [options] video_file.avi [outputpath]

  * `--colors INT`: Override for the number of colors to use in the GIF
  * `-f TEXT` `--find-text TEXT`: Text to search for in the subtitle file
  * `--use-first-match`: When used with `-f`, automatically use the first match
  * `-t TEXT` `--use-text TEXT`: Text to use. Disabled subtitle file checks. Must be used with `--start` and `--end`

## MovieBoard

    storyboard movie [options] video_file.avi [outputpath]
    movieboard [options] video_file.avi [outputpath]

  * `--colors INT`: Override for the number of colors to use in the GIF
  * `--in TIME`: The total time that the GIF should take to replay the movie. 
