############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("patientloginviewmodule")
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
count = 10000

# c = count
# before = performance.now()
# while c--
#     operations()
# after = performacne.now()
# dif = after - before
# log "X took #{dif}ms"

############################################################
export initialize = ->
    log "initialize"
    patientloginHeading.addEventListener("click", backButtonClicked)
    codeSubmitButton.addEventListener("click", codeSubmitButtonClicked)
    codeRenewSubmitButton.addEventListener("click", codeRenewSubmitClicked)
    accessCompatibilityButton.addEventListener("click", accessCompatibilityButtonClicked)

    codeInput.addEventListener("keydown", codeInputKeyDowned)
    codeInput.addEventListener("keyup", codeInputKeyUpped)

    noCodeQuestion.addEventListener("click", noCodeQuestionClicked)
    codeRenewSvnPartInput.addEventListener("keyup", pinRenewSVNPartKeyUpped)
    codeRenewBirthdayPartInput.addEventListener("keyup", pinRenewBirthdayPartKeyUpped)

    pinRenewSvnPartLength = codeRenewSvnPartInput.value.length
    pinRenewBirthdayPartLength = codeRenewBirthdayPartInput.value.length

    return

############################################################
#region keyUpListeners
codeInputKeyDowned = (evt) ->
    # log "svnPartKeyUpped"
    value = codeInput.value
    codeLength = value.length
    
    # 46 is delete
    if evt.keyCode == 46 then return    
    # 8 is backspace
    if evt.keyCode == 8 then return
    # 27 is escape
    if evt.keyCode == 27 then return
    
    # We we donot allow the input to grow furtherly
    if codeLength == 13
        evt.preventDefault()
        return false
    
    if codeLength > 13 then codeInput.value = ""

    # okay = utl.isAlphanumericString(evt.key)
    okay = utl.isBase32String(evt.key)

    if !okay
        evt.preventDefault()
        return false
    return

codeInputKeyUpped = (evt) ->
    # log "svnPartKeyUpped"
    value = codeInput.value
    codeLength = value.length

    codeTokens = []
    rawCode = value.replaceAll(" ", "")
    log "rawCode #{rawCode}"
    if rawCode.length > 0
        codeTokens.push(rawCode.slice(0,3))
    if rawCode.length > 3
        codeTokens.push(rawCode.slice(3,6))
    if rawCode.length > 6
        codeTokens.push(rawCode.slice(6))
    newValue = codeTokens.join("  ")
    codeInput.value = newValue
    return

pinRenewSVNPartKeyUpped = (evt) ->
    # log "pinRenewSVNPartKeyUpped"
    value = codeRenewSvnPartInput.value
    pinRenewSvnPartLength = value.length
    # olog {newLength}

    if evt.keyCode == 46 then return

    if evt.keyCode == 8 then return

    if pinRenewSvnPartLength == 4 then focusPinRenewBirthdayPartFirst()
    return

pinRenewBirthdayPartKeyUpped = (evt) ->
    # log "pinRenewBirthdayPartKeyUpped"
    value = codeRenewBirthdayPartInput.value
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

accessCompatibilityButtonClicked = ->
    log "accessCompatibilityButtonClicked"
    S.save("loginView", "compatibility")
    return
    
noCodeQuestionClicked = (evnt) ->
    extensionBlock = patientloginview.getElementsByClassName("extension-block-content")[0]
    extensionBlock.classList.toggle("shown")
    return

############################################################
codeSubmitButtonClicked = (evt) ->
    log "codeSubmitClicked"
    evt.preventDefault()
    codeSubmitButton.disabled = true
    try
        resetAllErrorFeedback()
       
        loginBody = await extractCodeFormBody()
        olog {loginBody}

        if !loginBody.hashedPw and !loginBody.username then return

        response = await doLoginRequest(loginBody)
        
        if !response.ok then errorFeedback("codePatient", ""+response.status)
        else location.href = loginRedirectURL

    catch err then return errorFeedback("codePatient", "Other: " + err.message)
    finally codeSubmitButton.disabled = false
    return

codeRenewSubmitClicked = (evt) ->
    log "codeRenewSubmitClicked"
    evt.preventDefault()
    codeRenewSubmitButton.disabled = true
    try
        resetAllErrorFeedback()

        if !codeRenewSvnPartInput.value and !codeRenewBirthdayPartInput.value then return

        renewPinBody = extractRenewPinBody()
        olog { renewPinBody } 
    
        response = await doRenewPinRequest(renewPinBody)
        if !response.ok then errorFeedback("codeRenewPatient", ""+response.status)
        
    catch err then return errorFeedback("codeRenewPatient", "Other: " + err.message)
    finally codeRenewSubmitButton.disabled = false
    return

############################################################
extractCodeFormBody = ->
    username = ""+birthdayInput.value
    if !username then return {}

    code = codeInput.value.replaceAll(" ", "").toLowerCase()
    if !utl.isBase32String(code) then return {}

    isMedic = false
    rememberMe = false

    hashedPw = utl.argon2HashPw(code, username)

    return {username, hashedPw, isMedic, rememberMe}

extractRenewPinBody = ->

    # username = ""+codeRenewSvnPartInput.value+codeRenewBirthdayPartInput.value
    svn_pin1 = ""+codeRenewSvnPartInput.value
    svn_pin2 = ""+codeRenewBirthdayPartInput.value
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
focusBirthdayInput = ->
    birthdayInput.focus()
    # svnPartInput.focus()

focusCodeInput = ->
    codeInput.setSelectionRange(0, 0)
    codeInput.focus()



focusPinRenewSVNPartLast = ->
    codeRenewSvnPartInput.setSelectionRange(4, 4)
    codeRenewSvnPartInput.focus()

focusPinRenewBirthdayPartFirst = ->
    codeRenewBirthdayPartInput.setSelectionRange(0, 0)
    codeRenewBirthdayPartInput.focus()


#endregion


############################################################
export enterWasClicked = (evt) -> codeSubmitClicked(evt)

export onPageViewEntry = ->
    log "onPageViewEntry"
    # setTimeout(focusBirthdayInput, 400)
    setTimeout(focusCodeInput, 400)
    return


