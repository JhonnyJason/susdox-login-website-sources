############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("navtriggers")
#endregion

############################################################
import * as nav from "navhandler"


############################################################
export patientLogin = ->
    log "patientLogin"
    return await nav.toBaseAt("patient-login", null, 1)

############################################################
export doctorLogin = ->
    log "doctorLogin"
    return await nav.toBaseAt("doctor-login", null, 1)


############################################################
export doctorRegistration = ->
    log "doctorRegistration"
    return await nav.toBaseAt("doctor-registration", null, 1)

############################################################
export patientRegistration = ->
    log "patientRegistration"
    return await nav.toBaseAt("patient-registration", null, 1)


############################################################
export back = ->
    return await nav.back(1)