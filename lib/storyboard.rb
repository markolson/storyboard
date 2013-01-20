require 'storyboard/subtitles.rb'
require 'storyboard/bincheck.rb'
require 'storyboard/thread-util.rb'
require 'storyboard/time.rb'
require 'storyboard/version.rb'

require 'storyboard/generators/sub.rb'
require 'storyboard/generators/pdf.rb'

require 'mime/types'
require 'fileutils'
require 'sanitize'

class Storyboard
  attr_accessor :options, :capture_points, :subtitles, :timings
  attr_accessor :length, :renderers, :mime

  def initialize(o)
    @capture_points = []
    @renderers = []
    @options = o

    check_video
  end

  def run
    LOG.info("Processing #{options[:file]}")
    setup

    @subtitles = SRT.new(options[:subs] ? File.read(options[:subs]) : get_subtitles, options)
    # bit of a temp hack so I don't have to wait all the time.
    @subtitles.save if options[:verbose]


    @renderers << Storyboard::PDFRenderer.new(self) if options[:types].include?('pdf')

    run_scene_detection if options[:scenes]
    consolidate_frames
    extract_frames
    render_output

    cleanup
  end

  def run_scene_detection
    pbar = ProgressBar.create(:title => " Analyzing Video", :format => '%t [%B] %e', :total => @length, :smoothing => 0.6)
    bin = File.join(File.dirname(__FILE__), '../bin/storyboard-ffprobe')
    Open3.popen3('ffprobe', "-show_frames", "-of", "compact=p=0", "-f", "lavfi", %(movie=#{options[:file]},select=gt(scene\\,.30)), "-pretty") {|stdin, stdout, stderr, wait_thr|
        begin
          # trolololol
          o = stdout.gets.split('|').inject({}){|hold,value| s = value.split('='); hold[s[0]]=s[1]; hold }
          t = STRTime.parse(o['pkt_pts_time'])
          pbar.progress = t.value
          @capture_points << t
        end while !stdout.eof?
    }
    pbar.finish
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

  def extract_frames
    pool = Thread::Pool.new(2)
    pbar = ProgressBar.create(:title => " Extracting Frames", :format => '%t [%c/%C|%B] %e', :total => @capture_points.count)

    @capture_points.each_with_index {|f,i|
      # It's *massively* quicker to jump to a bit before where we want to be, and then make the incrimental jump to
      # exactly where we want to be.
      seek_primer = (f.value < 1.000)  ? 0 : -1.000
      # should make Frame a struct with idx and subs
      image_name = File.join(@options[:save_directory], "%04d.jpg" % [i])
      pool.process {
        pbar.increment
        cmd = ["ffmpeg", "-ss", (f + seek_primer).to_srt, "-i", %("#{options[:file]}"), "-vframes 1", "-ss", STRTime.new(seek_primer.abs).to_srt, %("#{image_name}")].join(' ')
        Open3.popen3(cmd){|stdin, stdout, stderr, wait_thr|
          # block the output so it doesn't quit immediately
          stdout.readlines
        }
      }
    }
    pool.shutdown
    LOG.info("Finished Extracting Frames")

  end

  def render_output
    pbar = ProgressBar.create(:title => " Rendering Output", :format => '%t [%c/%C|%B] %e', :total => @capture_points.count)
    @capture_points.each_with_index {|f,i|
      image_name = File.join(@options[:save_directory], "%04d.jpg" % [i])
      capture_point_subtitles = @subtitles.pages.select { |page| f.value >=  page.start_time.value and f.value <= page.end_time.value }.first
      begin
        @renderers.each{|r| r.render_frame(image_name, capture_point_subtitles) }
      rescue
        p $!
      end
      pbar.increment
    }

    @renderers.each {|r| r.write }
    LOG.info("Finished Rendering Output files")
  end

  def check_video
    @mime = MIME::Types.type_for(options[:file])
    if video_file?
      @length = `ffmpeg -i "#{options[:file]}" 2>&1 | grep "Duration" | cut -d ' ' -f 4 | sed s/,//`
      @length = STRTime.parse(length.strip+'0').value
    end
  end

  def video_file?
    !@mime.grep(/video\//).empty?
  end

  def mkv?
    !@mime.grep(/matroska/).empty?
  end

  def setup
    @options[:basename] = File.basename(options[:file], ".*")
    @options[:work_dir] = Dir.mktmpdir
    Dir.mkdir(@options[:write_to]) unless File.directory?(@options[:write_to])
    @options[:save_directory] = File.join(@options[:work_dir], 'raw_frames')
    Dir.mkdir(@options[:save_directory]) unless File.directory?(@options[:save_directory])
  end

  def cleanup
    FileUtils.remove_dir(@options[:work_dir])
  end

end
