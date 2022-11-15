############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("compatibitlityloginviewmodule")
#endregion

############################################################
import * as S from "./statemodule.js"
import * as utl from "./utilmodule.js"
import { resetAllErrorFeedback, errorFeedback } from "./errorfeedbackmodule.js"
import { loginURL, loginRedirectURL, renewPinURL } from "./configmodule.js"


############################################################
#region inputField Length tracking
svnPartLength = 0
svnBirthdayPartLength = 0

pinRenewSvnPartLength = 0
pinRenewBirthdayPartLength = 0

#endregion

############################################################
export initialize = ->
    log "initialize"
    compatibilityloginHeading.addEventListener("click", backButtonClicked)
    svnSubmitButton.addEventListener("click", svnSubmitClicked)
    authcodeSubmitButton.addEventListener("click", authcodeSubmitClicked)
    pinRenewSubmitButton.addEventListener("click", pinRenewSubmitClicked)

    svnPartInput.addEventListener("keyup", svnPartKeyUpped)
    birthdayPartInput.addEventListener("keyup", birthdayPartKeyUpped)
    pinRenewSvnPartInput.addEventListener("keyup", pinRenewSVNPartKeyUpped)
    pinRenewBirthdayPartInput.addEventListener("keyup", pinRenewBirthdayPartKeyUpped)

    svnPartLength = svnPartInput.value.length
    svnBirthdayPartLength = birthdayPartInput.value.length

    pinRenewSvnPartLength = pinRenewSvnPartInput.value.length
    pinRenewBirthdayPartLength = pinRenewBirthdayPartInput.value.length

    return

############################################################
#region keyUpListeners
svnPartKeyUpped = (evt) ->
    # log "svnPartKeyUpped"
    value = svnPartInput.value
    svnPartLength = value.length
    # olog {newLength}

    if evt.keyCode == 46 then return
    
    if evt.keyCode == 8 then return

    if svnPartLength == 4 then focusBirthdayPartFirst()
    return

birthdayPartKeyUpped = (evt) ->
    # log "birthdayPartKeyUpped"
    value = birthdayPartInput.value
    newLength = value.length
    # olog {newLength}

    if evt.keyCode != 8
        svnBirthdayPartLength = newLength
        return

    if svnBirthdayPartLength == 0 then focusSVNPartLast()
    else svnBirthdayPartLength = newLength
    return

pinRenewSVNPartKeyUpped = (evt) ->
    # log "pinRenewSVNPartKeyUpped"
    value = pinRenewSvnPartInput.value
    pinRenewSvnPartLength = value.length
    # olog {newLength}

    if evt.keyCode == 46 then return

    if evt.keyCode == 8 then return

    if pinRenewSvnPartLength == 4 then focusPinRenewBirthdayPartFirst()
    return

pinRenewBirthdayPartKeyUpped = (evt) ->
    # log "pinRenewBirthdayPartKeyUpped"
    value = pinRenewBirthdayPartInput.value
    newLength = value.length
    # olog {newLength}

    if evt.keyCode != 8
        pinRenewBirthdayPartLength = newLength
        return

    if pinRenewBirthdayPartLength == 0 then focusPinRenewSVNPartLast()
    else pinRenewBirthdayPartLength = newLength
    return

#endregion

############################################################
# using History
backButtonClicked = -> window.history.back()

############################################################
authcodeSubmitClicked = (evt) ->
    log "authcodeSubmitClicked"
    evt.preventDefault()
    authcodeSubmitButton.disabled = true
    try
        resetAllErrorFeedback()

        loginBody = await extractNoSVNFormBody()
        olog {loginBody}

        if !loginBody.hashedPw and !loginBody.username then return

        response = await doLoginRequest(loginBody)
        
        if !response.ok then errorFeedback("authcodePatient", ""+response.status)
        else location.href = loginRedirectURL

    catch err then return errorFeedback("authcodePatient", "Other: " + err.message)
    finally authcodeSubmitButton.disabled = false
    return

