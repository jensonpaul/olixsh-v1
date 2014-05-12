###
# Configuration det installation du NTP
# ==============================================================================
# - Installation
# ------------------------------------------------------------------------------
# @package olixsh
# @subpackage install
# @author Olivier
# @created 24/08/2013
##

echo
echo -e "${CVIOLET} Configuration du NTP ${CVOID}"
echo -e "${CBLANC}===============================================================================${CVOID}"

apt-get --yes install ntp ntpdate
