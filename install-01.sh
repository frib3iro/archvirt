#!/usr/bin/env bash
#----------------------------------------------------------------------
# Script    : [install-01.sh]
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

# Tela de boas vindas
clear
echo -e "${S} ${C}Bem vindo a primeira parte da instalação do Arch Linux no modo UEFI${F}"
sleep 1

# Atualizando o relógio do sistema
echo
echo -e "${S} ${C}Atualizando o relógio do sistema${F}"
sleep 1
timedatectl set-ntp true

# Listando os discos
echo
echo -e "${S} ${C}Listando os discos${F}"
sleep 1
lsblk -l | grep disk

# Informando o nome do seu disco
echo
echo -en "${S} ${C}Informe o nome do seu disco:${F} "
read disco
disco=/dev/${disco}

echo
echo -e "${S} ${C}Iniciando particionamento na máquina virtual${F}"
sleep 1
(echo g; echo n; echo ""; echo ""; echo +512M; echo t; echo 1; echo n; echo ""; echo ""; echo ""; echo w) | fdisk ${disco}

# Formatando partições
echo
echo -e "${S} ${C}Formatando as partições${F}"
sleep 1
mkfs.fat -F32 ${disco}1
mkfs.ext4 ${disco}2

# Montando partições
echo
echo -e "${S} ${C}Montando as partições${F}"
sleep 1
mount ${disco}2 /mnt
mkdir -p /mnt/boot/efi
mount ${disco}1 /mnt/boot/efi

# Listando partições
echo
echo -e "${S} ${C}Conferindo as partições${F}"
sleep 1
lsblk ${disco}

# Instalando os pacotes base
echo
echo -e "${S} ${C}Instalando os pacotes base${F}"
sleep 1
pacstrap /mnt base base-devel linux linux-firmware intel-ucode

# Gerando o fstab
echo
echo -e "${S} ${C}Gerando o fstab${F}"
sleep 1
genfstab -U /mnt >> /mnt/etc/fstab

# Copiando o script archinstall-02.sh para /mnt
echo
echo -e "${S} ${C}Copiando o script install-02.sh para /mnt${F}"
sleep 1
cp install-02.sh /mnt

# Iniciando arch-chroot
echo
echo -e "${S} ${C}Iniciando arch-chroot${F}"
sleep 1
arch-chroot /mnt ./install-02.sh

