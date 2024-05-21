import Modules from "./allmodules"
import domconnect from "./supportdomconnect"

import * as nav from "navhandler"

############################################################
import * as uiState from "./uistatemodule.js"
import * as triggers from "./navtriggers.js"

domconnect.initialize()

delete Modules.patientloginviewmodule
delete Modules.doctorloginviewmodule
delete Modules.compatibilityloginviewmodule

global.allModules = Modules

############################################################
appBaseState = null

############################################################
appStartup = ->
    # nav.initialize(setNavState, setNavState, true)
    nav.initialize(setNavState, setNavState)

    doctorregistrationBlock.addEventListener("click", triggers.doctorRegistration)
    patientregistrationBlock.addEventListener("click", triggers.patientRegistration)

    nav.appLoaded()
    return


############################################################
setNavState = (navState) ->
    appBaseState = navState.base
    if appBaseState == "RootState" then appBaseState = "support"
    uiState.applyUIStateBase(appBaseState)
    return


############################################################
run = ->
    promises = (m.initialize() for n,m of Modules when m.initialize?) 
    await Promise.all(promises)
    appStartup()

############################################################
run()