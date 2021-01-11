 
#!/bin/bash
timedatectl set-ntp true
pacman -Syyu  --noconfirm
echo ""
read -p "Введите имя компьютера: " hostname
echo ""
echo " Используйте в имени только буквы латинского алфавита "
echo ""
read -p "Введите имя пользователя: " username

echo $hostname > /etc/hostname
ln -sf /usr/share/zoneinfo/Asia/Irkutsk /etc/localtime
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo 'LANG=ru_RU.UTF-8' > /etc/locale.conf 
echo "KEYMAP=ru" >> /etc/vconsole.conf
echo "FONT=cyr-sun16" >> /etc/vconsole.conf
echo ""
echo " Укажите пароль для ROOT "
passwd

echo ""
useradd -m -G wheel,audio,video,storage,power -s /bin/bash $username
echo ""
echo 'Добавляем пароль для пользователя '$username' '
echo ""
passwd $username
echo ""

clear

bootctl install 
clear
echo ' default arch ' > /boot/loader/loader.conf
echo 'title   ARCH LINUX' > /boot/loader/entries/arch.conf
echo "linux  /vmlinuz-linux" >> /boot/loader/entries/arch.conf

pacman -S amd-ucode --noconfirm
echo  'initrd /amd-ucode.img ' >> /boot/loader/entries/arch.conf
echo "initrd  /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo ""
read -p "ROOT раздел для загрузчика: " root
Proot=$(blkid -s PARTUUID /dev/$root | grep -oP '(?<=PARTUUID=").+?(?=")')
echo options root=PARTUUID=$Proot rw quiet splash mitigations=off amdgpu.ppfeaturemask=0xffffffff >> /boot/loader/entries/arch.conf
#
cd /home/$username 
git clone https://aur.archlinux.org/systemd-boot-pacman-hook.git
chown -R $username:users /home/$username/systemd-boot-pacman-hook   
chown -R $username:users /home/$username/systemd-boot-pacman-hook/PKGBUILD 
cd /home/$username/systemd-boot-pacman-hook   
sudo -u $username makepkg -si --noconfirm  
rm -Rf /home/$username/systemd-boot-pacman-hook
cd /home/$username 
#
clear
mkinitcpio -p linux
##########
echo ""

echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
clear
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
clear
echo ""

pacman -Sy xorg-server xorg-drivers xorg-xdpyinfo mesa-demos --noconfirm
pacman -Syy
echo "#####################################################################"
echo ""
echo " Установим DE/WM? "
while 
    read -n1 -p  "
    1 - KDE(Plasma)
    
    2 - xfce 
    
    3 - gmome
    
    4 - lxde
    
    5 - Deepin

    6 - Mate

    7 - Lxqt
    
    8 - i3 (  конфиги стандартные, возможна установка с автовходом )

    0 - пропустить " x_de
    echo ''
    [[ "$x_de" =~ [^123456780] ]]
do
    :
done
if [[ $x_de == 0 ]]; then
  echo 'уcтановка DE пропущена' 
elif [[ $x_de == 1 ]]; then
pacman -S  plasma plasma-meta plasma-pa plasma-desktop kde-system-meta kde-utilities-meta kio-extras kwalletmanager latte-dock  konsole  kwalletmanager --noconfirm
clear
echo " Если желаете использовать 2 окружения тогда укажите 0  "
echo ""
echo " Нужен автовход без DM ? "
while 
    read -n1 -p  "
    1 - да  
    
    0 - нет : " i_kde   # sends right after the keypress
    echo ''
    [[ "$i_kde" =~ [^10] ]]
do
    :
done
if [[ $i_kde  == 0 ]]; then
echo " буду использовами DM "
elif [[ $i_kde  == 1 ]]; then
pacman -S xorg-xinit --noconfirm
cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc
chown $username:users /home/$username/.xinitrc
chmod +x /home/$username/.xinitrc
sed -i 52,55d /home/$username/.xinitrc
echo "exec startplasma-x11 " >> /home/$username/.xinitrc
mkdir /etc/systemd/system/getty@tty1.service.d/
echo " [Service] " > /etc/systemd/system/getty@tty1.service.d/override.conf
echo " ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo   ExecStart=-/usr/bin/agetty --autologin $username --noclear %I 38400 linux >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo ' [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx ' >> /etc/profile
fi
pacman -R konqueror --noconfirm
clear
echo "Plasma KDE успешно установлена"
elif [[ $x_de == 2 ]]; then
pacman -S  xfce4  pavucontrol xfce4-goodies  --noconfirm
clear
echo " Если желаете использовать 2 окружения тогда укажите 0  "
echo ""
echo " Нужен автовход без DM ? "
while 
    read -n1 -p  "
    1 - да  
    
    0 - нет : " i_xfce   # sends right after the keypress
    echo ''
    [[ "$i_xfce" =~ [^10] ]]
