module Storyboard
  class CLI
    def self.global_options(opts)
      opts.opt :subtitle_path, "Subtitle Path", :short => '-s', :long => '--subtitle', :type => :string
      opts.opt :nudge, "Subtitle Adjustment", :short => '-n', :long => '--nudge', :type => :float

      opts.opt :start_time, "Start Time", long: "--start", :type => :string
      opts.opt :end_time, "End Time", long: "--end", :type => :string

      opts.opt :quality, "Output Quality", :long => '--quality', :type => :int
      opts.opt :dimensions, "Output Dimensions", short: '-d', long: '--output-size', type: :string
      opts.opt :preview, "Preview", :long => '--preview', :type => :int, default: 10
    end
  end
end