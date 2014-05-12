###
# Installation et configuration des TOOLS
# ==============================================================================
# - Installation des paquets TOOLS
# - Installation des fichiers de crontab
# ------------------------------------------------------------------------------
# OLIX_INSTALL_TOOLS_APT       : Liste des packets à intaller
# OLIX_INSTALL_TOOLS_CRONTAB   : Fichier de conf pour les taches planifiées
# OLIX_INSTALL_TOOLS_LOGROTATE : Fichier de conf pour la rotation de log
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 06/05/2014
##


###
# Paramètres
##
__PATH_CONFIG="${OLIX_INSTALL_PATH_CONFIG}/tools"


echo
echo -e "${CVIOLET} Installation et Configuration de TOOLS ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"


###
# Installation
##
logger_debug "Installation des packages TOOLS"
apt-get --yes install ${OLIX_INSTALL_TOOLS_APT}


###
# Installation des fichiers LOGROTATE
##
if [ -n "${OLIX_INSTALL_TOOLS_LOGROTATE}" ]; then
	install_linkNodeConfiguration "${__PATH_CONFIG}/${OLIX_INSTALL_TOOLS_LOGROTATE}" "/etc/logrotate.d/" \
								  "Mise en place de ${CCYAN}${OLIX_INSTALL_TOOLS_LOGROTATE}${CVOID} vers /etc/logrotate.d"
fi


###
# Installation des fichiers CRONTAB
##
if [ -n "${OLIX_INSTALL_TOOLS_CRONTAB}" ]; then
	logger_debug "Copie de ${__PATH_CONFIG}/${OLIX_INSTALL_TOOLS_CRONTAB} vers /etc/cron.d/"
    [[ ! -f ${__PATH_CONFIG}/${OLIX_INSTALL_TOOLS_CRONTAB} ]] && logger_error "Le fichier ${__PATH_CONFIG}/${OLIX_INSTALL_TOOLS_CRONTAB} n'existe pas"
    cp ${__PATH_CONFIG}/${OLIX_INSTALL_TOOLS_CRONTAB} /etc/cron.d/ > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    [[ ! -z $3 ]] && echo -e "Mise en place de ${CCYAN}${OLIX_INSTALL_TOOLS_CRONTAB}${CVOID} vers /etc/cron.d : ${CVERT}OK ...${CVOID}"
fi


###
# Fin
##
echo -e "${CVERT}Installation et Configuration de ${CVIOLET}TOOLS${CVERT} terminée${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"

