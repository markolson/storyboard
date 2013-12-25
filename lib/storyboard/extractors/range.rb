module Storyboard::Extractor
  class Range < Storyboard::Extractor::Base

  	attr_accessor :fps
  	def run
  		filters << "fps=#{@fps}"

  		cmd = build_ffmpeg_command(
  			:pre => ["-ss", Titlekit::ASS.build_timecode(@parent.start_time-1)],
  			:post => ["-ss", Titlekit::ASS.build_timecode(1), "-to", Titlekit::ASS.build_timecode(@parent.end_time-@parent.start_time)],
  			:filename => "tmp%04d.jpg"
  		)
  		Storyboard::Binaries.ffmpeg(cmd)
  	end

    def format
      "tmp*.jpg"
    end

  end
end