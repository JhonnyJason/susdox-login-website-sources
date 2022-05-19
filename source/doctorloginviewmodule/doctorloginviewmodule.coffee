############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("doctorloginform")
#endregion

import * as S from "./statemodule.js"

############################################################
export initialize = ->
    log "initialize"
    doctorloginHeading.addEventListener("click", backButtonClicked)
    return

############################################################
# using History
# backButtonClicked = -> window.history.back()

############################################################
# no History
backButtonClicked = -> S.save("loginView", "none")
