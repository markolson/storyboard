module Storyboard::Subtitles
  class Web < Storyboard::Subtitles::File
  	attr_accessor :osdb
  	def initialize(parent)
  		@osdb = OSDb::MovieFile.new(parent.options['_video'] )
  		super(parent)
  	end

  	def download
  		server = OSDb::Server.new(
	      :timeout => 90, 
	      :useragent => "SubDownloader 2.0.10"
	    ) 

			search_engines = [OSDb::Search::MovieHash, OSDb::Search::IMDB, OSDb::Search::Name, OSDb::Search::Path].map{|se|
				se.new(server)
			}
			finders = [OSDb::Finder::Score.new]
			selectors = [OSDb::Selector::Movie.new(OSDb::Finder::First.new)]
			subtitle_finder = OSDb::SubtitleFinder.new(search_engines, finders, selectors)
			
			found = subtitle_finder.find_sub_for(osdb, 'eng')
			p found

			really_temporary_temp = ::Tempfile.new(['storyboard.web', ".#{found.format}"])

			really_temporary_temp.write(clean(found.body.lines))
			writer = load_subs(really_temporary_temp)
  	end
  end
end

