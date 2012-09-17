require 'rubygems'
require 'fileutils'
require 'uri'
require 'rbvmomi'

VIM = RbVmomi::VIM

module Vagrant
  module Downloaders
    # Creates a file detailing where the VM is stored in VirtualMachineInfrastructure. This downloader
    # does not download any content from VirtualMachineInfrastructure. This is in preperation for cloning.
    # an existing image in VMWare's Virtual Machine Infrastructure.
    #
    # supports urls of the form : USER:PASSWORD@HOSTNAME/DC/SOME/FOLDERS/VM_NAME
    class VirtualMachineInfrastructure < Base
      def self.match?(uri)
        extracted = URI.extract(uri, ['vmi']).first
        extracted && extracted.include?(uri)
      end

      def download!(source_url, destination_file)
        uri = URI.parse(source_url)
        vm_path = uri.path.split '/'

        # drop the first, it's an empy string
        vm_path.shift

        # the first element in the array is the datacenter name
        datacenter_name = vm_path.shift

        # the last element in the array is the vm_name
        vm_name = vm_path.pop

        # setting insecure to allow self-signed ssl certificates
        vim = VIM.connect host: uri.host, user: uri.user, password: URI.unescape(uri.password), :insecure => true

        dc = vim.serviceInstance.find_datacenter(datacenter_name) or fail "datacenter not found"

        # descend the folders, if present
        parent_folder = dc.vmFolder
        vm_path.each do |folder_name|
          parent_folder.childEntity.grep(RbVmomi::VIM::Folder).find do |folder|
            if folder.name == URI.unescape(folder_name)
              parent_folder = folder
              break
            end
          end
        end

        # find the vm in the parent_folder
        control_vm = nil
        parent_folder.childEntity.grep(RbVmomi::VIM::VirtualMachine).find do |vm|
          if vm.name == URI.unescape(vm_name)
              control_vm = vm
              break
          end
        end

        print 'Found VM ' + control_vm.name
        #FileUtils.cp(::File.expand_path(source_url), destination_file.path)
        #'{"provider":"vmi"}'
      end
    end
  end
end
