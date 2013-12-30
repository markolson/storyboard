module Storyboard
  class Subtitles
    attr_accessor :runner, :subtitles, :encoding
    def initialize(parent)
      @runner = parent
      @encoding = 'UTF-8'
      @subtitles = []
      @subtitle_file = ::Tempfile.new(['storyboard.ffmpeg', '.ass'])
    end

    def load_from(types)
      types.detect {|loader| loader.run(self, runner) }
    end

    def write
      runner.extractor.post << "-copyts"
      runner.extractor.filters << "ass=#{@subtitle_file.path}"
      runner.extractor.filters << "setpts=PTS-#{runner.start_time}/TB"

      clean_subtitles

      out = Titlekit::ASS.export(@subtitles, 
        { 'PlayResX' => @runner.video.width, 
          'PlayResY' => @runner.video.height, 
          'FontName' => 'Verdana', 
          'Fontsize' => find_optimal_font_size, 
          'Shadow' => 6
        }
      )
      @subtitle_file.write(out).size()
      @subtitle_file.rewind
    end

    def add_line(start_time, end_time, lines)
      @subtitles << {:start => start_time, :end => end_time, :lines => lines.join("\\N") }
    end

    def load_file(path)

    end

    private
    def clean_subtitles
     @subtitles.map{ |line| 
        text = line[:lines]
        if !(text.bytes.to_a | [233,146]).empty? && @encoding == 'UTF-8'
          text = text.unpack("C*").pack("U*")
        end
        text = text.strip
        text.force_encoding(@encoding).encode(@encoding)
        line[:lines] = text
      }
    end

    def find_optimal_font_size
      lines = subtitles.map{ |frame| 
        frame[:lines].split("\\N").
        flatten.map{|x| x.split("\n") }.
        flatten.map{|x| x.split("\r") }.
        flatten
      }.flatten

      font_path = ::File.expand_path(::File.join(__FILE__, "..", "..", "..", "resources", "fonts"))
      @prawn_scratch ||= ::Prawn::Document.new(:page_size => [runner.video.width, runner.video.height], :margin => [0,0,0,0] )
      @prawn_scratch.font ::File.join(font_path, "Verdana.ttf")

      line_widths = lines.map{ |line|
        ratio = 0
        bump = 0
        font_size = 20
        while ratio < 0.9 && bump < (@prawn_scratch.bounds.height / 3)
          ratio = @prawn_scratch.width_of(line, size: font_size, kerning: true) / (@prawn_scratch.bounds.width.to_f)
          font_size += 1
          bump = @prawn_scratch.height_of(line, size: font_size, kerning: true)
        end
        font_size
      }
      line_widths.min
    end
  end
end