###
# Installation et Configuration des applications
# ==============================================================================
# - Configuration d'Apache
# - Installation et configuration des modules PHP
# - Configuration de MySQL
# - Configuration du partage NFS
# - Configuration du partage Samba
# - Configuration du serveur FTP
# - Configuration du transport de mail
# - Configuration du monitoring
# - Tuning du système
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 02/05/2014
##


source lib/install.inc.sh


###
# Il faut être root
##
logger_debug "Test si root"
core_checkIfRoot
[ $? -ne 0 ] && logger_error "Seulement root peut executer l'installation d'oliXsh"


###
# Chargement du fichier de conf pour l'installation
##
install_loadConfiguration


###
# Si Package dans l'argument
##
if [[ ! -z "${OLIX_ARGS}" ]]; then

	OLIX_ARGS=$(echo "${OLIX_ARGS}" | sed -e 's/^ *//' -e 's/ *$//')

	if [[ ${OLIX_ARGS} == "all" ]]; then

		# Installation de tous les packages
		for I in ${OLIX_INSTALL_PACKAGES_LIST}; do
			logger_debug "Installation du package ${I}"
			source install/lib-${OLIX_INSTALL_UBUNTU_VERSION_RELEASE}/${I}.inc.sh
		done

	else

		# Installation du et des packages demandés
		for I in ${OLIX_ARGS}; do
			install_isPackage ${I}
			if [[ $? -eq 0 ]]; then
				logger_debug "Installation du package ${I}"
				source install/lib-${OLIX_INSTALL_UBUNTU_VERSION_RELEASE}/${I}.inc.sh
			else
				logger_warning "Le package ${I} n'existe pas"
			fi
		done

	fi

	core_exit 0
fi


###
# Sinon affiche le menu
##
while true; do
    install_printChoicePackage
    read PACKAGE
    case ${PACKAGE} in
        all)	for I in ${OLIX_INSTALL_PACKAGES_LIST}; do
					logger_debug "Installation du package ${I}"
					source install/lib-${OLIX_INSTALL_UBUNTU_VERSION_RELEASE}/${I}.inc.sh
				done
				;;
        quit)   break
				;;
	    *)      if [[ "${PACKAGE}" == "" ]]; then
					break
				else
					install_isPackage ${PACKAGE}
					if [[ $? -eq 0 ]]; then
						logger_debug "Installation du package ${PACKAGE}"
						source install/lib-${OLIX_INSTALL_UBUNTU_VERSION_RELEASE}/${PACKAGE}.inc.sh
					fi
				fi
				;;
	esac
done