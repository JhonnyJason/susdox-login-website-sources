############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("compatibitlityloginviewmodule")
#endregion

############################################################
import { ScrollRollDatepicker } from "./scrollrolldatepickermodule.js"

############################################################import * as S from "./statemodule.js"
import * as utl from "./utilmodule.js"
import * as triggers from "./navtriggers.js"

import { resetAllErrorFeedback, errorFeedback } from "./errorfeedbackmodule.js"
import { legacyLoginURL, loginRedirectURL, requestCodeURL } from "./configmodule.js"


############################################################
#region inputField Length tracking
svnPartLength = 0
svnBirthdayPartLength = 0

pinRenewSvnPartLength = 0
pinRenewBirthdayPartLength = 0

#endregion

############################################################
phoneNumberRegex = /^\+?[0-9]+$/gm

############################################################
noSVNDatePicker = null
requestDatePicker = null

############################################################
export initialize = ->
    log "initialize"
    compatibilityloginHeading.addEventListener("click", triggers.back)
    svnSubmitButton.addEventListener("click", svnSubmitClicked)
    authcodeSubmitButton.addEventListener("click", authcodeSubmitClicked)
    requestCodeSubmitButton.addEventListener("click", requestCodeSubmitClicked)

    svnPartInput.addEventListener("keyup", svnPartKeyUpped)
    birthdayPartInput.addEventListener("keyup", birthdayPartKeyUpped)

    noPinQuestion.addEventListener("click", noPinQuestionClicked)

    linkButtons = compatibilityloginview.getElementsByClassName("link-button")
    # console.log("number of link buttons: #{linkButtons.length}")
    linkButtons[0].addEventListener("click", supportButtonClicked)

    svnPartLength = svnPartInput.value.length
    svnBirthdayPartLength = birthdayPartInput.value.length

    try
        options =
            element: "authcode-birthday-input"
            # height: 32
        noSVNDatePicker = new ScrollRollDatepicker(options)
        noSVNDatePicker.initialize()

        options =
            element: "request-birthday-input"
            # height: 32
        requestDatePicker = new ScrollRollDatepicker(options)
        requestDatePicker.initialize()

    catch err then log err

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
        if newLength == 6 then focusPinInput()
        return

    if svnBirthdayPartLength == 0 then focusSVNPartLast()
    else svnBirthdayPartLength = newLength
    return

pinRenewSVNPartKeyUpped = (evt) ->
    # log "pinRenewSVNPartKeyUpped"
    value = compatibilityPinRenewSvnPartInput.value
    pinRenewSvnPartLength = value.length
    # olog {newLength}

    if evt.keyCode == 46 then return

    if evt.keyCode == 8 then return

    if pinRenewSvnPartLength == 4 then focusPinRenewBirthdayPartFirst()
    return

pinRenewBirthdayPartKeyUpped = (evt) ->
    # log "pinRenewBirthdayPartKeyUpped"
    value = compatibilityPinRenewBirthdayPartInput.value
    newLength = value.length
    # olog {newLength}

    if evt.keyCode != 8
        pinRenewBirthdayPartLength = newLength
        return

    if pinRenewBirthdayPartLength == 0 then focusPinRenewSVNPartLast()
    else pinRenewBirthdayPartLength = newLength
    return

noPinQuestionClicked = ->
    log "noPinQuestionClicked"
    extensionBlock = requestcodeformblock.getElementsByClassName("extension-block-content")[0]
    extensionBlock.classList.toggle("shown")
    return

#endregion

############################################################
# using History

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
        else
            #alert("redirect to: #{loginRedirectURL}") 
            location.href = loginRedirectURL

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
        else 
            #alert("redirect to: #{loginRedirectURL}") 
            location.href = loginRedirectURL

    catch err then return errorFeedback("svnPatient", "Other: " + err.message)
    finally svnSubmitButton.disabled = false
    return

requestCodeSubmitClicked = (evt) ->
    log "requestCodeSubmitClicked"
    evt.preventDefault()
    requestCodeSubmitButton.disabled = true
    try
        resetAllErrorFeedback()        
        if !requestDatePicker.value and !requestPhoneInput.value then return

        requestCodeBody = extractRequestCodeBody()
        olog { requestCodeBody } 
    
        response = await doRequestCode(requestCodeBody)
        if !response.ok then errorFeedback("requestCode", ""+response.status)
        else
            requestDatePicker.reset()
            requestPhoneInput.value = ""
        
    catch err then return errorFeedback("requestCode", "Other: " + err.message)
    finally requestCodeSubmitButton.disabled = false
    return

############################################################
supportButtonClicked = (evnt) ->
    log "supportButtonClicked"
    evnt.preventDefault()
    location.href = "support.html#patient-registration"
    return

############################################################
extractSVNFormBody = ->

    isMedic = false
    rememberMe = false
    
    username = ""+svnPartInput.value+birthdayPartInput.value
    password = ""+pinInput.value
    pw = password

    if !password then hashedPw = ""
    else hashedPw = await computeHashedPw(username, password)
    
    return {username, hashedPw, pw, isMedic, rememberMe}

extractNoSVNFormBody = ->

    isMedic = false
    rememberMe = false

    username = noSVNDatePicker.value
    # console.log(username)
    password = "AT-"+authcodeInput.value
    pw = password
    ## Testing
    # username = "mengelhardt"
    # password = "medexdoc"

    if password == "AT-" then hashedPw = ""
    else hashedPw = await computeHashedPw(username, password)
    
    # console.log(hashedPw)
    return {username, hashedPw, pw, isMedic, rememberMe}

extractRequestCodeBody = ->
    log "extractRequestCodeBody"
    dateOfBirth = requestDatePicker.value
    phoneNumber = requestPhoneInput.value.replaceAll(/[ \-\(\)]/g, "")
    
    phoneNumberValid = phoneNumber.length > 6 and phoneNumber.length < 25
    if phoneNumberValid then phoneNumberValid = phoneNumberRegex.test(phoneNumber)

    if !phoneNumberValid then throw new InputError("Fehler in der Telefonnummer!")
    if !dateOfBirth then throw new InputError("Kein Geburtsdatum gewählt!")

    return {dateOfBirth, phoneNumber}

############################################################
computeHashedPw = (username, pwd) ->
    return utl.hashUsernamePw(username, pwd)

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

    try return fetch(legacyLoginURL, fetchOptions)
    catch err then log err

doRequestCode = (body) ->
    method = "POST"
    mode = 'cors'
    
    # # url encoded
    # headers = { 'Content-Type': 'application/x-www-form-urlencoded' }
    # body = new URLSearchParams(body)

    headers = { 'Content-Type': 'application/json' }
    body = JSON.stringify(body)
    
    fetchOptions = { method, mode, headers, body }

    try return fetch(requestCodeURL, fetchOptions)
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

focusPinInput = -> pinInput.focus()

focusPinRenewSVNPartLast = ->
    compatibilityPinRenewSvnPartInput.setSelectionRange(4, 4)
    compatibilityPinRenewSvnPartInput.focus()

focusPinRenewBirthdayPartFirst = ->
    compatibilityPinRenewBirthdayPartInput.setSelectionRange(0, 0)
    compatibilityPinRenewBirthdayPartInput.focus()


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

