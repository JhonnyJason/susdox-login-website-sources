############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("doctorregistrationviewmodule")
#endregion

############################################################
import {supportRequestURL} from "./configmodule.js"

############################################################
import * as S from "./statemodule.js"
import * as triggers from "./navtriggers.js"
import * as utl from "./utilmodule.js"

############################################################
export initialize = ->
    log "initialize"
    doctorregistrationviewHeading.addEventListener("click", triggers.back)
    doctorregistrationForm.addEventListener("submit", doctorregistrationFormSubmitted)
    return

############################################################
# using History

############################################################
doctorregistrationFormSubmitted = (evnt) ->
    log "doctorregistrationFormSubmitted"
    evnt.preventDefault()

    formJSON = utl.extractJsonFormData(doctorregistrationForm)
    formJSON.isMedic = true

    olog formJSON

    try
        doctorregistrationSubmitButton.disabled = true
        response = await doSupportRequest(formJSON)
        if response.ok then setSuccessFrame()
        else throw new Error("Response Status: #{response.status}")
    catch err then log err
    finally doctorregistrationSubmitButton.disabled = false
    return

############################################################
setSuccessFrame = ->
    log "setSuccessFrame"
    doctorregistrationview.classList.add("success")
    document.body.style.height = ""+doctorregistrationview.clientHeight+"px"
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
export onPageViewEntry = ->
    doctorregistrationview.classList.remove("success")

    # TODO focus on initial field
    return