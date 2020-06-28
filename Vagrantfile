# -*- mode: ruby -*-
# vi: set ft=ruby :

CPUCOUNT = "2"
RAM = "4096"

$non_priviledged = <<SCRIPT
#!/bin/sh
set -e

PROFILE=~/.profile
BASH_PROFILE=~/.bash_profile
RAW_GITHUB=https://raw.githubusercontent.com

yes | /bin/bash -c "$(curl -fsSL ${RAW_GITHUB}/Homebrew/install/master/install.sh)"
test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
line="eval \$($(brew --prefix)/bin/brew shellenv)"
test -r ~/.bash_profile &&  grep -qF -- "$line" "${BASH_PROFILE}" || echo "$line" >> "${BASH_PROFILE}"
test -r ~/.bash_profile &&  grep -qF -- ". ~/.profile" "${BASH_PROFILE}" || echo ". ~/.profile" >> "${BASH_PROFILE}"

brew doctor
brew install git
brew install chezmoi
brew list

git --version
SCRIPT

$priviledged = <<SCRIPT
#!/bin/sh
set -e
pip3 install --upgrade pip dotbot --user
dotbot --version
SCRIPT

$project_setup = <<SCRIPT
#!/bin/sh
set -e
git clone https://github.com/ivankatliarchuk/dotfiles.git
echo "cd dotfiles; git pull" > gitpull.sh
chmod +x gitpull.sh
SCRIPT

Vagrant.configure("2") do |config|
  # config.vm.box = "crystax/macos15"
  config.vm.box = "ramsey/macos-catalina"
  config.vm.box_version = "1.0.0"

  if Vagrant.has_plugin?('vagrant-vbguest') then
      config.vbguest.auto_update = false
  end

  config.vm.network "private_network", ip: "10.0.0.100"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provision "prereq", type: "shell", inline: $non_priviledged,
    privileged: false, name: "prereq"

  config.vm.provision "prereq_v2", type: "shell", inline: $priviledged,
    privileged: false, name: "prereq_v2"

  config.vm.provision "project_setup", type: "shell", inline: $project_setup,
    privileged: false, name: "project_setup"

  config.vm.provider :virtualbox do |v, override|
    v.name   = "macos.dotenv"
    # Display the VirtualBox GUI when booting the machine. You might want to turn 3D accelerating to speed-up VM GUI.
    v.gui    = false
    v.memory = "#{RAM}"
    v.cpus   = "#{CPUCOUNT}"

    v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    v.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
    v.customize ["modifyvm", :id, "--accelerate3d", "on"]
    v.customize ["modifyvm", :id, "--accelerate2dvideo", "on"]

    # Some needed OSX configs
    v.customize ["modifyvm", :id, "--cpuid-set", "00000001", "000106e5", "00100800", "0098e3fd", "bfebfbff"]
    v.customize ["setextradata", :id, "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct", "MacBookPro11,3"]
    v.customize ["setextradata", :id, "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion", "1.0"]
    v.customize ["setextradata", :id, "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct", "Iloveapple"]
    v.customize ["setextradata", :id, "VBoxInternal/Devices/smc/0/Config/DeviceKey", "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"]
    v.customize ["setextradata", :id, "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC", "1"]

    # set resolution on OSX:
    # Values: 0 = 640x480, 1 = 800x600, 2 = 1024x768, 3 = 1280x1024, 4 = 1440x900, 5 = 1920x1200
    v.customize ["setextradata", :id, "VBoxInternal2/EfiGopMode", "5"]
    v.customize ["setextradata", :id, "CustomVideoMode1", "1920x1080x32"]
    v.customize ["setextradata", :id, "GUI/CustomVideoMode1", "1920x1080x32"]
  end

  config.vm.post_up_message="Setup complete `vagrant ssh` to ssh into the box"

end
