###
# Installation et Configuration de LOGWATCH
# ==============================================================================
# - Installation des paquets LOGWATCH
# - Installation des fichiers de configuration
# ------------------------------------------------------------------------------
# OLIX_INSTALL_LOGWATCH          : true pour l'installation
# OLIX_INSTALL_LOGWATCH_FILECFG  : Fichier logwatch.conf à utiliser
# OLIX_INSTALL_LOGWATCH_LOGFILES : Liste des fichiers de configuration pour surcharger la conf initiale
# OLIX_INSTALL_LOGWATCH_SERVICES : Liste des fichiers de services pour surcharger la conf initiale
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 12/05/2014
##


###
# Paramètres
##
__PATH_CONFIG="${OLIX_INSTALL_PATH_CONFIG}/logwatch"


###
# Test si LOGWATCH doit être installé
##
[[ "${OLIX_INSTALL_LOGWATCH}" != "true" ]] && logger_warning "Installation de LOGWATCH ignorée" && return

echo
echo -e "${CVIOLET} Installation et Configuration de LOGWATCH ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"


###
# Installation
##
logger_debug "Installation des packages LOGWATCH"
apt-get --yes install logwatch


###
# Mise en place du fichier de configuration
##
install_linkNodeConfiguration "${__PATH_CONFIG}/${OLIX_INSTALL_LOGWATCH_FILECFG}" "/etc/logwatch/conf/logwatch.conf" \
							  "Mise en place de ${CCYAN}${OLIX_INSTALL_LOGWATCH_FILECFG}${CVOID} vers /etc/logwatch/conf/logwatch.conf"


###
# Mise en place du fichier de configuration de "logfiles"
##
logger_debug "Effacement des fichiers déjà présents dans /etc/logwatch/conf/logfiles"
rm -f /etc/logwatch/conf/logfiles/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
for I in ${OLIX_INSTALL_LOGWATCH_LOGFILES}; do
	install_linkNodeConfiguration "${__PATH_CONFIG}/logfiles/${I}" "/etc/logwatch/conf/logfiles/" \
							      "Mise en place de ${CCYAN}logfiles/${I}${CVOID} vers /etc/logwatch/conf/logfiles"
done

###
# Mise en place du fichier de configuration de "services"
##
logger_debug "Effacement des fichiers déjà présents dans /etc/logwatch/conf/services"
rm -f /etc/logwatch/conf/services/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
for I in ${OLIX_INSTALL_LOGWATCH_SERVICES}; do
	install_linkNodeConfiguration "${__PATH_CONFIG}/services/${I}" "/etc/logwatch/conf/services/" \
							      "Mise en place de ${CCYAN}services/${I}${CVOID} vers /etc/logwatch/conf/services"
done


###
# Fin
##
echo -e "${CVERT}Installation et Configuration de ${CVIOLET}LOGWATCH${CVERT} terminée${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
