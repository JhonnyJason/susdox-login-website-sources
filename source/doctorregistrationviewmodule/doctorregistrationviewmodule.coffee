############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("doctorregistrationviewmodule")
#endregion

############################################################
import * as S from "./statemodule.js"
import * as triggers from "./navtriggers.js"

############################################################
export initialize = ->
    log "initialize"
    doctorregistrationviewHeading.addEventListener("click", triggers.back)
    doctorregistrationSubmitButton.addEventListener("click", submitButtonClicked)
    return

############################################################
# using History

############################################################
submitButtonClicked = ->
    log "submitButtonClicked"
    return

############################################################
export onPageViewEntry = ->
    # TODO focus on initial field
    return