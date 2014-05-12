###
# Installation et configuration de PHP
# ==============================================================================
# - Installation des paquets PHP
# - Installation des fichiers de configuration
# ------------------------------------------------------------------------------
# OLIX_INSTALL_PHP         : true pour l'installation
# OLIX_INSTALL_PHP_MODULES : Liste des modules php à installer
# OLIX_INSTALL_PHP_FILECFG : Fichier php.ini à utiliser
# ------------------------------------------------------------------------------
# @modified 10/05/2014
# conf dans /etc/php5/apache2/conf.d ET etc/php5/cli/conf.d au lieu de etc/php5/conf.d 
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 10/05/2014
##


###
# Paramètres
##
__PATH_CONFIG="${OLIX_INSTALL_PATH_CONFIG}/php"


###
# Test si PHP doit être installé
##
[[ "${OLIX_INSTALL_PHP}" != "true" ]] && logger_warning "Installation de PHP ignorée" && return

echo
echo -e "${CVIOLET} Installation et Configuration de PHP ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"


###
# Installation
##
logger_debug "Installation des packages PHP"
apt-get --yes install libapache2-mod-php5 php5 ${OLIX_INSTALL_PHP_MODULES}


###
# Mise en place du fichier de configuration
##
install_linkNodeConfiguration "${__PATH_CONFIG}/${OLIX_INSTALL_PHP_FILECFG}" "/etc/php5/apache2/conf.d/"
install_linkNodeConfiguration "${__PATH_CONFIG}/${OLIX_INSTALL_PHP_FILECFG}" "/etc/php5/cli/conf.d/"
echo -e "Activation de la conf ${CCYAN}${OLIX_INSTALL_PHP_FILECFG}${CVOID} : ${CVERT}OK ...${CVOID}"


###
# Redémarrage du service
##
logger_debug "Redémarrage du service APACHE"
service apache2 restart


###
# Fin
##
echo -e "${CVERT}Installation et Configuration de ${CVIOLET}PHP${CVERT} terminée${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
