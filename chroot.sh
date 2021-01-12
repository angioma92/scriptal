 
#!/bin/bash
ln -sf /usr/share/zoneinfo/Asia/Irkutsk /etc/localtime

echo 'en_US.UTF-8 UTF-8
ru_RU.UTF-8 UTF-8' > /etc/locale.gen

locale-gen
echo 'LANG=ru_RU.UTF-8' > /etc/locale.conf 
echo 'KEYMAP=ru
FONT=ter-k24n' > /etc/vconsole.conf
clear
echo ''
read -p "                 Введите имя компьютера: " hostname
clear
echo $hostname > /etc/hostname

echo '127.0.0.1    localhost
::1          localhost
127.0.1.1    $hostname.localdomain    $hostname' >> /etc/hosts

clear
echo ''
read -p "                 Введите имя нового пользователя: " username
clear
echo ''
echo "                    Создать пароль для ROOT "
passwd

useradd -m -G wheel,audio,video,storage,power -s /bin/bash $username
clear
echo ''
echo '                    Создать пароль для пользователя '$username' '
passwd $username
clear

echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
pacman -S amd-ucode --noconfirm
bootctl install 
echo 'default arch ' > /boot/loader/loader.conf
echo 'title    ARCH LINUX
linux    /vmlinuz-linux
initrd   /amd-ucode.img
initrd   /initramfs-linux.img' > /boot/loader/entries/arch.conf
clear
echo ''
read -p "                 ROOT раздел для загрузчика (например: sda2): " root
Proot=$(blkid -s PARTUUID /dev/$root | grep -oP '(?<=PARTUUID=").+?(?=")')
echo options    root=PARTUUID=$Proot rw quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0 radeon.modeset=1 mitigations=off amdgpu.ppfeaturemask=0xffffffff >> /boot/loader/entries/arch.conf

cd /home/$username 
git clone https://aur.archlinux.org/systemd-boot-pacman-hook.git
chown -R $username:wheel /home/$username/systemd-boot-pacman-hook   
cd /home/$username/systemd-boot-pacman-hook   
sudo -u $username makepkg -si --noconfirm  
rm -Rf /home/$username/systemd-boot-pacman-hook
cd /home/$username 
mkinitcpio -p linux

echo '[multilib]
Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

pacman -Syy
pacman -S xorg-server xorg-drivers xorg-apps mesa-demos --noconfirm
echo ''
while 
    read -n1 -p  "
    1 - Gnome
    
    0 - Openbox: " x_de
    [[ "$x_de" =~ [^10] ]]
do
    :
done 
 if [[ $x_de == 1 ]]; then
  pacman -S gnome gnome-tweaks chrome-gnome-shell --noconfirm
  pacman -Rsu totem eog baobab epiphany gnome-documents gnome-maps gnome-books gnome-contacts gnome-music gnome-photos gnome-software gnome-boxes --noconfirm
  pacman -S gdm --noconfirm
  systemctl enable gdm.service -f
 clear
elif [[ $x_de == 0 ]]; then
  pacman -S xorg-xinit openbox obconf lxappearance lxappearance-obconf volumeicon leafpad lxterminal nitrogen tint2 pcmanfm --noconfirm
  cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc
  chown $username:wheel /home/$username/.xinitrc
  chmod +x /home/$username/.xinitrc
  sed -i 52,55d /home/$username/.xinitrc
  echo "exec openbox-session" >> /home/$username/.xinitrc
  mkdir /etc/systemd/system/getty@tty1.service.d/
  echo '[Service]
  ExecStart=
  ExecStart=-/usr/bin/agetty --autologin $username --noclear %I 38400 linux' > /etc/systemd/system/getty@tty1.service.d/override.conf
  echo ' [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx ' >> /etc/profile
  
  mkdir -p /home/$username/.config/openbox
  cp -a /etc/xdg/openbox/ /home/$username/.config/
  chown -R $username:wheel /home/$username/.config/openbox
  
#######################  
###### autostart ###### 
#######################
  echo 'tint2 &
