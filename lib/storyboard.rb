require 'json'
require 'prawn'
require 'logger'
require 'tmpdir'
require 'tempfile'
require 'shellwords'

module Storyboard
  autoload :VERSION,              "storyboard/version"
  autoload :CLI,                  "storyboard/cli"

  autoload :Binaries,             "storyboard/binaries"
  autoload :Video,                "storyboard/video"

  module Extractor
    autoload :Timestamps,         "storyboard/extractors/timestamps.rb"
    autoload :Range,              "storyboard/extractors/range.rb"
  end


  module Builder
    autoload :GIF,               "storyboard/builder/gif.rb"
  end

  module Subtitles
    autoload :Base,               "storyboard/subtitles/base.rb"
    autoload :Line,               "storyboard/subtitles/line.rb"
    autoload :File,               "storyboard/subtitles/file.rb"
    autoload :Web,                "storyboard/subtitles/web.rb"
  end

  module Runners
    autoload :Base,               "storyboard/runners/base.rb"
    autoload :Book,               "storyboard/runners/book.rb"
    autoload :Gif,                "storyboard/runners/gif.rb"
    autoload :Movie,              "storyboard/runners/movie.rb"
  end

  module UI
    autoload :Console,            "storyboard/ui/console.rb"
  end  
end
