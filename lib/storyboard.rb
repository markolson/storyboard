load 'lib/subtitles.rb'

require 'mime/types'

class Storyboard
  attr_accessor :options
  def initialize(o)
    @options = o
    check_video
    srt = SRT.new(options[:subs] ? File.read(options[:subs]) : get_subtitles)
    p srt.pages
  end

  def check_video
    LOG.debug MIME::Types.type_for(options[:file])
  end

end