nitrogen --restore &
volumeicon &' >> /home/$username/.config/openbox/autostart
#######################  
###### menu ###### 
#######################
  echo '<?xml version="1.0" encoding="UTF-8"?>

<openbox_menu xmlns="http://openbox.org/3.4/menu">

<menu id="system-menu" label="System">
  <item label="obconf">
    <action name="Execute">
      <command>obconf</command>
      <startupnotify><enabled>yes</enabled></startupnotify>
    </action>
  </item>
    <item label="tint2">
    <action name="Execute">
      <command>tint2conf</command>
      <startupnotify><enabled>yes</enabled></startupnotify>
    </action>
  </item>
    <item label="lxappearance">
    <action name="Execute">
      <command>lxappearance</command>
      <startupnotify><enabled>yes</enabled></startupnotify>
    </action>
  </item>

</menu>

<menu id="root-menu" label="Openbox 3">
  <item label="Terminal">
    <action name="Execute">
      <command>lxterminal</command>
      <startupnotify><enabled>yes</enabled></startupnotify>
    </action>
  </item>
  <item label="Web Browser">
    <action name="Execute">
      <command>google-chrome-stable</command>
      <startupnotify><enabled>yes</enabled></startupnotify>
    </action>
  </item>
  <item label="File Manager">
    <action name="Execute">
      <command>pcmanfm</command>
      <startupnotify><enabled>yes</enabled></startupnotify>
    </action>
  </item>
  <item label="Text Editor">
    <action name="Execute">
      <command>leadpad</command>
      <startupnotify><enabled>yes</enabled></startupnotify>
    </action>
  </item>

  <separator />
  <menu id="system-menu"/>
  <separator />
    <item label="Reconfigure">
    <action name="Reconfigure" />
  </item>
  <item label="Log Out">
    <action name="Exit">
      <prompt>yes</prompt>
    </action>
  </item>
  <item label="Reboot">
    <action name="Execute">
        <prompt>
            Перезагрузка
        </prompt>
        <execute>
            sudo shutdown -r now
        </execute>
    </action>
  </item>

  <item label="Shutdown">
    <action name="Execute">
        <prompt>
            Выключение
        </prompt>
        <execute>
            sudo shutdown -h now
        </execute>
    </action>
  </item>
 </menu>

</openbox_menu>' > /home/$username/.config/openbox/menu.xml

##############################################################################
##############################################################################

fi 
clear
echo '################## Pulseaudio ##################'
pacman -S pulseaudio alsa-utils alsa-lib pavucontrol pulseaudio-equalizer-ladspa --noconfirm
clear
echo '################## files, fonts and git ##################'
pacman -S exfat-utils ntfs-3g unzip unrar lha file-roller p7zip unace lrzip --noconfirm
pacman -S  git ttf-liberation ttf-dejavu htop neofetch --noconfirm
clear

echo '################## Google Chrome ##################'
cd /home/$username   
git clone https://aur.archlinux.org/google-chrome.git
chown -R $username:wheel /home/$username/google-chrome 
cd /home/$username/google-chrome  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/google-chrome
clear

echo '################## INXI ##################'
cd /home/$username 
git clone https://aur.archlinux.org/inxi.git
chown -R $username:wheel /home/$username/inxi
cd /home/$username/inxi  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/inxi
clear

echo '################## AUR ##################'
cd /home/$username
git clone https://aur.archlinux.org/yay.git
chown -R $username:wheel /home/$username/yay
cd /home/$username/yay  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/yay
clear

echo '################## Pamac AUR ##################'
cd /home/$username
 git clone https://aur.archlinux.org/pamac-aur.git
chown -R $username:wheel /home/$username/pamac-aur
cd /home/$username/pamac-aur
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/pamac-aur
clear

echo '################## Corectrl ##################'
cd /home/$username
wget https://mirror.yandex.ru/mirrors/manjaro/testing/community/x86_64/corectrl-1.1.1-5-x86_64.pkg.tar.zst
chown -R $username:wheel /home/$username/corectrl-1.1.1-5-x86_64.pkg.tar.zst
sudo pacman -U corectrl-1.1.1-5-x86_64.pkg.tar.zst --noconfirm
rm /home/$username/corectrl-1.1.1-5-x86_64.pkg.tar.zst
clear

