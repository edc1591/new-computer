#!/bin/sh

#                    _           _        _ _ 
#  ___  _____  __   (_)_ __  ___| |_ __ _| | |
# / _ \/ __\ \/ /   | | '_ \/ __| __/ _` | | |
#| (_) \__ \>  <    | | | | \__ \ || (_| | | |
# \___/|___/_/\_\   |_|_| |_|___/\__\__,_|_|_|


echo "I  ❤️  🍎"
echo "Mac OS Install Setup Script"
echo "By Nina Zakharenko"
echo "Follow me on twitter! https://twitter.com/nnja"

# Some configs reused from:
# https://github.com/ruyadorno/installme-osx/
# https://gist.github.com/millermedeiros/6615994
# https://gist.github.com/brandonb927/3195465/

# Colorize

# Set the colours you can use
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)

# Resets the style
reset=`tput sgr0`

# Color-echo. Improved. [Thanks @joaocunha]
# arg $1 = message
# arg $2 = Color
cecho() {
  echo "${2}${1}${reset}"
  return
}

# Set continue to false by default.
CONTINUE=false

echo ""
cecho "Have you read through the script you're about to run and " $red
cecho "understood that it will make changes to your computer? (y/n)" $red
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  CONTINUE=true
fi

if ! $CONTINUE; then
  # Check if we're continuing and output a message if not
  cecho "Please go read the script, it only takes a few minutes" $red
  exit
fi

# Here we go.. ask for the administrator password upfront and run a
# keep-alive to update existing `sudo` time stamp until script has finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


##############################
# Prerequisite: Install Brew #
##############################

echo "Installing brew..."

if test ! $(which brew)
then
	## Don't prompt for confirmation when installing homebrew
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
fi

# Latest brew, install brew cask
brew upgrade
brew update
brew tap caskroom/cask
brew tap homebrew/cask-drivers


##############################
# Prerequisite: Install rbenv #
##############################

echo "Installing rbenv..."

if test ! $(which rbenv)
then
  brew install rbenv
fi

##############################
# Prerequisite: Install nvm #
##############################

echo "Installing nvm..."

if test ! $(which nvm)
then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh | bash
fi


##############################
# Prerequisite: Install mackup #
##############################

echo "Installing mackup..."

if test ! $(which mackup)
then
  brew install mackup
fi

mackup restore


#############################################
### Add ssh keys to ssh-agent
### See: https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
#############################################

