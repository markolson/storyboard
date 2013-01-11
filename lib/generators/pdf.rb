require 'rubygems'
require 'bundler/setup'
require 'prawn'

image_path = ARGV[0]


p image_path

pdf = Prawn::Document.new(:page_size => [640, 480], :margin => 0)
  Dir["#{image_path}/*.jpg"].each {|i|
    p i
    pdf.image i, :height => 480, :width => 640
  }

 pdf.render_file "#{image_path}.pdf"
