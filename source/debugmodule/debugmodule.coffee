import { addModulesToDebug } from "thingy-debug"

############################################################
export modulesToDebug = 
    unbreaker: true
    # configmodule: true
    # statemodule: true
    errorfeedbackmodule: true
    patientloginviewmodule: true
    doctorloginviewmodule: true
    registrationviewmodule: true
    utilmodule: true

addModulesToDebug(modulesToDebug)