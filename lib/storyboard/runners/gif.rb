module Storyboard::Runners
  class Gif < Storyboard::Runners::Base
    def run
      # do secondary checks.
      raise Trollop::CommandlineError, "--use_first_text_match requires --find-text" if @options[:use_first_text_match] && @options[:find_text].nil?
      
      @extractor = Storyboard::Extractor::Range.new(self)
        
      if @options[:use_text_given]
        @extractor.start = start_time = ts_to_s(@options[:start_time])
        @extractor.stop = end_time = ts_to_s(@options[:end_time])
        raise Trollop::CommandlineError, "--start cannot be further than --end" if start_time >= end_time
      
        @extractor.fps = @video.framerate_r(2)

        @sub = Storyboard::Subtitles::Base.new(self)
        @sub.add_line(start_time, end_time, options[:use_text])
        @sub.write
      else
        raise Trollop::CommandlineError "only -t for now."
      end

      # EITHER the text from -t

      # OR load the subtitle file from -s 

      # OR try to find one to download

      # If we downloaded one, check for the text.

      @extractor.run

      @gif = Storyboard::Builder::GIF.new(self).run(@extractor.format)
    end

    def name
    	"Gifboard"
    end
  end
end
