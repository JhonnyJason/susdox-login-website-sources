############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("doctorloginviewmodule")
#endregion

############################################################
import * as S from "./statemodule.js"
import * as utl from "./utilmodule.js"
import * as triggers from "./navtriggers.js"
import { errorFeedback, resetAllErrorFeedback } from "./errorfeedbackmodule.js"
import { loginURL, legacyLoginURL, loginRedirectURL } from "./configmodule.js"

############################################################
export initialize = ->
    log "initialize"
    doctorloginHeading.addEventListener("click", triggers.back)
    doctorloginSubmitButton.addEventListener("click", loginClicked)
    doctormiscContinueButton.addEventListener("click", triggers.patientLogin)
    getLoginDataButton.addEventListener("click", getLoginDataButtonClicked)
    return

############################################################
# using History
############################################################
# no History
# backButtonClicked = -> S.save("loginView", "none")

getLoginDataButtonClicked = ->
    log "getLoginDataButtonClicked"
    location.href = "support.html#doctor-registration"
    return

############################################################
loginClicked = (evt) ->
    log "loginClicked"
    evt.preventDefault()
    doctorloginSubmitButton.disabled = true
    try
        resetAllErrorFeedback()

        loginBody = await extractLoginBody()
        olog {loginBody}

        if !loginBody.vpn and !loginBody.username and !loginBody.hashedPw then return

        redirectURL = loginRedirectURL
        # if loginBody.usedURL == "webviewroute" then redirectURL = webviewRoute
        # if loginBody.usedURL == "webviewsubdomain" then redirectURL = webviewSubdomain
        # if loginBody.usedURL == "webviewrouteandsubdomain" then redirectURL = webviewRouteAndSubdomain

        response = await doLoginRequest(loginBody)
        if !response.ok then errorFeedback("doctor", ""+response.status)
        else
            #alert("redirect to: #{redirectURL}") 
            location.href = redirectURL        
        
        # responseBody = await response.json()
        # responseHeaders = response.headers

        # log " - - - - received response"
        # olog response
        # log "url: "+response.url
        # log "status: "+response.status
        # log "type: "+response.type
        # log "redirected: "+response.redirected
        # olog { responseHeaders }
        # olog { responseBody }

        # log "cookie:\n" + document.cookie
        # document.cookie = "webviewToken:"+responseBody.webviewToken+";"

        # params = new URLSearchParams()
        # params.append('webviewToken', responseBody.webviewToken)

        # # response.redirect(loginRedirectURL+responseBody.redirect)
        # location.href = loginRedirectURL+"?"+params.toString()

    catch err then return errorFeedback("doctor", "Other: " + err.message)
    finally doctorloginSubmitButton.disabled = false
    return

############################################################
extractLoginBody = ->
    vpn = vpnInput.value.toLowerCase()
    # TODO check if vpn is valid - ignoring for now
    isMedic = true
    rememberMe = saveLoginInput.checked
    username = usernameInput.value.toLowerCase()
    password = passwordInput.value
    # password = password.replace("\n", "")
    # password = password.replace("\t", "")
    # password = password.replace("\r", "")
    password = password.trim()
    # usedURL = usedUrlSelect.value
    # log usedURL

    if password then hashedPw = await computeHashedPw(vpn, username, password)
    else hashedPw = ""

    # return {vpn, username, hashedPw, isMedic, rememberMe, usedURL}
    return {vpn, username, hashedPw, isMedic, rememberMe}

computeHashedPw = (vpn, username, pwd) ->
    if vpn == 'wfpi'
        if username == 'engi' then return utl.hashUsernamePw(vpn+username, pwd)
        else return utl.hashUsernamePw(username+'.'+vpn, pwd)
    else return utl.hashUsernamePw(username, pwd)

############################################################
doLoginRequest = (body) ->
    method = "POST"
    mode = 'cors'
    redirect =  'manual'
    credentials = 'include'
    
    # json body
    headers = { 'Content-Type': 'application/json' }
    body = JSON.stringify(body)

    fetchOptions = { method, mode, redirect, credentials, headers, body }

    # try return fetch(loginURL, fetchOptions)
    try return fetch(legacyLoginURL, fetchOptions)
    catch err then log err

############################################################
export enterWasClicked = (evt) -> loginClicked(evt)

export onPageViewEntry = ->
    log "onPageViewEntry"

    doFocus = ->
        vpnInput.setSelectionRange(0,0)
        vpnInput.focus()

    setTimeout(doFocus, 400)
    return
