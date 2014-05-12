###
# Installation et Configuration de MONIT
# ==============================================================================
# - Installatio des paquets MONIT
# - Installation des fichiers de configuration
# ------------------------------------------------------------------------------
# OLIX_INSTALL_MONIT       : true pour l'installation
# OLIX_INSTALL_MONIT_CONFD : Liste des fichiers de conf des check
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 12/05/2013
##


###
# Paramètres
##
__PATH_CONFIG="${OLIX_INSTALL_PATH_CONFIG}/monit"


###
# Test si MONIT doit être installé
##
[[ "${OLIX_INSTALL_MONIT}" != "true" ]] && logger_warning "Installation de MONIT ignorée" && return

echo
echo -e "${CVIOLET} Installation et Configuration de MONIT ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"


###
# Installation
##
logger_debug "Installation des packages MONIT"
apt-get --yes install monit


###
# Mise en place du fichier de configuration
##
logger_debug "Effacement des fichiers déjà présents dans /etc/monit/conf.d"
rm -f /etc/monit/conf.d/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && logger_error
for I in ${OLIX_INSTALL_MONIT_CONFD}; do
	install_linkNodeConfiguration "${__PATH_CONFIG}/${I}" "/etc/monit/conf.d/" \
							      "Mise en place de ${CCYAN}${I}${CVOID} vers /etc/monit/conf.d"
done


###
# Redémarrage du service
##
logger_debug "Redémarrage du service MONIT"
service monit restart


###
# Fin
##
echo -e "${CVERT}Installation et Configuration de ${CVIOLET}MONIT${CVERT} terminée${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
