module Storyboard::Runners
  class Book < Storyboard::Runners::Base
    def run
      pull_options!
      @extractor = Storyboard::Extractor::Points.new(self)
      
      @subtitles = Storyboard::Subtitles.new(self)

      load_from = [
        Storyboard::Subtitles::Source::Path,
        Storyboard::Subtitles::Source::Local,
        Storyboard::Subtitles::Source::Web,
      ]

      if @subtitles.load_from(load_from)
      	@subtitles.filter([Storyboard::Subtitles::Filter::Time])
      	@extractor.add_from_subtitles(@subtitles)
      else
      	p "FAIL"
      	exit
      end

      @extractor.add_from_ffprobe unless @options[:skip_scene_detection_given]

			@subtitles.write
      @extractor.post += ["-flags", "gray"] unless @options[:keep_colors_given]
      @extractor.run

      @pdf = Storyboard::Builder::PDF.new(self).run(@extractor.format)
    end

    def name
      "Storyboard"
    end
  end
end


