############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("registrationform")
#endregion

############################################################
import * as S from "./statemodule.js"

############################################################
export initialize = ->
    log "initialize"
    registrationviewHeading.addEventListener("click", backButtonClicked)
    registrationSubmitButton.addEventListener("click", submitButtonClicked)

    #Implement or Remove :-)
    return

############################################################
backButtonClicked = -> S.save("registrationFormHere", false)

############################################################
submitButtonClicked = ->
    log "submitButtonClicked"
    return