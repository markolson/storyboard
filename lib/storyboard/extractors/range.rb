module Storyboard::Extractor
  class Range < Storyboard::Extractor::Base

    attr_accessor :fps
    def run
      filters << "fps=#{@fps}"

      offset = (@runner.start_time > 1) ? 1 : 0
      @filters << "setpts=PTS-#{@runner.start_time}/TB"

      cmd = build_ffmpeg_command(
        :pre => ["-ss", Titlekit::ASS.build_timecode(@runner.start_time-offset)], 
        :post => ["-ss", Titlekit::ASS.build_timecode(offset), "-to", Titlekit::ASS.build_timecode(@runner.end_time-@runner.start_time), "-copyts"],
        :filename => "tmp%04d.jpg"
      )
      runner.ui.progress("Extracting images", 475) do |bar|
        Open3.popen3(Storyboard::Binaries.ffmpeg_cmd(cmd)) {|stdin, stdout, stderr, wait_thr|
          begin
            match = stderr.read_nonblock(1024).match(/frame\=\s+(\d+)/)
            bar.progress = match[1].to_i if match
          rescue
          end while !stderr.eof?
        }
      end
    end

    def format
      "tmp*.jpg"
    end

  end
end