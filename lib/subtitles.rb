load 'lib/time.rb'

class Storyboard
  def get_subtitles
    if false == "the file has subtitles embedded"

    else
      LOG.debug("No subtitles embeded. Using suby.")
      # suby includes a giant util library the guy also wrote
      # that it uses to call file.basename instead of File.basename(file),
      #but "file" has to be a "Path", so, whatever.
      suby_file = Path(options[:file])
      downloader = Suby::Downloader::OpenSubtitles.new(suby_file, 'en')
      LOG.debug("Found #{downloader.download_url}")
      downloader.extract(downloader.download_url)
    end
  end


  class SRT
    Page = Struct.new(:index, :start_time, :end_time, :lines)

    TIME_REGEX = /\d{2}:\d{2}:\d{2},\d{3}/
    attr_accessor :text, :pages, :options

    def initialize(contents, parent_options)
      @options = parent_options
      @text = contents
      @pages = []
      parse
      clean_promos
    end

    #There are some horrid files, so I want to be able to have more than just a single regex
    #to parse the srt file. Eventually, handling these errors will be a thing to do.
    #There's also some files with UTF8 BOM markers that should be handled, but wtf.
    #And and and badly encoded UTF8.
    def parse
      phase = :line_no
      page = nil
      @text.each_line {|l|
        l = l.strip
        case phase
        when :line_no
          if l =~ /^\d+$/
            page = Page.new(@pages.count + 1, nil, nil, [])
            phase = :time
          elsif !l.empty?
            raise "Bad SRT File: Should have a block number but got '#{l}'"
          end
        when :time
          if l =~ /^(#{TIME_REGEX}) --> (#{TIME_REGEX})$/
            page[:start_time] = STRTime.parse($1)
            page[:end_time] = STRTime.parse($2)
            phase = :text
          else
            raise "Bad SRT File: Should have time range but got '#{l}'"
          end
        when :text
          if l.empty?
            phase = :line_no
            @pages << page
          else
            page[:lines] << l
          end
        end
      }
    end

    # Strip out obnoxious "CREATED BY L33T DUD3" or "DOWNLOADED FROM ____" text
    def clean_promos
      @pages.delete_if {|page|
        !page[:lines].grep(/Subtitles downloaded/).empty? ||
        false
      }
    end

    def save
      File.open(File.join(options[:write_to], options[:basename] + '.srt'), 'w') {|f|
        f.write(self.to_s)
      }
      self
    end

    def to_s
       text
    end

    def pages
      @pages.count
    end
  end

end
