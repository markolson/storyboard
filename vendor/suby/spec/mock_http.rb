class Suby::Downloader
  caches = {}
  [:get, :post, :get_redirection].each { |meth|
    original_method = instance_method(meth)
    remove_method meth
    define_method(meth) { |*args|
      file = 'spec/fixtures/' + self.class::SITE.downcase + '.marshal'
      caches[file] ||= File.exist?(file) ? Marshal.load(IO.read(file)) : {}
      data = caches[file]

      if data[args]
        data[args]
      else
        puts "doing the real request: #{meth}(#{args * ', '})"
        value = original_method.bind(self).call(*args)
        data[args] = value
        File.write(file, Marshal.dump(data))
        value
      end
    }
  }
end
