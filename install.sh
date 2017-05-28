#/bin/sh

set -e

function os {
  set +e
  case `uname` in
    Linux )
      which yumls && {
        OS_ID=centos
        OS_INSTALL_COMMAND="yum -y install"
        return
      }
      which zypper && {
        OS_ID=opensuse
        OS_INSTALL_COMMAND="zypper --non-interactive install"
        return
      }
      which apt-get && {
        OS_ID=debian
        OS_INSTALL_COMMAND="apt-get -y install"

        cat /etc/lsb-release && { OS_ID=ubuntu; }

        return
      }
      ;;
    Darwin )
      OS_ID=osx
      OS_INSTALL_COMMAND="brew install"
      ;;
    * )
      # Handle AmgiaOS, CPM, and modified cable modems here.
      OS_ID=unknown
      ;;
  esac
  set -e
}

function prepare_system_for_install {
  #export LC_ALL="en_US.UTF-8"
  export LC_ALL="C.UTF-8"

  case $OS_ID in
    osx )
      # Ask for the administrator password upfront
      sudo -v

      # Keep-alive: update existing `sudo` time stamp until `.osx` has finished
      while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

      # Some preferences
      defaults write NSGlobalDomain KeyRepeat -int 0
      defaults write NSGlobalDomain InitialKeyRepeat -int 5
      defaults write -g ApplePressAndHoldEnabled -bool false

      # Install xcode build tools
      xcode-select --install

      # Install brew
      ruby \
        -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" \
        </dev/null

      # Update brew
      brew update
      brew upgrade
      # brew bundle
      brew cleanup
      ;;
    debian )
      apt-get -y update
      apt-get -y upgrade
      ;;
    ubuntu )
      apt-get -y update
      apt-get -y upgrade
      ;;
    * )
      ;;
  esac
}

function install_base_tools {
  $OS_INSTALL_COMMAND locales wget curl sed git zsh unzip direnv
}

function font_locale_install {
  case $OS_ID in
    debian )
      echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
      /usr/sbin/locale-gen
      ;;
    * )
      locale-gen en_US
      locale-gen en_US.UTF-8
      ;;
  esac

  echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
  echo "export LANG=en_US.UTF-8" >> ~/.bashrc
  echo "export LANGUAGE=en_US.UTF-8" >> ~/.bashrc

  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8
  export LANGUAGE=en_US.UTF-8

  # clone
  git clone https://github.com/powerline/fonts.git
  # install
  cd fonts
  ./install.sh
  # clean-up a bit
  cd ..
  rm -rf fonts

}

function install_oh_my_zsh {
  font_locale_install

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  # Auto suggestions
  git clone git://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

  # Syntax coloring
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

  # Set themes
  sed -ri 's/^ZSH_THEME=".+"/ZSH_THEME="agnoster"/' ~/.zshrc

  # Add plugins
  sed -ri 's/^plugins=\((.*)\)/plugins=(\1 themes zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

  # Add exports
  mkdir -p ~/bin/
  echo 'export PATH="$PATH:~/bin"' >> ~/.zshrc
  echo 'export EDITOR="vim"' >> ~/.zshrc
  echo 'export TERM="xterm-256color"' >> ~/.zshrc

  # Add aliases
  echo 'zshconfig="vim ~/.zshrc"' >> ~/.zshrc

  # Only on osx
  case $OS_ID in
    osx )
      echo 'apt-get="brew"' >> ~/.zshrc
      echo 'service="brew services"' >> ~/.zshrc
      ;;
    * )
      ;;
  esac

  # Enable direnv
  echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc

  # Add to bashrc
  echo "exec zsh" >> ~/.bashrc
}

function install_vim {
  $OS_INSTALL_COMMAND vim

  # Create vim color directory
  mkdir -p ~/.vim/bundle/
  mkdir -p ~/.vim/colors/

  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

  # Add theme
  wget https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim -O ~/.vim/colors/molokai.vim

  # Setup settings
  cp ./resources/.vimrc ~/.vimrc

  # Install plugins
  vim +PluginInstall +qall
}

os &> /dev/null
prepare_system_for_install
install_base_tools

echo $OS_ID
echo "$OS_INSTALL_COMMAND"

mkdir -p ~/tmp-install
cd ~/tmp-install
wget https://github.com/IanLuites/scripts/archive/master.zip
unzip master.zip
cp -R ./scripts-master/* .
rm -R ./scripts-master

install_vim
install_oh_my_zsh

cd ~
rm -Rf ~/tmp-install

source ~/.bashrc
