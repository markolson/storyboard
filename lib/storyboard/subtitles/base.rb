module Storyboard::Subtitles
  class Base
    attr_accessor :parent, :subs, :max_font_size, :tmpfile, :encoding

    attr_accessor :prawn_scratch
    def initialize(parent)
      @encoding = 'UTF-8'
      @parent = parent
      @min_font_sizes = []
      @subs = []
      @tmpfile = ::Tempfile.new('storyboard')
    end

    def add_line(start_time, end_time, lines)
      @subs << {:start => start_time, :end => end_time, :lines => lines.join("\\N"), :max_font => max_font_for(lines.join("\\N"))}
    end

    def write
      @parent.extractor.post << "-copyts"
      @parent.extractor.filters << "ass=#{tmpfile.path}"
      @parent.extractor.filters << "setpts=PTS-#{@parent.start_time}/TB"

      # trim out the fat so that we can set the correct max font size.
      @subs = @subs.select{|s| 
        (s[:start] <= parent.end_time) &&  (s[:end] >= parent.start_time)
      }
      @subs.each{|l| max_font_for(l[:lines]) }

      out = Titlekit::ASS.export(@subs, 
        { 'PlayResX' => @parent.video.width, 
          'PlayResY' => @parent.video.height, 
          'FontName' => 'Verdana', 
          'Fontsize' => @min_font_sizes.min, 
          'Shadow' => 6
        }
      )
      @tmpfile.write(out).size()
      @tmpfile.rewind
    end

    def fix_encoding_of(l)
      # The only  ISO8859-1  I hit so far. I expec this to grow.
      if !(l.bytes.to_a | [233,146]).empty? && @encoding == 'UTF-8'
        l = l.unpack("C*").pack("U*")
      end
      l
    end

    def clean(lines)
      lines.map{ |line| 
        line = fix_encoding_of(line)
        line = line.strip
      }.join("\n").force_encoding(@encoding).encode(@encoding)
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