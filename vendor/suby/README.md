# suby

Find and download subtitles

`suby` is a little script to find and download subtitles for TV series

## Install

    gem install suby

## Synopsis

    suby 'My Show 1x01 - Pilot.avi' # => Downloads 'My Show 1x01 - Pilot.srt'

## Features

* Parse filename to detect show, season and episode
* Search and download appropriate subtitle, extracting it from the archive and renaming it
* Accept a lang option (defaults to en)
* Try multiple sites, falling back on the next one if it was not found on the current
* Detailed error messages

## TODO

* usual movies support (via opensubtitles.org)
* multi-episodes support
* choose wiser the right subtitle if many are available
