###
# Installation et Configuration de MySQL
# ==============================================================================
# - Installation des paquets MySQL
# - Déplacement des fichiers de l'instance
# - Installation des fichiers de configuration
# - Configuration des droits
# ------------------------------------------------------------------------------
# OLIX_INSTALL_MYSQL         : true pour l'installation
# OLIX_INSTALL_MYSQL_PATH    : Chemin des bases mysql
# OLIX_INSTALL_MYSQL_FILECFG : Fichier my.cnf à utiliser
# OLIX_INSTALL_MYSQL_SCRIPT  : Script sql d'affectation des privilèges
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 10/05/2014
##


###
# Paramètres
##
__PATH_CONFIG="${OLIX_INSTALL_PATH_CONFIG}/mysql"


###
# Test si APACHE doit être installé
##
[[ "${OLIX_INSTALL_MYSQL}" != "true" ]] && logger_warning "Installation de MYSQL ignorée" && return

echo
echo -e "${CVIOLET} Installation et Configuration de MYSQL ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"


###
# Installation
##
logger_debug "Installation des packages MYSQL"
apt-get --yes install mysql-server


###
# Déplacement des fichiers de l'instance
##
REPONSE="o"
if [ -d /home/mysql/mysql ]; then
    echo -e "${CBLANC}Création de l'instance MySQL${CVOID}"
    echo -en "${Cjaune}ATTENTION !!! L'instance existe déjà : Confirmer pour ECRASEMENT ${CJAUNE}[o/N]${CVOID} : "
    read REPONSE
fi
if [ "${REPONSE}" == "o" ]; then
    service mysql stop
    logger_debug "Suppression de /home/mysql"
    rm -rf /home/mysql > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    logger_debug "Création de /home/mysql"
    mkdir /home/mysql > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    logger_debug "Chown de /home/mysql"
    chown -R mysql:mysql /home/mysql > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    logger_debug "Copie de l'instance MySQL"
    cp -rp /var/lib/mysql/* /home/mysql > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    echo -e "Regenération de l'instance MySQL : ${CVERT}OK ...${CVOID}"
    service mysql start
fi


###
# Mise en place du fichier de configuration
##
install_linkNodeConfiguration "${__PATH_CONFIG}/${OLIX_INSTALL_MYSQL_FILECFG}" "/etc/mysql/conf.d/" \
                              "Mise en place de ${CCYAN}${OLIX_INSTALL_MYSQL_FILECFG}${CVOID} vers /etc/mysql/conf.d"

if [ -f /etc/apparmor.d/usr.sbin.mysqld ]; then
    logger_debug  "Désactivation du fichier de configuration appArmor"
    ln -sf /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/usr.sbin.mysqld > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
fi


###
# Redémarrage du service
##
logger_debug "Redémarrage du service MySQL"
service apparmor reload
service mysql restart


###
# Configuration des droits
##
logger_debug "Affectation des droits pour ${OLIX_CONF_SERVER_MYSQL_USER}"
echo -e "Mot de passe pour affectation des droits à ${CBLANC}${OLIX_CONF_SERVER_MYSQL_USER}${CVOID}"
echo "GRANT ALL PRIVILEGES ON *.* TO '${OLIX_CONF_SERVER_MYSQL_USER}'@'localhost' IDENTIFIED BY '${OLIX_CONF_SERVER_MYSQL_PASS}' WITH GRANT OPTION;" \
    | mysql -p > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && logger_error

logger_debug "Execution du script ${OLIX_INSTALL_MYSQL_SCRIPT}"
[[ ! -f ${__PATH_CONFIG}/${OLIX_INSTALL_MYSQL_SCRIPT} ]] && logger_error "Le fichier ${__PATH_CONFIG}/${OLIX_INSTALL_MYSQL_SCRIPT} n'existe pas"
cat ${__PATH_CONFIG}/${OLIX_INSTALL_MYSQL_SCRIPT} \
    | mysql --user=${OLIX_CONF_SERVER_MYSQL_USER} --password=${OLIX_CONF_SERVER_MYSQL_PASS} \
    > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && logger_error
echo -e "Affectation des privilèges :  ${CVERT}OK ...${CVOID}"


###
# Fin
##
echo -e "${CVERT}Installation et Configuration de ${CVIOLET}MYSQL${CVERT} terminée${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
