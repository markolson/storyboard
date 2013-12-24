module Storyboard::UI
  class Console
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
  end
end