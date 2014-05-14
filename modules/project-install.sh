###
# Installation d'un projet
# ==============================================================================
# - Installation des paquets additionnels
# - Installation des fichiers
# - Installation de la base
# - Installation des fichiers systèmes
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 12/05/2014
##


source lib/project.inc.sh
source lib/install.inc.sh


###
# Il faut être root
##
logger_debug "Test si root"
core_checkIfRoot
[ $? -ne 0 ] && logger_error "Seulement root peut executer l'installation d'oliXsh"



###
# Chargement du fichier de conf
##
project_checkArguments
project_loadConfiguration ${OLIX_PROJECT_CODE}



###
# Traitement
##
echo -en "${CROUGE}ATTENTION !!! ${CVOID}${Cjaune}Cela va écraser toutes les données actuelles (fichiers + base) : Confirmer ${CVOID}${CJAUNE}[o/N]${CVOID} "
read REPONSE
[ "$REPONSE" != "o" ] && return 0



###
# Installation de paquets additionnels
##
echo
echo -e "${CVIOLET} Installation de paquets additionnels ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
if [[ ! -z ${OLIX_CONF_PROJECT_INSTALL_APT} ]]; then
	logger_debug "apt-get install ${OLIX_CONF_PROJECT_INSTALL_APT}"
	sudo apt-get --yes install ${OLIX_CONF_PROJECT_INSTALL_APT}
	[[ $? -ne 0 ]] && logger_error
fi



###
# Installation via la synchronisation du dossier 
##
echo
echo -e "${CVIOLET} Copie des fichiers dans ${CCYAN}${OLIX_CONF_PROJECT_PATH}${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"

stdinout_readConnexionServerSSH ${OLIX_PROJECT_CODE}

filesystem_synchronize "${OLIX_STDINOUT_SERVER_PORT}" \
                       "${OLIX_STDINOUT_SERVER_USER}@${OLIX_STDINOUT_SERVER_HOST}:${OLIX_STDINOUT_SERVER_PATH}" \
                       "${OLIX_CONF_PROJECT_PATH}" \
                       "${OLIX_CONF_PROJECT_INSTALL_FILE_EXCLUDE}"
[[ $? -ne 0 ]] && logger_error



###
# Installation des bases de données
##
for I in ${OLIX_CONF_PROJECT_MYSQL_BASE}; do
	echo
	echo -e "${CVIOLET} Installation de la base ${CCYAN}${I}${CVOID}"
	echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"

	OLIX_STDINOUT_SERVER_BASE="${I}"
	stdinout_readConnexionServerMySQL "${OLIX_PROJECT_CODE}.${I}"

    mysql_dropDatabase "${I}"
    [[ $? -ne 0 ]] && logger_error "Impossible de supprimer la base $I"

    mysql_createDatabase "${I}"
    [[ $? -ne 0 ]] && logger_error "Impossible de créer la base $I"

    mysql_createRole "${OLIX_CONF_PROJECT_MYSQL_USER}" "${OLIX_CONF_PROJECT_MYSQL_PASS}" "${I}"
    [[ $? -ne 0 ]] && logger_error "Impossible de créer le role de {OLIX_CONF_PROJECT_MYSQL_USER} sur $I"
    echo -e "Création de la base : ${CVERT}OK ...${CVOID}"

    [[ "|${OLIX_CONF_PROJECT_INSTALL_BASE_EXCLUDE// /|}|" =~ "|${I}|" ]] && continue

    mysql_synchronizeDatabase "${OLIX_STDINOUT_SERVER_HOST}" "${OLIX_STDINOUT_SERVER_PORT}" \
    						  "${OLIX_STDINOUT_SERVER_USER}" "${OLIX_STDINOUT_SERVER_BASE}" "${I}"
    [[ $? -ne 0 ]] && logger_error "Impossible de synchroniser la base $I"
done



###
# Installation système
##
echo
echo -e "${CVIOLET} Installation des fichiers de configuration${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"

# Installation du fichier LOGROTATE
__FILE_CONF=$(project_getFileConf "${OLIX_PROJECT_PATH_CONFIG}/logrotate")
if [[ -z ${__FILE_CONF} ]]; then
	logger_warning "Pas de configuration trouvée pour logrotate"
else
	install_linkNodeConfiguration "${__FILE_CONF}" "/etc/logrotate.d/${OLIX_PROJECT_CODE}" \
								  "Mise en place de ${CCYAN}$(basename $__FILE_CONF)${CVOID} vers /etc/logrotate.d"
fi

# Installation des fichiers CRONTAB
__FILE_CONF=$(project_getFileConf "${OLIX_PROJECT_PATH_CONFIG}/crontab")
if [[ -z ${__FILE_CONF} ]]; then
	logger_warning "Pas de configuration trouvée pour crontab"
else
	install_CopyConfiguration "${__FILE_CONF}" "/etc/cron.d/${OLIX_PROJECT_CODE}" \
							  "Mise en place de ${CCYAN}$(basename $__FILE_CONF)${CVOID} vers /etc/cron.d"
fi

# Installation du vhost
__FILE_CONF=$(project_getFileConf "${OLIX_PROJECT_PATH_CONFIG}/vhost" ".conf")
if [[ -z ${__FILE_CONF} ]]; then
	logger_warning "Pas de configuration trouvée pour le Virtual Host"
else
	install_linkNodeConfiguration "${__FILE_CONF}" "/etc/apache2/sites-available/${OLIX_PROJECT_CODE}"
	logger_debug "Activation du site ${OLIX_PROJECT_CODE}"
	a2ensite ${OLIX_PROJECT_CODE} > ${OLIX_LOGGER_FILE_ERR} 2>&1
	[[ $? -ne 0 ]] && logger_error
	echo -e "Activation du site ${CCYAN}$(basename $__FILE_CONF)${CVOID} : ${CVERT}OK ...${CVOID}"

	logger_debug "Redémarrage du Apache"
	service apache2 reload
fi



###
# FIN
##
echo
echo -e "${CVERT}Installation de ${CVIOLET}${OLIX_PROJECT_CODE}${CVERT} terminée${CVOID}"
