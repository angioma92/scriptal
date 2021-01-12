#!/bin/bash
efibootmgr -b 0 -B
efibootmgr -b 1 -B
efibootmgr -b 2 -B
efibootmgr -b 3 -B
efibootmgr -b 4 -B
efibootmgr -b 5 -B
timedatectl set-ntp true
loadkeys ru
setfont cyr-sun16
clear
echo 'Разметка диска'
while 
  read -n1 -p  "
  y - да
  n - нет: " cfdisk
    [[ "$cfdisk" =~ [^yn] ]]
do
  :
done
  if [[ $cfdisk == y ]]; then
  clear
  lsblk
  read -p "Укажите диск (например: sda) : " cfd
cfdisk /dev/$cfd
clear
elif [[ $cfdisk == n ]]; then
  clear 
fi
lsblk
read -p "Укажите ROOT раздел (например: sda2):" root
mkfs.ext4 /dev/$root
mount /dev/$root /mnt
clear
lsblk
read -p "Укажите BOOT раздел (например: sda1):" bootd
mkfs.fat -F32 /dev/$bootd
mkdir /mnt/boot
mount /dev/$bootd /mnt/boot
clear 
pacstrap /mnt base base-devel linux linux-headers linux-firmware dhcpcd wget nano  efibootmgr  
genfstab -U /mnt >> /mnt/etc/fstab
clear
arch-chroot /mnt sh -c "$(curl -fsSL https://git.io/JLjW3)"
umount -R /mnt
reboot
