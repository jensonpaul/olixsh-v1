###
# Installation des fichiers de configuration
# ==============================================================================
# Mode intéractif uniquement
# Installation des fichiers de configuration dans le dossier désiré
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 09/04/2014
##


###
# Demande des infos de connexion du serveur où se trouve la config et copie les fichiers
##
echo -e "${CBLANC}Demande d'information sur le serveur où se trouve la configuration${CVOID}"
while true; do

	echo -en "Emplacement source de la configuration ${CJAUNE}[${OLIX_CONF_SERVER_INSTALL_REMOTE_CONF}]${CVOID} ? "
	read REPONSE
	[[ ! -z ${REPONSE} ]] && OLIX_CONF_SERVER_INSTALL_REMOTE_CONF=${REPONSE}
	logger_debug "Emplacement de la conf : ${OLIX_CONF_SERVER_INSTALL_REMOTE_CONF}"

	echo -e "Synchronisation depuis ${CCYAN}${OLIX_CONF_SERVER_INSTALL_REMOTE_CONF}${CVOID} vers ${CCYAN}${OLIX_CONFIG_PATH}${CVOID} :"
	filesystem_synchronize "${OLIX_CONF_SERVER_INSTALL_REMOTE_PORT}" "${OLIX_CONF_SERVER_INSTALL_REMOTE_CONF}" "${OLIX_CONFIG_PATH}"
	[[ $? -eq 0 ]] && break;
done


echo -e "${CVERT}L'installation de la configuration s'est terminé avec succès${CVOID}"