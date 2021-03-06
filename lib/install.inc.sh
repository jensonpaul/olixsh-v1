###
# Librairies pour l'installation du serveur Ubuntu
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 10/04/2014
##


OLIX_INSTALL_UBUNTU_VERSION_RELEASE=$(lsb_release -sr)
OLIX_INSTALL_PATH_CONFIG=${OLIX_CONFIG_PATH}/install/${OLIX_INSTALL_UBUNTU_VERSION_RELEASE}
OLIX_INSTALL_PATH_CONFIG_FILE=${OLIX_INSTALL_PATH_CONFIG}/${OLIX_CONF_SERVER_INSTALL}
OLIX_INSTALL_PACKAGES_LIST="apache php mysql ftp samba nfs postfix collectd logwatch monit snmpd tools"


###
# Vérifie et charge le fichier de conf de l'installation du serveur
##
function install_loadConfiguration()
{
    logger_debug "install_loadConfiguration ()"
    logger_debug "Vérification de la présence de fichier de conf ${OLIX_INSTALL_PATH_CONFIG_FILE}"
    if [[ ! -r ${OLIX_INSTALL_PATH_CONFIG_FILE} ]]; then
        logger_warning "${OLIX_INSTALL_PATH_CONFIG_FILE} absent"
        logger_error "Impossible de charger le fichier de configuration ${OLIX_INSTALL_PATH_CONFIG_FILE}"
    fi

    logger_debug "Chargement de ${OLIX_INSTALL_PATH_CONFIG_FILE}"
    source ${OLIX_INSTALL_PATH_CONFIG_FILE}
}


###
# Verifie si un package fait partie de la liste installable
# @param $1 : Nom du package à vérifier
##
function install_isPackage()
{
    logger_debug "install_isPackage ($1)"
	[[ "|${OLIX_INSTALL_PACKAGES_LIST// /|}|" =~ "|$1|" ]] && return 0
	return 1
}


###
# Affiche le menu du choix des packages
##
function install_printChoicePackage()
{
    logger_debug "install_printChoicePackage ()"
	echo
    echo -e "${CVIOLET} Menu du choix de l'application à configurer${CVOID}"
    echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
    echo -e "${CJAUNE} all${CVOID}        : ${CBLANC}Configuration complète${CVOID}"
    echo -e "${CJAUNE} apache${CVOID}     : Installation et configuration d'Apache"
    echo -e "${CJAUNE} php${CVOID}        : Installation et configuration des modules PHP"
    echo -e "${CJAUNE} mysql${CVOID}      : Installation et configuration du MySQL"
    echo -e "${CJAUNE} nfs${CVOID}        : Installation et configuration du partage NFS"
    echo -e "${CJAUNE} samba${CVOID}      : Installation et configuration du partage Samba"
    echo -e "${CJAUNE} ftp${CVOID}        : Installation et configuration du serveur FTP"
    echo -e "${CJAUNE} postfix${CVOID}    : Installation et configuration du transport de mail"
    echo -e "${CJAUNE} collectd${CVOID}   : Installation et configuration des stats serveur"
    echo -e "${CJAUNE} logwatch${CVOID}   : Installation et configuration d'analyseur de log"
    echo -e "${CJAUNE} monit${CVOID}      : Installation et configuration du monitoring"
    echo -e "${CJAUNE} snmpd${CVOID}      : Installation et configuration du protocol de gestion du réseau"
    echo -e "${CJAUNE} tools${CVOID}      : Installation d'outils supplémentaire"
    echo -e "${CJAUNE} quit${CVOID}       : Quitter"
    echo -en "${Cjaune}Ton choix ${CJAUNE}[quit]${CVOID} : "
}


###
# Crée un lien avec mon fichier de configuration
# @param $1 : Fichier de configuration à lier
# @param $2 : Lien de destination
# @param $3 : Message
##
function install_linkNodeConfiguration()
{
    logger_debug "install_linkNodeConfiguration ($1, $2, $3)"
    # Si on ne choisit pas le mode par lien symbolique
    if [[ "${OLIX_INSTALL_MODE_CONFIG}" != "symlink" ]]; then
        install_CopyConfiguration "$1" "$2" "$3"
        return 0
    fi
    [[ ! -f $1 ]] && logger_error "Le fichier $1 n'existe pas"
    ln -sf $1 $2 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    [[ ! -z $3 ]] && echo -e "$3 : ${CVERT}OK ...${CVOID}"
    return 0
}


###
# Copie un fichier de configuration dans son emplacement
# @param $1 : Fichier de configuration à lier
# @param $2 : Lien de destination
# @param $3 : Message
##
function install_CopyConfiguration()
{
    logger_debug "install_CopyConfiguration ($1, $2, $3)"
    [[ ! -f $1 ]] && logger_error "Le fichier $1 n'existe pas"
    cp $1 $2 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    [[ ! -z $3 ]] && echo -e "$3 : ${CVERT}OK ...${CVOID}"
    return 0
}


###
# Sauvegarde le fichier de configuration original
# @param $1 : Fichier à conserver
##
function install_backupFileOriginal()
{
    logger_debug "install_backupFileOriginal ($1)"
    local ORIGINAL="$1.original"
    if [ ! -f ${ORIGINAL} ]; then
        logger_debug "Sauvegarde de l'original $1"
        cp $1 ${ORIGINAL} > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_error "Impossible de sauvegarder $1"
    fi
    logger_debug "Effacement de l'ancien fichier"
    rm -f $1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error "Impossible d'effacer $1"
    logger_debug "Remise de l'original de $1"
    cp ${ORIGINAL} $1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error "Impossible de remettre l'original $1"
}
