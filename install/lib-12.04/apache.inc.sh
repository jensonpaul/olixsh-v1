###
# Installation et configuration d'APACHE
# ==============================================================================
# - Installation des paquets APACHE
# - Activation des modules
# - Installation des fichiers de configuration
# - Activation du site par défaut
# ------------------------------------------------------------------------------
# OLIX_INSTALL_APACHE         : true pour l'installation
# OLIX_INSTALL_APACHE_MODULES : Liste des modules apache à activer
# OLIX_INSTALL_APACHE_FILECFG : Liste des fichiers de configuration httpd.conf, etc...
# OLIX_INSTALL_APACHE_VHOST   : Nom du dossier contenant les virtual host
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 02/05/2014
##


###
# Paramètres
##
__PATH_CONFIG="${OLIX_INSTALL_PATH_CONFIG}/apache"


###
# Test si APACHE doit être installé
##
[[ "${OLIX_INSTALL_APACHE}" != "true" ]] && logger_warning "Installation de APACHE ignorée" && return

echo
echo -e "${CVIOLET} Installation et Configuration de APACHE ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"


###
# Installation
##
logger_debug "Installation des packages APACHE"
apt-get --yes install apache2-mpm-prefork ssl-cert


###
# Activation des modules Apache
##
for I in ${OLIX_INSTALL_APACHE_MODULES}; do
    logger_debug "Activation du module $I"
    a2enmod $I > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    echo -e "Activation du module ${CCYAN}$I${CVOID} : ${CVERT}OK ...${CVOID}"
done


###
# Installation des fichiers de configuration
##
for I in ${OLIX_INSTALL_APACHE_FILECFG}; do
	install_linkNodeConfiguration "${__PATH_CONFIG}/$I" "/etc/apache2/" \
								  "Mise en place de ${CCYAN}$I${CVOID} vers /etc/apache2"
done


###
# Activation du site par défaut
##
logger_debug "Effacement de /etc/apache2/sites-enabled/*"
rm -rf /etc/apache2/sites-enabled/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && logger_error

install_linkNodeConfiguration "${__PATH_CONFIG}/${OLIX_INSTALL_APACHE_VHOST}.default.conf" "/etc/apache2/sites-available/000-default.conf"

logger_debug "Activation du site 000-default.conf"
a2ensite 000-default.conf > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && logger_error
echo -e "Activation du site ${CCYAN}default.conf${CVOID} : ${CVERT}OK ...${CVOID}"


###
# Redémarrage du service
##
logger_debug "Redémarrage du service APACHE"
service apache2 restart


###
# Fin
##
echo -e "${CVERT}Installation et Configuration de ${CVIOLET}APACHE${CVERT} terminée${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
