module Storyboard::Extractor
  class Range
  	attr_accessor :parent
  	attr_accessor :start, :stop, :fps
  	def initialize(parent)
  		@parent = parent
  	end

#ffmpeg -v quiet -ss #{Titlekit::ASS.build_timecode(ffmpeg_at-1)}  -i sein/vid.avi -ss #{Titlekit::ASS.build_timecode(1)} -vf scale=#{WIDTH}:-1,fps=25/2 -y -frames:v #{frame_count} -copyts sein/o-%02d.jpg`


  	def run
  		parent.filters << "fps=#{@fps}"
  		cmd = @parent.build_ffmpeg_command(
  			:pre => ["-ss", Titlekit::ASS.build_timecode(start-1)],
  			:post => ["-ss", Titlekit::ASS.build_timecode(1), "-to", Titlekit::ASS.build_timecode(stop-start)],
  			:filename => "tmp%04d.jpg"
  		)
  		Storyboard::Binaries.ffmpeg(cmd)
  	end
  end
end