module Storyboard::Runners
  class Gif < Storyboard::Runners::Base
    def run
      p @options

      # do secondary checks.
      raise Trollop::CommandlineError, "--use_first_text_match requires --find-text" if @options[:use_first_text_match] && @options[:find_text].nil?
      
      @extractor = Storyboard::Extractor::Range.new(self)
        
      if @options[:use_text_given]
        start_time = ts_to_s(@options[:start_time])
        end_time = ts_to_s(@options[:end_time])
        raise Trollop::CommandlineError, "--start cannot be further than --end" if start_time >= end_time
      
        p @video.framerate
        p start_time
        p end_time
      else
        raise Trollop::CommandlineError "only -t for now."
      end

      # EITHER the text from -t

      # OR load the subtitle file from -s 

      # OR try to find one to download

      # If we downloaded one, check for the text.
    end

    def name
    	"Gifboard"
    end
  end
end
