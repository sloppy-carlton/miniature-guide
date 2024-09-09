#!/bin/bash

echo "Now configuring your Arch system."
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock
pacman -Syu intel-ucode sof-firmware networkmanager wpa_supplicant nano man-db man-pages texinfo bluez bluez-utils reflector sudo alsa-utils pulseaudio pulseaudio-bluetooth pulseaudio-alsa pulseaudio-equalizer git
systemctl enable --now alsa-restore alsa-state bluetooth
amixer sset Master unmute
amixer sset Speaker unmute
amixer sset Headphone unmute
if [[ "$(lspci | grep -o 'Broadcom')" == 'Broadcom' ]];
	then
	pacman -Syu broadcom-wl-dkms linux-headers
	echo "Broadcom Wireless drivers installed."
else
	echo "No Broadcom drivers needed"
fi
echo "Which Desktop Environment would you like to install?"
select opt in Xfce MATE Cinnamon Budgie KDE none; do
	case $opt in
		Xfce)
			pacman -Syu xfce4 xfce4-goodies network-manager-applet xfce4-pulseaudio-plugin lightdm lightdm-slick-greeter
			systemctl enable lightdm
			;;
		MATE)
			pacman -Syu mate mate-extra network-manager-applet mate-applet-dock blueman paprefs lightdm lightdm-slick-greeter
			systemctl enable lightdm
			;;
		Cinnamon)
			pacman -Syu cinnamon network-manager-applet gnome-keyring blueberry paprefs lightdm lightdm-slick-greeter
			systemctl enable lightdm
			;;
		Budgie)
			pacman -Syu budgie budgie-extras network-manager-applet budgie-desktop-view budgie-backgrounds materia-gtk-theme arc-gtk-theme papirus-icon-theme plasma-pa paprefs lightdm lightdm-slick-greeter
			systemctl enable lightdm
			;;
		KDE)
			pacman -Syu plasma kde-applications sddm sddm-kcm
			systemctl enable sdddm
			;;
		none)
			echo "Skipping desktop environment installation."
			;;
		*)
			echo "Invalid option $REPLY"
			;;
	esac
done
pacman -Syu rust
useradd -m -G wheel -s bash pmckenna
passwd pmckenna
echo "visudo will open soon. Please add the following line if it does not already exist (no quotes): '%wheel      ALL=(ALL:ALL) ALL' "
EDITOR=nano visudo
systemctl enable NetworkManager
su pmckenna -c cat <<-EOF
	$(git clone https://aur.archlinux.org/paru.git)
	$(cd paru)
	$(makepkg -i)
	$(cd ~)
	$(cat <<-ENDRC > ~/.bashrc
		#
		# ~/.bashrc
		#
		
		# If not running interactively, don't do anything
		[[ $- != *i* ]] && return
		
		alias ls='ls --color=auto'
		alias grep='grep --color=auto'
		alias yay='paru -Syupw && paru -c && paru -S --needed'
		alias yeet='paru -R'
		PS1='[\[\e[38;5;51;1;2m\]\u\[\e[0;1m\]@\[\e[38;5;51;2m\]\h\[\e[0m\]\w]\$ '
	ENDRC)
	$(if [[ "$(pacman -Q | grep -o 'lightdm')" == 'lightdm' ]];
	then
	paru -S arch-update lightdm-settings 
	else
	paru -S arch-update
	fi)
	$(rm -R ./paru)
EOF
pacman -Rs rust
