###
# Installation et Configuration de SAMBA
# ==============================================================================
# - Installation des paquets SAMBA
# - Installation des fichiers de configuration
# - Activation des utilisateurs
# ------------------------------------------------------------------------------
# OLIX_INSTALL_SAMBA_INSTALL : 1 pour l'installation
# OLIX_INSTALL_SAMBA_FILECFG : Fichier smb.conf à utiliser
# OLIX_INSTALL_SAMBA_USERS   : Liste des utilisateurs à activer
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 03/05/2014
##


###
# Paramètres
##
__PATH_CONFIG="${OLIX_INSTALL_PATH_CONFIG}/samba"


###
# Test si SAMBA doit être installé
##
[[ "${OLIX_INSTALL_SAMBA}" != "true" ]] && logger_warning "Installation de SAMBA ignorée" && return

echo
echo -e "${CVIOLET} Installation et Configuration de SAMBA ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"


###
# Installation
##
logger_debug "Installation des packages SAMBA"
apt-get --yes install samba smbclient smbfs


###
# Mise en place du fichier de configuration
##
install_backupFileOriginal "/etc/samba/smb.conf"
install_linkNodeConfiguration "${__PATH_CONFIG}/${OLIX_INSTALL_SAMBA_FILECFG}" "/etc/samba/smb.conf" \
							  "Mise en place de ${CCYAN}${OLIX_INSTALL_SAMBA_FILECFG}${CVOID} vers /etc/samba/smb.conf"


###
# Activation des utilisateurs
##
for I in ${SAMBA_USERS}; do
	logger_debug "Activation de l'utilisateur $I"
    echo -e "Activation de l'utilisateur ${CCYAN}$I${CVOID}"
    smbpasswd -a $I
done


###
# Redémarrage du service
##
logger_debug "Redémarrage du service SAMBA"
service smbd restart


###
# Fin
##
echo -e "${CVERT}Installation et Configuration de ${CVIOLET}SAMBA${CVERT} terminée${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
