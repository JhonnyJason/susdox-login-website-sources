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
    # open new link in new tab
    window.open('https://forms.monday.com/forms/c5fe9d109217da4d38a65f1fb92bc910?r=euc1&name=Ihre%20Supportanfrage%20zu%20Bilder%20und%20Befunde&type=arzt&status=offen')

    ## old direct link
    # location.href = 'https://forms.monday.com/forms/c5fe9d109217da4d38a65f1fb92bc910?r=euc1&name=&type=Arzt%20Supportanfrage%20zu%20Bilder%20und%20Befunde'
    return
    # return await nav.toBaseAt("doctor-registration", null, 1)

############################################################
export patientRegistration = ->
    log "patientRegistration"
    # open new link in new tab
    window.open('https://forms.monday.com/forms/7b143b2a59073b47d74a77d1d0daa947?r=euc1&name=Ihre%20Supportanfrage%20zu%20Bilder%20und%20Befunde&type=patient&status=offen')
    
    ## old direct link
    # location.href = 'https://forms.monday.com/forms/7b143b2a59073b47d74a77d1d0daa947?r=euc1&name=Patienten%20Supportanfrage%20zu%20Bilder%20und%20Befunde'
    return
    # return await nav.toBaseAt("patient-registration", null, 1)


############################################################
export back = ->
    return await nav.back(1)