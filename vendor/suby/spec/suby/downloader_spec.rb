require_relative '../spec_helper'

describe Suby::Downloader do
  downloader = Suby::Downloader.new Path('How I Met Your Mother 3x9 - Slapsgiving.mkv')
  it 'guess the right type of subtitles from the contents' do
    downloader.sub_extension("1\r\n00").should == 'srt'
    downloader.sub_extension("\xEF\xBB\xBF1\r\n00:00:14,397").should == 'srt'
    downloader.sub_extension("\xEF\xBB\xBF1\r\n00:00:14,397").should == 'srt'
    downloader.sub_extension("{346}{417}informa").should == 'sub'
  end
end
