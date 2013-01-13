require File.expand_path('../lib/storyboard/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Mark Olson"]
  gem.email         = ["\"theothermarkolson@gmail.com\""]
  gem.description   = %q{Generate PDFs and eBooks from video files}
  gem.summary       = %q{Video to PDF/ePub generator}
  gem.homepage      = "http://github.com/markolson/storyboard"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "storyboard"
  gem.require_paths = ["lib"]
  gem.version       = Storyboard::VERSION

  gem.add_dependency 'nokogiri'
  gem.add_dependency 'rmagick'
  gem.add_dependency 'prawn'
  gem.add_dependency 'ruby-progressbar'
end
