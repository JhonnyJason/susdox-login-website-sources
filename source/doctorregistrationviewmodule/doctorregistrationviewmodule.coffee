############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("doctorregistrationviewmodule")
#endregion

############################################################
import * as S from "./statemodule.js"

############################################################
export initialize = ->
    log "initialize"
    doctorregistrationviewHeading.addEventListener("click", backButtonClicked)
    doctorregistrationSubmitButton.addEventListener("click", submitButtonClicked)
    return

############################################################
# using History
backButtonClicked = -> window.history.back()

############################################################
submitButtonClicked = ->
    log "submitButtonClicked"
    return

############################################################
export onPageViewEntry = ->
    # TODO focus on initial field
    return