###
# Librairies pour la gestion de rapport vide
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 16/05/2014
##


OLIX_REPORT_FORMAT="text"
OLIX_REPORT_FILENAME=""
OLIX_REPORT_EMAIL=""



###
# Initialise le rapport
# @param $1 : Type du rapport texte ou html
# @param $2 : Chemin + nom du fichier du rapport
# @param $3 : Email sur lequel sera envoyé le rapport
##
function report_initialize()
{
	logger_debug "report_initialize ($1, $2, $3)"

	case $1 in
		HTML|html)  source lib/report.html.inc.sh
					OLIX_REPORT_FILENAME="$2.html";;		
		TEXT|text)  source lib/report.text.inc.sh
					OLIX_REPORT_FILENAME="$2.txt";;
		*)			logger_warning "Type de rapport non défini"
					return;;
	esac

	OLIX_REPORT_FORMAT=$1
	OLIX_REPORT_EMAIL=$3

	echo > ${OLIX_REPORT_FILENAME}
	report_printHeader
}


###
# Finalise le rapport et l'envoi pas mail le cas échéant
# @param $1 : Format du rapport
# @param $2 : Sujet du mail
##
function report_terminate()
{
	logger_debug "report_terminate ($1, $2)"

	report_printFooter

	if [[ ! -z ${OLIX_REPORT_EMAIL} ]]; then
		core_sendMail "$1" "${OLIX_REPORT_EMAIL}" "${OLIX_REPORT_FILENAME}" "$2"
		[[ $? -ne 0 ]] && logger_warning "Impossible d'envoyer l'email à ${OLIX_REPORT_EMAIL}"
	fi
}


###
# Rapport d'erreur
# @param $1 : Message d'erreur
##
function report_error()
{
	[[ -n $1 ]] && report_print "$1" "color:red;"
	[[ -s ${OLIX_LOGGER_FILE_ERR} ]] && report_printFile "${OLIX_LOGGER_FILE_ERR}" "color:red;"
	report_terminate "${OLIX_REPORT_FORMAT}" "ERREUR"
    return 0
}


###
# Rapport d'avertissement
# @param $1 : Message d'avertissement
##
function report_warning()
{
	[[ -n $1 ]] && report_print "$1" "color:red;"
	[[ -s ${OLIX_LOGGER_FILE_ERR} ]] && report_printFile "${OLIX_LOGGER_FILE_ERR}" "color:red;"
    return 0
}


function report_printHead1() { echo > /dev/null; }

function report_printHead2() { echo > /dev/null; }

function report_printLine() { echo > /dev/null; }

function report_print() { echo > /dev/null; }

function report_printMessageReturn() { echo > /dev/null; }

function report_printInfo() { echo > /dev/null; }

function report_printFile() { echo > /dev/null; }
