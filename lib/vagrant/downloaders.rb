module Vagrant
  module Downloaders
    autoload :Base, 'vagrant/downloaders/base'
    autoload :File, 'vagrant/downloaders/file'
    autoload :HTTP, 'vagrant/downloaders/http'
    autoload :VirtualMachineInfrastructure, 'vagrant/downloaders/vmi'
  end
end
