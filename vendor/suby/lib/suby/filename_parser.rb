module Suby
  module FilenameParser
    extend self

    # from tvnamer @ ab2c6c, with author's agreement, adapted
    # See https://github.com/dbr/tvnamer/blob/master/tvnamer/config_defaults.py
    TVSHOW_PATTERNS = [
      # foo.s0101
      /^(?<show>.+?)
      [ \._\-]
      [Ss](?<season>[0-9]{2})
      [\.\- ]?
      (?<episode>[0-9]{2})
      (?<title>[^0-9]*)$/x,

      # foo.1x09*
      /^(?<show>.+?)
      [ \._\-]
      \[?
      (?<season>[0-9]+)
      [xX]
      (?<episode>[0-9]+)
      \]?
      [ \._\-]*
      (?<title>[^\/]*)$/x,

      # foo.s01.e01, foo.s01_e01
      /^(?<show>.+?)
      [ \._\-]
      \[?
      [Ss](?<season>[0-9]+)[\. _-]?
      [Ee]?(?<episode>[0-9]+)
      \]?
      [ \._\-]*
      (?<title>[^\/]*)$/x,

      # foo - [01.09]
      /^(?<show>.+?)
      [ \._\-]?
      \[
      (?<season>[0-9]+?)
      [.]
      (?<episode>[0-9]+?)
      \]
      [ \._\-]?
      (?<title>[^\/]*)$/x,

      # Foo - S2 E 02 - etc
      /^(?<show>.+?)
      [ ]?[ \._\-][ ]?
      [Ss](?<season>[0-9]+)[\.\- ]?
      [Ee]?[ ]?(?<episode>[0-9]+)
      (?<title>[^\/]*)$/x,

      # Show - Episode 9999 [S 12 - Ep 131] - etc
      /(?<show>.+)
      [ ]-[ ]
      [Ee]pisode[ ]\d+
      [ ]
      \[
      [sS][ ]?(?<season>\d+)
      ([ ]|[ ]-[ ]|-)
      ([eE]|[eE]p)[ ]?(?<episode>\d+)
      \]
      (?<title>.*)$/x,

      # foo.103*
      /^(?<show>.+)
      [ \._\-]
      (?<season>[0-9]{1})
      (?<episode>[0-9]{2})
      (?<title>[\._ -][^\/]*)$/x,
    ]
    MOVIE_PATTERN = /^(?<movie>.*)[.\[( ](?<year>(?:19|20)\d{2})/

    def parse(file)
      filename = File.basename(file, ".*")
      if TVSHOW_PATTERNS.find { |pattern| pattern.match(filename) }
        m = $~
        { type: :tvshow, show: clean_show_name(m[:show]), season: m[:season].to_i, episode: m[:episode].to_i, title: m[:title] }
      elsif m = MOVIE_PATTERN.match(filename)
        { type: :movie, name: clean_show_name(m[:movie]), year: m[:year].to_i }
      else
        { type: :unknown, name: filename }
      end
    end

    # from https://github.com/dbr/tvnamer/blob/master/tvnamer/utils.py#L78-95
    # Cleans up series name by removing any . and _
    # characters, along with any trailing hyphens.
    #
    # Is basically equivalent to replacing all _ and . with a
    # space, but handles decimal numbers in string.
    #
    #   clean_show_name("an.example.1.0.test") # => "an example 1.0 test"
    #   clean_show_name("an_example_1.0_test") # => "an example 1.0 test"
    def clean_show_name show
      show.gsub!(/(?<!\d)[.]|[.](?!\d)/, ' ')
      show.tr!('_', ' ')
      show.chomp!('-')
      show.strip!
      show
    end
  end
end
