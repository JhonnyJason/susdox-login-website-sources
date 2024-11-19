########################################################
demoRoot = "https://extern.bilder-befunde.at"
productionRoot = "https://bilder-befunde.at"

authPartProduction = "/service/api/v1/auth"
authPartDemo = "/caas/api/v1/auth"

currentOrigin = window.location.origin

########################################################
# export loginURL = demoRoot+authPartDemo+"/login" # demo
export loginURL = productionRoot+authPartProduction+"/login" # production

########################################################
export legacyLoginURL = "https://www.bilder-befunde.at/pwa-api/api/v1/login/"

########################################################
# export loginRedirectURL = "https://www.bilder-befunde.at/webview"
export loginRedirectURL = currentOrigin+"/home"

########################################################
export supportRequestURL = "https://www.bilder-befunde.at/pwa-api/api/v1/support/"

########################################################
export requestCodeURL = "https://www.bilder-befunde.at/pwa-api/api/v1/request-code/"

########################################################
export renewPinURL = "https://bilder-befunde.at/index.php?site=scripts/login_patient.php"