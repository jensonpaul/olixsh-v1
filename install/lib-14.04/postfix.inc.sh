###
# Installation et Configuration de POSTFIX
# ==============================================================================
# - Installation des APT
# - Lancement du configurateur
# - Modification du hostname
# ------------------------------------------------------------------------------
# OLIX_INSTALL_POSTFIX     : true pour l'installation
# OLIX_INSTALL_POSTFIX_APT : Paquet à installer postfix ou sendmail
# ------------------------------------------------------------------------------
# @modified 11/05/2014
# Plus besoin de changer le hostname du postix : utilisation du FQDN du système
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 11/05/2014
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
#echo -e "Configurer en mode ${CCYAN}Internet avec un smarthost${CVOID}"; sleep 3
#dpkg-reconfigure postfix


###
# Redémarrage du service
##
logger_debug "Redémarrage du service Postfix"
service postfix restart

