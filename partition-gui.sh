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

diskpartcfdisk(){
		device=$( selectdisk "${txteditparts} (cfdisk)" )
	if [ "$?" = "0" ]; then
		clear
		cfdisk ${device}
	fi
}
diskpartcgdisk(){
		device=$( selectdisk "${txteditparts} (cgdisk)" )
	if [ "$?" = "0" ]; then
		clear
		cgdisk ${device}
	fi
}

mountmenu(){
	if [ "${1}" = "" ]; then
		nextitem="."
	else
		nextitem=${1}
	fi
	options=()
	options+=("${txtformatdevices}" "")
	options+=("${txtmount}" "${txtmountdesc}")
	sel=$(whiptail --backtitle "${apptitle}" --title "${txtformatmountmenu}" --menu "" --cancel-button "${txtback}" --default-item "${nextitem}" 0 0 0 \
		"${options[@]}" \
		3>&1 1>&2 2>&3)
	if [ "$?" = "0" ]; then
		case ${sel} in
			"${txtformatdevices}")
				formatdevices
				nextitem="${txtmount}"
			;;
			"${txtmount}")
				mountparts
				nextitem="${txtmount}"
			;;
		esac
		mountmenu "${nextitem}"
	fi
}
formatdevices(){
	if (whiptail --backtitle "${apptitle}" --title "${txtformatdevices}" --yesno "${txtformatdeviceconfirm}" --defaultno 0 0) then
		fspkgs=""
		if [ ! "${bootdev}" = "" ]; then
			formatbootdevice boot ${bootdev}
		fi
		if [ ! "${swapdev}" = "" ]; then
			formatswapdevice swap ${swapdev}
		fi
		formatdevice root ${rootdev}
		if [ ! "${homedev}" = "" ]; then
			formatdevice home ${homedev}
		fi
	fi
}
formatbootdevice(){
	options=()
	if [ "${efimode}" == "1" ]||[ "${efimode}" = "2" ]; then
		options+=("fat32" "(EFI)")
	fi
	options+=("ext2" "")
	options+=("ext3" "")
	options+=("ext4" "")
	if [ ! "${efimode}" = "1" ]&&[ ! "${efimode}" = "2" ]; then
		options+=("fat32" "(EFI)")
	fi
	sel=$(whiptail --backtitle "${apptitle}" --title "${txtformatdevice}" --menu "${txtselectpartformat//%1/${1} (${2})}" 0 0 0 \
		"${options[@]}" \
		3>&1 1>&2 2>&3)
	if [ ! "$?" = "0" ]; then
		return 1
	fi
	clear
	echo "${txtformatingpart//%1/${2}} ${sel}"
	echo "----------------------------------------------"
	case ${sel} in
		ext2)
			echo "mkfs.ext2 ${2}"
			mkfs.ext2 ${2}
		;;
		ext3)
			echo "mkfs.ext3 ${2}"
			mkfs.ext3 ${2}
		;;
		ext4)
			echo "mkfs.ext4 ${2}"
			mkfs.ext4 ${2}
		;;
		fat32)
			fspkgs="${fspkgs[@]} dosfstools"
			echo "mkfs.fat ${2}"
			mkfs.fat ${2}
		;;
	esac
	echo ""
	pressanykey
}
formatswapdevice(){
	options=()
	options+=("swap" "")
	sel=$(whiptail --backtitle "${apptitle}" --title "${txtformatdevice}" --menu "${txtselectpartformat//%1/${1} (${2})}" 0 0 0 \
		"${options[@]}" \
		3>&1 1>&2 2>&3)
	if [ ! "$?" = "0" ]; then
		return 1
	fi
	clear
	echo "${txtformatingpart//%1/${swapdev}} swap"
	echo "----------------------------------------------------"
	case ${sel} in
		swap)
			echo "mkswap ${swapdev}"
			mkswap ${swapdev}
			echo ""
			pressanykey
		;;
	esac
	clear
}
formatdevice(){
	options=()
	options+=("btrfs" "")
	options+=("ext4" "")
	options+=("ext3" "")
	options+=("ext2" "")
	options+=("xfs" "")
	options+=("f2fs" "")
	options+=("jfs" "")
	options+=("reiserfs" "")
	if [ ! "${3}" = "noluks" ]; then
		options+=("luks" "encrypted")
	fi
	sel=$(whiptail --backtitle "${apptitle}" --title "${txtformatdevice}" --menu "${txtselectpartformat//%1/${1} (${2})}" 0 0 0 \
		"${options[@]}" \
		3>&1 1>&2 2>&3)
	if [ ! "$?" = "0" ]; then
		return 1
	fi
	clear
	echo "${txtformatingpart//%1/${2}} ${sel}"
	echo "----------------------------------------------"
	case ${sel} in
		btrfs)
			fspkgs="${fspkgs[@]} btrfs-progs"
			echo "mkfs.btrfs -f ${2}"
			mkfs.btrfs -f ${2}
			if [ "${1}" = "root" ]; then
				echo "mount ${2} /mnt"
				echo "btrfs subvolume create /mnt/root"
				echo "btrfs subvolume set-default /mnt/root"
				echo "umount /mnt"
				mount ${2} /mnt
				btrfs subvolume create /mnt/root
				btrfs subvolume set-default /mnt/root
				umount /mnt
			fi
		;;
		ext4)
			echo "mkfs.ext4 ${2}"
			mkfs.ext4 ${2}
		;;
		ext3)
			echo "mkfs.ext3 ${2}"
			mkfs.ext3 ${2}
		;;
		ext2)
			echo "mkfs.ext2 ${2}"
			mkfs.ext2 ${2}
		;;
		xfs)
			fspkgs="${fspkgs[@]} xfsprogs"
			echo "mkfs.xfs -f ${2}"
			mkfs.xfs -f ${2}
		;;
		f2fs)
			fspkgs="${fspkgs[@]} f2fs-tools"
			echo "mkfs.f2fs -f $2"
			mkfs.f2fs -f $2
		;;
		jfs)
			fspkgs="${fspkgs[@]} jfsutils"
			echo "mkfs.jfs -f ${2}"
			mkfs.jfs -f ${2}
		;;
		reiserfs)
			fspkgs="${fspkgs[@]} reiserfsprogs"
			echo "mkfs.reiserfs -f ${2}"
			mkfs.reiserfs -f ${2}
		;;
		luks)
			echo "${txtcreateluksdevice}"
			echo "cryptsetup luksFormat ${2}"
			cryptsetup luksFormat ${2}
			if [ ! "$?" = "0" ]; then
				pressanykey
				return 1
			fi
			pressanykey
			echo ""
			echo "${txtopenluksdevice}"
			echo "cryptsetup luksOpen ${2} ${1}"
			cryptsetup luksOpen ${2} ${1}
			if [ ! "$?" = "0" ]; then
				pressanykey
				return 1
			fi
			pressanykey
			options=()
			options+=("normal" "")
			options+=("fast" "")
			sel=$(whiptail --backtitle "${apptitle}" --title "${txtformatdevice}" --menu "Wipe device ?" --cancel-button="${txtignore}" 0 0 0 \
				"${options[@]}" \
				3>&1 1>&2 2>&3)
			if [ "$?" = "0" ]; then
				case ${sel} in
					normal)
						echo "dd if=/dev/zero of=/dev/mapper/${1}"
						dd if=/dev/zero of=/dev/mapper/${1} & PID=$! &>/dev/null
					;;
					fast)
						echo "dd if=/dev/zero of=/dev/mapper/${1} bs=60M"
						dd if=/dev/zero of=/dev/mapper/${1} bs=60M & PID=$! &>/dev/null
					;;
				esac
				clear
				sleep 1
				while kill -USR1 ${PID} &>/dev/null
				do
					sleep 1
				done
			fi
			echo ""
			pressanykey
			formatdevice ${1} /dev/mapper/${1} noluks
			if [ "${1}" = "root" ]; then
				realrootdev=${rootdev}
				rootdev=/dev/mapper/${1}
				luksroot=1
				luksrootuuid=$(cryptsetup luksUUID ${2})
			else
				case ${1} in
					home) homedev=/dev/mapper/${1} ;;
				esac
				luksdrive=1
				crypttab="\n${1}    UUID=$(cryptsetup luksUUID ${2})    none"
			fi
			echo ""
			echo "${txtluksdevicecreated}"
		;;
	esac
	echo ""
	pressanykey
}
mountparts(){
	clear
	echo "mount ${rootdev} /mnt"
	mount ${rootdev} /mnt
	echo "mkdir /mnt/{boot,home}"
	mkdir /mnt/{boot,home} 2>/dev/null
	if [ ! "${bootdev}" = "" ]; then
		echo "mount ${bootdev} /mnt/boot"
		mount ${bootdev} /mnt/boot
	fi
	if [ ! "${swapdev}" = "" ]; then
		echo "swapon ${swapdev}"
		swapon ${swapdev}
	fi
	if [ ! "${homedev}" = "" ]; then
		echo "mount ${homedev} /mnt/home"
		mount ${homedev} /mnt/home
	fi
	pressanykey
}
