module Suby
  # from http://trac.opensubtitles.org/projects/opensubtitles/wiki/HashSourceCodes
  module MovieHasher

    CHUNK_SIZE = 64 * 1024 # in bytes
    MASK64 = 0xffffffffffffffff # 2^64 - 1

    def self.compute_hash(file)
      filesize = file.size
      hash = filesize

      # Read 64 kbytes, divide up into 64 bits and add each
      # to hash. Do for beginning and end of file.
      file.open('rb') do |f|
        # Q = unsigned long long = 64 bit
        f.read(CHUNK_SIZE).unpack("Q*").each do |n|
          hash = (hash + n) & MASK64
        end

        f.seek([0, filesize - CHUNK_SIZE].max, IO::SEEK_SET)

        # And again for the end of the file
        f.read(CHUNK_SIZE).unpack("Q*").each do |n|
          hash = (hash + n) & MASK64
        end
      end

      "%016x" % hash
    end
  end
end
