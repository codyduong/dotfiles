#!/bin/bash

pacman -Syu --noconfirm
pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain --noconfirm
# Define packages
# packages=("base-devel" "mingw-w64-ucrt-x86_64-toolchain")

# echo "Updating package database and upgrading system..."
# pacman -Syu --noconfirm

# # Check if packages are installed
# for pkg in "${packages[@]}"; do
#   if ! pacman -Qi $pkg &>/dev/null; then
#     echo "$pkg is not installed. Installing..."
#     # Attempt to install the package and check for errors during the installation
#     if ! pacman -S --needed $pkg --noconfirm; then
#       echo "Failed to install $pkg. Exiting the script."
#       exit 1
#     fi
#   else
#     echo "$pkg is already installed."
#   fi
# done