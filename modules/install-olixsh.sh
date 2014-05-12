###
# Installation et configuration de olixsh dans le système
# ==============================================================================
# Mode intéractif
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 08/04/2014
##


###
# Paramètres par défaut
# - IO_PATH_DEST_CONFIG : Chemin de la configuration
# - IO_FILENAME_CONFIG  : Nom du fichier de config server
# - IO_MYSQL_HOST       : Host du serveur MySQL
# - IO_MYSQL_PORT       : Port du serveur MySQL
# - IO_MYSQL_USER       : Utilisateur du serveur MySQL
# - IO_MYSQL_PASS       : Mot de passe de l'utilisateur du serveur MySQL
##
IO_PATH_DEST_CONFIG="/home/projects/config"
IO_FILENAME_CONFIG=$(hostname -f).conf
IO_MYSQL_HOST="localhost"
IO_MYSQL_PORT="3306"
IO_MYSQL_USER="olix"
IO_MYSQL_PASS="olix52"



###
# Il faut être root
##
logger_debug "Test si root"
core_checkIfRoot
[ $? -ne 0 ] && logger_error "Seulement root peut executer l'installation d'oliXsh"


echo -e "${CVIOLET}Installation de oliXsh dans le système${CVOID}"
echo -e "${CBLANC}--------------------------------------${CVOID}"


###
# Demande du dossier où sera stocké la configuration
##
echo -en "Emplacement de la configuration ${CJAUNE}[${IO_PATH_DEST_CONFIG}]${CVOID} ? "
read REPONSE
[ ! -z ${REPONSE} ] && IO_PATH_DEST_CONFIG=${REPONSE}
[ ! -d ${IO_PATH_DEST_CONFIG} ] && mkdir -p ${IO_PATH_DEST_CONFIG}


###
# Création du fichier de configuration serveur lié au serveur
##
echo -en "Nom du fichier de configuration serveur en fonction du serveur ${CJAUNE}[${IO_FILENAME_CONFIG}]${CVOID} ? "
read REPONSE
[ ! -z ${REPONSE} ] && IO_FILENAME_CONFIG=${REPONSE}
if [ -f ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG} ]; then
    echo -e "Le fichier ${CCYAN}${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}${CVOID} existe déjà !"
    echo -en "Confirmer son écrasement ${CJAUNE}[o/N]${CVOID} ? "
    read REPONSE
else
    REPONSE="o"
fi


###
# Création du fichier de configuration serveur
##
if [[ "$REPONSE" == "o" ]]; then
	echo -e "${CBLANC}Demande d'information sur l'utilisateur mySQL permettant la gestion du serveur mySQL : ${CVOID}"
	echo -en "Host du serveur mySQL ${CJAUNE}[${IO_MYSQL_HOST}]${CVOID} ? "; read REPONSE
	[ ! -z ${REPONSE} ] && IO_MYSQL_HOST=${REPONSE}
	echo -en "Port du serveur mySQL ${CJAUNE}[${IO_MYSQL_PORT}]${CVOID} ? "; read REPONSE
	[ ! -z ${REPONSE} ] && IO_MYSQL_PORT=${REPONSE}
	echo -en "Nom de l'utilisateur du serveur mySQL ${CJAUNE}[${IO_MYSQL_USER}]${CVOID} ? "; read REPONSE
	[ ! -z ${REPONSE} ] && IO_MYSQL_USER=${REPONSE}
	echo -en "Mot de passe associé ${CJAUNE}[${IO_MYSQL_PASS}]${CVOID} ? "; read REPONSE
	[ ! -z ${REPONSE} ] && IO_MYSQL_PASS=${REPONSE}

	logger_info "Création du fichier ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}"
	logger_debug "Copie du fichier template/server.conf vers ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}"
    cp -f template/server.conf ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG} > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [ $? -ne 0 ] && logger_error "Impossible de créer le fichier ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}"

    logger_debug "Remplacement de la valeur NAME=${HOSTNAME}"
    sed -i "s/#NAME#/${HOSTNAME}/g" ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}
    [ $? -ne 0 ] && logger_error "Impossible de créer le fichier ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}"
    logger_debug "Remplacement de la valeur MYSQLHOST=${IO_MYSQL_HOST}"
    sed -i "s/#MYSQLHOST#/${IO_MYSQL_HOST}/g" ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}
    [ $? -ne 0 ] && logger_error "Impossible de créer le fichier ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}"
    logger_debug "Remplacement de la valeur MYSQLPORT=${IO_MYSQL_PORT}"
    sed -i "s/#MYSQLPORT#/${IO_MYSQL_PORT}/g" ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}
    [ $? -ne 0 ] && logger_error "Impossible de créer le fichier ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}"
    logger_debug "Remplacement de la valeur MYSQLUSER=${IO_MYSQL_USER}"
    sed -i "s/#MYSQLUSER#/${IO_MYSQL_USER}/g" ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}
    [ $? -ne 0 ] && logger_error "Impossible de créer le fichier ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}"
    logger_debug "Remplacement de la valeur MYSQLPASS=${IO_MYSQL_PASS}"
    sed -i "s/#MYSQLPASS#/${IO_MYSQL_PASS}/g" ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}
    [ $? -ne 0 ] && logger_error "Impossible de créer le fichier ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}"
