###
# Installation et Configuration de FTP
# ==============================================================================
# - Installation des paquets PUREFTPD
# - Modification de base de pureftpd
# - Modification de la configuration de pureftpd
# - Création des utilisateurs virtuels
# ------------------------------------------------------------------------------
# OLIX_INSTALL_FTP           : true pour l'installation
# OLIX_INSTALL_FTP_CONFIG[x] : Configuration de pure-ftpd avec nom du parametre = valeur. Exemple : "MinUID=1110"
# OLIX_INSTALL_FTP_USERS[x]  : Création des utilisateurs virtuels Exemple : "otop -u otop -g users -d /home/otop"
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 04/05/2014
##


###
# Paramètres
##
__PATH_CONFIG="${OLIX_INSTALL_PATH_CONFIG}/ftp"


###
# Test si FTP doit être installé
##
[[ "${OLIX_INSTALL_FTP}" != "true" ]] && logger_warning "Installation de FTP ignorée" && return

echo
echo -e "${CVIOLET} Installation et Configuration de FTP ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"


###
# Installation
##
logger_debug "Installation des packages FTP"
apt-get --yes install pure-ftpd


###
# Modification de base
##
logger_debug "Modification du VirtualChRoot dans /etc/default/pure-ftpd-common"
sed -i "s/^VIRTUALCHROOT=.*$/VIRTUALCHROOT=true/g" /etc/default/pure-ftpd-common > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && logger_error

# Activation de PureDB
logger_debug "Suppression de /etc/pure-ftpd/auth/75puredb"
rm -f /etc/pure-ftpd/auth/75puredb > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && logger_error
logger_debug "Activation de la base puredb pour les utilisateurs virtuels"
PWDTMP=`pwd`
cd /etc/pure-ftpd/auth
ln -sf ../conf/PureDB 75puredb > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && logger_error
cd ${PWDTMP}


###
# Modification de la configuration de pureftpd
##
for I in $(seq 1 $((${#OLIX_INSTALL_FTP_CONFIG[@]}))); do
    PARAM=${OLIX_INSTALL_FTP_CONFIG[$I]%%=*}
    VALUE=${OLIX_INSTALL_FTP_CONFIG[$I]##*=}
    logger_debug "Paramètre $VALUE dans /etc/pure-ftpd/conf/${PARAM}"
    echo $VALUE > /etc/pure-ftpd/conf/${PARAM} 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_error
    echo -e "Modification du paramètre ${CCYAN}${PARAM}${CVOID} = ${CCYAN}${VALUE}${CVOID} : ${CVERT}OK ...${CVOID}"
done


###
# Création des utilisateurs virtuels
##
for I in $(seq 1 $((${#OLIX_INSTALL_FTP_USERS[@]}))); do
    UTILISATEUR=${OLIX_INSTALL_FTP_USERS[$I]%% *}
    COMMAND=${OLIX_INSTALL_FTP_USERS[$I]}
    logger_debug "Test si ${UTILISATEUR} existe"
    if pure-pw show ${UTILISATEUR} > /dev/null 2>&1; then
        logger_debug "pure-pw usermod ${COMMAND}"
        pure-pw usermod ${COMMAND} -m 2> ${OLIX_LOGGER_FILE_ERR}
        [[ $? -ne 0 ]] && logger_error
        echo -e "Création de l'utilisateur ${CCYAN}${UTILISATEUR}${CVOID} : ${CBLEU}Déjà créé ...${CVOID}"
    else
        logger_debug "pure-pw useradd ${COMMAND}"
        echo -e "Initialisation du mot de passe de ${CCYAN}${UTILISATEUR}${CVOID}"
        pure-pw useradd ${COMMAND} -m 2> ${OLIX_LOGGER_FILE_ERR}
        [[ $? -ne 0 ]] && logger_error
        echo -e "Création de l'utilisateur ${CCYAN}${UTILISATEUR}${CVOID} : ${CVERT}OK ...${CVOID}"
    fi
done


###
# Redémarrage du service
##
logger_debug "Redémarrage du service FTP"
service pure-ftpd restart


###
# Fin
##
echo -e "${CVERT}Installation et Configuration de ${CVIOLET}FTP${CVERT} terminée${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
