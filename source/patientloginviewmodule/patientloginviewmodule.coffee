############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("patientloginviewmodule")
#endregion

############################################################
import * as S from "./statemodule.js"
import * as utl from "./utilmodule.js"
import { loginURL, loginRedirectURL } from "./configmodule.js"

############################################################
export initialize = ->
    log "initialize"
    patientloginHeading.addEventListener("click", backButtonClicked)
    svnSubmitButton.addEventListener("click", svnSubmitClicked)
    authcodeSubmitButton.addEventListener("click", authcodeSubmitClicked)
    return

############################################################
# using History
# backButtonClicked = -> window.history.back()

############################################################
# no History
backButtonClicked = -> S.save("loginView", "none")

############################################################
errorFeedback = (error) ->
    log "errorFeedback" 
    if error.authcode
        doctorloginForm.classList.remove("error")
        patientAuthcodeLoginForm.classList.add("error")
        patientSvnLoginForm.classList.remove("error")
        patientRenewPinForm.classList.remove("error")
        log error.msg
        return

    if error.svnLogin
        doctorloginForm.classList.remove("error")
        patientAuthcodeLoginForm.classList.remove("error")
        patientSvnLoginForm.classList.add("error")
        patientRenewPinForm.classList.remove("error")
        log error.msg
        return

    if error.renewPin
        doctorloginForm.classList.remove("error")
        patientAuthcodeLoginForm.classList.remove("error")
        patientSvnLoginForm.classList.remove("error")
        patientRenewPinForm.classList.add("error")
        log error.msg
        return

    log error.msg
    return

############################################################
authcodeSubmitClicked = (evt) ->
    log "authcodeSubmitClicked"
    evt.preventDefault()
    authcodeSubmitButton.disabled = true
    try
        loginBody = await extractNoSVNFormBody()
        olog {loginBody}

        if !loginBody.hashedPw and !loginBody.username then return

        response = await doLoginRequest(loginBody)
        
        if !response.ok then errorFeedback({authcode:true, msg: "Response was not OK!"})
        else location.href = loginRedirectURL

    catch err then return errorFeedback({authcode:true, msg: err.message})
    finally authcodeSubmitButton.disabled = false
    return

svnSubmitClicked = (evt) ->
    log "svnSubmitClicked"
    evt.preventDefault()
    svnSubmitButton.disabled = true
    try
        loginBody = await extractSVNFormBody()
        olog {loginBody}

        if !loginBody.hashedPw and !loginBody.username then return

        response = await doLoginRequest(loginBody)
        
        if !response.ok then errorFeedback({svnLogin:true, msg: "Response was not OK!"})
        else location.href = loginRedirectURL

    catch err then return errorFeedback({svnLogin:true, msg: err.message})
    finally svnSubmitButton.disabled = false
    return

############################################################
extractSVNFormBody = ->

    isMedic = false
    rememberMe = false
    username = ""+svnPartInput.value+birthdayPartInput.value
    password = ""+pinInput.value

    if !password then hashedPw = ""
    else hashedPw = await computeHashedPw(username, password)
    
    return {username, hashedPw, isMedic, rememberMe}

extractNoSVNFormBody = ->

    isMedic = false
    username = ""+authcodeBirthdayInput.value
    password = "AT-"+authcodeInput.value
    
    if password == "AT-" then hashedPw = ""
    else hashedPw = await computeHashedPw(username, password)
    
    return {username, hashedPw, isMedic}

############################################################
computeHashedPw = (username, pwd) ->
    return utl.hashUsernamePw(username, pwd)

############################################################
doLoginRequest = (body) ->
    method = "POST"
    mode = 'cors'
    redirect =  'follow'
    credentials = 'include'
    
    # url encoded
    # headers = { 'Content-Type': 'application/x-www-form-urlencoded' }
    # body = new URLSearchParams(body)

    # json body
    headers = { 'Content-Type': 'application/json' }
    body = JSON.stringify(body)

    fetchOptions = { method, mode, redirect, credentials, headers, body }

    try return fetch(loginURL, fetchOptions)
    catch err then log err

############################################################
export enterWasClicked = (evt) ->
    if pinInput.value then svnSubmitClicked(evt)
    else if authcodeInput.value then authcodeSubmitClicked(evt)
    return

export onPageViewEntry = ->
    log "onPageViewEntry"

    doFocus = ->
        # svnPartInput.setSelectionRange(0, 0)
        svnPartInput.focus()

    setTimeout(doFocus, 400)
    return

