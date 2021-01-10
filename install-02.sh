#!/usr/bin/env bash
#----------------------------------------------------------------------
# Script    : [install-02.sh]
# Descrição : Script para instalação do arch linux no modo UEFI
# Versão    : 1.0
# Autor     : Fabio Junior Ribeiro
# Email     : rib3iro@live.com
# Data      : 11/12/2020
# Licença   : GNU/GPL v3.0
#----------------------------------------------------------------------
# Uso       : ./install-01.sh
#----------------------------------------------------------------------
# variaveis 
# Password root/user
user='fabio'
pass_user='123'
pass_root='123'
# Cores usadas no script
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
C='\033[0;36m'
# Fechamento das cores no script
F='\033[0m'
# Seta utilizada no inicio das frases
S='\e[32;1m[+]\e[m'
#----------------------------------------------------------------------
# Funções
arquivo_swap(){
    dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile none swap defaults 0 0" >> /etc/fstab
}

clear
echo -e "${S} ${C}Bem vindo a segunda parte da instalação do Arch Linux no modo UEFI${F}"
sleep 1

# Criando o arquivo de swap
echo
echo -en "${S} ${C}Criar o arquivo de swap [ s/n ]:${F} "
read resposta

if [ "$resposta" = 's' ]
then
    echo
    echo -e "${S} ${C}Criando o arquivo de swap${F}"
    sleep 1
    arquivo_swap
elif [ "$resposta" = 'n' ]
then
    echo
    echo -e "${S} ${C}O sistema será instalado sem o arquivo de swap${F}"
    sleep 1
else
    echo
    echo -e "${S} ${R}Resposta inválida!${F}"
    exit 1
fi

# Ajustando o fuso horário
echo
echo -e "${S} ${C}Ajustando o fuso horário${F}"
sleep 1
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Executando hwclock
echo
echo -e "${S} ${C}Executando o hwclock${F}"
sleep 1
hwclock --systohc --utc

# Definindo o idioma
echo
echo -e "${S} ${C}Definindo o idioma${F}"
sleep 1
sed -i 's/en_US ISO-8859-1/#en_US ISO-8859-1/' /etc/locale.gen
sed -i 's/en_US.UTF-8/#en_US.UTF-8/' /etc/locale.gen
sed -i 's/#pt_BR.UTF-8/pt_BR.UTF-8/' /etc/locale.gen
sed -i 's/#pt_BR ISO-8859-1/pt_BR ISO-8859-1/' /etc/locale.gen

# Gerando locale.gen
echo
echo -e "${S} ${C}Gerando o locale-gen${F}"
sleep 1
locale-gen

# Criando o arquivo locale.conf
echo
echo -e "${S} ${C}Criando o arquivo locale.conf${F}"
sleep 1
echo LANG=pt_BR.UTF-8 > /etc/locale.conf

# Exportando a variável LANG
echo
echo -e "${S} ${C}Exportando a variável LANG${F}"
sleep 1
export LANG=pt_BR.UTF-8

# Atualizando o relógio do sistema
echo
echo -e "${S} ${C}Atualizando o relógio do sistema${F}"
sleep 1
timedatectl set-ntp true

# Criando o arquivo vconsole.conf
echo
echo -e "${S} ${C}Criando o arquivo vconsole.conf${F}"
sleep 1
echo KEYMAP=br-abnt2 > /etc/vconsole.conf
echo FONT=ter-122n >> /etc/vconsole.conf

# Criando o hostname
echo
echo -e "${S} ${C}Criando o hostname${F}"
sleep 1
echo archlinux > /etc/hostname

# Configurando o hosts
echo
echo -e "${S} ${C}Configurando o arquivo hosts${F}"
sleep 1
cat >> '/etc/hosts' << EOF
127.0.0.1   localhost.localdomain localhost
::1         localhost.localdomain localhost
127.0.1.1   archlinux.localdomain archlinux
EOF

# Criando senha de root
echo
echo -e "${S} ${C}Criando a senha do root${F}"
sleep 1
echo "root:$pass_root" | chpasswd

# Baixando o Gerenciador de boot
echo
echo -e "${S} ${C}Baixando o Gerenciador de boot e mais alguns pacotes${F}"
sleep 1
pacman -S dialog dosfstools efibootmgr git grub linux-headers mtools networkmanager network-manager-applet terminus-font vim wget xorg --noconfirm

# Instalando o grub
echo
echo -e "${S} ${C}Instalando o grub${F}"
sleep 1
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Configurando o grub
echo
echo -e "${S} ${C}Configurando o grub${F}"
sleep 1
grub-mkconfig -o /boot/grub/grub.cfg

# Iniciando o NetworkManager
echo
echo -e "${S} ${C}Iniciando os Serviços NetworkManager${F}"
sleep 1
systemctl enable NetworkManager
systemctl start NetworkManager

# Adicionando um usuario
echo
echo -e "${S} ${C}Adicionando o usuário${F}"
sleep 1
useradd -m -g users -G wheel fabio

# Criando senha de usuario
echo
echo -e "${S} ${C}Adicionando a senha do usuário${F}"
sleep 1
echo "$user:$pass_user" | chpasswd

# Adicionando user no grupo sudoers
echo
echo -e "${S} ${C}Adicionando o usuário no grupo sudoers${F}"
sleep 1
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Colorindo a sída do pacman
echo
echo -e "${S} ${C}Colorindo a saída do pacman${F}"
sleep 1
sed -i 's/#Color/Color/' /etc/pacman.conf

# Definindo lauout do teclado para pt-br
echo
echo -e "${S} ${C}Definindo o layout do teclado no xorg${F}"
sleep 1
cat >> '/etc/X11/xorg.conf.d/10-keyboard.conf' << EOF
Section "InputClass"
Identifier "keyboard default"
MatchIsKeyboard "yes"
Option "XkbLayout" "br"
Option "XkbVariant" "abnt2"
fimSection
EOF

# Reiniciando
echo
echo -e "${S} ${R}Instalação finalizada!${F}"
exit

