###
# Finalisation de l'installation d'un serveur Ubuntu
# ==============================================================================
# Mode intéractif uniquement
# - Configuration du réseau
# - Mise à jour du système
# - Configuration des utilisateurs
# - NTP
# - Vérification du système en UTF-8
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 09/04/2014
##


source lib/install.inc.sh


###
# Début de l'installation
##
echo
echo -e "${CBLANC}INSTALLATION DU SERVEUR UBUNTU ${CVIOLET}${OLIX_INSTALL_UBUNTU_VERSION_RELEASE}${CVOID}"
echo
sleep 1


###
# Chargement du fichier de conf pour l'installation
##
install_loadConfiguration


###
# RESEAU
##
source install/lib-${OLIX_INSTALL_UBUNTU_VERSION_RELEASE}/network.inc.sh
sleep 1


###
# MISE A JOUR DU SYSTEME
##
if [[ "${OLIX_INSTALL_APT_UPDATE}" == "true" ]]; then
    source install/lib-${OLIX_INSTALL_UBUNTU_VERSION_RELEASE}/apt-update.inc.sh
    sleep 1
fi


###
# UTF-8
##
source install/lib-${OLIX_INSTALL_UBUNTU_VERSION_RELEASE}/utf8.inc.sh
sleep 1


###
# NTP
##
source install/lib-${OLIX_INSTALL_UBUNTU_VERSION_RELEASE}/ntp.inc.sh
sleep 1


###
# Installation de Tools pour machine virtuel
##
if [[ "${OLIX_INSTALL_VIRTUALBOX}" == "true" ]]; then
    source install/lib-${OLIX_INSTALL_UBUNTU_VERSION_RELEASE}/virtualbox.inc.sh
fi
if [[ "${OLIX_INSTALL_VMWARE}" == "true" ]]; then
    source install/lib-${OLIX_INSTALL_UBUNTU_VERSION_RELEASE}/vmware.inc.sh
fi
sleep 1


###
# Utilisateur
##
source install/lib-${OLIX_INSTALL_UBUNTU_VERSION_RELEASE}/users.inc.sh
sleep 1


###
# FIN
##
echo
echo -e "${CBLANC}===============================================================================${CVOID}"
echo
echo -e "${CVERT}Finalisation de l'installation d'un serveur UBUNTU ${CVIOLET}${OLIX_INSTALL_UBUNTU_VERSION_RELEASE}${CVERT} terminée${CVOID}"
echo
echo -e "${Crouge}Il est fortement recommandé de rebooter${CVOID}"
echo -en "${Cjaune}Rebooter ${CJAUNE}[o/N]${CVOID} "
read REPONSE
if [ "${REPONSE}" == "o" ]; then
    reboot
fi
