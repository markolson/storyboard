module Storyboard::Subtitles
  class Loader
    attr_accessor :parent, :subtitles

    LOADERS = {
      text: proc { |s|
        p "hello from text"
        raise Trollop::CommandlineError, "--start cannot be further than --end" if start_time >= end_time
        @sub.add_line(start_time, end_time, options[:use_text])
        true
      },
      local: proc {
        p "hello from local"
        false
      },
      web: proc {
        p "hello from web"
        true
      }
    }

    def initialize(parent)
      @parent = parent
    end

    def load_from(*types)
      p types
      types.detect {|loader|
        LOADERS[loader].call(s)
      }
    end
  end
end