do
    :
done
if [[ $i_xfce  == 0 ]]; then
echo " буду использовами DM "
elif [[ $i_xfce  == 1 ]]; then
pacman -S xorg-xinit --noconfirm
cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc
chown $username:users /home/$username/.xinitrc
chmod +x /home/$username/.xinitrc
sed -i 52,55d /home/$username/.xinitrc
echo "exec startxfce4 " >> /home/$username/.xinitrc
mkdir /etc/systemd/system/getty@tty1.service.d/
echo " [Service] " > /etc/systemd/system/getty@tty1.service.d/override.conf
echo " ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo   ExecStart=-/usr/bin/agetty --autologin $username --noclear %I 38400 linux >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo ' [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx ' >> /etc/profile
fi
clear
echo "Xfce успешно установлено"
elif [[ $x_de == 3 ]]; then
pacman -S gnome gnome-tweaks chrome-gnome-shell  --noconfirm
clear
echo " Gnome успешно установлен " 
elif [[ $x_de == 4 ]]; then
pacman -S lxde --noconfirm
clear
echo " Если желаете использовать 2 окружения тогда укажите 0  "
echo ""
echo " Нужен автовход без DM ? "
while 
    read -n1 -p  "
    1 - да  
    
    0 - нет : " i_lxde   # sends right after the keypress
    echo ''
    [[ "$i_lxde" =~ [^10] ]]
do
    :
done
if [[ $i_lxde  == 0 ]]; then
echo " буду использовами DM "
elif [[ $i_lxde  == 1 ]]; then
pacman -S xorg-xinit --noconfirm
cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc
chown $username:users /home/$username/.xinitrc
chmod +x /home/$username/.xinitrc
sed -i 52,55d /home/$username/.xinitrc
echo "exec startlxde " >> /home/$username/.xinitrc
mkdir /etc/systemd/system/getty@tty1.service.d/
echo " [Service] " > /etc/systemd/system/getty@tty1.service.d/override.conf
echo " ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo   ExecStart=-/usr/bin/agetty --autologin $username --noclear %I 38400 linux >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo ' [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx ' >> /etc/profile
fi
clear
echo " lxde успешно установлен "
elif [[ $x_de == 5 ]]; then
pacman -S deepin deepin-extra --noconfirm
clear
echo " Если желаете использовать 2 окружения тогда укажите 0  "
echo ""
echo " Нужен автовход без DM ? "
while 
    read -n1 -p  "
    1 - да  
    
    0 - нет : " i_deepin   # sends right after the keypress
    echo ''
    [[ "$i_deepin" =~ [^10] ]]
do
    :
done
if [[ $i_deepin  == 0 ]]; then
echo " буду использовами DM "
elif [[ $i_deepin  == 1 ]]; then
pacman -S xorg-xinit --noconfirm
cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc
chown $username:users /home/$username/.xinitrc
chmod +x /home/$username/.xinitrc
sed -i 52,55d /home/$username/.xinitrc
echo "exec startdde  " >> /home/$username/.xinitrc
mkdir /etc/systemd/system/getty@tty1.service.d/
echo " [Service] " > /etc/systemd/system/getty@tty1.service.d/override.conf
echo " ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo   ExecStart=-/usr/bin/agetty --autologin $username --noclear %I 38400 linux >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo ' [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx ' >> /etc/profile
fi
clear
echo " Deepin успешно установлен "
elif [[ $x_de == 6 ]]; then
pacman -S  mate mate-extra  --noconfirm
clear
echo " Если желаете использовать 2 окружения тогда укажите 0  "
echo ""
echo " Нужен автовход без DM ? "
while 
    read -n1 -p  "
    1 - да  
    
    0 - нет : " i_mate   # sends right after the keypress
    echo ''
    [[ "$i_mate" =~ [^10] ]]
do
    :
