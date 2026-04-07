Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "bento/ubuntu-25.04"
    ubuntu.vm.hostname = "dotfiles-ubuntu"
    ubuntu.vm.network "private_network", type: "dhcp"
    
    ubuntu.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
      vb.gui = true
      vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
      vb.customize ["modifyvm", :id, "--vram", "128"]
      vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
      vb.customize ["modifyvm", :id, "--usb", "on"]
      vb.customize ["modifyvm", :id, "--usbxhci", "on"]
      vb.customize ["usbfilter", "add", "0", "--target", :id, "--name", "YubiKey", "--vendorid", "0x1050"]
    end

    ubuntu.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y git curl ubuntu-desktop
      systemctl set-default graphical.target
    SHELL
  end

  config.vm.define "arch" do |arch|
    arch.vm.box = "generic/arch"
    arch.vm.hostname = "dotfiles-arch"
    arch.vm.network "private_network", type: "dhcp"
    
    arch.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
      vb.gui = true
      vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
      vb.customize ["modifyvm", :id, "--vram", "128"]
      vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
    end

    arch.vm.provision "shell", inline: <<-SHELL
      pacman-key --init
      pacman-key --populate archlinux
      pacman -Sy --noconfirm archlinux-keyring
      pacman -Syu --noconfirm
      pacman -S --noconfirm git curl base-devel
    SHELL
  end
end
