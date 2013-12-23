module Storyboard
  autoload :VERSION,                        "storyboard/version"
  autoload :CLI,                        		"storyboard/cli"

  module Runners
    autoload :Book,                   			"storyboard/runners/book.rb"
    autoload :Gif,                   				"storyboard/runners/gif.rb"
    autoload :Movie,                   			"storyboard/runners/movie.rb"
 end
end
