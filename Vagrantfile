# For AWS, you need the following ENV variables:
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_KEYPAIR_NAME
# SSH_PRIVKEY
#
# For Rackspace, you need the following ENV variables:
# RS_USERNAME
# RS_API_KEY
# RS_PUBLIC_KEY
# SSH_PRIVKEY
#
# This was largely cribbed from https://github.com/relateiq/docker_public/blob/master/Vagrantfile

# Use the pre-built vagrant box: http://blog.phusion.nl/2013/11/08/docker-friendly-vagrant-boxes/
BOX_NAME = ENV['BOX_NAME'] || "docker-ubuntu-12.04.3-amd64-vbox"
BOX_URI = ENV['BOX_URI'] || "https://oss-binaries.phusionpassenger.com/vagrant/boxes/ubuntu-12.04.3-amd64-vbox.box"
VBOX_VERSION = ENV['VBOX_VERSION'] || "4.3.2"

Vagrant.configure("2") do |config|
  config.vm.box = BOX_NAME

  # No forwarded ports on this - we assume the vagrant server should only
  # be accessible locally. If this is wrong, feel free to add forwards in here.
  config.vm.network "forwarded_port", guest: 8000, host: 8000

  config.vm.provision "docker"

  # Virtualbox guest additions if needed
  # It is assumed Vagrant can successfully launch the provider instance.
  if Dir.glob("#{File.dirname(__FILE__)}/.vagrant/machines/default/*/id").empty?
    pkg_cmd = ''
    # Add guest additions if local vbox VM. As virtualbox is the default provider,
    # it is assumed it won't be explicitly stated.
    if ENV["VAGRANT_DEFAULT_PROVIDER"].nil? && ARGV.none? { |arg| arg.downcase.start_with?("--provider") }
      pkg_cmd << "echo 'Downloading VBox Guest Additions...'; " \
        "wget -q http://dlc.sun.com.edgesuite.net/virtualbox/#{VBOX_VERSION}/VBoxGuestAdditions_#{VBOX_VERSION}.iso; "
      # Prepare the VM to add guest additions after reboot
      pkg_cmd << "echo -e 'mount -o loop,ro /home/vagrant/VBoxGuestAdditions_#{VBOX_VERSION}.iso /mnt\n" \
        "echo yes | /mnt/VBoxLinuxAdditions.run\numount /mnt\n" \
          "rm /root/guest_additions.sh; ' > /root/guest_additions.sh; " \
        "chmod 700 /root/guest_additions.sh; " \
        "sed -i -E 's#^exit 0#[ -x /root/guest_additions.sh ] \\&\\& /root/guest_additions.sh#' /etc/rc.local; " \
        "echo 'Installation of VBox Guest Additions is proceeding in the background.'; " \
        "echo '\"vagrant reload\" can be used in about 2 minutes to activate the new guest additions.'; "
      config.vm.provision :shell, :inline => pkg_cmd
    end
    # Other installation actions
    config.vm.provision :shell, :path => "bootstrap.sh"
  end

  config.vm.provider :aws do |aws, override|
    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
    aws.region = ENV['AWS_REGION'] || 'ap-southeast-2'
    aws.instance_type = 'm1.small'
    aws.ami = "ami-9fc25ea5"
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = ENV['SSH_PRIVKEY']
  end

  config.vm.provider :rackspace do |rs|
    config.ssh.private_key_path = ENV["SSH_PRIVKEY"]
    rs.username = ENV["RS_USERNAME"]
    rs.api_key  = ENV["RS_API_KEY"]
    rs.public_key_path = ENV["RS_PUBLIC_KEY"]
    rs.flavor   = /512MB/
    rs.image    = /Ubuntu/
  end

  config.vm.provider :vmware_fusion do |f, override|
    override.vm.box = BOX_NAME
    override.vm.box_url = ENV['BOX_URI'] || "https://oss-binaries.phusionpassenger.com/vagrant/boxes/ubuntu-12.04.3-amd64-vmwarefusion.box"
    #override.vm.synced_folder ".", "/vagrant", disabled: true
    f.vmx["displayName"] = "docker"
  end

end