module Storyboard::Subtitles::Source
  class Path
  	def self.run(subtitles, runner)
  		return false unless runner.options[:subtitle_path_given]
  		runner.ui.log("Adding subtitles from Source::Path: #{runner.options[:subtitle_path]}")

  		subtitles.load_from_file(runner.options[:subtitle_path])
  		return true
  	end
  end
end