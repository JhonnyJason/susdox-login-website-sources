############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("susdoxshareloginmodule")
#endregion

############################################################
import * as utl from "./utilmodule.js"

############################################################
import { ScrollRollDatepicker } from "./scrollrolldatepickermodule.js"

############################################################
import { resetAllErrorFeedback, errorFeedback } from "./errorfeedbackmodule.js"
import { loginSusdoxShareURL, redirectSusdoxShareURL } from "./configmodule.js"

############################################################
codeSeparator = "-"

############################################################
isActive = false

############################################################
datePicker = null
extensionBlock = null

############################################################
currentCode = ""
currentFormatted = ""

#susdoxshare-login-form -> susdoxshareLoginForm
#susdoxshare-input -> susdoxshareInput                
#susdoxshare-birthday-input -> susdoxshareBirthdayInput 
#susdoxshare-error-feedback-text -> susdoxshareErrorFeedbackText
#susdoxshare-submit-button susdoxshareSubmitButton

############################################################
letMainThreadRun = ->
    if window.scheduler? and window.scheduler.yield? then return scheduler.yield()
    return new Promise((reslv) -> setTimeout(reslv, 0))

############################################################
export initialize = ->
    log "initialize"
    return unless susdoxshareLoginForm? 
    susdoxshareLoginForm.addEventListener("submit", onFormSubmit)

    susdoxshareInput.addEventListener("keydown", inputKeyDowned)
    susdoxshareInput.addEventListener("input", onInput)

    try
        extensionBlock = susdoxshareloginBlock.getElementsByClassName("extension-block-content")[0]
    
        options =
            element: "susdoxshare-birthday-input"
        datePicker = new ScrollRollDatepicker(options)
        datePicker.initialize()
    catch err then log err
    return

############################################################
#region Event Listeners
onFormSubmit = (evnt) ->
    log "onFormSubmit"
    evnt.preventDefault()
    susdoxshareSubmitButton.disabled = true
    try
        resetAllErrorFeedback()

        loginBody = await extractCodeFormBody()
        olog {loginBody}

        if !loginBody.hashedPw and !loginBody.username then return focusCodeInput()
            # return errorFeedback("codeSusdoxshare", "input")


        # errorFeedback("codeSusdoxshare", "404")
        # errorFeedback("codeSusdoxshare", "401")
        # errorFeedback("codeSusdoxshare", "input")
        response = await doLoginRequest(loginBody)
        if !response.ok then errorFeedback("codeSusdoxshare", ""+response.status)
        else 
            try res = await response.json()
            catch err then log err
            if res?.redirect_url then window.location.replace(res.redirect_url)          
            # else window.location.replace(redirectSusdoxShareURL)
            return

    catch err then return errorFeedback("codeSusdoxshare", "Other: " + err.message)
    finally susdoxshareSubmitButton.disabled = false
    return

    return

############################################################
inputKeyDowned = (evnt) ->
    log "inputKeyDowned"

    # 13 is enter
    if evnt.keyCode == 13
        if datePicker.value then onFormSubmit(evnt)
        else 
            evnt.preventDefault()
            focusBirthdayInput()
        return

    # 27 is escape
    if evnt.keyCode == 27 
        susdoxshareInput.blur()
        turnDown()

    return

onInput = (evnt) ->
    log "onInput"
    { raw, formatted } = formatCode(susdoxshareInput.value)
    currentCode = raw

    oldCursor = susdoxshareInput.selectionStart

    log oldCursor
    switch(oldCursor)
        when 4,5 then newCursor = 6
        when 9,10 then newCursor = 11
        else newCursor = oldCursor
    log newCursor

    susdoxshareInput.value = formatted
    susdoxshareInput.setSelectionRange(newCursor, newCursor)
    return

#endregion

############################################################
formatCode = (uiString) ->
    log "formatCode: "+uiString
    raw = ""
    for c in uiString when utl.isAlphanumericString(c)
        raw += c.toLowerCase()
    
    raw = raw.slice(0, 9)
    rLen = raw.length

    tokens = []
    tokens.push(raw.slice(0, 3)) if rLen > 0
    tokens.push(raw.slice(3, 6)) if rLen > 3
    tokens.push(raw.slice(6)) if rLen > 6

    formatted = tokens.join(codeSeparator)
    olog { raw, formatted }

    return { raw, formatted }

############################################################
extractCodeFormBody = ->
    username = datePicker.value
    if !username then return {}

    code = currentCode
    isMedic = false
    rememberMe = false

    ## version, sending plaintext code for 6-digit code and accept 6-digi code with prefix "at"
    # if code.length == 9 then hashedPw = await utl.argon2HashPw(code, username)
    # # else if code.length == 6 then hashedPw = await utl.hashUsernamePw(username, code)
    # else if code.length == 6 then hashedPw = code
    # else if code.length == 8 and (code.indexOf("at")==0) then hashedPw = code.slice(2)
    # else throw new Error("Unexpected code Length!")

    ## version, always using argon2 hash
    if code.length == 9 then hashedPw = await utl.argon2HashPw(code, username)
    else 
        console.error("Unexpected code Length! ("+code+") -> invalid input!")
        return {}

    return { username, hashedPw, isMedic, rememberMe }

# ############################################################
# computeHashedPw = (username, pwd) ->
#     return utl.hashUsernamePw(username, pwd)

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

    try return fetch(loginSusdoxShareURL, fetchOptions)
    catch err then log err

############################################################
ensureVisibleInputFields = ->
    currentPos = document.documentElement.scrollTop || document.body.scrollTop
    console.log("currentPos: "+currentPos)
    console.log("document.body.scrollHeight: "+document.body.scrollHeight)
    console.log("window.screen.height: "+window.screen.height)

    scrollDestination = document.body.scrollHeight - window.screen.height - 180
    console.log("scrollDestination: "+scrollDestination)

    if currentPos > scrollDestination then return

    window.scrollTo({ 
        top: scrollDestination, 
        behavior: "smooth"
    });
    return


############################################################
focusBirthdayInput = -> susdoxshareBirthdayInput.focus()

focusCodeInput = ->
    susdoxshareInput.setSelectionRange(0, 0)
    susdoxshareInput.focus()


############################################################
setUIState = ->
    if isActive
        extensionBlock.classList.add("shown")
        focusCodeInput()
        await letMainThreadRun()
        ensureVisibleInputFields()
    else extensionBlock.classList.remove("shown")
    ## TODO focus on the code input
    return

############################################################
export toggleActive = ->
    return unless susdoxshareLoginForm? 
    log "activate"
    isActive = !isActive
    setUIState()
    return

export turnDown = ->
    return unless susdoxshareLoginForm? 

    isActive = false
    setUIState()
    return