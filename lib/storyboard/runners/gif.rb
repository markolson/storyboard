module Storyboard::Runners
  class Gif < Storyboard::Runners::Base
    def run
      # do secondary checks.
      raise Trollop::CommandlineError, "--use_first_text_match requires --find-text" if @options[:use_first_text_match] && @options[:find_text].nil?
      pull_options!
      @extractor = Storyboard::Extractor::Range.new(self)
      
      @extractor.fps = @video.framerate_r(2)
      @extractor.post += ["-q", 1]
      
      @sub = nil

      ui.log("Checking for subtitles")
      @subtitles = Storyboard::Subtitles.new(self)

      load_from = [
        Storyboard::Subtitles::Source::Text,
        Storyboard::Subtitles::Source::Path,
        Storyboard::Subtitles::Source::Local,
        Storyboard::Subtitles::Source::Web,
      ]

      if @subtitles.load_from(load_from)

        filters = [
          Storyboard::Subtitles::Filter::Text,
          Storyboard::Subtitles::Filter::Time,
        ]

        @subtitles.filter(filters)
        @subtitles.write
      end

      ui.log("Building frames", Logger::INFO)
      @extractor.run
      ui.log("Outputting GIF", Logger::INFO)
      @gif = Storyboard::Builder::GIF.new(self).run(@extractor.format)
    end

    def name
    	"Gifboard"
    end
  end
end
