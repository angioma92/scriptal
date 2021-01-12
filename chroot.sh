 
#!/bin/bash
read -p "Введите имя компьютера: " hostname
read -p "Введите имя пользователя: " username
clear
echo $hostname > /etc/hostname
echo 127.0.0.1 localhost > /etc/hosts
echo ::1 localhost >> /etc/hosts
echo 127.0.1.1 $hostname.localdomain $hostname >> /etc/hosts
clear
ln -sf /usr/share/zoneinfo/Asia/Irkutsk /etc/localtime
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo 'LANG=ru_RU.UTF-8' > /etc/locale.conf 
echo "KEYMAP=ru" > /etc/vconsole.conf
echo "FONT=ter-k24n" >> /etc/vconsole.conf
clear
echo " Укажите пароль для ROOT "
passwd

useradd -m -G wheel,audio,video,storage,power -s /bin/bash $username
clear
echo 'Укажите пароль для пользователя '$username' '
passwd $username
clear

bootctl install 
echo ' default arch ' > /boot/loader/loader.conf
echo 'title   ARCH LINUX' > /boot/loader/entries/arch.conf
echo "linux  /vmlinuz-linux" >> /boot/loader/entries/arch.conf
pacman -S amd-ucode --noconfirm
echo  'initrd /amd-ucode.img ' >> /boot/loader/entries/arch.conf
echo "initrd  /initramfs-linux.img" >> /boot/loader/entries/arch.conf
clear

read -p "Укажите ROOT раздел для загрузчика (например: sda2): " root
Proot=$(blkid -s PARTUUID /dev/$root | grep -oP '(?<=PARTUUID=").+?(?=")')
echo options root=PARTUUID=$Proot rw quiet splash mitigations=off amdgpu.ppfeaturemask=0xffffffff >> /boot/loader/entries/arch.conf

cd /home/$username 
git clone https://aur.archlinux.org/systemd-boot-pacman-hook.git
chown -R $username:users /home/$username/systemd-boot-pacman-hook   
chown -R $username:users /home/$username/systemd-boot-pacman-hook/PKGBUILD 
cd /home/$username/systemd-boot-pacman-hook   
sudo -u $username makepkg -si --noconfirm  
rm -Rf /home/$username/systemd-boot-pacman-hook
cd /home/$username 
mkinitcpio -p linux

echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

pacman -Syy
pacman -S xorg-server xorg-drivers xorg-apps mesa-demos --noconfirm
pacman -S gnome gnome-tweaks chrome-gnome-shell --noconfirm
pacman -S gdm --noconfirm

systemctl enable gdm.service -f
systemctl enable dhcpcd.service

pacman -S pulseaudio alsa-utils alsa-lib pavucontrol pulseaudio-equalizer-ladspa --noconfirm
pacman -S exfat-utils ntfs-3g unzip unrar lha file-roller p7zip unace lrzip --noconfirm
pacman -S  git ttf-liberation ttf-dejavu htop neofetch --noconfirm

cd /home/$username   
git clone https://aur.archlinux.org/google-chrome.git
chown -R $username:users /home/$username/google-chrome 
chown -R $username:users /home/$username/google-chrome/PKGBUILD 
cd /home/$username/google-chrome  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/google-chrome

cd /home/$username 
git clone https://aur.archlinux.org/inxi.git
chown -R $username:users /home/$username/inxi
chown -R $username:users /home/$username/inxi/PKGBUILD 
cd /home/$username/inxi  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/inxi

cd /home/$username
git clone https://aur.archlinux.org/yay.git
chown -R $username:users /home/$username/yay
chown -R $username:users /home/$username/yay/PKGBUILD 
cd /home/$username/yay  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/yay

cd /home/$username
 git clone https://aur.archlinux.org/pamac-aur.git
chown -R $username:users /home/$username/pamac-aur
chown -R $username:users /home/$username/pamac-aur/PKGBUILD 
cd /home/$username/pamac-aur
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/pamac-aur

pacman -S ufw --noconfirm
systemctl enable ufw
ufw enable

pacman -S lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm

pacman -S wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm

pacman -Syu cabextract cups faudio lib32-acl lib32-faudio lib32-fontconfig lib32-freetype2 lib32-gettext lib32-giflib lib32-gnutls lib32-gst-plugins-base-libs lib32-gtk3 lib32-harfbuzz lib32-lcms2 lib32-libjpeg-turbo lib32-libldap lib32-libnl lib32-libpcap lib32-libpng lib32-libtasn1 lib32-libtiff lib32-libusb lib32-libxcomposite lib32-libxinerama lib32-libxrandr lib32-libxslt lib32-libxss lib32-mpg123 lib32-nspr lib32-nss lib32-opencl-icd-loader lib32-p11-kit lib32-sqlite lib32-v4l-utils lib32-vkd3d lib32-vulkan-icd-loader libimagequant lsof opencl-icd-loader python-distro python-evdev python-pillow sane vkd3d zenity icoutils xterm wget curl libudev0-shim python2 wxgtk-common wxgtk3 gnu-netcat lib32-libudev0-shim lib32-vulkan-intel lib32-vulkan-radeon python2-wxpython3 vulkan-intel vulkan-tools gamemode vulkan-radeon --noconfirm

pacman -Rsu totem evince eog baobab epiphany gnome-documents gnome-maps gnome-books gnome-contacts gnome-music cups gnome-photos gnome-software gnome-boxes wpa_supplicant --noconfirm

clear
exit
