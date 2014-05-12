###
# Installation et Configuration de COLLECTD
# ==============================================================================
# - Installation des paquets COLLECTD
# - Installation des fichiers de configuration
# - Reset des données
# ------------------------------------------------------------------------------
# OLIX_INSTALL_COLLECTD         : true pour l'installation
# OLIX_INSTALL_COLLECTD_PLUGINS : Liste des plugins à activer
# ------------------------------------------------------------------------------
# @modified 12/05/2014
# Chaque plugin est configuré dans un fichier séparé dans conf.d : OLIX_INSTALL_COLLECTD_PLUGINS
# Désactivation des plugins et activation de ceux necessaires dans le fichier de conf principal
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 11/05/2014
##


###
# Paramètres
##
__PATH_CONFIG="${OLIX_INSTALL_PATH_CONFIG}/collectd"
__PLUGINS="syslog rrdtool df cpu load memory processes swap users"


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
# Activation des Plugins obligatoire
##
install_backupFileOriginal "/etc/collectd/collectd.conf"
logger_debug "Commentaire sur les LoadPlugin"
sed -i "s/^LoadPlugin/\#LoadPlugin/g" /etc/collectd/collectd.conf > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && logger_error
for I in ${__PLUGINS}; do
	logger_debug "Activation du plugin $I"
	sed -i "s/^\#LoadPlugin $I/LoadPlugin $I/g" /etc/collectd/collectd.conf > ${OLIX_LOGGER_FILE_ERR} 2>&1
	[[ $? -ne 0 ]] && logger_error
done


###
# Mise en place de la conf pour chaque plugin
##
logger_debug "Effacement des anciennes configurations"
rm -f /etc/collectd/collectd.conf.d/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && logger_error
for I in ${OLIX_INSTALL_COLLECTD_PLUGINS}; do
	install_linkNodeConfiguration "${__PATH_CONFIG}/$I.conf" "/etc/collectd/collectd.conf.d" \
								  "Activation du plugin ${CCYAN}$I${CVOID}"
done


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
