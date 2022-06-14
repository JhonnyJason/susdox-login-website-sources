import Modules from "./allmodules"
import domconnect from "./indexdomconnect"
import {loginRedirectURL} from "./configmodule.js"

domconnect.initialize()

delete Modules.registrationviewmodule

global.allModules = Modules

############################################################
S = Modules.statemodule

############################################################
loginView = null
historyStatePushed = false

############################################################
appStartup = ->
    checkInstantRedirect()

    patientLoginBlock.addEventListener("click", patientLoginClicked)
    doctorLoginBlock.addEventListener("click", doctorLoginClicked)
    
    document.addEventListener("keydown", keyDowned)

    loginView = S.get("loginView")

    if loginView == "patient" then setStateInPatientView()
    else if loginView == "doctor" then setStateInDoctorView()
    
    S.addOnChangeListener("loginView", loginViewChanged)
    # window.onpopstate = popHistoryState
    return

############################################################
#region loginView Changes
loginViewChanged = ->
    console.log("loginViewChanged")
    loginView = S.get("loginView")

    if loginView == "patient" then setStateInPatientView()
    else if loginView == "doctor" then setStateInDoctorView()
    else unsetLoginViews()
    return

############################################################
unsetLoginViews = ->
    doctorloginview.classList.remove("here")
    patientloginview.classList.remove("here")
    document.body.style.height = "auto"
    return

setStateInPatientView = ->
    doctorloginview.classList.remove("here")
    patientloginview.classList.add("here")
    
    document.body.style.height =""+patientloginview.clientHeight+"px"

    Modules.patientloginviewmodule.onPageViewEntry()

    # return if historyStatePushed 
    # window.history.pushState({loginView: "patient"}, "", "#patienten_login");
    # historyStatePushed = true
    return

setStateInDoctorView = ->
    patientloginview.classList.remove("here")
    doctorloginview.classList.add("here")
    
    document.body.style.height = ""+doctorloginview.clientHeight+"px"
    
    Modules.doctorloginviewmodule.onPageViewEntry()
    
    # return if historyStatePushed 
    # window.history.pushState({loginView: "doctor"}, "", "#ärzte_login");
    # historyStatePushed = true
    return

############################################################
popHistoryState = (event) ->
    console.log("popHistoryState")
    return unless event?
    state = event.state
    if !state? or !state.loginView?
        historyStatePushed = false
        S.save("loginView", "none")
    else if state.loginView == "patient"
        historyStatePushed = true
        S.save("loginView", "patient")
    else if state.loginView == "doctor"
        historyStatePushed = true
        S.save("loginView", "doctor")
    else 
        console.log("Error, we had unknown loginView of: "+state.loginView)
    console.log(state)
    return

#endregion

############################################################
patientLoginClicked = ->
    console.log("patientLoginClicked")
    S.save("loginView", "patient")
    return

doctorLoginClicked = ->
    console.log("doctorLoginClicked")
    S.save("loginView", "doctor")
    return

############################################################
keyDowned = (evt) ->
    return unless evt.keyCode == 13
    if loginView == "doctor" then Modules.doctorloginviewmodule.enterWasClicked(evt)
    if loginView == "patient" then Modules.patientloginviewmodule.enterWasClicked(evt)
    return

############################################################
checkInstantRedirect = ->
    cookie = document.cookie
    log cookie
    if cookie.indexOf("username:") > 0 and cookie.indexOf("password:") > 0
        location.href = loginRedirectURL
    return

############################################################
run = ->
    promises = (m.initialize() for n,m of Modules when m.initialize?) 
    await Promise.all(promises)
    appStartup()

############################################################
run()