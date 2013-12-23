module Storyboard::Runners
  class Base
    attr_reader :ui, :options

    attr_reader :video, :subtitles

    def self.run(options, ui=Storyboard::UI::Console)
      self.new(options,ui).run
    end

    def initialize(options, ui=Storyboard::UI::Console)
      @options = options
      @ui = ui
    end

    def run
      raise NotImplementedError
    end
  end
end
