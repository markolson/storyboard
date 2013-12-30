module Storyboard::Extractor
  class Range < Storyboard::Extractor::Base

    attr_accessor :fps
    def run
      filters << "fps=#{@fps}"

      offset = (@parent.start_time > 1) ? 1 : 0
      @filters << "setpts=PTS-#{@parent.start_time}/TB"

      cmd = build_ffmpeg_command(
        :pre => ["-ss", Titlekit::ASS.build_timecode(@parent.start_time-offset)], 
        :post => ["-ss", Titlekit::ASS.build_timecode(offset), "-to", Titlekit::ASS.build_timecode(@parent.end_time-@parent.start_time), "-copyts"],
        :filename => "tmp%04d.jpg"
      )
      Storyboard::Binaries.ffmpeg(cmd)
    end

    def format
      "tmp*.jpg"
    end

  end
end