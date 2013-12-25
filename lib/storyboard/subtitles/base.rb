module Storyboard::Subtitles
  class Base
    attr_accessor :parent, :subs, :max_font_size, :tmpfile

    attr_accessor :prawn_scratch
    def initialize(parent)
      @parent = parent
      @max_font_size = 16
      @subs = []
      @tmpfile = ::Tempfile.new('storyboard')
    end

    def add_line(start_time, end_time, lines)
      @subs << {:start => start_time, :end => end_time, :lines => lines, :max_font => max_font_for(lines)}
    end

    def write
      out = Titlekit::ASS.export(@subs, 
        { 'PlayResX' => @parent.video.width, 
          'PlayResY' => @parent.video.height, 
          'FontName' => 'Verdana', 
          'Fontsize' => @max_font_size, 
          'Shadow' => 6
        }
      )
      @parent.post << "-copyts"
      @parent.filters << "ass=#{@tmpfile.path}"
      @parent.filters << "setpts=PTS-#{parent.start_time}/TB"
      @tmpfile.write(out).size()
      @tmpfile.rewind
    end

    private
    def max_font_for(lines)
      font_path = ::File.expand_path(::File.join(__FILE__, "..", "..", "..", "..", "resources", "fonts"))
      @prawn_scratch ||= ::Prawn::Document.new(:page_size => [@parent.video.width, @parent.video.height], :margin => [0,0,0,0] )
      @prawn_scratch.font ::File.join(font_path, "Verdana.ttf")

      ratio = 0
      bump = 0
      font_size = 16
      while ratio < 0.8 && bump < (@prawn_scratch.bounds.height / 3)
        ratio = @prawn_scratch.width_of(lines, size: font_size, kerning: true) / (@prawn_scratch.bounds.width.to_f)
        font_size += 1
        bump = prawn_scratch.height_of(lines, size: font_size, kerning: true)
      end

      @max_font_size = font_size if font_size > @max_font_size
      font_size
    end
  end
end