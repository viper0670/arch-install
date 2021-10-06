diskpartmenu(){
	if [ "${1}" = "" ]; then
		nextitem="."
	else
		nextitem=${1}
	fi
	options=()
	if [ "${eficomputer}" == "0" ]; then
		options+=("${txtautoparts} (gpt)" "")
		options+=("${txtautoparts} (dos)" "")
	else
		options+=("${txtautoparts} (gpt,efi)" "")
		options+=("${txtautoparts} (gpt)" "")
		options+=("${txtautoparts} (dos)" "")
		options+=("${txtautoparts} (gpt,bios+efi,noswap)" "")
	fi
	options+=("${txteditparts} (cfdisk)" "")
	options+=("${txteditparts} (cgdisk)" "")
	sel=$(whiptail --backtitle "${apptitle}" --title "${txtdiskpartmenu}" --menu "" --cancel-button "${txtback}" --default-item "${nextitem}" 0 0 0 \
		"${options[@]}" \
		3>&1 1>&2 2>&3)
	if [ "$?" = "0" ]; then
		case ${sel} in
			"${txtautoparts} (dos)")
				diskpartautodos
				nextitem="${txtautoparts} (dos)"
			;;
			"${txtautoparts} (gpt)")
				diskpartautogpt
				nextitem="${txtautoparts} (gpt)"
			;;
			"${txtautoparts} (gpt,efi)")
				diskpartautoefi
				nextitem="${txtautoparts} (gpt,efi)"
			;;
			"${txtautoparts} (gpt,bios+efi,noswap)")
				diskpartautoefiusb
				nextitem="${txtautoparts} (gpt,bios+efi,noswap)"
			;;
			"${txteditparts} (cfdisk)")
				diskpartcfdisk
				nextitem="${txteditparts} (cfdisk)"
			;;
			"${txteditparts} (cgdisk)")
				diskpartcgdisk
				nextitem="${txteditparts} (cgdisk)"
			;;
		esac
		diskpartmenu "${nextitem}"
	fi
}

diskpartautodos(){
		device=$(selectdisk "${txtautoparts} (dos)")
	if [ "$?" = "0" ]; then
		if (whiptail --backtitle "${apptitle}" --title "${txtautoparts} (dos)" --yesno "${txtautopartsconfirm//%1/${device}}" --defaultno 0 0) then
			clear
			echo "${txtautopartclear}"
			parted ${device} mklabel msdos
			sleep 1
			echo "${txtautopartcreate//%1/boot}"
			echo -e "n\np\n\n\n+512M\na\nw" | fdisk ${device}
			sleep 1
			echo "${txtautopartcreate//%1/swap}"
			swapsize=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
			swapsize=$((${swapsize}/1000))"M"
			echo -e "n\np\n\n\n+${swapsize}\nt\n\n82\nw" | fdisk ${device}
			sleep 1
			echo "${txtautopartcreate//%1/root}"
			echo -e "n\np\n\n\n\nw" | fdisk ${device}
			sleep 1
			echo ""
			pressanykey
			if [ "${device::8}" == "/dev/nvm" ]; then
				bootdev=${device}"p1"
				swapdev=${device}"p2"
				rootdev=${device}"p3"
			else
				bootdev=${device}"1"
				swapdev=${device}"2"
				rootdev=${device}"3"
			fi
			efimode="0"
		fi
	fi
}

diskpartautogpt(){
		device=$(selectdisk "${txtautoparts} (gpt)")
	if [ "$?" = "0" ]; then
		if (whiptail --backtitle "${apptitle}" --title "${txtautoparts} (gpt)" --yesno "${txtautopartsconfirm//%1/${device}}" --defaultno 0 0) then
			clear
			echo "${txtautopartclear}"
			parted ${device} mklabel gpt
			echo "${txtautopartcreate//%1/BIOS boot}"
			sgdisk ${device} -n=1:0:+31M -t=1:ef02
			echo "${txtautopartcreate//%1/boot}"
			sgdisk ${device} -n=2:0:+512M
			echo "${txtautopartcreate//%1/swap}"
			swapsize=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
			swapsize=$((${swapsize}/1000))"M"
			sgdisk ${device} -n=3:0:+${swapsize} -t=3:8200
			echo "${txtautopartcreate//%1/root}"
			sgdisk ${device} -n=4:0:0
			echo ""
			pressanykey
			if [ "${device::8}" == "/dev/nvm" ]; then
				bootdev=${device}"p2"
				swapdev=${device}"p3"
				rootdev=${device}"p4"
			else
				bootdev=${device}"2"
				swapdev=${device}"3"
				rootdev=${device}"4"
			fi
			efimode="0"
		fi
	fi
}

diskpartautoefi(){
		device=$(selectdisk "${txtautoparts} (gpt,efi)")
	if [ "$?" = "0" ]; then
		if (whiptail --backtitle "${apptitle}" --title "${txtautoparts} (gpt,efi)" --yesno "${txtautopartsconfirm//%1/${device}}" --defaultno 0 0) then
			clear
			echo "${txtautopartclear}"
			parted ${device} mklabel gpt
			echo "${txtautopartcreate//%1/EFI boot}"
			sgdisk ${device} -n=1:0:+1024M -t=1:ef00
			echo "${txtautopartcreate//%1/swap}"
			swapsize=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
			swapsize=$((${swapsize}/1000))"M"
			sgdisk ${device} -n=2:0:+${swapsize} -t=2:8200
			echo "${txtautopartcreate//%1/root}"
			sgdisk ${device} -n=3:0:0
			echo ""
			pressanykey
			if [ "${device::8}" == "/dev/nvm" ]; then
				bootdev=${device}"p1"
				swapdev=${device}"p2"
				rootdev=${device}"p3"
			else
				bootdev=${device}"1"
				swapdev=${device}"2"
				rootdev=${device}"3"
			fi
			efimode="1"
		fi
	fi
}

diskpartautoefiusb(){
		device=$(selectdisk "${txtautoparts} (gpt,efi)")  
	if [ "$?" = "0" ]; then
		if (whiptail --backtitle "${apptitle}" --title "${txtautoparts} (gpt,efi)" --yesno "${txtautopartsconfirm//%1/${device}}" --defaultno 0 0) then
			clear
			echo "${txtautopartclear}"
			parted ${device} mklabel gpt
			echo "${txtautopartcreate//%1/EFI boot}"
			sgdisk ${device} -n=1:0:+1024M -t=1:ef00
			echo "${txtautopartcreate//%1/BIOS boot}"
			sgdisk ${device} -n=2:0:+31M -t=2:ef02
			echo "${txtautopartcreate//%1/root}"
			sgdisk ${device} -n=3:0:0
			echo "${txthybridpartcreate}"
			echo -e "r\nh\n3\nN\n\nY\nN\nw\nY\n" | gdisk ${device}
			echo ""
			pressanykey
			if [ "${device::8}" == "/dev/nvm" ]; then
				bootdev=${device}"p1"
				swapdev=
				rootdev=${device}"p3"
			else
				bootdev=${device}"1"
				swapdev=
				rootdev=${device}"3"
			fi
			efimode="2"
		fi
	fi
}
