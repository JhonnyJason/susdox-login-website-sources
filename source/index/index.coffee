import Modules from "./allmodules"
import domconnect from "./indexdomconnect"
domconnect.initialize()

global.allModules = Modules

############################################################
S = Modules.statemodule

############################################################
loginView = null
historyStatePushed = false

############################################################
appStartup = ->
    patientLoginBlock.addEventListener("click", patientLoginClicked)
    doctorLoginBlock.addEventListener("click", doctorLoginClicked)

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
    return

setStateInPatientView = ->
    doctorloginview.classList.remove("here")
    patientloginview.classList.add("here")
    # return if historyStatePushed 
    # window.history.pushState({loginView: "patient"}, "", "#patienten_login");
    # historyStatePushed = true
    return

setStateInDoctorView = ->
    patientloginview.classList.remove("here")
    doctorloginview.classList.add("here")
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
run = ->
    promises = (m.initialize() for n,m of Modules when m.initialize?) 
    await Promise.all(promises)
    appStartup()

############################################################
run()