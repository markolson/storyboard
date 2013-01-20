require File.expand_path('../lib/storyboard/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Mark Olson"]
  gem.email         = ["\"theothermarkolson@gmail.com\""]
  gem.description   = %q{Generate PDFs and eBooks from video files}
  gem.summary       = %q{Video to PDF/ePub generator}
  gem.homepage      = "http://github.com/markolson/storyboard"

  gem.required_ruby_version = '>= 1.9.3'

  gem.files         = `git ls-files`.split($\) if File.exist?('.git')
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "storyboard"
  gem.require_paths = ["lib","vendor/suby"]
  gem.version       = Storyboard::VERSION

  gem.add_dependency 'nokogiri'
  gem.add_dependency 'rmagick'
  gem.add_dependency 'prawn'
  gem.add_dependency 'ruby-progressbar'
  gem.add_dependency 'levenshtein-ffi'

  # suby stuff.
  gem.add_dependency 'path', '>= 1.3.0'
  gem.add_dependency 'rubyzip'
  gem.add_dependency 'term-ansicolor'
  gem.add_dependency 'mime-types', '>= 1.19'

end
