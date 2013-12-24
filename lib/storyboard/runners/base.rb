module Storyboard::Runners
  class Base
    attr_reader :ui, :options

    attr_reader :video, :subtitles

    def self.run(options, ui=Storyboard::UI::Console)
      Storyboard::Binaries.check
      # catch exceptions from the above, and prompt to install if 
      # there are known good options.
      self.new(options,ui).run
    end

    def initialize(options, ui=Storyboard::UI::Console)
      @options = options
      @ui = ui.new(self)

      assign_paths
      @ui.log("Will be saving files to #{@options['_output_director']}")
      @video = Storyboard::Video.new(self)
    end

    def run
      raise NotImplementedError
    end

    private
    def assign_paths
      while not ARGV.empty? do
        last_arg = File.expand_path(ARGV.pop)
        if File.directory?(last_arg) && File.writable?(last_arg)
          @options['_output_director'] = last_arg
        elsif File.file?(last_arg) && File.readable?(last_arg)
          @options['_video'] = last_arg
        end
        @options['_output_director'] = Dir.pwd
      end

    end
  end
end
