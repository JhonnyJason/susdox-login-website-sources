import Modules from "./allmodules"
import domconnect from "./supportdomconnect"
domconnect.initialize()

delete Modules.patientloginviewmodule
delete Modules.doctorloginviewmodule

global.allModules = Modules

############################################################
S = Modules.statemodule

############################################################
registrationView = null

############################################################
appStartup = ->
    doctorregistrationBlock.addEventListener("click", doctorregistrationClicked)
    patientregistrationBlock.addEventListener("click", patientregistrationClicked)

    S.addOnChangeListener("registrationView", registrationViewChanged)
    
    base = location.href.split("#")[0]

    if location.hash == "#doctor-registration" 
        history.replaceState({}, "", base)
        history.pushState({}, "", base+"#doctor-registration")
        setStateInDoctorView()

    if location.hash == "#patient-registration"
        history.replaceState({}, "", supportBase)
        history.pushState({}, "", supportBase+"#patient-registration")   
        setStateInPatientView()

    window.onhashchange = hashChanged
    return

############################################################
#region registratinView Changes
registrationViewChanged = ->
    # console.log("registrationViewChanged")
    registrationView = S.get("registrationView")

    if registrationView == "patient" then setStateInPatientView()
    else if registrationView == "doctor" then setStateInDoctorView()
    else unsetRegistrationView()
    return

############################################################
setStateInPatientView = ->
    # console.log "setStateInPatientView"
    doctorregistrationview.classList.remove("here")
    patientregistrationview.classList.add("here")

    location.hash = "#patient-registration"

    document.body.style.height = ""+patientregistrationview.clientHeight+"px"
    Modules.patientregistrationviewmodule.onPageViewEntry()
    return

setStateInDoctorView = ->
    # console.log "setStateInDoctorView"
    doctorregistrationview.classList.add("here")
    patientregistrationview.classList.remove("here")

    location.hash = "#doctor-registration"

    document.body.style.height = ""+doctorregistrationview.clientHeight+"px"
    Modules.doctorregistrationviewmodule.onPageViewEntry()
    return

unsetRegistrationView = ->
    # console.log "unsetRegistrationView"
    doctorregistrationview.classList.remove("here")
    patientregistrationview.classList.remove("here")

    location.hash = ""

    document.body.style.height = "auto"
    return

############################################################
hashChanged = (event) ->
    # console.log("hash has changed")
    # console.log(location.hash)

    view = "none"

    if location.hash == "#doctor-registration" then view = "doctor"
    if location.hash == "#patient-registration" then view = "patient"

    S.set("registrationView", view)
    return

#endregion

############################################################
doctorregistrationClicked = ->
    # console.log("doctorregistrationClicked")
    S.set("registrationView", "doctor")
    return

patientregistrationClicked = ->
    # console.log("patientregistrationClicked")
    S.set("registrationView", "patient" )
    return

############################################################
run = ->
    promises = (m.initialize() for n,m of Modules when m.initialize?) 
    await Promise.all(promises)
    appStartup()

############################################################
run()