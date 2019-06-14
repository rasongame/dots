#!/usr/bin/sh

# DISPLAY FETCH

bold=$(tput bold)
norm=$(tput sgr0)
base=$(tput setaf 6)
KERN=$(uname -rv | awk '{print $1;}')
UPTIME=$(uptime | awk '{print $3;}')
VER="$HOME/.bin/ver.sh"
S="\u2714"
echo -e "${bold}${base} _____  ${base} DISTRO ${base}${S} Arch Linux"
echo -e "${bold} |._.|  ${base} KERNEL ${base}${S} $(${VER} linux)"
echo -e "${bold}/|   |\ ${base} UPTIME ${base}${S}   ${UPTIME}"
echo -e "${bold} |___|  ${base} NVIM   ${base}${S} $(${VER} neovim)"
echo -e "${bold} |   |  ${base} ZSH    ${base}${S} $(${VER} zsh )"
echo -e "${bold}        ${base} WM     ${base}${S} Awesome WM"

















