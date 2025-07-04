############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("patientregistrationviewmodule")
#endregion

############################################################
import {ScrollRollDatepicker} from "./scrollrolldatepickermodule.js"
import {supportRequestURL, requestCodeURL} from "./configmodule.js"

############################################################
import * as S from "./statemodule.js"
import * as triggers from "./navtriggers.js"
import * as utl from "./utilmodule.js"

############################################################
import { resetAllErrorFeedback, errorFeedback } from "./errorfeedbackmodule.js"

############################################################
questionDatePicker = null
requestDatePicker = null
datePickerIsInitialized = false


############################################################
phoneNumberRegex = /^\+?[0-9]+$/gm

############################################################
# temporarily deprecated
# export initialize = ->
#     log "initialize"
#     patientregistrationviewHeading.addEventListener("click", triggers.back)
#     patientsupportForm.addEventListener("submit", patientsupportFormSubmitted)
#     requestCodeForm.addEventListener("submit", requestCodeSubmitted)
#     # noPinQuestion.addEventListener("click", noPinQuestionClicked)
#     return

############################################################
# using History
############################################################
# no History

noPinQuestionClicked = -> 
    log "noPinQuestionClicked"
    extensionBlock = requestcodeformblock.getElementsByClassName("extension-block-content")[0]
    extensionBlock.classList.toggle("shown")
    return

extractRequestCodeBody = ->
    log "extractRequestCodeBody"
    dateOfBirth = requestDatePicker.value
    phoneNumber = requestPhoneInput.value.replaceAll(/[ \-\(\)]/g, "")
    
    phoneNumberValid = phoneNumber.length > 6 and phoneNumber.length < 25
    if phoneNumberValid then phoneNumberValid = phoneNumberRegex.test(phoneNumber)

    if !phoneNumberValid then throw new InputError("Fehler in der Telefonnummer!")
    if !dateOfBirth then throw new InputError("Kein Geburtsdatum gewählt!")

    return {dateOfBirth, phoneNumber}

doRequestCode = (body) ->
    method = "POST"
    mode = 'cors'

    headers = { 'Content-Type': 'application/json' }
    body = JSON.stringify(body)
    
    fetchOptions = { method, mode, headers, body }
    
    try return fetch(requestCodeURL, fetchOptions)
    catch err then log err

############################################################
requestCodeSubmitted = (evnt) ->
    log "requestCodeSubmitted"
    evnt.preventDefault()
    requestCodeSubmitButton.disabled = true
    try
        resetAllErrorFeedback()        
        if !requestDatePicker.value and !requestPhoneInput.value then return

        try requestCodeBody = extractRequestCodeBody()
        catch err then return errorFeedback("requestCode", "input")
        olog { requestCodeBody } 
    
        response = await doRequestCode(requestCodeBody)
        if !response.ok then errorFeedback("requestCode", ""+response.status)
        else
            codeRequestSuccessFeedback()
            requestDatePicker.reset()
            requestPhoneInput.value = ""
        
    catch err then return errorFeedback("requestCode", "Other: " + err.message)
    finally requestCodeSubmitButton.disabled = false
    return


patientsupportFormSubmitted = (evnt) ->
    log "patientsupportFormSubmitted"
    evnt.preventDefault()

    formJSON = utl.extractJsonFormData(patientsupportForm)

    formJSON.birthday = questionDatePicker.value
    formJSON.isMedic = false
    olog formJSON

    try
        patientregistrationSubmitButton.disabled = true
        response = await doSupportRequest(formJSON)
        if response.ok then setSuccessFrame()
        else throw new Error("Response Status: #{response.status}")
    catch err then log err
    finally patientregistrationSubmitButton.disabled = false
    return

############################################################
setSuccessFrame = ->
    log "setSuccessFrame"
    patientregistrationview.classList.add("success")
    document.body.style.height = ""+patientregistrationview.clientHeight+"px"
    return


############################################################
doSupportRequest = (body) ->
    log "doSupportRequest"
    method = "POST"
    mode = 'cors'
    
    # json body
    headers = { 'Content-Type': 'application/json' }
    body = JSON.stringify(body)

    fetchOptions = { method, mode, headers, body }

    try return fetch(supportRequestURL, fetchOptions)
    catch err then log err
    return

############################################################
initializeDatePickers = ->
    try
        options =
            element: "patient-birthday-input"
        questionDatePicker = new ScrollRollDatepicker(options)
        options = 
            element: "request-birthday-input"
        requestDatePicker = new ScrollRollDatepicker(options)

        questionDatePicker.initialize()
        requestDatePicker.initialize()

        datePickerIsInitialized = true
    catch err then log err

############################################################
export onPageViewEntry = ->
    if !datePickerIsInitialized then initializeDatePickers()
    patientregistrationview.classList.remove("success")
    # TODO focus on initial field
    return
