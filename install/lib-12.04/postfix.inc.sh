###
# Installation et Configuration de POSTFIX
# ==============================================================================
# - Installation des APT
# - Lancement du configurateur
# - Modification du hostname
# ------------------------------------------------------------------------------
# OLIX_INSTALL_POSTFIX         : true pour l'installation
# OLIX_INSTALL_POSTFIX_APT     : Paquet à installer postfix ou sendmail
# POSTFIX_HOSTNAME : Hostname à utiliser pour la configuration postfix
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 04/05/2014
##



###
# Test si Postfix doit être installé
##
[[ "${OLIX_INSTALL_POSTFIX}" != "true" ]] && logger_warning "Installation de POSTFIX ignorée" && return


echo
echo -e "${CVIOLET} Configuration de POSTFIX ${CVOID}"
echo -e "${CBLANC}===============================================================================${CVOID}"

__PATH_CONFIG="${OLIX_INSTALL_PATH_CONFIG}/postfix"



###
# Installation
##
logger_debug "Installation des packages Postfix"
apt-get --yes install mailutils ${OLIX_INSTALL_POSTFIX_APT}



###
# Lancement du configurateur
##
echo -e "Configurer en mode ${CCYAN}Internet avec un smarthost${CVOID}"; sleep 3
dpkg-reconfigure postfix


###
# Modification du hostname
##
#echo -en "Modification du hostname ${CCYAN}${POSTFIX_HOSTNAME}${CVOID} : "; sleep 1
#sed -i "s/^myhostname = .*$/myhostname = ${POSTFIX_HOSTNAME}/g" /etc/postfix/main.cf > ${OLIX_ERROR_FILE} 2>&1
#if [ $? -ne 0 ]; then core_handlerError; fi
#echo -e "${CVERT}OK ...${CVOID}"
##echo "mydestination = spiderman, localhost.localdomain, localhost"
##echo "mynetworks = 127.0.0.0/8"
##echo "inet_interfaces = loopback-only"
#echo "-------------------------------------------------------------------------------"


###
# Redémarrage du service
##
logger_debug "Redémarrage du service Postfix"
service postfix restart

