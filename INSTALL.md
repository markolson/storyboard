# Installing Storybard

Storyboard relies on a number of external libraries to handle extracting information from the video files and generating the output. Primarily, it requires Ruby 1.9.3 or greater, FFMpeg 1.1 or greater, Imagemagick (which in turn requires ghostscript), and a compiler.

## OS X

To begin, you'll need to download GCC, a set of tools that will let you compile low level code. You can find a nice installer for it at [osx-gcc-installer](https://github.com/kennethreitz/osx-gcc-installer). Once GCC is installed, download and install [homebrew](http://mxcl.github.com/homebrew/), which is a tool that will automate of the installation process for Imagemagick and FFmpeg. If you haven't installed homebrew before, open a Terminal window and do the following:

    ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
    brew install ffmpeg imagemagick ghostscript

If you've already installed homebrew, update it and re-install FFmpeg if necessary. Storyboard requires FFmpeg 1.1, which became available on homebrew in Janurary 2013.

    brew update
    brew uninstall ffmpeg
    brew upgrade ffmpeg

Finally, if you don't have Ruby 1.9.3 installed on your system, you can use <a href="http://rvm.io">RVM</a> to install it. In a termal window, run the following:

    curl -L https://get.rvm.io | bash -s stable --ruby
    rvm install 1.9.3-p374
    rvm default 1.9.3-p374

When all of those are installed, you can install Storyboard with the `gem` command

    gem install storyboard
