require 'term/ansicolor'

module Suby
  module Interface
    def success message
      puts Term::ANSIColor.green message
    end

    def failure message
       puts Term::ANSIColor.blue message
    end

    def error message
       puts Term::ANSIColor.red message
    end
  end
end