fi


###
# Création de l'utilisateur MySQL pour la connexion automatique
##
if $(mysql_isRunning); then
    for I in 1 2 3; do
        echo -e "Création de l'utilisateur MySQL pour la connexion automatique"
        logger_debug "Execution de la requête GRANT ALL PRIVILEGES ON *.* TO '${IO_MYSQL_USER}'@'${IO_MYSQL_HOST}' IDENTIFIED BY '${IO_MYSQL_PASS}' WITH GRANT OPTION"
        echo -en "Mot de passe à la base avec l'utilisateur ${CCYAN}root${CVOID} "
        mysql_createRoleOliX "${IO_MYSQL_HOST}" "${IO_MYSQL_PORT}" "root" "${IO_MYSQL_USER}" "${IO_MYSQL_USER}"
        RET=$?
        [ $RET -eq 0 ] && break
    done
    [ $RET -ne 0 ] && logger_error "Impossible d'executer le requête"
fi

###
# Effectue un lien vers l'interpréteur olixsh depuis /bin/olixsh pour l'installation
##
logger_info "Création du lien ${OLIX_SHELL_LINK}"
ln -sf $(pwd)/${OLIX_SHELL_NAME} ${OLIX_SHELL_LINK} > ${OLIX_LOGGER_FILE_ERR} 2>&1
[ $? -ne 0 ] && logger_error "Impossible de créer le lien ${OLIX_SHELL_LINK}"


###
# Crée le fichier /etc/olix dans le système
##
logger_info "Création du fichier système de configuration ${OLIX_CONFIG_FILE}"
logger_debug "Suppression du fichier ${OLIX_CONFIG_FILE}"
rm -f ${OLIX_CONFIG_FILE} > ${OLIX_LOGGER_FILE_ERR} 2>&1
[ $? -ne 0 ] && logger_error "Erreur sur création du fichier ${OLIX_CONFIG_FILE}"
logger_debug "Création du fichier ${OLIX_CONFIG_FILE}"
touch ${OLIX_CONFIG_FILE} > ${OLIX_LOGGER_FILE_ERR} 2>&1
[ $? -ne 0 ] && logger_error "Erreur sur création du fichier ${OLIX_CONFIG_FILE}"
logger_debug "Ecriture de OLIX_CONFIG_PATH=${IO_PATH_DEST_CONFIG}"
echo "# Dossier de l'installation de la configuration" >> ${OLIX_CONFIG_FILE}
echo "OLIX_CONFIG_PATH=${IO_PATH_DEST_CONFIG}" >> ${OLIX_CONFIG_FILE}
logger_debug "Ecriture de OLIX_CONFIG_SERVER=${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}"
echo "# Chemin du dossier du fichier de configuration serveur" >> ${OLIX_CONFIG_FILE}
echo "OLIX_CONFIG_SERVER=${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG}" >> ${OLIX_CONFIG_FILE}


echo -e "${CVERT}L'installation s'est terminé avec succès${CVOID}"
echo -e "Le fichier ${IO_PATH_DEST_CONFIG}/${IO_FILENAME_CONFIG} a bien été créé et peut être complété"
