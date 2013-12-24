module Storyboard
  class CLI
    def self.options(opts, &block)
      opts.opt :subtitle_path, "Subtitle Path", :short => '-s', :long => '--subtitle', :type => :io
      opts.opt :nudge, "Subtitle Adjustment", :short => '-n', :long => '--nudge', :type => :string, ex: 'HH:MM:SS.ms'

      opts.opt :start_time, "Start Time", long: "--start", :type => :string, ex: 'HH:MM:SS.ms'
      opts.opt :end_time, "End Time", long: "--end", :type => :string, ex: 'HH:MM:SS.ms'

      opts.opt :quality, "Output Quality", :long => '--quality', :type => :string, ex: '75%'
      opts.opt :dimensions, "Output Dimensions", short: '-d', long: '--output-size', type: :string, ex: '1080x720 or 50%'
      opts.opt :preview, "Preview", :long => '--preview', :type => :int, default: 10

      block.call(opts)
    end
  end
end