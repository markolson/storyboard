
module Storyboard::Extractor
  class Points < Storyboard::Extractor::Base

    attr_accessor :sub_points, :extracted_points

    def initialize(runner)
      @extracted_points, @sub_points = [], []
      super(runner)
    end


    def run
      runner.ui.progress("Extracting images", raw_points.count) do |bar|
        raw_points.each_with_index {|pt, i|
          img_name = "tmp%06d.jpg" % [i]
          offset = (pt > 1) ? 1 : 0
          cmd = build_ffmpeg_command(
            :pre => ["-v", "quiet", "-ss", Titlekit::ASS.build_timecode(pt-offset)], 
            :post => ["-ss", Titlekit::ASS.build_timecode(offset), "-vframes", "1", "-copyts"],
            :filters => ["setpts=PTS-#{pt}/TB"],
            :filename => img_name
          )
          Storyboard::Binaries.ffmpeg(cmd)
          bar.progress = i
        }
      end
    end

    def raw_points
      full_list = (@sub_points + @extracted_points).sort
      o = full_list.dup
      last_time = -1
      full_list.delete_if {|a|  
        del = a - last_time < 0.4
        last_time = a
        del
      }
    end


    def add_from_subtitles(subs)
      found = subs.subtitles.map{|s| s[:start] + 0.01 }
      runner.ui.log("Added #{found.count} extraction points from subtitles")
      @sub_points = found
    end

    def add_from_ffprobe
      found = []
      runner.ui.progress("Searching for scene changes", runner.end_time) do |bar|

        #TODO: ffprobe errors out if a start seek time is used.
        # Discard unneeded entries for now.

        interval = "%#{Titlekit::ASS.build_timecode(runner.end_time)}" 

        Open3.popen3('./resources/binaries/ffprobe', "-read_intervals", interval,  "-show_frames", "-of", "compact=p=0", "-f", "lavfi", %(movie=#{runner.video.path},select=gt(scene\\,.30)), "-pretty") {|stdin, stdout, stderr, wait_thr|
           begin
              o = stdout.gets
              next if o.nil?
              o = o.split('|').inject({}){|hold,value| s = value.split('='); hold[s[0]]=s[1]; hold }
              point = runner.ts_to_s(o['pkt_pts_time'])
              bar.progress = point
              found << point if point >= runner.start_time && point <= runner.end_time
            end while !stdout.eof?
        }
      end
      runner.ui.log("Added #{found.count} extraction points from scanning for scene changes")
      @extracted_points = found
    end

    def format
      "tmp*.jpg"
    end

  end
end