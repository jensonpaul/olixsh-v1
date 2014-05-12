###
# Installation et Configuration de SNMPD
# ==============================================================================
# - Installation des paquets SNMPD
# - Installation du fichier de configuration
# ------------------------------------------------------------------------------
# OLIX_INSTALL_SNMPD         : true pour l'installation
# OLIX_INSTALL_SNMPD_FILECFG : Fichier snmpd.conf à utiliser
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 12/05/2014
##


###
# Paramètres
##
__PATH_CONFIG="${OLIX_INSTALL_PATH_CONFIG}/snmpd"


###
# Test si SNMPD doit être installé
##
[[ "${OLIX_INSTALL_SNMPD}" != "true" ]] && logger_warning "Installation de SNMPD ignorée" && return

echo
echo -e "${CVIOLET} Installation et Configuration de SNMPD ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"


###
# Installation
##
logger_debug "Installation des packages SNMPD"
apt-get --yes install snmpd


###
# Mise en place du fichier de configuration
##
install_backupFileOriginal "/etc/snmp/snmpd.conf"
install_linkNodeConfiguration "${__PATH_CONFIG}/${OLIX_INSTALL_SNMPD_FILECFG}" "/etc/snmp/snmpd.conf" \
							  "Mise en place de ${CCYAN}${OLIX_INSTALL_SNMPD_FILECFG}${CVOID} vers /etc/snmp/snmpd.conf"


###
# Redémarrage du service
##
logger_debug "Redémarrage du service SNMPD"
service snmpd restart


###
# Fin
##
echo -e "${CVERT}Installation et Configuration de ${CVIOLET}SNMPD${CVERT} terminée${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