done
if [[ $i_mate  == 0 ]]; then
echo " буду использовами DM "
elif [[ $i_mate  == 1 ]]; then
pacman -S xorg-xinit --noconfirm
cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc
chown $username:users /home/$username/.xinitrc
chmod +x /home/$username/.xinitrc
sed -i 52,55d /home/$username/.xinitrc
echo "exec mate-session  " >> /home/$username/.xinitrc
mkdir /etc/systemd/system/getty@tty1.service.d/
echo " [Service] " > /etc/systemd/system/getty@tty1.service.d/override.conf
echo " ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo   ExecStart=-/usr/bin/agetty --autologin $username --noclear %I 38400 linux >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo ' [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx ' >> /etc/profile
fi
clear
echo " Mate успешно установлен "
elif [[ $x_de == 7 ]]; then
pacman -S lxqt lxqt-qtplugin lxqt-themes oxygen-icons xscreensaver --noconfirm
clear
echo " Если желаете использовать 2 окружения тогда укажите 0  "
echo ""
echo " Нужен автовход без DM ? "
while 
    read -n1 -p  "
    1 - да  
    
    0 - нет : " i_lxqt   # sends right after the keypress
    echo ''
    [[ "$i_deepin" =~ [^10] ]]
do
    :
done
if [[ $i_lxqt  == 0 ]]; then
echo " буду использовами DM "
elif [[ $i_lxqt  == 1 ]]; then
pacman -S xorg-xinit --noconfirm
cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc
chown $username:users /home/$username/.xinitrc
chmod +x /home/$username/.xinitrc
sed -i 52,55d /home/$username/.xinitrc
echo "exec startlxqt " >> /home/$username/.xinitrc
mkdir /etc/systemd/system/getty@tty1.service.d/
echo " [Service] " > /etc/systemd/system/getty@tty1.service.d/override.conf
echo " ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo   ExecStart=-/usr/bin/agetty --autologin $username --noclear %I 38400 linux >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo ' [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx ' >> /etc/profile
fi
clear
echo " Lxqt успешно установлен "
elif [[ $x_de == 8 ]]; then
pacman -S i3 i3-wm i3status dmenu --noconfirm
clear
echo ""
echo " Если желаете использовать 2 окружения тогда укажите 0  "
echo ""
echo " Нужен автовход без DM ? "
while 
    read -n1 -p  "
    1 - да  
    
    0 - нет : " i_i3w   # sends right after the keypress
    echo ''
    [[ "$i_i3w" =~ [^10] ]]
do
    :
done
if [[ $i_i3w  == 0 ]]; then
echo " буду использовами DM "
elif [[ $i_i3w  == 1 ]]; then
pacman -S xorg-xinit --noconfirm
cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc
chown $username:users /home/$username/.xinitrc
chmod +x /home/$username/.xinitrc
sed -i 52,55d /home/$username/.xinitrc
echo "exec i3 " >> /home/$username/.xinitrc
mkdir /etc/systemd/system/getty@tty1.service.d/
echo " [Service] " > /etc/systemd/system/getty@tty1.service.d/override.conf
echo " ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo   ExecStart=-/usr/bin/agetty --autologin $username --noclear %I 38400 linux >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo ' [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx ' >> /etc/profile
fi
echo ""
echo " nitrogen - легкая программа для установки обоев на рабочий стол" 
echo ""
echo " Установим nitrogen? "
while 
    read -n1 -p  "
    1 - да  
    
    0 - нет : " i_natro   # sends right after the keypress
    echo ''
    [[ "$i_natro" =~ [^10] ]]
do
    :
done
if [[ $i_natro  == 0 ]]; then
echo "yстановка пропущена"
elif [[ $i_natro  == 1 ]]; then
pacman -Sy nitrogen  --noconfirm
fi
echo " i3wm успешно установлен " 
fi
clear 
####
echo ""
echo " Установим еще одно DE/WM? "
while 
    read -n1 -p  "
    1 - KDE(Plasma)
    
    2 - xfce 
    
    3 - gmome
    
    4 - lxde
    
    5 - Deepin

    6 - Mate

    7 - Lxqt
    
    8 - i3 ( конфиги стандартные, не забудьте установить DM )

    0 - пропустить " x_de2
    echo ''
    [[ "$x_de2" =~ [^123456780] ]]
do
    :
done
if [[ $x_de2 == 0 ]]; then
  echo 'уcтановка DE пропущена' 
