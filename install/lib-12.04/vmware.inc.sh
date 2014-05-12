###
# Installation des Tools pour VMware
# ==============================================================================
# - Installation du noyau
# - Installation des tools
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 10/05/2014
##


echo
echo -e "${CVIOLET} Installation des Tools pour VMware ${CVOID}"
echo -e "${CBLANC}===============================================================================${CVOID}"


###
# Traitement
##
if [ ! -f /usr/bin/vmware-config-tools.pl ]; then
    logger_debug "Installation des packages necessaires à VMware"
    apt-get --yes install dkms build-essential linux-headers-`uname -r`
    umount /dev/cdrom
    echo -en "Activer l'installation de VMware Tools depuis le menu ${CJAUNE}[ENTER pour continuer] ?${CVOID} "
    read REP
    logger_debug "Montage du CDROM"
    mount /dev/cdrom /media/cdrom
    PWD_BCK=$(pwd)
    cd /tmp
    logger_debug "Décompression des Tools"
    tar xzf /media/cdrom/VMwareTools-*.tar.gz
    cd vmware-tools-distrib
    logger_debug "Installation des Tools"
    ./vmware-install.pl
    cd ${PWD_BCK}
fi
