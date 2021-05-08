#!/usr/bin/env bash
#
# This configures OSX specific features
set -e

# shellcheck source=/dev/null
source utils

if test ! "$(uname)" = "Darwin"
  then
  exit 0
fi

while true; do
    response=''
    read_input "run macOS setup? [y|N] " response
    case $response in
        [Yyes]* )
          break;;
        [Nn]* )
          exit 0;
          break;
          ;;
        * ) echo "Please answer yes or no.";;
    esac
done


write() {
  if ! defaults write $@; then
    error "not installed. $*"
  else
    ok
  fi
}
# defaults read NSGlobalDomain AppleHighlightColor

###################################################################################
bot "Hi! I'm going to install tooling and tweak your system settings. Here I go..."
###################################################################################

###############################################################################
bot "Dock & Dashboard"
###############################################################################
run "Set the icon size of Dock items to 36 pixels"
write com.apple.dock tilesize -int 36

run "Change minimize/maximize window effect to scale" # default 'genie'
write com.apple.dock mineffect -string "scale"

run "Automatically hide and show the Dock"
write com.apple.dock autohide -bool true

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don’t group windows by application in Mission Control
# (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock expose-group-by-app -bool false


###############################################################################
bot "Terminal & iTerm2"
###############################################################################
run "hide tab title bars"
write com.googlecode.iterm2 HideTab -bool true

run "don’t display the annoying prompt when quitting iterm"
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

run "only use utf-8 in terminal.app"
defaults write com.apple.terminal StringEncodings -array 4

###############################################################################
bot "Activity Monitor"
###############################################################################
run "Show the main window when launching Activity Monitor"
write com.apple.ActivityMonitor OpenMainWindow -bool true

run "Show all processes in Activity Monitor"
write com.apple.ActivityMonitor ShowCategory -int 0

run "Visualize CPU usage in the Activity Monitor Dock icon"
write com.apple.ActivityMonitor IconType -int 5

run "Sort Activity Monitor results by CPU usage"
write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
bot "Mac App Store"
###############################################################################

run "Check for software updates daily, not just once per week"
write com.apple.SoftwareUpdate ScheduleFrequency -int 1

###############################################################################
bot "Mixed Setup"
###############################################################################
run "Disable smart quotes as they’re annoying when typing code"
write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

run "Disable smart dashes as they’re annoying when typing code"
write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

run "Enable spring loading for directories"
write NSGlobalDomain com.apple.springing.enabled -bool true

run "Disable automatic capitalization as it’s annoying when typing code"
write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

run "Set highlight color to green" # 0.968627 0.831373 1.000000 Purple
defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600";ok

###############################################################################
bot "Trackpad, mouse, keyboard, Bluetooth accessories, and input"
###############################################################################

run "set a blazingly fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 6 # normal minimum is 2 (30 ms)
defaults write NSGlobalDomain InitialKeyRepeat -int 25 # normal minimum is 15 (225 ms)

###############################################################################
bot "Finder Configs"
###############################################################################
run "Keep folders on top when sorting by name (version 10.12 and later)"
write com.apple.finder _FXSortFoldersFirst -bool true

run "Show hidden files by default"
write com.apple.finder AppleShowAllFiles -bool true

run "finder: show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

run "Show status bar"
write com.apple.finder ShowStatusBar -bool true

run "Display full POSIX path as Finder window title"
write com.apple.finder _FXShowPosixPathInTitle -bool true

run "Use list view in all Finder windows by default"
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
write com.apple.finder FXPreferredViewStyle -string "Nlsv"

run "Finder: show path bar"
write com.apple.finder ShowPathbar -bool true

# defaults read com.apple.finder FXDefaultSearchScope
run "When performing a search, search the current folder by default"
write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

###############################################################################
# Setup default keychain                                                      #
###############################################################################
run "Setup default keychain"
# security login-keychain
# security default-keychain -s login.keychain-db;ok
# security default-keychain

###############################################################################
# Kill affected applications                                                  #
###############################################################################
for app in "Activity Monitor" "Dock" "Finder" "Keychain Access"; do
  set +e
  killall "${app}" > /dev/null 2>&1
  set -e
done

information "Done. Note that some of these changes require a logout/restart to take effect."
