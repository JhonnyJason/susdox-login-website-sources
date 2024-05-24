import Modules from "./allmodules"
import domconnect from "./indexdomconnect"

import * as nav from "navhandler"

############################################################
import * as uiState from "./uistatemodule.js"
import * as triggers from "./navtriggers.js"

############################################################
import * as patientLoginView from "./patientloginviewmodule.js"
import * as doctorLoginView from "./doctorloginviewmodule.js"
import * as compatibilityLoginView from "./compatibilityloginviewmodule.js"

############################################################
import { loginRedirectURL } from "./configmodule.js"

############################################################
domconnect.initialize()

############################################################
## Remove unused modules to not trigger uncaught Exceptions
delete Modules.doctorregistrationviewmodule
delete Modules.patientregistrationviewmodule

global.allModules = Modules

############################################################
appBaseState = "RootState"

############################################################
appStartup = ->
    # nav.initialize(setNavState, setNavState, true)
    nav.initialize(setNavState, setNavState)

    patientLoginBlock.addEventListener("click", triggers.patientLogin)
    doctorLoginBlock.addEventListener("click", triggers.doctorLogin)

    document.addEventListener("keydown", keyDowned)

    checkInstantRedirect()
    await nav.appLoaded()
    checkURLHash()
    return
    

############################################################
setNavState = (navState) ->
    appBaseState = navState.base
    if appBaseState == "RootState" then appBaseState = "index"
    uiState.applyUIStateBase(appBaseState)
    return

############################################################
keyDowned = (evt) ->
    return unless evt.keyCode == 13
    if appBaseState == "doctor" then doctorLoginView.enterWasClicked(evt)
    # if appBaseState == "patient" then patientLoginView.enterWasClicked(evt)
    if appBaseState == "patient" then compatibilityLoginView.enterWasClicked(evt)
    return

############################################################
checkURLHash = ->
    url = new URL(window.location)
    hash = url.hash
    route = url.pathname
    history.replaceState(history.state, document.title, route)

    if hash == "#doctor-login" then triggers.doctorLogin()
    if hash == "#patient-login" then triggers.patientLogin()
    return

############################################################
checkInstantRedirect = ->
    allCookies = document.cookie
    cookies = allCookies.split(";")
    
    passwordExists = false
    usernameExists = false
    
    for cookie in cookies
        c = cookie.trim()
        if c.indexOf("password=") == 0 then passwordExists = true
        if c.indexOf("username=") == 0 then usernameExists = true
    
    if passwordExists and usernameExists
        #alert("redirect to: #{loginRedirectURL}") 
        location.href = loginRedirectURL
    return





############################################################
run = ->
    promises = (m.initialize() for n,m of Modules when m.initialize?) 
    await Promise.all(promises)
    appStartup()

############################################################
run()