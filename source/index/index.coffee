import Modules from "./allmodules"
import domconnect from "./indexdomconnect"
import {loginRedirectURL} from "./configmodule.js"

domconnect.initialize()

delete Modules.doctorregistrationviewmodule
delete Modules.patientregistrationviewmodule

global.allModules = Modules

############################################################
S = Modules.statemodule

############################################################
loginView = null

############################################################
appStartup = ->
    checkInstantRedirect()

    patientLoginBlock.addEventListener("click", patientLoginClicked)
    doctorLoginBlock.addEventListener("click", doctorLoginClicked)
    
    document.addEventListener("keydown", keyDowned)

    loginView = S.get("loginView")
    if location.hash == "#doctor-login" then loginView = "doctor"
    if location.hash == "#patient-login" then loginView = "patient"

    S.save("loginView", loginView)

    S.addOnChangeListener("loginView", loginViewChanged)
    base = location.href.split("#")[0]

    if loginView == "patient" 
        history.replaceState({}, "", base)
        history.pushState({}, "", base+"#patient-login")
        setStateInPatientView()

    if loginView == "doctor" 
        history.replaceState({}, "", base)
        history.pushState({}, "", base+"#doctor-login")
        setStateInDoctorView()
    
    if loginView == "compatibility" 
        history.replaceState({}, "", base)
        history.pushState({}, "", base+"#compatibility-login")
        # setStateInCompatibilityView()
    
    window.onhashchange = hashChanged
    return

############################################################
#region loginView Changes
loginViewChanged = ->
    console.log("loginViewChanged")
    loginView = S.get("loginView")

    switch(loginView)
        when "patient" then setStateInPatientView()
        when "doctor" then setStateInDoctorView()
        when "compatibility" then setStateInCompatibilityView()
        else unsetLoginViews()
    return

############################################################
setStateInPatientView = ->
    doctorloginview.classList.remove("here")
    compatibilityloginview.classList.remove("here")
    patientloginview.classList.add("here")

    location.hash = "#patient-login"

    document.body.style.height =""+patientloginview.clientHeight+"px"

    Modules.patientloginviewmodule.onPageViewEntry()
    return

setStateInDoctorView = ->
    patientloginview.classList.remove("here")
    compatibilityloginview.classList.remove("here")
    doctorloginview.classList.add("here")

    location.hash = "#doctor-login"    

    document.body.style.height = ""+doctorloginview.clientHeight+"px"
    
    Modules.doctorloginviewmodule.onPageViewEntry()
    return

setStateInCompatibilityView = ->
    patientloginview.classList.remove("here")
    doctorloginview.classList.remove("here")
    compatibilityloginview.classList.add("here")

    location.hash = "#compatibility-login"    

    document.body.style.height = ""+compatibilityloginview.clientHeight+"px"
    
    Modules.compatibilityloginviewmodule.onPageViewEntry()
    return

unsetLoginViews = ->
    console.log("unsetLoginViews")
    doctorloginview.classList.remove("here")
    patientloginview.classList.remove("here")
    compatibilityloginview.classList.remove("here")

    location.hash = ""

    document.body.style.height = "auto"
    return

############################################################
hashChanged = (event) ->
    # console.log("hash has changed")
    # console.log(location.hash)

    view = "none"

    if location.hash == "#doctor-login" then view = "doctor"
    if location.hash == "#patient-login" then view = "patient"
    if location.hash == "#compatibility-login" then view = "compatibility"

    S.save("loginView", view)
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
    allCookies = document.cookie
    cookies = allCookies.split(";")
    
    passwordExists = false
    usernameExists = false
    
    for cookie in cookies
        c = cookie.trim()
        if c.indexOf("password=") == 0 then passwordExists = true
        if c.indexOf("username=") == 0 then usernameExists = true
    
    if passwordExists and usernameExists
        location.href = loginRedirectURL
    return

############################################################
run = ->
    promises = (m.initialize() for n,m of Modules when m.initialize?) 
    await Promise.all(promises)
    appStartup()

############################################################
run()