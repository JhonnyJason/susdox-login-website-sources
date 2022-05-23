import Modules from "./allmodules"
import domconnect from "./supportdomconnect"
domconnect.initialize()

delete Modules.patientloginviewmodule
delete Modules.doctorloginviewmodule
global.allModules = Modules

############################################################
S = Modules.statemodule

############################################################
registrationFormHere = false

############################################################
appStartup = ->
    registrationBlock.addEventListener("click", registrationClicked)
    S.addOnChangeListener("registrationFormHere", registrationFormHereChanged)
    return

############################################################
registrationFormHereChanged = ->
    console.log("registrationFormHereChanged")
    registrationFormHere = S.get("registrationFormHere")

    if registrationFormHere then registrationview.classList.add("here")
    else registrationview.classList.remove("here")
    return
    

############################################################
registrationClicked = ->
    console.log("registrationClicked")
    S.set("registrationFormHere", true)
    return

############################################################
run = ->
    promises = (m.initialize() for n,m of Modules when m.initialize?) 
    await Promise.all(promises)
    appStartup()

############################################################
run()