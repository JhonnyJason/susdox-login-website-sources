########################################################
demoRoot = "https://extern.bilder-befunde.at"
productionRoot = "https://bilder-befunde.at"

authPartProduction = "/service/api/v1/auth"
authPartDemo = "/caas/api/v1/auth"

# export loginURL = demoRoot+authPartDemo+"/login" # demo
export loginURL = productionRoot+authPartProduction+"/login" # production


########################################################
export loginRedirectURL = "https://webview.bilder-befunde.at/webview"

########################################################
export renewPinURL = "https://bilder-befunde.at/index.php?site=scripts/login_patient.php"