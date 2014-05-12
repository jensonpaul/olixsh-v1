###
# Configuration det installation du NTP
# ==============================================================================
# - Installation
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 09/05/2014
##


echo
echo -e "${CVIOLET} Configuration du NTP ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"

apt-get --yes install ntp ntpdate
