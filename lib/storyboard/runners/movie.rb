module Storyboard::Runners
  class Movie < Storyboard::Runners::Base
    def run
      pull_options!
      @extractor = Storyboard::Extractor::Range.new(self)
      
      ui.log("Checking for subtitles")
      @subtitles = Storyboard::Subtitles.new(self)

      @extractor.fps = "fps=1/#{(@video.duration/475)}" # frames needed.
      @extractor.post += ["-q", 5]
      @extractor.run

      @movie = Storyboard::Builder::GIF.new(self)
      @movie.run(@extractor.format)
    end

    def name
      "Movieboard"
    end
  end
end


