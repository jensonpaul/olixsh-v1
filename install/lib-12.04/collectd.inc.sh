###
# Installation et Configuration de COLLECTD
# ==============================================================================
# - Installation des paquets COLLECTD
# - Installation des fichiers de configuration
# - Reset des données
# ------------------------------------------------------------------------------
# OLIX_INSTALL_COLLECTD         : true pour l'installation
# OLIX_INSTALL_COLLECTD_FILECFG : Fichier collectd.conf à utiliser
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 05/05/2014
##


###
# Paramètres
##
__PATH_CONFIG="${OLIX_INSTALL_PATH_CONFIG}/collectd"


###
# Test si COLLECTD doit être installé
##
[[ "${OLIX_INSTALL_COLLECTD}" != "true" ]] && logger_warning "Installation de COLLECTD ignorée" && return

echo
echo -e "${CVIOLET} Installation et Configuration de COLLECTD ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"


###
# Installation
##
logger_debug "Installation des packages COLLECTD"
apt-get --yes install collectd librrds-perl libconfig-general-perl libhtml-parser-perl libregexp-common-perl


###
# Changement des droits
##
#gunzip /usr/share/doc/collectd/examples/collection.cgi.gz
logger_debug "Droit d'exécution sur /usr/share/doc/collectd/examples/collection.cgi"
chmod +x /usr/share/doc/collectd/examples/collection.cgi > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && logger_error


###
# Mise en place du fichier de configuration
##
install_backupFileOriginal "/etc/collectd/collectd.conf"
install_linkNodeConfiguration "${__PATH_CONFIG}/${OLIX_INSTALL_COLLECTD_FILECFG}" "/etc/collectd/collectd.conf" \
							  "Mise en place de ${CCYAN}${OLIX_INSTALL_COLLECTD_FILECFG}${CVOID} vers /etc/collectd/collectd.conf"


###
# Reset des données
##
echo -en "${Cjaune}ATTENTION !!! Ecrasement des fichiers de données RTM. Confirmer ${CJAUNE}[o/N]${CVOID} : "
read REPONSE
if [ "${REPONSE}" == "o" ]; then
    logger_debug "Effacement des fichiers de données RRD"
    rm -rf /var/lib/collectd/rrd/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    echo -e "Effacement des fichiers de données RRD : ${CVERT}OK ...${CVOID}"
fi


###
# Redémarrage du service
##
logger_debug "Redémarrage du service COLLECTD"
service collectd restart


###
# Fin
##
echo -e "${CVERT}Installation et Configuration de ${CVIOLET}COLLECTD${CVERT} terminée${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
