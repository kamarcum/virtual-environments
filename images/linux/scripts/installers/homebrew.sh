#!/bin/bash
################################################################################
##  File:  homebrew.sh
##  Desc:  Installs the Homebrew on Linux
################################################################################

# Source the helpers
source $HELPER_SCRIPTS/document.sh
source $HELPER_SCRIPTS/etc-environment.sh

# Install the Homebrew on Linux
if [ "${UID}" == "0" ]; then
  echo "You seem to be running this as root. Setting up the linuxbrew user..."
  useradd -m -s /bin/bash linuxbrew \
      && echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

  git clone https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew/Homebrew
  mkdir /home/linuxbrew/.linuxbrew/bin
  ln -s /home/linuxbrew/.linuxbrew/Homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin
  ln -s /home/linuxbrew/.linuxbrew/Homebrew/bin/brew /usr/local/bin
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

# Make brew files and directories writable by any user
sudo chmod -R o+w $HOMEBREW_PREFIX

# Update /etc/environemnt
## Put HOMEBREW_* variables
brew shellenv|grep 'export HOMEBREW'|sed -E 's/^export (.*);$/\1/' | sudo tee -a /etc/environment
# add brew executables locations to PATH
brew_path=$(brew shellenv|grep  '^export PATH' |sed -E 's/^export PATH="([^$]+)\$.*/\1/')
appendEtcEnvironmentPath "$brew_path"

# Validate the installation ad hoc
echo "Validate the installation reloading /etc/environment"
reloadEtcEnvironment

if ! command -v brew; then
    echo "brew was not installed"
    exit 1
fi

# Document the installed version
echo "Document the installed version"
DocumentInstalledItem "Homebrew on Linux ($(brew -v 2>&1))"
