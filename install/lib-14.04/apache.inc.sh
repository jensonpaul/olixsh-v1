###
# Installation et configuration d'APACHE
# ==============================================================================
# - Installation des paquets APACHE
# - Installation de la clé privée
# - Activation des modules
# - Installation des fichiers de configuration
# ------------------------------------------------------------------------------
# OLIX_INSTALL_APACHE               : true pour l'installation
# OLIX_INSTALL_APACHE_SSL_KEY       : Clé privé du serveur
# OLIX_INSTALL_APACHE_MODULES       : Liste des modules apache à activer
# OLIX_INSTALL_APACHE_CONFIGS       : Liste des fichiers de configuration
# OLIX_INSTALL_APACHE_VHOST_DEFAULT : Site par défaut
# ------------------------------------------------------------------------------
# @modified 09/05/2014
# Ajout des variables OLIX_INSTALL_APACHE_SSL_KEY et OLIX_INSTALL_APACHE_CONFIGS
# Suppression des variables OLIX_INSTALL_APACHE_VHOST et OLIX_INSTALL_APACHE_FILECFG
# Installation de la clé privée
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 09/05/2014
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
# Installation de la clé privée
##
logger_debug "Installation de la clé privée"
if [[ ! -z ${OLIX_INSTALL_APACHE_SSL_KEY} ]]; then
	install_CopyConfiguration "${__PATH_CONFIG}/keys/${OLIX_INSTALL_APACHE_SSL_KEY}" "/etc/ssl/private" \
							  "Copie de la clé ${CCYAN}${OLIX_INSTALL_APACHE_SSL_KEY}${CVOID} vers /etc/ssl/private"
fi


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
logger_debug "Suppression de la conf actuelle"
rm -rf /etc/apache2/conf-enabled/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && logger_error
rm -rf /etc/apache2/conf-available/olix* > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && logger_error
for I in $(ls ${__PATH_CONFIG}/conf/olix*); do
	install_linkNodeConfiguration "$I" "/etc/apache2/conf-available/"
done
for I in ${OLIX_INSTALL_APACHE_CONFIGS}; do
	logger_debug "Activation de la conf $I"
	a2enconf $I > ${OLIX_LOGGER_FILE_ERR} 2>&1
	[[ $? -ne 0 ]] && logger_error
	echo -e "Activation de la conf ${CCYAN}$I${CVOID} : ${CVERT}OK ...${CVOID}"
done


###
# Activation du site par défaut
##
if [[ -n ${OLIX_INSTALL_APACHE_VHOST_DEFAULT} ]]; then
    install_backupFileOriginal "/etc/apache2/sites-available/000-default.conf"

    logger_debug "Effacement de /etc/apache2/sites-enabled/000-default.conf"
    rm -rf /etc/apache2/sites-enabled/000-default.conf > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error

    install_linkNodeConfiguration "${__PATH_CONFIG}/default/${OLIX_INSTALL_APACHE_VHOST_DEFAULT}" "/etc/apache2/sites-available/000-default.conf"

    logger_debug "Activation du site 000-default.conf"
    a2ensite 000-default.conf > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    echo -e "Activation du site ${CCYAN}default.conf${CVOID} : ${CVERT}OK ...${CVOID}"
fi


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
