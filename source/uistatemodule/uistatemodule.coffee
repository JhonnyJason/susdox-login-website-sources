############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("uistatemodule")
#endregion

############################################################
import * as patientLoginView from "./patientloginviewmodule.js"
import * as doctorLoginView from "./doctorloginviewmodule.js"
import * as compatibilityLoginView from "./compatibilityloginviewmodule.js"

############################################################
import * as patientRegistrationView from "./patientregistrationviewmodule.js"
import * as doctorRegistrationView from "./doctorregistrationviewmodule.js"

############################################################
applyBaseState = {}

############################################################
currentBase = null

############################################################
applyBaseState["index"] = ->
    doctorloginview.classList.remove("here")
    patientloginview.classList.remove("here")
    compatibilityloginview.classList.remove("here")

    document.body.style.height = "auto"
    return

############################################################
applyBaseState["patient-login"] = ->
    ## actually is compatibility state...
    patientloginview.classList.remove("here")
    doctorloginview.classList.remove("here")
    compatibilityloginview.classList.add("here")

    document.body.style.height = ""+compatibilityloginview.clientHeight+"px"
    
    compatibilityLoginView.onPageViewEntry()

    ## this is real patient login state
    # doctorloginview.classList.remove("here")
    # compatibilityloginview.classList.remove("here")
    # patientloginview.classList.add("here")

    # location.hash = "#patient-login"

    # document.body.style.height =""+patientloginview.clientHeight+"px"

    # allModules.patientloginviewmodule.onPageViewEntry()
    return

############################################################
applyBaseState["doctor-login"] = ->

    patientloginview.classList.remove("here")
    compatibilityloginview.classList.remove("here")
    doctorloginview.classList.add("here")

    document.body.style.height = ""+doctorloginview.clientHeight+"px"
    
    doctorLoginView.onPageViewEntry()
    return

############################################################
applyBaseState["support"] = ->
    doctorregistrationview.classList.remove("here")
    patientregistrationview.classList.remove("here")

    document.body.style.height = "auto"
    return

applyBaseState["patient-registration"] = ->
    doctorregistrationview.classList.remove("here")
    patientregistrationview.classList.add("here")

    document.body.style.height = ""+patientregistrationview.clientHeight+"px"
    patientRegistrationView.onPageViewEntry()    
    return

applyBaseState["doctor-registration"] = ->    
    doctorregistrationview.classList.add("here")
    patientregistrationview.classList.remove("here")

    document.body.style.height = ""+doctorregistrationview.clientHeight+"px"
    doctorRegistrationView.onPageViewEntry()
    return


############################################################
export applyUIStateBase = (base) ->
    log "applyUIBaseState #{base}"
    applyBaseFunction = applyBaseState[base]

    if typeof applyBaseFunction != "function" then throw new Error("on applyUIStateBase: base '#{base}' apply function did not exist!")

    currentBase = base
    applyBaseFunction()
    return

############################################################
export getBase = -> currentBase
