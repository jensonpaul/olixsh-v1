###
# Installation et configuration d'APACHE
# ==============================================================================
# - Installation des paquets APACHE
# - Installation de la clé privée
# - Activation des modules
# - Installation des fichiers de configuration
# ------------------------------------------------------------------------------
# OLIX_INSTALL_APACHE         : true pour l'installation
# OLIX_INSTALL_APACHE_SSL_KEY : Clé privé du serveur
# OLIX_INSTALL_APACHE_MODULES : Liste des modules apache à activer
# OLIX_INSTALL_APACHE_CONFIGS : Liste des fichiers de configuration
# ------------------------------------------------------------------------------
# @modified 09/05/2014
# Ajout des variables OLIX_INSTALL_APACHE_SSL_KEY et OLIX_INSTALL_APACHE_CONFIGS
# Suppression des variables OLIX_INSTALL_APACHE_VHOST et OLIX_INSTALL_APACHE_FILECFG
# Installation de la clé privée
# Suppression du site par défaut
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
for I in ${OLIX_INSTALL_APACHE_CONFIGS}; do
	install_linkNodeConfiguration "${__PATH_CONFIG}/conf/$I.conf" "/etc/apache2/conf-available/"
	logger_debug "Activation de la conf $I"
	a2enconf $I > ${OLIX_LOGGER_FILE_ERR} 2>&1
	[[ $? -ne 0 ]] && logger_error
	echo -e "Activation de la conf ${CCYAN}$I${CVOID} : ${CVERT}OK ...${CVOID}"
done


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