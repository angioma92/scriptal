#!/bin/bash
loadkeys ru
setfont cyr-sun16
clear
#####
echo " готовы приступить?  "
while 
    read -n1 -p  "
    1 - да
    
    0 - нет: " hello # sends right after the keypress
    echo ''
    [[ "$hello" =~ [^10] ]]
do
    :
done
 if [[ $hello == 1 ]]; then
  clear
  echo "Добро пожаловать в установку ArchLinux"
  elif [[ $hello == 0 ]]; then
   exit   
fi
###
echo ""

##
clear

efibootmgr
echo ""
echo " UEFI( no grub ) или Grub-legcy? "
while 
    read -n1 -p  "
    1 - UEFI
    
    2 - GRUB-legacy
    
    0 - exit " menu # sends right after the keypress
    echo ''
    [[ "$menu" =~ [^120] ]]
do
    :
done
if [[ $menu == 1 ]]; then
clear


echo ""
lsblk -f
echo " Здесь вы можете удалить boot от старой системы, файлы Windows загрузчика не затрагиваются."
echo " если вам необходимо полность очистить boot раздел, то пропустите этот этап далее установка предложит отформатировать boot раздел "
echo " При установке дуал бут раздел не нужно форматировать!!! "
echo ""
echo 'удалим старый загрузчик linux'
while 
    read -n1 -p  "
    1 - удалим старый загрузчкик линукс 
    
    0 -(пропустить) - данный этап можно пропустить если установка производиться первый раз или несколько OS  " boots 
    echo ''
    [[ "$boots" =~ [^10] ]]
do
    :
done
if [[ $boots == 1 ]]; then
  clear
 lsblk -f
  echo ""
read -p "Укажите boot раздел (sda2/sdb2 ( например sda2 )):" bootd
mount /dev/$bootd /mnt
cd /mnt
ls | grep -v EFI | xargs rm -rfv
cd /mnt/EFI
ls | grep -v Boot | grep -v Microsoft | xargs rm -rfv
cd /root
umount /mnt
  elif [[ $boots == 0 ]]; then
   echo " очистка boot раздела пропущена, далее вы сможете его отформатировать! "   
fi
#
pacman -Sy --noconfirm
##############################
clear
echo ""
echo " Выбирайте "1 ", если ранее не производилась разметка диска и у вас нет разделов для ArchLinux "
echo ""
echo 'Нужна разметка диска?'
while 
    read -n1 -p  "
    1 - да
    
    0 - нет: " cfdisk # sends right after the keypress
    echo ''
    [[ "$cfdisk" =~ [^10] ]]
do
    :
done
 if [[ $cfdisk == 1 ]]; then
   clear
 lsblk -f
  echo ""
  read -p "Укажите диск (sda/sdb например sda или sdb) : " cfd
cfdisk /dev/$cfd
echo ""
clear
elif [[ $cfdisk == 0 ]]; then
   echo ""
   clear
   echo 'разметка пропущена.'   
fi
#
  clear
  lsblk -f
  echo ""
  read -p "Укажите ROOT раздел(sda/sdb 1.2.3.4 (sda5 например)):" root
echo ""
mkfs.ext4 /dev/$root -L root
mount /dev/$root /mnt
echo ""
########## boot  ########
 clear
 lsblk -f
  echo ""
echo 'форматируем BOOT?'
while 
    read -n1 -p  "
    1 - да
    
    0 - нет: " boots # sends right after the keypress
    echo ''
    [[ "$boots" =~ [^10] ]]
do
    :
done
 if [[ $boots == 1 ]]; then
  read -p "Укажите BOOT раздел(sda/sdb 1.2.3.4 (sda7 например)):" bootd
  mkfs.fat -F32 /dev/$bootd
  mkdir /mnt/boot
  mount /dev/$bootd /mnt/boot
  elif [[ $boots == 0 ]]; then
 read -p "Укажите BOOT раздел(sda/sdb 1.2.3.4 (sda7 например)):" bootd 
 mkdir /mnt/boot
mount /dev/$bootd /mnt/boot
fi
############ swap   ####################################################
 clear
 lsblk -f
  echo ""
fi
 clear

################################################################################### 
clear 
  pacstrap /mnt base linux linux-headers dhcpcd which inetutils netctl base-devel wget nano linux-firmware  efibootmgr  
  genfstab -U /mnt >> /mnt/etc/fstab
##################################################
clear
  arch-chroot /mnt sh -c "$(curl -fsSL https://git.io/JLjW3)"
echo "################################################################"
echo "###################    T H E   E N D      ######################"
echo "################################################################"
umount -a
reboot  
#####################################
#####################################

elif [[ $menu == 0 ]]; then
exit
fi