# Now that sshconfig is synced add key to ssh-agent and
# store passphrase in keychain
ssh-add -K ~/.ssh/*[^.pub]

# If you're using macOS Sierra 10.12.2 or later, you will need to modify your ~/.ssh/config file to automatically load keys into the ssh-agent and store passphrases in your keychain.

if [ -e ~/.ssh/config ]
then
  rm ~/.ssh/config
fi

for filename in ~/.ssh/*[^.pub]; do
	echo "Writing osx specific settings to ssh config for $filename... "
   cat <<EOT >> ~/.ssh/config
	Host *
		AddKeysToAgent yes
		UseKeychain yes
		IdentityFile $filename
EOT
done

##############################
# Install via gem            #
##############################

gem install bundler
gem install cocoapods
gem install fastlane

##############################
# Install via Brew           #
##############################

cecho "Install homebrew packages? (y/N)" $red
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo "Starting brew app install..."

  brew cask install --appdir="/Applications" ${apps[@]}

  ### Developer Tools
  brew cask install iterm2
  brew cask install paw
  brew cask install tower
  brew cask install charles
  brew cask install sublime-text
  brew cask install sketch
  brew cask install transmit


  ### Development
  brew install postgresql
  brew install redis
  brew install carthage


  ### Command line tools - install new ones, update others to latest version
  brew install git  # upgrade to latest
  brew install git-lfs # track large files in git https://github.com/git-lfs/git-lfs
  brew install wget
  brew install trash  # move to osx trash instead of rm
  brew install less


  ### Writing
  brew cask install macdown


  ### Productivity
  brew cask install google-chrome
  brew cask install alfred
  brew cask install nextcloud
  brew cask install flux
  brew cask install bettertouchtool
  brew cask install 1password
  brew cask install bartender
  brew cask install rescuetime
  brew cask install viscosity
  brew cask install istat-menus
  brew cask install fantastical
  brew cask install authy


  ### Quicklook plugins https://github.com/sindresorhus/quick-look-plugins
  brew cask install qlcolorcode # syntax highlighting in preview
  brew cask install qlstephen  # preview plaintext files without extension
  brew cask install qlmarkdown  # preview markdown files
  brew cask install quicklook-json  # preview json files
  brew cask install quicklook-csv  # preview csvs


  ### Chat / Video Conference
  brew cask install slack
  brew cask install zoomus
  brew cask install signal


  ### Music and Video
  brew cask install vlc


  ### Run Brew Cleanup
  brew cleanup
fi

#############################################
### Installs from Mac App Store
#############################################

cecho "Install Mac App Store apps? (y/N)" $red
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo "Installing apps from the App Store..."

  ### find app ids with: mas search "app name"
  brew install mas

  ### Mas login is currently broken on mojave. See:
  ### Login manually for now.

  cecho "Need to log in to App Store manually to install apps with mas...." $red
  echo "Opening App Store. Please login."
  open "/Applications/App Store.app"
  echo "Is app store login complete.(y/n)? "
  read response
  if [ "$response" != "${response#[Yy]}" ]
  then
  	mas install 425424353   # The Unarchiver
  	mas install 937984704   # Amphetamine
  	mas install 407963104   # Pixelmator
  	mas install 429449079   # Patterns
  	mas install 1384080005  # Tweetbot
    mas install 880001334   # Reeder
    mas install 1176895641  # Spark
    mas install 1063996724  # Tyme 2
  else
  	cecho "App Store login not complete. Skipping installing App Store Apps" $red
  fi
fi

###############################################################################
# System Settings                                                             #
###############################################################################

#"Disabling OS X Gate Keeper"
#"(You'll be able to install any app you want from here on, not just Mac App Store apps)"
sudo spctl --master-disable
sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
defaults write com.apple.LaunchServices LSQuarantine -bool false

#"Allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool TRUE

#"Expanding the save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

#"Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

#"Setting trackpad & mouse speed to a reasonable number"
defaults write -g com.apple.trackpad.scaling 1.5

#"Showing icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

#"Showing all filename extensions in Finder by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

#"Disabling the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

#"Enabling snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

#"Setting the icon size of Dock items to 52 pixels"
defaults write com.apple.dock tilesize -int 52

#"Setting Dock settings"
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock largesize -int 97
defaults write com.apple.dock magnification -int 1
defaults write com.apple.dock tilesize -int 51

#"Setting screenshots location to ~/Desktop"
defaults write com.apple.screencapture location -string "$HOME/Desktop"

#"Setting screenshot format to PNG"
defaults write com.apple.screencapture type -string "png"

#"Hiding Safari's bookmarks bar by default"
defaults write com.apple.Safari ShowFavoritesBar -bool true

#"Enabling the Develop menu and the Web Inspector in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Use list view in all Finder windows by default (codes for the other view modes: `icnv`, `clmv`, `Flwv`)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# defaults write com.apple.dock persistent-apps -array "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/App Store.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Safari.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/iTunes.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Xcode.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Sublime Text.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/iTerm.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Paw.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Tower.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Transmit.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Sketch.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Tweetbot.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Spark.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Messages.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Slack.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Reeder.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/System Preferences.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

killall Dock


echo ""
cecho "Done!" $cyan
echo ""
echo ""
cecho "################################################################################" $white
echo ""
echo ""
cecho "Note that some of these changes require a logout/restart to take effect." $red
echo ""
echo ""
echo -n "Check for and install available OSX updates, install, and automatically restart? (y/n)? "
read response
if [ "$response" != "${response#[Yy]}" ] ;then
    softwareupdate -i -a --restart
fi