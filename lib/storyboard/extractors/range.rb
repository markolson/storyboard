module Storyboard::Extractor
  class Range
  	attr_accessor :parent
  	attr_accessor :start, :stop, :fps
  	def initialize(parent)
  		@parent = parent
  	end

  	def run
  		parent.filters << "fps=#{@fps}"

  		cmd = @parent.build_ffmpeg_command(
  			:pre => ["-ss", Titlekit::ASS.build_timecode(start-1)],
  			:post => ["-ss", Titlekit::ASS.build_timecode(1), "-to", Titlekit::ASS.build_timecode(stop-start)],
  			:filename => "tmp%04d.jpg"
  		)
  		Storyboard::Binaries.ffmpeg(cmd)
  	end

    def format
      "tmp*.jpg"
    end
  end
end