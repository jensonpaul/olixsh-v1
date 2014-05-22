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
    echo '<style>' >> ${OLIX_REPORT_FILENAME}
    echo 'body { font-family:"Courier New",monospace; }' >> ${OLIX_REPORT_FILENAME}
    echo 'p { margin:0; padding:0; }' >> ${OLIX_REPORT_FILENAME}
    echo 'h1 { font-family:inherit; font-weight:500; line-height:1.1; font-size:1.8em; padding-bottom:10px; border-bottom:2px solid; }' >> ${OLIX_REPORT_FILENAME}
    echo 'h2 { font-family:inherit; font-weight:500; line-height:1.1; font-size:1.3em; padding-bottom:7px; border-bottom:1px solid; }' >> ${OLIX_REPORT_FILENAME}
    echo 'hr { border-top:1px solid black; border-bottom:none; border-left:none; border-right:none; }' >> ${OLIX_REPORT_FILENAME}
    echo 'em { color:purple; font-style:normal; }' >> ${OLIX_REPORT_FILENAME}
    echo '.ok { color:green; }' >> ${OLIX_REPORT_FILENAME}
    echo '.error { color:red; }' >> ${OLIX_REPORT_FILENAME}
    echo '.info { color:blue; }' >> ${OLIX_REPORT_FILENAME}
    echo '.return { font-weight:bold; }' >> ${OLIX_REPORT_FILENAME}
    echo '.time { font-style:italic; }' >> ${OLIX_REPORT_FILENAME}
    echo '</style>' >> ${OLIX_REPORT_FILENAME}
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
    echo
    echo "<h1>$(printf "$MSG" "<em>$1</em>" "<em>$2</em>" "<em>$3</em>")</h1>" >> ${OLIX_REPORT_FILENAME}
}


###
# Affiche un message d'en-tête de niveau 2
# @param $1 : Message
# @param $2 : Valeur à inclure dans le message
##
function report_printHead2()
{
	logger_debug "report_printHead2 ($1, $2)"
	echo >> ${OLIX_REPORT_FILENAME}
    echo "<h2>$(printf "$1" "<em>$2</em>")</h2>" >> ${OLIX_REPORT_FILENAME}
}


###
# Afficher une ligne
##
function report_printLine()
{
    logger_debug "report_printLine ()"
    echo "<hr>" >> ${OLIX_REPORT_FILENAME}
}


###
# Affiche un message standard
# @param $1 : Message à afficher
##
function report_print()
{
    logger_debug "report_print ($1)"
    echo $1 >> ${OLIX_REPORT_FILENAME}
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
    echo -n "<p>" >> ${OLIX_REPORT_FILENAME}
    echo -n $(stdout_strpad "$2" 64 "." " :") >> ${OLIX_REPORT_FILENAME}
    if [[ $1 -ne 0 ]]; then
        echo -n ' <span class="return error">ERROR</span>' >> ${OLIX_REPORT_FILENAME}
    elif [[ -z $3 ]]; then
        echo -n ' <span class="return ok">OK</span>' >> ${OLIX_REPORT_FILENAME}
        [[ ! -z $4 ]] && echo " <span class=\"time ok\">($4s)</span>" >> ${OLIX_REPORT_FILENAME} || echo  >> ${OLIX_REPORT_FILENAME}
    else
        echo -n " <span class=\"return ok\">$3</span>" >> ${OLIX_REPORT_FILENAME}
        [[ ! -z $4 ]] && echo " <span class=\"time ok\">($4s)</span>" >> ${OLIX_REPORT_FILENAME} || echo  >> ${OLIX_REPORT_FILENAME}
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
    echo -n "<p>" >> ${OLIX_REPORT_FILENAME}
    echo -n $(stdout_strpad "$1" 64 "." " :") >> ${OLIX_REPORT_FILENAME}
    echo " <span class=\"return info\">$2</span></p>" >> ${OLIX_REPORT_FILENAME}
}


###
# Affiche le contenu d'un fichier
# @param $1 : Nom du fichier
##
function report_printFile()
{
    logger_debug "report_printFile ($1)"
    for J in `cat $1`; do
        echo "$J<br>" >> ${OLIX_REPORT_FILENAME}
    done
    #cat $1 >> ${OLIX_REPORT_FILENAME}
}