elif [[ $x_de2 == 1 ]]; then
pacman -S plasma plasma-meta plasma-pa plasma-desktop kde-system-meta kde-utilities-meta kio-extras kwalletmanager latte-dock  konsole  kwalletmanager --noconfirm
pacman -R konqueror --noconfirm
clear
echo "Plasma KDE успешно установлена"
elif [[ $x_de2 == 2 ]]; then
pacman -S  xfce4 pavucontrol xfce4-goodies  --noconfirm
clear
echo "Xfce успешно установлено"
elif [[ $x_de2 == 3 ]]; then
pacman -S gnome gnome-extra  --noconfirm
clear
echo " Gnome успешно установлен " 
elif [[ $x_de2 == 4 ]]; then
pacman -S lxde --noconfirm
clear
echo " lxde успешно установлен "
elif [[ $x_de2 == 5 ]]; then
pacman -S deepin deepin-extra
clear
echo " Deepin успешно установлен "
elif [[ $x_de2 == 6 ]]; then
pacman -S  mate mate-extra  --noconfirm
clear
echo " Mate успешно установлен "
elif [[ $x_de2 == 7 ]]; then
pacman -S lxqt lxqt-qtplugin lxqt-themes --noconfirm
clear
echo " Lxqt успешно установлен "
elif [[ $x_de2 == 8 ]]; then
pacman -S i3 i3-wm i3status  dmenu  --noconfirm
clear
echo " Установка i3 завершена "
echo ""
echo " nitrogen - легкая программа для установки обоев на рабочий стол" 
echo ""
echo " Установим nitrogen? "
while 
    read -n1 -p  "
    1 - да  
    
    0 - нет : " i_natro   # sends right after the keypress
    echo ''
    [[ "$i_natro" =~ [^10] ]]
do
    :
done
if [[ $i_natro  == 0 ]]; then
echo "yстановка пропущена"
elif [[ $i_natro  == 1 ]]; then
pacman -Sy nitrogen  --noconfirm
fi 
fi
clear
echo "#####################################################################"
echo ""
echo " При установке i3  без dm, dm не ставим!!! " 
echo " 
Arch-wiki рекоендует для: 
kde      <-> sddm
Lxqt     <-> sddm
xfce(i3) <-> lightdm
lxde     <-> lightdm
Gnome    <-> gdm
Deepin   <-> lightdm
Mate     <-> lightdm "
echo ""
echo "Установка Менеджера входа в систему "
while 
    read -n1 -p  "
    1 - Sddm
    
    2 - lightdm 
    
    3 - gdm
    
    0 - пропустить: " i_dm # sends right after the keypress
    
    echo ''
    [[ "$i_dm" =~ [^1230] ]]
do
    :
done
if [[ $i_dm == 0 ]]; then
clear
echo " Установка пропущена "
elif [[ $i_dm == 1 ]]; then
pacman -S sddm sddm-kcm --noconfirm
systemctl enable sddm.service -f
clear
echo " установка sddm  завершена "
elif [[ $i_dm == 2 ]]; then
pacman -S lightdm lightdm-gtk-greeter-settings lightdm-gtk-greeter --noconfirm
systemctl enable lightdm.service -f
clear
echo " установка lightdm завершена "
elif [[ $i_dm == 3 ]]; then
pacman -S gdm --noconfirm
systemctl enable gdm.service -f
clear
echo " установка gdm завершена "
fi

systemctl enable dhcpcd.service

clear
echo ""

pacman -Sy pulseaudio alsa-utils alsa-lib pavucontrol pulseaudio-equalizer-ladspa   --noconfirm

pacman -Sy exfat-utils ntfs-3g   --noconfirm
#####
clear

pacman -Sy unzip unrar lha file-roller p7zip unace lrzip  --noconfirm  

clear
echo ""
###############################################################################
pacman -S  git ttf-liberation ttf-dejavu htop neofetch --noconfirm
clear

cd /home/$username   
git clone https://aur.archlinux.org/google-chrome.git
chown -R $username:users /home/$username/google-chrome 
chown -R $username:users /home/$username/google-chrome/PKGBUILD 
cd /home/$username/google-chrome  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/google-chrome
clear

cd /home/$username
git clone https://aur.archlinux.org/yay.git
chown -R $username:users /home/$username/yay
chown -R $username:users /home/$username/yay/PKGBUILD 
cd /home/$username/yay  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/yay
clear


cd /home/$username 
git clone https://aur.archlinux.org/inxi.git
chown -R $username:users /home/$username/inxi
chown -R $username:users /home/$username/inxi/PKGBUILD 
cd /home/$username/inxi  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/inxi
clear

cd /home/$username
 git clone https://aur.archlinux.org/pamac-aur.git
chown -R $username:users /home/$username/pamac-aur
chown -R $username:users /home/$username/pamac-aur/PKGBUILD 
cd /home/$username/pamac-aur
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/pamac-aur
clear
echo ""
echo " Просмотрим//отредактируем /etc/fstab ?"
while 
    read -n1 -p  "1 - да, 0 - нет: " vm_fstab # sends right after the keypress
    echo ''
    [[ "$vm_fstab" =~ [^10] ]]
do
    :
done
if [[ $vm_fstab == 0 ]]; then
  echo 'этап пропущен' 
elif [[ $vm_fstab == 1 ]]; then
nano /etc/fstab
fi 
clear
echo " Установка завершена для выхода введите >> exit << "
exit
exit
