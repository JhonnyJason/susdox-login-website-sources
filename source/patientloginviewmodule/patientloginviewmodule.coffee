############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("patientloginform")
#endregion

############################################################
import * as S from "./statemodule.js"

############################################################
loginType = "svn"

############################################################
export initialize = ->
    log "initialize"
    patientloginHeading.addEventListener("click", backButtonClicked)
    patientSvnFormButton.addEventListener("click", svnFormButtonClicked)
    patientAuthcodeFormButton.addEventListener("click", authcodeButtonClicked)
    patientRenewPinButton.addEventListener("click", renewPinButtonClicked)
    patientNoAuthcodeButton.addEventListener("click", noAuthcodeButtonClicked)


    loginType = S.load("patientLoginType")
    
    switch loginType
        when "svn", "svn-no-pin" then setStateSVNLogin()
        when "authcode", "authcode-no-authcode" then setStateAuthcodeLogin()
        else log "unknown patientLoginType: " + loginType

    if loginType == "svn-no-pin" 
        S.save("patientLoginType", "svn")
        loginType = "svn"

    if loginType == "authcode-no-authcode"
        S.save("patientLoginType", "authcode")
        loginType = "authcode"

    S.addOnChangeListener("patientLoginType", patientLoginTypeChanged)
    return


############################################################
# using History
# backButtonClicked = -> window.history.back()

############################################################
# no History
backButtonClicked = -> S.save("loginView", "none")


############################################################
#region UIState Handling
patientLoginTypeChanged = ->
    loginType = S.load("patientLoginType")
    switch loginType
        when "svn" then setStateSVNLogin()
        when "svn-no-pin" then setStateRenewPin()
        when "authcode" then setStateAuthcodeLogin()
        when "authcode-no-authcode" then setStateNoAuthcode()
        else log "unknown patientLoginType: " + loginType
    return

############################################################
#region setStateFunctions
setStateSVNLogin = ->
    patientSvnLoginForm.classList.add("here")

    patientAuthcodeLoginForm.classList.remove("here")
    patientRenewPinForm.classList.remove("here")
    patientNoAuthcode.classList.remove("here")

    patientSvnFormButton.classList.add("on")
    
    patientAuthcodeFormButton.classList.remove("on")
    patientRenewPinButton.classList.remove("on")
    patientNoAuthcodeButton.classList.remove("on")
    return

setStateAuthcodeLogin = ->
    patientAuthcodeLoginForm.classList.add("here")
    
    patientSvnLoginForm.classList.remove("here")
    patientRenewPinForm.classList.remove("here")
    patientNoAuthcode.classList.remove("here")

    patientAuthcodeFormButton.classList.add("on")
    
    patientSvnFormButton.classList.remove("on")
    patientRenewPinButton.classList.remove("on")
    patientNoAuthcodeButton.classList.remove("on")
    return

setStateRenewPin = ->
    patientRenewPinForm.classList.add("here")
    
    patientSvnLoginForm.classList.remove("here")
    patientAuthcodeLoginForm.classList.remove("here")
    patientNoAuthcode.classList.remove("here")

    patientRenewPinButton.classList.add("on")
    
    patientSvnFormButton.classList.remove("on")
    patientAuthcodeFormButton.classList.remove("on")
    patientNoAuthcodeButton.classList.remove("on")
    return

setStateNoAuthcode = ->
    patientNoAuthcode.classList.add("here")
    
    patientSvnLoginForm.classList.remove("here")
    patientAuthcodeLoginForm.classList.remove("here")
    patientRenewPinForm.classList.remove("here")

    
    patientNoAuthcodeButton.classList.add("on")

    patientSvnFormButton.classList.remove("on")
    patientAuthcodeFormButton.classList.remove("on")
    patientRenewPinButton.classList.remove("on")
    return
#endregion

############################################################
#region UI state-relevant Events

svnFormButtonClicked = -> S.save("patientLoginType", "svn")

authcodeButtonClicked = -> S.save("patientLoginType", "authcode")

renewPinButtonClicked = -> S.save("patientLoginType", "svn-no-pin")

noAuthcodeButtonClicked = -> S.save("patientLoginType", "authcode-no-authcode")


#endregion

#endregion