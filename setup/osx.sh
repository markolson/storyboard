#!/bin/bash
vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

return=$(osascript -e 'tell app "System Events" to display dialog "This script will potentially download and install lots of additional software on your system, including GCC, Homebrew, FFmpeg, Imagemagick, Ghostscript, RVM, and Ruby 1.9.3. If you feel able to install these yourself, I recommend that you do. This is a crude installer that cares for nothing beyond itself." with icon caution with title "OSX 10.8 Mountain Lion: Storyboard installer" buttons {"OK", "Cancel"} default button 1' >/dev/null 2>/dev/null)
if [ $? -ne 0 ]; then
  exit
fi

echo -n "Checking for gcc devtools..."
if [ -x /usr/bin/gcc-4.2 ]; then
    printf '%s ok %s\n' "$(tput setaf 2)" "$(tput op)"
else
   printf '%s have to install %s\n' "$(tput setaf 1)" "$(tput op)"
   curl -C - -O http://devimages.apple.com/downloads/xcode/command_line_tools_for_xcode_10_8_late_july_2012.dmg
   open -W command_line_tools_for_xcode_10_8_late_july_2012.dmg
   rm command_line_tools_for_xcode_10_8_late_july_2012.dmg
fi

echo -n "Checking for homebrew..."
if [ -x /usr/local/bin/brew ]; then
    printf '%s ok %s\n' "$(tput setaf 2)" "$(tput op)"
    echo -n "Ensuring it's up to date..."
    brew update
else
   printf '%s have to install %s\n' "$(tput setaf 1)" "$(tput op)"
   /usr/bin/ruby -e "$(/usr/bin/curl -fksSL https://raw.github.com/mxcl/homebrew/master/Library/Contributions/install_homebrew.rb)"
fi

echo -n "Checking for FFmpeg"
if [ -x /usr/local/bin/ffmpeg ]; then
    printf '%s ok %s\n' "$(tput setaf 2)" "$(tput op)"
    echo -n "Ensuring FFmpeg is up to date"
    version=$(ffprobe -version | awk '/ffprobe version (.*)$/{print $0}' | grep -oE '[0-9\.]{1,}')
    version=$(printf $version)
    vercomp $version '1.1'
    if [ $? -lt 2 ] ; then
      printf '%s ok %s\n' "$(tput setaf 2)" "$(tput op)"
    else
      brew upgrade ffmpeg
    fi
else
   printf '%s have to install %s\n' "$(tput setaf 1)" "$(tput op)"
   brew install ffmpeg
fi

echo -n "Checking for ImageMagick"
if [ -x /usr/local/bin/convert ]; then
  printf '%s ok %s\n' "$(tput setaf 2)" "$(tput op)"
else
  printf '%s have to install %s\n' "$(tput setaf 1)" "$(tput op)"
  brew install imagemagick
fi

echo -n "Checking for Ghostscript"
if brew list | grep -q ghostscript ; then
  printf '%s ok %s\n' "$(tput setaf 2)" "$(tput op)"
else
  printf '%s have to install %s\n' "$(tput setaf 1)" "$(tput op)"
  brew install ghostscript
fi

echo -n "Checking for RVM"
if which -s rvm ; then
  printf '%s ok %s\n' "$(tput setaf 2)" "$(tput op)"
else
  printf '%s have to install %s\n' "$(tput setaf 1)" "$(tput op)"
  curl -L https://get.rvm.io | bash
  source ~/.rvm/scripts/rvm
fi

echo -n "Checking for Ruby 1.9.3"
if rvm list | grep -q 1.9.3 ;  then
  printf '%s ok %s\n' "$(tput setaf 2)" "$(tput op)"
else
  printf '%s have to install %s\n' "$(tput setaf 1)" "$(tput op)"
  rvm install 1.9.3 --default
fi

source ~/.rvm/scripts/rvm
rvm use 1.9.3
gem install storyboard
rvm wrapper 1.9.3 --no-prefix storyboard
source ~/.rvm/scripts/rvm
