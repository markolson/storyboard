module Storyboard::Extractor
  class Range
  	attr_accessor :parent
  	attr_accessor :start, :end, :fps
  	def initialize(parent)
  		@parent = parent
  	end
  end
end