svnSubmitClicked = (evt) ->
    log "svnSubmitClicked"
    evt.preventDefault()
    svnSubmitButton.disabled = true
    try
        resetAllErrorFeedback()
       
        loginBody = await extractSVNFormBody()
        olog {loginBody}

        if !loginBody.hashedPw and !loginBody.username then return

        response = await doLoginRequest(loginBody)
        
        if !response.ok then errorFeedback("svnPatient", ""+response.status)
        else location.href = loginRedirectURL

    catch err then return errorFeedback("svnPatient", "Other: " + err.message)
    finally svnSubmitButton.disabled = false
    return

pinRenewSubmitClicked = (evt) ->
    log "pinRenewSubmitClicked"
    evt.preventDefault()
    pinRenewSubmitButton.disabled = true
    try
        resetAllErrorFeedback()

        if !pinRenewSvnPartInput.value and !pinRenewBirthdayPartInput.value then return

        renewPinBody = extractRenewPinBody()
        olog { renewPinBody } 
    
        response = await doRenewPinRequest(renewPinBody)
        if !response.ok then errorFeedback("pinRenewPatient", ""+response.status)
        
    catch err then return errorFeedback("pinRenewPatient", "Other: " + err.message)
    finally pinRenewSubmitButton.disabled = false
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
    rememberMe = false

    username = ""+authcodeBirthdayInput.value
    password = "AT-"+authcodeInput.value
    
    if password == "AT-" then hashedPw = ""
    else hashedPw = await computeHashedPw(username, password)
    
    return {username, hashedPw, isMedic, rememberMe}

extractRenewPinBody = ->

    # username = ""+pinRenewSvnPartInput.value+pinRenewBirthdayPartInput.value
    svn_pin1 = ""+pinRenewSvnPartInput.value
    svn_pin2 = ""+pinRenewBirthdayPartInput.value
    pin_send = true
    pin_send_extern = true

    # return {username, pin_send, pin_send_extern}
    return {svn_pin1, svn_pin2, pin_send, pin_send_extern}

############################################################
computeHashedPw = (username, pwd) ->
    return utl.hashUsernamePw(username, pwd)

############################################################
doLoginRequest = (body) ->
    method = "POST"
    mode = 'cors'
    redirect =  'follow'
    credentials = 'include'
    

    # json body
    headers = { 'Content-Type': 'application/json' }
    body = JSON.stringify(body)

    fetchOptions = { method, mode, redirect, credentials, headers, body }

    try return fetch(loginURL, fetchOptions)
    catch err then log err

doRenewPinRequest = (body) ->
    method = "POST"
    mode = 'cors'
    redirect =  'follow'
    credentials = 'include'
    
    # url encoded
    headers = { 'Content-Type': 'application/x-www-form-urlencoded' }
    body = new URLSearchParams(body)


    fetchOptions = { method, mode, redirect, credentials, headers, body }

    try return fetch(renewPinURL, fetchOptions)
    catch err then log err


############################################################
#region focus inputs functions
focusSVNPartFirst = ->
    svnPartInput.setSelectionRange(0, 0)
    svnPartInput.focus()

focusSVNPartLast = ->
    svnPartInput.setSelectionRange(4, 4)
    svnPartInput.focus()

focusBirthdayPartFirst = ->
    birthdayPartInput.setSelectionRange(0, 0)
    birthdayPartInput.focus()


focusPinRenewSVNPartLast = ->
    pinRenewSvnPartInput.setSelectionRange(4, 4)
    pinRenewSvnPartInput.focus()

focusPinRenewBirthdayPartFirst = ->
    pinRenewBirthdayPartInput.setSelectionRange(0, 0)
    pinRenewBirthdayPartInput.focus()


#endregion


############################################################
export enterWasClicked = (evt) ->
    if pinInput.value then svnSubmitClicked(evt)
    else if authcodeInput.value then authcodeSubmitClicked(evt)
    return

export onPageViewEntry = ->
    log "onPageViewEntry"
    setTimeout(focusSVNPartFirst, 400)
    return


