############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("errorfeedbackmodule")
#endregion

############################################################
import * as S from "./statemodule.js"

############################################################
svnLogin404ErrorText = null
svnLogin401ErrorText = null
nosvnLoginErrorText = null
pinRenewErrorText = null

############################################################
export initialize = ->
    log "initialize"

    svnLogin404ErrorText = svnLoginError404.innerHTML
    svnLogin401ErrorText = svnLoginError401.innerHTML
    nosvnLoginErrorText = nosvnLoginError.innerHTML
    pinRenewErrorText = pinRenewErrorFeedbackText.innerHTML
    return

############################################################
adjustBodyHeight = ->
    loginView = S.get("loginView")
    if loginView == "doctor"
        document.body.style.height = ""+doctorloginview.clientHeight+"px"
    else 
        document.body.style.height =""+patientloginview.clientHeight+"px"
    return

############################################################
export errorFeedbackSVNLogin = (reason) ->
    patientSvnLoginForm.classList.add("error")

    switch reason
        when "404" then svnErrorFeedbackText.innerHTML = svnLogin404ErrorText
        when "401" then svnErrorFeedbackText.innerHTML = svnLogin401ErrorText
        else svnErrorFeedbackText.innerHTML = "Connection Error!"
    log "Error: "+reason
    return

export errorFeedbackAuthcodeLogin = (reason) ->
    patientAuthcodeLoginForm.classList.add("error")

    switch reason
        when "404", "401" then authcodeErrorFeedbackText.innerHTML = nosvnLoginErrorText
        else authcodeErrorFeedbackText.innerHTML = "Connection Error!"
    log "Error: "+reason
    return

export errorFeedbackPinRenew = (reason) ->
    patientRenewPinForm.classList.add("error")
    switch reason
        when "404" then pinRenewErrorFeedbackText.innerHTML = pinRenewErrorText
        else pinRenewErrorFeedbackText.innerHTML = "Connection Error!"
    log "Error: "+reason
    return

export errorFeedbackDoctorLogin = (reason) ->
    doctorloginForm.classList.add("error")
    log "Error: "+reason
    return

############################################################
export resetAllErrorFeedback = ->
    doctorloginForm.classList.remove("error")
    patientAuthcodeLoginForm.classList.remove("error")
    patientSvnLoginForm.classList.remove("error")
    patientRenewPinForm.classList.remove("error")

    svnErrorFeedbackText.innerHTML = ""
    authcodeErrorFeedbackText.innerHTML = ""
    pinRenewErrorFeedbackText.innerHTML = ""

    adjustBodyHeight()
    return

export errorFeedback = (usecase, reason) ->
    switch usecase
        when "doctor" then errorFeedbackDoctorLogin(reason)
        when "svnPatient" then errorFeedbackSVNLogin(reason)
        when "authcodePatient" then errorFeedbackAuthcodeLogin(reason)
        when "pinRenewPatient" then errorFeedbackPinRenew(reason)
        else log "unknown error usecase: " + usecase
    adjustBodyHeight()
    return