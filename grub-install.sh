archgrubinstallchroot(){
	echo "mkdir /boot/grub"
	echo "grub-mkconfig -o /boot/grub/grub.cfg"
	mkdir /boot/grub
	grub-mkconfig -o /boot/grub/grub.cfg
	exit
}
archgrubinstallbootloader(){
		device=$( selectdisk "${txtinstall//%1/bootloader}" )  
	if [ "$?" = "0" ]; then
		if [ "${eficomputer}" == "1" ]; then
			options=()
			if [ "${efimode}" = "1" ]; then
				options+=("EFI" "")
				options+=("BIOS" "")
				options+=("BIOS+EFI" "")
			elif [ "${efimode}" = "2" ]; then
				options+=("BIOS+EFI" "")
				options+=("BIOS" "")
				options+=("EFI" "")
			else
				options+=("BIOS" "")
				options+=("EFI" "")
				options+=("BIOS+EFI" "")
			fi
			sel=$(whiptail --backtitle "${apptitle}" --title "${txtinstall//%1/bootloader}" --menu "" --cancel-button "${txtback}" 0 0 0 \
				"${options[@]}" \
				3>&1 1>&2 2>&3)
			if [ "$?" = "0" ]; then
				clear
				case ${sel} in
					"BIOS") archchroot grubbootloaderinstall ${device};;
					"EFI") archchroot grubbootloaderefiinstall ${device};;
					"BIOS+EFI") archchroot grubbootloaderefiusbinstall ${device};;
				esac
				pressanykey
			fi
		else
			clear
			archchroot grubbootloaderinstall ${device}
			pressanykey
		fi
	fi
}
archgrubinstallbootloaderchroot(){
	if [ ! "${1}" = "none" ]; then
		echo "grub-install --target=i386-pc --recheck ${1}"
		grub-install --target=i386-pc --recheck ${1}
	fi
	exit
}
archgrubinstallbootloaderefichroot(){
	if [ ! "${1}" = "none" ]; then
		echo "grub-install --target=x86_64-efi --efi-directory=/boot --recheck ${1}"
		grub-install --target=x86_64-efi --efi-directory=/boot --recheck ${1}
		isvbox=$(lspci | grep "VirtualBox G")
		if [ "${isvbox}" ]; then
			echo "VirtualBox detected, creating startup.nsh..."
			echo "\EFI\arch\grubx64.efi" > /boot/startup.nsh
		fi
	fi
	exit
}
archgrubinstallbootloaderefiusbchroot(){
	if [ ! "${1}" = "none" ]; then
		echo "grub-install --target=i386-pc --recheck ${1}"
		grub-install --target=i386-pc --recheck ${1}
		echo "grub-install --target=x86_64-efi --efi-directory=/boot --removable --recheck ${1}"
		grub-install --target=x86_64-efi --efi-directory=/boot --removable --recheck ${1}
		isvbox=$(lspci | grep "VirtualBox G")
		if [ "${isvbox}" ]; then
			echo "VirtualBox detected, creating startup.nsh..."
			echo "\EFI\arch\grubx64.efi" > /boot/startup.nsh
		fi
	fi
	exit
}
