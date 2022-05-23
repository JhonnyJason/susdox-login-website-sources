import { addModulesToDebug } from "thingy-debug"

############################################################
export modulesToDebug = 
    unbreaker: true
    # configmodule: true
    # statemodule: true
    patientloginviewmodule: true
    doctorloginviewmodule: true
    registrationviewmodule: true

addModulesToDebug(modulesToDebug)