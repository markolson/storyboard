load 'lib/subtitles.rb'

require 'mime/types'

class Storyboard
  attr_accessor :options
  def initialize(o)
    @options = o
    check_video
    srt = SRT.new(options[:subs] ? File.read(options[:subs]) : get_subtitles, options)
    srt.save unless options[:subs]
    LOG.info("Parsed subtitle file. #{srt.pages} entries found.")

    LOG.info("Scanning #{options[:basename]} for scene changes. This may take a moment.")
    @scenes = []
    if options[:scenes]
      Open3.popen3("ffprobe", "-show_frames", "-of", "compact=p=0", "-f", "lavfi", %(movie=#{options[:file]},select=gt(scene\\,.35)), "-pretty") {|stdin, stdout, stderr, wait_thr|
        @scenes = stdout.readlines
      }
    end
    LOG.info("#{@scenes.count} scenes registered")
  end

  def check_video
    LOG.debug MIME::Types.type_for(options[:file])
  end

end
