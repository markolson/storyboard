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

    def filter(types)
      types.each {|filter|
        pre = @subtitles.count
        @subtitles = filter.run(self, runner)
        runner.ui.log("#{filter} caused a diff of #{pre - @subtitles.count}")
      }
    end

    def write
      runner.extractor.filters << "ass=#{@subtitle_file.path}"

      clean_subtitles

      out = Titlekit::ASS.export(@subtitles, 
        { 'PlayResX' => @runner.video.width, 
          'PlayResY' => @runner.video.height, 
          'FontName' => 'Verdana', 
          'Fontsize' => find_optimal_font_size, 
          'Shadow' => 6
        }
      )
      p out
      @subtitle_file.write(out).size()
      @subtitle_file.rewind
    end

    def add_line(start_time, end_time, lines)
      @subtitles << {:start => start_time, :end => end_time, :lines => lines.join("\\N") }
    end

    def load_from_file(path)
      cleaned_file = clean_with_ffmpeg(path)
      runner.ui.log("Starting loading subtitle file")

      job = Titlekit::Job.new
      input = job.have
      input.encoding(@encoding)
      input.file(cleaned_file)
      begin
        job.send(:import, input)
      rescue
        p job.report
        exit
      end

      output = job.want
      output.file(@tmpfile)
      output.subtitles =  input.subtitles.clone

      Titlekit::ASS.master(output.subtitles)
      job.send(:polish, output)
      @subtitles = output.subtitles
      runner.ui.log("Done loading subtitle file")
    end

    def clean_with_ffmpeg(path)
      runner.ui.log("Cleaning subtitle file before loading")
      really_temporary_temp = ::Tempfile.new(['storyboard.file', ::File.extname(path)])
      cleaned_body = clean_lines(::File.read(path).lines).join("\n")

      really_temporary_temp.write(cleaned_body)
      really_temporary_temp.rewind.size
      really_temporary_temp.flush
      Storyboard::Binaries.ffmpeg(["-v", "quiet", "-y", "-i", really_temporary_temp.path, really_temporary_temp.path])
      really_temporary_temp.path
    end

    private
    def clean_lines(lines)
      lines.map{|line| clean_line(line) }
    end

    def clean_line(text)
      if !(text.bytes.to_a & [233,146]).empty? && @encoding == 'UTF-8'
        text = text.unpack("C*").pack("U*")
      end
      text = text.strip
      text.force_encoding(@encoding).encode(@encoding)
      text
    end

    def clean_subtitles
     @subtitles.map{ |line| 
        line[:lines] = clean_line(line[:lines])
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