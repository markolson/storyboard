module Storyboard::UI
  class Console
    require "highline/import"
    attr_accessor :parent, :logger
    def initialize(parent)
      @parent = parent
      @logger = Logger.new(STDOUT)
      # DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
      @logger.level = Logger::DEBUG
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{severity}] #{msg}\n"
      end
    end

    def log(msg, level=Logger::DEBUG)
      @logger.add(level) { "#{parent.name}> #{msg}" }
    end

    def progress(name, max_value, &block) 
      pbar = ProgressBar.create(:title => "  #{name}", :format => '%t [%B] %e', :total => max_value, :smoothing => 0.6, :throttle_rate => 0.1)
      yield(pbar)
      pbar.finish
    end

    def pick(question, options)
      options = options.map.with_index { |o,i|
          formatted = HighLine.color(o[2].lines.join("\t"), HighLine::BOLD_STYLE)
          "#{i+1}: #{o[0]} - #{o[1]} \n\t#{formatted}"
      }.join("\n")

      say HighLine.color("Multiple matches found. Select one to continue..", HighLine::BOLD_STYLE, HighLine::RED_STYLE)
      say(options)
      return ask("Subtitle to use?  ", Integer) { |q| q.in = 1..(options.length) } - 1
    end
  end
end