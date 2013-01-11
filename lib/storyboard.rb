load 'lib/subtitles.rb'
load 'lib/thread-util.rb'

require 'mime/types'

class Storyboard
  attr_accessor :options, :capture_points, :subtitles, :frames

  def initialize(o)
    @options = o
    check_video
    @subtitles = SRT.new(options[:subs] ? File.read(options[:subs]) : get_subtitles, options)
    # temp hack so I don't have to wait all the time.
    @subtitles.save if options[:verbose]

    @capture_points = []
    run_scene_detection if options[:scenes]

    consolidate_frames

    extract_screenshots
  end

  def run_scene_detection
    LOG.info("Scanning for scene changes. This may take a moment.")
    Open3.popen3("ffprobe", "-show_frames", "-of", "compact=p=0", "-f", "lavfi", %(movie=#{options[:file]},select=gt(scene\\,.35)), "-pretty") {|stdin, stdout, stderr, wait_thr|
       stdout.readlines.each {|line|
          # trolololol
          o = line.split('|').inject({}){|hold,value| s = value.split('='); hold[s[0]]=s[1]; hold }
          @capture_points << STRTime.parse(o['pkt_pts_time'])
        }
    }
    LOG.info("#{@capture_points.count} scenes registered")
  end

  def consolidate_frames
    @subtitles.pages.each {|f| @capture_points <<  f[:start_time] }
    @capture_points = @capture_points.sort_by {|cp| cp.value }
    last_time = STRTime.new(0)
    removed = 0
    @capture_points.each_with_index {|ts,i|
      # while it should be a super rare condition, this should not be
      # allowed to delete subtitle frames.
      if (ts.value - last_time.value) < options[:consolidate_frame_threshold]
        @capture_points.delete_at(i-1) unless i == 0
        removed += 1
      end
      last_time = ts
    }
    LOG.debug("Removed #{removed} frames that were within the consolidate_frame_threshold of #{options[:consolidate_frame_threshold]}")
  end

  def extract_screenshots
    pool = Thread::Pool.new(8)
    pbar = ProgressBar.create(:title => " Extracting Frames", :format => '%t [%c/%C|%B] %e', :total => @capture_points.count)
    #pbar.long_running
    #pbar.format = "%-20s %3d%% %s %s"
    save_directory = File.join(options[:write_to], 'raw_frames')
    Dir.mkdir(save_directory) unless File.directory?(save_directory)
    @frames = []
    @capture_points.each_with_index {|f,i|

      seek_primer = (f.value < 1.000)  ? 0 : -1.000
      # should make Frame a struct with idx and subs
      image_name = File.join(save_directory, "%04d.jpg" % [i])
      pool.process {
        pbar.increment
        #p "Writing #{image_name}"
        cmd = ["ffmpeg", "-ss", (f + seek_primer).to_srt, "-i", %("#{options[:file]}"), "-vframes 1", "-ss", STRTime.new(seek_primer.abs).to_srt, %("#{image_name}")].join(' ')
        Open3.popen3(cmd){|stdin, stdout, stderr, wait_thr|
          stdout.readlines
          #p stderr.readlines
        }
      }
    }
    pool.shutdown
    pbar.clear
    LOG.info("Finished Extracting Frames")
  end

  def check_video
    LOG.debug MIME::Types.type_for(options[:file])
  end

end
