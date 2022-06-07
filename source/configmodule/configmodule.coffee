########################################################
demoRoot = "https://extern.bilder-befunde.at"
productionRoot = "https://bilder-befunde.at"
authPart = "/service/api/v1/auth"

# export loginURL = demoRoot+authPart+"/login" # demo
export loginURL = productionRoot+authPart+"/login" # production

export logoutURL = demoRoot+authPart+"/logout" # demo
# export logoutURL = productionRoot+authPart+"/logout" # production
