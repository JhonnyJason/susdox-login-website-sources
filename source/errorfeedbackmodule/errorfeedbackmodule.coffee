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
    pinRenewErrorText = pinRenewError.innerHTML
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
    compatibilitySvnLoginForm.classList.add("error")

    switch reason
        when "404" then svnErrorFeedbackText.innerHTML = svnLogin404ErrorText
        when "401" then svnErrorFeedbackText.innerHTML = svnLogin401ErrorText
        else svnErrorFeedbackText.innerHTML = "Connection Error!"
    log "Error: "+reason
    return

export errorFeedbackCodeLogin = (reason) ->
    patientCodeLoginForm.classList.add("error")

    switch reason
        when "404" then svnErrorFeedbackText.innerHTML = svnLogin404ErrorText
        when "401" then svnErrorFeedbackText.innerHTML = svnLogin401ErrorText
        else codeErrorFeedbackText.innerHTML = "Connection Error!"
    log "Error: "+reason
    return

export errorFeedbackAuthcodeLogin = (reason) ->
    compatibilityAuthcodeLoginForm.classList.add("error")

    switch reason
        when "404", "401" then authcodeErrorFeedbackText.innerHTML = nosvnLoginErrorText
        else authcodeErrorFeedbackText.innerHTML = "Connection Error!"
    log "Error: "+reason
    return

export errorFeedbackPinRenew = (reason) ->
    compatibilityRenewPinForm.classList.add("error")
    switch reason
        when "404" then compatibilityPinRenewErrorFeedbackText.innerHTML = pinRenewErrorText
        else compatibilityPinRenewErrorFeedbackText.innerHTML = "Connection Error!"
    log "Error: "+reason
    return

export errorFeedbackCodeRenew = (reason) ->
    renewCodeForm.classList.add("error")
    switch reason
        when "404" then codeRenewErrorFeedbackText.innerHTML = pinRenewErrorText
        else codeRenewErrorFeedbackText.innerHTML = "Connection Error!"
    log "Error: "+reason
    return


export errorFeedbackDoctorLogin = (reason) ->
    doctorloginForm.classList.add("error")
    log "Error: "+reason
    return

############################################################
export resetAllErrorFeedback = ->
    if doctorloginForm? then doctorloginForm.classList.remove("error")

    if patientCodeLoginForm? then patientCodeLoginForm.classList.remove("error")
    if renewCodeForm? then renewCodeForm.classList.remove("error")

    if codeErrorFeedbackText? then codeErrorFeedbackText.innerHTML = ""
    if codeRenewErrorFeedbackText? then codeRenewErrorFeedbackText.innerHTML = ""

    if compatibilityAuthcodeLoginForm? then compatibilityAuthcodeLoginForm.classList.remove("error")
    if compatibilitySvnLoginForm? then compatibilitySvnLoginForm.classList.remove("error")
    if compatibilityRenewPinForm? then compatibilityRenewPinForm.classList.remove("error")    

    if svnErrorFeedbackText? then svnErrorFeedbackText.innerHTML = ""
    if authcodeErrorFeedbackText? then authcodeErrorFeedbackText.innerHTML = ""
    if compatibilityPinRenewErrorFeedbackText? then compatibilityPinRenewErrorFeedbackText.innerHTML = ""
        
    adjustBodyHeight()
    return

export errorFeedback = (usecase, reason) ->
    switch usecase
        when "doctor" then errorFeedbackDoctorLogin(reason)
        when "svnPatient" then errorFeedbackSVNLogin(reason)
        when "authcodePatient" then errorFeedbackAuthcodeLogin(reason)
        when "codePatient" then errorFeedbackCodeLogin(reason)
        when "codeRenewPatient" then errorFeedbackCodeRenew(reason)
        when "codeRenewCompatibility" then errorFeedbackPinRenew(reason)
        else log "unknown error usecase: " + usecase
    adjustBodyHeight()
    return