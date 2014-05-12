###
# Installation et Configuration de NFS
# ==============================================================================
# - Installation des paquets NFS
# - Installation des fichiers de configuration
# ------------------------------------------------------------------------------
# OLIX_INSTALL_NFS         : true pour l'installation
# OLIX_INSTALL_NFS_FILECFG : Fichier exports à utiliser
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 03/05/2014
##


###
# Paramètres
##
__PATH_CONFIG="${OLIX_INSTALL_PATH_CONFIG}/nfs"


###
# Test si NFS doit être installé
##
[[ "${OLIX_INSTALL_NFS}" != "true" ]] && logger_warning "Installation de NFS ignorée" && return

echo
echo -e "${CVIOLET} Installation et Configuration de NFS ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"


###
# Installation
##
logger_debug "Installation des packages NFS"
apt-get --yes install nfs-common nfs-kernel-server


###
# Mise en place du fichier de configuration
##
install_backupFileOriginal "/etc/exports"
install_linkNodeConfiguration "${__PATH_CONFIG}/${OLIX_INSTALL_NFS_FILECFG}" "/etc/exports" \
							  "Mise en place de ${CCYAN}${OLIX_INSTALL_NFS_FILECFG}${CVOID} vers /etc/exports"


###
# Redémarrage du service
##
logger_debug "Redémarrage du service NFS"
service nfs-kernel-server restart


###
# Fin
##
echo -e "${CVERT}Installation et Configuration de ${CVIOLET}NFS${CVERT} terminée${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
