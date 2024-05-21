############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("patientregistrationviewmodule")
#endregion

############################################################
import * as S from "./statemodule.js"
import * as triggers from "./navtriggers.js"

############################################################
export initialize = ->
    log "initialize"
    patientregistrationviewHeading.addEventListener("click", triggers.back)
    patientregistrationSubmitButton.addEventListener("click", submitButtonClicked)
    return

############################################################
# using History
############################################################
# no History

############################################################
submitButtonClicked = ->
    log "submitButtonClicked"
    return

############################################################
export onPageViewEntry = ->
    # TODO focus on initial field
    return