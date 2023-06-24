############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("patientloginviewmodule")
#endregion

############################################################
import { ScrollRollDatepicker } from "./scrollrolldatepickermodule.js"

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

currentCode = ""

#endregion

############################################################
datePicker = null

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
    # accessCompatibilityButton.addEventListener("click", accessCompatibilityButtonClicked)

    codeInput.addEventListener("keydown", codeInputKeyDowned)
    codeInput.addEventListener("keyup", codeInputKeyUpped)

    noCodeQuestion.addEventListener("click", noCodeQuestionClicked)
    codeRenewSvnPartInput.addEventListener("keyup", pinRenewSVNPartKeyUpped)
    codeRenewBirthdayPartInput.addEventListener("keyup", pinRenewBirthdayPartKeyUpped)

    pinRenewSvnPartLength = codeRenewSvnPartInput.value.length
    pinRenewBirthdayPartLength = codeRenewBirthdayPartInput.value.length

    options =
        element: "birthday-input"
        # height: 32
    datePicker = new ScrollRollDatepicker(options)
    datePicker.initialize()

    return

############################################################
#region keyUpListeners
codeInputKeyDowned = (evt) ->
    log "codeInputKeyDowned"

    # 13 is enter
    if evt.keyCode == 13
        evt.preventDefault()
        codeSubmitButtonClicked()
        return    
    # 46 is delete
    if evt.keyCode == 46 then return    
    # 8 is backspace
    if evt.keyCode == 8 then return
    # 27 is escape
    if evt.keyCode == 27 then return

    rawCode = codeInput.value.replaceAll(" ", "").toLowerCase()
    if rawCode != currentCode then rawCode = currentCode
    rLen = rawCode.length

    codeTokens = []
    
    if rLen > 0
        codeTokens.push(rawCode.slice(0,3))
    if rLen > 3
        codeTokens.push(rawCode.slice(3,6))
    if rLen > 6
        codeTokens.push(rawCode.slice(6))
    newValue = codeTokens.join("  ")

    if (rLen == 3 or rLen == 6) then rawCode += "  "    

    codeInput.value = newValue
    return

codeInputKeyUpped = (evt) ->
    log "codeInputKeyUpped"

    rawCode = codeInput.value.replaceAll(" ", "").toLowerCase()
    log "rawCode #{rawCode}"
    newCode = ""
    # filter out all the illegal characters
    for c in rawCode when utl.isAlphanumericString(c)
        newCode += c

    rLen = newCode.length
    if rLen > 9 then newCode = newCode.slice(0, 9)
    currentCode = newCode
    rLen = newCode.length

    codeTokens = []
    
    log "newCode #{newCode}"
    if rLen > 0
        codeTokens.push(newCode.slice(0,3))
    if rLen > 3
        codeTokens.push(newCode.slice(3,6))
    if rLen > 6
        codeTokens.push(newCode.slice(6))
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

# accessCompatibilityButtonClicked = ->
#     log "accessCompatibilityButtonClicked"
#     S.save("loginView", "compatibility")
#     return
    
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
    username = datePicker.value
    if !username then return {}

    code = codeInput.value.replaceAll(" ", "").toLowerCase()
    # if !utl.isBase32String(code) then return {}
    if !utl.isAlphanumericString(code) then return {}

    isMedic = false
    rememberMe = false

    ## version, sending plaintext code for 6-digit code and accept 6-digi code with prefix "at"
    # if code.length == 9 then hashedPw = await utl.argon2HashPw(code, username)
    # # else if code.length == 6 then hashedPw = await utl.hashUsernamePw(username, code)
    # else if code.length == 6 then hashedPw = code
    # else if code.length == 8 and (code.indexOf("at")==0) then hashedPw = code.slice(2)
    # else throw new Error("Unexpected code Length!")

    ## version, always using argon2 hash
    if code.length == 8 and (code.indexOf("at")==0) then code = code.slice(2)
    if code.length == 9 or code.length == 6 then hashedPw = await utl.argon2HashPw(code, username)
    else throw new Error("Unexpected code Length!")

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


