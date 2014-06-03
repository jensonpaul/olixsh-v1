###
# Librairies pour la gestion de rapport vide
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 16/05/2014
##


###
# En tête du rapport
##
report_printHeader()
{
    logger_debug "report_printHeader ()"
    echo '<!DOCTYPE html>' >> ${OLIX_REPORT_FILENAME}
    echo '<html>' >> ${OLIX_REPORT_FILENAME}
    echo '<head>' >> ${OLIX_REPORT_FILENAME}
    echo '<meta charset="UTF-8">' >> ${OLIX_REPORT_FILENAME}
    echo '</head>' >> ${OLIX_REPORT_FILENAME}
    echo '<body>' >> ${OLIX_REPORT_FILENAME}
}


###
# Pied de page du rapport
##
report_printFooter()
{
    logger_debug "report_printFooter ()"
    echo '</body>' >> ${OLIX_REPORT_FILENAME}
    echo '</html>' >> ${OLIX_REPORT_FILENAME}
}


###
# Affiche un message d'en-tête de niveau 2
# @param $1     : Message
# @param $2..$9 : Valeur à inclure dans le message
##
function report_printHead1()
{
    local MSG=$1
    shift
    logger_debug "report_printHead1 ($MSG, $*)"
    echo "<h1 style=\"font-family:'Courier New',monospace; font-weight:500; line-height:1.1; font-size:1.8em; padding-bottom:10px; border-bottom:2px solid;\">" >> ${OLIX_REPORT_FILENAME}
    echo "$(printf "$MSG" "<em style=\"color:purple;font-style:normal;\">$1</em>" "<em style=\"color:purple;font-style:normal;\">$2</em>" "<em style=\"color:purple;font-style:normal;\">$3</em>")</h1>" >> ${OLIX_REPORT_FILENAME}
}


###
# Affiche un message d'en-tête de niveau 2
# @param $1 : Message
# @param $2 : Valeur à inclure dans le message
##
function report_printHead2()
{
	logger_debug "report_printHead2 ($1, $2)"
    echo "<h2 style=\"font-family:"Courier New",monospace; font-weight:500; line-height:1.1; font-size:1.3em; padding-bottom:7px; border-bottom:1px solid;\">" >> ${OLIX_REPORT_FILENAME}
    echo "$(printf "$1" "<em style=\"color:purple;font-style:normal;\">$2</em>")</h2>" >> ${OLIX_REPORT_FILENAME}
}


###
# Afficher une ligne
##
function report_printLine()
{
    logger_debug "report_printLine ()"
    echo "<hr style=\"border-top:1px solid black; border-bottom:none; border-left:none; border-right:none;\">" >> ${OLIX_REPORT_FILENAME}
}


###
# Affiche un message standard
# @param $1 : Message à afficher
# @param $2 : Style CSS
##
function report_print()
{
    logger_debug "report_print ($1,$2)"
    echo "<p style=\"font-family:'Courier New',monospace;margin:0;padding:0;$2\">$1</p>" >> ${OLIX_REPORT_FILENAME}
}


###
# Affiche le message d'information de retour d'un traitement
# @param $1 : Valeur de retour
# @param $2 : Message
# @param $3 : Message de retour
##
function report_printMessageReturn()
{
	logger_debug "report_printMessageReturn ($1, $2, $3)"
    echo -n "<p style=\"font-family:'Courier New',monospace;margin:0;padding:0;\">" >> ${OLIX_REPORT_FILENAME}
    echo -n $(stdout_strpad "$2" 64 "." " :") >> ${OLIX_REPORT_FILENAME}
    if [[ $1 -ne 0 ]]; then
        echo -n ' <b style="color:red">ERROR</b>' >> ${OLIX_REPORT_FILENAME}
    elif [[ -z $3 ]]; then
        echo -n ' <b style="color:green">OK</b>' >> ${OLIX_REPORT_FILENAME}
        [[ ! -z $4 ]] && echo " <i style=\"color:green\">($4s)</i>" >> ${OLIX_REPORT_FILENAME} || echo  >> ${OLIX_REPORT_FILENAME}
    else
        echo -n " <b style=\"color:green\">$3</b>" >> ${OLIX_REPORT_FILENAME}
        [[ ! -z $4 ]] && echo " <i style=\"color:green\">($4s)</i>" >> ${OLIX_REPORT_FILENAME} || echo  >> ${OLIX_REPORT_FILENAME}
    fi
    echo '</p>' >> ${OLIX_REPORT_FILENAME}
    return $1
}


###
# Affiche un message d'information simple
# @param $1 : Message
# @param $2 : Valeur
##
function report_printInfo()
{
    logger_debug "report_printInfo ($1, $2)"
    echo -n "<p style=\"font-family:'Courier New',monospace;margin:0;padding:0;\">" >> ${OLIX_REPORT_FILENAME}
    echo -n $(stdout_strpad "$1" 64 "." " :") >> ${OLIX_REPORT_FILENAME}
    echo " <b style=\"color:blue\">$2</b></p>" >> ${OLIX_REPORT_FILENAME}
}


###
# Affiche le contenu d'un fichier
# @param $1 : Nom du fichier
# @param $2 : Style CSS
##
function report_printFile()
{
    logger_debug "report_printFile ($1, $2)"
    echo "<p style=\"font-family:'Courier New',monospace; margin:0; padding:0;$2\">" >> ${OLIX_REPORT_FILENAME}
    while IFS='\n' read LINE; do
        echo "$LINE<br>" >> ${OLIX_REPORT_FILENAME}
    done < <(cat $1)
    echo '</p>' >> ${OLIX_REPORT_FILENAME}
}
