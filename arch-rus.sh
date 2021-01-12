#!/bin/bash
efibootmgr -b 0 -B
efibootmgr -b 1 -B
efibootmgr -b 2 -B
efibootmgr -b 3 -B
efibootmgr -b 4 -B
efibootmgr -b 5 -B
timedatectl set-ntp true
loadkeys ru
setfont ter-k24n
clear
echo '                    Разметка диска'
echo ''
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
  echo ''
  read -p "               Укажите диск (например: sda) : " cfd
cfdisk /dev/$cfd
clear
lsblk
echo ''
read -p "                 Укажите ROOT раздел (например: sda2):" root
mkfs.ext4 /dev/$root
mount /dev/$root /mnt
clear
lsblk
echo ''
read -p "                 Укажите BOOT раздел (например: sda1):" bootd
mkfs.fat -F32 /dev/$bootd
mkdir /mnt/boot
mount /dev/$bootd /mnt/boot
clear
elif [[ $cfdisk == n ]]; then
  clear 
fi
lsblk
echo ''
read -p "                 Укажите ROOT раздел (например: sda2):" root
mkfs.ext4 /dev/$root
mount /dev/$root /mnt
clear
lsblk
echo ''
read -p "                 Укажите BOOT раздел (например: sda1):" bootd
mkfs.fat -F32 /dev/$bootd
mkdir /mnt/boot
mount /dev/$bootd /mnt/boot
clear
echo 'Server = https://mirror.yandex.ru/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
echo 'Server = https://mirror.truenetwork.ru/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
echo 'Server = http://mirror.yandex.ru/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
echo 'Server = http://mirror.truenetwork.ru/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
pacman -Sy --noconfirm
pacstrap /mnt base base-devel linux linux-headers linux-firmware dhcpcd wget which git terminus-font nano efibootmgr  
genfstab -U /mnt >> /mnt/etc/fstab
clear
arch-chroot /mnt sh -c "$(curl -fsSL https://git.io/JLjW3)"
umount -R /mnt
reboot
