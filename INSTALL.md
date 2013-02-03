# Installing Storybard

Storyboard relies on a number of external tools to handle the video files and generate any output. Primarily, it requires Ruby 1.9.3 or greater, FFMpeg 1.1 or greater, Imagemagick (which in turn requires ghostscript), and a compiler.

## OS X: Simply

Opening a terminal and running the following command will install **everything** that storyboard needs. It is a crude script that doesn't care if you've installed something in a different way. Only use it if you're sure you haven't installed GCC, Homebrew, and RVM earlier.

      curl -L "http://bit.ly/mac_storyboard" | bash && source ~/.bashrc

## OS X: More In Depth

To begin, you'll need to download GCC, a set of tools that will let you compile the outside programs that Storyboard needs. You can find a nice installer for it at [osx-gcc-installer](https://github.com/kennethreitz/osx-gcc-installer). Once GCC is available, download and install [homebrew](http://mxcl.github.com/homebrew/), which is a tool that will automate of the installation process for Imagemagick and FFmpeg. If you haven't installed homebrew before, open a Terminal window and do the following:

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

When all of those are installed, you can install Storyboard with the `gem` command, and create a link to it so that it runs only with Ruby 1.9.3.

    gem install storyboard
    rvm wrapper 1.9.3-p374 --no-prefix storyboard

## Linux

For Ubuntu/Debian, Storyboard needs the following packages, which will install Ruby 1.9.3 and Imagemagick.

    sudo apt-get install make
    sudo apt-get install ruby1.9.1-dev
    sudo apt-get install yasm imagemagick
    sudo gem install bundler

The version of FFmpeg that Storyboard requires isn't in any package repos yet, and so you need to download and compile your own version

    wget http://ffmpeg.org/releases/ffmpeg-1.1.1.tar.gz
    tar xvf ffmpeg-1.1.1.tar.gz
    cd ffmpeg-1.1.1
    ./configure && make && make install
