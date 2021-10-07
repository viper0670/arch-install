archmenu(){
	if [ "${1}" = "" ]; then
		nextitem="."
	else
		nextitem=${1}
	fi
	options=()
	options+=("${txtsethostname}" "/etc/hostname")
	options+=("${txtsetkeymap}" "/etc/vconsole.conf")
	options+=("${txtsetfont}" "/etc/vconsole.conf (${txtoptional})")
	options+=("${txtsetlocale}" "/etc/locale.conf, /etc/locale.gen")
	options+=("${txtsettime}" "/etc/localtime")
	options+=("${txtsetrootpassword}" "")
	options+=("${txtgenerate//%1/fstab}" "")
	if [ "${luksdrive}" = "1" ]; then
		options+=("${txtgenerate//%1/crypttab}" "")
	fi
	if [ "${luksroot}" = "1" ]; then
		options+=("${txtgenerate//%1/mkinitcpio.conf-luks}" "(encrypt hooks)")
	fi
	if [ "${isnvme}" = "1" ]; then
		options+=("${txtgenerate//%1/mkinitcpio.conf-nvme}" "(nvme module)")
	fi
	options+=("${txtedit//%1/fstab}" "(${txtoptional})")
	options+=("${txtedit//%1/crypttab}" "(${txtoptional})")
	options+=("${txtedit//%1/mkinitcpio.conf}" "(${txtoptional})")
	options+=("${txtedit//%1/mirrorlist}" "(${txtoptional})")
	options+=("${txtbootloader}" "")
	options+=("${txtextrasmenu}" "")
	options+=("archdi" "${txtarchdidesc}")
	sel=$(whiptail --backtitle "${apptitle}" --title "${txtarchinstallmenu}" --menu "" --cancel-button "${txtback}" --default-item "${nextitem}" 0 0 0 \
		"${options[@]}" \
		3>&1 1>&2 2>&3)
	if [ "$?" = "0" ]; then
		case ${sel} in
			"${txtsethostname}")
				archsethostname
				nextitem="${txtsetkeymap}"
			;;
			"${txtsetkeymap}")
				archsetkeymap
				nextitem="${txtsetlocale}"
			;;
			"${txtsetfont}")
				archsetfont
				nextitem="${txtsetlocale}"
			;;
			"${txtsetlocale}")
				archsetlocale
				nextitem="${txtsettime}"
			;;
			"${txtsettime}")
				archsettime
				nextitem="${txtsetrootpassword}"
			;;
			"${txtsetrootpassword}")
				archsetrootpassword
				nextitem="${txtgenerate//%1/fstab}"
			;;
			"${txtgenerate//%1/fstab}")
				archgenfstabmenu
				if [ "${luksdrive}" = "1" ]; then
					nextitem="${txtgenerate//%1/crypttab}"
				else
					if [ "${luksroot}" = "1" ]; then
						nextitem="${txtgenerate//%1/mkinitcpio.conf-luks}"
					else
						if [ "${isnvme}" = "1" ]; then
							nextitem="${txtgenerate//%1/mkinitcpio.conf-nvme}"
						else
							nextitem="${txtbootloader}"
						fi
					fi
				fi
			;;
			"${txtgenerate//%1/crypttab}")
				archgencrypttab
				if [ "${luksroot}" = "1" ]; then
					nextitem="${txtgenerate//%1/mkinitcpio.conf-luks}"
				else
					if [ "${isnvme}" = "1" ]; then
						nextitem="${txtgenerate//%1/mkinitcpio.conf-nvme}"
					else
						nextitem="${txtbootloader}"
					fi
				fi
			;;
			"${txtgenerate//%1/mkinitcpio.conf-luks}")
				archgenmkinitcpioluks
				if [ "${isnvme}" = "1" ]; then
					nextitem="${txtgenerate//%1/mkinitcpio.conf-nvme}"
				else
					nextitem="${txtbootloader}"
				fi
			;;
			"${txtgenerate//%1/mkinitcpio.conf-nvme}")
				archgenmkinitcpionvme
				nextitem="${txtbootloader}"
			;;
			"${txtedit//%1/fstab}")
				${EDITOR} /mnt/etc/fstab
				nextitem="${txtedit//%1/fstab}"
			;;
			"${txtedit//%1/crypttab}")
				${EDITOR} /mnt/etc/crypttab
				nextitem="${txtedit//%1/crypttab}"
			;;
			"${txtedit//%1/mkinitcpio.conf}")
				archeditmkinitcpio
				nextitem="${txtedit//%1/mkinitcpio.conf}"
			;;
			"${txtedit//%1/mirrorlist}")
				${EDITOR} /mnt/etc/pacman.d/mirrorlist
				nextitem="${txtedit//%1/mirrorlist}"
			;;
			"${txtbootloader}")
				archbootloadermenu
				nextitem="${txtextrasmenu}"
			;;
			"${txtextrasmenu}")
				archextrasmenu
				nextitem="archdi"
			;;
			"archdi")
				installarchdi
				nextitem="archdi"
			;;
		esac
		archmenu "${nextitem}"
	fi
}
