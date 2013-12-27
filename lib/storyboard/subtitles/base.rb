module Storyboard::Subtitles
  class Base
    attr_accessor :parent, :subs, :max_font_size, :tmpfile

    attr_accessor :prawn_scratch
    def initialize(parent)
      @parent = parent
      @min_font_sizes = []
      @subs = []
      @tmpfile = ::Tempfile.new('storyboard')
    end

    def write
      out = Titlekit::ASS.export(@subs, 
        { 'PlayResX' => @parent.video.width, 
          'PlayResY' => @parent.video.height, 
          'FontName' => 'Verdana', 
          'Fontsize' => @min_font_sizes.min, 
          'Shadow' => 6
        }
      )

      @parent.extractor.post << "-copyts"
      @parent.extractor.filters << "ass=#{@tmpfile.path}"
      @parent.extractor.filters << "setpts=PTS-#{parent.start_time}/TB"

      @tmpfile.write(out).size()
      @tmpfile.rewind
    end

    private
    def max_font_for(lines)
      lines = lines.split("\\N").flatten.map{|x| x.split("\n") }.flatten.map{|x| x.split("\r") }.flatten
      font_path = ::File.expand_path(::File.join(__FILE__, "..", "..", "..", "..", "resources", "fonts"))
      @prawn_scratch ||= ::Prawn::Document.new(:page_size => [@parent.video.width, @parent.video.height], :margin => [0,0,0,0] )
      @prawn_scratch.font ::File.join(font_path, "Verdana.ttf")

      line_widths = lines.map{ |line|
        ratio = 0
        bump = 0
        font_size = 20
        while ratio < 0.9 && bump < (@prawn_scratch.bounds.height / 3)
          ratio = @prawn_scratch.width_of(line, size: font_size, kerning: true) / (@prawn_scratch.bounds.width.to_f)
          font_size += 1
          bump = prawn_scratch.height_of(line, size: font_size, kerning: true)
        end
        font_size
      }
      @min_font_sizes << line_widths.min
      line_widths
    end
  end
end