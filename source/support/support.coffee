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

    if location.href.indexOf("#registration") > 0 then S.set("registrationFormHere", true)
    return

############################################################
registrationFormHereChanged = ->
    console.log("registrationFormHereChanged")
    registrationFormHere = S.get("registrationFormHere")

    if registrationFormHere 
        registrationview.classList.add("here")
        document.body.style.height = ""+registrationview.clientHeight+"px"
    else 
        registrationview.classList.remove("here")
        document.body.style.height = "auto"
        location.href = location.href.replace("#registration", "")
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