###
# Installation des Tools pour VirtualBox
# ==============================================================================
# - Installation du noyau
# - Installation des tools
# ------------------------------------------------------------------------------
# @package olixsh
# @subpackage install
# @author Olivier
# @created 24/08/2013
##


echo
echo -e "${CVIOLET} Installation des Tools pour VirtualBox ${CVOID}"
echo -e "${CBLANC}===============================================================================${CVOID}"


###
# Traitement
##
if [ ! -f /etc/init.d/vboxadd ]; then
    logger_debug "Installation des packages necessaires à VirtualBox"
    apt-get --yes install dkms build-essential linux-headers-`uname -r`
    umount /dev/cdrom
    echo -en "Activer l'installation de ClientTools depuis le menu ${CJAUNE}[ENTER pour continuer] ?${CVOID} "
    read REP
    logger_debug "Montage du CDROM"
    mount /dev/cdrom /media/cdrom
    PWD_BCK=$(pwd)
    cd /media/cdrom
    logger_debug "Installation des Tools"
    sh ./VBoxLinuxAdditions.run
    cd ${PWD_BCK}
else
    logger_debug "/etc/init.d/vboxadd setup"
    /etc/init.d/vboxadd setup
fi

echo -en "Activer le partage automatique ${CJAUNE}[ENTER pour continuer] ?${CVOID} "; read REP
#    mount -t vboxsf $VBOX_SHARENAME $VBOX_MOUNTPOINT

