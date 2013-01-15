require_relative '../../spec_helper'

describe Suby::Downloader::OpenSubtitles do
  file = Path("breaking.bad.s05e04.hdtv.x264-fqm.mp4")
  downloader = Suby::Downloader::OpenSubtitles.new file
  correct_query = [{ moviehash: "709b9ff887cf987d", moviebytesize: "308412149", sublanguageid: "eng" }]
  wrong_query = correct_query.first.merge({ sublanguageid: "wrong_language" })

  it 'finds the right subtitles' do
    response = downloader.search_subtitles(correct_query)['data']
    response.should_not be_false
    response.first['MovieName'].should == '"Breaking Bad" Fifty-One'
  end

  it 'finds the right download link' do
    url = downloader.download_url
    url.should match(%r{http(s)?://.*opensubtitles.org/en/download/.*})
  end

  it "doesn't find anything for bad query" do
    response = downloader.search_subtitles(wrong_query)['data']
    response.should be_false
  end

  it "gets right token" do
    downloader.token.should match(/\A[a-z0-9]{26}\z/)
  end

  it 'fails gently when there is no subtitles available' do
    d = Suby::Downloader::OpenSubtitles.new(Path("Not Existing Show 1x1.mkv"), :eawdad)
    -> { d.download_url }.should raise_error(Suby::NotFoundError, "no subtitles available")
  end
end