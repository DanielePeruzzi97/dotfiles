Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "bento/ubuntu-24.04"
    ubuntu.vm.hostname = "dotfiles-ubuntu"
    ubuntu.vm.network "private_network", type: "dhcp"
    
    ubuntu.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
      vb.name = "dotfiles-ubuntu"
      vb.gui = true
      vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
      vb.customize ["modifyvm", :id, "--vram", "128"]
    end

    ubuntu.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y git curl
    SHELL
  end

  config.vm.define "arch" do |arch|
    arch.vm.box = "generic/arch"
    arch.vm.hostname = "dotfiles-arch"
    arch.vm.network "private_network", type: "dhcp"
    
    arch.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
      vb.name = "dotfiles-arch"
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
