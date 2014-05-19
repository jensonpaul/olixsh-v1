###
# Librairies pour la gestion de rapport vide
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 16/05/2014
##


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

	OLIX_REPORT_EMAIL=$3
	echo > ${OLIX_REPORT_FILENAME}
}



function report_terminate()
{
	logger_debug "report_terminate ($1)"
	if [[ ! -z ${OLIX_REPORT_EMAIL} ]]; then
		core_sendMail "text" "${OLIX_REPORT_EMAIL}" "${OLIX_REPORT_FILENAME}" "$1"
		[[ $? -ne 0 ]] && logger_warning "Impossible d'envoyer l'email à ${OLIX_REPORT_EMAIL}"
	fi
}



function report_head1() { echo > /dev/null; }