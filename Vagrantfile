Vagrant::Config.run do |config|
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
  config.vm.box = "precise64"

  config.vm.define 'pdftv' do |chef_server|
    chef_server.vm.host_name = 'pdftv'
    chef_server.vm.network :hostonly, "33.33.33.226"
  end
end
