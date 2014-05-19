###
# Librairies pour la gestion de rapport vide
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 16/05/2014
##



###
# Affiche un message d'en-tête de niveau 2
# @param $1     : Message
# @param $2..$9 : Valeur à inclure dans le message
##
function report_head1()
{
	logger_debug "report_head1 ($@)"
	echo >> ${OLIX_REPORT_FILENAME}
    echo -e " $(printf "$@")" >> ${OLIX_REPORT_FILENAME}
    echo -e "===============================================================================" >> ${OLIX_REPORT_FILENAME}
}


###
# Affiche un message d'en-tête de niveau 2
# @param $1 : Message
# @param $2 : Valeur à inclure dans le message
##
function report_head2()
{
	logger_debug "report_head2 ($1, $2)"
	echo >> ${OLIX_REPORT_FILENAME}
    echo -e " $(printf "$1" "$2")" >> ${OLIX_REPORT_FILENAME}
    echo -e "-------------------------------------------------------------------------------" >> ${OLIX_REPORT_FILENAME}
}



###
# Affiche le message d'information de retour d'un traitement
# @param $1 : Valeur de retour
# @param $2 : Message
# @param $3 : Message de retour
##
function report_messageReturn()
{
	logger_debug "report_messageReturn ($1, $2, $3)"
    echo -en $(stdout_strpad "$2" 64 "." " :") >> ${OLIX_REPORT_FILENAME}
    if [[ ! -z $3 ]]; then
    	[[ $1 -eq 0 ]] && echo -e " $3" >> ${OLIX_REPORT_FILENAME} || echo -e " ERROR" >> ${OLIX_REPORT_FILENAME}
    else
    	[[ $1 -eq 0 ]] && echo -e " OK" >> ${OLIX_REPORT_FILENAME} || echo -e " ERROR" >> ${OLIX_REPORT_FILENAME}
    fi
    return $1
}


###
# Affiche le contenu d'un fichier
# @param $1 : Valeur de retour
# @param $2 : Nom du fichier
##
function report_printFile()
{
    logger_debug "report_printFile ($1, $2)"
    cat $2 >> ${OLIX_REPORT_FILENAME}
    return $1
}