echo '################## Vulkan ##################'
pacman -S lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm
clear

echo '################## Wine ##################'
pacman -S wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm
clear

echo '################## Games libs ##################'
pacman -Syu cabextract cups faudio lib32-acl lib32-faudio lib32-fontconfig lib32-freetype2 lib32-gettext lib32-giflib lib32-gnutls lib32-gst-plugins-base-libs lib32-gtk3 lib32-harfbuzz lib32-lcms2 lib32-libjpeg-turbo lib32-libldap lib32-libnl lib32-libpcap lib32-libpng lib32-libtasn1 lib32-libtiff lib32-libusb lib32-libxcomposite lib32-libxinerama lib32-libxrandr lib32-libxslt lib32-libxss lib32-mpg123 lib32-nspr lib32-nss lib32-opencl-icd-loader lib32-p11-kit lib32-sqlite lib32-v4l-utils lib32-vkd3d lib32-vulkan-icd-loader libimagequant lsof opencl-icd-loader python-distro python-evdev python-pillow sane vkd3d zenity icoutils xterm wget curl libudev0-shim python2 wxgtk-common wxgtk3 gnu-netcat lib32-libudev0-shim lib32-vulkan-intel lib32-vulkan-radeon python2-wxpython3 vulkan-intel vulkan-tools gamemode vulkan-radeon winetricks --noconfirm
clear

echo 'Section "Device"
    Identifier "AMD"
    Driver "amdgpu"
    Option "TearFree" "true"
    Option "DRI" "3"
EndSection' > /etc/X11/xorg.conf.d/20-amdgpu.conf

echo 'polkit.addRule(function(action, subject) {
    if ((action.id == "org.corectrl.helper.init" ||
         action.id == "org.corectrl.helperkiller.init") &&
        subject.local == true &&
        subject.active == true &&
        subject.isInGroup("wheel")) {
            return polkit.Result.YES;
    }
});' > /etc/polkit-1/rules.d/90-corectrl.rules

echo 'zram' > /etc/modules-load.d/zram.conf
echo 'options zram num_devices=4' > /etc/modprobe.d/zram.conf
echo 'KERNEL=="zram0", ATTR{disksize}="1024Mb" RUN="/usr/bin/mkswap /dev/zram0", TAG+="systemd"
KERNEL=="zram1", ATTR{disksize}="1024Mb" RUN="/usr/bin/mkswap /dev/zram1", TAG+="systemd"
KERNEL=="zram2", ATTR{disksize}="1024Mb" RUN="/usr/bin/mkswap /dev/zram2", TAG+="systemd"
KERNEL=="zram3", ATTR{disksize}="1024Mb" RUN="/usr/bin/mkswap /dev/zram3", TAG+="systemd"' > /etc/udev/rules.d/99-zram.rules

echo 'UUID=12bf5ca9-9742-4868-9907-cff73d83ee37 /home/nik/250GB ext4 auto,users,rw 0 0
UUID=70663DBE663D863E /home/nik/500GB ntfs auto,users,rw 0 0
/dev/zram0 none swap defaults 0 0
/dev/zram1 none swap defaults 0 0
/dev/zram2 none swap defaults 0 0
/dev/zram3 none swap defaults 0 0' >> /etc/fstab

echo "vm.swappiness=20" > /etc/sysctl.d/swap.conf

sysctl -w vm.vfs_cache_pressure=1000
echo "vm.vfs_cache_pressure=1000" >> /etc/sysctl.d/99-sysctl.conf
echo "vm.dirty_background_ratio = 50" >> /etc/sysctl.conf
echo "vm.dirty_ratio = 80" >> /etc/sysctl.conf

pacman -S ufw --noconfirm
ufw enable
systemctl enable ufw
systemctl disable avahi-daemon
clear
mkinitcpio -p linux
clear
exit
