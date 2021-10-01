$check network
if ping -q -c 1 -W 1 8.8.8.8 > /dev/null; then
	echo 
else
	echo "ERROR: Bad internet connection"
	exit
  
$partitioning (working on auto partition)
sgdisk --new=1:0:+768M $DEV
sgdisk --new=2:0:+2M $DEV
sgdisk --new=3:0:+128M $DEV
sgdisk --new=5:0:0 $DEV

$cfdisk /dev/sda

$prepare swap partition
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2swapon /dev/sda2

$prepare root partition
mkfs.ext4 /dev/sda3

$install arch system
pacman -Syy
mount /dev/sda3 /mnt
pacstrap /mnt base linux linux-firmware sudo nano

$configure arch system
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
nano /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
nano /etc/hosts
passwd

$install grub
pacman -S grub efibootmgr os-prober mtools
mkdir /boot/efi
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi
grub-mkconfig -o /boot/grub/grub.cfg
