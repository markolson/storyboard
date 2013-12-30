module Storyboard::Subtitles::Source
  class Text
  	def self.run(subtitles, runner)
  		return false unless runner.options[:use_text_given]
  		raise Trollop::CommandlineError, "--start cannot be further than --end" if runner.start_time >= runner.end_time

  		
  		runner.ui.log("Adding subtitles from Source::Text")
			subtitles.add_line(runner.start_time, runner.end_time, runner.options[:use_text])
  		return true
  	end
  end
end