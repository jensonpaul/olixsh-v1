###
# Mise à jour du système
# ==============================================================================
# - Update des sources
# - Upgrade des packages
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 09/05/2014
##


echo
echo -e "${CVIOLET} Mise à jour du système ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"

logger_debug "Mise à jour des dépôts"
apt-get update
[[ $? -ne 0 ]] && logger_error "Update des dépôts"

logger_debug "Mise à jour des packages"
apt-get --yes upgrade
[[ $? -ne 0 ]] && logger_error "Update des packages"
