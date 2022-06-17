############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("patientregistrationviewmodule")
#endregion

############################################################
import * as S from "./statemodule.js"

############################################################
export initialize = ->
    log "initialize"
    patientregistrationviewHeading.addEventListener("click", backButtonClicked)
    patientregistrationSubmitButton.addEventListener("click", submitButtonClicked)
    return

############################################################
# using History
backButtonClicked = -> window.history.back()

############################################################
# no History
# backButtonClicked = -> S.set("registrationView", "none")

############################################################
submitButtonClicked = ->
    log "submitButtonClicked"
    return

############################################################
export onPageViewEntry = ->
    # TODO focus on initial field
    return