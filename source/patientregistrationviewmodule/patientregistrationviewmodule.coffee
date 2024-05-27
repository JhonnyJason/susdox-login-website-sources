############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("patientregistrationviewmodule")
#endregion

############################################################
import {ScrollRollDatepicker} from "./scrollrolldatepickermodule.js"
import {supportRequestURL} from "./configmodule.js"

############################################################
import * as S from "./statemodule.js"
import * as triggers from "./navtriggers.js"
import * as utl from "./utilmodule.js"

############################################################
datePicker = null
datePickerIsInitialized = false

############################################################
export initialize = ->
    log "initialize"
    patientregistrationviewHeading.addEventListener("click", triggers.back)
    patientsupportForm.addEventListener("submit", patientsupportFormSubmitted)
    return

############################################################
# using History
############################################################
# no History

############################################################
patientsupportFormSubmitted = (evnt) ->
    log "patientsupportFormSubmitted"
    evnt.preventDefault()

    formJSON = utl.extractJsonFormData(patientsupportForm)

    formJSON.birthday = datePicker.value
    formJSON.isMedic = false
    olog formJSON
    
    doSupportRequest(formJSON)
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
initializeDatePicker = ->
    try
        options =
            element: "patient-birthday-input"
        datePicker = new ScrollRollDatepicker(options)
        datePicker.initialize()
        datePickerIsInitialized = true
    catch err then log err

############################################################
export onPageViewEntry = ->
    if !datePickerIsInitialized then initializeDatePicker()
    # TODO focus on initial field
    return
