###
# Module de test
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 22/05/2014
##

source lib/project.inc.sh

TOTO=$(project_getFileConf "/home/projects/config/project/zoom/vhost" ".conf")

echo " --> $TOTO"